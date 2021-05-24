/*
@Company:Infoglen
@Author:Imran Shaik
@Creation date:30/11/2017
Reference:
*/
/**
 * Trigger S2SSalesInvoiceItemRecordsUpdate
 *
 * This trigger is used to update sales invoice item record opportunity id with order id
 */
trigger S2SSalesInvoiceItemRecordsUpdate on Sales_Invoice_Item__c(Before Insert){
    
    List<Id> listOldtOppId = new List<Id>();
    Map<Id,Id> mapWithOppOrderIds = new Map<Id,Id>();
    
    for(Sales_Invoice_Item__c obj : trigger.new){
        listOldtOppId.add(obj.Source_Opportunity_Id__c);
    }
    for(Order obj : [SELECT Id,Source_Opportunity_Id__c FROM Order WHERE Source_Opportunity_Id__c IN:listOldtOppId]){
        mapWithOppOrderIds.put(obj.Source_Opportunity_Id__c,obj.Id);
    }
    
    for(Sales_Invoice_Item__c obj : trigger.new){
        if(mapWithOppOrderIds.containsKey(obj.Source_Opportunity_Id__c))
        obj.Order__c = mapWithOppOrderIds.get(obj.Source_Opportunity_Id__c);
    }
}