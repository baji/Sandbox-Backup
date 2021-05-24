@IsTest
public class TestUpdateOpportunityLevels{
    
    public static testMethod void UpdateOpportunityLevels(){
    
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunOpportunityTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        // Create common test accounts and opportunities
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteDRMAccountTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        GiftIdSeries__c gfSeries = new GiftIdSeries__c();
        gfSeries.Name = 'GiftIdStartNumber';
        gfSeries.GiftIdSeriesNo__c = 100041;
        Insert gfSeries;
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        acc1.name = 'Mary';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        Awana_Settings__c  setting = new Awana_Settings__c();
        setting.Name = 'ExecuteOpportunityTrigger';
        setting.Value__c = 'true';
        insert setting;
        ConstitIdSeries__c  csetting = new ConstitIdSeries__c();
        csetting.Name = 'ConstitIdStartNumber';
        csetting.ConstitSeriesNo__c = 1500000;
        insert csetting;
        //create test opportunity  
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria'); 
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id matchingGiftRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Matching Gift').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 300,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            isPosted__c = true,
            StageName       = 'Posted'));
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 350,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            Soft_Credit_Organization__c = acc.id,
            Soft_Credit_Amount__c = 100,    
            StageName       = 'Posted'));
        insert o;
        System.Assert(o.size()!=0, 'Opportunities are not inserted');
        o[1].amount = 560;
        o[1].Soft_Credit_Organization__c = acc1.id;
        update o[1];
        o[0].amount = 10; 
        o[0].isPosted__c = true;
        o[0].recordtypeid =matchingGiftRecordTypeId;
        system.debug('o[0]'+o[0]);
        update o[0];
    }
    public static testMethod void UpdateOpportunityLevels1(){
    
        
        // Create common test accounts and opportunities
        
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunOpportunityTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteDRMAccountTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        GiftIdSeries__c gfSeries = new GiftIdSeries__c();
        gfSeries.Name = 'GiftIdStartNumber';
        gfSeries.GiftIdSeriesNo__c = 100041;
        Insert gfSeries;
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        acc1.name = 'Mary';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        Awana_Settings__c  setting = new Awana_Settings__c();
        setting.Name = 'ExecuteOpportunityTrigger';
        setting.Value__c = 'true';
        insert setting;
        ConstitIdSeries__c  csetting = new ConstitIdSeries__c();
        csetting.Name = 'ConstitIdStartNumber';
        csetting.ConstitSeriesNo__c = 1500000;
        insert csetting;
        //create test opportunity  
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria'); 
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id matchingGiftRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Matching Gift').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 300,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            isPosted__c = true,
            StageName       = 'Posted'));
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 350,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            Soft_Credit_Organization__c = acc.id,
            Soft_Credit_Amount__c = 100,    
            StageName       = 'Posted'));
        insert o;
        System.Assert(o.size()!=0, 'Opportunities are not inserted');
        o[1].amount = 560;
        o[1].Soft_Credit_Organization__c = acc1.id;
        update o[1];
        o[0].amount = 10; 
        o[0].isPosted__c = true;
        o[0].recordtypeid =matchingGiftRecordTypeId;
        system.debug('o[0]'+o[0]);
        update o[0];
        test.startTest();
        OpportunityHandler.giftId(o);
        OpportunityHandler.giftIdSeriesUpdate(o);
        OpportuunityHandler.giftId(o);
        test.stopTest();
    }
    public static testMethod void dataMigration(){
        // Create common test accounts and opportunities
        
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunOpportunityTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteOpptyTriggerForREMigration';
        myCS1.Value__c = 'true';
        insert myCS1;
        Id USOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        acc.RecordTypeId = USOrgRecordTypeId;
        acc.RE_Constit_Rec_Id__c = '765';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        acc1.name = 'Mary';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        //create test opportunity  
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria',RE_Constit_Rec_Id__c = '765'); 
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        Id matchingGiftRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Matching Gift').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 300,
            CloseDate       = Date.today(),
            RE_Consist_Record_Id__c = '765',
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            isPosted__c = true,
            StageName       = 'Posted'));
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 350,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            Soft_Credit_Organization__c = acc.id,
            Soft_Credit_Amount__c = 100,    
            StageName       = 'Posted'));
        insert o;
        System.Assert(o.size()!=0, 'Opportunities are not inserted');
        
    }
    
}