/****************************************************************************************************************************************************************
    Programmer: Matthew Keefe
    Developer:  Tony Williams
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Order Entry in Salesforce
    Created:    08/13/2010
    Updated:    10/01/2010 - added QueueGenerateAllBackorderPickTickets to generate all backorder pick tickets
    Updated:    10/01/2010 - added CancelBackorderedLines functionality
    Updated:    12/12/2011 - added QuantityGivenAway field for promotionals. (T.W.)
    Updated:    01/12/2012 - Added promo code field to pick ticket line item generation and OLI queries (T.W.)
    Updated:    04/03/2012 - Added an additional AND clause to not create closed tickets if a back order item is Discount 77777
    Updated:    04/21/2012 - Added Company value to each pick tickets created closed or opened.
    Updated:    06/16/2012 - Added check for Line Type = 'SB' (Subscriptions because they are non-stock as well.)
    Updated:    09/10/2012 - Added New Discount codes 77780 and 77778 to calculate Discounted line times and remove them from true Backorder items.
    Updated:    03/18/2013 - Added New Handling of pick ticketrs for new payment term "To Be Filled" which creates a closed pick ticket.  
    Updated:    04/25/2013 - Removing JDE Item variables in  test cases.
    Updated:    05/21/2013 -  Added PreOrder Handling value to Line Item which will be used in Pick Ticket.
    Updated:    02-26-2014 - Removed the FIP tables used for OrderEntryStatus Page. I was told by Tim and Jen that we don;t need them anymore.
    Updated:    03/04/2014 - Added QGA To the QTY Ordered for latest Spring Stock up sale (BOGO).
    Updated:    07/29/2014 - FRT RECONSTRCTION: Added Weight attributes to all Order, PIck List Item, and Order Line Item SOQL queries and objhects which require it.
    Updated:    09/8/2014 - FRT RECONSTRUCTION: Added updates for Pitney Bowse Webservice call out using PB Integration for CancelBackorderItems() method.
    Updated:    09/08/2014 - FRT RECONSTRUCTION: Added code for handling Rush FRT for processing queued Pick Tickets for Jennifer.
    Updated:    09/23/2014 - <FRT RECONTSRUCT>  Updated the WSDL call to include parameter Customer ID( Mailing Address Book) to the service port method.   
    Updated:    09/25/2014 - <FRT RECONTSRUCT>  Removed all instanced of Freight Calculation in CancelBackOrderItems() method. We don;t really update freight but just get rid of the BO product item
    Updated:    09/17/2015 - Optimized the general query string - Query -  using LAST_YEAR date literal for all status types especially BO because the lag time is great.
    Updated:    01/21/2015 - Decrementing Product's Qantity in Pick Pick Bin field needs to be decremented every time a Pick Ticket Quantity (QTY on Pick ) is incremented.
    Updated:    02/14/2015 - <ASP-893> - Updated the PickTicketLine Item Creation by removing the defunct OrderItem.PriceBookEntry.Product2Id attribute and just used OrderItem.Product2Id which is the correct
                            for this object (OrderItem).
 **************************************************************************************************************************************************************************************************************/ 
 
global class OrderEntryStatus
{
    public Boolean IsTest = false;
    public Boolean getIsTest() { return IsTest; }
    public void setIsTest(Boolean value) { IsTest = value; }
    
    public String ContentType=null;
    public String getContentType() { return ContentType; }
    
    public String StatusType='errors';
    public String getStatusType() { return StatusType; }
    public void setStatusType(String value) { StatusType=value; }

    public Boolean UseCustomQuery = false;
    public Boolean getUseCustomQuery() { return UseCustomQuery; }
    public void setUseCustomQuery(Boolean value) { UseCustomQuery = value; }
    public void callUseCustomQuery() {}

    public String CustomQuery=null;
    public String getCustomQuery() { return CustomQuery; }
    public void setCustomQuery(String value) { CustomQuery=value; }
    
    public String CustomNameSearch=null;
    public String getCustomNameSearch() { return CustomNameSearch; }
    public void setCustomNameSearch(String value) { CustomNameSearch=value; }
    
    public String OrderId = null;
    public String getOrderId() { return OrderId; }
    public void setOrderId(String value) { OrderId=value; }
    
    public String OrderStatus = null;
    public String getOrderStatus() { return OrderStatus; }
    public void setOrderStatus(String value) { OrderStatus=value; }
    
    public List<Order> Orders = null;
    public List<Order> getOrders() { return Orders; }
    public Integer getOrdersSize() { if(Orders != null) { return Orders.size(); } else { return 0; } }
    
    public Integer TotalBatchJobs = 0;
    public Integer getTotalBatchJobs() { return TotalBatchJobs; }
    
    public Integer TotalProcessingBatchJobs = 0;
    public Integer getTotalProcessingBatchJobs() { return TotalProcessingBatchJobs; }
    
    public Integer OrdersToPickLimit = 0;
    public Integer getOrdersToPickLimit() { return OrdersToPickLimit; }
    public void setOrdersToPickLimit(Integer value) { OrdersToPickLimit=value; }
    
    public ApexPages.StandardSetController SetController { get;set; }
    public Integer getSetControllerPageSize() { if(SetController != null) { return SetController.getPageSize(); } else { return 0; } }
    public Integer getSetControllerPageNumber() { if(SetController != null) { return SetController.getPageNumber(); } else { return 0; } }
    public Integer getSetControllerResultSize() { if(SetController != null) { return SetController.getResultSize(); } else { return 0; } }
    
    ApexPages.Action ResubmitOrder = new ApexPages.Action('{!ResubmitOrder}');
    ApexPages.Action CallUseCustomQuery = new ApexPages.Action('{!CallUseCustomQuery}');
    ApexPages.Action GeneratePickTickets = new ApexPages.Action('{!GeneratePickTickets}');
    ApexPages.Action GeneratePickTicket = new ApexPages.Action('{!GeneratePickTicket}');
    ApexPages.Action BatchPickTicketStatus = new ApexPages.Action('{!BatchPickTicketStatus}'); 
    
    public OrderEntryStatus() 
    {
      PageReference Current = ApexPages.currentPage();
      
        if(Current.getUrl() != null)
        {
          StatusType = ApexPages.currentPage().getParameters().get('type');
            if(StatusType==null && ApexPages.currentPage().getURL().contains(Page.OrderEntryStatus.getURL())) { StatusType='error'; QueryOrders(); }
            else if(StatusType==null && ApexPages.currentPage().getURL().contains(Page.OrdersToPick.getURL())) { StatusType='orders_to_pick'; QueryOrders(); }
        }
        else { QueryOrders(); } 
        
        // return the batch processing page
        BatchPickTicketStatus();
    }
    
    public OrderEntryStatus(String bypass) { }
    
    /* 
     * Method:  QueryOrders
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public void QueryOrders()
    {
        Orders = new List<Order>();
        
        if(UseCustomQuery)
        {
            Orders = Database.query(CustomQuery);
        }
        else
        {
            String Query = generateQuery(); CustomQuery = Query; system.debug(Query);
            Orders = Database.query(Query);
            SetController = new ApexPages.StandardSetController(Database.getQueryLocator(Query));
            SetController.setPageSize(OrdersToPickLimit);
            Orders = SetController.getRecords();
        }
        
        UseCustomQuery = false;
    }
    
    /* 
     * Method:  GetHasNextOrders
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public Boolean GetHasNextOrders() 
    { 
        if(SetController!=null){
            return SetController.getHasNext();}
        else{
            return false;} 
    }
    
    /* 
     * Method:  GetHasPreviousOrders
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public Boolean GetHasPreviousOrders() 
    { 
        if(SetController!=null){
            return SetController.getHasPrevious();}
        else{
            return false;} 
    }
    
    /* 
     * Method:  QueryNextOrders
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public PageReference QueryNextOrders()
    {
        SetController.next();
        Orders = SetController.getRecords();
        return ApexPages.currentPage();
    }
  
   /* 
     * Method:  QueryPreviousOrders
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public PageReference QueryPreviousOrders()
    {
        SetController.previous();
        Orders = SetController.getRecords();
        return ApexPages.currentPage();
    }
    
    /* 
     * Method:  generateQuery
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public String generateQuery()
    {
        String Query = null;

          Query = 'Select Id, AccountId, Account.Name, Name, ' + 
                  'Status, TotalAmount, CreatedDate, Order_created_date__c ,CreatedById, CreatedBy.Name,LastModifiedDate, HasOrderLineItem__c, ' +
                  'LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, Company__c, ' +
                  'Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c, Shipping_Weight__c, ' +
                  '(Select Id, Name From Pick_Tickets__r) ' + 
                  // 'FROM Order Where CreatedDate >= LAST_N_MONTHS:9 ';
                  'FROM Order Where Order_created_date__c >= LAST_N_MONTHS:9 ';
        
        if(StatusType == 'duplicates')
        {
            Query += 'And Name In(';
            
            String aggregateQuery = 'SELECT Name From Order '+
                ' Where Name like \'O-%\' '; 
            if(IsTest) { aggregateQuery += ' And Name = \'O-TEST-0\' '; }
            aggregateQuery += ' Group By Name Having Count(Name)>1 ';
            
            AggregateResult[] OrderResults = Database.query(aggregateQuery);
            system.debug('Aggregate Query: '+aggregateQuery);
            
            for(AggregateResult ar : OrderResults)
            {
                Query += '\''+ar.get('Name')+'\', ';
            }
            
            Query += '\' \') ';
        }
        
        if(StatusType == 'rush_orders_to_pick')
        {
            Query += ' And TotalAmount >= 0 ';
            Query += ' And Rush_Order__c = true ';
            Query += ' And Total_Pick_Tickets__c = 0 ';
            Query += ' And Status != \'Order Cancelled\' ';
            Query += ' And Status = \'Order Confirmed\' ';
            Query += ' And (NOT Status like \'%Partially%\') ';
            Query += ' And (Not Status like \'%Fulfilled%\') ';
            Query += ' And (Pick_Ticket_Not_Fulfillable__c = false) ';
            Query += ' And (NOT Account.RecordType.Name like \'%Canada%\') ';
        }

        if(StatusType == 'orders_to_pick')
        {
            Query += ' And TotalAmount >= 0 ';
            Query += ' And Rush_Order__c = false ';
            Query += ' And Total_Pick_Tickets__c = 0 ';
            Query += ' And Status != \'Order Cancelled\' ';
            Query += ' And Status = \'Order Confirmed\' ';
            Query += ' And (NOT Status like \'%Partially%\') ';
            Query += ' And (Not Status like \'%Fulfilled%\') ';
            Query += ' And (Pick_Ticket_Not_Fulfillable__c = false) ';
            Query += ' And (NOT Account.RecordType.Name like \'%Canada%\') ';
        }

        if(StatusType == 'canada_orders_to_pick')
        {
            Query += ' And TotalAmount >= 0 ';
            Query += ' And Total_Pick_Tickets__c = 0 ';
            Query += ' And Status != \'Order Cancelled\' ';
            Query += ' And Status = \'Order Confirmed\' ';
            Query += ' And (NOT Status like \'%Partially%\') ';
            Query += ' And (Not Status like \'%Fulfilled%\') ';
            Query += ' And (Pick_Ticket_Not_Fulfillable__c = false) ';
            Query += ' And (Account.RecordType.Name like \'%Canada%\' OR Account.Name like \'%Canada%\') ';              
        }
        
        if(StatusType == 'backorders_to_pick')
        {
            Query += ' And TotalAmount >= 0 ';
            Query += ' And (Total_Pick_Tickets__c > 0 OR Pick_Ticket_Not_Fulfillable__c = true) ';
            Query += ' And Status != \'Order Cancelled\' ';
            Query += ' And Status != \'Order Invoiced\' ';
            Query += ' And (Not Status like \'%Fulfilled%\') ';
            Query += ' And (Status like \'%Partially%\' OR Status = \'Order Confirmed\' OR Pick_Ticket_Not_Fulfillable__c = true) ';
        }
        
      if(StatusType == 'error')
        {
            Query += ' And Status = \'Order Error\' ';
        }

        if(StatusType == 'error_no_so')
        {
            Query += ' And Status = \'Order Error\' ';
        }
        
        if(StatusType == 'error_no_fip')
        {
            Query += ' And Status = \'Order Error\' ';
        }
        
        if(StatusType == 'error_no_shipper')
        {
            Query += ' And Status = \'Order Error\' ';
        }
        
        if(StatusType == 'error_no_invoice')
        {
            Query += ' And Status = \'Order Error\' ';
        }
        
        if(IsTest) { Query += ' And Name = \'O-TEST-0\' '; }
        
        if(CustomNameSearch != null)
        {
            if(CustomNameSearch.length() > 0)
            {
                if(!CustomNameSearch.contains('\'')) { CustomNameSearch = CustomNameSearch.replaceAll('(O-[^-]*-[0-9]*)', '\'$1\''); }
                 Query += ' And Name In ('+CustomNameSearch+') ';
                   // Query += ' And Name In (\''+CustomNameSearch+'\')';
                     
                CustomNameSearch = null;
            }
        }
        
        if(OrdersToPickLimit == 0) { OrdersToPickLimit=200; }
        
        if(!Query.toLowerCase().contains('limit')) { Query += ' limit 7500 '; }
        
        return Query;
    }
    
     /* 
     * Method:  ExportToExcel
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public PageReference ExportToExcel()
    {
        ContentType = 'application/vnd.ms-excel#OrderStatus.xls'; //'application/vnd.ms-excel#OrderDuplicates.xls'; //
        return ApexPages.currentPage();
    }
    
    public PageReference DeleteDuplicateErrorsWithNoLineItems()
    {
        List<Order> OrdersToDelete = new List<Order>();
        
        for(Order o : Orders)
        {
            if(!o.HasOrderLineItem__c && !(o.Status == 'Order Open'))
            {
                OrdersToDelete.add(o);
            }
        }
        
        delete OrdersToDelete;
        
        ApexPages.currentPage().getParameters().put('type', 'duplicates');
        ApexPages.currentPage().setRedirect(true);
        return ApexPages.currentPage();
    }
    
    /* 
     * Method:  GeneratePickTicket
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    
    public void GeneratePickTicket()
    {      
    Order  odr = null;
    Pick_Ticket__c PickTicket = null;
    List<OrderItem> OrderLineItems = new List<OrderItem>();
    List<OrderItem> OrderLineItemsToUpdate = new List<OrderItem>();
    List<Pick_Ticket_Line_Item__c> PickTicketLineItems = new List<Pick_Ticket_Line_Item__c>();
    List<Product2> Products = new List<Product2>();

     String OrderQuery = 'Select Id, AccountId, Account.Name, Name, ' + 
      'Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, ' +
      'LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, Company__c, ' +
      'Total_Pick_Tickets__c, Inventory_Items__c, Payment_Terms__c, Non_inventory_Items__c, Error_Log__c, Pick_Ticket_Not_Fulfillable__c, Shipping_Weight__c, ' +
      '(Select Id, Name From Pick_Tickets__r) ' + 
      'From Order ' + 
      'Where Id = \'' + OrderId + '\' ' +
      'limit 1 '; 
      
     odr = Database.query(OrderQuery);

     String OrderLineItemsQuery = 'Select Id, Quantity, ListPrice, UnitPrice, TotalPrice, ' +
            'OrderId, Order.Total_Pick_Tickets__c, Product2Id, Line_Type__c, ' + 
            'Product2.ProductCode, Product2.Quantity__c, Product2.Quantity_on_Pick__c, Product2.Quantity_in_Pick_Bin__c, Quantity_Shipped__c, ' +
            'Product2.Quantity_Available__c, Quantity_Fillable__c, Quantity_Given_Away__c, Promo_Code__c, Description,PreOrder_Backorder_Handling__c,Estimated_Weight__c  ' + 
            'From OrderItem Where Order.Name like \'O%\' And OrderId = \'' + OrderId + '\' ';
    
    OrderLineItems = Database.query(OrderLineItemsQuery);
    system.debug('<<ORDERLINEITEMS>> '+OrderLineItems);
    Double TotalFillableItems = 0;
    for(OrderItem li : OrderLineItems)
    {
       system.debug('<<QUANITITY_SHIPPING>> ' +li.Quantity_Shipped__c);
        if(li.Line_Type__c.toLowerCase().startsWith('s - stock'))
        {
          TotalFillableItems += li.Quantity_Fillable__c;
        }
        system.debug('<<PREORDER>> '+li.PreOrder_Backorder_Handling__c);
        system.debug('Fillable: '+li.Quantity_Fillable__c+'; TotalFillable: '+TotalFillableItems);
    }
    
    // !!! generate pick tickets
     system.debug('Inventory Items: '+odr.Inventory_Items__c+'; '+'Non-Inventory: '+odr.Non_inventory_Items__c+'; '+'Total Fillable: '+TotalFillableItems);
    
    if(odr.Inventory_Items__c == 0 && odr.Non_inventory_Items__c > 0 && TotalFillableItems <= 0)
    {
      system.debug('case 1 : I=0 N>0 TF=0'); 
      
          PickTicket = new Pick_Ticket__c(Order__c = odr.Id,Status__c='Closed', Company__c=odr.Company__c);
        //Decrement Pick Bin
    }
    else if(odr.Inventory_Items__c > 0 && odr.Non_inventory_Items__c == 0 && TotalFillableItems >= 1)
    {
      system.debug('case 2 : I>0 N=0 TF>0');
      
          PickTicket = new Pick_Ticket__c(Order__c=odr.Id,Status__c='Open', Company__c=odr.Company__c);
        //Decrement Pick Bin
    }
    else if(odr.Inventory_Items__c > 0 && odr.Non_inventory_Items__c == 0 && TotalFillableItems <= 0)
    {
      system.debug('case 3 : I>0 N=0 TF=0');
      
        // do not generate a pick ticket
        odr.Pick_Ticket_Not_Fulfillable__c = true;
    }//TW: 2-28-13 If an odr is of Payment Status "To Be Billed" then that is similar to a Back order and the ticket shouldbe closed.
  
    else if(odr.Payment_Terms__c != null && odr.Payment_Terms__c.toLowerCase().contains('to be billed')){
         PickTicket = new Pick_Ticket__c(Order__c=odr.Id, Status__c='Closed', Company__c=odr.Company__c);
    }
    
    else if(odr.Inventory_Items__c > 0 && odr.Non_inventory_Items__c > 0 && TotalFillableItems <= 0)
    {
      system.debug('case 4 : I>0 N>0 TF=0');
      
      Integer NonStockItemCount = 0;
      
        List<OrderItem> old_lines = OrderLineItems;
        List<OrderItem> new_lines = new List<OrderItem>();
        //Make sure that we get true product line items and not Tax, Discounts, or freight.
      //TW: 6-162012: added a check for Line Type = 'SB' since subscriptions are non-stock items
        for(OrderItem li : old_lines)
        {  // TW:09-10-2012 - Added New Discount 77780 and 7778.  instead of hard coding discount product codes.
            if (!li.Line_Type__c.toLowerCase().startsWith('f') && 
              !li.Line_Type__c.toLowerCase().startsWith('t') &&
              !(li.Product2.ProductCode == '77777') && !(li.Product2.ProductCode != '77780') && !(li.Product2.ProductCode != '77778'))
            {
                new_lines.add(li);
            }
            // TW:09-10-2012 - Added New Discounts 77780 and 77778.
           if((li.Line_Type__c.toLowerCase().startsWith('n') || li.Line_Type__c.toLowerCase().startsWith('sb') ) && li.Product2.ProductCode != '77777' && li.Product2.ProductCode != '77780' && li.Product2.ProductCode != '77778')
           {
              system.debug('<<DISCOUNT NOT CAUGHT? >> '+li.Product2.ProductCode );
                NonStockItemCount++;
            } 
            
        }        
        system.debug(OrderLineItems);
        
        OrderLineItems.clear();
        OrderLineItems = new_lines.clone();
        
        system.debug(OrderLineItems);
        
        if(OrderLineItems.size() > 0)
        {//TW 4-3-2012: added an additional AND clause to not create closed tickets if a back order item is...
         // ... combined with a 77777 Discount.
         //if(NonStockItemCount > 0 && odr.Inventory_Items__c <= 0)
         if(odr.Inventory_Items__c > 0 && TotalFillableItems <= 0)
          {
            odr.Pick_Ticket_Not_Fulfillable__c = true;
          }
         else if(NonStockItemCount > 0)
          {
            PickTicket = new Pick_Ticket__c(Order__c=odr.Id,Status__c='Closed',Company__c=odr.Company__c);
            system.debug('<<CLOSED PICKTICKET>> '+PickTicket );
            //Decrement Pick Bin
          }
          
        }//END TW 4-3-2012
        else
        {
          odr.Pick_Ticket_Not_Fulfillable__c = true;
        }
    }
    else if(odr.Inventory_Items__c > 0 && odr.Non_inventory_Items__c > 0 && TotalFillableItems > 0)
    {
      system.debug('case 5 : I>0 N>0 TF>0');
      
        PickTicket = new Pick_Ticket__c(Order__c=odr.Id, Status__c='Open', Company__c=odr.Company__c);
        //Decrement Pick Bin
    }
    else 
    {
      system.debug('case 6 else');
      
      String OrderError = odr.Error_Log__c;
      
        if(OrderError != null) { OrderError += '\n'; } else { OrderError = ''; }
        odr.Error_Log__c = OrderError + String.valueOf(DateTime.Now())+': Attempted to generate Pick Ticket, but did not match any case. I='+
          odr.Inventory_Items__c+' N='+odr.Non_inventory_Items__c+' TF='+TotalFillableItems;
        update odr; 
    }
    
    system.debug(PickTicket);
   // !!! end generate pick tickets
    
        if(PickTicket != null)
        {
          system.debug('Looping Line Items');
          
            for(OrderItem li : OrderLineItems)
            {
              system.debug('Line Item: '+li);
              
                if(PickTicket.Order__c == li.OrderId)
                {
                    Decimal QuantityOrdered = li.Quantity;
                    Decimal QuantityShipped = li.Quantity_Shipped__c;
                    system.debug('<<Before Quantity_Shipped__c >> '+li.Quantity_Shipped__c);
                    Decimal QuantityInStock = li.Product2.Quantity__c;
                    Decimal QuantityOnPickTicket = li.Product2.Quantity_on_Pick__c;
                    Decimal QuantityInPickBin = li.Product2.Quantity_in_Pick_Bin__c;
                    Decimal QuantityFillable = li.Quantity_Fillable__c;
                    Decimal TotalQuantityShipped = QuantityShipped;
                    Decimal QuantityToShip = 0;
                    Decimal EstimatedWeight = li.Estimated_Weight__c;
                     //TW: Add assignment for new field Quantity_GivenAway__c;
                    if (li.Line_Type__c.toLowerCase().startsWith('sb')){QuantityShipped = 0;}
                    Decimal QuantityGivenAway = li.Quantity_Given_Away__c;
                    QuantityOrdered = (QuantityOrdered!=null)?(QuantityOrdered):(0);
                    QuantityShipped = (QuantityShipped!=null)?(QuantityShipped):(0);
                    QuantityInStock = (QuantityInStock!=null)?(QuantityInStock):(0);
                    QuantityOnPickTicket = (QuantityOnPickTicket!=null)?(QuantityOnPickTicket):(0);
                    QuantityInPickBin = (QuantityInPickBin!=null)?(QuantityInPickBin):(0);
                    QuantityFillable = (QuantityFillable!=null)?(QuantityFillable):(0);
                    //TW: Add assignment for new field Quantity_GivenAway__c;
                    QuantityGivenAway = (QuantityGivenAway!=null)?(QuantityGivenAway):(0);
                    EstimatedWeight = (EstimatedWeight!=null)?(EstimatedWeight):(0);

                    QuantityToShip = QuantityShipped;
                    system.debug('<<PREORDER>> '+li.PreOrder_Backorder_Handling__c);
                    // per Jason P on 2011-02-09 - he found that invoices were not being generated for closed pick tickets that have all non-stock items
                // if the line is not a stock item (non-stock, freight, discount, tax), set the quantity shipped to quantity ordered
                if(!li.Line_Type__c.toLowerCase().startsWith('s - stock'))
                    {
                      QuantityToShip = QuantityOrdered;
                    }
                    else // otherwise (line is a stock item) make sure the quantity shipped is set to quantity fillable
                    {
                      QuantityToShip = QuantityFillable;
                    }
                
                    // put all non-stock line type items (fright, tax, etc.) into the first pick ticket 
                    if(li.Order.Total_Pick_Tickets__c == 0)
                    {    //TW: Added promotional field Quantity Given Away for Pick Ticket for non-stock items.
                        // add all items to the pick ticket
                        // -- note: 2011-02-09 Quantity__c set to QuantityToShip instead of QuantityFillable
                        //TW: 1/12/2012 Moved Opportunity Line Item Promo Code to Pick Ticket Line Item
                        //TW: 5-21-2013: Added new PreOrder_BackOrder Handling field to pick ticket.    
                        //TW: 3-3-14: Added QGA (Quantity GIven Away) to the Quantity Ordered                   
                        PickTicketLineItems.add(new Pick_Ticket_Line_Item__c(Product__c=li.Product2Id, Quantity_Ordered__c=QuantityOrdered + QuantityGivenAway, 
                            Item_Number__c=li.Product2.ProductCode, Pick_Ticket__c=PickTicket.Id, Quantity__c=QuantityToShip, Quantity_Given_Away__c=QuantityGivenAway,Estimated_Weight__c =  EstimatedWeight,
                            Line_Type__c=li.Line_Type__c, Price__c=li.UnitPrice, Promo_Code__c = li.Promo_Code__c, Line_Description__c = li.Description, PreOrder_Backorder_Handling__c = li.PreOrder_Backorder_Handling__c));
                    }
                    else
                    {    //TW: Added promotional field Quantity Given Away for Pick Ticket set to Opportunity Line Item Quantity Given Away field.
                        // add all stock items with quantity pickable greater than zero
                         //TW: 1/12/2012 Moved Opportunity Line Item Promo Code to Pick Ticket Line Item
                        //TW: 5-21-2013: Added new PreOrder_BackOrder Handling field to pick ticket.
                        
                        if(li.Quantity_Fillable__c > 0 && li.Line_Type__c.toLowerCase().startsWith('s - stock'))
                        {
                          // -- note: 2011-02-09 Quantity__c set to QuantityToShip instead of QuantityFillable
                          /* 8-15-2014: Adding new Pick Tickert update for LI.QTY (QTY Ordered)  to correct the Back odr miscalculation where Shipped value is correct but QTY and BO values are incorrect.
                            PickTicketLineItems.add(new Pick_Ticket_Line_Item__c(Product__c=li.Product2Id, Quantity_Ordered__c=QuantityOrdered + QuantityGivenAway, 
                                Item_Number__c=li.Product2.ProductCode, Pick_Ticket__c=PickTicket.Id, Quantity__c=QuantityToShip, Quantity_Given_Away__c=QuantityGivenAway,Estimated_Weight__c =  EstimatedWeight,
                                Line_Type__c=li.Line_Type__c, Price__c=li.UnitPrice, Promo_Code__c = li.Promo_Code__c, Line_Description__c = li.Description, PreOrder_Backorder_Handling__c = li.PreOrder_Backorder_Handling__c));
                             <ASP-893> -There's a direct look up for the new OrderItem to Product2 instead of PriceBookEntry whic is now removed */
                            PickTicketLineItems.add(new Pick_Ticket_Line_Item__c(Product__c=li.Product2Id, Quantity_Ordered__c=(li.Quantity - li.Quantity_Shipped__c), 
                                Item_Number__c=li.Product2.ProductCode, Pick_Ticket__c=PickTicket.Id, Quantity__c=QuantityToShip, Quantity_Given_Away__c=QuantityGivenAway,Estimated_Weight__c =  EstimatedWeight,
                                Line_Type__c=li.Line_Type__c, Price__c=li.UnitPrice, Promo_Code__c = li.Promo_Code__c, Line_Description__c = li.Description, PreOrder_Backorder_Handling__c = li.PreOrder_Backorder_Handling__c));
                           
                           system.debug('<<QuantityOrdered>> '+QuantityOrdered);
                        }
                    }
                    
                    // add the quantity that will be shipped (QuantityToShip) to the original quantity shipped (QuantityShipped) 
                    // for the new total quantity shipped (TotalQuantityShipped) on the OrderItem 
                    TotalQuantityShipped = QuantityShipped + QuantityToShip;
                    
                    // 2011-02-09 Quantity_Shipped__c set to TotalQuantityShipped instead of QuantityFillable
                    OrderLineItemsToUpdate.add(new OrderItem(Id=li.Id, Quantity_Shipped__c=TotalQuantityShipped)); 
                    system.debug('<<Updated Line Item >> '+OrderLineItemsToUpdate );
                    system.debug('<<QTY - QTYY SHIPPED for OLI Update>> '+ (li.Quantity - TotalQuantityShipped) );
                   // system.debug('ProductUpdate - QuantityOnPickTicket: '+QuantityOnPickTicket+', QuantityFillable: '+QuantityFillable+', Weight: '+ EstimatedWeight);
                   //Decrementing QTY IN PIck Bin by the QTY On Pick Ticket - Fillable
                    Products.add(new Product2(Id=li.Product2Id, Quantity_on_Pick__c=QuantityOnPickTicket+QuantityFillable, Quantity_in_Pick_Bin__c = QuantityInPickBin - QuantityFillable));
                }
            }//loop
            
        }
        
        if(odr.Pick_Ticket_Not_Fulfillable__c == true)
        {
          update odr;
        }
        
        if(PickTicketLineItems.size() > 0)
        {
            Boolean error = false;
            try { update Products; } catch (Exception exc) { error = true; }
      
                if(!error)
                {
                    insert PickTicket;
        system.debug('<< PICK TICKET >> '+PickTicket);
        system.debug('<< PICKed Products >> '+Products);
                    if(!odr.Status.toLowerCase().contains('partially')) {
                    odr.Status='Order Being Fulfilled'; }
        
                    for(Pick_Ticket_Line_Item__c ptli : PickTicketLineItems)
                    {
                        ptli.Pick_Ticket__c = PickTicket.Id;
                    }
        
                    insert PickTicketLineItems;
                    update odr;
                    update OrderLineItemsToUpdate;
                }
        }
    
    return;
    }    
    
    
    /* 
     * Method:  GeneratePickTickets
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public PageReference GeneratePickTickets()
    {
      //for(Order o:Orders) {
      //  system.debug(o.Name); }
      
      BatchGeneratePickTickets Job = new BatchGeneratePickTickets(); 
      Job.OrdersToPick = Orders;
      ID batchprocessid = Database.executeBatch(Job, 1); 

        PageReference RedirectPage =  new PageReference('/apex/OrdersToPickStatus');
        RedirectPage.setRedirect(true);
    
    return RedirectPage;
    //return ApexPages.currentPage();
    }
    
    /* 
     * Method:  QueueGeneratePickTicket
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
     */
    webservice static void QueueGeneratePickTicket(String QueuedOrderId)
    {
      OrderEntryStatus OES = new OrderEntryStatus('bypass query');
      OES.OrderId = QueuedOrderId;
      OES.GeneratePickTicket();
      
      // this code is for testing ONLY
      //Order Order = [Select Id, Name, Ship_To_Name__c From Order Where Id = :QueuedOrderId];
      //Order.Ship_To_Name__c = 'Pick Ticket Queued!'; update Order;
    }
    
    /* 
     * Method:  GenerateAllBackorderPickTickets
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    public PageReference GenerateAllBackorderPickTickets()
    {
      QueueGenerateAllBackorderPickTickets();
      
        PageReference RedirectPage =  new PageReference('/apex/OrdersToPickStatus');
        RedirectPage.setRedirect(true);
    
    return RedirectPage;
    }
    
    /* 
     * Method:  QueueGenerateAllBackorderPickTickets
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
    webservice static void QueueGenerateAllBackorderPickTickets()
    {      
      // check backorders
      // select count() from Pick_Ticket__c where createddate > 2010-10-21T00:00:00.000Z and CreatedBy.Name like '%applications%' 
      
    String CustomQuery =
      ' Select Id, AccountId, Account.Name, Name, ' + 
          ' Status, TotalAmount, CreatedDate,Order_created_date__c , CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, ' +
          ' LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, Company__c, Shipping_Weight__c, ' +
          ' Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c ' + 
          //' FROM Order Where CreatedDate >= LAST_N_MONTHS:9 ' +
          ' FROM Order Where Order_created_date__c >= LAST_N_MONTHS:9 ' +

      ' And TotalAmount >= 0 ' + 
      ' And (Total_Pick_Tickets__c > 0 OR Pick_Ticket_Not_Fulfillable__c = true) ' + 
      ' And Status != \'Order Cancelled\' ' + 
      ' And Status != \'Order Invoiced\' ' + 
      ' And (Not Status like \'%Fulfilled%\') ' + 
      ' And (Status like \'%Partially%\' OR Status = \'Order Confirmed\' OR Pick_Ticket_Not_Fulfillable__c = true) '; 

    
    system.debug(CustomQuery);
    
    BatchGeneratePickTicketsByQuery Job = new BatchGeneratePickTicketsByQuery(); 
    Job.Query = CustomQuery;
    ID batchprocessid = Database.executeBatch(Job, 1); 
    }
    
    /* 
     * Method:  BatchPickTicketStatus
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
     */
    public PageReference BatchPickTicketStatus()
    {
    TotalBatchJobs = 0;
    TotalProcessingBatchJobs = 0;
      
      List<AsyncApexJob> BatchJobs = [Select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, 
        Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name 
        From AsyncApexJob 
        Where JobType = 'BatchApex' 
        And ApexClass.Name like 'BatchGeneratePickTickets%' 
        And Status != 'Failed' 
        And Status != 'Aborted' 
        Order By CreatedDate Desc
        limit 1];
      
      for(AsyncApexJob a : BatchJobs)
      {
        TotalBatchJobs += a.TotalJobItems;
        TotalProcessingBatchJobs += a.JobItemsProcessed;
      }
      
      system.debug(TotalBatchJobs);
      system.debug(TotalProcessingBatchJobs);
      
    return null;
    }
    
    /* 
     * Method:  CancelBackorderedLines
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an Order. If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
     */
      webservice static OrderEntryServices.Result CancelBackorderedLines(String BackOrderId) // ==> Vks - pending method to understand the RelationShip of OrderItem and PriceBook
    {

        String CancelBackorderedLinesLog = String.valueOf(DateTime.Now()) + ' - ' + 'Cancelling Backordered Lines - ';
    
        Order Ord;
        List<OrderItem> OrderLineItems = new List<OrderItem>();
        //TW: 8-10-2014 Added Shipping_Carrier__c to query
        List<Order> MatchingOrders = [select Id, Name, Status, Account.Mailing_Address_Book__c, TotalAmount, Shipping_Carrier__c, Shipping_Code__c, Shipping_Zip_Code__c,Shipping_Type__c, HasOrderLineItem__c, Cancel_Log__c From Order Where Id = :BackOrderId];

        if(MatchingOrders.size() > 0) { Ord = MatchingOrders[0]; }
        else { return new OrderEntryServices.Result(false,'No Matching Orders were found','OK'); }

        List<Pick_Ticket__c> OpenPickTickets = [Select Id, Name From Pick_Ticket__c Where Order__c = :BackOrderId and Status__c like '%Open%']; // ==>Order__c = :BackOrderId
        //List<Pick_Ticket__c> AnyPickTickets = [Select Id, Name From Pick_Ticket__c Where Order__c = :BackOrderId];

        //FRT RECONSTRUCTION: 8-14-201 Place PItney Bowes stuff
      //TW: 1/12/2012: Added Promo Code to Order Line Item
        String OrderLineItemsQuery = ' Select Id, Quantity, PricebookEntryId, ListPrice, UnitPrice, TotalPrice, ' +
            ' OrderId, Order.Total_Pick_Tickets__c, Order.Status, Line_Type__c, ' +
            ' Product2Id, Product2.Quantity__c, Product2.Quantity_on_Pick__c, ' +
            ' Product2.Quantity_Available__c, Product2.Quantity_Reserved__c, Product2.Weight__c, ' +
            ' Product2.ProductCode, Quantity_Shipped__c, Quantity_Fillable__c, Quantity_Backordered__c, Quantity_Given_Away__c, Promo_Code__c, Description, PreOrder_Backorder_Handling__c, Estimated_Weight__c, ' +
            ' PricebookEntry.Product2.ProductCode,PriceBookEntry.Product2.Quantity_Reserved__c ' +
            ' From OrderItem Where Order.Name like \'O%\' And OrderId = \'' + BackOrderId + '\' ';
 
        OrderLineItems = Database.query(OrderLineItemsQuery);
        decimal TotalStockWeight = 0;
        decimal TotalStockweightToDelete = 0;
        List<OrderItem> FreightLines = new List<OrderItem>();
        List<OrderItem> TaxLines = new List<OrderItem>();
        List<OrderItem> DiscountLines = new List<OrderItem>();
        List<OrderItem> FillableStockLines = new List<OrderItem>();
        List<OrderItem> BackorderStockLines = new List<OrderItem>();
        List<OrderItem> FulfillableBackorderStockLines = new List<OrderItem>();
        List<OrderItem> NonStockLines = new List<OrderItem>();
        List<OrderItem> OtherLines = new List<OrderItem>();
 
        for(OrderItem li : OrderLineItems)
        {
            string LineType = li.Line_Type__c.toLowerCase();
            if(LineType.startsWith('s - stock'))
            {
                system.debug('<<ESTIMATED WEIGHT >> '+li.Estimated_Weight__c+' <<PRODUCT CODE >> '+li.PricebookEntry.Product2.ProductCode);
                TotalStockWeight = TotalStockWeight + (li.Estimated_Weight__c); // TW: 8-10-2014 Add total Weight for all stock items
                system.debug('<<RUNNING TOTAl WEIGHT >> '+TotalStockWeight);

                if((li.Quantity_Fillable__c > 0 || li.Quantity_Shipped__c > 0) && li.Quantity_Backordered__c == 0)
                {
                    FillableStockLines.add(li);
                    // Add weight here to get total weight
                }
                else
                {
                    if(li.Quantity_Fillable__c > 0) {
                        FulfillableBackorderStockLines.add(li); }
                    else {
                        BackorderStockLines.add(li);
                        // Deduct this weight from the total weight of stock lines.
     
                    }
                }
            }//TW: 6-162012: added a check for Line Type = 'SB' for discounts  since subscriptions are also non-stock items     
            else if(LineType.startsWith('n') || LineType.startsWith('sb') ||  li.Product2.ProductCode == '77777' || li.Product2.ProductCode == '77780'  || li.Product2.ProductCode == '77778')
            { //TW: 09-10-2012: Added 77780 and 77778 also to discountLines to make sur ethese dicsounts are not added to other line item lists.
                if(li.Product2.ProductCode == '77777' || li.Product2.ProductCode == '77780' ||  li.Product2.ProductCode == '77778') {
                DiscountLines.add(li); }
                else {
                    NonStockLines.add(li); }
            }
            else if(LineType.startsWith('f'))
            {
                FreightLines.add(li);
            }
            else if(LineType.startsWith('t'))
            {
                TaxLines.add(li);
            }
            else
            {
                OtherLines.add(li);
            }
        }//FOR
        system.debug(' DISCOUNT LINES: '+DiscountLines);
        Boolean CancelOrder = false;
        Boolean CancelOrRemoveLines = false;
        Boolean AllLinesBackordered = false;

        if(BackorderStockLines.size() > 0 && FillableStockLines.size() == 0 && FulfillableBackorderStockLines.size() == 0 &&
            NonStockLines.size() == 0 && OtherLines.size() == 0)
        {
            AllLinesBackordered = true;
        }

        if(Ord.Status.toLowerCase().contains('open') || // order open
            Ord.Status.toLowerCase().contains('confirmed')) // order confirmed
        {
            // if all line itemss are backordered, change order stagename to order cancelled
            if(AllLinesBackordered)
            {
                Ord.Status = 'Order Cancelled';
                CancelBackorderedLinesLog += 'All lines are backordered; Order Status set to "Order Cancelled". ';
            }
            // else cancel/remove all backorder lines and decrement product2 quantity reserved for each
            else // FRT RECONSTRUCTION:  Need to only select partially fillable stock lines
            {
                    CancelOrRemoveLines = true;
            }
        }
        else if(Ord.Status.toLowerCase().contains('being partially') || // order being partially fulfilled
            Ord.Status.toLowerCase().contains('partially shipped') || // order partially shipped
            Ord.Status.toLowerCase().contains('partially invoiced')) // order partially invoiced
        {
            // cancel/remove all backorder lines and decrement product2 quantity reserved for each
            CancelOrRemoveLines = true;

            if(FillableStockLines.size() <= 0)
            {
                // change stagename to the non-partially version
                CancelBackorderedLinesLog += 'Order partially fulfilled. Changing Satus from "'+Ord.Status;
                Ord.Status = Ord.Status.replace('Partially ','');
                CancelBackorderedLinesLog += '" to "'+Ord.Status+'". ';
            }
        }
        else
        {
            // if stage is:
            //  order canceled or order cancelled or
            //  credit issued or
            //  order on hold or
            //  order error
            //  order submitted
            //  order being fulfilled
            //  order shipped
            //  order invoiced
            // then:
            //  do not allow cancel backorder
            CancelBackorderedLinesLog += 'Invalid conditions for canceling backordered lines. ';
        }
        system.debug('<< CANCEL OR REMOVE LINES VALUE>> '+CancelOrRemoveLines);
        if(CancelOrRemoveLines)
        {
            BackorderStockLines.addAll(FulfillableBackorderStockLines);

            List<OrderItem> OrderLineItemsToUpdate = new List<OrderItem>();
            List<OrderItem> OrderLineItemsToDelete = new List<OrderItem>();
            List<Product2> ProductsToUpdate = new List<Product2>();

            for(OrderItem li : BackorderStockLines)
            {
                if(li.Quantity_Shipped__c < li.Quantity && li.Quantity_Backordered__c > 0)
                {
                    Double UpdatedQuantity = math.max(li.Quantity - li.Quantity_Backordered__c,0);
                    li.Quantity = UpdatedQuantity;

                    if(li.Quantity == 0)
                    {
                        OrderLineItemsToDelete.add(li);
                        TotalStockWeightToDelete = TotalStockWeightToDelete + li.Estimated_Weight__c;
                        system.debug('<< QTY BO To Delete/Deduct>> '+TotalStockWeightToDelete);
                    }
                    else
                    {
                        OrderLineItemsToUpdate.add(li);
                        TotalStockWeightToDelete = TotalStockWeightToDelete +(li.Product2.Weight__c * li.Quantity_Backordered__c);
                        system.debug('<<BO To Delete/Deduct >> '+TotalStockWeightToDelete);
                    }

                    if (!Ord.Status.toLowerCase().contains('open') &&
                        !Ord.Status.toLowerCase().contains('cancel') &&
                        !Ord.Status.toLowerCase().contains('error'))
                    {
                        CancelBackorderedLinesLog += 'Updating Product: ' +
                        'Item='+li.Product2.ProductCode +
                         ',PrevQtyRsv=' + li.PriceBookEntry.Product2.Quantity_Reserved__c;
                        // Add updated weoght weher total weight = total +  QTY  * weight
                        ProductsToUpdate.Add(
                        new Product2(
                        Id=li.Product2Id,
                        ProductCode=li.Product2.ProductCode,
                        Quantity_Reserved__c =
                        math.max(li.Product2.Quantity_Reserved__c-li.Quantity_Backordered__c,0)
                        )
                        );

                    CancelBackorderedLinesLog += ',NewQtyRsv=' +
                    math.max(li.Product2.Quantity_Reserved__c-li.Quantity_Backordered__c,0) + '. ';
                }
                system.debug(ProductsToUpdate);
            }

    }//FOR: Gather All Line Types
    //+++++++++++++++++++++++++++++++++++ REMOVE THE FOLLOWING LINES BELOW +++++++++++++++++++
        //FRT RECONSTURCTION: 8-14-2014: CAll PItney BOwes INtegration for FRT rate if not using old SHipping Table rates
    //+++++++++++++++++++++++ REMOVE THE LINES ABOVE +++++++++++++++++++++++++++++++++
    // do not allow cancel backorder if the order stagename contains cancel or if there are no products
     if(OpenPickTickets.size() > 0 || Ord.Status.toLowerCase().contains('cancel') || Ord.HasOrderLineItem__c == false )
      {
        CancelBackorderedLinesLog += 'Invalid conditions for cancelling backordered lines. ' +
        'Order cannot be Cancelled, must have Products, and must not have any Open Pick Tickets.';
        Ord.Cancel_Log__c = CancelBackorderedLinesLog;

        update Ord;
        return new OrderEntryServices.Result(false,'OPen PIck Ticket Found.','OK');
      }
      if(OrderLineItemsToUpdate.size() > 0)
      {
            CancelBackorderedLinesLog += 'Updating Line Items: ';
            for(OrderItem logLineItem : OrderLineItemsToUpdate) {
                CancelBackorderedLinesLog += 'Item='+logLineItem.Product2.ProductCode + ';'; }
                CancelBackorderedLinesLog = CancelBackorderedLinesLog.substring(0,CancelBackorderedLinesLog.length()-1);
                CancelBackorderedLinesLog += '. ';
                update OrderLineItemsToUpdate;
       }

      if(OrderLineItemsToDelete.size() > 0)
      {
            CancelBackorderedLinesLog += 'Deleting Line Items: ';
            for(OrderItem logLineItem : OrderLineItemsToDelete) {
            CancelBackorderedLinesLog += 'Item='+logLineItem.Product2.ProductCode + ';'; }
            CancelBackorderedLinesLog = CancelBackorderedLinesLog.substring(0,CancelBackorderedLinesLog.length()-1);
            CancelBackorderedLinesLog += '. ';
            delete OrderLineItemsToDelete;
      }
    //+++++++++++++++++ REMOVE FRT LINES BELOW> WE DON:T NEED TO UPDATE THE FRT LINES 
      // update freight line

      //+++++++++++++++++++++++++ REMOVE THE FRT LINES ABOVE> WE DON:T NEED RECALCULATION OF FRT.
    }

    Ord.Cancel_Log__c = CancelBackorderedLinesLog;
    update Ord;
    return new OrderEntryServices.Result(true,'Success','OK');
   }
     /*Commented by CK 07 Feb 2018 to replace this with new code 
    webservice static OrderEntryServices.Result CancelBackorderedLines(String BackOrderId)  // ==> Vks - pending method to understand the RelationShip of OrderItem and PriceBook
    {
        String CancelBackorderedLinesLog = String.valueOf(DateTime.Now()) + ' - ' + 'Cancelling Backordered Lines - ';
    
        Order Order;
        List<OrderItem> OrderLineItems = new List<OrderItem>();
        //TW: 8-10-2014 Added Shipping_Carrier__c to query
        List<Order> MatchingOrders = [select Id, Name, Status, Account.Mailing_Address_Book__c, TotalAmount, Shipping_Carrier__c, Shipping_Code__c, Shipping_Zip_Code__c,Shipping_Type__c, HasOrderLineItem__c, Cancel_Log__c From Order Where Id = :BackOrderId];
        
        if(MatchingOrders.size() > 0) { Order = MatchingOrders[0]; }
        else { return new OrderEntryServices.Result(false,'No Matching Orders were found','OK'); }
      
        List<Pick_Ticket__c> OpenPickTickets = [Select Id, Name From Pick_Ticket__c Where Status__c like '%Open%']; // ==>Order__c = :BackOrderId
        //List<Pick_Ticket__c> AnyPickTickets = [Select Id, Name From Pick_Ticket__c Where Order__c = :BackOrderId];
      
        //FRT RECONSTRUCTION: 8-14-201 Place PItney Bowes stuff 
      //TW: 1/12/2012: Added Promo Code to Order Line Item
        String OrderLineItemsQuery = ' Select Id, Quantity, PricebookEntryId, ListPrice, UnitPrice, TotalPrice, ' +
            ' OrderId, Order.Total_Pick_Tickets__c, Order.Status, Line_Type__c, ' + 
            ' Product2Id, Product2.Quantity__c, Product2.Quantity_on_Pick__c, ' + 
            ' Product2.Quantity_Available__c, Product2.Quantity_Reserved__c, Product2.Weight__c, ' +
            ' Product2.ProductCode, Quantity_Shipped__c, Quantity_Fillable__c, Quantity_Backordered__c, Quantity_Given_Away__c, Promo_Code__c, Description, PreOrder_Backorder_Handling__c, Estimated_Weight__c ' + 
            ' From OrderItem Where Order.Name like \'O%\' And OrderId = \'' + BackOrderId + '\' ';
    
        OrderLineItems = Database.query(OrderLineItemsQuery);
        decimal TotalStockWeight = 0;
        decimal TotalStockweightToDelete = 0; 
        List<OrderItem> FreightLines = new List<OrderItem>();
        List<OrderItem> TaxLines = new List<OrderItem>();
        List<OrderItem> DiscountLines = new List<OrderItem>();
        List<OrderItem> FillableStockLines = new List<OrderItem>();
        List<OrderItem> BackorderStockLines = new List<OrderItem>();
        List<OrderItem> FulfillableBackorderStockLines = new List<OrderItem>();
        List<OrderItem> NonStockLines = new List<OrderItem>();
        List<OrderItem> OtherLines = new List<OrderItem>();
    
        for(OrderItem li : OrderLineItems)
        {
            string LineType = li.Line_Type__c.toLowerCase();
            if(LineType.startsWith('s - stock')) 
            { 
                //system.debug('<<ESTIMATED WEIGHT >> '+li.Estimated_Weight__c+' <<PRODUCT CODE >> '+li.PricebookEntry.Product2.ProductCode);
                TotalStockWeight = TotalStockWeight + (li.Estimated_Weight__c); // TW: 8-10-2014 Add total Weight for all stock items
                system.debug('<<RUNNING TOTAl WEIGHT >> '+TotalStockWeight);
        
                if((li.Quantity_Fillable__c > 0 || li.Quantity_Shipped__c > 0) && li.Quantity_Backordered__c == 0) 
                {
                    FillableStockLines.add(li); 
                    // Add weight here to get total weight
                }
                else 
                {
                    if(li.Quantity_Fillable__c > 0) {
                        FulfillableBackorderStockLines.add(li); }
                    else {
                        BackorderStockLines.add(li); 
                        // Deduct this weight from the total weight of stock lines.
            
                    } 
                } 
            }//TW: 6-162012: added a check for Line Type = 'SB' for discounts  since subscriptions are also non-stock items      
            else if(LineType.startsWith('n') || LineType.startsWith('sb') ||  li.Product2.ProductCode == '77777' || li.Product2.ProductCode == '77780'  || li.Product2.ProductCode == '77778') 
            { //TW: 09-10-2012: Added 77780 and 77778 also to discountLines to make sur ethese dicsounts are not added to other line item lists.
                if(li.Product2.ProductCode == '77777' || li.Product2.ProductCode == '77780' ||  li.Product2.ProductCode == '77778') { 
                DiscountLines.add(li); } 
                else {
                    NonStockLines.add(li); } 
            }
            else if(LineType.startsWith('f')) 
            { 
                FreightLines.add(li); 
            }
            else if(LineType.startsWith('t')) 
            { 
                TaxLines.add(li); 
            }
            else 
            { 
                OtherLines.add(li); 
            }
        }//FOR
        system.debug(' DISCOUNT LINES: '+DiscountLines);
        Boolean CancelOrder = false;
        Boolean CancelOrRemoveLines = false;
        Boolean AllLinesBackordered = false;
    
        if(BackorderStockLines.size() > 0 && FillableStockLines.size() == 0 && FulfillableBackorderStockLines.size() == 0 && 
            NonStockLines.size() == 0 && OtherLines.size() == 0) 
        {
            AllLinesBackordered = true; 
        }
    
        if(Order.Status.toLowerCase().contains('open') || // order open
            Order.Status.toLowerCase().contains('confirmed')) // order confirmed
        {
            // if all line itemss are backordered, change order stagename to order cancelled
            if(AllLinesBackordered) 
            { 
                Order.Status = 'Order Cancelled'; 
                CancelBackorderedLinesLog += 'All lines are backordered; Order Status set to "Order Cancelled". ';
            }
            // else cancel/remove all backorder lines and decrement product2 quantity reserved for each
            else // FRT RECONSTRUCTION:  Need to only select partially fillable stock lines
            { 
                    CancelOrRemoveLines = true; 
            }
        }
        else if(Order.Status.toLowerCase().contains('being partially') || // order being partially fulfilled
            Order.Status.toLowerCase().contains('partially shipped') || // order partially shipped
            Order.Status.toLowerCase().contains('partially invoiced')) // order partially invoiced
        { 
            // cancel/remove all backorder lines and decrement product2 quantity reserved for each
            CancelOrRemoveLines = true;
      
            if(FillableStockLines.size() <= 0)
            {
                // change stagename to the non-partially version
                CancelBackorderedLinesLog += 'Order partially fulfilled. Changing Satus from "'+Order.Status;
                Order.Status = Order.Status.replace('Partially ',''); 
                CancelBackorderedLinesLog += '" to "'+Order.Status+'". ';
            }
        }
        else 
        {
            // if stage is:
            //  order canceled or order cancelled or 
            //  credit issued or 
            //  order on hold or 
            //  order error
            //  order submitted
            //  order being fulfilled
            //  order shipped
            //  order invoiced
            // then:
            //  do not allow cancel backorder
            CancelBackorderedLinesLog += 'Invalid conditions for canceling backordered lines. ';
        }
        system.debug('<< CANCEL OR REMOVE LINES VALUE>> '+CancelOrRemoveLines);
        if(CancelOrRemoveLines)
        {
            BackorderStockLines.addAll(FulfillableBackorderStockLines);
      
            List<OrderItem> OrderLineItemsToUpdate = new List<OrderItem>();
            List<OrderItem> OrderLineItemsToDelete = new List<OrderItem>();
            List<Product2> ProductsToUpdate = new List<Product2>();
      
            for(OrderItem li : BackorderStockLines)
            {
                if(li.Quantity_Shipped__c < li.Quantity && li.Quantity_Backordered__c > 0)
                {
                    Double UpdatedQuantity = math.max(li.Quantity - li.Quantity_Backordered__c,0);
                    li.Quantity = UpdatedQuantity;
          
                    if(li.Quantity == 0)
                    {
                        OrderLineItemsToDelete.add(li);
                        TotalStockWeightToDelete = TotalStockWeightToDelete + li.Estimated_Weight__c;
                        system.debug('<< QTY BO To Delete/Deduct>> '+TotalStockWeightToDelete);
                    }
                    else
                    {
                        OrderLineItemsToUpdate.add(li);
                        TotalStockWeightToDelete = TotalStockWeightToDelete +(li.Product2.Weight__c * li.Quantity_Backordered__c);
                        system.debug('<<BO To Delete/Deduct >> '+TotalStockWeightToDelete);
                    }
          
                    if (!Order.Status.toLowerCase().contains('open') && 
                        !Order.Status.toLowerCase().contains('cancel') && 
                        !Order.Status.toLowerCase().contains('error'))
                    {
                        CancelBackorderedLinesLog += 'Updating Product: ' + 
                        'Item='+li.Product2.ProductCode + 
                         ',PrevQtyRsv=' + li.PriceBookEntry.Product2.Quantity_Reserved__c;
                        // Add updated weoght weher total weight = total +  QTY  * weight
                        ProductsToUpdate.Add(
                        new Product2(
                        Id=li.Product2Id,
                        ProductCode=li.Product2.ProductCode,
                        Quantity_Reserved__c = 
                        math.max(li.Product2.Quantity_Reserved__c-li.Quantity_Backordered__c,0)
                        )
                        );
            
                    CancelBackorderedLinesLog += ',NewQtyRsv=' + 
                    math.max(li.Product2.Quantity_Reserved__c-li.Quantity_Backordered__c,0) + '. ';
                }
                system.debug(ProductsToUpdate);
            }
    }//FOR: Gather All Line Types
    //+++++++++++++++++++++++++++++++++++ REMOVE THE FOLLOWING LINES BELOW +++++++++++++++++++
        //FRT RECONSTURCTION: 8-14-2014: CAll PItney BOwes INtegration for FRT rate if not using old SHipping Table rates
    
    //+++++++++++++++++++++++ REMOVE THE LINES ABOVE +++++++++++++++++++++++++++++++++
    // do not allow cancel backorder if the order stagename contains cancel or if there are no products
     if(OpenPickTickets.size() > 0 || Order.Status.toLowerCase().contains('cancel') || Order.HasOrderLineItem__c == false ) 
      { 
        CancelBackorderedLinesLog += 'Invalid conditions for cancelling backordered lines. ' + 
        'Order cannot be Cancelled, must have Products, and must not have any Open Pick Tickets.';
        Order.Cancel_Log__c = CancelBackorderedLinesLog; 
        
        update Order;
        return new OrderEntryServices.Result(false,'OPen PIck Ticket Found.','OK');
      }
      if(OrderLineItemsToUpdate.size() > 0)
      {
            CancelBackorderedLinesLog += 'Updating Line Items: ';
            for(OrderItem logLineItem : OrderLineItemsToUpdate) {
                CancelBackorderedLinesLog += 'Item='+logLineItem.Product2.ProductCode + ';'; }
                CancelBackorderedLinesLog = CancelBackorderedLinesLog.substring(0,CancelBackorderedLinesLog.length()-1);
                CancelBackorderedLinesLog += '. ';
                update OrderLineItemsToUpdate;
       }
      
      if(OrderLineItemsToDelete.size() > 0)
      {
            CancelBackorderedLinesLog += 'Deleting Line Items: ';
            for(OrderItem logLineItem : OrderLineItemsToDelete) {
            CancelBackorderedLinesLog += 'Item='+logLineItem.Product2.ProductCode + ';'; }
            CancelBackorderedLinesLog = CancelBackorderedLinesLog.substring(0,CancelBackorderedLinesLog.length()-1);
            CancelBackorderedLinesLog += '. ';
            delete OrderLineItemsToDelete;
      }
    //+++++++++++++++++ REMOVE FRT LINES BELOW> WE DON:T NEED TO UPDATE THE FRT LINES  
      // update freight line
    
      //+++++++++++++++++++++++++ REMOVE THE FRT LINES ABOVE> WE DON:T NEED RECALCULATION OF FRT.
    }
    
    Order.Cancel_Log__c = CancelBackorderedLinesLog;
    update Order;
    return new OrderEntryServices.Result(true,'Success','OK');
   }
   Commented by CK 07 Feb 2018 to replace this with new code*/
   
  /* 
     * Method:  ResubmitOrder
     * Inputs:  string OrderSalesforceId - The Salesforce ID of an Order. This is used to lookup an Order.
     * Output:  Result Object containing Success and Message (at minimum) and the calculated delivery charge.
     * Purpose: Calculates the delivery (freight) charge for all of the stock products on an . If a freigt line is found
     *            the previous freight line is deleted before a new one is added.
     * SOQL:    3
     * DML:     0
    */
  
    public void ResubmitOrder() 
    {
        system.debug(OrderId);
        
        List<Order> ResubmitOrder = [Select Id, Status From Order Where Id = :OrderId limit 1];
        
        if(ResubmitOrder.size() > 0)
        {
            if(OrderStatus != null && OrderStatus.length() > 1)
            {
                ResubmitOrder[0].Status = OrderStatus;
                update ResubmitOrder[0];
            }
        }
    }
}