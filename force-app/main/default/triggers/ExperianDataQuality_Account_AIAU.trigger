trigger ExperianDataQuality_Account_AIAU on Account (after insert, after update) {

    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c))
        EDQ.DataQualityService.ExecuteWebToObject(Trigger.New, 2, Trigger.IsUpdate);
}