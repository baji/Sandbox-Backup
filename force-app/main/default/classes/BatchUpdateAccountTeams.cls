/**************************************************************************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Account Team Updates
    Original:            03/20/2018 - <ASP-925> - Updates Account Teams for all active US organization churches
  Tested By: BatchUpdateAccountTeams_Test - Used Test.IsRunning.Test() to get good coverage.
 ********************************************************************************************************************************************************************************/ 
global class BatchUpdateAccountTeams  implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
     global String query;
    global Integer accountSize = 0;
    List<Account> accountsToUpdate = new List<Account>();
    global class UtilException extends Exception {} 
    global Integer accountsReadSofar = 0;
    global Integer overallRecords = 10000;
    
    global database.querylocator start(Database.BatchableContext BC){
        //*****************************************************************************************************************************************************************************p
        //Select All active US Accounts that have counties and states
        //NOTE: You don't need to get all Physical address components just the city and state.
        //*****************************************************************************************************************************************************************************
        if(query == null) 
        {
            
            // Now load processed IDs as part of the WHERE clause for processing  2000 row-batch
            query 
            = 'Select Id,Physical_County__c,Physical_State__c  '
            + ' From Account WHERE Status__c = \'Added\' '
            + ' And Physical_County__c <> null '
            + ' And Physical_State__c <> null '
            + ' And Registration_Level__c = \'R1\''
            + ' And RecordType.Name = \'US Organization\' ORDER By Name  ASC ';
            system.debug('<< QUERY  >> '+query);  
            
        }
        return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Id> accountIDs = new List<Id>();
        //List<RecordType> rec = [Select Id from RecordType where Name = 'US Organization' Limit 1];
        //1. Get access to all Active US Organizations having Physical counties and states.
        Integer maxRecords = 1000;
       	system.debug('<<ACCOUNT SIZE >> '+scope.size());
       	maxRecords = scope.size();
        for(Object s: scope){
        	Account thisAccount = (Account)s;
            accountsToUpdate.add(thisAccount);
           	accountIDs.add(thisAccount.Id);
            accountSize++;
            system.debug('<<ACCOUNTs PROCESSED SO FAR >> '+accountSize);
            if(accountSize  == maxRecords - 1){
                system.debug('<<ACCOUTS TO UPDATE >> '+accountsToUpdate);
            	if(accountsToUpdate.size() > 0){
          			TeamMemberAccounts.handler(accountsToUpdate,accountIDs); 
            		TeamMemberAccounts.handler(accountsToUpdate); 
        		}
                accountsToUpdate.clear();
                accountIDs.clear();
                accountSize = 0;     
            }
            accountsReadSofar++;
            system.debug('<<Accounts read in so found>> '+accountsReadSofar);
    	}
   		system.debug('<< Max Accounts found>> '+accountSize);
  }
    
  global void finish(Database.BatchableContext BC){
        AsyncApexJob apexBatchResult = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: BC.getJobId()
        ];
    
        // Generate email body
        String emailBody = 'Apex Batch to Update Account Team objects  processed '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
        
        
         //3. Get User Ids for the Acocunt Team Updates Group.
            Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN (
    								SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'Account Team Updates')]);
            
        	
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
        mail.setSenderDisplayName('About.com Experts - Batch Results');
        mail.setSubject('About.com - Batch to Update Account Team members: ' + apexBatchResult.Status);
        mail.setPlainTextBody('Batch Process has completed\n\n' + emailBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
    
    
}