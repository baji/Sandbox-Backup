@isTest
public class Test_S2STrainingTrackerCredit{
    static testMethod void createTraining(){
        
        Contact con = new Contact();
            con.LastName = 'Imran';
        Insert con;
        
        RITT_Credits__c rc1 = new RITT_Credits__c();
            rc1.Source_Rec_Id__c = 'dsdasd232sd';
            rc1.Contact__c = con.Id;
        Insert rc1;
        
        S2STrainingTrackerCreditObjectUpdate ss = new S2STrainingTrackerCreditObjectUpdate();
        Database.ExecuteBatch(ss,10);
    }
}