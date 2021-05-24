/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SOpportunityObjectUpdate
 
 * This batch class is used to update all lookup fields of a Opportunity Object
 */
global class S2SOpportunityObjectUpdate implements Database.Batchable<sObject>{
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Source_Account_Id__c,Source_Billing_Address_Id__c,Source_Campaign_Id__c,Source_Country_Id__c,Source_Inquiry_Id__c,Source_Pricebook_Id__c,Source_Shipping_Address_Id__c,Source_Intacct_Entity_Id__c,Source_Project_Code__c,AccountId,Pricebook2Id,CampaignId,Billing_Address__c,Country__c,Inquiry_ID2__c,Intacct_Entity__c,Project_Code__c,Shipping_Address__c FROM Opportunity WHERE Source_Record_Id__c != null');
    }
    global void execute(Database.BatchableContext BC, List<Opportunity>scope){
        List<String> listOldCampId = new List<String>();
        List<String> listOldPriceBookId = new List<String>();
        List<String> listoldId = new List<String>();
        for(Opportunity obj : scope){                      
            listoldId.add(obj.Source_Account_Id__c);    
            listoldId.add(obj.Source_Billing_Address_Id__c);
            listOldCampId.add(obj.Source_Campaign_Id__c);
            listoldId.add(obj.Source_Country_Id__c);
            listOldPriceBookId.add(obj.Source_Pricebook_Id__c);
            listoldId.add(obj.Source_Shipping_Address_Id__c);
            listoldId.add(obj.Source_Intacct_Entity_Id__c);
            listoldId.add(obj.Source_Project_Code__c);
            listoldId.add(obj.Source_Inquiry_Id__c);
        }
        
        
        Map<Id,Id> mapWithNewOldId = S2SPartnerNetworkRecordUtility.getData(listoldId);
        Map<Id,Id> mapWithNewCampOldId = S2SPartnerNetworkRecordUtility.getCamp(listOldCampId);
        Map<Id,Id> mapWithNewPriceBookOldId = S2SPartnerNetworkRecordUtility.getPriceBook(listOldPriceBookId);
        
        List<Opportunity> listCon = new List<Opportunity>();
        
        for(Opportunity obj : scope){       
            if(mapWithNewOldId.containsKey(obj.Source_Account_Id__c))
                obj.AccountId = mapWithNewOldId.get(obj.Source_Account_Id__c);
            if(mapWithNewOldId.containsKey(obj.Source_Billing_Address_Id__c))
                obj.Billing_Address__c = mapWithNewOldId.get(obj.Source_Billing_Address_Id__c);
            if(mapWithNewCampOldId.containsKey(obj.Source_Campaign_Id__c))
                obj.CampaignId = mapWithNewCampOldId.get(obj.Source_Campaign_Id__c);
            if(mapWithNewOldId.containsKey(obj.Source_Country_Id__c))
                obj.Country__c = mapWithNewOldId.get(obj.Source_Country_Id__c);
            if(mapWithNewOldId.containsKey(obj.Source_Intacct_Entity_Id__c))
                obj.Intacct_Entity__c = mapWithNewOldId.get(obj.Source_Intacct_Entity_Id__c);
            if(mapWithNewPriceBookOldId.containsKey(obj.Source_Pricebook_Id__c))
                obj.Pricebook2Id = mapWithNewPriceBookOldId.get(obj.Source_Pricebook_Id__c);
            if(mapWithNewOldId.containsKey(obj.Source_Shipping_Address_Id__c))
                obj.Shipping_Address__c = mapWithNewOldId.get(obj.Source_Shipping_Address_Id__c);
            if(mapWithNewOldId.containsKey(obj.Source_Project_Code__c))
                obj.Project_Code__c = mapWithNewOldId.get(obj.Source_Project_Code__c);
            if(mapWithNewOldId.containsKey(obj.Source_Inquiry_Id__c))
                obj.Inquiry_ID2__c = mapWithNewOldId.get(obj.Source_Inquiry_Id__c);
          listCon.add(obj); 
        }       
        update listCon;                
    }
    global void finish(Database.BatchableContext BC){
    
    }
}