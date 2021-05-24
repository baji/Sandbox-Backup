/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Test class for UpdateAccountSoftCredit
***************************************************************************************************************************************************************************************************************************************** **************/

@IsTest
public class TestGenerateReceiptsController{
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
        List<Opportunity> o = new List<Opportunity>();
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId(); 
        for(integer i = 0;i<=10;i++){
            o.add(new Opportunity(
                Name            = 'Test Oppty'+i,
                AccountId       = acc.Id,
                Amount       = 300,
                recordtypeid = donationRecordTypeId,
                CloseDate       = Date.today(),
                StageName       = 'Posted'));
        }
        o.add(new Opportunity(
            Name            = 'Test Oppty1',
            AccountId       = acc1.Id,
            Amount       = 500,
            recordtypeid = donationRecordTypeId,
            CloseDate       = Date.today(),
            StageName       = 'Posted'));
        insert o;
        Gift_Adjustments__c gf = new Gift_Adjustments__c();
        gf.Opportunity__c = o[0].id;
        insert gf;
    }
    public static testMethod void GenerateReceiptsMethod1(){
        list<opportunity> opList = [select id,name from opportunity limit 100];
        Receipt_Number_Series__c  setting = new Receipt_Number_Series__c();
        setting.Name = 'ReceiptStartNumber';
        setting.Receipt_No__c = 1500000;
        insert setting;
        Test.startTest();
        ApexPages.StandardController  sc = new ApexPages.StandardController(opList[0]);
        GenerateReceiptsController gr = new GenerateReceiptsController(sc);
        gr.executeBatch();
        gr.checkBatchStatus();
        gr.cancelBatch();
        Test.stopTest();
        
    }
    public static testMethod void GenerateReceiptsMethodBatch(){
        Account acc = testObjects.NewGenericAccount();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        acc.name = 'Ayesha';
        acc.recordtypeid = RecordTypeIdAccount;
        insert acc;
        List<Opportunity> oList = new List<Opportunity>();
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId(); 
        for(integer i = 0;i<=50;i++){
            oList.add(new Opportunity(
                Name            = 'Test Oppty'+i,
                AccountId       = acc.Id,
                Amount       = 300,
                recordtypeid = donationRecordTypeId,
                CloseDate       = Date.today(),
                StageName       = 'Posted'));
        }
        insert oList;
        Receipt_Number_Series__c  setting = new Receipt_Number_Series__c();
        setting.Name = 'ReceiptStartNumber';
        setting.Receipt_No__c = 1500000;
        insert setting;
        Id batchprocessid;
        Test.startTest();
        GenerateReceipts gr1 = new GenerateReceipts();
        batchprocessid = Database.executeBatch(gr1,100);
        system.debug('batchprocessid**'+batchprocessid);
        Receipt__c rt = new Receipt__c();
        rt.Tech_BatchProcess_Id__c = batchprocessid;
        insert rt;
        system.debug('rt**'+rt);
         
        
        ApexPages.StandardController  sc = new ApexPages.StandardController(oList[0]);
        GenerateReceiptsController gr = new GenerateReceiptsController(sc);
        PageReference p=new PageReference('/'+rt.Id);  
        Test.setCurrentPage(p);
        gr.redirectReceipt();
        gr.executeBatch();
        System.abortJob(batchprocessid);
        checkRecursive.batchStatus = 'Processing';
        gr.checkBatchStatus();
        
        gr.cancelBatch();
        Test.stopTest();
    }
    public static testMethod void GenerateReceiptsMethod2(){
        list<opportunity> opList = [select id,name from opportunity];
        Receipt_Number_Series__c  setting = new Receipt_Number_Series__c();
        setting.Name = 'ReceiptStartNumber';
        setting.Receipt_No__c = 1500000;
        insert setting;
        Test.startTest();
        ApexPages.StandardController  sc = new ApexPages.StandardController(opList[0]);
        GenerateReceiptsController gr = new GenerateReceiptsController(sc);
        
        Test.stopTest();
        
    }
    public static testMethod void GenerateReceiptsMethodBatch3(){
        Account acc = testObjects.NewGenericAccount();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        acc.name = 'Ayesha';
        acc.recordtypeid = RecordTypeIdAccount;
        insert acc;
        List<Opportunity> oList = new List<Opportunity>();
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId(); 
        for(integer i = 0;i<=50;i++){
            oList.add(new Opportunity(
                Name            = 'Test Oppty'+i,
                AccountId       = acc.Id,
                Receipt_Generated_Date__c = Date.today(),
                Amount       = 300,
                recordtypeid = donationRecordTypeId,
                CloseDate       = Date.today(),
                StageName       = 'Posted'));
        }
        insert oList;
        Receipt_Number_Series__c  setting = new Receipt_Number_Series__c();
        setting.Name = 'ReceiptStartNumber';
        setting.Receipt_No__c = 1500000;
        insert setting;
        Id batchprocessid;
        Test.startTest();
        GenerateReceipts gr1 = new GenerateReceipts();
        batchprocessid = Database.executeBatch(gr1,100);
        system.debug('batchprocessid**'+batchprocessid);
        Receipt__c rt = new Receipt__c();
        rt.Tech_BatchProcess_Id__c = batchprocessid;
        insert rt;
        system.debug('rt**'+rt);
        ApexPages.StandardController  sc = new ApexPages.StandardController(oList[0]);
        GenerateReceiptsController gr = new GenerateReceiptsController(sc);
        gr.executeBatch();
        System.abortJob(batchprocessid);
        checkRecursive.batchStatus = 'Holding';
        gr.checkBatchStatus();
        checkRecursive.batchStatus = 'Completed';
        gr.checkBatchStatus();
        gr.redirectReceipt();
        gr.cancelBatch();
        Test.stopTest();
    }
    public static testMethod void GenerateReceiptsMethodBatch4(){
        Account acc = testObjects.NewGenericAccount();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        acc.name = 'Ayesha';
        acc.recordtypeid = RecordTypeIdAccount;
        insert acc;
        List<Opportunity> oList = new List<Opportunity>();
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId(); 
        for(integer i = 0;i<=50;i++){
            oList.add(new Opportunity(
                Name            = 'Test Oppty'+i,
                AccountId       = acc.Id,
                Receipt_Generated_Date__c = Date.today(),
                Amount       = 300,
                recordtypeid = donationRecordTypeId,
                CloseDate       = Date.today(),
                StageName       = 'Posted'));
        }
        insert oList;
        Receipt_Number_Series__c  setting = new Receipt_Number_Series__c();
        setting.Name = 'ReceiptStartNumber';
        setting.Receipt_No__c = 1500000;
        insert setting;
        Id batchprocessid;
        Test.startTest();
        GenerateReceipts gr1 = new GenerateReceipts();
        batchprocessid = Database.executeBatch(gr1,100);
        system.debug('batchprocessid**'+batchprocessid);
        Receipt__c rt = new Receipt__c();
        rt.Tech_BatchProcess_Id__c = batchprocessid;
        insert rt;
        system.debug('rt**'+rt);
        ApexPages.StandardController  sc = new ApexPages.StandardController(oList[0]);
        GenerateReceiptsController gr = new GenerateReceiptsController(sc);
        gr.executeBatch();
        System.abortJob(batchprocessid);
        checkRecursive.batchStatus = 'Holding';
        gr.checkBatchStatus();
        checkRecursive.batchStatus = 'Complete';
        gr.checkBatchStatus();
        gr.redirectReceipt();
        gr.cancelBatch();
        Test.stopTest();
    }
}