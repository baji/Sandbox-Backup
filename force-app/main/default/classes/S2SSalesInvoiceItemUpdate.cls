/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SSalesInvoiceItemUpdate
 *
 * This batch class is used to replace Opportunity to Order
 */
global class S2SSalesInvoiceItemUpdate implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Opportunity_Id__c,Order__c FROM Sales_Invoice_Item__c WHERE Source_Opportunity_Id__c!=null');
    }
    global void execute(Database.BatchableContext BC, List<Sales_Invoice_Item__c>scope){
        
        Map<Id,Id> mapOrder = new Map<Id,Id>();
        List<String> listOldOppId = new List<String>();
        List<Sales_Invoice_Item__c> listSalesInvoice = new List<Sales_Invoice_Item__c>();
        
        for(Sales_Invoice_Item__c obj : scope){
            listOldOppId.add(obj.Source_Opportunity_Id__c);
        }
        
        for(Order obj : [SELECT Id,Source_Opportunity_Id__c FROM Order WHERE Source_Opportunity_Id__c IN : listOldOppId]){
            mapOrder.put(obj.Source_Opportunity_Id__c,obj.Id);
        }
        
        
        for(Sales_Invoice_Item__c obj : scope){
            if(mapOrder.containsKey(obj.Source_Opportunity_Id__c))
                obj.Order__c = mapOrder.get(obj.Source_Opportunity_Id__c);
            listSalesInvoice.add(obj);
        }
        
        Update listSalesInvoice;
    }
    global void finish(Database.BatchableContext BC){
    
    }
}