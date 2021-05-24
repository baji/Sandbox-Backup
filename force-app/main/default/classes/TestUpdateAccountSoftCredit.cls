/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Test class for UpdateAccountSoftCredit
***************************************************************************************************************************************************************************************************************************************** **************/

@IsTest
public class TestUpdateAccountSoftCredit{
     @testSetup 
    static void createOpportunity() {
        // Create common test accounts and opportunities
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
        Amount       = 300,
        CloseDate       = Date.today(),
        recordtypeid = donationRecordTypeId,
        StageName       = 'Posted',
        Soft_Credit_Organization__c = acc.id,
        Soft_Credit_Amount__c = 0)); 
        insert o;
                
    }
    public static testMethod void accountUpdate(){
         List <opportunity> opptList = [SELECT ID,name,account.id,amount,closedate,stagename,Soft_Credit_Organization__c,Soft_Credit_Organization__r.Physical_Zip__c,Soft_Credit_Amount__c FROM opportunity];
        Test.startTest();
        UpdateAccountSoftCredit.accountUpdate(opptList);
        Test.stopTest();
        
    }
    public static testMethod void accountUpdateMethod2(){
        Awana_Settings__c setting = new Awana_Settings__c();
        setting.Name = 'EnableDeDupCheck';
        setting.Value__c = 'true';
        insert setting;
        Contact cn = new contact(firstname = 'Ms',lastname = 'sai');
        insert cn;
        Id RecordTypeIdOrg = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        Account acc = testObjects.NewGenericAccount();
        acc.RecordTypeId = RecordTypeIdOrg;
        acc.name = 'Ayesha1';
        acc.ShippingCountry = 'UNITED STATES';
        acc.npe01__One2OneContact__c = cn.id;
        insert acc;
        List <opportunity> opptList = [SELECT ID,name,amount,account.id,closedate,stagename,Soft_Credit_Organization__c,Soft_Credit_Amount__c FROM opportunity];
        Test.startTest();
        UpdateAccountSoftCredit.accountUpdate(opptList);
        Test.stopTest();
        
    }
}