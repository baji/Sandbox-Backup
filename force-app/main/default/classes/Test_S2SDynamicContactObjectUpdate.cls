@isTest
public class Test_S2SDynamicContactObjectUpdate{
    static testMethod void contactMethod(){
        Contact con = new Contact();
            con.LastName = 'Imran';
        Insert con;
        Contact con1 = new Contact();
            con1.LastName = 'Shaik';
            con1.Source_Contact_Rec_Id__c = con.Id;
        Insert con1;
        S2SDynamicContactObjectUpdate ss = new S2SDynamicContactObjectUpdate();
            Database.ExecuteBatch(ss,10);
    }
}