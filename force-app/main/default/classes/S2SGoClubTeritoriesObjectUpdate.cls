/*
@Company:Infoglen
@Author:Imran
@Creation date:09/01/2018
Reference:
*/
/**
 * Class S2SGoClubTeritoriesObjectUpdate
 *
 * This batch class is used to update GO Club Territories object lookup fields 
 */
global class S2SGoClubTeritoriesObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_GO_Club_Outreach_Specialist__c,GO_Club_Outreach_Specialist__c FROM GO_Club_Territories__c WHERE Source_GO_Club_Outreach_Specialist__c != null');
    }
    global void execute(Database.BatchableContext BC, List<GO_Club_Territories__c>scope){
        List<String> listoldEmailIds = new List<String>();
        for(GO_Club_Territories__c obj : scope){                      
            listoldEmailIds.add(obj.Source_GO_Club_Outreach_Specialist__c);    
        }              
        Map<String,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getUsers(listoldEmailIds);       
        List<GO_Club_Territories__c> listCon = new List<GO_Club_Territories__c>();
        
        for(GO_Club_Territories__c obj : scope){       
                obj.GO_Club_Outreach_Specialist__c = mapWithNewOldId.containsKey(obj.Source_GO_Club_Outreach_Specialist__c)?mapWithNewOldId.get(obj.Source_GO_Club_Outreach_Specialist__c):null;
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}