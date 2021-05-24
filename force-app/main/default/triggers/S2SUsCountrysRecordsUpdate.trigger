/*
@Company:Infoglen
@Author:Imran Shaik
@Creation date:30/11/2017
Reference:
*/
/**
 * Trigger S2SUsCountrysRecordsUpdate
 *
 * This trigger is used to update old users lookup id's with new user id's
 */
trigger S2SUsCountrysRecordsUpdate on US_Counties__c(Before Insert){
    List<String> listEmailFields = new List<String>();  
    for(US_Counties__c obj : trigger.new){
        listEmailFields.add(obj.Source_Field_Director_Email__c);
        listEmailFields.add(obj.Source_Primary_Missionary_Email__c);
        listEmailFields.add(obj.Source_Work_Group_Lead_Email__c);
    }
    Map<String,Id> mapUserIds = S2SPartnerNetworkRecordUtility.getUsers(listEmailFields);
    for(US_Counties__c obj : trigger.new){
        if(mapUserIds.containsKey(obj.Source_Field_Director_Email__c))
            obj.Field_Director__c = mapUserIds.get(obj.Source_Field_Director_Email__c);
        if(mapUserIds.containsKey(obj.Source_Primary_Missionary_Email__c))
            obj.Primary_Missionary__c = mapUserIds.get(obj.Source_Primary_Missionary_Email__c);
        if(mapUserIds.containsKey(obj.Source_Work_Group_Lead_Email__c))
            obj.Work_Group_Leader__c = mapUserIds.get(obj.Source_Work_Group_Lead_Email__c);
    }
}