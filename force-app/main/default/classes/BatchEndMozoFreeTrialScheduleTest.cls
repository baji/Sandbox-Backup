/*********************************************************************************************************
    Programmer:         Mayur Soni
    Company:            Infoglen
    Contact:            mayur@infoglen.com
    Project:            MOZO (SFDC-154)
    Original:          8/24/2016- Used to Test schedule class for cancel bulk mozo trials when expiration date = today's date.   
****************************************************************************************************************************/
@isTest(SeeAllData = true)
public class BatchEndMozoFreeTrialScheduleTest {
    static testMethod void BatchEndMozoFreeTrialAccountsSchedule_TestMethod (){
            RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
            List<Account>  usOrgAccount = new List<Account>();
             List<String> accountIds = new List<String>();
            List<npe5__Affiliation__c> testAffiliation = new List<npe5__Affiliation__c>();
            Contact c = new Contact();
            
            c.LastName = 'Baji';
            insert c;
            usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                            Name='Test Account',
                                            Mozo_Trial_Status__c = 'Current',
                                            Registration_Level__c = 'R1',
                                            Mozo_Free_Trial_ContactID__c = c.Id,
                                            Mozo_Trial_Start_Date__c = system.today(),
                                            Mozo_Trial_End_Date__c = system.today()
                                     )
            );
            insert usOrgAccount;
            testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[0].Id,npe5__Contact__c = c.Id));
            insert testAffiliation;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new myMock(true));
            BatchEndMozoFreeTrialSchedule j = new  BatchEndMozoFreeTrialSchedule();
            String sch = '0 50 15 30 6 ? *';
            String jobID = system.schedule('MozoFreeTrial', sch, j);    
            
            Test.stopTest();
        }
}