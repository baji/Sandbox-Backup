/***************************************************************************************************************************************************************************************
    Programmer: Ayesha Zulkha.  
    Company:    Awana
    Contact:    ayesha@infoglen.com
    Project:    <Advocacy>
    Description: Test ProcessOrderTrigger 
    Created:    12/28/2017 - ProcessOrderTrigger_Test
***************************************************************************************************************************************************************************************/
@isTest(seeAllData=true)
public class ProcessOrderTrigger_Test {
    public static testMethod void testRecursiveCheck()
    {
      checkRecursive.runOnce();
      checkRecursive.runOnceOrderSubmit();
      checkRecursive.runOnceDuplicateContact();
      checkRecursive.runOnceDuplicateAccount();
    }
    public static testmethod void testProcessOrderTrigger(){
        
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
        ord.Chargent_Order__c = cn.Id;
        ord.Status='Order in JDE';
        insert ord;
        ord.Status='Order Confirmed';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'ayesha@awana.org';
        
        ord.Pricebook2Id = pricebookIds;
        update ord;
        
        Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test');
        insert prod;

        PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
        Insert standardPE;
        
        OrderItem oItem = new OrderItem();
        oItem.OrderId = ord.id;
        oItem.PricebookEntryId = standardPE.id;
        //oItem.Product2id  = prod.id;
        oItem.Quantity  = 2;
        oItem.UnitPrice  = 1000.89;
        oItem.Line_Type__c = 'F - Freight';
        Insert oItem;
        contact cnt = TestObjects.NewGenericContact();
        cnt.AccountId = acc.id;
        insert cnt;
        Order_Contact_Role__c ocd = new Order_Contact_Role__c();
        ocd.Order__c = ord.Id;
        ocd.Contact__c = cnt.id;
        insert ocd;
    }
    public static testmethod void testProcessOrderTriggermethod2(){
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Minds';
        acc.Mailing_Address_Book__c = '000123';
        acc.Registration_Number__c='US1234';
        insert acc;
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        ord.Chargent_Order__c = cn.Id;
        ord.Status='Order Being Fulfilled';
        insert ord;
        ord.Status='Order Invoiced';
        ord.Opportunity_Source__c = 'Advocacy';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'ayesha@awana.org';
        update ord;
        contact cnt = TestObjects.NewGenericContact();
        cnt.AccountId = acc.id;
        insert cnt;
        Order_Contact_Role__c ocd = new Order_Contact_Role__c();
        ocd.Order__c = ord.Id;
        ocd.Contact__c = cnt.id;
        insert ocd;
    }
    public static testmethod void testProcessOrderTriggermethod3(){
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Minds';
        acc.Mailing_Address_Book__c = '000123';
        acc.Registration_Number__c='US1234';  
        insert acc;
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        ord.Chargent_Order__c = cn.Id;
        ord.Status='Order Submitted';
        insert ord;
        ord.Status='Order Confirmed';
        ord.Registration_Product__c = 'hey';
        ord.Opportunity_Source__c = 'Advocacy';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'ayesha@awana.org';
        update ord;
        contact cnt = TestObjects.NewGenericContact();
        cnt.AccountId = acc.id;
        insert cnt;
        Order_Contact_Role__c ocd = new Order_Contact_Role__c();
        ocd.Order__c = ord.Id;
        ocd.Contact__c = cnt.id;
        insert ocd;
    }
    public static testmethod void testProcessOrderTriggermethod4(){
        
        Account acc = TestObjects.NewCustomAccount();
        acc.name = 'Minds';
        acc.Mailing_Address_Book__c = '000123';
        acc.Registration_Number__c='US1234';  
        insert acc;
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        Order ord = TestObjects.NewOrder();
        ord.AccountId = acc.Id;
        ord.Chargent_Order__c = cn.Id;
        ord.Status='Order Submitted';
        insert ord;
        ord.Status='Order Confirmed';
        ord.Registration_Product__c = 'hey';
        ord.Opportunity_Source__c = 'Advocacy';
        ord.Company__c ='Awana';
        ord.ExtraEmail__c = 'ayesha@awana.org';
        ord.Description = 'Race Date is';
        ord.Order_Submitted__c = system.now();
        update ord;
        contact cnt = TestObjects.NewGenericContact();
        cnt.AccountId = acc.id;
        insert cnt;
        Order_Contact_Role__c ocd = new Order_Contact_Role__c();
        ocd.Order__c = ord.Id;
        ocd.Contact__c = cnt.id;
        IDHelper idhelp = new IDHelper('123456');
        insert ocd;
    }
    /*
    Author- Darshan Chhajed.
    Note - Making See ALl Data true as we need to fetch email template and we can not insert in test class(Mixed DML)
    */
     /*
     @isTest(SeeAllData=true)
     public static void SendExtraEmailTest(){
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        insert a;
        Id priceBookId = Test.getStandardPricebookId();
        O.AccountId  = a.Id;
        O.Pricebook2Id = pricebookId;
        O.ExtraEmail__c = 'someone@someone.com,test@test.com';
        system.debug('##ORDER'+O);
        insert o;
        Contact c = TestObjects.FullContact();
        insert c;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = O.Id);
        OrderEntryServices.AddProduct(O.Id,'99001',10,10,0,'','S - Stock Inventory Item');
        O.Status = 'Order Submitted';
        system.debug('#Total Amount'+o.TotalAmount);
        O.Status = 'Order Confirmed';
        update o;
     }
     */
     public static testmethod void testUpdateOrderTrigger(){
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        insert a;
        Id priceBookId = Test.getStandardPricebookId();
        O.AccountId  = a.Id;
        O.Pricebook2Id = pricebookId;
        insert o;
        Contact c = TestObjects.FullContact();
        insert c;
        OrderEntryServices.AddProduct(O.Id,'70001',1,99.00,0,'','');
        list<OrderItem> oItemLst = [SELECT Id FROM OrderItem WHERE OrderId=:o.Id];
        OrderEntryServices.removeProduct(oItemLst[0].Id);
        OrderEntryServices.AddProduct(O.Id,'70002',1,200.00,0,'','');
         O.Status = 'Order Submitted';
         upsert O;
         O.Status = 'Order Confirmed';
         update O;
     }
     public static testmethod void testAdvocacy(){
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        a.Mailing_Address_Book__c = '43';
        a.BillingStreet  = '5921 Walnut Hill Ln';
        a.BillingState = 'TX';
        a.BillingPostalCode = '75230';
        a.BillingCountry = 'UNITED STATES';
        a.BillingCity = 'Waco';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='US1234';
        insert a;
        list<PricebookEntry> PBE = [SELECT Id,Pricebook2Id FROM PriceBookEntry WHERE Product2.Name='Freight' AND PriceBook2.Name='Catalog Price Book']; 
        O.AccountId  = a.Id;
        O.Pricebook2Id = PBE[0].Pricebook2Id;
        O.Status = 'Order Being Fulfilled';
        insert o;
        Contact c = TestObjects.FullContact();
        insert c;
        npe5__Affiliation__c Aff =  new npe5__Affiliation__c();
         Aff.Authorized_Purchaser__c = true;
         Aff.npe5__Contact__c = C.Id;
         Aff.npe5__Organization__c = A.Id;
         insert Aff;
        OrderItem OI = new OrderItem();
        OrderItem LineItem = new OrderItem(
                        Quantity            = 1, 
                        PricebookEntryId    = PBE[0].Id, 
                        OrderId       = O.Id, 
                        Line_Type__c        = 'F - Freight',
                        UnitPrice = 100
                    );
        insert LineItem;
        O.Opportunity_Source__c = 'Advocacy';
        O.Order_Submitted__c = System.now();
        O.Status = 'Order Invoiced';
        update o; 
        
     }
    
     public static testMethod void Test_DownloadableEmails(){
         //1. create a account
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        insert a;
      list<PricebookEntry> PBE = [SELECT Id,Pricebook2Id FROM PriceBookEntry WHERE Product2.ProductCode='75807' AND PriceBook2.Name='Catalog Price Book' limit 1];
        O.AccountId  = a.Id;
        O.Payment_Terms__c='Credit Card';
        O.AccountId  = a.Id;
        O.Pricebook2Id = PBE[0].Pricebook2Id;
        insert o;
        Contact c = TestObjects.FullContact();
        insert c;
      
        npe5__Affiliation__c Aff =  new npe5__Affiliation__c();
         Aff.Authorized_Purchaser__c = true;
         Aff.npe5__Contact__c = C.Id;
         Aff.npe5__Organization__c = A.Id;
         insert Aff;
        OrderItem OI = new OrderItem();
        OrderItem LineItem = new OrderItem(
                        Quantity            = 1, 
                        PricebookEntryId    = PBE[0].Id, 
                        OrderId       = O.Id, 
                  Downloadable_Product_URL__c = 'www.awana.org',
                        UnitPrice = 1.00
                    );
        insert LineItem;
        Order_Contact_Role__c ocd = new Order_Contact_Role__c();
        ocd.Order__c = o.Id;
        ocd.Contact__c = c.id;
        insert ocd; 
        O.Opportunity_Source__c = 'Customer Service';
        O.Order_Submitted__c = System.now();
        O.Company__c = 'Awana';
        O.Status = 'Order Submitted';
        O.ExtraEmail__c = 'test@test.com,test1@test.com,';  
        O.Payment_Terms__c = 'Net 30'; 
        update o;  

        O.Status = 'Order Confirmed';
         update o;
         system.debug('<< ORDER STATUS >> '+o);
         Test.startTest();
           system.assertEquals('www.awana.org', LineItem.Downloadable_Product_URL__c);
         Test.stopTest();
      }
     public static testMethod void testDonationUpdateMethod1(){
        //Insert Opportunity
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        acc1.name = 'Mary';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria'); 
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 300,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            isPosted__c = true,
            Gift_SubType__c = 'wooCommerce',
            StageName       = 'Pre Post'));
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            npsp__Primary_Contact__c = cn.id,
            Amount          = 350,
            CloseDate       = Date.today(),
            recordtypeid = donationRecordTypeId,
            Gift_SubType__c = 'wooCommerce',
            StageName       = 'Pre Post'));
        insert o;
        System.Assert(o.size()!=0, 'Opportunities are not inserted');
        List<ChargentOrders__ChargentOrder__c> coList = new List<ChargentOrders__ChargentOrder__c>();
        coList.add(new ChargentOrders__ChargentOrder__c(
            ChargentOrders__Payment_Method__c = 'Credit Card'));
        coList.add(new ChargentOrders__ChargentOrder__c(
            ChargentOrders__Payment_Method__c = 'Check'));
        insert coList;
        System.Assert(coList.size()!= 0, 'Chargent Order are not inserted');
        list<order> ordList = new List<order>();
        ordList.add(new order(
            Accountid = acc.id,
            EffectiveDate = system.today(),
            Status = 'Order Entered',
            OpportunityId = o[1].id,
            Chargent_Order__c = coList[1].id));
        ordList.add(new order(
            Accountid = acc.id,
            EffectiveDate = system.today(),
            Status = 'Order Entered',
            OpportunityId = o[0].id,
            Chargent_Order__c = coList[0].id));
        
        insert ordList;
        ordList[0].status = 'Order Invoiced';
        update ordList[0];
        System.Assert(ordList.size()!=0, 'Orders are not inserted');
        
    }    
}