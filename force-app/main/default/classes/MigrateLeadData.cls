global class MigrateLeadData{
    @InvocableMethod
    global static void updateContact(List<Id> accountId){    
    
        Lead ld = [SELECT Id,AcountID__c,ContactID__c,LeadSource FROM Lead WHERE AcountID__c IN :accountId Limit 1];
    
        if(ld.ContactID__c != null){
            
            Contact con = [SELECT Id,LeadSource FROM Contact WHERE Id=:ld.ContactID__c];
            
            if(Con != null){
                con.LeadSource = ld.LeadSource;            
                update con;
            }
        }   
    }   
}