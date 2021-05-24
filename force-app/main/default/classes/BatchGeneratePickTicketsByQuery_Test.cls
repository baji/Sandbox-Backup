@isTest(SeeAllData=true)
public class BatchGeneratePickTicketsByQuery_Test {
    static testmethod void test() {  
    
       /* Account acc= new Account(Name = 'testAcc',BillingStreet='testStreet',BillingCity ='tectcity',BillingState='testState',BillingPostalCode='123',
                                   BillingCountry='testcountry',Description='testdesc');
        insert acc;

        //Case record in Test method. 
        Contact conObj = new Contact();
        conObj.lastname = 'testcon';
        conObj.AccountId = acc.id;
        insert conObj;
    
        Opportunity opp= new Opportunity(AccountId=acc.id,Amount=1234.00,Description='testdesc',Name='testOpp',
                                         StageName='Prospecting',CloseDate = System.Today());
        insert opp; */

        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test';
        insert a;
        
        Contact c = TestObjects.NewGenericContact();
        c.accountid = a.id;
        insert c;
        
        npe5__Affiliation__c aff = new npe5__Affiliation__c( npe5__Organization__c  = a.Id, npe5__Contact__c = c.Id);        
        insert aff;
      
        Id priceBookId = Test.getStandardPricebookId();
        
        //Order o1 = new Order(name='O-'+aff.npe5__Organization__r.Mailing_Address_Book__c+'-0',Status='Order Confirmed', effectiveDate=Date.Today(), AccountId=aff.npe5__Organization__c, Pricebook2Id = priceBookId); 
        //insert o1;
        User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        List<Account> accts = new List<Account>();
        accts.add(TestObjects.FullAccount());
        insert accts;
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestObjects.FullContact());
        insert contacts;
        List<Order> testOrd = new List<Order>();
        testOrd.add(TestObjects.NewOrder());
        Id pricebookIds = Test.getStandardPricebookId();
        Integer i = 0;
        testOrd[i].Name = 'O-111-';
        testOrd[i].Type = 'Shipping';
        testOrd[i].Company__c = 'Awana';
        testOrd[i].Order_Type__c = 'SO';
        testOrd[i].Shipping_Country__c =  'UNITED STATES';
        testOrd[i].OwnerId = ouser.Id;
        testOrd[i].Payment_Terms__c = 'Net 30';
        testOrd[i].Shipping_Type__c = 'Priority Mail'; 
        testOrd[i].Shipping_Code__c = 'PRI';              
        testOrd[i].Shipping_Carrier__c = 'POST';
        testOrd[i].Notes__c ='Tes Order for faux client';
        testOrd[i].Pricebook2Id = pricebookIds;
        testOrd[i].AccountId = accts[i].Id;
        Order o1 = testOrd[i];
        o1.Chargent_Order__c = cn.Id;
        o1.Status='Order Confirmed';
        insert o1;
        //Order o3 = new Order(name='O-'+aff.npe5__Organization__r.Mailing_Address_Book__c+'-1',Status='Order Confirmed', effectiveDate=Date.Today(), AccountId=aff.npe5__Organization__c, Pricebook2Id = priceBookId); 
        //insert o3;

        Product2 prod = new Product2(Name= 'Test Prod', Description= 'Test');
        insert prod;

        PricebookEntry standardPE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prod.Id, UnitPrice = 2000.00, IsActive = true, UseStandardPrice = false);
        Insert standardPE;
        
        OrderItem oItem = new OrderItem();
        oItem.OrderId = o1.id;
        oItem.PricebookEntryId = standardPE.id;
        //oItem.Product2id  = prod.id;
        oItem.Quantity  = 2;
        oItem.UnitPrice  = 1000.89;
        Insert oItem;
        
        Pick_Ticket__c pick = new Pick_Ticket__c();
        pick.Order__c = o1.id;
        insert pick;       

        String Query =
        ' Select Id, AccountId, Account.Name, RecordTypeId, RecordType.Name, Name, ' + 
          ' StageName, Amount, CreatedDate, CreatedById, CreatedBy.Name, HasOpportunityLineItem, LastModifiedDate, ' +
          ' LastModifiedById, LastModifiedBy.Name, TotalOpportunityQuantity, Total_Pick_Quantity__c, Company__c,Shipping_Weight__c, ' +
          ' Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c ' + 
          ' FROM Opportunity ' ;
        
        Test.startTest();   
        BatchGeneratePickTicketsByQuery pickBatch = new BatchGeneratePickTicketsByQuery();
        //pickBatch.Query= Query;
        ID batchprocessid = Database.executeBatch(pickBatch);
        Test.stopTest();
    }
}