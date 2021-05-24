@isTest(SeeAllData = True)
public class BatchSearchWBShipmentsTest {
   static testMethod void SearchShipments1_TestMethod (){
        //1. Create an order with no pick tickets for first test of stock OLIs
         // Set mock callout class 
        List<String> orderIds = new List<String>();
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Contact c = TestObjects.NewGenericContact();
        c.accountid = a.id;
        insert c;
        npe5__Affiliation__c aff = new npe5__Affiliation__c( npe5__Organization__c  = a.Id,npe5__Contact__c = c.Id);
        
        insert aff;
        // Create Order
        Id priceBookId = Test.getStandardPricebookId();
        Ord.AccountId  = a.Id;
        Ord.Pricebook2Id = pricebookId;
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        // sETUP oRDER sOURCE
        system.debug('##ORDER'+Ord);
        insert Ord;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
        // Add Shipping Firstname, Lastname and all else on the PostShipmentRequest class.
        Ord.Ship_to_First_Name__c = c.FirstName;
        Ord.Ship_to_Last_Name__c = c.LastName;
        Ord.Shipping_Street__c ='1415 Casa Dr';
        Ord.Shipping_City__c = 'Austin';
        Ord.Shipping_State__c = 'TX';
        Ord.Shipping_Zip_Code__c = '78745';
        Ord.Shipping_Country__c = 'United States';
        Ord.Billing_Email__c = 'someone@mailinator.com';
        Ord.Payment_Terms__c = 'Net 30';
        update Ord;
        
        List<OrderItem> orderItems = new List<OrderItem>();
        //=-======================================================================


        
        List<PriceBookEntry> ProductsToAdd2 = [Select Product2.ProductCode,Product2.Id,Pricebook2.Name,Product2.Line_Type__c,Product2.Downloadable_Product_URL__c,Product2.PreOrder_Backorder_Handling__c,Product2.Weight__c From PriceBookEntry Where  Pricebook2.Name='Standard Price Book' and Product2.Name like 'Classic Membership%' Limit 1];
        List<PricebookEntry> ProductsToAddWB = [Select Product2.ProductCode,Product2.Id,Pricebook2.Name,Product2.Line_Type__c,Product2.Downloadable_Product_URL__c,Product2.PreOrder_Backorder_Handling__c,Product2.Weight__c from PriceBookEntry Where  Pricebook2.Name='Standard Price Book' and currencyISOCode='USD' and (Product2.ProductCode='41267' OR Product2.ProductCode='15587' OR Product2.ProductCode='34265' OR Product2.ProductCode='32150' OR Product2.ProductCode='16096' OR Product2.ProductCode='21143' OR Product2.ProductCode='14537' OR Product2.ProductCode='36982' OR Product2.ProductCode='14561' OR Product2.ProductCode='41814' OR Product2.ProductCode='34522' OR Product2.ProductCode='20423')];

       
      for(PricebookEntry Item : ProductsToAddWB)
        {
            orderItems.add( new OrderItem(
                        Quantity            = 5, 
                        PricebookEntryId    = Item.Id, 
                        OrderId       = Ord.Id, 
                        Line_Type__c        = 'S - Stock Inventory Item',
                        Price_of_Discount__c = 2.95,
                        UnitPrice = 5.95,
                        Promo_Code__c ='Sales Promotion',
                        Downloadable_Product_URL__c =  Item.Product2.Downloadable_Product_URL__c,
                        PreOrder_Backorder_Handling__c= Item.Product2.PreOrder_Backorder_Handling__c,
                        Estimated_Weight__c = Item.Product2.Weight__c * 5
                    ));
             
        }
         for(PricebookEntry Item : ProductsToAdd2)
        {
            orderItems.add( new OrderItem(
                        Quantity            = 5, 
                        PricebookEntryId    = Item.Id, 
                        OrderId       = Ord.Id, 
                        Line_Type__c        = 'N - Non-Stock',
                        Price_of_Discount__c = 2.95,
                        UnitPrice = 5.95,
                        Promo_Code__c ='Sales Promotion',
                        Downloadable_Product_URL__c =  Item.Product2.Downloadable_Product_URL__c,
                        PreOrder_Backorder_Handling__c= Item.Product2.PreOrder_Backorder_Handling__c
                        //Estimated_Weight__c = Item.Product2.Weight__c * 5
                    ));
        }  
        
        insert orderItems;
        OrderEntryServices.GetOrderAmounts1(Ord.Id);
        
        orderItems= [Select Id,Quantity,UnitPrice From OrderItem Where OrderId = :Ord.Id];
        system.debug('<< QUERIED ORDER ITEMS >> '+orderItems);
        //Ord.OrderNumber = '01999999';
        //===================================================================================
        Ord.Status = 'Order Being Fulfilled';
        update Ord;
        BatchSearchWBShipments batchObjBSNS = new BatchSearchWBShipments();
        Newgistics_Settings__c custSettings = Newgistics_Settings__c.getValues('NewgsticsAPIFields');
        batchObjBSNS.custSettings= [SELECT id,End_Shipped_Time__c,Start_Shipped_Time__c,NG_API_Key__c,Added_Hours__c,NG_Endpoint__c,FRT_Code__c,TAX_Code__c from  Newgistics_Settings__c];
        batchObjBSNS.custSettings.End_Shipped_Time__c  = String.valueOf(DateTime.now());
        batchObjBSNS.custSettings.Start_Shipped_Time__c = String.valueOf(DateTime.now().addHours(-2));
        //String query 
        //      = 'SELECT Id FROM Order Limit 1' ;       
        //system.debug('<< QUERY  >> '+query);
        
         Set<String> OrderNos = new Set<String>();
        List<Order> os = [select Id,OrderNumber from Order where Id =: Ord.Id];
         for(Order o: os){
             OrderNos.add(o.OrderNumber);
         }
         system.debug('ORDNUMS---'+OrderNos);
         String query  = 'SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,'
                +'Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c,Estimated_Weight__c,' 
                +'Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Tax__c,Shipment_Cost__c,Payment_Terms__c,'
                +'AccountId, Account.Name, OrderNumber, Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name,'
                +'HasOrderLineItem__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c,'
                +'Total_Pick_Quantity__c, Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,'
                +'Order.NG_Shipment_ID__c, (Select Id,NG_Package_ID__c,NG_Shipment_ID__c,Order__c From Pick_Tickets__r where Status__c=\'Open\') '
                +'FROM Order '
                +'where (Status = \'Order Being Fulfilled\' or Status like \'%Partially%\')'
                +' And (NOT Status like \'%Cancelled%\')'
                +' And OrderNumber IN: OrderNos';
               
        system.debug('<< QUERY  >> '+query);
        
        Test.startTest();
        String json ='{"shipmentCount":1,"shipments":[{"id":989898,"orderId":2431394,"merchantOrderId":"'+os[0].OrderNumber+'","status":"SHIPPED","shipDate":"2020-04-24 11:08:49","carrier":"fedex","service":"fedex_international_economy","tracking":"392210113498","totalWeight":"44.31","trackingUrl":"http://www.fedex.com/Tracking?action=track&tracknumbers=392210113498","latestTrackingEvent":{"statusDescription":"Test"},"isVoided": false,"containers":[{"id":490317,"shipmentId":989898,"sscc":null,"weight":"44.31","length":"24.00","height":"17.00","width":"16.00","packageCode":"package","items":[{"id":696975,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269471,"sku":"AWNA-41267-001-MCF","upc":"41267","clientSku":"41267"},{"id":696976,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269053,"sku":"AWNA-15587-001-MCF","upc":"15587","clientSku":"15587"},{"id":696977,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269499,"sku":"AWNA-34265-001-MCF","upc":"34265","clientSku":"34265"},{"id":696978,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269035,"sku":"AWNA-32150-001-MCF","upc":"32150","clientSku":"32150"},{"id":696979,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269218,"sku":"AWNA-16096-001-MCF","upc":"16096","clientSku":"16096"},{"id":696980,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269105,"sku":"AWNA-21143-001-MCF","upc":"21143","clientSku":"21143"},{"id":696981,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268925,"sku":"AWNA-14537-001-MCF","upc":"14537","clientSku":"14537"},{"id":696982,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269109,"sku":"AWNA-36982-001-MCF","upc":"36982","clientSku":"36982"},{"id":696983,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268928,"sku":"AWNA-14561-001-MCF","upc":"14561","clientSku":"14561"},{"id":696984,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269502,"sku":"AWNA-41814-001-MCF","upc":"41814","clientSku":"41814"},{"id":696985,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269158,"sku":"AWNA-34522-001-MCF","upc":"34522","clientSku":"34522"},{"id":696986,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269103,"sku":"AWNA-20423-001-MCF","upc":"20423","clientSku":"20423"},{"id":696987,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269603,"sku":"AWNA-16053-001-MCF","upc":"16053","clientSku":"16053"}]}]}]}';
        batchObjBSNS.query = query;
        batchObjBSNS.Teststring = json;
        //Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
        HttpRequest req;
        Database.executeBatch(batchObjBSNS);
        
                
        String cronExpression = '0 15 2 * * ? ';
        BatchWBNightlyJob snsswbd = new BatchWBNightlyJob(); 
        String jobID = system.schedule('Daily PT Close', cronExpression, snsswbd);
      
        Test.stopTest();
       
      
    }
    
  public static testMethod void SearchShipments2_TestMethod (){
        //2. Add open Pick Ticket and shipmen object for second test (New method) 
        BatchSearchWBShipments batchObjBSNS = new BatchSearchWBShipments();
         String query 
              = 'SELECT Id,OrderNumber FROM Order Limit 1' ;
               
        system.debug('<< QUERY  >> '+query);
        Test.startTest();
        batchObjBSNS.query = query;
        Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
        Database.executeBatch(batchObjBSNS);
        BatchSearchWBShipments job = new BatchSearchWBShipments();
      
        Test.stopTest();
    }  
  public static testMethod String CreateSHipments_TestMethod(){
      Order Ord = [SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,
                Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c, 
                Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Shipment_Cost__c, 
                AccountId, Account.Name, OrderNumber,
                Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, 
                LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, 
                Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,Order.NG_Shipment_ID__c, 
                (Select Id, Name From Pick_Tickets__r)
                FROM Order WHERE (Status = 'Order Being Fulfilled' or Status like '%Partially%') 
                And (NOT Status like '%Cancelled%') LIMIT 1];
        system.debug('ORDNUMS:--'+Ord.Id+'----'+Ord.OrderNumber);
        String json ='{"shipmentCount":1,"shipments":[{"id":989898,"orderId":2431394,"merchantOrderId":"'+Ord.OrderNumber+'","status":"SHIPPED","shipDate":"2020-04-24 11:08:49","carrier":"fedex","service":"fedex_international_economy","tracking":"392210113498","totalWeight":"44.31","trackingUrl":"http://www.fedex.com/Tracking?action=track&tracknumbers=392210113498","latestTrackingEvent":{"statusDescription":"Test"},"isVoided":true,"containers":[{"id":490317,"shipmentId":989898,"sscc":null,"weight":"44.31","length":"24.00","height":"17.00","width":"16.00","packageCode":"package","items":[{"id":696975,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269471,"sku":"AWNA-41267-001-MCF","upc":"41267","clientSku":"41267"},{"id":696976,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269053,"sku":"AWNA-15587-001-MCF","upc":"15587","clientSku":"15587"},{"id":696977,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269499,"sku":"AWNA-34265-001-MCF","upc":"34265","clientSku":"34265"},{"id":696978,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269035,"sku":"AWNA-32150-001-MCF","upc":"32150","clientSku":"32150"},{"id":696979,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269218,"sku":"AWNA-16096-001-MCF","upc":"16096","clientSku":"16096"},{"id":696980,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269105,"sku":"AWNA-21143-001-MCF","upc":"21143","clientSku":"21143"},{"id":696981,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268925,"sku":"AWNA-14537-001-MCF","upc":"14537","clientSku":"14537"},{"id":696982,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269109,"sku":"AWNA-36982-001-MCF","upc":"36982","clientSku":"36982"},{"id":696983,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4268928,"sku":"AWNA-14561-001-MCF","upc":"14561","clientSku":"14561"},{"id":696984,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269502,"sku":"AWNA-41814-001-MCF","upc":"41814","clientSku":"41814"},{"id":696985,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269158,"sku":"AWNA-34522-001-MCF","upc":"34522","clientSku":"34522"},{"id":696986,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269103,"sku":"AWNA-20423-001-MCF","upc":"20423","clientSku":"20423"},{"id":696987,"shipmentId":989898,"shipmentContainerId":490317,"shipQty":5,"skuId":4269603,"sku":"AWNA-16053-001-MCF","upc":"16053","clientSku":"16053"}]}]}]}';
        WBShipment obj = WBShipment.parse(json);
        Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
        return json;  
    }
}