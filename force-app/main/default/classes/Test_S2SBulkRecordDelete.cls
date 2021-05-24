@isTest
public class Test_S2SBulkRecordDelete{
    static testMethod void deleteMethod(){
        Account acc = new Account();
            acc.Name = 'Popular Tech';
        Insert acc;
        S2SBulkRecordDelete ss = new S2SBulkRecordDelete('Account');
            Database.ExecuteBatch(ss,10);
    }
}