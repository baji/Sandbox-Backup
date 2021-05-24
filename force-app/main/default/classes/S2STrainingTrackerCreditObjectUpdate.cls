/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2STrainingTrackerCreditObjectUpdate
 
 * This batch class is used to update all lookup fields of a Training Tracker Credit Object
 */
global class S2STrainingTrackerCreditObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Contact_Information__c,Source_Contact_Rec_Id__c,Source_Record_Type_Name__c,Source_RITT_Courses__c,Contact__c,Contact_Information__c,RITT_Courses__c FROM RITT_Credits__c');
    }
    global void execute(Database.BatchableContext BC, List<RITT_Credits__c>scope){
        List<String> listoldId = new List<String>();
        for(RITT_Credits__c obj : scope){                      
            listoldId.add(obj.Source_Contact_Information__c);
            listoldId.add(obj.Source_Contact_Rec_Id__c);
            listoldId.add(obj.Source_RITT_Courses__c);
        }   
        
        Map<String,Id> mapRecType = new Map<String,Id>();
        for(RecordType rt:[Select Id,Name From RecordType Where sObjectType = 'RITT_Credits__c']){
            mapRecType.put(rt.Name,rt.Id);
        } 
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);   
        
        List<RITT_Credits__c> listCon = new List<RITT_Credits__c>();
        
        for(RITT_Credits__c obj : scope){       
            if(mapWithNewOldId.containsKey(obj.Source_Contact_Information__c))
                obj.Contact_Information__c = mapWithNewOldId.get(obj.Source_Contact_Information__c);
            if(mapWithNewOldId.containsKey(obj.Source_Contact_Rec_Id__c))
                obj.Contact__c = mapWithNewOldId.get(obj.Source_Contact_Rec_Id__c);
            if(mapWithNewOldId.containsKey(obj.Source_RITT_Courses__c))
                obj.RITT_Courses__c = mapWithNewOldId.get(obj.Source_RITT_Courses__c);
            if(mapRecType.containsKey(obj.Source_Record_Type_Name__c))
                obj.RecordTypeId = mapRecType.get(obj.Source_Record_Type_Name__c);                
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}