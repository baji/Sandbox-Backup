@isTest
public class Test_S2SDynamicLeadObjectUpdate{
    static testMethod void leadMethod(){
        List<RecordType> listRecType = [Select id,name,developerName From RecordType Where sObjectType = 'Lead'];
        Lead lea = new Lead();
            lea.LastName = 'Shaik';
            lea.Company = 'Infogeln';
        Insert lea;
        Lead le = new Lead();
            le.LastName = 'Imran';
            le.Company = 'Infoglen';
            le.Source_Inquiry_Rec_Id__c = lea.Id;
            le.Source_OwnerId__c = '005f4000000ZJhT';
            le.RecordTypeId = listRecType[0].Id;
        Insert le;
        
        S2SDynamicLeadObjectUpdate ss = new S2SDynamicLeadObjectUpdate();
            Database.ExecuteBatch(ss,10);
       
    }
}