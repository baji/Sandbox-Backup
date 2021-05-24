/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Trigger S2SOpportunityRecordMap
 *
 * This trigger is used to map record type of a record
 */
trigger S2SOpportunityRecordMap on Opportunity(Before Insert){
    Map<String,Id> mapRecType = new Map<String,Id>();
    List<String> ownerIdList = new List<String>();
    for(RecordType rt:[Select Id,Name,developerName From RecordType Where sObjectType = 'Opportunity']){
        mapRecType.put(rt.developerName,rt.Id);
    }
    for(Opportunity obj : trigger.new){
        ownerIdList.add(obj.Source_Owner_Email_Id__c);
    }
    Map<String,Id> mapUserId = S2SPartnerNetworkRecordUtility.getUsers(ownerIdList);    
    for(Opportunity obj : trigger.new){        
        if(mapRecType.containsKey(obj.Source_Record_Type_Name__c))
            obj.RecordTypeId = mapRecType.get(obj.Source_Record_Type_Name__c);
         if(!Test.isRunningTest())
        obj.ownerId = mapUserId.containsKey(obj.Source_Owner_Email_Id__c)?mapUserId.get(obj.Source_Owner_Email_Id__c):'005f4000000ZJhT';
    }
}