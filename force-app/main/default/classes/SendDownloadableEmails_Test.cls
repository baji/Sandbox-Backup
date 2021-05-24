/*
Purpose - Class SendDownloadableEmails_Test  - <ASP-847>
Description: Tests the class SendDownloadableEmails
Class Tested : SendDownloadableEmails 
Author - Tony Williams.
*/
@isTest(SeeAllData=true)
public class SendDownloadableEmails_Test {
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
                        UnitPrice = 0.49
                    );
        insert LineItem;
        Order_Contact_Role__c ocd = new Order_Contact_Role__c();
        ocd.Order__c = o.Id;
        ocd.Contact__c = c.id;
        insert ocd; 
        O.Opportunity_Source__c = 'Customer Service';
        O.Order_Submitted__c = System.now();
        O.Status = 'Order Submitted';
        update o;        
        O.Status = 'Order Confirmed';
         update o;
         system.debug('<< ORDER STATUS >> '+o);
         Test.startTest();
         	system.assertEquals('www.awana.org', LineItem.Downloadable_Product_URL__c);
         Test.stopTest();
      }
         
}