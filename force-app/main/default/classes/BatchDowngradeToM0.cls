/*************************************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            
    Original:          	11/6/2018- <ASP-1476> -  batch Apex Scheduler to do cleanup of delinquent Mozo Levels which should be set to M0 when Mozo Expiration Date <= Today.   
	------------------------------------------------------------------
Example: How to clean up straggling MFT accounts when their Registration Due Date is up? (This  example runs once per year)
BatchDowngradeToM0 j = new  BatchDowngradeToM0();
String sch = '0 50 14 06 11 ? *';
String jobID = system.schedule('DowngradeToM0', sch, j);
 ********************************************************************************************************************************/ 

global class BatchDowngradeToM0 implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
	// global variables  
    global String query;
    global List<String> mozoEndedAccountStrings = new List<String>();
    global Id aId;
    global class UtilException extends Exception {} 
    
    global database.querylocator start(Database.BatchableContext BC){
        // Even though system.today is of type Date it gives DateTime-like values ..
        String someDateStr = String.valueOf(system.today());
        // ... so remove the time fromthe date.
        someDateStr= someDateStr.substringBefore('00:');
        // Select All US Org Accounts that have Current as their free traill Status with MFT End Date <= today
        if(query == null){
        query 
            = 'Select Id,MOZO_Expiration_Date__c FROM ACCOUNT'
            + ' WHERE MOZO_Level__c in (\'M1\',\'M2\',\'M3\',\'M4\')' 
            + ' AND Status__c = \'Added\' '
            + ' AND MOZO_Expiration_Date__c  <='+someDateStr+''
            + ' And (RecordType.Name like \'%Church%\' Or RecordType.Name like \'%Organization%\')';
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
     	// Get all MFT Accounts and store them for loading start and end date values into DW
		List<Account> accountsToUpdate = new List<Account>();
    	for(sObject s : scope){
      		Account thisAccount = (Account)s;
      		system.debug('<<DEBUG STATUS >> '+thisAccount.Id+' <<ID>> '+thisAccount.MOZO_Expiration_Date__c+'<<  DATE  >> '+thisAccount.MOZO_Expiration_Date__c+' VS  '+system.today());
      		thisAccount.MOZO_Level__c = 'M0';
        	accountsToUpdate.add(thisAccount);
        	aId = (Id)thisAccount.Id;
        	system.debug('**************************'+aId);
        }//<For Scope>
    	system.debug('**************no.of accounts to be updated*******************'+accountsToUpdate.size());
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
        String emailBody = 'Apex Batch to DELETE Stuck WOO Order objects has been  processed '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
        
        
         //3. Get User Ids for the SF Admins. They are the only ones that should be getting email.
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
        mail.setSenderDisplayName('Downgrade To M0  Results');
        mail.setSubject('Batch to Downgrade Account Mozo Level TO M0 on  Mozo Expiration Date ='+Date.Today()+': ' + apexBatchResult.Status);
        mail.setPlainTextBody('Batch Process has completed\n\n' + emailBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
  }
}