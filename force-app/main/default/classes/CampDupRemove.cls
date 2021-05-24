/************************************************************************************************************************************************************
Programmer: Imran Shaik
Company:    Awana
Project:    Donation management
Original:   17/04/2018  - CampaignMember Duplication Remove 
*************************************************************************************************************************************************************/
global class CampDupRemove{
    
    global CampDupRemove(ApexPages.StandardController controller) {
      
    }
    
    //This method is used to call from javascript button 
    webservice static void duplicateRemove(String parentRecId){
        for(Campaign obj : [SELECT Id,Name,Segment_Priority__c,ParentId FROM Campaign WHERE ParentId=:parentRecId Order By Segment_Priority__c ASC LIMIT 1]){
            CampDupRemoveBatch cmp = new CampDupRemoveBatch(obj.ParentId,obj.Id,[SELECT Id FROM Campaign WHERE ParentId=:parentRecId AND Id !=:obj.Id Order By Segment_Priority__c ASC LIMIT 1].Id);
                Database.ExecuteBatch(cmp,2000);
        }
    }
    //This method call from lightning vf page 
    public static PageReference removeDuplicate(){
        String parentRecId = apexpages.currentpage().getparameters().get('id');
        if(parentRecId != null){
            for(Campaign obj : [SELECT Id,Name,Segment_Priority__c,ParentId FROM Campaign WHERE ParentId=:parentRecId Order By Segment_Priority__c ASC LIMIT 1]){
                CampDupRemoveBatch cmp = new CampDupRemoveBatch(obj.ParentId,obj.Id,[SELECT Id FROM Campaign WHERE ParentId=:parentRecId AND Id !=:obj.Id Order By Segment_Priority__c ASC LIMIT 1].Id);
                    Database.ExecuteBatch(cmp,2000);
            }
        }
        Campaign cmp = new Campaign();
        PageReference campaignPage = new ApexPages.StandardController(cmp).view();
        campaignPage.setRedirect(true);
        return campaignPage;        
    }   
}