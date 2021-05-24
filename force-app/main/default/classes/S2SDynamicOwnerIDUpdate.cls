/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SDynamicObjectOwnerIDUpdate
 
 * This batch class is used to update all ownerid  fields of a any Object
 */
global class S2SDynamicOwnerIDUpdate implements Database.Batchable<sObject>{
    global String objectApiName;
    global String sourceOwnerID;
    global S2SDynamicOwnerIDUpdate(String ObjName, String SourceOwnerIDFieldName){
        objectApiName = ObjName;
        sourceOwnerID = SourceOwnerIDFieldName;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,'+sourceOwnerID+',OwnerId FROM '+objectApiName + ' WHERE '+ sourceOwnerID +' != null');
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String,Id> mapUserIds = new Map<String,Id>();
        Map<String,Id> mapQueue = new Map<String,Id>();
        List<String> listOldEmailId = new List<String>();
        Set<String> setQueueNames = new Set<String>();
        
        for(sObject obj : scope){
           String srcOwnerId = (String)obj.get(sourceOwnerID);
           if((srcOwnerId ).contains('@')){
                listOldEmailId.add(srcOwnerId );
            }else{
                setQueueNames.add(srcOwnerId );
            } 
        }
        mapUserIds = S2SPartnerNetworkRecordUtility.getUsers(listOldEmailId);

        if(!setQueueNames.isEmpty()){
            for(Group obj : [SELECT Id,Type,Name FROM Group WHERE Type = 'Queue' AND Name IN : setQueueNames]){
                mapQueue.put(obj.Name,Obj.Id);
            }
        }

        for(sObject obj : scope){
            String srcOwnerId = (String)obj.get(sourceOwnerID);
            if(mapUserIds.containsKey(srcOwnerId))
                obj.put('OwnerId',mapUserIds.get(srcOwnerId));
            if(mapQueue.containsKey(srcOwnerId))
                obj.put('OwnerId',mapQueue.get(srcOwnerId));
        }
        Update scope;               
    }
    global void finish(Database.BatchableContext BC){
    
    }
}