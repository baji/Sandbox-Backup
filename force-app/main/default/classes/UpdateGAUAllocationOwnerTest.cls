/*
* Name  : UpdateGAUAllocationOwnerTest
* Usage : This class is test class for ScheduleGAUAllocationBatch,UpdateGAUAllocationOwner class and GAUUSMissionaryChange trigger.
* Developer : Mayur Soni (mayur@infoglen.com)
*/
@isTest
public Class UpdateGAUAllocationOwnerTest{
    @TestSetup
    public static void createData(){
        List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
         Account a1 = new Account(
                RecordTypeId=rec[0].id, 
                Name='Registration Trigger Test 1-IWNISO', // national with null iso
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US',
                Mailing_Address_Book__c = '000223',
                Registration_Number__c  ='US143'
            ); 
        insert a1;  
        List<GL_Debit_Account_Detail__c> listDebitDetail = new List<GL_Debit_Account_Detail__c>();
        listDebitDetail.add(new GL_Debit_Account_Detail__c( Gift_type__c='Cash',Gift_sub_type__c='ACH1',Debit_Account_Number__c='aci.10.10001'));
        listDebitDetail.add(new GL_Debit_Account_Detail__c( Gift_type__c='Cash',Gift_sub_type__c='BofA',Debit_Account_Number__c='aci.10.10002'));
        listDebitDetail.add(new GL_Debit_Account_Detail__c( Gift_type__c='Pledge Pay - Cash',Gift_sub_type__c='ACH15',Debit_Account_Number__c='aci.10.10001'));
        Insert listDebitDetail;
        
        List<npsp__General_Accounting_Unit__c> listGau = new List<npsp__General_Accounting_Unit__c>();
                listGau.add(new npsp__General_Accounting_Unit__c(Name='AE001',Credit_Account_Number__c='aci.AE001.35002'));
                listGau.add(new npsp__General_Accounting_Unit__c(Name='U214',Credit_Account_Number__c='aci.214.35000'));
                listGau.add(new npsp__General_Accounting_Unit__c(Name='General Fund',Credit_Account_Number__c=''));
        Insert listGau;
        
        List<Contact> listCon = new List<Contact>();
            listCon.add(new Contact(LastName='GAU 1',Email='imran@infoglen.com',Phone='8121448600'));
            listCon.add(new Contact(LastName='GAU 2',Email='shaik@infoglen.com',Phone='9398046470'));
        Insert listCon;
        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
         
        List<Opportunity> listOpp = new List<Opportunity>();
            listOpp.add(new Opportunity(Name='Donation1',Amount=500,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH1',isPosted__c=false,recordTypeId=devRecordTypeId,npsp__Primary_Contact__c=listCon[0].id));
            listOpp.add(new Opportunity(Name='Donation2',Amount=700,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='BofA',isPosted__c=false,recordTypeId=devRecordTypeId,Accountid=a1.id));
            listOpp.add(new Opportunity(Name='Donation3',Amount=600,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH',isPosted__c=false,recordTypeId=devRecordTypeId));
            listOpp.add(new Opportunity(Name='Donation4',Amount=400,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH1',isPosted__c=false,recordTypeId=devRecordTypeId));
            listOpp.add(new Opportunity(Name='Donation5',Amount=200,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH1',isPosted__c=false,recordTypeId=devRecordTypeId));
        Insert listOpp;

        List<npsp__Allocation__c> listAllocation = new List<npsp__Allocation__c>();
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[0].Id,npsp__Amount__c=300));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[0].Id,npsp__Amount__c=200));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[1].Id,npsp__Amount__c=400));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[2].Id,npsp__Opportunity__c=listOpp[1].Id,npsp__Amount__c=300));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[1].Id,npsp__Opportunity__c=listOpp[2].Id,npsp__Amount__c=600));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[1].Id,npsp__Opportunity__c=listOpp[3].Id,npsp__Amount__c=400));
        Insert listAllocation; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User u = new User(Alias = 'GAU', Email='gau@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', FirstName='GAU', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Chicago', UserName='gau@testorg.com');
        insert u;
        
        Awana_Settings__c setting = new Awana_Settings__c(Name='ExecuteGAUUSMissionaryChange',value__c='true');
        insert setting;
        
    }
    /* Covers the GAUUSMissionaryChange trigger*/
    @isTest
    public static void testGAUUSMissionaryChnage(){
        //add US Missionary to GAU
        List<User> u = [SELECT Id,name FROM User where UserName='gau@testorg.com'];
        List<npsp__General_Accounting_Unit__c> gauList =[SELECT Id,Name,Missionary__c FROM npsp__General_Accounting_Unit__c
         WHERE Name='AE001'];
         gauList[0].Missionary__c = u[0].id;
        Test.startTest();
        update gauList;
        npsp__General_Accounting_Unit__c gauCheck = [SELECT Id,Name,IsUSMissionaryChanged__c FROM npsp__General_Accounting_Unit__c where Name='AE001' LIMIT 1];
        System.assert(gauCheck.IsUSMissionaryChanged__c==true);
        Test.stopTest();
    }
    /* Covers the UpdateGAUAllocationOwner Batch class*/
    @isTest
    public static void testMissionaryBatch(){
        //add US Missionary to GAU
        List<User> u = [SELECT Id,name FROM User where UserName='gau@testorg.com'];
        List<npsp__General_Accounting_Unit__c> gauList =[SELECT Id,Name,Missionary__c FROM npsp__General_Accounting_Unit__c
         WHERE Name='AE001'];
         gauList[0].Missionary__c = u[0].id;
        Test.startTest();
        update gauList;
        Test.stopTest();
        List<npsp__Allocation__c> alloList =[SELECT Id,name,OwnerId FROM npsp__Allocation__c WHERE npsp__General_Accounting_Unit__c=: gauList[0].id];
        
    }
    /* Covers the ScheduleGAUAllocationBatch Schedule class*/
    /*@isTest
    public static void testMissionaryBatchSchedule(){
        //add US Missionary to GAU
        List<User> u = [SELECT Id,name FROM User where UserName='gau@testorg.com'];
        List<npsp__General_Accounting_Unit__c> gauList =[SELECT Id,Name,Missionary__c FROM npsp__General_Accounting_Unit__c
         WHERE Name='AE001'];
         gauList[0].Missionary__c = u[0].id;
        update gauList;
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();

            String jobId = System.schedule('ScheduleGAUAllocationBatch',  CRON_EXP, new ScheduleGAUAllocationBatch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        //List<npsp__Allocation__c> alloList =[SELECT Id,name,OwnerId FROM npsp__Allocation__c WHERE npsp__General_Accounting_Unit__c=: gauList[0].id];
        //System.assert(alloList[0].ownerid==u[0].id);
         
    }*/
}