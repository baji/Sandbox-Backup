/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SDynamicSalesInvoiceObjectUpdate
 
 * This batch class is used to update all lookup fields of a Sales Invoice Object
 */
global class S2SDynamicSalesInvoiceObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Account_Id__c,Source_Opportunity_Id__c,Source_IntAcct_Entity_Id__c,Source_Parent_Entity_Id__c,Source_Sales_Invoice_Rec_Id__c ,Account__c,Intacct_Entity__c,Opportunity__c,Parent_Entity__c,Order__c FROM Sales_Invoice__c WHERE Source_Sales_Invoice_Rec_Id__c !=null');
    }
    global void execute(Database.BatchableContext BC, List<Sales_Invoice__c>scope){
        List<String> listoldId = new List<String>();
        List<String> listOppId = new List<String>();
        for(Sales_Invoice__c obj : scope){                      
            listoldId.add(obj.Source_Account_Id__c);    
            listOppId.add(obj.Source_Opportunity_Id__c);
            listoldId.add(obj.Source_Opportunity_Id__c);
            listoldId.add(obj.Source_Parent_Entity_Id__c);
            listoldId.add(obj.Source_IntAcct_Entity_Id__c);
        }
        Map<Id,Id> mapOrderOppId = S2SPartnerNetworkRecordUtility.getOrder(listOppId);
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);
        
        List<Sales_Invoice__c> listCon = new List<Sales_Invoice__c>();
        
        for(Sales_Invoice__c obj : scope){      
           
            obj.Account__c = mapWithNewOldId.containsKey(obj.Source_Account_Id__c)?mapWithNewOldId.get(obj.Source_Account_Id__c):null;
        
            obj.Opportunity__c = mapWithNewOldId.containsKey(obj.Source_Opportunity_Id__c)?mapWithNewOldId.get(obj.Source_Opportunity_Id__c):null;
       
            obj.Parent_Entity__c = mapWithNewOldId.containsKey(obj.Source_Parent_Entity_Id__c)?mapWithNewOldId.get(obj.Source_Parent_Entity_Id__c):null;
        
            obj.Intacct_Entity__c = mapWithNewOldId.containsKey(obj.Source_IntAcct_Entity_Id__c)?mapWithNewOldId.get(obj.Source_IntAcct_Entity_Id__c):null;
       
            obj.Order__c = mapOrderOppId.containsKey(obj.Source_Opportunity_Id__c)?mapOrderOppId.get(obj.Source_Opportunity_Id__c):null;
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}