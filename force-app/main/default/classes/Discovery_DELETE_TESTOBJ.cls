global class Discovery_DELETE_TESTOBJ implements Database.Batchable<sObject>,Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name FROM TEST_OBJ__c ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<TEST_OBJ__c> testObjListChunk) {
        try {
            if(testObjListChunk!=null && !testObjListChunk.isEmpty()){
                delete testObjListChunk;
            }
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}