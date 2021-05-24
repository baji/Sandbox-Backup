trigger ExperianDataQuality_Account_BIBU on Account (before insert, before update) {
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');       
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c))
        EDQ.DataQualityService.SetValidationStatus(Trigger.new, Trigger.old, Trigger.IsInsert, 2);
}