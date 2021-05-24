/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Test class for UpdateAccountSoftCredit
***************************************************************************************************************************************************************************************************************************************** **************/

@IsTest
public class TestGenerateReceipts {
@testSetup 
    static void createOpportunity() {
        // Create common test accounts and opportunities
         Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteDRMAccountTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        Account acc = testObjects.NewGenericAccount();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        acc.name = 'Ayesha';
        acc.recordtypeid = RecordTypeIdAccount;
        insert acc;
        Account acc1 = testObjects.NewGenericAccount();
        Id RecordTypeIdAccountHH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        acc1.name = 'Ayesha1';
        acc1.recordtypeid = RecordTypeIdAccountHH;
        insert acc1;
        //create test opportunity  
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId(); 
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
        Name            = 'Test Oppty',
        AccountId       = acc.Id,
        Amount       = 300,
        recordtypeid = donationRecordTypeId,
        CloseDate       = Date.today(),
        StageName       = 'Posted'));
        o.add(new Opportunity(
        Name            = 'Test Oppty1',
        AccountId       = acc1.Id,
        Amount       = 300,
        CloseDate       = Date.today(),
        StageName       = 'Posted'));
        insert o;
        Gift_Adjustments__c gf = new Gift_Adjustments__c();
        gf.Opportunity__c = o[0].id;
        insert gf;
    }
    public static testMethod void GenerateReceiptsMethod1(){
        Receipt_Number_Series__c  setting = new Receipt_Number_Series__c();
        setting.Name = 'ReceiptStartNumber';
        setting.Receipt_No__c = 1500000;
        insert setting;
        Test.startTest();
        GenerateReceipts gr = new GenerateReceipts();
        Database.executeBatch(gr,200);
        Test.stopTest();
        
    }
}