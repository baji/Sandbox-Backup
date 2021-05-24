/*********************************************************************************************************
    Programmer:         Sowmya
    Company:            Awana
    Contact:            sowmya@infoglen.com
    Project:            <SFDC-26> 
    Original:           10/14/2016 - Used to test Order entry
    
 ***********************************************************************************************************/ 

@IsTest(SeeAllData=true)
public class OrderEntryStatus_Test{

  public static testMethod void TestOrderEntryStatus()
    {
        Test.startTest();
            List<Order> Orders;   
            Order ord,ord1;         
            try{
                ord = FullOrder();
            }catch(Exception e ){ system.debug(e.getmessage());}
            
            OrderEntryStatus OES = new OrderEntryStatus();
            Test.setCurrentPage(Page.OrderEntryStatus);
            
            OES.getOrdersSize();
            OES.getStatusType();
            OES.getContentType();
            OES.getUseCustomQuery();
            OES.getIsTest();
            OES.getTotalBatchJobs();
            OES.getTotalProcessingBatchJobs();
            OES.getOrdersToPickLimit();
            OES.setOrdersToPickLimit(100);
           
            OES.setIsTest(true);
            OES.callUseCustomQuery();
            
            OES.setStatusType('Duplicates');
            OES.QueryOrders(); Orders = OES.getOrders();
    
            OES.setStatusType('error');
            OES.QueryOrders(); Orders = OES.getOrders(); OES.getOrdersSize();
            
           Test.setCurrentPage(Page.OrderEntryStatus);
            
            OES.setStatusType('error_no_so');
            OES.QueryOrders(); Orders = OES.getOrders();
            
            OES.setStatusType('error_no_fip');
            OES.QueryOrders(); Orders = OES.getOrders();
            
            OES.setStatusType('error_no_shipper');
            OES.QueryOrders(); Orders = OES.getOrders();
            
            OES.setStatusType('error_no_invoice');
            OES.QueryOrders(); Orders = OES.getOrders(); OES.getOrdersSize();
          
            OES.setUseCustomQuery(true);
            OES.setStatusType('error');
            OES.generateQuery();
            OES.setCustomQuery(OES.getCustomQuery());
            OES.QueryOrders(); Orders = OES.getOrders();
            OES.setStatusType(null); OES.getStatusType(); OES.setStatusType('error');
              
            OES.setOrderId(ord.Id);
            OES.getOrderId();
            OES.setOrderStatus('Order Error');
            OES.getOrderStatus();
            OES.ResubmitOrder();
            
            try{
                ord1 = TestObjects.NewOrder();
                ord1.Status = 'Draft';
                insert ord1;
            }catch(Exception e ){ system.debug(e.getmessage());}
            
            
            OES.ExportToExcel();
            OES.GenerateAllBackorderPickTickets();
            OES.setOrderStatus('Order Open');
            OES.DeleteDuplicateErrorsWithNoLineItems();
            OrderEntryStatus.CancelBackorderedLines('1234567890'); 
           
            OES.setStatusType('canada_orders_to_pick');
            OES.generateQuery();
            
            OES.setStatusType('rush_orders_to_pick');
            ord1.Rush_Order__c = true;
            OES.generateQuery();
            
            OES.setStatusType('backorders_to_pick');
            OES.generateQuery();
            
            OES.setCustomNameSearch(ord1.Name);
            OES.getCustomNameSearch();
            OES.generateQuery();
            
            OES.GeneratePickTickets();
        
        Test.stopTest();
        
    }
    
    public static testmethod void TestOrdersToVerifyPickItems(){
        
            Order ord1 =  FullOrder();
            Order ord2 =  FullOrder();
            try{    
                insert ord1;
                insert ord2;
            }catch(Exception e){ system.debug('exception ---'+e.getmessage());}
            Test.startTest();
             Id pricebookId = Test.getStandardPricebookId();
            
            Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test',Line_Type__c = 'S - Stock Inventory Item',ProductCode = '0012');
            insert prod;
    
            PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
            Insert standardPE;
            
            OrderItem oItem = new OrderItem();
            oItem.OrderId = ord1.id;
            oItem.PricebookEntryId = standardPE.id;
            //oItem.Product2id  = prod.id;
            oItem.Quantity  = 2;
            oItem.UnitPrice  = 1000.89;
            oItem.Line_Type__c = 'S - Stock Inventory Item';
            Insert oItem;
            
            Pick_Ticket__c pick = new Pick_Ticket__c();
            pick.Order__c = ord1.id;
            insert pick; 
            
            OrderEntryStatus OES = new OrderEntryStatus();
            
            OrderEntryStatus OESWithParameter = new OrderEntryStatus('ByPass');
            OES.setCustomNameSearch(ord1.Name);
            OES.getCustomNameSearch();
            
            system.debug('order details ---'+ord1);
            OES.OrderId = ord1.id;
            OES.GeneratePickTicket();
            
            OES.setOrderId(ord1.id);
           OrderEntryStatus.CancelBackorderedLines(ord2.id);
           OrderEntryStatus.QueueGeneratePickTicket(ord1.id);
           OES.setOrderStatus('Order Error');
           OES.ResubmitOrder();
         Test.stopTest(); 
    }
    
    public static testmethod void TestOrdersToPick(){
        
            List<Order> Orders;  
            Order ord2 =  FullOrder();
            Order ord1 = FullOrder();
            try{    
                insert ord1;
                insert ord2;
            }catch(Exception e){ system.debug('exception ---'+e.getmessage());}
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test',Line_Type__c = 'S - Stock Inventory Item',ProductCode = '0012');
            insert prod;
    
            PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
            Insert standardPE;
            
            OrderItem oItem = new OrderItem();
            oItem.OrderId = ord1.id;
            oItem.PricebookEntryId = standardPE.id;
            //oItem.Product2id  = prod.id;
            oItem.Quantity  = 2;
            oItem.UnitPrice  = 1000.89;
            oItem.Line_Type__c = 'S - Stock Inventory Item';
            Insert oItem;
            
            Pick_Ticket__c pick = new Pick_Ticket__c();
            pick.Order__c = ord1.id;
            insert pick; 
            
            system.debug('ord1--'+ord1);
             
            Test.setCurrentPage(Page.OrdersToPick);
            OrderEntryStatus OES = new OrderEntryStatus();
            
            Orders = OES.getOrders(); 
            OES.getOrdersSize();
            OES.setOrdersToPickLimit(1); OES.GetHasNextOrders(); OES.GetHasPreviousOrders();
            OES.QueryNextOrders(); OES.QueryPreviousOrders();
            OES.getSetControllerPageNumber(); OES.getSetControllerPageSize(); OES.getSetControllerResultSize();
            OES.setOrdersToPickLimit(100); OES.GetHasNextOrders(); OES.GetHasPreviousOrders();
            OES.QueryNextOrders(); OES.QueryPreviousOrders();
            OES.getSetControllerPageNumber(); OES.getSetControllerPageSize(); OES.getSetControllerResultSize(); 
            
            system.debug('order is ===='+ ord1.id);
            OES.setOrderId(ord1.id);
            OES.GeneratePickTicket();
            
          List<OrderItem> AllLineItems = new List<OrderItem>();
            
            OrderItem LineItem = new OrderItem(
                    Quantity      = 1, 
                    PriceBookEntryId  = standardPE.Id, 
                    UnitPrice      = 0.01, 
                    OrderId    = ord1.Id, 
                    Line_Type__c    = 'S - Stock Inventory Item' 
                );
                
            insert LineItem ;
            Test.startTest();    
            OES.GeneratePickTicket();
            
            LineItem.Quantity = 10 ;
            update LineItem;
              
            OES.GeneratePickTicket();
            
            OrderItem LineItem1 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'D - Direct Ship Item' );
            AllLineItems.add(LineItem1);
            OrderItem LineItem2 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'N - Non-Stock' );
            AllLineItems.add(LineItem2);
            OrderItem LineItem4 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'ND - Non-Stock Downloadable' );
            AllLineItems.add(LineItem4);
            
            upsert AllLineItems;
            OES.GeneratePickTicket();
               
           
           OrderItem LineItem5 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord2.Id, Line_Type__c = 'D - Direct Ship Item' );
           insert LineItem5;
           OES.setOrderId(ord2.id); 
           OES.GeneratePickTicket();
       
       Test.stopTest(); 
    }
    
    public static testmethod void TestOrdersToPickItems(){
        
            List<Order> Orders;  
            List<OrderItem> AllLineItems = new List<OrderItem>();
            Order ord1 = FullOrder();
            try{    
                insert ord1;
            }catch(Exception e){ system.debug('exception ---'+e.getmessage());}
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test',Line_Type__c = 'S - Stock Inventory Item',ProductCode = '0012');
            insert prod;
    
            PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
            Insert standardPE;
            
            OrderItem oItem = new OrderItem();
            oItem.OrderId = ord1.id;
            oItem.PricebookEntryId = standardPE.id;
            //oItem.Product2id  = prod.id;
            oItem.Quantity  = 1;
            oItem.UnitPrice  = 1000.89;
            oItem.Line_Type__c = 'SB - Subscription';
            try{
                Insert oItem;
            }catch(Exception e){ system.debug('exception ---'+e.getmessage());}
            
            Pick_Ticket__c pick = new Pick_Ticket__c();
            pick.Order__c = ord1.id;
            insert pick; 
            system.debug('ord1--'+ord1);
           Test.startTest();
           Test.setCurrentPage(Page.OrdersToPick);
           OrderEntryStatus OES = new OrderEntryStatus();
           OES.OrderId = ord1.id;
           OES.GeneratePickTicket();  
           
           OrderItem oItem1 = new OrderItem();
            oItem1.OrderId = ord1.id;
            oItem1.PricebookEntryId = standardPE.id;
            //oItem.Product2id  = prod.id;
            oItem1.Quantity  = 1;
            oItem1.UnitPrice  = 1000.89;
            oItem1.Line_Type__c = 's - stock Inventory Item';
            oItem1.Estimated_Weight__c = 30;
            Insert oItem1;
        
           OES.setOrderId(ord1.id);
           OrderEntryStatus.CancelBackorderedLines(ord1.id);
           
            OrderItem LineItem1 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'D - Direct Ship Item' );
            AllLineItems.add(LineItem1);
            OrderItem LineItem2 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'N - Non-Stock' );
            AllLineItems.add(LineItem2);
            OrderItem LineItem3 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'F - Freight' );
            AllLineItems.add(LineItem3);
            OrderItem LineItem4 = new OrderItem(Quantity= 10,PriceBookEntryId  = standardPE.Id,UnitPrice = 0.01, OrderId = ord1.Id, Line_Type__c = 'SB - Subscription' );
            AllLineItems.add(LineItem4);
           
            insert AllLineItems;
            
            OrderEntryStatus.CancelBackorderedLines(ord1.id);
            
            OES.setStatusType('Order Being Partially Fulfilled');
            ord1.status = 'Order Being Partially Fulfilled';
            update ord1;
            OrderEntryStatus.CancelBackorderedLines(ord1.id);
            
       Test.stopTest();
       
   }
   
    public static Order FullOrder()
    {
      //Test.startTest();
            User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
            List<Account> accts = new List<Account>();
            accts.add(FullAccount());
            insert accts;
            system.debug('accts--'+accts);
            List<Contact> contacts = new List<Contact>();
            contacts.add(TestObjects.FullContact());
            insert contacts;
            List<Order> testOrd = new List<Order>();
            testOrd.add(TestObjects.NewOrder());
            Id pricebookId = Test.getStandardPricebookId();
            Integer i = 0;
            //OrderEntryServices.Result result = OrderEntryServices.GetNextOrderNumber('O',accts[i].Mailing_Address_Book__c);    
            testOrd[i].Name = 'O-111-';
            testOrd[i].Type = 'Shipping';
            testOrd[i].Company__c = 'Awana';
            testOrd[i].Order_Type__c = 'SO';
            testOrd[i].Shipping_Country__c =  'UNITED STATES';
            ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
            
            cOrder.ChargentOrders__Billing_First_Name__c = contacts[i].FirstName;
            cOrder.ChargentOrders__Billing_Last_Name__c = contacts[i].LastName;
            cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
            cOrder.ChargentOrders__Billing_Country__c = 'United States';
            insert cOrder;
            testOrd[i].Chargent_Order__c = cOrder.Id;
            testOrd[i].Promo_code__c= '';
            testOrd[i].OwnerId = ouser.Id;
            testOrd[i].Payment_Terms__c = 'Net 30';
            testOrd[i].Shipping_Type__c = 'Priority Mail'; 
            testOrd[i].Shipping_Code__c = 'PRI';              
            testOrd[i].Shipping_Carrier__c = 'POST';
            //testOrd[i].Notes__c ='Tes Order for faux client';
            testOrd[i].Pricebook2Id = pricebookId;
            testOrd[i].AccountId = accts[i].Id;
            
            system.debug('<< BEFORE ORDER ITEMS >> '+testOrd);
            system.debug('<< ACCOUNTID ORDER ITEMS >> '+testOrd[i].AccountId);
            system.debug('Order has not been inserted. Set the PriceBook2Id and AccountId for this Order before insert.');
        //Test.stoptest();
        return testOrd[i];
    }
    
    public static Account FullAccount(){
        //Test.startTest();
            RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
            Account someAcct =  new Account(Name='Christian Test Church Canada', Description='Test Church');
            system.debug('<<GOT ACCT VALUE?>> '+someAcct.Description);
            someAcct.RecordTypeId = acctRecordType.Id;
            system.debug('<<ENTERING INTO  acct>> '+someAcct );
            someAcct.ShippingStreet = '5921 Walnut Hill Ln';
            someAcct.ShippingState = 'TX';
            someAcct.ShippingPostalCode = '75230';
            someAcct.ShippingCountry = 'UNITED STATES';
            someAcct.ShippingCity = 'Waco';
        //Test.stopTest();
        return someAcct;
    }
   
} // class