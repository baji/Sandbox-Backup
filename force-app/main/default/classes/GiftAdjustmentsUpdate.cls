/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    03/16/2018 - Track down the opportunity changes in the Gift Adjustment Object
***************************************************************************************************************************************************************************************************************************************** **************/

public class GiftAdjustmentsUpdate {
    public static void UpdateOpportunityChanges(List<Opportunity> opptyIdList,Map<Id,opportunity> oppMap) {
        List<Gift_Adjustments__c> giftList = new List<Gift_Adjustments__c>();
        for(Opportunity op:opptyIdList){
            Gift_Adjustments__c gf = new Gift_Adjustments__c();
            gf.Batch_No__c = op.Tech_Batch_No__c;
            gf.Current_Amount__c = op.amount;
            gf.Previous_Amount__c = oppMap.get(op.id).amount;
            gf.Opportunity__c = op.id;
            giftList.add(gf);
        }
        try{
            Database.insert(giftList,false);
            system.debug('&&'+giftList);
        }
        catch(Exception e){
            
        }
    }
    
}