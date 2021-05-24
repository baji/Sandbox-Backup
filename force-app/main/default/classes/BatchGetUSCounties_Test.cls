/*********************************************************************************************************
Programmer:         Ayesha.
Company:            Infoglen
Contact:            ayesha@infoglen.com
Project:            ASP-
Original:          1/24/2018 - Test for BatchGetUSCounties  
***********************************************************************************************************/ 
@isTest()
public class BatchGetUSCounties_Test{
    static testMethod void testMethod1() 
    {
        List<Account> lstAccount= new List<Account>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        for(Integer i=0 ;i <50;i++)
        {
            Account acc = new Account();
            acc.RecordTypeId =recordTypeId;
            acc.Name ='Name'+i;
            acc.Physical_County__c = null;
            acc.Physical_City__c = 'Santa Clara';
            acc.Physical_State__c = 'CA';
            acc.Physical_Zip__c  = '95050';
            acc.Status__c ='Added';
            acc.Registration_Level__c = 'R1';
            lstAccount.add(acc);
        }
        
        
        insert lstAccount;
        lstAccount[0].Registration_Level__c = 'R1';
        update lstAccount[0];
        Test.startTest();
        
        //Id AccountId = lstAccount[0].id;
        BatchGetUSCounties obj = new BatchGetUSCounties();
        Test.setMock(HttpCalloutMock.class, new BatchGetUSCountiesMock());
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
    static testMethod void testMethod2() 
    {
        List<Account> lstAccount= new List<Account>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        for(Integer i=0 ;i <20;i++)
        {
            Account acc = new Account();
            acc.RecordTypeId =recordTypeId;
            acc.Name ='NameInfo'+i;
            acc.Physical_County__c = null;
            acc.Physical_City__c = 'Santa Clara';
            acc.Physical_State__c = 'CA';
            acc.Physical_Zip__c  = '95050';
            acc.Status__c ='Added';
            acc.Registration_Level__c = 'R1';
            lstAccount.add(acc);
        }
        
        
        
        Test.startTest();
        insert lstAccount;
        lstAccount[0].Registration_Level__c = 'R2';
        update lstAccount[0];
        system.debug('*****'+lstAccount);
        BatchGetUSCounties obj = new BatchGetUSCounties();
        //Test.setMock(HttpCalloutMock.class, new BatchGetUSCountiesMock());
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
    
}