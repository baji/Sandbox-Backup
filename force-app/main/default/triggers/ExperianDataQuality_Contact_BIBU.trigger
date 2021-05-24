trigger ExperianDataQuality_Contact_BIBU on Contact (before insert, before update) {
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunContactTrigger');   
    
   if (custmSetting != null && Boolean.valueOf(custmSetting.value__c))
       EDQ.DataQualityService.SetValidationStatus(Trigger.new, Trigger.old, Trigger.IsInsert, 2);
}