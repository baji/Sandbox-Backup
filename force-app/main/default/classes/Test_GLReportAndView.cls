/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    04/02/2018 - <CRM - 130> GL Post Report Test Class
***************************************************************************************************************************************************************************************************************************************** **************/

@isTest
public class Test_GLReportAndView{
    @testSetup static void setupData() {
        
        User u = [SELECT Id,Name FROM User where id=:USERINFO.getUserId() LIMIT 1];
        system.runAS(u){
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
            
            GiftIdSeries__c gfSeries = new GiftIdSeries__c();
                gfSeries.Name = 'GiftIdStartNumber';
                gfSeries.GiftIdSeriesNo__c = 100040;
            Insert gfSeries;
            
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

            List<npsp__Allocation__c> listAllocation = new List<npsp__Allocation__c>();
                listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[0].Id,npsp__Amount__c=300));
                listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=listOpp[0].Id,npsp__Amount__c=200));
                listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[1].Id,npsp__Opportunity__c=listOpp[1].Id,npsp__Amount__c=400));
                listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[2].Id,npsp__Opportunity__c=listOpp[1].Id,npsp__Amount__c=300));
                listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[1].Id,npsp__Opportunity__c=listOpp[2].Id,npsp__Amount__c=600));
                listAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[1].Id,npsp__Opportunity__c=listOpp[3].Id,npsp__Amount__c=400));
            Insert listAllocation; 
        }
    }
    /*
    static testMethod void extractReport(){ 
        User u = [SELECT Id,Name FROM User where id=:USERINFO.getUserId() LIMIT 1];
        system.runAS(u){
            PageReference pageRef = Page.npsp_GLPostReportPage;
            pageref.getparameters().put('fromDate',String.valueOf(system.today()));

            Test.setCurrentPage(pageRef);
            
            GL_Post_Report__c glReport = new GL_Post_Report__c();
                glReport.name = string.valueOf(system.today());
            Apexpages.StandardController stdController = new Apexpages.StandardController(glReport);
            
            GLPostReport gl = new GLPostReport(stdController);
                gl.PostMethod();  
            
            Opportunity opp = [SELECT Id,Name,Amount FROM Opportunity WHERE Name='Donation1'];
                opp.Amount = 600;
            Update opp;

            Opportunity opp1 = [SELECT Id,Name,Amount FROM Opportunity WHERE Name='Donation4'];
                opp1.Amount = 500;
            Update opp1;

            npsp__Allocation__c nspAll = [SELECT Id,Name,npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c=:opp1.Id AND npsp__Amount__c=400];
                nspAll.npsp__Amount__c = 300;
            Update nspAll;
            List<npsp__General_Accounting_Unit__c> listGau = [SELECT Id FROM npsp__General_Accounting_Unit__c WHERE Credit_Account_Number__c !=null];

            List<npsp__Allocation__c> listGauAllocation = new List<npsp__Allocation__c>();
                listGauAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=opp1.Id,npsp__Amount__c=100));
                listGauAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=opp1.Id,npsp__Amount__c=100));
            Insert listGauAllocation;

            test.startTest();

            GLPostReport gl1 = new GLPostReport(stdController);
                gl1.PostMethod(); 

            test.stopTest();
        }
    }
*/
    static testMethod void extractReportView(){

        User u = [SELECT Id,Name FROM User where id=:USERINFO.getUserId() LIMIT 1];
        system.runAS(u){

            

            test.startTest();

            PageReference pageRef = Page.npsp_GLPostPreviewPage;
            pageref.getparameters().put('fromDate',String.valueOf(system.today()));
            Test.setCurrentPage(pageRef);

            GLPostReportView  gl11 = new GLPostReportView ();
                gl11.getData();


            PageReference pageRef1 = Page.npsp_GLPostReportPage;
            pageref1.getparameters().put('fromDate',String.valueOf(system.today()));

            Test.setCurrentPage(pageRef1);
            
            GL_Post_Report__c glReport = new GL_Post_Report__c();
                glReport.name = string.valueOf(system.today());
            Apexpages.StandardController stdController = new Apexpages.StandardController(glReport);
            
            GLPostReport gl = new GLPostReport(stdController);
                gl.PostMethod();  


            Opportunity opp = [SELECT Id,Name,Amount,Tech_Batch_No__c FROM Opportunity WHERE Name='Donation1'];
                opp.Amount = 600;
            Update opp;

            Opportunity opp1 = [SELECT Id,Name,Amount,Tech_Batch_No__c  FROM Opportunity WHERE Name='Donation4'];
                opp1.Amount = 500;
            Update opp1;

            npsp__Allocation__c nspAll = [SELECT Id,Name,npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c=:opp1.Id AND npsp__Amount__c=400];
                nspAll.npsp__Amount__c = 300;
            Update nspAll;
            List<npsp__General_Accounting_Unit__c> listGau = [SELECT Id FROM npsp__General_Accounting_Unit__c WHERE Credit_Account_Number__c !=null];

            List<npsp__Allocation__c> listGauAllocation = new List<npsp__Allocation__c>();
                listGauAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=opp1.Id,npsp__Amount__c=100));
                listGauAllocation.add(new npsp__Allocation__c(npsp__General_Accounting_Unit__c=listGau[0].Id,npsp__Opportunity__c=opp1.Id,npsp__Amount__c=100));
            Insert listGauAllocation;

            List<Gift_Adjustments__c> listGiftAjust = [SELECT Id,Name FROM Gift_Adjustments__c];
            system.debug('listGiftAjust-------------'+listGiftAjust);
            
            //create Gift adjustment for different days
            Gift_Adjustments__c ga1 = new Gift_Adjustments__c(
                                    Batch_No__c = opp1.Tech_Batch_No__c,
                                    Current_Amount__c = opp1.amount,
                                    Previous_Amount__c  = opp1.amount-10,
                                    Opportunity__c  = opp1.id,
                                    createdDate = DateTime.Now().addDays(-1),
                                    adjustment_date__c = system.today().addDays(-1)// For this to work, Current running user must have "Edit Audit Fields" permission set assigned
                                    );
            insert ga1;
                     
            List<GAU_Allocation_Adjustment__c> listAllGiftAjust = [SELECT Id,Name FROM GAU_Allocation_Adjustment__c];
            system.debug('listAllGiftAjust-------------'+listAllGiftAjust);
            
            //for multiple days scenario
            List<npsp__Allocation__c> gauAllocationList = [SELECT Id,name,npsp__Amount__c,Credit_Account_Number__c,npsp__Opportunity__c FROM npsp__Allocation__c where npsp__Opportunity__c=:opp1.id];   
            GAU_Allocation_Adjustment__c gaa1 = new GAU_Allocation_Adjustment__c(
                                                Amount__c = gauAllocationList[0].npsp__Amount__c-10,
                                                Credit_Account_Number__c = gauAllocationList[0].Credit_Account_Number__c,
                                                GAU_Allocation__c = gauAllocationList[0].id,
                                                Opportunity__c = gauAllocationList[0].npsp__Opportunity__c,
                                                OppId__c = gauAllocationList[0].id,
                                                Previous_Amount__c = gauAllocationList[0].npsp__Amount__c,
                                                createdDate = DateTime.Now().addDays(-1),
                                                adjustment_date__c = system.today().addDays(-1)
                                                );
            insert gaa1;
            
            GLPostReportView  gl1 = new GLPostReportView ();
                gl1.getData();


            GLPostReport gl12 = new GLPostReport(stdController);
                gl12.PostMethod(); 

            test.stopTest();

        }
    }
    
}