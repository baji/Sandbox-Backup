/***************************************************************************************************************************************************************
    Programmer: Mayur Soni
    Company:    Infoglen
    Contact:    mayur@infoglen.com
    Description:Test class for SendDocusignEnvelope
    
  ***************************************************************************************************************************************************************/
@isTest(SeeAllData=true)
public class TestSendDocusignEmail{
    public static testmethod void sendDocusignEmail(){
        Account account = new Account(Name='Test Account');
        insert account;
        Account acc;
        SendDocusignEnvelope sde = new SendDocusignEnvelope(new ApexPages.StandardController(account));        
        SendDocusignEnvelope sdeo = new SendDocusignEnvelope();
        Account acc1 = sdeo.getAccount();
        insert acc1;
        sdeo.setAccount(account);
        
        PageReference pageRef = Page.SendDocusignEnvelope;
        Test.setCurrentPage(pageRef);
        Id id1 = ApexPages.currentPage().getParameters().put('id', acc1.id);
        Contact c = new Contact(FirstName='Contact',LastName='Test',Email='test@test.com');
        insert c;
        Contact con = [select Id,Name,Email From Contact where Id =: c.Id Limit 1];
        acc1.Applicant__c = con.Id;
        update acc1;
        Account accFetch = [select Name from Account where Id =: account.id Limit 1];
        
        /*Contact con1 = [select Id,Name,FirstName,LastName,Email from Contact where Id =: acc1.Applicant__c Limit 1];
        String conName = con1.FirstName+con1.LastName;
        
        Task t = new Task();
        t.OwnerId = '005f4000000xGMv';
        t.Subject = 'Sent Agreement via Docusign';
        t.ActivityDate =  Date.Today();
        t.Type = 'Registration';
        t.Status = 'Completed';
        t.WhoId = c.Id;
        t.WhatId = accFetch.id;
        insert t;
        */
        User u = new User( 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            FirstName = 'Tag',
            LastName = 'Tools',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            );
        insert u;
        sdeo.sendAgreement();
        sdeo.sendToMe();
    } 
}