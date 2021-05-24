/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Project:    Salesforce SSO
    Original:   5/16/2014  - Dispatcher that processes contacts after insertion 
                a) Convert Leads button is click within contact , a 1x1 Account is created for that newly inserted contact
 ***********************************************************************************************************************************************/

trigger ContactAfterInsert on Contact (before insert, after insert) {
Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunContactTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        List<String> newContactIds= new List<String>();
        List<Contact> conList = new List<Contact>();
        for(Contact c : trigger.new){
        //1. We need to pass the IDs in as a string to the Future handler method to allow for ...
        // ... aynschronous processing otherwise a race condition will result between contact processing and the conversion for Lead
            if(c.LeadSource !=null && c.LeadSource !=''){
                newContactIds.add(c.Id);
            }
            
        }
        if(Trigger.isBefore){
            for(Contact c : trigger.new){
                system.debug('************'+c.Constituent_Id__c);
                if(c.Constituent_Id__c == null || c.Constituent_Id__c == ''){
                    conList.add(c);
                }
            }
        }
        if(newContactIds.size() > 0){
            InsertOne2OneAccountMgr.handler(newContactIds);
        }
        if(conList.size() > 0){
            ConstituentIDContactNew.contactInsert(conList);
        }
    }
}