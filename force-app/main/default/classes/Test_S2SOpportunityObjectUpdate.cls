@isTest
public class Test_S2SOpportunityObjectUpdate{
    static testMethod void leaderInformation(){
        
        Opportunity opp1 = new Opportunity();
            opp1.Name = 'Test';
            opp1.StageName = 'Closed';
            opp1.CloseDate = date.today();
        Insert opp1;
        
        Opportunity opp2 = new Opportunity();
            opp2.Name = 'Test2';            
            opp2.StageName = 'Closed';
            opp2.CloseDate = date.today();
            opp2.Source_Record_Id__c = opp1.Id;
        Insert opp2;
        
        S2SOpportunityObjectUpdate ss = new S2SOpportunityObjectUpdate();
        Database.ExecuteBatch(ss,10);
    }
}