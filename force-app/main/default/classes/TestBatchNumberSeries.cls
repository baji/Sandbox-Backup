/******************************************************************************************************************
Programmer:         Ayesha
Contact:            ayesha@infoglen.com
Project:            DRM 
Original:           5/29/2018  - To test BatchNumberSeries Trigger
****************************************************************************************************************************/

@isTest
public  class TestBatchNumberSeries {
    public static testMethod void testBatchNumberSeriesMethod1(){
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteBatchTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 8;
        insert bCS1;
        //Insert Apsona Batch
        apsona_be__Batch__c  newApsona = new apsona_be__Batch__c ();
        newApsona.Name = 'testClassBatch';
        insert newApsona;
        System.Assert(newApsona.Id != null, 'Batch is not inserted');
    }
   public static testMethod void testBatchNumberSeriesMethod2(){
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteBatchTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
       GiftIdSeries__c gfSeries = new GiftIdSeries__c();
        gfSeries.Name = 'GiftIdStartNumber';
        gfSeries.GiftIdSeriesNo__c = 100041;
        Insert gfSeries;
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 18;
        insert bCS1;
        Awana_Settings__c  setting = new Awana_Settings__c();
        setting.Name = 'ExecuteOpportunityTrigger';
        setting.Value__c = 'true';
        insert setting;
        ConstitIdSeries__c  csetting = new ConstitIdSeries__c();
        csetting.Name = 'ConstitIdStartNumber';
        csetting.ConstitSeriesNo__c = 1500000;
        insert csetting;
        //Insert Opportunity
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        acc1.name = 'Mary';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria'); 
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 300,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            isPosted__c = true,
            
            Gift_SubType__c = 'wooCommerce',
            StageName       = 'Posted'));
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            npsp__Primary_Contact__c = cn.id,
            Amount          = 350,
            
            CloseDate       = Date.today(),
            recordtypeid = donationRecordTypeId,
            Gift_SubType__c = 'wooCommerce',
            StageName       = 'Posted'));
        insert o;
        System.Assert(o.size()!=0, 'Opportunities are not inserted');
    }
    /*public static testMethod void testBatchNumberSeriesMethod3(){
        Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteBatchTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        GiftIdSeries__c gfSeries = new GiftIdSeries__c();
        gfSeries.Name = 'GiftIdStartNumber';
        gfSeries.GiftIdSeriesNo__c = 100041;
        Insert gfSeries;
        Batch_Number_Series__c  bCS1 = new Batch_Number_Series__c();
        bCS1.Name = 'Batch Record 1';
        bCS1.Current_Year__c = '2017';
        bCS1.Serial_Number__c = 28;
        insert bCS1;
        Awana_Settings__c  setting = new Awana_Settings__c();
        setting.Name = 'ExecuteOpportunityTrigger';
        setting.Value__c = 'true';
        insert setting;
        ConstitIdSeries__c  csetting = new ConstitIdSeries__c();
        csetting.Name = 'ConstitIdStartNumber';
        csetting.ConstitSeriesNo__c = 1500000;
        insert csetting;
        //Insert Apsona Batch
        apsona_be__Batch__c  newApsona = new apsona_be__Batch__c ();
        newApsona.Name = 'testClassBatch';
        newApsona.IsWooCommerceBatch__c = true;
        insert newApsona;
        //Insert Opportunity
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        System.Assert(acc.Id != null, 'Account is not inserted');
        Account acc1 = testObjects.NewGenericAccount();
        acc1.name = 'Mary';
        insert acc1;
        System.Assert(acc1.Id != null, 'Account is not inserted');
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria'); 
        insert cn;
        System.Assert(cn.Id != null, 'Contact is not inserted');
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            Amount          = 300,
            CloseDate       = Date.today(),
            npsp__Primary_Contact__c = cn.id,
            recordtypeid = donationRecordTypeId,
            isPosted__c = true,
            
            Gift_SubType__c = 'wooCommerce',
            StageName       = 'Posted'));
        o.add(new Opportunity(
            Name            = 'Test Oppty',
            AccountId       = acc.Id,
            npsp__Primary_Contact__c = cn.id,
            Amount          = 350,
           
            CloseDate       = Date.today(),
            recordtypeid = donationRecordTypeId,
            Gift_SubType__c = 'wooCommerce',
            StageName       = 'Posted'));
        insert o;
        System.Assert(o.size()!=0, 'Opportunities are not inserted');
    }*/
}