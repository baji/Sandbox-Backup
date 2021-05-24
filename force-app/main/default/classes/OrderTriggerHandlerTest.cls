@isTest
Public class OrderTriggerHandlerTest{

    public static testMethod void testAfterUpdateOrderSubmitConfirm(){
        
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'WBOrderAPI';
        custmSetting.Value__c = 'false';
        insert custmSetting;
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Minds';
        acc.Mailing_Address_Book__c = '000123';
        acc.Registration_Number__c='US1234';
        insert acc;
        
        Id pricebookIds = Test.getStandardPricebookId();
        Id priceBookId = Test.getStandardPricebookId();
        
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        //ord.Chargent_Order__c = cn.Id;
        ord.Status='Order Open';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'test@awana.org';
        ord.Pricebook2Id = pricebookIds;
        ord.Payment_Terms__c = 'Net 30';
        insert ord;
        
        Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test',Quantity_Reserved__c = 2.00);
        insert prod;

        PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
        Insert standardPE;
        
        OrderItem oItem = new OrderItem();
        oItem.OrderId = ord.id;
        oItem.PricebookEntryId = standardPE.id;
        oItem.Product2id  = prod.id;
        oItem.Quantity  = 2;
        oItem.UnitPrice  = 1000.89;
        oItem.Line_Type__c = 'S - Stock Inventory Item';
        Insert oItem;
        
        ord.Status='Order Submitted';       
        update ord;
               
        System.assertEquals([SELECT Status FROM Order WHERE Id =:ord.id].Status ,'Order Confirmed');
        System.assertEquals([SELECT Quantity_Reserved__c FROM Product2 WHERE Id =:prod.id].Quantity_Reserved__c,4.00);
    
    }
    
    public static testMethod void testAfterUpdateOrderSubmitOnHold(){
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Minds';
        acc.Mailing_Address_Book__c = '000123';
        acc.Registration_Number__c='US1234';
        //acc.Account_On_Hold__c = True;
        insert acc;
        
       
        Id pricebookIds = Test.getStandardPricebookId();
        Id priceBookId = Test.getStandardPricebookId();
        
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
   
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        //ord.Chargent_Order__c = cn.Id;
        ord.Status='Order Open';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'test@awana.org';
        ord.Pricebook2Id = pricebookIds;
        insert ord;
        
        OrderTriggerHandler.runTest = true;
        
        ord.Status='Order Submitted';          
        update ord;
               
        System.assertEquals([SELECT Status FROM Order WHERE Id =:ord.id].Status ,'Order on Hold');
            
    }
    
    public static testMethod void testAfterUpdateOrderSubmitCancel(){
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Minds';
        acc.Mailing_Address_Book__c = '000123';
        acc.Registration_Number__c='US1234';
        insert acc;
        
        Id pricebookIds = Test.getStandardPricebookId();
        Id priceBookId = Test.getStandardPricebookId();
        
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        //ord.Chargent_Order__c = cn.Id;
        ord.Status='Order Open';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'test@awana.org';
        ord.Payment_Terms__c = 'Net 30';
        ord.Pricebook2Id = pricebookIds;
        insert ord;
        
        Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test',Quantity_Reserved__c = 4.00);
        insert prod;

        PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
        Insert standardPE;
        
        OrderItem oItem = new OrderItem();
        oItem.OrderId = ord.id;
        oItem.PricebookEntryId = standardPE.id;
        oItem.Product2id  = prod.id;
        oItem.Quantity  = 2;
        oItem.UnitPrice  = 1000.89;
        oItem.Line_Type__c = 'S - Stock Inventory Item';
        Insert oItem;
        
        ord.Status='Order Confirmed';          
        update ord;
        
        ord.Status='Order Cancelled';       
        update ord;
                       
        System.assertEquals([SELECT Quantity_Reserved__c FROM Product2 WHERE Id =:prod.id].Quantity_Reserved__c,2.00);
    
    }    
    
    
   
}