/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Track down the opportunity which influenced the level change in Account
***************************************************************************************************************************************************************************************************************************************** **************/

@IsTest
public class TestOpportunityUpdateAction{
    @testSetup 
    static void createLevels() {
        List<npsp__Level__c> levelRecords = new List<npsp__Level__c>();
        levelRecords.add(new npsp__Level__c(npsp__Active__c = true,name = 'Mid',npsp__Source_Field__c = 'npo02__OppAmountLastNDays__c',
                                           npsp__Level_Field__c = 'Level__c',npsp__Previous_Level_Field__c = 'Previous_Level__c',
                                           npsp__Target__c = 'Account',npsp__Maximum_Amount__c = 5000,npsp__Minimum_Amount__c = 500));
        levelRecords.add(new npsp__Level__c(npsp__Active__c = true,name = 'Mass',npsp__Source_Field__c = 'npo02__OppAmountLastNDays__c',
                                           npsp__Level_Field__c = 'Level__c',npsp__Previous_Level_Field__c = 'Previous_Level__c',
                                           npsp__Target__c = 'Account',npsp__Maximum_Amount__c = 500,npsp__Minimum_Amount__c = 0));
        levelRecords.add(new npsp__Level__c(npsp__Active__c = true,name = 'Major',npsp__Source_Field__c = 'npo02__OppAmountLastNDays__c',
                                           npsp__Level_Field__c = 'Level__c',npsp__Previous_Level_Field__c = 'Previous_Level__c',
                                           npsp__Target__c = 'Account',npsp__Minimum_Amount__c = 50000));
        insert levelRecords;
    }
    public static testMethod void UpdateOpportunities() {
         List<npsp__Level__c> levelsList = new List<npsp__Level__c>([select id,name,npsp__Active__c,npsp__Maximum_Amount__c,npsp__Minimum_Amount__c,npsp__Target__c from npsp__Level__c where npsp__Target__c = 'Account' and npsp__Active__c=true and (name = 'Major' or name = 'Mid' or name = 'Mass')]);
                    
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteDRMAccountTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        //create test opportunity 
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId(); 
  		List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
        Name            = 'Test Oppty',
        AccountId       = acc.Id,
        Amount   		= 300,
        CloseDate       = Date.today(),
        recordtypeid = donationRecordTypeId,
        StageName       = 'Posted')); 
        insert o;
        Test.startTest();
        OpportunityUpdateAction.UpdateOpportunities(o);
        Test.stopTest();
    }
   public static testMethod void UpdateOpportunities1() {
        List<npsp__Level__c> levelsList = new List<npsp__Level__c>([select id,name,npsp__Active__c,npsp__Maximum_Amount__c,npsp__Minimum_Amount__c,npsp__Target__c from npsp__Level__c where npsp__Target__c = 'Account' and npsp__Active__c=true and (name = 'Major' or name = 'Mid' or name = 'Mass')]);
                    
        Awana_Settings__c myCS1 = Awana_Settings__c.getValues('ExecuteDRMAccountTrigger');
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        //create test opportunity   
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
        Name            = 'Test Oppty',
        AccountId       = acc.Id,
        Amount   		= 500,
        CloseDate       = Date.today(),
        StageName       = 'Posted')); 
        insert o;
        o[0].amount = 600;
        update o;
       Test.startTest();
        OpportunityUpdateAction.UpdateOpportunities(o);
       Test.stopTest();
    }
    public static testMethod void UpdateOpportunities2() {
        List<npsp__Level__c> levelsList = new List<npsp__Level__c>([select id,name,npsp__Active__c,npsp__Maximum_Amount__c,npsp__Minimum_Amount__c,npsp__Target__c from npsp__Level__c where npsp__Target__c = 'Account' and npsp__Active__c=true and (name = 'Major' or name = 'Mid' or name = 'Mass')]);
                    
        Awana_Settings__c myCS1 = Awana_Settings__c.getValues('ExecuteDRMAccountTrigger');
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        //create test opportunity   
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
        Name            = 'Test Oppty',
        AccountId       = acc.Id,
        Amount   		= 5010,
        CloseDate       = Date.today(),
        StageName       = 'Posted')); 
        insert o;
        o[0].amount = 6000;
        update o;
       Test.startTest();
        OpportunityUpdateAction.UpdateOpportunities(o);
       Test.stopTest();
    }
}