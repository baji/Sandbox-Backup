/*
 * Trigger name : updateDebitAccountOnOpportunity
 * Developed by : Mayur Soni(mayur@infoglen.com)
 * Usage        : If donation opportunity is inserted/updated with Gift type and Subtype value, fetch the related Debit Account Number from GL_Debit_Account_Detail__c object and update it to GL_Debit_Account_Number__c field of opportunity
 * Date created : 14-Feb-2018
 * Company      : Infoglen
*/

trigger updateDebitAccountOnOpportunity on Opportunity (before insert,before update) {
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunOpportunityTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        Set<String> giftType = new Set<String>();
        Set<String> giftSubType = new Set<String>();
        
        //TO-DO : add DRM related record type id
        Set<String> donationRecTypeName = new Set<String>{'Donation','Matching Gift'};
        Set<Id> donationRecTypeId = new Set<Id>();
        for(String str : donationRecTypeName){
            donationRecTypeId.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
        }
        //Id donationRecordTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        //Id donationRecordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Matching Gift').getRecordTypeId();
        if(Trigger.isInsert){
            for(Opportunity opp : Trigger.new){
                if(donationRecTypeId.contains(opp.RecordTypeId)){ // == donationRecordTypeId
                    if(String.isNotEmpty(opp.Gift_Type__c) && String.isNotEmpty(opp.Gift_SubType__c)){
                        giftType.add(opp.Gift_Type__c);
                        giftSubType.add(opp.Gift_SubType__c);
                    }
                }
            }
        }
        if(Trigger.isUpdate){
            for(Opportunity opp : Trigger.new){
                if(donationRecTypeId.contains(opp.RecordTypeId)){ //opp.RecordTypeId == donationRecordTypeId
                    //check if gift type and sub type is not empty
                    if(String.isNotEmpty(opp.Gift_Type__c) && String.isNotEmpty(opp.Gift_SubType__c)){
                        //check if gift type and sub type is changed from old value
                        if(opp.Gift_Type__c != Trigger.oldMap.get(opp.Id).Gift_Type__c)
                            giftType.add(opp.Gift_Type__c);
                        if(opp.Gift_SubType__c != Trigger.oldMap.get(opp.Id).Gift_SubType__c)
                            giftSubType.add(opp.Gift_SubType__c);
                    }
                }
            }
            
        }
        //if the gift type or sub type is available fetch Debit Account number
        if(!giftType.isEmpty() || !giftSubType.isEmpty()){
            List<GL_Debit_Account_Detail__c> debitAccountList = [SELECT Id,Gift_type__c,Gift_sub_type__c,Debit_Account_Number__c FROM GL_Debit_Account_Detail__c WHERE Gift_type__c IN :giftType OR Gift_Sub_type__c IN :giftSubType];
            if(!debitAccountList.isEmpty()){
                Map<String,String> typeOfGiftVsDebitAccountMap = new Map<String,String>();
                for(GL_Debit_Account_Detail__c glDebit : debitAccountList){
                    if(String.isNotEmpty(glDebit.Gift_Type__c) && String.isNotEmpty(glDebit.Gift_Sub_type__c)){
                        String key = glDebit.Gift_Type__c + glDebit.Gift_Sub_type__c;
                        typeOfGiftVsDebitAccountMap.put(key,glDebit.Debit_Account_Number__c);
                    }
                }//End For
                
                if(!typeOfGiftVsDebitAccountMap.isEmpty()){
                    //update Debit Account Number on Opportunity
                    for(Opportunity opp : Trigger.new){
                        if(donationRecTypeId.contains(opp.RecordTypeId)){ //opp.RecordTypeId == donationRecordTypeId
                            if(String.isNotEmpty(opp.Gift_Type__c) && String.isNotEmpty(opp.Gift_SubType__c)){
                                String key = opp.Gift_Type__c + opp.Gift_SubType__c;
                                if(typeOfGiftVsDebitAccountMap.containsKey(key))
                                    opp.GL_Debit_Account_Number__c = typeOfGiftVsDebitAccountMap.get(key);
                            }
                        }
                    }//End For
                }//End If
                
            }
        }
    }
}