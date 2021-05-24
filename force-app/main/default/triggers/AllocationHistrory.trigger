/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    03/19/2018 - <CRM - 130> GAU Allocation trigger to store history in GAU Allocation Adjustment  
***************************************************************************************************************************************************************************************************************************************** **************/
trigger AllocationHistrory on npsp__Allocation__c(After Insert,After Update){
    List<GAU_Allocation_Adjustment__c> litsAllocations = new List<GAU_Allocation_Adjustment__c>();  
    if(trigger.isAfter && trigger.isUpdate){
        for(npsp__Allocation__c obj : trigger.new){
            if((trigger.oldMap.get(obj.Id).npsp__Amount__c != obj.npsp__Amount__c || trigger.oldMap.get(obj.Id).npsp__Percent__c != obj.npsp__Percent__c) && obj.OpportunityPostedDate__c != null){
                GAU_Allocation_Adjustment__c gaa = new GAU_Allocation_Adjustment__c();
                    gaa.Amount__c = obj.npsp__Amount__c;
                    gaa.Credit_Account_Number__c = obj.Credit_Account_Number__c;
                    gaa.GAU_Allocation__c = obj.Id;
                    gaa.Opportunity__c = obj.npsp__Opportunity__c;
                    gaa.OppId__c = obj.Id;
                    gaa.Previous_Amount__c = trigger.oldMap.get(obj.Id).npsp__Amount__c;
                litsAllocations.add(gaa);           
            }
        }
    }
    if(trigger.isAfter && trigger.isInsert){
        for(npsp__Allocation__c obj : trigger.new){
            if(obj.OpportunityPostedDate__c != null){
                GAU_Allocation_Adjustment__c gaa = new GAU_Allocation_Adjustment__c();
                    gaa.Amount__c = obj.npsp__Amount__c;
                    gaa.Credit_Account_Number__c = obj.Credit_Account_Number__c;
                    gaa.GAU_Allocation__c = obj.Id;
                    gaa.Opportunity__c = obj.npsp__Opportunity__c;
                    gaa.OppId__c = obj.Id;
                    //gaa.Previous_Amount__c = obj.npsp__Amount__c;
                litsAllocations.add(gaa);           
            }
        }
    }
    if(!litsAllocations.isEmpty())
            //upsert litsAllocations OppId__c;
            upsert litsAllocations;
}