/*********************************************************************************************************
    Programmer:         Sowmya
    Company:            Awana
    Contact:            sowmya@infoglen.com
    Project:            <SFDC-26> 
    Original:           10/14/2016 - Used to test OpportunityProducts
    Modified by Darshan Chhajed to remove seeAlldata=True
    
 ***********************************************************************************************************/ 
@isTest
public class MigrateOpportunityProducts_Test{

  public static testMethod void batchToValidateOpportunityProducts(){
	Test.startTest();
     Opportunity opp = new Opportunity(Safe_to_delete__c = true,Name='O-TEST-0',Payment_Terms__c='Net30',StageName='Order Error',CloseDate=Date.Today());
 	 opp.Source_Record_Type_Name__c = 'Orders';
     opp.Billing_County__c ='IL';
     opp.Cancel_Log__c ='TestCancel';
     opp.Shipping_Code__c = 'ShippingCode'; 
     opp.Shipping_GeoCode__c = 'GeoCode';
     opp.Ship_to_Name__c = 'Test Name';
     opp.Source_Record_Id__c = '701500000017qiO';
     insert opp;
    
    Product2 NewProduct = new Product2(Name='99999',ProductCode='99999',Quantity__c=1000, Weight__c=0.35); 
    insert NewProduct;
   
    PriceBook2 NewPriceBook = new PriceBook2(Name='Test Price Book', Source_Pricebook_Rec_Id__c='0015000000QufbD'); 
    insert NewPriceBook;
    PriceBookEntry NewStandardPriceBookEntry = new PriceBookEntry(PriceBook2Id=Test.getStandardPricebookId(),Product2Id=NewProduct.Id,UnitPrice=1,UseStandardPrice=FALSE,IsActive=True); 
    insert NewStandardPriceBookEntry;
   
    system.debug('pricebookentry---'+NewStandardPriceBookEntry);
    
    OpportunityLineItem OLI = new OpportunityLineItem(OpportunityId=opp.Id,PriceBookEntryId=NewStandardPriceBookEntry.Id,UnitPrice=1,Quantity=1,Line_Type__c='S - Stock Inventory Item',Estimated_Weight__c=0.9);
    OLI.IsOrderItemCreated__c = false;
    OLI.Source_Pricebook_Entry_Id__c = '0015000000QufbD'; //some random ids
    OLI.Source_Opportunity_Id__c = '701500000017qiO'; 
    insert OLI;
    
	Account fullAcc = Test_S2SObjects.S2S_FullAccount();
	insert fullAcc;
	Order ord = Test_S2SObjects.S2S_FullOrder();
	ord.AccountId = fullAcc.Id;
	ord.Source_Opportunity_Id__c = '701500000017qiO';
	insert ord; 	
    
    MigrateOpportunityProducts batchObj = new MigrateOpportunityProducts();
    Database.executeBatch(batchObj);
   Test.stopTest();
  
  }
}//class