/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    03/19/2018 - <CRM - 130> Campaign trigger handler class
***************************************************************************************************************************************************************************************************************************************** **************/

public class CampaginTriggerHandler{

    //bfi = before insert
    public static void bfiPriorityValidate(List<Campaign> listNewCamp){      
       List<String> listPriority = new List<String>();
       List<String> listParentID = new List<String>();
       Id segRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Segment').getRecordTypeId();
       for(Campaign obj : listNewCamp){
           if(obj.ParentId != null && obj.Segment_Priority__c != null){
               listParentID.add(obj.ParentId);
               listPriority.add(obj.Segment_Priority__c); 
           }else if(obj.ParentId != null && obj.Segment_Priority__c == null && obj.RecordTypeId == segRecordTypeId){
                (obj.Segment_Priority__c).addError('Seggment priority is required');
           }
            
        }
        if(!listPriority.isEmpty()){
            List<Campaign> listCamp = [SELECT Id,ParentId,Segment_Priority__c FROM Campaign WHERE ParentId IN : listParentID AND Segment_Priority__c IN : listPriority];
            if(!listCamp.isEmpty())
            listNewCamp[0].Segment_Priority__c.addError('Duplicate priority under parent campaign');
        }
       
    }
    
    public static void bfuPriorityValidate(List<Campaign> listNewCamp,List<Campaign> listOldCamp,Map<Id,Campaign> mapNewCamp,Map<Id,Campaign> mapOldCamp){
            List<String> listPriority = new List<String>();
            List<String> listParentId = new List<String>();
            for(Campaign obj : listNewCamp){
                if(obj.ParentId != null && obj.Segment_Priority__c != null && mapOldCamp.get(obj.Id).Segment_Priority__c != obj.Segment_Priority__c &&  mapOldCamp.get(obj.Id).ParentId == obj.ParentId){
                    listParentId.add(obj.ParentId);
                    listPriority.add(obj.Segment_Priority__c);
                }else if(obj.ParentId != null && obj.Segment_Priority__c != null && mapOldCamp.get(obj.Id).Segment_Priority__c == obj.Segment_Priority__c && mapOldCamp.get(obj.Id).ParentId != obj.ParentId){
                    listParentId.add(obj.ParentId);
                    listPriority.add(obj.Segment_Priority__c);
                }else if(obj.ParentId != null && obj.Segment_Priority__c != null && mapOldCamp.get(obj.Id).Segment_Priority__c != obj.Segment_Priority__c && mapOldCamp.get(obj.Id).ParentId != obj.ParentId){
                    listParentId.add(obj.ParentId);
                    listPriority.add(obj.Segment_Priority__c);
                }
                    
            }
            if(!listPriority.isEmpty()){
                List<Campaign> listDuplicateCamp = [SELECT Id,Segment_Priority__c,ParentId FROM Campaign WHERE ParentId IN : listParentId AND Segment_Priority__c IN : listPriority AND Id Not IN : listNewCamp];
                if(!listDuplicateCamp.isEmpty())
                    listNewCamp[0].Segment_Priority__c.addError('Duplicate priority under parent campaign');
            }           
    }
}