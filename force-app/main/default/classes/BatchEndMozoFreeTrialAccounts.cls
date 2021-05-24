/*************************************************************************************************************************************
    Programmer:         S. A. Baji.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            MOZO (SFDC-154)
    Original:          	8/24/2016- Used to Test cancel bulk mozo trials when expiration date = today's date.  
	Updated:(TW)		4/09/2018 - Refactored Code to avoid SOQL Governor limist as too many SOQL statements were  inside loops
	Updated:(TW)		8-22-2018 -<ASP-1318> -  Removed all references to DW since wqe are no longer using this client service.
	Updated:(TW)        9-07-2018 - <ASP-1353> - Changed the email body string to replace "IC19 batch process" to "Mozo Free Trial" .
------------------------------------------------------------------
Example: How to clean up straggling MFT accounts when their Registration Due Date is up? (This  example runs once per year)
BatchEndMozoFreeTrialSchedule j = new  BatchEndMozoFreeTrialSchedule();
String sch = '0 50 15 30 6 ? 2018';
String jobID = system.schedule('MozoFreeTrial', sch, j);
 ********************************************************************************************************************************/ 
global class BatchEndMozoFreeTrialAccounts  implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    // global variables  
    global String query;
    global List<Id> mozoEndedIds = new List<Id>();
    global List<String> mozoEndedAccountStrings = new List<String>();
    global Id aId;
    global class UtilException extends Exception {} 
  
	global database.querylocator start(Database.BatchableContext BC){
        // Even though system.today is of type Date it gives DateTime-like values ..
        String someDateStr = String.valueOf(system.today());
        // ... so remove the time fromthe date.
        someDateStr= someDateStr.substringBefore('00:');
        // Select All US Org Accounts that have Current as their free traill Status with MFT End Date <= today
        if(query == null) 
        {
        query 
            = 'Select Id, '
            + ' Mozo_Trial_End_Date__c, '
            + ' Mozo_Trial_Start_Date__c, '
            + ' Mozo_Trial_Status__c '
            + 'From Account WHERE Mozo_Trial_Status__c = \'Current\' '
	    	+ ' AND Mozo_Trial_End_Date__c <='+someDateStr+''
            + ' And (RecordType.Name like \'%Church%\' Or RecordType.Name like \'%Organization%\')';
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    } 
  	global void execute(Database.BatchableContext BC, List<sObject> scope){
     	// Get all MFT Accounts and store them for loading start and end date values into DW
		List<Account> accountsToUpdate = new List<Account>();
    	List<ID> storeContactIDs = new List<ID>();
    	for(sObject s : scope){
      		Account thisAccount = (Account)s;
      		system.debug('<<DEBUG STATUS >> '+thisAccount.Id+' <<ID>> '+thisAccount.Mozo_Trial_Status__c+'<<  DATE  >> '+thisAccount.Mozo_Trial_End_Date__c+' VS  '+system.today());
      		thisAccount.Mozo_Trial_Status__c = 'Former';
        	accountsToUpdate.add(thisAccount);
        	aId = (Id)thisAccount.Id;
        	system.debug('**************************'+aId);
        	mozoEndedIds.add(aId); // Just  for Test purposes. Makes sure we get all the account IDs		
        }//<For Scope>
    	system.debug('**************************'+mozoEndedIds.size());
    	system.debug('**************no.of accounts to be updated*******************'+accountsToUpdate);
       // Go through all filtered accounts and send DW their End and Start MFT dates as well as their Status
       
        system.debug('**************no.of accounts to be updated*******************'+accountsToUpdate);
    	if(accountsToUpdate.size() > 0){
      		update accountsToUpdate;
    	}
	}
  	global void finish(Database.BatchableContext BC){
		AsyncApexJob apexBatchResult = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: BC.getJobId()
        ];
    
        // Generate email body
        String emailBody = ' Apex Batch to Expire Mozo Free Trial Account objects  processed '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
        
        
         //3. Get User Ids for the Acocunt Team Updates Group.
            Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN (
    								SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'SF Administrator')]);
            
        	
            List<String> userEmail = new List<String>();
            //We need to make sure that the Test coverage will work when testing emails otherwise a REQUIRED_FIELD_MISSING, Missing exception will occur.
            if(Test.isRunningTest()){
                User tUser=[Select Email from User where Name Like 'MyAwana%' Limit 1];
                userEmail.add(tUser.Email);
            }else{
           		for(User someUser : users.values()){
					userEmail.add(someUser.Email); 
            	}
            }
            List<String> sendTo = new List<String>();
			sendTo.addAll(userEmail);

        // Send email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('Expired Mozo Free Trial Batch Results');
        mail.setSubject('Batch to Expire Mozo Free Trial Accounts: ' + apexBatchResult.Status);
        mail.setPlainTextBody('Batch Process has completed\n\n' + emailBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        
        // Set Affiliation Mozo User Levels to 'LMS' and update them 
        List<npe5__Affiliation__c> batchAffUpdate = new List<npe5__Affiliation__c>();
        system.debug('********************3*****************'+mozoEndedIds.size());
        List<npe5__Affiliation__c> affList = [select Id from npe5__Affiliation__c where Mozo_User_Level__c =: 'LMS' AND npe5__Organization__c IN: mozoEndedIds];
        system.debug('______________________________'+affList.size());
         
		for(npe5__Affiliation__c aff: affList){       
         	aff.affiliationBatchFlag__c = 'updated';
                batchAffUpdate.add(aff);
      	}
        update batchAffUpdate;  
  }

}