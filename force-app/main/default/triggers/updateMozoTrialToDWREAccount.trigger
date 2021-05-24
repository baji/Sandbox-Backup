trigger updateMozoTrialToDWREAccount on Account (after update) {
    
    List<String> accountIds = new List<String>();
    List<Account> accountList = new List<Account>();
    String doNotCallController = 'success';
    //RecordType rec = [select Id from RecordType where Name  = 'US Organization' limit 1];
    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
    User demandwareAppUser = [select Id from User where Name = 'Demandware'];
    if(Trigger.isUpdate){
        system.debug('--------------------'+demandwareAppUser.Id);
        for(Account accs: Trigger.new){
            if(accs.RecordTypeId == accRecordTypeId && accs.LastModifiedById != demandwareAppUser.Id){
                system.debug('Account Details'+'--'+accs.Name+'--'+accs.RecordTypeId+'--'+accs.LastModifiedById);
                system.debug('<< NEW REG LEVEL>>> '+accs.Registration_Level__c);   
                accountList.add(accs);
            }
        }
    }
    for(Integer count = 0; count < accountList.size() ; count++){
        if(trigger.old[count].Mozo_Trial_Status__c != trigger.new[count].Mozo_Trial_Status__c || 
           trigger.old[count].Mozo_Free_Trial_ContactID__c != trigger.new[count].Mozo_Free_Trial_ContactID__c ||
           trigger.old[count].Mozo_Trial_Start_Date__c != trigger.new[count].Mozo_Trial_Start_Date__c ||
           trigger.old[count].Mozo_Trial_End_Date__c != trigger.new[count].Mozo_Trial_End_Date__c){
            
            system.debug('--'+trigger.new[count].Id+'--'+trigger.new[count].Mozo_Free_Trial_ContactID__c+'--'+trigger.new[count].Mozo_Trial_Status__c+'--'+trigger.new[count].Mozo_Trial_Start_Date__c+'--'+trigger.new[count].Mozo_Trial_End_Date__c);
            //DemandwareController.getAccessToken(trigger.new[count].Id,trigger.new[count].Mozo_Free_Trial_ContactID__c,trigger.new[count].Mozo_Trial_Status__c,trigger.new[count].Mozo_Trial_Start_Date__c,trigger.new[count].Mozo_Trial_End_Date__c);
            /*
            if( trigger.old[count].Mozo_Trial_Status__c == 'Former' && trigger.old[count].Mozo_Trial_End_Date__c == trigger.new[count].Mozo_Trial_End_Date__c && (trigger.new[count].LastModifiedById == '00550000000vuyG' || trigger.new[count].LastModifiedById == '00550000001qiyX')){
                doNotCallController = 'fail';
            }
            */
            if(!system.isbatch()){
                AccountHelper ah = new AccountHelper(trigger.new[count].Id);
                accountIds.add(JSON.serialize(ah));  
                ControllerToUpdateDWREAccount.getAccessToken(accountIds);
            }
        }
        
    }
    
}