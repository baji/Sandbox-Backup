trigger updateDonationCounter on Opportunity (after insert) {
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunOpportunityTrigger');       
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        Id oppId;
        Id oppConId;
        DateTime oppCreateDateTime;
        if(Trigger.isInsert){
             for(Opportunity opp : Trigger.new){
                 system.debug('Opportunity: '+opp);
                 system.debug('Opportunity: '+opp.npsp__Primary_Contact__c);
                     oppId = opp.Id;
                     oppConId = opp.npsp__Primary_Contact__c;
             }
             if(oppConId != null){
                DonationCounter.updateDonationCounter(oppId);
             }
        }
    }
}