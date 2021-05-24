/*************************************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            WOO Stuck Tickets
    Orignal:(TW)        8-22-2018 -<ASP-1318> -  Removed all stuck Woo orders in Order Open state that are more than 10 minutes old.
-------------------------------------------------------------------------------------------------------------------------------------
Example: How to delete stuck WOO orders
BatchDeleteStuckWooOrdersScheduler j = new  BatchDeleteStuckWooOrdersScheduler();
String sch = '0 50 15 30 6 ? 2018';
String jobID = system.schedule('Delete Stuck Woo Orders', sch, j);
 ********************************************************************************************************************************/ 
global class BatchDeleteStuckWooOrders implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
 // global variables  
    global String query;
    global List<Id> mozoEndedIds = new List<Id>();
    global List<String> mozoEndedAccountStrings = new List<String>();
    global Id aId;
    global class UtilException extends Exception {} 
    global Datetime dtRemove10Minutes;
    global database.querylocator start(Database.BatchableContext BC){
        
        // Select All Accounts that have Current as their free trail Status
        if(query == null) {
            dtRemove10Minutes = system.now().addSeconds(-600); // We want the lastDate MOdified to be < 10 minutes from now.
            String timelapsed = String.valueOf(dtRemove10Minutes); 
        query 
            = 'Select Id,LastModifiedDate,Status,Name,Opportunity_Source__c  '
            + 'From Order  WHERE Opportunity_Source__c  = \'Awana Store\' '
            + 'And CreatedBy.Name=\'WooCommerce\' '
            + ' And Status = \'Order Open\' '
            + ' And LastModifiedDate < : dtRemove10Minutes';
        }
        if(Test.isRunningTest() ){
            query = query + ' LIMIT 200';
        }
        system.debug('<< QUERY  >> '+query);  
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
        List<Order> ordersToDelete = new List<Order>();
        for(sObject s : scope){
            Order thisOrder = (Order)s;
            system.debug('<<DEBUG STATUS >> '+thisOrder.Id+' <<ID>> '+thisOrder.Name+' <<NAME>> '+thisOrder.LastModifiedDate+'<<DATE>> '+thisOrder.Status+'<< STATUS >>'+thisOrder.Opportunity_Source__c+'<< SOURCE >>'); 
           // if(thisOrder.LastModifiedDate < dtRemove10Minutes){
                ordersToDelete.add(thisOrder); 
          //  }
        }
        
        if(ordersToDelete.size() > 0){
            delete ordersToDelete; 
        }
  }

  global void finish(Database.BatchableContext BC)
  {
            AsyncApexJob apexBatchResult = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: BC.getJobId()
        ];
    
        // Generate email body
        String emailBody = 'Apex Batch to DELETE Stuck WOO Order objects has been  processed '
            + apexBatchResult.TotalJobItems + ' batches with '+ apexBatchResult.NumberOfErrors + ' failures.\n\n';
         
        
         //3. Get User Ids for the SF Admins. They are the only ones that should be getting email.         
          Map<Id,User> users = new Map<Id, User>([SELECT Id, Email FROM User WHERE UserRole.name = 'System Administrator' 
                                                  AND IsActive = true]);
            
            
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
        mail.setSenderDisplayName('Stuck WOO Order Batch Results');
        mail.setSubject('Batch to Remove Stuck WOO Orders: ' + apexBatchResult.Status);
        mail.setPlainTextBody('Batch Process has completed\n\n' + emailBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
  }
}