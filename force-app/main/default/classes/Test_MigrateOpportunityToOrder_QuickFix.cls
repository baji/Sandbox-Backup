@IsTest
public class Test_MigrateOpportunityToOrder_QuickFix{
     public static testMethod void MigrateOpportunityToOrder_QuickFix_Test(){
         Test.StartTest();
         Opportunity opp = new Opportunity(Safe_to_delete__c = true,Name='O-TEST-0',Payment_Terms__c='Net30',StageName='Order Error',CloseDate=Date.Today());
         opp.Source_Record_Type_Name__c = 'Orders';
         opp.Billing_County__c ='IL';
         opp.Cancel_Log__c ='TestCancel';
         opp.Shipping_Code__c = 'ShippingCode'; 
         opp.Shipping_GeoCode__c = 'GeoCode';
         opp.Ship_to_Name__c = 'Test Name';
         opp.Source_Record_Id__c = '123456';
         insert opp;
         
         Account fullAcc = Test_S2SObjects.S2S_FullAccount();
         Insert fullAcc;
         Order ord = Test_S2SObjects.S2S_FullOrder();
         ord.AccountId = fullAcc.Id;
         ord.Source_Opportunity_Id__c = '123456';
         Insert ord; 
         
         MigrateOpportunityToOrder_QuickFix batchObj = new MigrateOpportunityToOrder_QuickFix();
         Database.executeBatch(batchObj,200);
         Test.StopTest();
     }
}