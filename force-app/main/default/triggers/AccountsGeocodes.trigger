/***********************************************************************************************************************************************
    Programmer: Shaik A. Baji
    Updates: Tony WIlliams
    Company:    Awana
    Project:    Salesforce SSO
    Original:   5/11/2014 - Processes Geo Codes for  created or updated Accounts based on Physical Address changes.
    Updated:    02/10/2015 - Removed the Record Type check on US Organizations as we wish to also get geo codes for Canada/Int'l account's too. 
    Updated:    11/01/2018 -  <1400,1465> - Added additional IF  condition to make sure that County gets displayed by GeoLocationCallout.
    Updated:    11/21/2018 - <ASP-1509,1488> - Added checks to guard against exceptions if the currently executing code is invoked by Future/Batch code
 ***********************************************************************************************************************************************/

trigger AccountsGeocodes on Account (after insert, after update) {
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');       
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
    Boolean changed = false;
    //RecordType rec = [Select Id from RecordType where SObjectType = 'Account' AND ( Name  = 'US Organization' or Name = 'Canada Church') limit 1];
    Id usOrgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
    Id canadaRecTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canada Church').getRecordTypeId(); 
    //Modified by Shaik : added the trigger context Variables 
    List<String> accountIds = new List<String>();
    Integer extraAccts = 0; // Sequentially counts all of the inserted accounts for GeoCoding.
    Integer extraUpdatedAccts = 0;// Sequentially counts all of the updated accounts for GeoCoding.
    if (Trigger.isAfter) {// AFter All records saved
       if(Trigger.isInsert){
         if(!System.isFuture() && !System.isBatch()){  
         for (Account a : Trigger.new) {
            if(a.RecordTypeId == usOrgRecTypeId || a.RecordTypeId == canadaRecTypeId){
                extraAccts++;
                AccountHelper ah = new AccountHelper(a.Id);
                accountIds.add(JSON.serialize(ah));
            // TW: The following IF condition gets the even nnumber count of Ids on INSERT. This is neededdue to the @future call outs to Google. 
             
                if(math.mod(extraAccts,10 ) == 0)
                {   
                    system.debug('Even Number? : '+changed);  
                     if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                        GeoLocationCallouts.getLocation(accountIds);
                     }
                    accountIds.clear();
                }//batch ids
              
             }//recordType
          }//Loop
            
            if(math.mod(extraAccts ,10) != 0){ // get the remaining odd number of Geo Codes for the remaining accounts
                 system.debug('ODD Number? : '+changed); 
                if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                    GeoLocationCallouts.getLocation(accountIds);
                }
                 accountIds.clear();
            }//other than batch
         }// Is FUture or Batch?     
       }//isInsert
       
       if(Trigger.isUpdate){
          System.debug('Line no 44 in AccountsGeoCodes');
           //System.isfuture()' method  will return 'TRUE' if the currently executing code is invoked by code contained underneath future annotation (For eg. @future ) ,otherwise returns "FALSE' 
            if(!System.isFuture() && !System.isBatch()){ 
              Integer acctLimit = Trigger.new.size(); 
                for(Integer oCnt = 0; oCnt < acctLimit ; oCnt++){
                    if (trigger.new[oCnt].RecordTypeId == usOrgRecTypeId || trigger.new[oCnt].RecordTypeId == canadaRecTypeId) {
                        
                    if(trigger.old[oCnt].Physical_Street_1__c != trigger.new[oCnt].Physical_Street_1__c){changed = true;}
                    if(trigger.old[oCnt].Physical_Street_2__c != trigger.new[oCnt].Physical_Street_2__c){changed = true;}
                    if(trigger.old[oCnt].Physical_City__c != trigger.new[oCnt].Physical_City__c){changed = true;}
                    if(trigger.old[oCnt].Physical_State__c != trigger.new[oCnt].Physical_State__c){changed = true;}
                    if(trigger.old[oCnt].Physical_Zip__c != trigger.new[oCnt].Physical_Zip__c){changed = true;}
                    if(trigger.old[oCnt].PhysicalCountry__c != trigger.new[oCnt].PhysicalCountry__c){changed = true;}
                    // <--- ASP-1400 --->
                    if(trigger.new[oCnt].Physical_County__c  == null || trigger.new[oCnt].Physical_County__c  == '' &&  
                       (trigger.new[oCnt].Physical_Street_1__c != null || trigger.new[oCnt].Physical_Street_1__c!='') &&
                       (trigger.new[oCnt].Physical_City__c != null || trigger.new[oCnt].Physical_City__c!='') &&
                       (trigger.new[oCnt].Physical_State__c != null || trigger.new[oCnt].Physical_State__c !='') 
                       ){changed = true;} // <--- Just added for missing counties
                    system.debug('Old PHYS Street 1: '+trigger.old[oCnt].Physical_Street_1__c + ' NEW PHYS Street 1: '+trigger.new[oCnt].Physical_Street_1__c);
                    system.debug('HAS CHANGED? : '+changed);  
                    if(changed){
                        AccountHelper ah = new AccountHelper(trigger.new[oCnt].Id);
                        accountIds.add(JSON.serialize(ah));  
                        if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                            GeoLocationCallouts.getLocation(accountIds);
                        }
                    }   
                } //Record Type check.         
              }//LOOP  
            }//  Is FUture or Batch?
            /*
            //Baji: code to test SMS-105
            Id prmId,accId,srmId;
           
            for(Integer cnt = 0; cnt < Trigger.new.size(); cnt++){
                
                if(Trigger.new[cnt].Primary_Moves_Manager__c != null && Trigger.old[cnt].OwnerId !=Trigger.new[cnt].OwnerId){
                    system.debug('PRM value is:'+Trigger.new[cnt].Primary_Moves_Manager__c);
                    prmId = Trigger.new[cnt].Primary_Moves_Manager__c;
                    accId = Trigger.new[cnt].Id;
                    srmId = Trigger.new[cnt].Secondary_Relationship_Manager__c;
                }
            }
            
            if(prmId != null){
                system.debug('PRM value is:'+prmId);
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = accId;
                atm.UserId = prmId;
                atm.TeamMemberRole = 'Primary Relationship Manager';
                insert atm;
            }
            if(srmId != null){
                system.debug('SRM value is:'+srmId);
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = accId;
                atm.UserId = srmId;
                atm.TeamMemberRole = 'Secondary Relationship Manager';
                insert atm;
            }
            Awana_Settings__c custmPRMSetting =  Awana_Settings__c.getValues('RunPRMTrigger');
            system.debug('CustomSetting Value:'+custmPRMSetting.value__c);
            custmPRMSetting.value__c = 'false';
            update custmPRMSetting;
            */
            //SMS-105 end
       }//isUpdate
     }//isAfter
 }
}