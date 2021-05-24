@isTest
public class UpdateSumOfAllocationAmountTest{
    @Testsetup
    public static void createData(){
        List<GL_Debit_Account_Detail__c> listDebitDetail = new List<GL_Debit_Account_Detail__c>();
        listDebitDetail.add(new GL_Debit_Account_Detail__c( Gift_type__c='Cash',Gift_sub_type__c='ACH1',Debit_Account_Number__c='aci.10.10001'));
        listDebitDetail.add(new GL_Debit_Account_Detail__c( Gift_type__c='Cash',Gift_sub_type__c='BofA',Debit_Account_Number__c='aci.10.10002'));
        listDebitDetail.add(new GL_Debit_Account_Detail__c( Gift_type__c='Pledge Pay - Cash',Gift_sub_type__c='ACH15',Debit_Account_Number__c='aci.10.10001'));
        Insert listDebitDetail;
        
        List<apsona_be__Batch__c> listAppBatch = new List<apsona_be__Batch__c>();
            listAppBatch.add(new apsona_be__Batch__c(Name='FirstBatch',apsona_be__Total_amount__c=500,apsona_be__Total_items__c=3));
            listAppBatch.add(new apsona_be__Batch__c(Name='SecondBatch',apsona_be__Total_amount__c=700,apsona_be__Total_items__c=2));
        Insert listAppBatch;
        List<npsp__General_Accounting_Unit__c> listGau = new List<npsp__General_Accounting_Unit__c>();
            listGau.add(new npsp__General_Accounting_Unit__c(Name='AE001',Credit_Account_Number__c='aci.AE001.35002'));
            listGau.add(new npsp__General_Accounting_Unit__c(Name='U214',Credit_Account_Number__c='aci.214.35000'));
            listGau.add(new npsp__General_Accounting_Unit__c(Name='General Fund',Credit_Account_Number__c=''));
        Insert listGau;
        
        List<Awana_Settings__c> listAwanSettings = new List<Awana_Settings__c>();
            listAwanSettings.add(new Awana_Settings__c(Value__c='true',Name='EnableDeDupCheck'));
            listAwanSettings.add(new Awana_Settings__c(Value__c='true',Name='ExecuteOpportunityTrigger'));
        Insert listAwanSettings;

        ConstitIdSeries__c conSeries = new ConstitIdSeries__c();
            conSeries.Name = 'ConstitIdStartNumber';
            conSeries.ConstitSeriesNo__c = 100040;
        Insert conSeries;

        
        List<Contact> listCon = new List<Contact>();
            listCon.add(new Contact(LastName='Imran',Email='imran@infoglen.com',Phone='8121448600'));
            listCon.add(new Contact(LastName='Shaik',Email='shaik@infoglen.com',Phone='9398046470'));
        Insert listCon;
        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
         
        List<Opportunity> listOpp = new List<Opportunity>();
            listOpp.add(new Opportunity(Name='Donation1',Amount=500,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH1',Apsona_Batch__c=listAppBatch[0].Id,isPosted__c=false,recordTypeId=devRecordTypeId));
            listOpp.add(new Opportunity(Name='Donation2',Amount=700,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='BofA',Apsona_Batch__c=listAppBatch[1].Id,isPosted__c=false,recordTypeId=devRecordTypeId));
            listOpp.add(new Opportunity(Name='Donation3',Amount=600,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH',Apsona_Batch__c=listAppBatch[1].Id,isPosted__c=false,recordTypeId=devRecordTypeId));
            listOpp.add(new Opportunity(Name='Donation4',Amount=400,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH1',Apsona_Batch__c=listAppBatch[1].Id,isPosted__c=false,recordTypeId=devRecordTypeId));
            listOpp.add(new Opportunity(Name='Donation5',Amount=200,StageName='Posted',CloseDate=system.today(),Gift_Type__c='Cash',Gift_SubType__c='ACH1',Apsona_Batch__c=listAppBatch[0].Id,isPosted__c=false,recordTypeId=devRecordTypeId));
        Insert listOpp;
        
    }
    
    @isTest
    public static void testAllocationSum(){
        List<opportunity> listOpp = [SELECT Id,name FROM opportunity];
        List<npsp__General_Accounting_Unit__c> listGau = [SELECT Id,name FROM npsp__General_Accounting_Unit__c];
        Test.startTest();
        List<npsp__Allocation__c> listAllocation = new List<npsp__Allocation__c>();
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[0].Id,npsp__Amount__c=300));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[0].Id,npsp__Amount__c=200));
            listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[1].Id,npsp__Opportunity__c=listOpp[1].Id,npsp__Amount__c=400));
            
        Insert listAllocation; 
        List<Opportunity> oppCheck = [SELECT Id,Name,Fund_With_Amount__c FROM Opportunity WHERE Id=:listOpp[0].Id];
        System.assert(oppCheck[0].Fund_With_Amount__c.contains(listGau[0].name));
        
        //update allocation
        List<npsp__Allocation__c> allocationList = [SELECT Id,name,npsp__General_Accounting_Unit__c FROM npsp__Allocation__c WHERE id=:listAllocation[1].id];
        allocationList[0].npsp__General_Accounting_Unit__c  = listGau[1].id;
        update allocationList;
        
        //delete allocation
        DELETE [SELECT ID from npsp__Allocation__c WHERE Id=:listAllocation[0].id];
        oppCheck = [SELECT Id,Name,Fund_With_Amount__c FROM Opportunity WHERE Id=:listOpp[0].Id];
        System.assert(!oppCheck[0].Fund_With_Amount__c.contains(listGau[0].name));
        Test.stopTest();
        
        
    }
}