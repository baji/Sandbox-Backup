public class ContentNoteBatch implements Database.Batchable <sObject> {
    
    public Database.QueryLocator Start(Database.BatchableContext BC){
        string query = 'SELECT Title__c,ParentId__c,NoteBody__c,ContentNoteId__c FROM TaskNotes__c  WHERE ContentNoteId__c =null';
        return Database.getQueryLocator(query);
    }
    public void Execute(Database.BatchableContext BC, list<sObject> scope){
        map<string,TaskNotes__c> inputMap =  new map<String,TaskNotes__c>();
        map<String,ContentNote> contentNotesMap = new map<string,ContentNote >();
        integer key = 1; string contentBody;
        for(sObject sobj : scope)
        {
            TaskNotes__c TN = (TaskNotes__c)sobj;
            inputMap.put(string.valueOf(key),TN);
            ContentNote cn  = new ContentNote();
            contentNotesMap.put(string.valueOf(key),cn);
            cn.Title = TN.Title__c.trim();
            contentBody = TN.NoteBody__c.trim();
            contentBody = contentBody.escapeHTML4();            
            try{
                cn.Content = Blob.valueOf(contentBody);
            }
            catch(Exception e){
                inputMap.remove(string.valueOf(key));
                contentNotesMap.remove(string.valueOf(key));
            }
            key++;
        }
        Database.insert(contentNotesMap.Values(),false);
        for(string mapKey : contentNotesMap.keySet()){
            try{
                inputMap.get(mapkey).ContentNoteId__c = contentNotesMap.get(mapKey).Id;
            }catch(Exception e){
                inputMap.get(mapkey).ContentNoteId__c = null;
            }
            
        }
        update inputMap.Values();
        
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
}