global class CreatePRM{
    @InvocableMethod
    public static void createATMPRM(List<Id> accId){
        Id prmId,aId;
        system.debug('Account Id: '+accId[0]);
        AccountTeamMember atm = new AccountTeamMember();
        List<AccountTeamMember> atmems = [select UserId,TeamMemberRole,AccountId from AccountTeamMember where AccountId IN: accId and isDeleted = true];
        for(AccountTeamMember a: atmems){
            if(a.TeamMemberRole == 'Primary Relationship Manager'){
                prmId = a.UserId;
                aId = a.AccountId;
            }
        }
        if(prmId != '' || prmId != null){    
            atm.AccountId = aId;
            atm.TeamMemberRole = 'Primary Relationship Manager';
            atm.UserId = prmId;
        }
        try{
        insert atm;
        }
        catch(Exception e){
            system.debug(e);
        }
    }
}