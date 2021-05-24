@isTest
public class Test_S2SLeaderInformationbjectUpdate{
    static testMethod void leaderInformation(){
        
        CP_Contact__c osd1 = new CP_Contact__c();
            osd1.Name = 'Test';
        Insert osd1;
        
        CP_Contact__c osd = new CP_Contact__c();
            osd.Name = 'Test Salesforce Document';
            osd.Source_Rec_Id__c = osd1.Id;
        Insert osd;
        
        S2SLeaderInformationbjectUpdate ss = new S2SLeaderInformationbjectUpdate();
        Database.ExecuteBatch(ss,10);
    }
}