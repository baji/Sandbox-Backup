/************************************************************************************************************************************************************
    Programmer: Ayesha Zulkha
    Company:    Awana
    Project:    Donation management
    Original:   2/16/2018  - Level Assignment on Opportunity
    *************************************************************************************************************************************************************/
trigger UpdateOpportunityLevels on Opportunity (before insert, after insert,before Update, after update) {
    
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunOpportunityTrigger');   
    
    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        Map<String, Awana_Settings__c> AwanaSettings = Awana_Settings__c.getAll();
        String myCCVal,REMigration;
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id MatchingGiftRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Matching Gift').getRecordTypeId();
        if(AwanaSettings.containsKey('ExecuteOpportunityTrigger'))
        {   Awana_Settings__c myCS1 = AwanaSettings.get('ExecuteOpportunityTrigger');
            myCCVal = myCS1.Value__c;
        }
       
        if(myCCVal!=null && Boolean.valueOf(myCCVal))
        {
            if(trigger.isBefore && trigger.isInsert){
                
                List<opportunity> newOptList = new List<opportunity>();
                List<opportunity> WCOptList = new List<opportunity>();
                for (opportunity op: Trigger.new) {
                    if(op.RecordTypeId  == donationRecordTypeId || op.RecordTypeId  == MatchingGiftRecordTypeId) {
                       newOptList.add(op);
                       if(op.Gift_SubType__c == 'wooCommerce'){
                           WCOptList.add(op);
                       }
                    }
                    
                }
                if(newOptList!=null && newOptList.size()>0){
                    OpportunityUpdateAction.UpdateOpportunities(newOptList);
                    
                }
                if(WCOptList!=null && WCOptList.size()>0){
                    wooCommerceBatch.createWCBatch(WCOptList);
                }
            }
            if(trigger.isAfter){
                if(trigger.isInsert){
                List<opportunity> newOptList = new List<opportunity>();
                for (opportunity op: Trigger.new) {
                    if(op.RecordTypeId  == donationRecordTypeId || op.RecordTypeId  == MatchingGiftRecordTypeId) {
                       newOptList.add(op); 
                    }
                    
                }
                if(newOptList!=null && newOptList.size()>0){
                    UpdateAccountSoftCredit.AccountUpdate(newOptList);
                    CreateContactConstitId.contactUpdate(newOptList);
                }
                
                }
                if(trigger.isUpdate){
                List<opportunity> newOptList = new List<opportunity>();
                for (opportunity op: Trigger.new) {
                    opportunity oldOpt = Trigger.oldMap.get(op.ID);
                    if((op.Soft_Credit_Organization__c!= oldOpt.Soft_Credit_Organization__c) && (op.RecordTypeId  == donationRecordTypeId || op.RecordTypeId  == MatchingGiftRecordTypeId)) {
                       newOptList.add(op); 
                    }
                    
                }
                if(newOptList!=null && newOptList.size()>0){
                    UpdateAccountSoftCredit.AccountUpdate(newOptList);
                }
                
                }
            }
            if(trigger.isBefore && trigger.isUpdate){
                List<opportunity> newOptList = new List<opportunity>();
                for (opportunity op: Trigger.new) {
                    opportunity oldOpt = Trigger.oldMap.get(op.ID);
                    if((op.amount != oldOpt.amount) && (op.RecordTypeId  == donationRecordTypeId || op.RecordTypeId  == MatchingGiftRecordTypeId)) {
                       newOptList.add(op); 
                    }
                    
                }
                if(newOptList!=null && newOptList.size()>0){
                    OpportunityUpdateAction.UpdateOpportunities(newOptList);
                }
                
            } 
            if(trigger.isAfter && trigger.isUpdate){
                List<opportunity> giftAdjList = new List<opportunity>();
                
                 for (opportunity op: Trigger.new) {
                 opportunity oldOpt = Trigger.oldMap.get(op.ID);
                  if((op.amount!= oldOpt.amount) && (op.isPosted__c) && (op.RecordTypeId  == donationRecordTypeId || op.RecordTypeId  == MatchingGiftRecordTypeId)) {
                       giftAdjList.add(op);
                    }
                 }
                if(giftAdjList!=null && giftAdjList.size()>0){
                    GiftAdjustmentsUpdate.UpdateOpportunityChanges(giftAdjList,trigger.oldMap);
                }
            }
         }
         if(AwanaSettings.containsKey('ExecuteOpptyTriggerForREMigration') && Boolean.valueOf(AwanaSettings.get('ExecuteOpptyTriggerForREMigration').Value__c) && trigger.isBefore && trigger.isInsert)
         {
             set<string> consistRecordIds = new Set<String>();
             map<string,string> ConsistRecordToAccountMap = new map<string,string>();
             map<string,string> ConsistRecordToContacttMap = new map<string,string>();
             
             for(Opportunity opp : Trigger.New){
                 if(opp.RE_Consist_Record_Id__c!=null && opp.RE_Consist_Record_Id__c!=''){
                          consistRecordIds.add(opp.RE_Consist_Record_Id__c);
                      } 
                       
             }
             
             list<Contact> contactLst = [SELECT id, AccountId,RE_Constit_Rec_Id__c FROM Contact WHERE RE_Constit_Rec_Id__c IN :consistRecordIds AND Account.RecordType.DeveloperName = 'HH_Account'];
             list<Account> AccountLst = [SELECT Id,RE_Constit_Rec_Id__c,npe01__One2OneContact__c FROM Account WHERE RE_Constit_Rec_Id__c IN :consistRecordIds AND RecordType.DeveloperName = 'US_Organization' ];
             
             if(contactLst!=null && contactLst.size()>0){
                     for(Contact Con: contactLst)
                         ConsistRecordToContacttMap.put(con.RE_Constit_Rec_Id__c,con.AccountId+':'+con.Id);
             }
             if(AccountLst!=null && AccountLst.size()>0){
                   for(Account Acc: AccountLst)
                         ConsistRecordToAccountMap.put(Acc.RE_Constit_Rec_Id__c,Acc.Id+':'+Acc.npe01__One2OneContact__c);
             }    
                
             for(Opportunity opp : Trigger.New){
                 if(ConsistRecordToAccountMap.containsKey(opp.RE_Consist_Record_Id__c)){
                    list<string> splitLst = (list<string>)ConsistRecordToAccountMap.get(opp.RE_Consist_Record_Id__c).split(':');
                    opp.AccountId = splitLst.get(0);
                    if(splitLst.size()>2 && splitLst.get(1)!=null)
                        opp.npsp__Primary_Contact__c=  splitLst.get(1);
                 }
                else if(ConsistRecordToContacttMap.containsKey(opp.RE_Consist_Record_Id__c)){
                    list<string> splitLst = (list<string>)ConsistRecordToContacttMap.get(opp.RE_Consist_Record_Id__c).split(':');
                    opp.AccountId = splitLst.get(0);
                    opp.npsp__Primary_Contact__c=  splitLst.get(1);
                }
             }
         }     
     }
}