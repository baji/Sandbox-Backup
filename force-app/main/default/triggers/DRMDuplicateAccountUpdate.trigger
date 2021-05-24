/*
 * Purpose : This trigger handles the scenario for RE to SFDC data migration. This code will particulary handle the update scenarios of duplicate data upload.
 * Developed By : Mayur Soni(mayur@infoglen.com)
 * Created on : 20-Apr-2018
*/
trigger DRMDuplicateAccountUpdate on Account (before update) {

    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){
        Id orgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
    
        Awana_Settings__c myCS1 = Awana_Settings__c.getValues('DRMDuplicateAccountUpdate');
        if(myCS1 != null && Boolean.valueOf(myCS1.value__c)){
            if (checkRecursive.runOnceDuplicateAccount()) { //to check for recursive
                for(Account acc : trigger.new){
                    Account oldAcc = trigger.oldMap.get(acc.id);
                    system.debug('<<OLD REG_LEVEL>> '+oldAcc.Registration_Level__c);
                    system.debug('<< NEW REG LEVEL>>> '+acc.Registration_Level__c);
                    System.debug('oldAcc.RE_Constit_Rec_Id__c :'+oldAcc.RE_Constit_Rec_Id__c);
                    System.debug('acc.RE_Constit_Rec_Id__c :'+acc.RE_Constit_Rec_Id__c);
                    
                    if(String.isBlank(oldAcc.RE_Constit_Rec_Id__c) && String.isNotBlank(acc.RE_Constit_Rec_Id__c) && acc.RecordTypeId==orgRecTypeId){
                        if(String.isNotBlank(acc.Type) && !acc.Type.equalsIgnoreCase('Church')){
                            //If not church RE is master. However, if RE value blank use SFDC one
                            //if(String.isBlank(acc.Name))
                             //   acc.Name = oldAcc.Name;
                            if(acc.NumberOfEmployees == null)
                                acc.NumberOfEmployees = oldAcc.NumberOfEmployees;
                            if(acc.Phone == null)
                                acc.Phone = oldAcc.Phone;
                        }
                    }else{
                        //RE records are itself duplicate, so if coming record is already been updated, check RE_Date_Last_Changed__c value, if coming record has latest date then let it update else give error
                        if(String.isNotBlank(acc.RE_Constit_Rec_Id__c) && String.isNotBlank(oldAcc.RE_Constit_Rec_Id__c) && acc.RE_Date_Last_Changed__c!=null && oldAcc.RE_Date_Last_Changed__c!=null){
                            if(acc.RE_Date_Last_Changed__c < oldAcc.RE_Date_Last_Changed__c){
                                acc.addError('RE Account already updated with RE Record Id : '+oldAcc.RE_Constit_Rec_Id__c +' and Constituent Id :'+oldAcc.Constituent_Id__c);
                            }else if(acc.RE_Date_Last_Changed__c == oldAcc.RE_Date_Last_Changed__c){
                                if(acc.Constituent_Id__c == null){
                                    acc.addError('RE Account already updated with Constituent Id having RE Record Id : '+oldAcc.RE_Constit_Rec_Id__c +' and Constituent Id :'+oldAcc.Constituent_Id__c);
                                }
                            }
                        }
                     }      
                }
            }
        }
    }
}