public class ContentDocumentLinkBatch implements Database.Batchable <sObject> {
    
    public Database.QueryLocator Start(Database.BatchableContext BC){
        string query = 'SELECT Title__c,ParentId__c,NoteBody__c,ContentNoteId__c FROM TaskNotes__c  WHERE ContentNoteId__c !=null';
        return Database.getQueryLocator(query);
    }
    public void Execute(Database.BatchableContext BC, list<sObject> scope){
        map<string,list<TaskNotes__c>> inputMap =  new map<String,list<TaskNotes__c>>();
        list<ContentDocumentLink> lstTobeInserted = new list<ContentDocumentLink>();
        integer key = 1; string contentBody;
        for(sObject sobj : scope)
        {
            TaskNotes__c TN = (TaskNotes__c)sobj;
            if(inputMap.containsKey(TN.ParentId__c)){
                inputMap.get(TN.ParentId__c).add(TN);
            }
            else{
                list<TaskNotes__c> l = new list<TaskNotes__c>();
                l.add(TN);
                inputMap.put(TN.ParentId__c,l);
                
            }
         }
         list<Task> tasklst= [SELECT Id,Source_RE_ID__c FROM Task WHERE Source_RE_ID__c IN : inputMap.KeySet()];
         for(Task tak : tasklst){
             for(TaskNotes__c  TN : inputMap.get(tak.Source_RE_ID__c)){
                 ContentDocumentLink CDL = new ContentDocumentLink();
                 CDL.ContentDocumentId = TN.ContentNoteId__c;
                 CDL.LinkedEntityId = tak.Id;
                 CDL.ShareType = 'V';
                 lstTobeInserted.add(CDL);
             }
         }
         insert  lstTobeInserted;           
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
}