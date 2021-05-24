/**********************************************************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            AGD-2 & ASP_448
    Original:           7/11/2017-  Church signs up for Awana GO.
    Update:             02/03/2018 - <ASP-866>> Added Primary Missionary updates for a newly Added Account 
    Update:             02/08/2018 - <ASP-754> - Now churches the request to be hidden from CLub Finder can do so.
    Update:(Baji)       09-06-2018 - <1304> -  added Account Registration Level field in AccountBeforeUpdate to fix the ...
                                                issue Assigning the Primary Missionary as Account Owner though the church Registration Level is R0
    Update:(Tony)       09-25-2018 - <1400> - Removed the restriction of Reg Status = 'Reinstated' when a county changes for updating new Account Owners.
NOTE: <UNTIL TICKET IS CREATED: > REMOVING CALL TO RAT ACOCUNT TEAM AND ACCOUNT OWNER 11/01/2016
 *************************************************************************************************************************************************************/ 
trigger AccountBeforeUpdate on Account (before insert, before update) {
    List<Account> accIds,updateAccountOwners = new List<Account>();
    Integer allUpdatedAccounts = Trigger.new.size();
    List<Account> updateGOAccounts = new  List<Account>();
    List<RecordType> getUSRecordType = [SELECT Id FROM RecordType WHERE Name = 'US Organization' limit 1];
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');   
     
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        if(Trigger.isUpdate){
             for(Integer cnt = 0; cnt < allUpdatedAccounts; cnt++){
                 system.debug('<<New Go Level>>>'+Trigger.new[cnt].GO_Level__c);
                 system.debug('<<REcord Type ID>>>'+Trigger.old[cnt].RecordTypeId);
                 system.debug('<<OLD REG_LEVEL>> '+Trigger.old[cnt].Registration_Level__c);
                 system.debug('<<TYPE>>> '+Trigger.new[cnt].Type);
                 system.debug('<<ACCT ID>>> '+Trigger.old[cnt].Name);
                 system.debug('<< NEW REG LEVEL>>> '+Trigger.new[cnt].Registration_Level__c);
                 system.debug('<< 2- RECORD TYPE ID>>> '+getUSRecordType[0].Id );
                 //AC:If the Registered R1/R2/R3 Member is a Church, "Exclude from Club Finder" field should default to "false"
                 //AC:If a Registered R1/R2/R3 Member has "Exclude from Club Finder" value of "false", that customer should appear on Club Finder.
                 if(getUSRecordType[0].Id == Trigger.old[cnt].RecordTypeId && Trigger.old[cnt].Type == 'Church' && 
                             (Trigger.old[cnt].Registration_Level__c=='R0' || Trigger.old[cnt].Registration_Level__c == null) &&
                             (Trigger.new[cnt].Registration_Level__c == 'R1' || Trigger.new[cnt].Registration_Level__c =='R2' || Trigger.new[cnt].Registration_Level__c =='R3')){
                     Trigger.new[cnt].Exclude_From_Club_Finder__c = false;
      system.debug('<<  IF-1 UPDATE: >>> '+Trigger.new[cnt].Exclude_From_Club_Finder__c);
                 }
                 //AC:Non-member customers do not have the option of being listed on Club Finder
                 if(getUSRecordType[0].Id == Trigger.old[cnt].RecordTypeId && Trigger.old[cnt].Type == 'Church' && 
                             (Trigger.old[cnt].Registration_Level__c!='R0' && Trigger.old[cnt].Registration_Level__c != null) &&
                             (Trigger.new[cnt].Registration_Level__c == 'R0')){
                 Trigger.new[cnt].Exclude_From_Club_Finder__c = true;
      system.debug('<<  IF-2 UPDATE: >>> '+Trigger.new[cnt].Exclude_From_Club_Finder__c);    
                 }
                 if(getUSRecordType[0].Id == Trigger.old[cnt].RecordTypeId && Trigger.new[cnt].Type != 'Church' && Trigger.old[cnt].Type == 'Church'){
                     Trigger.new[cnt].Exclude_From_Club_Finder__c = true;
       system.debug('<<  IF-2 UPDATE: >>> '+Trigger.new[cnt].Exclude_From_Club_Finder__c);               
                 }
                  if(getUSRecordType[0].Id == Trigger.old[cnt].RecordTypeId && Trigger.new[cnt].Type == 'Church' && Trigger.old[cnt].Type != 'Church'){
                     Trigger.new[cnt].Exclude_From_Club_Finder__c = false;
       system.debug('<<  IF-2 UPDATE: >>> '+Trigger.new[cnt].Exclude_From_Club_Finder__c);               
                 }
                 //If GO Level Changes from null, Former, or None value to Level 1 - Level 3 then Update GO Fields
                 if(Trigger.old[cnt].GO_Level__c  == null || Trigger.old[cnt].GO_Level__c == '' || Trigger.old[cnt].GO_Level__c == 'None' || Trigger.old[cnt].GO_Level__c == 'Former'){
                     if(Trigger.new[cnt].GO_Level__c == 'Level 1' || Trigger.new[cnt].GO_Level__c == 'Level 2' ||  Trigger.new[cnt].GO_Level__c == 'Level 3'){
                         updateGOAccounts.add(Trigger.new[cnt]);
                     }
                    
                 }
                
                  //commented to test ASP-1400  
                  /*          
                  if(Trigger.old[cnt].Physical_County__c !=Trigger.new[cnt].Physical_County__c  && (Trigger.new[cnt].Status__c=='Added') ){
                     if((Trigger.new[cnt].Registration_Level__c != 'R0' &&  Trigger.new[cnt].Registration_Status__c != 'Dropped')) {
        
                         //load the account in this UpdateAccountOwner list
                         if((Trigger.new[cnt].Physical_County__c != null && Trigger.new[cnt].Physical_County__c != '') && (Trigger.new[cnt].Physical_State__c != null && Trigger.new[cnt].Physical_State__c != '')){
                             updateAccountOwners.add(Trigger.new[cnt]);
                         }
                     }
                 }
                 */
                 
             }//Loop
         }
         if(Trigger.isInsert){
              for(Account a: Trigger.new){
                 system.debug('<<New Go Level>>>'+a.GO_Level__c);
                 system.debug('<<REcord Type ID>>>'+a.RecordTypeId);
                 system.debug('<<REG_LEVEL>> '+a.Registration_Level__c);
                 system.debug('<<TYPE>>> '+a.Type);
                 system.debug('<<ACCT ID>>> '+a.Name);
      
                 //AC:If the Registered R1/R2/R3 Member is something other than a Church, "Exclude from Club Finder" should default to "true"
                 a.Exclude_From_Club_Finder__c = true;
                 //AC:If a Registered R1/R2/R3 Member has "Exclude from Club Finder" value of "true", that customer should NOT appear on Club Finder.
                 if((a.RecordTypeId == getUSRecordType[0].Id &&  (a.Type=='Church' || a.Type=='Military')) && (a.Registration_Level__c == 'R1' || a.Registration_Level__c == 'R2' || a.Registration_Level__c == 'R3')){
                     system.debug('*******true**********'+a.Type+'******'+a.Status__c);
                     a.Exclude_From_Club_Finder__c = false;
                   //    accIds.add(a);
                 }
         system.debug('<<  IF-1 INSERT: >>> '+a.Exclude_From_Club_Finder__c);     
             }//for loop
         }
          //Check for any ReUp GO Accounts
         if(updateGOAccounts.size() > 0){
             SignUpGOAccounts.helper(updateGOAccounts);
         }
         // Now get the Primary Misisonary and insert him into the recently added account
         if( updateAccountOwners.size() > 0){
             AddNewAccountOwner.helper(updateAccountOwners);
         }
     }
 }