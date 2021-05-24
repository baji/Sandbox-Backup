@isTest(seeAllData = true)
public class BatchGeneratePickTicket_Test {
    
    static testMethod void testTickets1() {
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
        //Order o3 = new Order(name='O-'+aff.npe5__Organization__r.Mailing_Address_Book__c+'-1',Status='Order Confirmed', effectiveDate=Date.Today(), AccountId=aff.npe5__Organization__c, Pricebook2Id = priceBookId); 
        //insert o3;
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
        //testOrd[i].Notes__c ='Tes Order for faux client';
        testOrd[i].Pricebook2Id = pricebookIds;
        testOrd[i].AccountId = accts[i].Id;
        Order o1 = testOrd[i];
        o1.Chargent_Order__c = cn.Id;
        o1.Status='Order Confirmed';
        insert o1;
        
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
        oItem.Line_Type__c = 's - stock';
        Insert oItem;
        
        Pick_Ticket__c pick = new Pick_Ticket__c();
        pick.Order__c = o1.id;
        insert pick; 

        Test.startTest();
        String query = ' Select Id, AccountId, Account.Name, Name, ' + 
                ' Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, ' +
                ' LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, ' +
                ' Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c, ' +
                ' (Select Id, Name From Pick_Tickets__r) ' + 
                ' FROM Order Where CreatedDate > 2010-07-01T00:00:00.000Z ' +
                ' And TotalAmount > 0 ' + 
                ' And (Status = \'Order Confirmed\' OR Status like \'%Partially%\') ' + 
                ' And (NOT Status like \'%Cancelled%\') LIMIT 2';
        BatchGeneratePickTickets batch = new BatchGeneratePickTickets();        
        batch.Query = query;
        Database.executeBatch(batch);
        Test.stopTest();
    }
}