/*
@Company:Infoglen
@Author:Imran Shaik
@Creation date:30/11/2017
Reference:
*/
/**
 * Trigger S2STrainingTrackeCatalogRecordMap
 *
 * This trigger is used to update record type of Training Tracker Catalog object
 */
trigger S2STrainingTrackeCatalogRecordMap on RITT_Courses__c(Before Insert){
   Map<String,Id> mapRecType = new Map<String,Id>();
    Map<String,Id> mapQueue = new Map<String,Id>();
    List<String> ownerIdSet = new List<String>();
    Set<String> setQueueNames = new Set<String>();
    for(RecordType rt:[Select Id,Name,developerName From RecordType Where sObjectType = 'RITT_Courses__c']){
        mapRecType.put(rt.developerName,rt.Id);
    }
    for(RITT_Courses__c obj : trigger.new){
        if(obj.Source_OwnerId__c != null && (obj.Source_OwnerId__c).left(3) == '005')
            ownerIdSet.add(obj.Source_OwnerId__c);
        else
            setQueueNames.add(obj.Source_OwnerId__c);
    }
    Map<String,Id> mapUserId = S2SPartnerNetworkRecordUtility.getUsers(ownerIdSet);
    if(!setQueueNames.isEmpty()){
          for(Group obj : [SELECT Id,Type,Name FROM Group WHERE Type = 'Queue' AND Name IN : setQueueNames]){
            mapQueue.put(obj.Name,obj.Id);
        }
    }   
    for(RITT_Courses__c obj : trigger.new){        
        if(mapRecType.containsKey(obj.Source_Record_Type_Name__c))
            obj.RecordTypeId = mapRecType.get(obj.Source_Record_Type_Name__c);
        if(mapUserId.containsKey(obj.Source_OwnerId__c))
            obj.ownerId = mapUserId.get(obj.Source_OwnerId__c);
        else if(mapQueue.containsKey(obj.Source_OwnerId__c))
            obj.ownerId = mapQueue.get(obj.Source_OwnerId__c);
        else
            obj.ownerId = '005f4000000ZJhT';
    }
}