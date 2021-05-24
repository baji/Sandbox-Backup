/*********************************************************************************************************
    Programmer:         Shaik A. Baji
    Company:            Awana/ EC Group
    Contact:            tonyw@awana.org
    Project:            MOZO (SFDC-154)
    Original:          8/24/2016- Used to Test cancel bulk mozo trials when expiration date = today's date.   
 ***********************************************************************************************************/ 
 
 @isTest
public class BatchEndMozoFreeTrialAccounts_Test {
 
    static testMethod void BatchEndMozoFreeTrialAccounts_TestMethod (){
        RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
        List<Account>  usOrgAccount = new List<Account>();
         List<String> accountIds = new List<String>();
        List<npe5__Affiliation__c> testAffiliation = new List<npe5__Affiliation__c>();
        Contact c = new Contact();
        
        c.LastName = 'Baji';
        c.Email = 'sbaji@mailinator.com';
        insert c;
        usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                        Name='Test Account',
                                        Mozo_Trial_Status__c = 'Current',
                                        Mozo_Free_Trial_ContactID__c = c.Id,
                                        Mozo_Trial_Start_Date__c = system.today(),
                                        Mozo_Trial_End_Date__c = system.today(),
                                      	Applicant__c = c.Id
                                 )
        );
        insert usOrgAccount;
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[0].Id,npe5__Contact__c = c.Id));
        insert testAffiliation;
        BatchEndMozoFreeTrialAccounts batchObj = new BatchEndMozoFreeTrialAccounts();
        
       
        Database.executeBatch(batchObj);
        
        usOrgAccount[0].Mozo_Trial_Status__c = 'Former';
        
        //first request
        AccountHelper ah1 = new AccountHelper(usOrgAccount[0].Id);
        accountIds.add(JSON.serialize(ah1));
        
        Test.setMock(HttpCalloutMock.class, new myMockETag(true));
        //second request
        Map<String,object> jsonObject = new Map<String,object>();
        jsonObject.put('c_MozoTrialStatus', usOrgAccount[0].Mozo_Trial_Status__c);
        jsonObject.put('c_MozoTrialContactID', usOrgAccount[0].Mozo_Free_Trial_ContactID__c);
        Integer d = usOrgAccount[0].Mozo_Trial_Start_Date__c.day();
        Integer mo = usOrgAccount[0].Mozo_Trial_Start_Date__c.month();
        Integer yr = usOrgAccount[0].Mozo_Trial_Start_Date__c.year();
        
        DateTime ST = DateTime.newInstance(yr, mo, d, 12, 0, 0);
        jsonObject.put('c_MozoTrialStartDate', ST);
        
        Integer ed = usOrgAccount[0].Mozo_Trial_End_Date__c.day();
        Integer emo = usOrgAccount[0].Mozo_Trial_End_Date__c.month();
        Integer eyr = usOrgAccount[0].Mozo_Trial_End_Date__c.year();
        
        DateTime ET = DateTime.newInstance(eyr, emo, ed, 12, 0, 0);
        
        jsonObject.put('c_MozoTrialEndDate', ET);
        String JSONString = JSON.serialize(jsonObject);
        AccountHelper ah = new AccountHelper(usOrgAccount[0].Id);
        accountIds.add(JSON.serialize(ah));
        Test.startTest();
       
        Database.executeBatch(batchObj);
        Test.stopTest();
        update usOrgAccount;
        Test.setMock(HttpCalloutMock.class, new myMockETag(false));
        
        }
}