/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SDynamicContactObjectUpdate
 *
 * This batch class is used to update all lookup fields of a Contact Object
 */
global class S2SDynamicContactObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Church_Rewards_Sponsored_Church__c,Source_AccountId__c,AccountId,Church_Rewards_Sponsored_Church__c FROM Contact WHERE Source_Contact_Rec_Id__c!=null');
    }
    global void execute(Database.BatchableContext BC, List<Contact>scope){
        List<String> listoldId = new List<String>();
        for(Contact obj : scope){           
            listoldId.add(obj.Source_Church_Rewards_Sponsored_Church__c);  
            listoldId.add(obj.Source_AccountId__c);
        }
        
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);
        List<Contact> listCon = new List<Contact>();
        for(Contact obj : scope){          
            obj.Church_Rewards_Sponsored_Church__c = mapWithNewOldId.containsKey(obj.Source_Church_Rewards_Sponsored_Church__c)?mapWithNewOldId.get(obj.Source_Church_Rewards_Sponsored_Church__c):null;
            obj.AccountId = mapWithNewOldId.containsKey(obj.Source_AccountId__c)?mapWithNewOldId.get(obj.Source_AccountId__c):null;
            listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}