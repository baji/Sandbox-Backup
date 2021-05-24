/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Trigger S2SHonorariumRecordMap
 *
 * This trigger is used to map record type of a record
 */
trigger S2SHonorariumRecordMap on Honorarium_Request__c(Before Insert){
    Map<String,Id> mapRecType = new Map<String,Id>();
    Map<String,Id> mapQueue = new Map<String,Id>();
    List<String> ownerIdSet = new List<String>();
    Set<String> setQueueNames = new Set<String>();
    for(RecordType rt:[Select Id,Name,developerName From RecordType Where sObjectType = 'Honorarium_Request__c']){
        mapRecType.put(rt.developerName,rt.Id);
    }
    for(Honorarium_Request__c obj : trigger.new){
        if(obj.Source_OwnerId__c != null && (obj.Source_OwnerId__c).left(3) == '005')
            ownerIdSet.add(obj.Source_OwnerId__c);
        else
            setQueueNames.add(obj.Source_OwnerId__c);
    }
    Map<String,Id> mapUserId = S2SPartnerNetworkRecordUtility.getUsers(ownerIdSet); 
    for(Honorarium_Request__c obj : trigger.new){        
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