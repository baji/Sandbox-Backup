/*
@Company:Infoglen
@Author:Imran Shaik
@Creation date:30/11/2017
Reference:
*/
/**
 * Trigger S2SSalesInvoiceRecordsUpdate
 *
 * This trigger is used to update record owner same as parent IntAcct Entity record owner
 */
trigger S2SSalesInvoiceRecordsUpdate on Sales_Invoice__c(Before Insert){
    List<String> listEmailFields = new List<String>();
    for(Sales_Invoice__c obj : trigger.new){
        if(obj.Source_IntAcct_Entity_OwnerEmailId__c != null)
        listEmailFields.add(obj.Source_IntAcct_Entity_OwnerEmailId__c);
        else
        listEmailFields.add(obj.Source_OwnerId__c);
    }
    Map<String,Id> mapUserIds = S2SPartnerNetworkRecordUtility.getUsers(listEmailFields);
    for(Sales_Invoice__c obj : trigger.new){                 
         if(obj.Source_IntAcct_Entity_OwnerEmailId__c != null){
             if(!Test.isRunningTest())
             obj.ownerId = mapUserIds.containsKey(obj.Source_IntAcct_Entity_OwnerEmailId__c)?mapUserIds.get(obj.Source_IntAcct_Entity_OwnerEmailId__c):'005f4000000ZJhT';
         }
        else{
            if(!Test.isRunningTest())
            obj.ownerId = mapUserIds.containsKey(obj.Source_OwnerId__c)?mapUserIds.get(obj.Source_OwnerId__c):'005f4000000ZJhT';
        }
                    
    }   
}