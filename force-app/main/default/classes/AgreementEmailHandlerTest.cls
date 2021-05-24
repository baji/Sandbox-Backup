/***************************************************************************************************************************************************************
    Programmer: Urvashi Dagara
    Company:    Infoglen
    Contact:    urvashi.dagara@infoglen.com
    Description: Test class for AgreementEmailHandler.
    
***************************************************************************************************************************************************************/
@isTest
private class AgreementEmailHandlerTest {
    
    static testMethod void testMailReceivePositive() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        Contact con = [SELECT Id,Email FROM Contact WHERE Email='Test@test.com'];
        
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test Subject Ref#'+con.Id;
        env.fromAddress = 'Test@test.com';
        email.plainTextBody = 'Thanks,PFA Wrote:'; 
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.pdf';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment }; 
            
         Test.startTest();
        // Call the class and test it with the data in the testMethod.
        AgreementEmailHandler controller = new AgreementEmailHandler();
        controller.handleInboundEmail(email, env );
        Test.stopTest();
        
        Contact conTest = [SELECT Ministry_Agreement_Status__c FROM Contact WHERE Id=:con.id];
        System.assertEquals('Received', conTest.Ministry_Agreement_Status__c);
        
    }
    
    static testMethod void testNegativeWoAttachment() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        Contact con = [SELECT Id,Email FROM Contact WHERE Email='Test@test.com'];
        
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test Subject Ref#'+con.Id;
        env.fromAddress = 'Test@test.com';
        email.plainTextBody = 'Thanks,PFA Regards'; 
        
        Test.startTest();
        // Call the class and test it with the data in the testMethod.
        AgreementEmailHandler controller = new AgreementEmailHandler();
        controller.handleInboundEmail(email, env );
        Test.stopTest();
        
        Contact conTest = [SELECT Ministry_Agreement_Status__c FROM Contact WHERE Id=:con.id];
        //As no contact found.
        System.assertEquals('Received with Errors', conTest.Ministry_Agreement_Status__c);
        
    }
    
    
    static testMethod void testNegativeSubjectModifyNoContactFound() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        Contact con = [SELECT Id,Email FROM Contact WHERE Email='Test@test.com'];
        
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test Subject Ref#';
        env.fromAddress = 'Testanotheremail@test.com';
        email.plainTextBody = 'Thanks,PFA Regards'; 
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.png';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        Test.startTest();
        // Call the class and test it with the data in the testMethod.
        AgreementEmailHandler controller = new AgreementEmailHandler();
        controller.handleInboundEmail(email, env );
        Test.stopTest();
        
        Contact conTest = [SELECT Ministry_Agreement_Status__c FROM Contact WHERE Id=:con.id];
        System.assertEquals(null, conTest.Ministry_Agreement_Status__c);
        
    }
    
    static testMethod void testNegativeSubjectModifyMultipleContactFound() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        Contact con = [SELECT Id,Email FROM Contact WHERE Email='Test@test.com'];
        
        contact conDuplicateEmail = new Contact(
        Firstname = 'ConDup', lastname= 'Test',Email = 'Test@test.com' 
        );
        
        insert conDuplicateEmail;
        
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test Subject Ref#';
        env.fromAddress = 'Test@test.com';
        email.plainTextBody = 'Thanks,PFA Regards'; 
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.jpeg';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        Test.startTest();
        // Call the class and test it with the data in the testMethod.
        AgreementEmailHandler controller = new AgreementEmailHandler();
        controller.handleInboundEmail(email, env );
        Test.stopTest();
        
        Contact conTest = [SELECT Ministry_Agreement_Status__c FROM Contact WHERE Id=:con.id];
        //as no unique contact found
        System.assertEquals(null, conTest.Ministry_Agreement_Status__c);
        
    }
    
    static testMethod void testPositiveSubjectModifyContactFound() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        
        Contact con = [SELECT Id,Email FROM Contact WHERE Email='Test@test.com'];
        
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test Subject Ref#';
        env.fromAddress = 'Test@test.com';
        email.plainTextBody = 'Thanks,PFA From:'; 
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.png';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

         Test.startTest();
        // Call the class and test it with the data in the testMethod.
        AgreementEmailHandler controller = new AgreementEmailHandler();
        controller.handleInboundEmail(email, env );
        Test.stopTest();
        
        Contact conTest = [SELECT Ministry_Agreement_Status__c FROM Contact WHERE Id=:con.id];
        System.assertEquals('Received', conTest.Ministry_Agreement_Status__c);
        
    }
    
    @testSetup static void createTestData() {
        //Test Data
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
        aff.npe5__Status__c = 'Test@test.com';
        Insert aff;
        
        EmailTemplate error = [SELECT Id,Subject,HTMLValue,Name FROM EmailTemplate WHERE Name = 'Ministry Agreement Error Notification'];
        OrgWideEmailAddress owd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName= 'Ministry Agreement Email' Limit 1];
        List<Membership_Agreement_Settings__c> customSetLst = new List<Membership_Agreement_Settings__c>();
        customSetLst.add(new Membership_Agreement_Settings__c(Name='Customer Care Email',value__c = 'Test@testcustomer.com'));
        customSetLst.add(new Membership_Agreement_Settings__c(Name='Org Wide Email Id',value__c = owd.id));
        customSetLst.add(new Membership_Agreement_Settings__c(Name='Error Notification Template Id',value__c = error.Id )); 
        
        insert customSetLst;
        
    }
    
}