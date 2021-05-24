global class Discovery_CreateHouseHold_Accounts implements Database.Batchable<sObject>,Database.Stateful{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String businessUnit = '012f4000000dA7N';
        String internaltionalChurch = '012f4000000dA7T';
        String query = 'SELECT Id,Name FROM contact where AccountId!=null AND Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        try {
            system.debug(': Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
            List<Account> newHouseHold_AccountList = new List<Account>();
            List<npe5__Affiliation__c> affliaTionList = new List<npe5__Affiliation__c>();
            
            for(Contact conObj : contactListChunk){
                Account newHouseHoldObj =  new Account();
                newHouseHoldObj.Name = 'house holdAccount';
                newHouseHoldObj.RecordTypeId = '012f4000000nLu0';
                newHouseHold_AccountList.add(newHouseHoldObj);
                
                npe5__Affiliation__c affiliationObj = new npe5__Affiliation__c();
                affiliationObj.npe5__Contact__c = conObj.Id;
                affiliationObj.npe5__Organization__c = conObj.Account.Id;
                affliaTionList.add(affiliationObj);
            }
            if(newHouseHold_AccountList!=null && !newHouseHold_AccountList.isEmpty()){
                insert newHouseHold_AccountList;
            }
            
            for(Integer i=0 ; i<contactListChunk.size() ;i++){
                contactListChunk[i].AccountId = newHouseHold_AccountList[i].Id;
            }
            if(affliaTionList!=null && !affliaTionList.isEmpty()){
                insert affliaTionList;
            }
            if(contactListChunk!=null && !contactListChunk.isEmpty()){
                update contactListChunk;
            }
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}