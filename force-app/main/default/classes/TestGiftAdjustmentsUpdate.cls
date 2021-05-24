/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Test class for UpdateAccountSoftCredit
***************************************************************************************************************************************************************************************************************************************** **************/

@IsTest
public class TestGiftAdjustmentsUpdate{
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
        Amount       	= 300,
        CloseDate       = Date.today(),
        recordtypeid = donationRecordTypeId,
        StageName       = 'Posted'));
        insert o;
        Gift_Adjustments__c gf = new Gift_Adjustments__c();
        gf.Opportunity__c = o[0].id;
        insert gf;
                
    }
    public static testMethod void TestUpdateOpportunityChanges(){
        List <opportunity> opptList = [SELECT ID,name,account.id,closedate,stagename FROM opportunity];
		opportunity opt = new opportunity();
        opt = opptList[0];
		opt.amount = 400;
		update opt;
		Map<id,opportunity> oldMap = new Map<id,opportunity>();
        oldMap.put(opt.id,opt);
        Test.startTest();
        GiftAdjustmentsUpdate.UpdateOpportunityChanges(opptList,oldMap);
        Test.stopTest();
        
    }
	public static testMethod void TestUpdateOpportunityChangesCatch(){
        List <opportunity> opptList = new list<opportunity>();
		Map<id,opportunity> oldMap = new Map<id,opportunity>();
        Test.startTest();
        GiftAdjustmentsUpdate.UpdateOpportunityChanges(opptList,oldMap);
        Test.stopTest();
        
    }
}