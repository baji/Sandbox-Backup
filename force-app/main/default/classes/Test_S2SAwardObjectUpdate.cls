@isTest
public class Test_S2SAwardObjectUpdate{
    static testMethod void awardMethod(){
        Account acc = new Account();
            acc.Name = 'Infoglen';
        Insert acc;
        Contact con = new Contact();
            con.LastName = 'Imran';
            con.AccountId = acc.Id;
        Insert con;
        Award__c awa = new Award__c();
            awa.AwardRecipient__c = con.Id;
            awa.Source_Contact_Id__c = con.Id;
            awa.Church__c = acc.Id;
        Insert awa;
        S2SAwardObjectUpdate ss = new S2SAwardObjectUpdate();
            Database.ExecuteBatch(ss,10);
    }
}