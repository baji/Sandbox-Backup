/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Trigger S2SLeadRecordsUpdate
 *
 * This trigger is used to map record type of a record and owner of a record
 */
trigger S2SLeadRecordsUpdate on Lead(Before Insert){
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunLeadTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        Map<String,Id> mapRecType = new Map<String,Id>();
        Map<String,Id> mapUserIds = new Map<String,Id>();
        Map<String,Id> mapQueue = new Map<String,Id>();
        List<String> listEmailFields = new List<String>();
        Set<String> setQueueNames = new Set<String>();
        for(RecordType rt:[Select id,name,developerName From RecordType Where sObjectType = 'Lead']){
            mapRecType.put(rt.developerName,rt.Id);
        }
        
        for(Lead obj : trigger.new){    
            if(obj.Source_OwnerId__c != null){
                if((obj.Source_OwnerId__c).left(3) == '005')
                    listEmailFields.add(obj.Source_OwnerId__c);
                else
                    setQueueNames.add(obj.Source_OwnerId__c);           
            }       
        }   
        mapUserIds = S2SPartnerNetworkRecordUtility.getUsers(listEmailFields);
        if(!setQueueNames.isEmpty()){
            for(Group obj : [SELECT Id,Type,Name FROM Group WHERE Type = 'Queue' AND Name IN : setQueueNames]){
                mapQueue.put(obj.Name,obj.Id);
            }
        }
        for(Lead obj : trigger.new){
            if(mapRecType.containsKey(obj.Source_Record_Type_Name__c))
                obj.RecordTypeId = mapRecType.get(obj.Source_Record_Type_Name__c);
            if(mapUserIds.containsKey(obj.Source_OwnerId__c))
                obj.ownerId = mapUserIds.get(obj.Source_OwnerId__c);
            else if(mapQueue.containsKey(obj.Source_OwnerId__c))
                obj.ownerId = mapQueue.get(obj.Source_OwnerId__c);
            else 
                obj.ownerId = '005f4000000ZJhT';
        }
    }
}