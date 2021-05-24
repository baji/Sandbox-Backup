/*
Purpose - Class PostShipmentRequest_Test  - NEW-25,28
Description - Code used to test REst API  Http call out to Newgistics Warehouse for new orders  as well as non-stock orders thast dont call out. 
Author - Tony Wiliams.
*/
@isTest  (SeeAllData = True)
private class PostShipmentRequestCallOut_Test {
 @isTest static void testFRTCHRG() {
         // Set mock callout class 
   
        List<String> orderIds = new List<String>();
        Account a = [Select Id, Name,Mailing_Address_Book__c from Account where RecordType.Name = 'US Organization' and Status__c = 'Added'  and Account_On_Hold__c = false  and Mailing_Address_Book__c <> null and BillingStreet <> null ANd
        BillingCity <> null AND BillingPostalcode <> null and BillingState <> null and billingcountry <> null limit 1];
         // Set mock callout class 
        // Create Order   
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__c =:a.Id limit 1];
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(Aff.npe5__Contact__c,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        
        
        Order Ord  = (Order)r.ObjectOutput;
        Ord.AccountId = a.Id; 
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        // sETUP oRDER sOURCE
        system.debug('##ORDER'+Ord);
        
        // Add Shipping Firstname, Lastname and all else on the PostShipmentRequest class.
        Ord.Ship_to_First_Name__c = 'Ben';
        Ord.Ship_to_Last_Name__c = 'Callhoun';
        Ord.Shipping_Street__c ='1415 Casa Dr';
        Ord.Shipping_City__c = 'Austin';
        Ord.Shipping_State__c = 'TX';
        Ord.Shipping_Zip_Code__c = '78745';
        Ord.Shipping_Country__c = 'United States';
        Ord.Shipping_Country_Code__c = 'US';
        Ord.Billing_Email__c = 'someone@mailinator.com';
        Ord.Payment_Terms__c = 'Net 30';
        
        update Ord;
           List<OrderItem> orderItems = new List<OrderItem>();
        //=-======================================================================
         List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
       
        Ord.Pricebook2Id = OrderPriceBookEntryList[0].PriceBook2Id;
        upsert Ord;
        
       List<PriceBookEntry> ProductFRT = [Select Id,UnitPrice,Product2.ProductCode From PriceBookEntry Where Product2.Name like 'Freight' Limit 1];
       List<PriceBookEntry> ProductTAX = [Select Id,UnitPrice,Product2.ProductCode From PriceBookEntry Where  Product2.Name like 'Tax' Limit 1];
       
     
        List<OrderItem> checkItems = new List<OrderItem>();
        checkItems.add(new OrderItem(Line_Type__c='F - Freight',
                        UnitPrice=0,
                        PricebookEntryId    = ProductFRT[0].Id,
                        Quantity            =1,
                        OrderId = Ord.Id,
                        PreOrder_Backorder_Handling__c='backorder')); 
        
         checkItems.add(new OrderItem(Line_Type__c='T - Text Line',
                        UnitPrice=9.00,
                        PricebookEntryId    = ProductTAX[0].Id,
                        Quantity            =1,
                        OrderId = Ord.Id,
                        PreOrder_Backorder_Handling__c='backorder'));      
          
        system.debug('<< CHECKITEMS - FRTCHRG >> '+checkItems);
          Ord.Status = 'Order Submitted';
        upsert Ord;
        Ord.Status = 'Order Confirmed';
        upsert Ord;
        Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=Ord.Id,Status__c='Closed', Company__c=Ord.Company__c);
        insert pt;
        Map<Id,List<OrderItem>> ordersWithNonStockItems  =  new  Map<Id,List<OrderItem>>();
        ordersWithNonStockItems.put(Ord.Id,checkItems);
        list<Pick_Ticket__c> tickets = new list<Pick_Ticket__c>();
        tickets.add(pt);
        IDHelper ih1 = new IDHelper(Ord.Id);
        orderIds.add(JSON.serialize(ih1));
        Test.startTest();
        PostShipmentRequest.postOrders(orderIds);
        //PostShipmentRequestBaji.postOrders(orderIds);
        PostShipmentRequest.createNSPickTicketItems(tickets,ordersWithNonStockItems);  
        //PostShipmentRequestBaji.createNSPickTicketItems(tickets,ordersWithNonStockItems);
        Test.stopTest();
    }  
  @isTest static void testPostNet30() {
      Test.setMock(HttpCalloutMock.class, new WB_Mock(true));
      Account a = [Select Id, Name,Mailing_Address_Book__c from Account where RecordType.Name = 'US Organization' and Status__c = 'Added'  and Account_On_Hold__c = false  and Mailing_Address_Book__c <> null and BillingStreet <> null ANd
        BillingCity <> null AND BillingPostalcode <> null and BillingState <> null and billingcountry <> null limit 1];
         // Set mock callout class 
        List<String> orderIds = new List<String>();
        // Create Order
        List<PriceBookEntry> PBs = [Select  Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like 'S - Stock%' and isActive = true  limit 2];
   npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__c =:a.Id limit 1];
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(Aff.npe5__Contact__c,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        Order Ord  = (Order)r.ObjectOutput;
        Ord.AccountId  = a.Id;
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        // sETUP oRDER sOURCE
        system.debug('##ORDER'+Ord);
        // Add Shipping Firstname, Lastname and all else on the PostShipmentRequest class.
        Ord.Ship_to_First_Name__c = 'Ben';
        Ord.Ship_to_Last_Name__c = 'Callhoun';
        Ord.Shipping_Street__c ='1415 Casa Dr';
        Ord.Shipping_City__c = 'Austin';
        Ord.Shipping_State__c = 'TX';
        Ord.Shipping_Zip_Code__c = '78745';
        Ord.Shipping_Country__c = 'United States';
        Ord.Shipping_Country_Code__c = 'US';
        Ord.Billing_Email__c = 'someone@mailinator.com';
        Ord.Billing_Phone__c='7735682471';
        
        Address__c someBilling = new Address__c();
        someBilling.Address_Line_1__c = '1415 Casa Dr';
        someBilling.First_Name__c = 'Ben';
        someBilling.Last_Name__c = 'Calhoun';
        someBilling.City__c = 'Austin';
        someBilling.State__c = 'TX';
        someBilling.Zip_Code__c = '78745';
        someBilling.Country__c = 'United States';
        insert someBilling;
        Ord.Billing_Address__c = someBilling.Id;
    
        update Ord;
        List<OrderItem> orderItems = new List<OrderItem>();
        //=-======================================================================
       
        Ord.Payment_Terms__c = 'Net 30';
        String Code = PBs[0].Product2.ProductCode;
        Decimal ordPrice =  PBs[0].UnitPrice;
        OrderEntryServices.AddProduct(Ord.Id,Code,2,ordPrice,0,'1.00','S - Stock Inventory Item');
        OrderEntryServices.AddProduct(Ord.Id,'43490',1,7.99,0,'','F - Freight'); 
        OrderEntryServices.AddProduct(Ord.Id,'57779',1,.99,0,'','T - Text Line');
        Ord.Payment_Terms__c = 'Net 30';
        List<OrderItem> checkItems = [SELECT Id, Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name
                                FROM OrderItem WHERE (Line_Type__c like 'S - Stock%' or Line_Type__c like 'T - Text Line%' or Line_Type__c like 'F - Freight') and OrderId =: Ord.Id ];
       
        system.debug('<< ORDER ITEMS >> '+checkItems+'<<ORDFER NUMBER >> '+Ord.OrderNumber);
        
        Ord.Status = 'Order Submitted';
        upsert Ord;
        Ord.Status = 'Order Confirmed';
        upsert Ord;
        checkRecursive.setBatchStatus('NGSearch');
        IDHelper ih1 = new IDHelper(Ord.Id);
        orderIds.add(JSON.serialize(ih1));
        Test.setMock(HttpCalloutMock.class, new WB_Mock(true));
        //String XMLString =  PostShipmentRequest.CreateXMLTemplate(Ord, checkItems);
        String builtJSON = PostShipmentRequest.CreateJSON(Ord, checkItems);
        system.debug('<< ORDER ITEMS >> '+checkItems+'<<ORDFER NUMBER  >> '+Ord.OrderNumber);
        Map<Id,List<OrderItem>> ordersWithNonStockItems  =  new  Map<Id,List<OrderItem>>();
        ordersWithNonStockItems.put(Ord.Id,checkItems);
        list<Pick_Ticket__c> tickets = new list<Pick_Ticket__c>();
        Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=Ord.Id,Status__c='Closed', Company__c=Ord.Company__c);
        tickets.add(pt);
        Test.startTest();
            PostShipmentRequest.postOrders(orderIds);
            ResendOrdertoWB.resendOrdertoWB(Ord.Id);
        Test.stopTest();
        
    }

   /* @isTest static void testPostNet320() {
      Test.setMock(HttpCalloutMock.class, new WB_Mock(true));
      Account a = [Select Id, Name,Mailing_Address_Book__c from Account where RecordType.Name = 'US Organization' and Status__c = 'Added'  and Account_On_Hold__c = false  and Mailing_Address_Book__c <> null and BillingStreet <> null ANd
        BillingCity <> null AND BillingPostalcode <> null and BillingState <> null and billingcountry <> null limit 1];
         // Set mock callout class 
        List<String> orderIds = new List<String>();
        // Create Order
        List<PriceBookEntry> PBs = [Select  Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like 'S - Stock%' and isActive = true  limit 2];
   npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__c =:a.Id limit 1];
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(Aff.npe5__Contact__c,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        Order Ord  = (Order)r.ObjectOutput;
        Ord.AccountId  = a.Id;
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        // sETUP oRDER sOURCE
        system.debug('##ORDER'+Ord);
        // Add Shipping Firstname, Lastname and all else on the PostShipmentRequest class.
        Ord.Ship_to_First_Name__c = 'Ben';
        Ord.Ship_to_Last_Name__c = 'Callhoun';
        Ord.Shipping_Street__c ='1415 Casa Dr';
        Ord.Shipping_City__c = 'Austin';
        Ord.Shipping_State__c = 'TX';
        Ord.Shipping_Zip_Code__c = '78745';
        Ord.Shipping_Country__c = 'United States';
        Ord.Shipping_Country_Code__c = 'US';
        Ord.Billing_Email__c = 'someone@mailinator.com';
        Ord.Billing_Phone__c='7735682471';
        
        Address__c someBilling = new Address__c();
        someBilling.Address_Line_1__c = '1415 Casa Dr';
        someBilling.First_Name__c = 'Ben';
        someBilling.Last_Name__c = 'Calhoun';
        someBilling.City__c = 'Austin';
        someBilling.State__c = 'TX';
        someBilling.Zip_Code__c = '78745';
        someBilling.Country__c = 'United States';
        insert someBilling;
        Ord.Billing_Address__c = someBilling.Id;
    
        update Ord;
        List<OrderItem> orderItems = new List<OrderItem>();
        //=-======================================================================
       
        Ord.Payment_Terms__c = 'Net 30';
        String Code = PBs[0].Product2.ProductCode;
        Decimal ordPrice =  PBs[0].UnitPrice;
        OrderEntryServices.AddProduct(Ord.Id,Code,2,ordPrice,0,'1.00','S - Stock Inventory Item');
        OrderEntryServices.AddProduct(Ord.Id,'43490',1,7.99,0,'','F - Freight'); 
        OrderEntryServices.AddProduct(Ord.Id,'57779',1,.99,0,'','T - Text Line');
        Ord.Payment_Terms__c = 'Net 30';
        List<OrderItem> checkItems = [SELECT Id, Quantity,OrderId,Product2.ProductCode,Product2Id,Line_Type__c,PreOrder_Backorder_Handling__c,Quantity_Given_Away__c,PricebookEntry.Product2.ProductCode,UnitPrice,PricebookEntry.Product2.Name
                                FROM OrderItem WHERE (Line_Type__c like 'S - Stock%' or Line_Type__c like 'T - Text Line%' or Line_Type__c like 'F - Freight') and OrderId =: Ord.Id ];
       
        system.debug('<< ORDER ITEMS >> '+checkItems+'<<ORDFER NUMBER >> '+Ord.OrderNumber);
        
        Ord.Status = 'Order Submitted';
        upsert Ord;
        Ord.Status = 'Order Confirmed';
        upsert Ord;
        IDHelper ih1 = new IDHelper(Ord.Id);
        orderIds.add(JSON.serialize(ih1));
        Test.setMock(HttpCalloutMock.class, new WB_Mock(true));
        //String XMLString =  PostShipmentRequest.CreateXMLTemplate(Ord, checkItems);
        String builtJSON = PostShipmentRequest.CreateJSON(Ord, checkItems);
        system.debug('<< ORDER ITEMS >> '+checkItems+'<<ORDFER NUMBER  >> '+Ord.OrderNumber);
        Map<Id,List<OrderItem>> ordersWithNonStockItems  =  new  Map<Id,List<OrderItem>>();
        ordersWithNonStockItems.put(Ord.Id,checkItems);
        checkRecursive.setBatchStatus('NGSearch');
        list<Pick_Ticket__c> tickets = new list<Pick_Ticket__c>();
        Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=Ord.Id,Status__c='Closed', Company__c=Ord.Company__c);
        insert pt;
        tickets.add(pt);
        Shipment__c Ship = new Shipment__c(Order__c=Ord.Id, Pick_Ticket__c = pt.Id, NG_Shipment_ID__c='3312979',NG_Package_ID__c='989898',Ship_Date__c =  Date.today());
        insert Ship;
        Test.startTest();
            ResendOrdertoWB.CancelShipment(Ship.Id,'3312979');
        Test.stopTest();
    }*/

    @isTest static void testTBB() {
        // Set mock callout class 
        List<String> orderIds = new List<String>();
        Account a = [Select Id, Name,Mailing_Address_Book__c from Account where RecordType.Name = 'US Organization' and Status__c = 'Added'  and Account_On_Hold__c = false  and Mailing_Address_Book__c <> null and BillingStreet <> null ANd
        BillingCity <> null AND BillingPostalcode <> null and BillingState <> null and billingcountry <> null limit 1];
        // Set mock callout class 
        // Create Order
        List<PriceBookEntry> PBs = [Select  Product2.Weight__c, Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '% - Non-Stock%' and isActive = true  limit 2];
   npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__c =:a.Id limit 1];
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(Aff.npe5__Contact__c,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        Order Ord  = (Order)r.ObjectOutput;
        Ord.AccountId = a.Id; Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        // sETUP oRDER sOURCE
        system.debug('##ORDER'+Ord);
        
        // Add Shipping Firstname, Lastname and all else on the PostShipmentRequest class.
        Ord.Ship_to_First_Name__c = 'Ben';
        Ord.Ship_to_Last_Name__c = 'Callhoun';
        Ord.Shipping_Street__c ='1415 Casa Dr';
        Ord.Shipping_City__c = 'Austin';
        Ord.Shipping_State__c = 'TX';
        Ord.Shipping_Zip_Code__c = '78745';
        Ord.Shipping_Country__c = 'United States';
        Ord.Shipping_Country_Code__c = 'US';
        Ord.Billing_Email__c = 'someone@mailinator.com';
        Ord.Payment_Terms__c = 'To Be Billed';
        update Ord;
           List<OrderItem> orderItems = new List<OrderItem>();
        //=-======================================================================
         List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
       
        Ord.Pricebook2Id = OrderPriceBookEntryList[0].PriceBook2Id;
        upsert Ord;
        
       List<PriceBookEntry> ProductFRT = [Select Id,UnitPrice,Product2.ProductCode From PriceBookEntry Where Product2.Name like 'Freight' Limit 1];
       List<PriceBookEntry> ProductTAX = [Select Id,UnitPrice,Product2.ProductCode From PriceBookEntry Where  Product2.Name like 'Tax' Limit 1];
       
     
        List<OrderItem> checkItems = new List<OrderItem>();
        checkItems.add(new OrderItem(Line_Type__c='F - Freight',
                        UnitPrice=0,
                        PricebookEntryId    = ProductFRT[0].Id,
                        Quantity            =1,
                        OrderId = Ord.Id,
                        PreOrder_Backorder_Handling__c='backorder')); 
        
         checkItems.add(new OrderItem(Line_Type__c='T - Text Line',
                        UnitPrice=9.00,
                        PricebookEntryId    = ProductTAX[0].Id,
                        Quantity            =1,
                        OrderId = Ord.Id,
                        PreOrder_Backorder_Handling__c='backorder'));      
          
        system.debug('<< CHECKITEMS - FRTCHRG >> '+checkItems);
          Ord.Status = 'Order Submitted';
        upsert Ord;
        Ord.Status = 'Order Confirmed';
        upsert Ord;
        Pick_Ticket__c pt = new Pick_Ticket__c(Order__c=Ord.Id,Status__c='Closed', Company__c=Ord.Company__c);
        insert pt;
        checkItems.add(new OrderItem(Line_Type__c='N - Non-Stock',
                        UnitPrice=PBS[0].UnitPrice,
                        PricebookEntryId    = PBS[0].Id,
                        Quantity            =1,
                        OrderId = Ord.Id,
                        PreOrder_Backorder_Handling__c='backorder')); 
        
        checkItems.add(new OrderItem(Line_Type__c='N - Non-Stock',
                        UnitPrice=PBS[0].UnitPrice,
                        PricebookEntryId    = PBS[1].Id,
                        Quantity            =1,
                        OrderId = Ord.Id,
                        PreOrder_Backorder_Handling__c='backorder'));
        
        Map<Id,List<OrderItem>> ordersWithNonStockItems  =  new  Map<Id,List<OrderItem>>();
        ordersWithNonStockItems.put(Ord.Id,checkItems);
        list<Pick_Ticket__c> tickets = new list<Pick_Ticket__c>();
        tickets.add(pt);
       
        IDHelper ih1 = new IDHelper(Ord.Id);
        orderIds.add(JSON.serialize(ih1));
        Test.startTest();
        PostShipmentRequest.postOrders(orderIds);
        //PostShipmentRequestBaji.postOrders(orderIds);
        PostShipmentRequest.createNSPickTicketItems(tickets,ordersWithNonStockItems);  
        //PostShipmentRequestBaji.createNSPickTicketItems(tickets,ordersWithNonStockItems);
        Test.stopTest();
    }   
    
    @isTest static void testPostShipmentTrigger() {
        
        Test.StartTest();
        
        Order o = new Order();
        Account a1 = [Select Id, Name,Mailing_Address_Book__c from Account where RecordType.Name = 'US Organization' and Status__c = 'Added'  and Account_On_Hold__c = false  and Mailing_Address_Book__c <> null and BillingStreet <> null ANd
        BillingCity <> null AND BillingPostalcode <> null and BillingState <> null and billingcountry <> null limit 1];
        
        o.AccountId = a1.Id;
        o.Status = 'Order Submitted';
        o.EffectiveDate = System.today();
        insert o;
        
        //Order ord = [SELECT id,Status FROM Order WHERE Status = 'Order Submitted' Limit 1];
        
        o.Status = 'Order Confirmed';
        
        update o;
        Test.stopTest();
    }
    
       
}