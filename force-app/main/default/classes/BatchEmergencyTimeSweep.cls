/*************************************************************************************************************************************
    Programmer:        Tony Williams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Newgistics
    Created:    12/06/2018 - <NEW 29>  - Retrieveing  Shipments from  Newgsitics web services. , Removed any reference to BO pick tickets and their SF Shipments
                                       - Creating Pick Tickets and HSimpents from Packages to get the ttracking info as well from the packages.
    Updated:    02/07/2019 - <NEW-79,82> - Created custom settings varibale to save the start time globally i order to catch all sshipped NG shipments for PT processing.
    Updated:    02/017/2019 - <NEW-97> - Updated to include multiple shipments per Pick Ticket based on multiple NG Package tracking numbers per NG Shipment
    Updated:    07/15/2019 - <SMS-4,ASP-1658> - Baji: Fixes for Mixed orders and double freight charges.
    Updated:    08/05/2019 - <SMS-45> - Anvesh: Fix to account for too many SOQL errors in batch run.
------------------------------------------------------------------
Example: How to clean up straggling MFT accounts when their Registration Due Date is up? (This  example runs once per year)
BatchSearchNewgisticsShipmentsScheduler j = new BatchSearchNewgisticsShipmentsScheduler();
String sch = '0 * * * * ? *';
String jobID = system.schedule('Search Shipment', sch, j);
For recusive help see: https://developer.secure.force.com/cookbook/recipe/parsing-xml-using-the-apex-dom-parser
 ********************************************************************************************************************************/ 
global class BatchEmergencyTimeSweep implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    global String query;
    global String startShippedTimestamp;
    //global String startReceivedTimestamp;
    global String endShippedTimestamp;
    // global String endReceivedTimestamp;
    public Integer ordersProcessed = 0;
    // Holds the list of NG Shipped shipments
    public List<NGUtilityClasses.Shipment> ShipmentResponses = new List<NGUtilityClasses.Shipment>();    
    // Processes each individual NG shipment record returned from call out.
    //NGUtilityClasses.Shipment   ShipmentResponse; 
    //Used in Recursive calls to get access to the Shipment Records
    SearchShipmentRequest sr;
    //Associate PTLIs with Pick Ticket using NG Package Id
    //Map<String,List<Pick_Ticket_Line_Item__c>> ngPackageIdToPTLI = new  Map<String,List<Pick_Ticket_Line_Item__c>>();
   // Associate SF Shipments with Pick Ticket using NG Package Id
    //Map<String,Shipment__c> ngPackageIdToSFShipment = new  Map<String,Shipment__c>();
    List<Pick_Ticket__c> ptickets = new List<Pick_Ticket__c>();
    global Newgistics_Settings__c custSettings = Newgistics_Settings__c.getValues('NewgsticsAPIFields');
    //global List<Order> printOrders = new List<Order>();
    //global List<Order> NGShippedOrderNumbers = new List<Order>();
    global List<String> NGShippedOrderNumbers = new List<String>();
    //global List<Pick_Ticket__c> ptToBeClosed = new List<Pick_Ticket__c>();
    //global List<Pick_Ticket__c> delete0PTs = new List<Pick_Ticket__c>();
    
    //**************************************************************************************
    //Constructor
    global BatchEmergencyTimeSweep(){
    
        custSettings = [SELECT id,End_Shipped_Time__c,Start_Shipped_Time__c,Start_Emergency_Timestamp__c,End_Emergency_Timestamp__c,Added_Hours__c,NG_API_Key__c,NG_Endpoint__c,FRT_Code__c,TAX_Code__c from  Newgistics_Settings__c];
        System.debug('Custom Setting Values:'+custSettings);
        if(custSettings.End_Emergency_Timestamp__c != null){
            system.debug('Start Time before +:'+custSettings.Start_Emergency_Timestamp__c);
            system.debug('End Time before +:'+custSettings.End_Emergency_Timestamp__c);            
            endShippedTimestamp=custSettings.End_Emergency_Timestamp__c;
            startShippedTimestamp =custSettings.Start_Emergency_Timestamp__c;
        }
    }
    /************************************************************************************
  * start() - Method indirectly calls execute() method using a simple query.
  **************************************************************************************/
    global database.querylocator start(Database.BatchableContext BC){
        String endpoint;
        String status = 'SHIPPED';
        checkRecursive.setBatchStatus('NGSearch'); //Used to prevent execution of triggers
        try {                  
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            // Set values to Params
            String apikey = custSettings.NG_API_Key__c;
            String timeParameters = '&startShippedTimestamp='+startShippedTimestamp+'&endShippedTimestamp='+endShippedTimestamp+'&Company=Awana&status='+status;
            endpoint = 'http://api.newgisticsfulfillment.com/shipments.aspx?key='+custSettings.NG_API_Key__c+timeParameters;
            //endpoint = 'http://apistaging.newgisticsfulfillment.com/shipments.aspx?key='+custSettings.NG_API_Key__c+timeParameters;
            system.debug('<< API KEY>> '+custSettings.NG_API_Key__c);
            system.debug('<< ENDPOINT:  >> '+endpoint);            
            req.setHeader('Content-Type','application/xml; charset=UTF-8');
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(20000);
            HTTPResponse resp;
            
            if(!Test.isRunningTest())
            {
                //resp = http.send(req);  
            }else{
                    Test.setMock(HttpCalloutMock.class, new Newgistics_SearchMock(true));
            }
            String shipmentID = '';
            // Read through the Search Shipment Resposne XML
            if(!Test.isRunningTest())
            {
                //String XMLString = resp.getBody();
                //system.debug('<< XML STRING AFTER Call OUT >> '+XMLString);
                //sr  = new SearchShipmentRequest(XMLString);
                
                //***Code to test mock responses which added in statiresource file
                StaticResource sres = [Select Body From StaticResource Where Name = 'XMLData' LIMIT 1 ];
                sr = new SearchShipmentRequest(sres.Body.toString());
                
            }else{ // Test the Mock XML string
                String XMLString = BatchSearchNewgisticsShipmentsTest.CreateShipments_TestMethod();
                sr  = new SearchShipmentRequest(XMLString);
            }
            ShipmentResponses = sr.ShipmentResponses;
            
            if(ShipmentResponses.size() > 0){
                for(NGUtilityClasses.Shipment aShipmentResponse : ShipmentResponses){
                    NGShippedOrderNumbers.add(aShipmentResponse.orderID);
                }//For
            }
            
        }Catch(Exception e){
            system.debug(e);
        }
        system.debug('Order Numbers:'+NGShippedOrderNumbers);
    
    if(query == null){
            query  = 'SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,'
                +'Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c,Estimated_Weight__c,' 
                +'Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Tax__c,Shipment_Cost__c,Payment_Terms__c,'
                +'AccountId, Account.Name, OrderNumber, Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name,'
                +'HasOrderLineItem__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c,'
                +'Total_Pick_Quantity__c, Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,'
                +'Order.NG_Shipment_ID__c, (Select Id, Name From Pick_Tickets__r) '
                +'FROM Order '
                +'where (Status = \'Order Being Fulfilled\' or Status like \'%Partially%\')'
                +' And (NOT Status like \'%Cancelled%\')'
                +' And OrderNumber IN: NGShippedOrderNumbers';
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    }//mETHOD sTART
    
   /************************************************************************************
  * execute() - Method creates pick tickets and shipments for each NG Shipment Response
  **************************************************************************************/
    global void execute(Database.BatchableContext BC, List<Order> orders) { 
       //system.debug('<<  SHIP RESPONSES FROM NG >> ' +ShipmentResponses);
       checkRecursive.setBatchStatus('NGSearch'); //Used to prevent execution of triggers
       system.debug('Order Size: '+orders.size());
       
       //Retrieves a Pick TIcket for a SF SHipment Record ID
        Map<Id,Pick_Ticket__c> SFShipIDToSFPTs = new Map<Id,Pick_Ticket__c>();
        //Retrieves a SF SHipment Record  for each NG Shipment ID
        Map<String,Shipment__c> NGShipIdToSFShipRecord = new Map<String,Shipment__c>();
        // Holds all order items per order.
        List<OrderItem> stockOLIs = new List<OrderItem>();
        //Holds all PickTickets for Current Order
        List<Pick_Ticket__c> pts = new List<Pick_Ticket__c>();
        //Holds all PickTicket LineItems for all PTs for Current Order
        List<Pick_Ticket_Line_Item__c> ptls = new List<Pick_Ticket_Line_Item__c>();
        //Holds all Non-Stock Pick Ticket LineItems for Current processing order
        List<Pick_Ticket_Line_Item__c> ptlsNonStock = new List<Pick_Ticket_Line_Item__c>();
        // Retrieves a pick ticket for each order's order number.
        Map<String,Pick_Ticket__c> OrderNumToPickT = new Map<String,Pick_Ticket__c>();
        //Retrieves an Order Numbers for each NG Shipment IDs
        Map<String,String> NGShipIDToNgOrderIDs = new Map<String,String>();
        Map<String,String>  NgOrderIDsToNGShipID = new Map<String,String>();
        // Associate Pick Ticket Line Items with Pick Ticket using NG Package Id
        Map<String,List<Pick_Ticket_Line_Item__c>> ngPackageIdToPTLIs = new  Map<String,List<Pick_Ticket_Line_Item__c>>();
        // Associate SF Shipments with Pick Ticket using NG Package Id
        Map<String,Shipment__c> ngPackageIdToSFShipment = new  Map<String,Shipment__c>();
        // Use these next two maps in tandem to get the totalfillable for a pick ticket and order.
        Map<String,Double> OrderNumberToFillable = new Map<String,Double>();
        Map<String, Set<OrderItem>> OrderNumberToOLIs = new Map<String, Set<OrderItem>>();
        List<Product2> Products = new List<Product2>();
        Map<String,List<Shipment__c>> shipments = new  Map<String,List<Shipment__c>>();
        Set<OrderItem> OLIs = new Set<OrderItem>();
        List<OrderItem> OLIsToUpsert = new List<OrderItem>();
        // New pick ticket line items for new open PT
        List<Pick_Ticket_Line_Item__c> pickTicketItems = new List<Pick_Ticket_Line_Item__c>();
        Map<Id,String> OrderIDToOrderNumber = new Map<Id,String>();
        Map<String,Id> OrderNumberToPTicketID = new Map<String,Id>();
        Map<String,Order> OrderNumberToOrder = new Map<String,Order>();
        Map<String,String> NGShipIDToSFShipID = new Map<String,String>();
        List<NGUtilityClasses.Shipment> cleanNGShipments = new List<NGUtilityClasses.Shipment>();
        List<String> ShipIds = new List<String>();
        List<Shipment__c> shipmentsTobeInserted = new List<Shipment__c>();
        List<Shipment__c> shipmentsTobeCreated = new List<Shipment__c>();
        Set<Shipment__c> shipmentsSet = new Set<Shipment__c>();
        map<id,List<Pick_Ticket__c>> OrderPTMap = new map<id,List<Pick_Ticket__c>>();
        List<String> ngShipmentIDs = new List<String>();
        Map<String,Order> srShipmentIDToOrderMap = new Map<String,Order>();
        Map<id,List<Pick_Ticket_Line_Item__c>> pickTicketVsLineItemMap = new Map<id,List<Pick_Ticket_Line_Item__c>>();
        ptickets = new list<Pick_Ticket__c>();
        set<String> oNumbers= new set<string>();
        Map<Id,String> OrderIDToOrderNumber2 = new Map<Id,String>();
        
        
       //1. Process all NG SHipments read form the NG Service and load them into Apex Maps and the NGUtilityClass structure   
        if(ShipmentResponses.size() > 0){
            for(NGUtilityClasses.Shipment aShipmentResponse : ShipmentResponses){
                ngShipmentIDs.add(aShipmentResponse.shipmentID); 
                //orderNumbers.add(aShipmentResponse.orderID);
                NGShipIDToNgOrderIDs.put(aShipmentResponse.shipmentID,aShipmentResponse.orderID);
                NgOrderIDsToNGShipID.put(aShipmentResponse.orderID,aShipmentResponse.shipmentID);
                //system.debug('<< SHIPID RESPONSED >>'+aShipmentResponse.shipmentID+' <<  ORDER NUMBER>>'+NGShipIDToNgOrderIDs.get(aShipmentResponse.shipmentID));
           }//For
                
            ordersProcessed = orders.size();
            //system.debug('<< ORDRES OBF and OPF >> '+orders);
            
            // Get SF shipments already created per order Number in order to avoid duplicate PTicket creation
            if(ngShipmentIDs.size() > 0){
                List<Shipment__c> sfShipments = [Select NG_Shipment_ID__c, Id from Shipment__c where NG_Shipment_ID__c in:  ngShipmentIDs];
                for(Shipment__c someShipment : sfShipments){
                    NGShipIDToSFShipID.put(someShipment.NG_Shipment_ID__c,someShipment.NG_Shipment_ID__c);
                     system.debug('<< NGShipIDToSFShipID LOAD >> '+NGShipIDToSFShipID);
                }
           }
        }//IF - NHG SHipments exists
        
    //3. Get order items for all Orders from each NG Shipment Response and incllude the Freight Line Item also.
            /*stockOLIs =[Select Id, Quantity, Order.OrderNumber,ListPrice, UnitPrice, TotalPrice, OrderId, Order.Total_Pick_Tickets__c, Product2Id, Line_Type__c, 
                Product2.ProductCode, Product2.Quantity__c, Product2.Quantity_on_Pick__c, Product2.Quantity_in_Pick_Bin__c, Quantity_Shipped__c, 
                Product2.Quantity_Available__c, Quantity_Fillable__c, Quantity_Given_Away__c, Quantity_Backordered__c, Promo_Code__c, Description,PreOrder_Backorder_Handling__c,Estimated_Weight__c  
            FROM OrderItem WHERE (Line_Type__c like 'S - Stock%'  OR Line_Type__c like '% - Freight%' or Line_Type__c like '% - Text Line%')  and Order.OrderNumber in: NGShipIDToNgOrderIDs.values()];     
            //system.debug('<<stockOLIs>> '+stockOLIs);
            system.debug('<<stockOLIs>> '+stockOLIs.size());*/
            
  //4. Load (Associate)  Orders with their Order Line Items and update TotalFillableItems Calculation for Pick Ticket generation
          try{
              
            for(Order someOrder : orders){
                OrderNumberToOrder.put(someOrder.OrderNumber,someOrder);
                OrderIDToOrderNumber.put(someOrder.Id,someOrder.OrderNumber);
            }
            if(OrderIDToOrderNumber.size()>0)
                    stockOLIs =[Select Id, Quantity, Order.OrderNumber,ListPrice, UnitPrice, TotalPrice, OrderId, Order.Total_Pick_Tickets__c, Product2Id, Line_Type__c, 
                        Product2.ProductCode, Product2.Quantity__c, Product2.Quantity_on_Pick__c, Product2.Quantity_in_Pick_Bin__c, Quantity_Shipped__c, 
                        Product2.Quantity_Available__c, Quantity_Fillable__c, Quantity_Given_Away__c, Quantity_Backordered__c, Promo_Code__c, Description,PreOrder_Backorder_Handling__c,Estimated_Weight__c  
                    FROM OrderItem WHERE (Line_Type__c like 'S - Stock%'  OR Line_Type__c like '% - Freight%' or Line_Type__c like '% - Text Line%')  and Order.OrderNumber in: OrderIDToOrderNumber.values()];     
            system.debug('<<stockOLIs-SIZE>> '+stockOLIs.size());
                
            
            for(Order someOrder : orders){
                OLIs = new Set<OrderItem>();
                if(stockOLIs.size() > 0){
                    Double TotalFillableItems = 1;
                    OrderNumberToOrder.put(someOrder.OrderNumber,someOrder);
                    OrderIDToOrderNumber.put(someOrder.Id,someOrder.OrderNumber);
                    for(OrderItem someOLI : stockOLIs){
                        if(someOrder.OrderNumber == someOLI.Order.OrderNumber){  
                            TotalFillableItems += someOLI.Quantity_Fillable__c;
                            OLIs.add(someOLI);
                            system.debug('<< Ln : 188 someOLI ? >> '+someOLI+ '<<  ORDER NUMBER >> '+someOrder.OrderNumber+' << FILLABLE  >>'+someOLI.Quantity_Fillable__c); 
                       // system.debug('<< Ln : 189 Product2.Quantity__c ? >> '+someOLI.Product2.Quantity__c +'<< Product2.Quantity_on_Pick__c  >>'+someOLI.Product2.Quantity_on_Pick__c);   
                        }
                    }
                    OrderNumberToFillable.put(someOrder.OrderNumber,TotalFillableItems);
                    //system.debug('<< ORDERNUMBER >>'+someOrder.OrderNumber+' << TOTAL FILLABLES >>'+TotalFillableItems);
                    OrderNumberToOLIs.put(someOrder.OrderNumber,OLIs);
                    //system.debug('<< ORDERNUMBER >>'+someOrder.OrderNumber+' << TOTAL FILLABLES >>'+OLIs);
                    }
                 }//FOR     
                
            //system.debug('<< Ln : 198 OrderNumberToOLIs ? >> '+OrderNumberToOLIs +'<< stockOLIs >>'+stockOLIs);      
   //5. Get all the pick tickets for every order and NG SHipment Response record
                for(NGUtilityClasses.Shipment aShipmentResponse : ShipmentResponses){
                    String orderNumber = NGShipIDToNgOrderIDs.get(aShipmentResponse.shipmentID);  
                    if(OrderNumberToOrder.get(orderNumber) != null){
                        Order someOrder = OrderNumberToOrder.get(orderNumber);
                        //We don't want to process the same shipment ID twice for an order (We already have a pick ticket for this shipment ID).
                        system.debug('<< IF -  NGShipIDToSFShipID  == NULL >> '+NGShipIDToSFShipID.get(aShipmentResponse.shipmentID));
                        if(NGShipIDToSFShipID.get(aShipmentResponse.shipmentID) == null ||  NGShipIDToSFShipID.get(aShipmentResponse.shipmentID) == ''){
                            OLIs = OrderNumberToOLIs.get(orderNumber);
                            Double totalFillableItems = OrderNumberToFillable.get(orderNumber);
                            if(someOrder.Inventory_Items__c > 0){
                                Pick_Ticket__c nonNullPT = GeneratePickTickets(someOrder,OLIs,totalFillableItems,aShipmentResponse.shipmentID); 
                                if(nonNullPT != null){
                                    ptickets.add(nonNullPT); 
                                }
                            }
                            srShipmentIDToOrderMap.put(aShipmentResponse.shipmentID,someOrder);// CHange to Order NUmber
                            someOrder.NG_Shipment_ID__c = aShipmentResponse.shipmentID; 
                        }     
                    }
                }//For  
           }catch(SObjectException ex){
                system.debug('There was an exception that occurred while processing Order Numbers. Check the SOQL statements or Http response. '+ex.getMessage());
                system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            }
            try{
                system.debug('<< PICK TICKETS Just INserted >> '+ptickets);
                 if(ptickets.size() > 0){
                    upsert ptickets; 
                }
                system.debug('<< PICK TICKETS Just INserted >> '+ptickets);
                
                //Baji: Re-arrange Pick Ticket Increment Number
                List<Pick_Ticket__c> pnumberIncs = new List<Pick_Ticket__c>(); 
                List<Pick_Ticket__c> pnumberIncsUpdate = new List<Pick_Ticket__c>();
                pnumberIncs = [select Id,Pick_Number_Increment__c,Order__c,NG_Shipment_ID__c from Pick_Ticket__c where Order__c IN :orders];
                OrderPTMap = new map<id,List<Pick_Ticket__c>>();
                Set<id> pickTicketIds = new Set<id>();
                for(Pick_Ticket__c Pt:pnumberIncs){
                    pickTicketIds.add(pt.id);
                    if(OrderPTMap.get(Pt.Order__c)!=null)
                        OrderPTMap.get(Pt.Order__c).add(Pt);
                    else
                        OrderPTMap.put(Pt.Order__c,new List<Pick_Ticket__c>{Pt});
                }
                System.debug('OrderPTMap'+OrderPTMap.size());
                
                //Urvashi : 30-07-2019 - Filling Pick_Ticket_Line_Item__c Map.
                if(!pickTicketIds.isEmpty()){
                    for(Pick_Ticket_Line_Item__c ptli : [select Product__c,Quantity_Ordered__c,Item_Number__c,Quantity_Given_Away__c,Estimated_Weight__c,Quantity__c,Line_Type__c,Price__c,
                                                        Promo_Code__c,Line_Description__c,PreOrder_Backorder_Handling__c,Pick_Ticket__c from Pick_Ticket_Line_Item__c
                                                        Where Pick_Ticket__c IN: pickTicketIds] )                   
                    {
                        if(pickTicketVsLineItemMap.get(ptli.Pick_Ticket__c)!= null)
                            pickTicketVsLineItemMap.get(ptli.Pick_Ticket__c).add(ptli);
                        else
                            pickTicketVsLineItemMap.put(ptli.Pick_Ticket__c,new List<Pick_Ticket_Line_Item__c>{ptli});
                    }
                }
                
                if(ptickets.size () > 0){
                    for(Order o: orders){
                        //pnumberIncs = [select Id,Pick_Number_Increment__c from Pick_Ticket__c where Order__c =: o.Id];
                        pnumberIncs=OrderPTMap.get(o.Id);
                        
                            Integer i = 0;
                            for(Pick_Ticket__c pt: pnumberIncs){
                                pt.Pick_Number_Increment__c = pt.Pick_Number_Increment__c + i;
                                i++;
                                pnumberIncsUpdate.add(pt);   
                            }
                    }
                }
                update pnumberIncsUpdate;
            }catch(DMLException ex){
                system.debug('There was a DML exception that occurred while processing Pick Tickets. Check the GeneratePickTickets method. '+ex.getMessage());
                system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
            }
    //6. Store each  Order Number per Pick Ticket to create new SF SHipment Records and PT Line items.
            for(Pick_Ticket__c aPT : ptickets){
                String orderNumber = OrderIDToOrderNumber.get(aPT.Order__c);
               // system.debug('<< PT ORDERID >>'+aPT.Order__c+' << orderNumber >>'+OrderIDToOrderNumber.get(aPT.Order__c));
                OrderNumberToPTicketID.put(orderNumber,aPT.Id);
               // system.debug('<< ORDERNUMBER >>'+orderNumber+' << PTicketID >>'+aPT.Id);
            }
    // 7. Create the Search Shipment Response list for each Order  
            Pick_Ticket__c somePickTicket;    
            Shipment__c someShipment;
   
    //8. Now For Each NG SHipment Record get the SF Shipment Record if One already exists (Previous Back order)
            system.debug('<<SHIPMENT RESPONSE TOTAL  >> '+ ShipmentResponses.size());
            NGUtilityClasses.Shipment nextShipmentResponse;
            NGUtilityClasses.Shipment previousShipmentResponse;
            for(NGUtilityClasses.Shipment aShipmentResponse : ShipmentResponses){
               system.debug('<<Ln: 236  aShipmentResponse >> '+aShipmentResponse);
                Order someOrder = srShipmentIDToOrderMap.get(aShipmentResponse.shipmentID);
              
                system.debug('<<Ln: 265 someOrder >> '+someOrder);
                if(someOrder != null &&  aShipmentResponse.orderID == someOrder.OrderNumber){
                    system.debug('<<Ln: 238 someOrder >> '+someOrder);
                    for(Pick_Ticket__c p:ptickets){
                        system.debug('PT Shipment ID:>>'+p.NG_Shipment_ID__c+'Response Shipment ID:>>'+aShipmentResponse.shipmentID);
                        if(p.NG_Shipment_ID__c == aShipmentResponse.shipmentID){
                            system.debug('Shipment matches');
                            shipmentsTobeCreated.clear();
                            shipmentsTobeCreated = GenerateSFShipments(p.Id,someOrder,aShipmentResponse); 
                        }
                    }
                    shipmentsTobeInserted.addAll(shipmentsTobeCreated);
                    
                    if(OrderNumberToPTicketID.get(someOrder.OrderNumber)!= null){
                        OLIs = OrderNumberToOLIs.get(someOrder.OrderNumber);
                        system.debug('<< OrderNumber >> '+someOrder.OrderNumber+' << OLIS >> '+OLIs);
     //9. Process NG SHipment Global Items
                        system.debug('<< aShipmentResponse.items >> '+aShipmentResponse.items);
                        if(aShipmentResponse.items != null){
                            String frtCode = custSettings.FRT_Code__c;
                            String taxCode = custSettings.TAX_Code__c;
                            OrderItem saveFRT = new OrderItem();
                            OrderItem saveTAX = new OrderItem();
                            Boolean gotItems = false;
                            Decimal backOrderQuantity = 0.0;
                            Integer backOrderSize = 0;
                            List<Pick_Ticket__c> orderPts = new List<Pick_Ticket__c>();
                     
                            orderPts = OrderPTMap.get(someOrder.Id);
                            pts=OrderPTMap.get(someOrder.Id);
                            system.debug('No. Of PTs for Current Order: '+pts.size());
                                
                            //Refresh line items lists for each order.
                            ptls = new List<Pick_Ticket_Line_Item__c>();
                            ptlsNonStock = new List<Pick_Ticket_Line_Item__c>();
                            
                            for(Pick_Ticket__c pt :pts){
                                if(pickTicketVsLineItemMap.containsKey(pt.id)){                                 
                                    ptls.addAll(pickTicketVsLineItemMap.get(pt.id));
                                    for(Pick_Ticket_Line_Item__c ptli : pickTicketVsLineItemMap.get(pt.id)){
                                        if(ptli.Line_Type__c!=null && (ptli.Line_Type__c.contains('- Non-Stock') || ptli.Line_Type__c.contains('P - Donation') || ptli.Line_Type__c.contains('- Direct Ship') ))
                                            ptlsNonStock.add(ptli);
                                        /* if(ptli.Line_Type__c.startsWith('ND - Non-Stock')){
                                            ptlsNonStock.add(ptli);
                                        } */
                                    }
                                }                               
                            }
                            
                            
                            for(NGUtilityClasses.Item anItem : aShipmentResponse.items){
                                for(Pick_Ticket__c p: orderPts){
                                        //Pick_Ticket__c pickt = [select NG_Shipment_ID__c,Id from Pick_Ticket__c where id =: p.Id];                                        
                                        for(OrderItem someOLI : OLIs){
                                            system.debug('<< COMPARE OLI PCODE>> '+someOLI.Product2.ProductCode+' << SKU >> '+anItem.sku );
                                            if((anItem.sku == someOLI.Product2.ProductCode) && (someOLI.Order.OrderNumber == someOrder.OrderNumber) && (p.NG_Shipment_ID__c == aShipmentResponse.ShipmentID)){
                                                pickTicketItems.add(new Pick_Ticket_Line_Item__c(Pick_Ticket__c=p.Id,Product__c=someOLI.Product2Id, Quantity_Ordered__c=someOLI.Quantity, 
                                                Item_Number__c=someOLI.Product2.ProductCode, Quantity_Given_Away__c=someOLI.Quantity_Given_Away__c,Estimated_Weight__c =  someOLI.Estimated_Weight__c,Quantity__c=anItem.qty,
                                                Line_Type__c=someOLI.Line_Type__c, Price__c=someOLI.UnitPrice, Promo_Code__c = someOLI.Promo_Code__c, Line_Description__c = someOLI.Description, PreOrder_Backorder_Handling__c = someOLI.PreOrder_Backorder_Handling__c));
     
                                                someOLI.Quantity_Shipped__c = anItem.qty;    // anItem.qty represents Total Qty Fillable.
                                                system.debug('<< PTLIS SO FAR >> '+pickTicketItems+'<<  PER ORDER ID>> '+someOrder.OrderNumber);
                                                gotItems = true;
                                                //break;
                                            }else{
                                                system.debug('Inside Freight and Tax');
                                                if(someOLI.Product2.ProductCode == frtCode){
                                                    saveFRT = someOLI;
                                                }
                                                if(someOLI.Product2.ProductCode == taxCode){
                                                    saveTAX = someOLI;
                                                }
                                            }
                                        }// Loop - OLIs
                                        
                                    }//PickTickets for Order
                          }//Loop - NG Global Items per order
                            if(gotItems == true){                                
                                    
                                    Boolean freightExist = false;
                                    if(pts.size() > 0){
                                        system.debug('PTs exist, So Check whether Freight exist or not');
                                        for(Pick_Ticket_Line_Item__c ptli: ptls){         
                                           if(ptli.Item_Number__c == '43490')
                                           {
                                                freightExist = true;
                                                break;
                                            }
                                        }      
                                        if(!freightExist){
                                            system.debug('Since Freight Not-Exist on the PTLIs, create Freight PTLI');
                                            system.debug('<< ADD FRT >>');
                                            if(ptlsNonStock.size() > 0){
                                                pickTicketItems.add(new Pick_Ticket_Line_Item__c(Pick_Ticket__c =pts[1].Id, Item_Number__c=frtCode,Product__c=saveFRT.Product2Id, Quantity_Ordered__c=1,Quantity__c=1,Line_Description__c = 'Freight Charge', Line_Type__c ='F - Freight' ,Price__c=saveFRT.UnitPrice)); 
                                            }
                                            else{
                                                pickTicketItems.add(new Pick_Ticket_Line_Item__c(Pick_Ticket__c =pts[0].Id, Item_Number__c=frtCode,Product__c=saveFRT.Product2Id, Quantity_Ordered__c=1,Quantity__c=1,Line_Description__c = 'Freight Charge', Line_Type__c ='F - Freight' ,Price__c=saveFRT.UnitPrice)); 
                                            }
                                        }
                                        else{
                                            system.debug('Since Freight Exist on the PTLIs, donot Create another Freight');
                                        }
                                    }
                            }
                        }// IF NG SR Items
                    }//IF
                    upsert someOrder;
                } //IF - ShipResp OID = OID?
            }//Loop - NG Ship Master  
        try{
      //10. Upsert PTLIS and to check which ones have 0 ine items
      Set<Pick_Ticket_Line_Item__c> ptis = new Set<Pick_Ticket_Line_Item__c>();
      List<Pick_Ticket_Line_Item__c> plsList = new List<Pick_Ticket_Line_Item__c>();
        if(pickTicketItems.size() > 0){
            ptis.addAll(pickTicketItems);
            plsList.addAll(ptis);
            upsert plsList;
        }
        //Insert all the shipments
        if(shipmentsTobeInserted.size() > 0){
            upsert shipmentsTobeInserted;
        }
            
        List<Shipment__c> allShipments = new List<Shipment__c>();
        if(shipments.size() > 0){
            system.debug('<< ln: 350 A - SHIPMENTS  >> '+shipments.size());
            for(String orderNumber: shipments.keySet()){
                List<Shipment__c> sfShipments = shipments.get(orderNumber);
                for(Shipment__c aShipment : sfShipments){
                    allShipments.add(aShipment);
                }
            }
            if(allShipments.size() > 0){
                upsert allShipments;
            }
        }
            
        //Code to delete extra PT for orders sent in the same time frame
        List<Pick_Ticket_Line_Item__c> pitls = new List<Pick_Ticket_Line_Item__c>();
        List<Pick_Ticket__c> ptDelete = new List<Pick_Ticket__c>();
        List<Pick_Ticket__c> ptToBeClosed = new List<Pick_Ticket__c>();
        List<Pick_Ticket__c> ptickets2 = [Select id,Name, Total_Pick_Ticket_Line_Items__c,Order__c,Status__c, (select Product__c,Quantity_Ordered__c,Item_Number__c,Quantity_Given_Away__c,Estimated_Weight__c,Quantity__c,Line_Type__c,Price__c,Promo_Code__c,Line_Description__c,PreOrder_Backorder_Handling__c from Pick_Ticket_Line_Items__r) from Pick_Ticket__c where Id IN:ptickets];
        system.debug('No. Of PTs for Current Order: '+ptickets.size()+'-'+ptickets2.size());
        
        for(Pick_Ticket__c pit: ptickets2){
            //pitls = [select Product__c,Quantity_Ordered__c,Item_Number__c,Quantity_Given_Away__c,Estimated_Weight__c,Quantity__c,Line_Type__c,Price__c,Promo_Code__c,Line_Description__c,PreOrder_Backorder_Handling__c from Pick_Ticket_Line_Item__c where Pick_Ticket__c =: pit.Id];
            pitls = pit.Pick_Ticket_Line_Items__r;
            system.debug('No. Of PTLIs for all for PT: '+pitls.size());
            if(pitls.size() == 0){
                system.debug('Empty Pick Ticket: '+ pit.Id);
                ptDelete.add(pit);
            }
            else{
                ptToBeClosed.add(pit);
            }
        }
        
    /*system.debug('PTs received in Finish method'+ptToBeClosed.size());
      Map<Id, Pick_Ticket__c> mapPT = new Map<Id, Pick_Ticket__c>();
      for(Pick_Ticket__c p : ptToBeClosed){
          mapPT.put(p.Id, p);
      }
      system.debug('PTs to be closed in Finish method'+mapPT.size());
      if(ptToBeClosed.size() > 0){
            for(Pick_Ticket__c aPT : mapPT.Values()){
                if(aPT.Total_Pick_Ticket_Line_Items__c != 0){
                    aPT.Status__c = 'Closed';
                }else{
                    delete0PTs.add(aPT);
                }  
            }
            if(delete0PTs.size() > 0){
                delete delete0PTs;
            }
            
            update mapPT.Values(); 
        } */
        
        // 11. Close off pick tickets that have been filled
         List<Pick_Ticket__c> delete0PTs = new List<Pick_Ticket__c>();
         if(ptToBeClosed.size() > 0){
            for(Pick_Ticket__c aPT : ptToBeClosed){
                if(aPT.Total_Pick_Ticket_Line_Items__c != 0){
                    aPT.Status__c = 'Closed';
                }else{
                    delete0PTs.add(aPT);
                }  
            }
            if(delete0PTs.size() > 0){
                delete delete0PTs;
            }
            if(ptickets.size() > 0){
                upsert ptToBeClosed; 
            } 
        }
        
        /*if(orders.size() > 0){
            system.debug('<< ln: 342 A - ORDERS  >> '+orders);
            //upsert orders;
            printOrders = orders;
        }*/
        if(stockOLIs.size() > 0){
            //system.debug('<< ln: 354 A - STOKOLIS  >> '+stockOLIs); 
            upsert stockOLIs;
        }
      //system.debug('PTs to be closed in Finish method'+ptToBeClosed.size());
        
        }catch(CalloutException ex){
            system.debug('There was an exception that occurred while updating order objects and their child obejcts '+ex.getMessage());
            system.debug('<< Stack Trace >> '+ex.getStackTraceString()+' << Line Number >> '+ex.getLineNumber());
        }// Try-Catch
    }//execute method
    
    /*****************************************************************************************
     * GeneratePickTickets() - Taken from the Original GeneratePickTicket in OrderEntryStatus
    ******************************************************************************************/
    private Pick_Ticket__c GeneratePickTickets(Order someOrder,Set<OrderItem> stockOLIs, Double TotalFillableItems,String ngShipmentID){
        // See OrderEntrystatus and copy that inito here.
        system.debug(' INSIDE GEN PTS: <<ORDER>> '+someOrder);
        system.debug(' INSIDE GEN PTS: <<stockOLIs>> '+stockOLIs);
        system.debug(' INSIDE GEN PTS: <<TotalFillableItems>> '+TotalFillableItems);
        Pick_Ticket__c pticket = new  Pick_Ticket__c();
         // !!! generate pick tickets (See Apex Code OrderEntryStatus)
       // system.debug('Inventory Items: '+someOrder.Inventory_Items__c+'; '+'Non-Inventory: '+someOrder.Non_inventory_Items__c+'; '+'Total Fillable: '+TotalFillableItems);
    
        if(someOrder.Inventory_Items__c > 0 && TotalFillableItems >= 1){
            system.debug('case 1 : I>0  TF>0');
                 pticket =new Pick_Ticket__c(Order__c=someOrder.Id,Status__c='Open',NG_Shipment_ID__c=ngShipmentID,Company__c=someOrder.Company__c,Package_Shipped__c = true,Shipment_Created__c = true );
        }
        else if(someOrder.Inventory_Items__c > 0  && TotalFillableItems <= 0){
            system.debug('case 2 : I>0 TF=0');
            // do not generate a pick ticket
            someOrder.Pick_Ticket_Not_Fulfillable__c = true;
        }//TW: 2-28-13 If an odr is of Payment Status "To Be Billed" then that is similar to a Back order and the ticket shouldbe closed.
        else if(someOrder.Inventory_Items__c > 0  && TotalFillableItems <= 0){
            system.debug('case 3 : I>0  TF=0');   
            if(stockOLIs.size() > 0){
                if(someOrder.Inventory_Items__c > 0 && TotalFillableItems <= 0){
                    someOrder.Pick_Ticket_Not_Fulfillable__c = true;
                }
            }//END TW 4-3-2012
            else{
                someOrder.Pick_Ticket_Not_Fulfillable__c = true;
            }
        }
        else {
            system.debug('case 4 else');
            String OrderError = someOrder.Error_Log__c;
            if(OrderError != null) { OrderError += '\n'; } else { OrderError = ''; }
                someOrder.Error_Log__c = OrderError + String.valueOf(DateTime.Now())+': Attempted to generate Pick Ticket, but did not match any case. I='+
                someOrder.Inventory_Items__c+' N='+someOrder.Non_inventory_Items__c+' TF='+TotalFillableItems;
        }                   
     system.debug(pticket);
        system.debug('<<  GENERATE PTS - LAST INSIDE PTICKETS >> '+ptickets);
     return pticket;
    }// Method GeneratePickTicket
    
    /*****************************************************************************************
     * GenerateSFShipments() - Taken from the Original GeneratePickTicket in OrderEntryStatus
    ******************************************************************************************/
    private List<Shipment__c> GenerateSFShipments(ID PTicketID, Order someOrder,NGUtilityClasses.Shipment aShipmentResponse){
        List<Shipment__c> pkgShipments = new List<Shipment__c>();
        for(NGUtilityClasses.NGPackage aPacakge: aShipmentResponse.packages){
            Integer pos = 0;
            Shipment__c someShipment = new Shipment__c(Order__c=someOrder.Id, Pick_Ticket__c = PTicketID, Shipment_Method__c=aShipmentResponse.shipMethod,Tracking_Number__c=aPacakge.trackingNumber,ShipmentCreated__c=true, NG_Shipment_ID__c=aShipmentResponse.shipmentID);
            if(aShipmentResponse.ShippedDate != '' &&  aShipmentResponse.ShippedDate != null){
                    pos = aShipmentResponse.ShippedDate.indexOf('T');
                    if(pos >0){
                        system.debug('<<aShipmentResponse.ShippedDate >> '+aShipmentResponse.ShippedDate+' with Position of: '+pos+'<< Results of Date: '+aShipmentResponse.ShippedDate.substring(0,pos));
                        aShipmentResponse.ShippedDate = aShipmentResponse.ShippedDate.substring(0,pos);
                        someShipment.Ship_Date__c =  Date.valueOf(aShipmentResponse.ShippedDate);
                    }
            }
            if(aShipmentResponse.ExpectedDeliveryDate != '' &&  aShipmentResponse.ExpectedDeliveryDate != null){
                    pos = aShipmentResponse.ExpectedDeliveryDate.indexOf('T');
                    if(pos >0){
                        system.debug('<<aShipmentResponse.ExpectedDeliveryDate >> '+aShipmentResponse.ExpectedDeliveryDate+' with Position of: '+pos+'<< Results of Date: '+aShipmentResponse.ExpectedDeliveryDate.substring(0,pos));
                        aShipmentResponse.ExpectedDeliveryDate = aShipmentResponse.ExpectedDeliveryDate.substring(0,pos);
                        someShipment.Expected_Delivery_Date__c =  Date.valueOf(aShipmentResponse.ExpectedDeliveryDate);
                    }
            }
            if(aShipmentResponse.weight  != '' &&  aShipmentResponse.weight != null){
                    someShipment.Shipping_Weight__c = Decimal.valueOf(aShipmentResponse.weight);
            } 
            if(aShipmentResponse.shipMethodCode  != '' &&  aShipmentResponse.shipMethodCode != null){
                    someShipment.Carrier__c = aShipmentResponse.shipMethodCode;
            } 
            pkgShipments.add(someShipment);
        }// PKG-FOR    
        return  pkgShipments;
    }
    
   /************************************************************
  * finsh() - Method sends a diagnostic email to the SF admins
  *************************************************************/
  global void finish(Database.BatchableContext BC){
      AsyncApexJob apexBatchResult = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: BC.getJobId()
        ];
    
        // Generate email body
        String emailBody = ' Apex Batch Search Newgistics Shipment objects  processed: '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
        
        emailBody += '<<==== NG Shipment Responses processed ====>>: '+ShipmentResponses.size()+'\n\n';
        Integer eolineCnt = 0;
       for(NGUtilityClasses.Shipment aShipmentResponse: ShipmentResponses){
            if(eolineCnt == 10){emailBody +='\n\n'; eolineCnt = 0;}
            if(eolineCnt < 9){
                emailBody += aShipmentResponse.shipmentID+', ';
            }else{
                 emailBody += aShipmentResponse.shipmentID;
            }
            eolineCnt++;
        }
        //3. Get User Ids for the Acocunt Team Updates Group.
            Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN (
                                    SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'SF Administrator')]);
            
            
            List<String> userEmail = new List<String>();
            //We need to make sure that the Test coverage will work when testing emails otherwise a REQUIRED_FIELD_MISSING, Missing exception will occur.
            if(Test.isRunningTest()){
                User tUser=[Select Email from User where Name Like 'MyAwana%' Limit 1];
                userEmail.add(tUser.Email);
            }else{
                    userEmail.add('SFApps@awana.org');
            }
            List<String> sendTo = new List<String>();
            sendTo.addAll(userEmail);
        // Send email
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('TEST ORG: Processes Newgistics Shipments');
        mail.setSubject('TEST ORG: Batch to Processes Newgistics Shipments: ' + apexBatchResult.Status);
        mail.setPlainTextBody('TEST ORG: Batch Process has completed\n\n' + emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
  }// Method finish
}//Class