/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Trigger S2SAccountRecordMap
 *
 * This trigger is used to map record type of record and record owner
 */
trigger S2SAccountRecordMap on Account(Before Insert){
    Map<String,Id> mapRecType = new Map<String,Id>();
    List<String> listEmailFields = new List<String>();
    for(RecordType rt:[Select id,name,developerName From RecordType Where sObjectType = 'Account']){
        mapRecType.put(rt.developerName,rt.Id);
    }   
    for(Account obj : trigger.new){
        listEmailFields.add(obj.Source_Primary_Moves_Manager__c);
        listEmailFields.add(obj.Source_OwnerId__c);
    }
    Map<String,Id> mapUserIds = new Map<String,Id>();
    for(User obj : [SELECT Id,Source_User_Rec_Id_c__c FROM User WHERE Source_User_Rec_Id_c__c IN : listEmailFields AND IsActive=true]){
        mapUserIds.put(obj.Source_User_Rec_Id_c__c,Obj.Id);
    }
    for(Account obj : trigger.new){    
        if(mapRecType.containsKey(obj.Source_Record_Type_Name__c))
            obj.RecordTypeId = mapRecType.get(obj.Source_Record_Type_Name__c);
            if(!Test.isRunningTest())
            obj.ownerId = mapUserIds.containsKey(obj.Source_OwnerId__c)?mapUserIds.get(obj.Source_OwnerId__c):'005f4000000ZJhT';
        if(mapUserIds.containsKey(obj.Source_Primary_Moves_Manager__c))
            obj.Primary_Moves_Manager__c = mapUserIds.get(obj.Source_Primary_Moves_Manager__c);
    }
}