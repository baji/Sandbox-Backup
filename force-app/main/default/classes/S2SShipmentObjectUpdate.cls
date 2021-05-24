/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SShipmentObjectUpdate
 
 * This batch class is used to update all lookup fields of a Shipment Object
 */
global class S2SShipmentObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Shipment__c,Source_Shipment_Rec_Id__c FROM Pick_Ticket__c WHERE Source_Shipment_Rec_Id__c != null');
    }
    global void execute(Database.BatchableContext BC, List<Pick_Ticket__c>scope){
        List<String> listoldId = new List<String>();
        for(Pick_Ticket__c obj : scope){                      
            listoldId.add(obj.Source_Shipment_Rec_Id__c);    
        }              
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getShipment(listoldId);       
        List<Pick_Ticket__c> listCon = new List<Pick_Ticket__c>();
        
        for(Pick_Ticket__c obj : scope){       
            if(mapWithNewOldId.containsKey(obj.Source_Shipment_Rec_Id__c))
                obj.Shipment__c = mapWithNewOldId.get(obj.Source_Shipment_Rec_Id__c);
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}