/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Trigger S2SContactRecordsUpdate
 *
 * This trigger is used to map old org record owner to new org record owner 
 */
trigger S2SContactRecordsUpdate on Contact(Before Insert){  
    List<String> listEmailFields = new List<String>();  
    for(Contact obj : trigger.new){
        listEmailFields.add(obj.Source_OwnerId__c);
    }
    Map<String,Id> mapUserIds = S2SPartnerNetworkRecordUtility.getUsers(listEmailFields);
    for(Contact obj : trigger.new){
        if(!Test.isRunningTest())
        obj.ownerId = mapUserIds.containsKey(obj.Source_OwnerId__c)?mapUserIds.get(obj.Source_OwnerId__c):'005f4000000ZJhT';       
    }
}