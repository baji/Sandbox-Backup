/*
 * BatchUpdateAccountTeams_Test - Tests the batch class BatchUpdateAccountTeams
 * 4/04/2018
 * Tony Williams
 */
//@isTest
@isTest(SeeAllData = true)
public without sharing class  BatchUpdateAccountTeams_Test {
  static testMethod void BatchUpdateAccountTeams_TestMethod (){
      RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
        List<Account>  usOrgAccount = new List<Account>();
        List<String> accountIds = new List<String>();
        List<npe5__Affiliation__c> testAffiliation = new List<npe5__Affiliation__c>();
        Contact c = new Contact();
        c.LastName = 'Baji';
        c.LeadSource = 'Web';
        insert c;
        
        // Now get Accounts
        usOrgAccount.add([Select Id,Mailing_Address_Book__c,Physical_County__c,Physical_State__c From Account WHERE Status__c = 'Added' And Type = 'Church'  And Physical_County__c <> null  And  Physical_State__c <> null And Type = 'Church' And Registration_Level__c = 'R1' And RecordType.Name = 'US Organization'  limit 1]);
        usOrgAccount[0].Physical_County__c = 'Cook'; // Clatsop is the original county of Oregon
       	usOrgAccount[0].Registration_Level__c = 'R0';
      	update usOrgAccount;
       // insert usOrgAccount;
      	List<User> missionaries = [Select Id,u.IsActive, u.Department From User u where department = 'US Missionaries' limit 1];
        
        usOrgAccount[0].OwnerId = missionaries[0].Id; 
      	update usOrgAccount;
        // Now Affiliation
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[0].Id,npe5__Contact__c = c.Id,npe5__Status__c = 'Pending', Other_Role__c='Volunteer'));
        insert testAffiliation;
      	testAffiliation[0].Other_Role__c = 'Advocate';
      	testAffiliation[0].npe5__Status__c = 'Current';
      	update testAffiliation;
        
        //Now set up or Batch script job.
        BatchUpdateAccountTeams batchObj = new BatchUpdateAccountTeams();
       	Test.startTest();
      		usOrgAccount[0].Registration_Level__c = 'R1';
      		//update usOrgAccount;
        	String  query 
            	= 'Select Id,Physical_County__c,Physical_State__c  '
            	+ ' From Account WHERE Status__c = \'Added\' '
            	+ ' And Physical_County__c <> null '
            	+ ' And Physical_State__c <> null '
            	+ ' AND Registration_Level__c = \'R1\' '
            	+ ' And RecordType.Name like \'%US Organization%\' Limit 150';
       
          	batchObj.query = query;
          	Database.executeBatch(batchObj);
        Test.stopTest();
    }
}