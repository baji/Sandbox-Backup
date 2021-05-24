/*********************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            MOZO (SFDC-154)
    Original:           8/24/2016- Used to Test cancel bulk mozo trials when expiration date = today's date. 
    Updated:           04-09-2018 - <NMM-18> - Added the Applicant__c field and Contact Email to avoid Process Builder Errors
 ***********************************************************************************************************************************/ 
 
 @isTest
public with sharing class BatchUpdateAffiliationToDWRE_Test {   
 static testMethod void UpdateAffiliationToDWRE_TestMethod (){
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
        
        testAffiliation[0].Mozo_User_Level__c = 'LMS';
        testAffiliation[0].affiliationBatchFlag__c = 'Updated';
        update testAffiliation;
        
        BatchUpdateAffiliationToDemandware batchObj = new BatchUpdateAffiliationToDemandware();
        
        Database.executeBatch(batchObj);
        
       // usOrgAccount[0].Mozo_Trial_Status__c = 'Former';
        
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
        
        testAffiliation[0].Mozo_User_Level__c = 'LMS';
        testAffiliation[0].affiliationBatchFlag__c = 'Updated';
        update testAffiliation;
        BatchUpdateAffiliationToDemandware   batchObjAff = new BatchUpdateAffiliationToDemandware();
        
        Test.startTest();
        
        Database.executeBatch(batchObjAff);
       
        Test.stopTest();
       update usOrgAccount;
       Test.setMock(HttpCalloutMock.class, new myMockETag(false));
       
        
      }
      public static testmethod void UpdateAffiliationToDWRE_Fail() {
            List<String> accountIds = new List<String>();
            List<String> affIds = new List<String>();
            RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
           
            List<Account>  usOrgAccount = new List<Account>();
            List<npe5__Affiliation__c> testAffiliation = new List<npe5__Affiliation__c>();
            Contact c = new Contact();
            
            c.LastName = 'Baji';
            c.Email = 'sbaji@mailinator.com';
            insert c;
          
            usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                            Name='Test Account',
                                            Mozo_Trial_Status__c = 'Current',
                                            Registration_Level__c = 'R1',
                                            Mozo_Free_Trial_ContactID__c = c.Id,
                                            Mozo_Trial_Start_Date__c = system.today(),
                                            Mozo_Trial_End_Date__c = system.today(),
                                            Applicant__c=c.Id,
                                            Phone='9789922724',
                                            Physical_City__c='Cook',
                                            Physical_State__c='IL',
                                            PhysicalCountry__c='United States',
                                            Physical_County__c='Cook',Physical_Zip__c='60193',
                                            Church_Attendance__c='100',
                                            Language__c='Hindi',
                                            Most_Recent_Date_Added__c=system.TODAY()
                                     )
                );
       
                Test.startTest();
                    insert usOrgAccount;
                    testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[0].Id,npe5__Contact__c = c.Id));
                    insert testAffiliation;
                
                    //first request
                    AccountHelper ah1 = new AccountHelper(usOrgAccount[0].Id);
                    accountIds.add(JSON.serialize(ah1));
                    Test.setMock(HttpCalloutMock.class, new myMockETag(false));
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
                
                    BatchUpdateAffiliationToDemandware   batchObjAff = new BatchUpdateAffiliationToDemandware();
                    Database.executeBatch(batchObjAff);
                    testAffiliation[0].npe5__Status__c = 'Current';
                    testAffiliation[0].Mozo_User_Level__c = 'LMS';
                    update testAffiliation;
                
                    Map<String,object> jsonObjectAff = new Map<String,object>();
                    jsonObjectAff.put('c_Status', testAffiliation[0].npe5__Status__c);
                    jsonObjectAff.put('c_MozoLicenseLevel', testAffiliation[0].Mozo_User_Level__c);
                
                    String JSONStringAff = JSON.serialize(jsonObjectAff);
                    AccountHelper ahaf = new AccountHelper(testAffiliation[0].Id);
                    affIds.add(JSON.serialize(ahaf));
                    affIds.clear();
                    BatchUpdateAffiliationToDemandware   batchObjAff2 = new BatchUpdateAffiliationToDemandware();
                    Database.executeBatch(batchObjAff2);
                Test.stopTest();
                //*******************************************************
        }
}