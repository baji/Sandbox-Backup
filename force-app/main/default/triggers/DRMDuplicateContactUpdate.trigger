/*
 * Purpose : This trigger handles the scenario for RE to SFDC data migration. This code will particulary handle the update scenarios of duplicate data upload.
 * Developed By : Mayur Soni(mayur@infoglen.com)
 * Created on : 17-Apr-2018
*/
trigger DRMDuplicateContactUpdate on Contact (before update) {
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunContactTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        Set<Id> accId  = new Set<Id>();
        Id individualRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Id HHRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Map<Id,List<Contact>> accVsContactMap = new Map<Id,List<Contact>>(); //this will store account whose record type is not individual
        Map<String,Contact> accIdConIdVsContact = new Map<String,Contact>();
        Set<Id> otherConIds = new Set<Id>();
        Awana_Settings__c myCS1 = Awana_Settings__c.getValues('DRMDuplicateContactUpdate');
        if(myCS1 != null && Boolean.valueOf(myCS1.value__c)){
            if (checkRecursive.runOnceDuplicateContact()) { //to check for recursive
                System.debug('Inside duplicate trigger');
                for(Contact con : trigger.new){
                    Contact oldCon = trigger.oldMap.get(con.id);
                    if(String.isNotBlank(con.RE_Constit_Rec_Id__c) && String.isBlank(oldCon.RE_Constit_Rec_Id__c)){
                        if(con.AccountId != null)
                            accId.add(con.AccountId);
    
                        //for the following fields if RE has blank value use SF value
                        if(String.isBlank(con.FirstName))
                            con.firstName = oldCon.FirstName;
                        if(String.isBlank(con.LastName))
                            con.LastName = oldCon.LastName;
                        if(String.isBlank(con.MiddleName))
                            con.MiddleName = oldCon.MiddleName;
                        if(String.isBlank(con.Suffix))
                            con.Suffix = oldCon.Suffix;
                        if(String.isBlank(con.Title))
                            con.Title = oldCon.Title;
                        if(String.isBlank(con.Email))
                            con.Email = oldCon.Email;
                        if(String.isBlank(con.Phone))
                            con.Phone = oldCon.Phone;
                        
                    }else{
                        //RE records are itself duplicate, so if coming record is already been updated, check RE_Date_Last_Changed__c value, if coming record has latest date then let it update else give error
                        if(String.isNotBlank(con.RE_Constit_Rec_Id__c) && String.isNotBlank(oldCon.RE_Constit_Rec_Id__c) && con.RE_Date_Last_Changed__c!=null && oldCon.RE_Date_Last_Changed__c!=null){
                            if(con.RE_Date_Last_Changed__c < oldCon.RE_Date_Last_Changed__c){
                                con.addError('RE Contact already updated with RE Record Id : '+oldCon.RE_Constit_Rec_Id__c +' and Constituent Id :'+oldCon.Constituent_Id__c);
                            }else if(con.RE_Date_Last_Changed__c == oldCon.RE_Date_Last_Changed__c){
                                if(con.Constituent_Id__c == null){
                                    con.addError('RE Contact already updated with Constituent Id having RE Record Id : '+oldCon.RE_Constit_Rec_Id__c +' and Constituent Id :'+oldCon.Constituent_Id__c);
                                }
                            }
                        }
                        
                    }
                    
                }
                if(!accId.isEmpty()){
                    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,RecordTypeId,RecordType.name FROM Account WHERE Id IN :accId]);
                    List<Account> individualAccToUpdate = new List<Account>();
                    Set<Id> otherAcccountIds = new Set<Id>();
                    if(!accountMap.isEmpty()){
                        for(Account acc : accountMap.values()){
                            if(acc.RecordTypeId == individualRecTypeId){ //if Account is Individual change the type to HoueseHold
                                acc.RecordTypeId = HHRecTypeId;
                                individualAccToUpdate.add(acc);
                            }else{
                                otherAcccountIds.add(acc.Id);
                            }
                        }
                        if(!individualAccToUpdate.isEmpty()) //update individual list
                            update individualAccToUpdate;
                        
                        if(!otherAcccountIds.isEmpty()){
                            //if other then individual, create new HH and set as AccountId of contact and create affiliation with existing account
                            for(Contact con : trigger.new){
                                if(con.AccountId != null){
                                    if(!accVsContactMap.containsKey(con.AccountId))
                                        accVsContactMap.put(con.AccountId,new List<Contact>());
                                    accVsContactMap.get(con.AccountId).add(con);
                                    String key = con.AccountId +'#'+ con.id;
                                    accIdConIdVsContact.put(key,con);
                                    otherConIds.add(con.id);
                                }
                            }
                            //System.debug('Other Con Id : '+otherConIds);
                            //System.debug('accVsContactMap : '+accVsContactMap);
                            if(!otherConIds.isEmpty() && !accVsContactMap.isEmpty()){
                                //Affiliation insert code starts
                                //below code from triggers gives the SELF_REFERENCE_FROM_TRIGGER
                                DRMDuplicateUtil.createAffiliations(otherConIds,accVsContactMap.keySet(),accIdConIdVsContact.keySet());
                                /*Map<string,Contact> copyContactMap = accIdConIdVsContact.deepClone();
                                List<npe5__Affiliation__c> affiliations = [SELECT Id,npe5__Organization__c,npe5__Contact__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : otherConIds and npe5__Organization__c IN:accVsContactMap.keySet()];
                                if(!affiliations.isEmpty()){
                                    for(npe5__Affiliation__c aff : affiliations){
                                        String key = aff.npe5__Organization__c + '#'+aff.npe5__Contact__c;
                                        if(copyContactMap.containsKey(key)){
                                            copyContactMap.remove(key); //if affiliation exist remove from map
                                        }
                                    }
                                    
                                    if(!copyContactMap.isEmpty()){// if map contains values then affiliations are not there, create new
                                        List<npe5__Affiliation__c> affiliationsToInsert = new List<npe5__Affiliation__c>();
                                        for(String key : copyContactMap.keySet()){
                                            Contact con = copyContactMap.get(key);
                                            //TO DO : other fields to add in affiliation
                                            npe5__Affiliation__c aff = new npe5__Affiliation__c();
                                            aff.npe5__Contact__c = con.id;
                                            aff.npe5__Organization__c = con.AccountId;
                                            affiliationsToInsert.add(aff);
                                        }
                                        if(!affiliationsToInsert.isEmpty())
                                            insert affiliationsToInsert;
                                    }
                                }else{//if no affiliations found create new
                                    if(!copyContactMap.isEmpty()){// if map contains values then affiliations are not there, create new
                                        List<npe5__Affiliation__c> affiliationsToInsert = new List<npe5__Affiliation__c>();
                                        for(String key : copyContactMap.keySet()){
                                            Contact con = copyContactMap.get(key);
                                            //TO DO : other fields to add in affiliation
                                            npe5__Affiliation__c aff = new npe5__Affiliation__c();
                                            aff.npe5__Contact__c = con.id;
                                            aff.npe5__Organization__c = con.AccountId;
                                            affiliationsToInsert.add(aff);
                                        }
                                        if(!affiliationsToInsert.isEmpty())
                                            insert affiliationsToInsert;
                                    }
                                }*/ //Affiliation insert code ends
                                //HH Account creation code starts
                                if(!otherConIds.isEmpty()){
                                    List<Account> hhAccountToInsert = new List<Account>();
                                    Map<Integer,Contact> contactToUpdateMap = new Map<Integer,Contact>();
                                    Integer count=0;
                                    for(Contact con : trigger.new){
                                        if(otherConIds.contains(con.Id)){
                                            Account acc = new Account();
                                            acc.Name = con.firstName+con.lastname+' HouseHold';
                                            acc.RecordTypeId = HHRecTypeId;
                                            acc.npe01__One2OneContact__c = con.id;
                                            hhAccountToInsert.add(acc);
                                            contactToUpdateMap.put(count,con);
                                            count++;
                                        }
                                    }
                                    if(!hhAccountToInsert.isEmpty()){
                                        insert hhAccountToInsert;
                                        for(Integer i = 0;i<contactToUpdateMap.keySet().size();i++){
                                            contactToUpdateMap.get(i).AccountId = hhAccountToInsert.get(i).id;
                                        }
                                        
                                    }
    
                                }
    
                            }
                            
                        }
                    }
                }
            }
        }
    
    }
}