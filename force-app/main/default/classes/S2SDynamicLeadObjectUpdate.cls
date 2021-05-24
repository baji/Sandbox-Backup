/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SDynamicLeadObjectUpdate
 
 * This batch class is used to update all lookup fields of a Lead Object
 */
global class S2SDynamicLeadObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Existing_Account__c,Source_Existing_Contact__c,Existing_Account__c,Existing_Contact__c FROM Lead WHERE Source_Inquiry_Rec_Id__c != null');
    }
    global void execute(Database.BatchableContext BC, List<Lead>scope){
        List<String> listoldId = new List<String>();
        for(Lead obj : scope){                      
            listoldId.add(obj.Source_Existing_Account__c);
            listoldId.add(obj.Source_Existing_Contact__c);          
        }
        
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);
        List<Lead> listCon = new List<Lead>();
        for(Lead obj : scope){
            obj.Existing_Account__c = mapWithNewOldId.containsKey(obj.Source_Existing_Account__c)?mapWithNewOldId.get(obj.Source_Existing_Account__c):null;
            obj.Existing_Contact__c = mapWithNewOldId.containsKey(obj.Source_Existing_Contact__c)?mapWithNewOldId.get(obj.Source_Existing_Contact__c):null;       
            listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}