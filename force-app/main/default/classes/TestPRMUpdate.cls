@isTest(SeeAllData=true)

private class TestPRMUpdate {
   static testmethod void TestAccountPRM() {
           
           //List<AccountTeamMember> atmListUpdate = [select Id,UserId,TeamMemberRole,AccountId from AccountTeamMember where Id=: null];
           //List<AccountTeamMember> atmListDelete = [select Id,UserId,TeamMemberRole,AccountId from AccountTeamMember where Id=: null and TeamMemberRole = 'Primary Relationship Manager'];
    User u = [select Id from User where Id !=: '' and Alias =: 'sbaji' Limit 1];
    Account acc = [select Id from Account where Id !=: '' Limit 1];
    AccountTeamMember atm = new AccountTeamMember();
    AccountTeamMember atmPRM = new AccountTeamMember();
    AccountTeamMember atmSRM = new AccountTeamMember();
    atm.UserId = u.Id;
    atm.TeamMemberRole = 'Primary Missionary';
    atm.AccountId = acc.Id;
    
    atmPRM.UserId = u.Id;
    atmPRM.TeamMemberRole = 'Primary Relationship Manager';
    atmPRM.AccountId = acc.Id;
    
    atmSRM.UserId = u.Id;
    atmSRM.TeamMemberRole = 'Secondary Relationship Manager';
    atmSRM.AccountId = acc.Id;
    
           Test.startTest();
           insert atm;
           insert atmPRM;
           delete atmPRM;
           insert atmSRM;
           delete atmSRM;
           Test.stopTest();
       
  }
}