/***************************************************************************************************************************************************************
    Programmer: Urvashi Dagara
    Company:    Infoglen
    Contact:    urvashi.dagara@infoglen.com
    Description: Test class for SendMembershipAgreement.
    
***************************************************************************************************************************************************************/


@isTest
public class SendMembershipAgreementTest{

    static testMethod void SendAgreementTest(){
    
        
        Id accUsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        
        Account acc = new Account(Name='Test Account',Mailing_Address_Book__c = '56478920',
                                  RecordTypeId = accUsRecordTypeId);  
                                  
        
        insert acc;
               
        system.debug(acc);
        
        Contact con = new Contact(FirstName='Test',
                                LastName='Contact',
                                Email='Test@test.com'
                                );   
                    
        insert con;
        
        npe5__Affiliation__c aff = new npe5__Affiliation__c();
        aff.npe5__Organization__c = acc.Id;
        aff.npe5__Contact__c = con.Id;
        aff.npe5__Status__c = 'Current';
        Insert aff;
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(con);
        SendMembershipAgreement controller = new SendMembershipAgreement(stdController);
        
        EmailTemplate english = [SELECT Id,Subject,HTMLValue,Name FROM EmailTemplate WHERE Name = 'Ministry Agreement English'];
        
        OrgWideEmailAddress owd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName= 'Ministry Agreement Email' Limit 1];
        
        List<Membership_Agreement_Settings__c> customSetLst = new List<Membership_Agreement_Settings__c>();
        customSetLst.add(new Membership_Agreement_Settings__c(Name='English Agreement Template Id',value__c = english.Id));
        customSetLst.add(new Membership_Agreement_Settings__c(Name='Org Wide Email Id',value__c = owd.id));
        customSetLst.add(new Membership_Agreement_Settings__c(Name='Spanish Agreement Template Id',value__c = english.Id )); 
        customSetLst.add(new Membership_Agreement_Settings__c(Name='Email Service Address',value__c = 'test@test.com'));
                
        insert customSetLst;
        
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId= english.Id;
        insert attach;
        
        List<Awana_Settings__c> awanaSettingsList = new List<Awana_Settings__c>();
        awanaSettingsList.add(new Awana_Settings__c(Name= 'ExecuteREMigrationAction',Value__c='False'));
        awanaSettingsList.add(new Awana_Settings__c(Name= 'ExecuteTaskTrigger',Value__c='False'));

        insert awanaSettingsList;
        
        ApexPages.currentPage().getParameters().put('id',con.id);

        controller.selectedAccount = acc.Id;       
        controller.getAccounts();
        controller.language = 'English';
        controller.sendAgreement();
        controller.language = 'Spanish';
        controller.sendAgreement();
        
        Test.stopTest();
       
        Contact conTest = [SELECT Id,Ministry_Agreement_Status__c FROM Contact WHERE Id=:Con.Id];
        System.assertEquals('Sent', conTest.Ministry_Agreement_Status__c);
    }
}