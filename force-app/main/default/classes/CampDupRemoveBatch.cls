/************************************************************************************************************************************************************
Programmer: Imran Shaik
Company:    Awana
Project:    Donation management
Original:   17/04/2018  - CampaignMember Duplication Remove 
*************************************************************************************************************************************************************/
global class CampDupRemoveBatch implements Database.Batchable<sObject>,DataBase.stateful{
    global List<String> listCampId;
    global String priorityId;
    global String parentCampID;
    global String childRecIds;
    global List<String> completedCampId;
    global CampDupRemoveBatch(String parentCampID,String campIds,String priorityId){
        this.listCampId = campIds.split(',');
        this.priorityId = priorityId;
        this.childRecIds = campIds;
        this.parentCampID = parentCampID;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ContactId FROM CampaignMember WHERE CampaignId IN : listCampId]);
    }
    global void execute(Database.BatchableContext BC, List<CampaignMember>scope){
        List<Id> listRecId = new List<Id>();
        List<Id> listContactId = new List<Id>();
        for(CampaignMember obj : scope){
            listContactId.add(obj.ContactId);
        }
        for(CampaignMember obj : [SELECT Id FROM CampaignMember WHERE CampaignId=:priorityId AND ContactId IN : listContactId]){
            listRecId.add(obj.Id);
        }
        DataBase.Delete(listRecId,false);
    }
    global void finish(Database.BatchableContext BC){
        String recIds = childRecIds+','+priorityId;
        List<String> listRecID  = recIds.split(',');
        for(Campaign obj :[SELECT Id FROM Campaign WHERE ParentId=:parentCampID AND Id Not IN : listRecID Order By Segment_Priority__c ASC LIMIT 1]){
            CampDupRemoveBatch camp = new CampDupRemoveBatch(parentCampID,recIds,obj.Id);
            Database.ExecuteBatch(camp,2000);
        }
        
    }                          
}