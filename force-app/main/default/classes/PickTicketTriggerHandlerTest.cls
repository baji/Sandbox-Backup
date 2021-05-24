@isTest
public class PickTicketTriggerHandlerTest {
    
    public static testMethod void testAfterUpdate(){
        test.startTest();
        Pick_Ticket__c pkt = [SELECT Id,Status__c FROM Pick_Ticket__c WHERE Status__c = 'Open'];
        
        pkt.status__c = 'Closed';
        update pkt;
        
        test.stopTest();
        
        Pick_Ticket__c updatedPkt = [SELECT Id,Status_Closed__c FROM Pick_Ticket__c WHERE Status__c = 'Closed'];
        
        List<Product2> updatedProductList = [SELECT Id,Quantity_Reserved__c,Quantity__c
                                             FROM Product2 
                                             WHERE Name = 'Test Prod' Limit 1];
        
        
        system.assertEquals(true,updatedPkt.Status_Closed__c);

        system.assertEquals(1.00,updatedProductList[0].Quantity_Reserved__c);
        
        system.assertEquals(1.00,updatedProductList[0].Quantity__c);
        
    }
    
    public static testMethod void testBeforeInsert(){
        
        test.startTest();
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'WBOrderAPI';
        custmSetting.Value__c = 'false';
        insert custmSetting;
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Test';
        acc.Mailing_Address_Book__c = '000124';
        acc.Registration_Number__c='US1235';
        insert acc;
        
        Id pricebookIds = Test.getStandardPricebookId();
        Id priceBookId = Test.getStandardPricebookId();
        
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        ord.Status='Order Open';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'test@awana.org';
        ord.Pricebook2Id = pricebookIds;
        ord.Payment_Terms__c = 'Net 30';
        insert ord;
        
        Product2 prod = new Product2(Name= 'Membership', Description= 'Test',Quantity_Reserved__c = 2.00,Quantity__c = 2.00);
        insert prod;
        
        Pick_Ticket__c pkt = new Pick_Ticket__c();
        pkt.Order__c = ord.id;
        pkt.status__c = 'Closed';
        insert pkt; 
		
        test.stopTest();
        Pick_Ticket__c updatedPkt = [SELECT Id,Status_Closed__c
                                     FROM Pick_Ticket__c
                                     WHERE Id=:pkt.id];
		        
        
        system.assertEquals(true,updatedPkt.Status_Closed__c);

        
    }
    
    @testSetup
    static void createData() {
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
        ord.Status='Order Open';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'test@awana.org';
        ord.Pricebook2Id = pricebookIds;
        ord.Payment_Terms__c = 'Net 30';
        insert ord;
        
        Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test',Quantity_Reserved__c = 2.00,Quantity__c = 2.00);
        insert prod;
        
        Product2 prod2 = new Product2(Name= 'Test Prod2', Description= 'Test',Quantity_Reserved__c = 2.00,Quantity__c = 2.00);
        
        PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
        Insert standardPE;
        
        Pick_Ticket__c pkt = new Pick_Ticket__c();
        pkt.Order__c = ord.id;
        pkt.status__c = 'Open';
        insert pkt; 
        
        Pick_Ticket_Line_Item__c pktLineItem = new Pick_Ticket_Line_Item__c();
        pktLineItem.Pick_Ticket__c = pkt.id;
        pktLineItem.Product__c = prod.id;
        pktLineItem.Quantity__c = 1.00;
        pktLineItem.Line_Type__c = 'S - Stock Inventory Item';
        insert pktLineItem;
        
        Pick_Ticket_Line_Item__c pktLineItem2 = new Pick_Ticket_Line_Item__c();
        pktLineItem2.Pick_Ticket__c = pkt.id;
        pktLineItem2.Product__c = prod2.id;
        pktLineItem2.Quantity__c = 1.00;
        pktLineItem2.Line_Type__c = 'S - Stock Inventory Item';
        insert pktLineItem2;
        
        //List<str>errorList = new string[] {'test1','test2'};
        
        
    }
    
    static testMethod void testNotification(){
        Test.startTest();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        
        User u = createTestUser(profileId,'TestAdmin','Awana');
        insert u;	 
        
        List<String >errorList = new List<String>{'test1','test2'};
            PickTicketTriggerHandler.sendErrorNotificationToAdmin(errorList);   
        Test.stopTest();
    }
    
    public static User createTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = 
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId);
        return tuser;
    }
}