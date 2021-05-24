/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SLeaderInformationbjectUpdate
 
 * This batch class is used to update all lookup fields of a Leader Information Object
 */
global class S2SLeaderInformationbjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Account_Rec_Id__c,Source_Contact_Rec_Id__c,Source_SFDC_User_ID__c,Source_SFDC_User_Record__c,SFDC_User_ID__c,SFDC_User_Record__c,StandardContact__c,Account__c FROM CP_Contact__c WHERE Source_Rec_Id__c != null');
    }
    global void execute(Database.BatchableContext BC, List<CP_Contact__c>scope){
        List<String> listoldId = new List<String>();
        List<String> listOldEmailId = new List<String>();
        for(CP_Contact__c obj : scope){                      
            listoldId.add(obj.Source_Account_Rec_Id__c);
            listoldId.add(obj.Source_Contact_Rec_Id__c);
            listOldEmailId.add(obj.Source_SFDC_User_ID__c);
            listOldEmailId.add(obj.Source_SFDC_User_Record__c);
        }   
        Map<String,Id> mapNewUserId = S2SPartnerNetworkRecordUtility.getUsers(listOldEmailId);
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);   
        
        List<CP_Contact__c> listCon = new List<CP_Contact__c>();
        
        for(CP_Contact__c obj : scope){       
            
            obj.Account__c = mapWithNewOldId.containsKey(obj.Source_Account_Rec_Id__c)?mapWithNewOldId.get(obj.Source_Account_Rec_Id__c):null;
       
            obj.StandardContact__c = mapWithNewOldId.containsKey(obj.Source_Contact_Rec_Id__c)?mapWithNewOldId.get(obj.Source_Contact_Rec_Id__c):null;
        
            obj.SFDC_User_ID__c = mapNewUserId.containsKey(obj.Source_SFDC_User_ID__c)?mapWithNewOldId.get(obj.Source_SFDC_User_ID__c):null;
        
            obj.SFDC_User_Record__c = mapNewUserId.containsKey(obj.Source_SFDC_User_Record__c)?mapWithNewOldId.get(obj.Source_SFDC_User_Record__c):null;
                
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}