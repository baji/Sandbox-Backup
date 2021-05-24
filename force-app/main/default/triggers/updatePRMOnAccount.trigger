trigger updatePRMOnAccount on AccountTeamMember (after insert, after update, after delete) {
    Map<Id, AccountTeamMember> accMap = new Map<Id, AccountTeamMember>();
    List<Account> accList = new List<Account>();
    List<AccountTeamMember> atmList = new List<AccountTeamMember>();
    List<Id> aIds = new List<Id>();
    List<AccountTeamMember> atmDelete = new List<AccountTeamMember>();
    Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunPRMTrigger');
    system.debug('CustomSetting Value:'+custmSetting);
    
    if( trigger.isInsert || trigger.isUpdate )
    {
        system.debug('Trigger Size:'+Trigger.New.size());
        for( AccountTeamMember a : Trigger.New ){
            atmList.add(a);
            aIds.add(a.AccountId);
            if(a.TeamMemberRole == 'Primary Relationship Manager'){
                accMap.put( a.AccountId, a );
            }
            if(a.TeamMemberRole == 'Secondary Relationship Manager'){
                accMap.put( a.AccountId, a );
            }
        }
        system.debug('ATM List size:'+atmList.size());
    }
    if(!atmList.isEmpty()){
        accList = [select Id,Primary_Moves_Manager__c,Secondary_Relationship_Manager__c from Account where Id IN:aIds];
        
            for(Account ac : accList){
                for(AccountTeamMember at: atmList){
                    if(at.TeamMemberRole == 'Primary Relationship Manager'){
                        ac.Primary_Moves_Manager__c = at.userId;
                    }
                    if(at.TeamMemberRole == 'Secondary Relationship Manager'){
                        ac.Secondary_Relationship_Manager__c = at.userId;
                    }
                }
            }
        system.debug('Final Account List size:'+accList.size());
    }
    
    
    if( trigger.isDelete){
        system.debug('Trigger Old Size:'+Trigger.Old.size());
        for( AccountTeamMember a : Trigger.Old ){
            atmDelete.add(a);
            aIds.add(a.AccountId);
        }
        system.debug('ATM Delete List size:'+atmDelete.size());
    }
    if( !atmDelete.isEmpty() && Boolean.valueOf(custmSetting.value__c) ){
        accList = [select Id,Primary_Moves_Manager__c,Secondary_Relationship_Manager__c from Account where Id IN:aIds];
        
            for(Account ac : accList){
                for(AccountTeamMember at: atmDelete){
                    if(at.TeamMemberRole == 'Primary Relationship Manager'){
                        ac.Primary_Moves_Manager__c = null;
                    }
                    if(at.TeamMemberRole == 'Secondary Relationship Manager'){
                        ac.Secondary_Relationship_Manager__c = null;
                    }
                }
            }
        system.debug('Final Account Delete List size:'+accList.size());
    }
    
    upsert accList;
    custmSetting.value__c = 'true';
    update custmSetting;
}