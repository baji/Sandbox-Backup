/*
 * Purpose   : This test class covers the DRMDuplicateContactUpdate trigger code for the DRM contact update.
 * Developer : Mayur Soni(msoni@apttus.com) 
*/
@isTest
public class DRMDuplicateContactUpdateTest{
    @TestSetup
    public static void testDataCreate(){
        
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunContactTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        ConstitIdSeries__c ConstitIdSeries = new ConstitIdSeries__c();
        ConstitIdSeries.Name = 'ConstitIdStartNumber';
        ConstitIdSeries.ConstitSeriesNo__c = 5047150;
        insert ConstitIdSeries;
        
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        Awana_Settings__c awanaAccSettings = new Awana_Settings__c(Name='DRMDuplicateAccountUpdate',Value__c='false');
        insert awanaAccSettings;
        
         List<Account> accList = new List<Account>();
         for(Integer i=0;i<5;i++){
            Account a2 = new Account();
            a2.Name = 'Account Org '+(i+1);
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
            a2.Mailing_Address_Book__c = '000125'+i;
            accList.add(a2);
         }
         insert accList;
     
        Awana_Settings__c awanaSettings = new Awana_Settings__c(Name='DRMDuplicateContactUpdate',Value__c='false');
        insert awanaSettings;
        List<Contact> conList = new List<Contact>();
        
        for(Integer i=0;i<5;i++){
            Contact con = new Contact(
                    lastName='Test last'+(i+1),
                    FirstName='Test first' +(i+1),
                    AccountId=accList.get(i).Id
                );    
            conList.add(con);
        }
        insert conList;
        
        Id individualRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        Account indiAcct = new Account(
                            name='Individual',
                            recordtypeid=individualRecTypeId 
                            );
        insert indiAcct;
        Contact con = new COntact(
                        firstname='Test',
                        lastname='individual',
                        Suffix = 'Test',
                        AccountId=indiAcct.id
                        );
       insert con;
                /*Constituent_Id__c = '112233',
                RE_Constit_Rec_Id__c = '1234',
                Constituent_Code__c = 'Individual;Former Board Member',
                Constituent_Solicit_Code__c='No Appeals;Requested No Email',
                Missionary_Salutation__c='Test',
                Major_Donor_Salutation__c='Missionary Test',
                RE_Primary_Addresee__c='Mr. Test',
                RE_Primary_Salutation__c='Test',
                RE_Sub_set__c='B'*/
           
    } 
    @isTest
    public static void testContactUpdate(){
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        List<Account> accList = [SELECT Id,name from Account WHERE RecordTypeId IN :getUSRecordType];
        //system.debug('accList : '+accList);
        
        List<Contact> conList = [SELECT Id,AccountId,Name,RE_Constit_Rec_Id__c FROM Contact WHERE AccountId IN :accList];
        //system.debug('conList : '+conList);
        
        List<npe5__Affiliation__c> affiliationList = [SELECT Id,npe5__Contact__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Organization__c  IN :accList AND  npe5__Contact__c IN :conList];
        system.assert(affiliationList != null);
        
        //delete any 2 affiliations
        DELETE affiliationList[0];
        DELETE affiliationList[1];
        //update records with RE_Constit_Rec_Id__c so the trigger will execute
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateContactUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateContactUpdate',Value__c='true');
            insert awanaSettings;    
        }
        
        Integer recId = 100;

        for(Contact con : conList){
            con.RE_Constit_Rec_Id__c = String.valueOf(recId);
            recId += 5;
        }
        Test.startTest();
        update conList;
        Test.stopTest();
        conList = [SELECT Id,AccountId,Account.RecordTypeId FROM Contact where ID IN :conList];
        Id HHRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        System.assert(conList[0].Account.RecordTypeId ==HHRecTypeId);
        
        //System.debug('affiliationList : '+affiliationList);
        
    } 
    
    @isTest
    public static void testContactUpdateAffiliation(){
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        List<Account> accList = [SELECT Id,name from Account WHERE RecordTypeId IN :getUSRecordType LIMIT 2];
        //system.debug('accList : '+accList);
        
        List<Contact> conList = [SELECT Id,AccountId,Name,RE_Constit_Rec_Id__c FROM Contact WHERE AccountId IN :accList LIMIT 2];
        //system.debug('conList : '+conList);
        
        List<npe5__Affiliation__c> affiliationList = [SELECT Id,npe5__Contact__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Organization__c  IN :accList AND  npe5__Contact__c IN :conList];
        system.assert(affiliationList != null);
        
        //delete affiliations
        DELETE affiliationList;
        //update records with RE_Constit_Rec_Id__c so the trigger will execute
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateContactUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateContactUpdate',Value__c='true');
            insert awanaSettings;    
        }
        
        Integer recId = 100;

        for(Contact con : conList){
            con.RE_Constit_Rec_Id__c = String.valueOf(recId);
            con.firstName ='';
            con.lastName = '';
            recId += 5;
        }
        Test.startTest();
        update conList;
        Test.stopTest();
        conList = [SELECT Id,AccountId,Account.RecordTypeId FROM Contact where ID IN :conList];
        Id HHRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        System.assert(conList[0].Account.RecordTypeId ==HHRecTypeId);
        
    }
    
    @isTest
    public static void testContactUpdateIndividual(){
        Contact con = [SELECT Id,name,RE_Constit_Rec_Id__c FROM Contact WHERE lastName ='individual'];
        //update records with RE_Constit_Rec_Id__c so the trigger will execute
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateContactUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateContactUpdate',Value__c='true');
            insert awanaSettings;    
        }
        Integer recId = 100;
        con.RE_Constit_Rec_Id__c = String.valueOf(recId);
        Test.startTest();
        update con;
        Test.stopTest();
        
        con = [SELECT Id,name,AccountId, Account.RecordTypeId FROM Contact WHERE lastName ='individual'];
        Id HHRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        System.assert(con.Account.RecordtypeId == HHRecTypeId);
        
    }
    @isTest
    public static void testContactUpdateDuplicate(){
        Contact con = [SELECT Id,name,RE_Constit_Rec_Id__c FROM Contact WHERE lastName ='individual'];
        //update records with RE_Constit_Rec_Id__c so the trigger will execute
        Awana_Settings__c awanaSettings = Awana_Settings__c.getValues('DRMDuplicateContactUpdate');
        if(awanaSettings!=null){
            awanaSettings.Value__c='true';
            update awanaSettings;
        }else{
            awanaSettings = new Awana_Settings__c(Name='DRMDuplicateContactUpdate',Value__c='true');
            insert awanaSettings;    
        }
        Integer recId = 100;
        DateTime dt = System.now();
        con.RE_Constit_Rec_Id__c = String.valueOf(recId);
        con.RE_Date_Last_Changed__c=dt;
        update con;
        Test.startTest();
        
        Contact con1 = [SELECT id,name,RE_Constit_Rec_Id__c,Phone,RE_Date_Last_Changed__c FROM Contact WHERE id =:con.id];
        System.debug('con1  : '+con1);
        System.debug('con1.RE_Date_Last_Changed__c  : '+dt.addDays(-1));
        con1.RE_Date_Last_Changed__c=dt.addDays(-1);
        try{
            checkRecursive.runDuplicateContact = true;
            update con1;
            
        }catch(Exception ex){
            
            System.assert(ex.getMessage().contains('Contact already updated'));
        }
        
        con1.RE_Date_Last_Changed__c=dt;
        con1.Constituent_Id__c = null;
        try{
            checkRecursive.runDuplicateContact = true;
            update con1;
            System.debug('updated in try');
        }catch(Exception ex){
            System.debug('updated in catch');
            System.assert(ex.getMessage().contains('Contact already updated with Constituent Id'));
        }
        
        Test.stopTest();
    }
}