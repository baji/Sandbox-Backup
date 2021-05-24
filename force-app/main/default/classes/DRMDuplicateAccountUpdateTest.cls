/*
 * Purpose   : This test class covers the DRMDuplicateAccountUpdate trigger code for the DRM duplicate handling.
 * Developer : Mayur Soni(msoni@apttus.com) 
*/
@isTest
public class DRMDuplicateAccountUpdateTest{
    
    @TestSetup
    public static void testDataCreate(){
    
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunAccountTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        Awana_Settings__c custmPRMSetting =  new Awana_Settings__c();
        custmPRMSetting.Name = 'RunPRMTrigger';
        custmPRMSetting.Value__c = 'true';
        insert custmPRMSetting;
    
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        Account a2 = new Account();
        a2.Name = 'Account Org 1';
        a2.Status__c = 'Added';
        a2.ShippingStreet = '503 Scruggs St';
        a2.Mailing_Street_1__c ='702 Scruggs St' ;
        a2.ShippingCity = 'Waycross';
        a2.Mailing_City__c = 'Waycross';
        a2.ShippingState = 'GA';
        a2.Mozo_Trial_Status__c = 'Current';
        a2.Mozo_Trial_End_Date__c = system.today() + 90;
        a2.Registration_Level__c = 'R1';
        a2.Mailing_State_Province__c='GA';
        a2.ShippingCountry ='United States';
        a2.Mailing_Country__c='United States';
        a2.ShippingPostalCode = '31501';
        a2.Mailing_Zip_Postal_Code__c = '31501';
        a2.BillingStreet='503 Scruggs St';
        a2.Physical_Street_1__c ='702 Scruggs St';
        a2.BillingCity = 'Waycross';
        a2.Physical_City__c ='Waycross';
        a2.BillingState ='CA';
        a2.Physical_State__c = 'CA';
        a2.BillingCountry = 'United States';
        a2.PhysicalCountry__c = 'United States';
        a2.BillingPostalCode = '31501';
        a2.Physical_Zip__c = '31501';
        a2.RecordType =  getUSRecordType[0];//getRecordType;
        a2.OwnerId=userinfo.getUserId();
        a2.Mozo_Trial_Status__c = 'Current';
        a2.Mozo_Trial_End_Date__c = system.today();
        a2.Mailing_Address_Book__c = '000125'; 
        a2.Phone = '1234567890';
        a2.Type = 'Business';
        insert a2;
        
        
        
    }
    @isTest
    public static void testAccountUpdate(){
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        Account acc = [SELECT id,name,RE_Constit_Rec_Id__c,Phone FROM Account WHERE RecordTypeId IN :getUSRecordType];
        system.debug('Account : '+acc);
        
        acc.RE_Constit_Rec_Id__c = '1234';
        acc.Phone = null;
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateAccountUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateAccountUpdate',Value__c='true');
            insert awanaSettings;    
        }
        
        Awana_Settings__c custmPRMSetting =  new Awana_Settings__c();
        custmPRMSetting.Name = 'RunPRMTrigger';
        custmPRMSetting.Value__c = 'true';
        insert custmPRMSetting;
        
        Test.startTest();
        update acc;
        Test.stopTest();
        acc = [SELECT id,name,RE_Constit_Rec_Id__c,Phone FROM Account WHERE RecordTypeId IN :getUSRecordType];
        System.assert(acc.phone!=null);
        checkRecursive.runOnceDuplicateAccount();
    }
    @isTest
    public static void testAccountUpdateDuplicate(){
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        Account acc = [SELECT id,name,RE_Constit_Rec_Id__c,Phone FROM Account WHERE RecordTypeId IN :getUSRecordType];
        system.debug('Account : '+acc);
        DateTime dt = System.now();
        acc.RE_Constit_Rec_Id__c = '1234';
        acc.Phone = null;
        acc.RE_Date_Last_Changed__c=dt;
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateAccountUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateAccountUpdate',Value__c='true');
            insert awanaSettings;    
        }
        
        
        Awana_Settings__c custmPRMSetting =  new Awana_Settings__c();
        custmPRMSetting.Name = 'RunPRMTrigger';
        custmPRMSetting.Value__c = 'true';
        insert custmPRMSetting;
        
        update acc;
        Test.startTest();
        Account acc1 = [SELECT id,name,RE_Constit_Rec_Id__c,Phone,RE_Date_Last_Changed__c FROM Account WHERE id =:acc.id];
        System.debug('acc1  : '+acc1);
        System.debug('acc1.RE_Date_Last_Changed__c  : '+dt.addDays(-1));
        acc1.RE_Date_Last_Changed__c=dt.addDays(-1);
        try{
            checkRecursive.runDuplicateAccount = true;
            update acc1;
            System.debug('updated in try');
        }catch(Exception ex){
            System.debug('updated in catch');
            System.assert(ex.getMessage().contains('Account already updated'));
        }
        
        Test.stopTest();
        
    }
    @isTest
    public static void testAccountUpdateDuplicate1(){
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        Account acc = [SELECT id,name,RE_Constit_Rec_Id__c,Phone FROM Account WHERE RecordTypeId IN :getUSRecordType];
        system.debug('Account : '+acc);
        DateTime dt = System.now();
        acc.RE_Constit_Rec_Id__c = '1234';
        acc.Phone = null;
        acc.RE_Date_Last_Changed__c=dt;
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateAccountUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateAccountUpdate',Value__c='true');
            insert awanaSettings;    
        }
        
        Awana_Settings__c custmPRMSetting =  new Awana_Settings__c();
        custmPRMSetting.Name = 'RunPRMTrigger';
        custmPRMSetting.Value__c = 'true';
        insert custmPRMSetting;
        
        update acc;
        Test.startTest();
        Account acc1 = [SELECT id,name,RE_Constit_Rec_Id__c,Phone,RE_Date_Last_Changed__c FROM Account WHERE id =:acc.id];
        System.debug('acc1  : '+acc1);
        System.debug('acc1.RE_Date_Last_Changed__c  : '+dt.addDays(-1));
        acc1.RE_Date_Last_Changed__c=dt.addDays(-1);
        try{
            checkRecursive.runDuplicateAccount = true;
            update acc1;
            
        }catch(Exception ex){
            
            System.assert(ex.getMessage().contains('Account already updated'));
        }
        
        acc1.RE_Date_Last_Changed__c=dt;
        acc1.Constituent_Id__c = null;
        try{
            checkRecursive.runDuplicateAccount = true;
            update acc1;
            System.debug('updated in try');
        }catch(Exception ex){
            System.debug('updated in catch');
            System.assert(ex.getMessage().contains('already updated with Constituent Id'));
        }
        
        Test.stopTest();
        
    }

}