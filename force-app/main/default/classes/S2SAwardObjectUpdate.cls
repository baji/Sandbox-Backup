/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SAwardObjectUpdate
 *
 * This batch class is used to update Award object lookup fields 
 */
global class S2SAwardObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Contact_Id__c,AwardRecipient__c,Source_Award_Rec_Id__c FROM Award__c WHERE Source_Contact_Id__c != null');
    }
    global void execute(Database.BatchableContext BC, List<Award__c>scope){
        List<String> listoldId = new List<String>();
        for(Award__c obj : scope){                      
            listoldId.add(obj.Source_Contact_Id__c);    
        }              
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);       
        List<Award__c> listCon = new List<Award__c>();
        
        for(Award__c obj : scope){       
                obj.AwardRecipient__c = mapWithNewOldId.containsKey(obj.Source_Contact_Id__c)?mapWithNewOldId.get(obj.Source_Contact_Id__c):null;
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}