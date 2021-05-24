/*
Purpose - Class ProcessDownloadURLsForStore_Test  - <ASP-1177>
Description: Tests the class ProcessDownloadURLsForStore
Class Tested : ProcessDownloadURLsForStore 
Author - Tony Williams.
*/
//@isTest(SeeAllData=true)
@isTest
public class ProcessDownloadURLsForStore_Test {
	public static testMethod void Test_DownloadableEmails(){
         //1. create a account
        List<Product2> productList =new List<Product2>();
         productList.add( new Product2(
            IsActive=true,Name='Someones Free Guide Download',ProductCode='99999',List_Price__c=0.0,
            Quantity__c=10,Quantity_Reserved__c=0,Line_Type__c='ND - Non-Stock Downloadable', Downloadable_Product_URL__c ='https://s3.amazonaws.com/store-download-content/legacy/revelation-parents-guide.pdf',Weight__c = 0.0) );
        productList.add( new Product2(
            IsActive=true,Name='Another Free Guide Download',ProductCode='99998',List_Price__c=0.0,
            Quantity__c=10,Quantity_Reserved__c=0,Line_Type__c='ND - Non-Stock Downloadable',Downloadable_Product_URL__c='https://s3.amazonaws.com/old-awana-content/pdfs/77497-TakingGodsWordForIt.pdf', Weight__c = 0.0) );
        insert productList;
    	system.debug('<<PROD LIST  >> '+productList);
       //Now create Order Items
        Account testAccount = TestObjects.NewCustomAccount();
        insert testAccount;
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = productList[0].Id,
        UnitPrice = 0.00, IsActive = true);
        insert standardPrice;
        Order newOrder = TestObjects.NewOrder();
        newOrder.Has_Downloads__c = true;
        newOrder.Opportunity_Source__c = 'Awana Store';
        newOrder.AccountId = testAccount.id;
        newOrder.Pricebook2Id = pricebookId;
        newOrder.Status = 'Order Submitted';
        newOrder.Chargent_Order__c = cn.Id;
        insert newOrder;
        
        OrderItem ordItem = new OrderItem();
        
        ordItem.Product2Id = productList[0].id;
        ordItem.OrderId = newOrder.Id;
        ordItem.UnitPrice = 0.00;
        ordItem.Quantity = 2.00;
        ordItem.PricebookEntryId = standardPrice.id;
        system.debug('<< O ITEMS >> '+ordItem);
        
        insert ordItem;
        
         OrderItem ordItem2 = new OrderItem();
        
        ordItem2.Product2Id = productList[1].id;
        ordItem2.OrderId = newOrder.Id;
        ordItem2.UnitPrice = 0.00;
        ordItem2.Quantity = 2.00;
        ordItem2.PricebookEntryId = standardPrice.id;
        system.debug('<< O ITEMS >> '+ordItem2);
        
        insert ordItem2;
        newOrder.Status = 'Order Confirmed';
        update newOrder;
        
        Test.startTest();
        List<ID> getOrderIDs = new List<ID>();
        getOrderIDs.add(newOrder.Id);
        ProcessDownloadURLsforStore.updateOrderItems(getOrderIDs);
        Test.stopTest();
	}
}