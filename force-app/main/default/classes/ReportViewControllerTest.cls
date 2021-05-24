@isTest
public class ReportViewControllerTest {
    
    static testmethod void testredirectToReport(){
        
        Account acc = new Account(name = 'Test');
        insert acc;
        
        dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c(dsfs__Company__c = acc.id,dsfs__Sender_Email__c = 'woocommerce@awana.org',
                                                                          dsfs__DocuSign_Envelope_ID__c = 'EB29041D-F21F-46A4-9352-BCA744C81768',
                                                                          dsfs__Sender__c = 'WooCommerce',dsfs__Subject__c = 'Awana Membership Registration',
                                                                          dsfs__Envelope_Status__c = 'Copmleted');
        insert docStatus;
        
        List<dsfs__DocuSign_Recipient_Status__c> docusignList = new List<dsfs__DocuSign_Recipient_Status__c>();
        docusignList.add(new dsfs__DocuSign_Recipient_Status__c(dsfs__Parent_Status_Record__c = docStatus.Id,Name = 'test',dsfs__DocuSign_Recipient_Email__c = 'test@test.com',
                                                                dsfs__DocuSign_Recipient_Id__c = 'EB29041D-F21F-46A4-9352-BCA744C81768',dsfs__Recipient_Status__c='Copmleted'));
        
        docusignList.add(new dsfs__DocuSign_Recipient_Status__c(dsfs__Parent_Status_Record__c = docStatus.Id,Name = 'test',dsfs__DocuSign_Recipient_Email__c = 'test@test.com',
                                                                dsfs__DocuSign_Recipient_Id__c = 'EB29041D-F21F-46A4-9352-BCA744C81769',dsfs__Recipient_Status__c='Copmleted'));
        
        insert docusignList;
        
        Test.startTest();
        	ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(docusignList);
        	stdSetController.setSelected(docusignList);
        	ReportViewController ext = new ReportViewController(stdSetController);
            ext.redirectToReport();
        	ext.redirectToList();
        	
        Test.stopTest();
    }
}