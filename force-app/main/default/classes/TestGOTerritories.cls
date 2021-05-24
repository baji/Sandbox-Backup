/***************************************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Salesforce
    Description:General Test Class for Affiliations
    Original:   09/11/2015  - Created to Test Affiliations for Advocacy
    Updated:    26/12/2017 - Mayur Soni - Removed use of SeeAllData=true
  ***************************************************************************************************************************************************************/

@isTest
public class TestGOTerritories {
    public static testMethod void UpdateTerritoryonAccount()
    {
        //Get the full Account
        Account thisAccount = TestObjects.FullAccount();
        thisAccount.Physical_Street_1__c = '5921 Walnut Hill Ln';
        thisAccount.Physical_State__c = 'TX';
        thisAccount.Physical_Zip__c = '75230';
        thisAccount.PhysicalCountry__c = 'UNITED STATES';
        thisAccount.Physical_City__c = 'Waco';
        thisAccount.Status__c='Added';
        upsert thisAccount;
        
        User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
         LastName = 'test',
         Email = 'test@test.com',
         Username = 'test@test.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         GO_Club_Outreach_Specialist__c = true
        );
        insert u;
        GO_Club_Territories__c goClub = new GO_Club_Territories__c(
            GO_Territory__c = 'Central Territory',
            Name = 'TX',
            GO_Club_Outreach_Specialist__c = u.id
        );
        insert goClub;
        List<GO_Club_Territories__c> a_Territory = [Select g.GO_Territory__c,g.GO_Club_Outreach_Specialist__c From GO_Club_Territories__c g where GO_Territory__c = 'Central Territory' and  Name = 'TX' ];
        system.debug('<<GO_Club_Territories__c>> '+a_Territory);
        a_Territory[0].GO_Territory__c = 'Eastern Territory';
        
        Test.startTest();
        upsert a_Territory[0];
        Test.StopTest();
        Account acc = [Select Id,GO_Territory__c FROM Account WHERE Id=:thisAccount.Id LIMIT 1];
       // System.assert(acc.GO_Territory__c =='Eastern Territory');
    }   

}