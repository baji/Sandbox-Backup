@isTest
public class Test_S2SGoClubTeritories{
    static testMethod void goClub(){
        GO_Club_Territories__c obj = new GO_Club_Territories__c();
            obj.Name = 'Test';
            obj.Source_GO_Club_Outreach_Specialist__c = 'imran@infoglen.com';
        Insert obj;
        S2SGoClubTeritoriesObjectUpdate ss = new S2SGoClubTeritoriesObjectUpdate();
            Database.ExecuteBatch(ss,10);
    }
}