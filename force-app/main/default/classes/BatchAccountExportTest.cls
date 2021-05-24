/*******************************************************
 * @ClassName: BatchAccountExportTest.cls
 * @author: infoglen - Urvashi Dagara
 * @Description: Test class for BatchAccountExport class to Export Individual type Account records.
 * 15/10/2019 - SMS-88-Convert All Individual Accounts
 * @ChangeHistory
 * 
 * *******************************************************/
@isTest
Public class BatchAccountExportTest{
    
    @isTest
    public static void testBatch(){    
        
        Test.StartTest();
        Id individualRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account'].Id;
        
        Awana_Settings__c awnSetting = new Awana_Settings__c();
        awnSetting.Name = 'AccountRecordTypeId';
        awnSetting.value__c = individualRecordTypeId;
        insert awnSetting;
        
        Awana_Settings__c awnSetting2 = new Awana_Settings__c();
        awnSetting2.Name = 'ToAddress';
        awnSetting2.value__c = 'test@test.com';
        insert awnSetting2;
        
        List<Account> accList = new List<Account>();
        Account acc;
        
        List<Contact> conList = new List<Contact>();
        Contact con;
        
        for(integer i=0;i<=10;i++){
            acc = new Account();
            acc.Name = 'TestAccount'+i;
            acc.RecordTypeId = individualRecordTypeId;
            accList.add(acc);        
        }
        
        if(!accList.isEmpty()){
            insert accList;
        
        
            for(Account ac : accList){
                con = new Contact();
                con.LastName = ac.Name;
                con.AccountId = ac.id;
                conList.add(con);          
            }
         
        
            if(!conList.isEmpty()){
                insert conList;
            }
            
        }       
        
        Id accountRecordTypeId =  Awana_Settings__c.getValues('AccountRecordTypeId').value__c; 
        string query = 'SELECT id,Name,(SELECT Id,Name FROM Contacts WHERE AccountId != null Limit 20),RecordType.Name FROM Account WHERE RecordTypeId =: accountRecordTypeId Limit 20';  
        BatchAccountExport.invokeBatch(query,200);
        Test.stopTest();
        
    }

}