/*****************************************
    Programmer:         Matthew Keefe
    Company:            Awana
    Contact:            mattk@awana.org
    Project:            Registration in Salesforce
    Original:           3/10/2009    
    Updated:            10/25/2012 - (TR) Updated for US Church to US Organization account record type name change.
 *****************************************/

@isTest(SeeAllData=true)

private class RegistrationTest {

    public static testMethod void testNationalChurchWithNullISO()
    {
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get church record type
            String RecordTypeId = null;
      //TR  US Church is now US Organization    
     //       List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with default registration settings
            Account a1 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 1-IWNISO', // national with null iso
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='USSSS',
                Mailing_Address_Book__c = '000223',
                Registration_Number__c  ='US143'
            ); 
            Test.startTest();
            try {
                insert a1; 
                }
            catch(Exception ex) 
            {
                System.debug(' Exceptio 55: '+ex.getMessage());
                System.assert(ex.getMessage().contains('STRING_TOO_LONG')); 
            }
            Test.stopTest();
        }
    }

    public static testMethod void testInternationalChurchWithNullISO()
    {
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get church record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'International Church'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with default registration settings
            Account a2 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 2-IWNISO', // international with null iso
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c=null,
                Mailing_Address_Book__c = '000123'        
            ); 
              Test.startTest();
            try {
                insert a2; }
            catch(Exception ex) {
                System.assert(ex.getMessage().contains('two character country code')); }
              Test.stopTest();
        }
    }
    /*
    public static testMethod void testKMChurch()
    {
        
            // get church record type
            String RecordTypeId = null;
            List<RecordType> rec2 = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'KM Church'];
            if(rec2.size() > 0) { RecordTypeId = rec2[0].Id; }
            
            // test with default registration settings
            Account a2 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 1-KM_CHURCH_GOOD', // international with null iso
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c=null    
            ); 
            
            try {
                insert a2; }
            catch(Exception ex) {
                //System.assert(ex.getMessage().contains('two character country code')); 
                }
        
    }
    */
    public static testMethod void testInternationalChurchWithInvalidISO()
    {
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get church record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'International Church'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with default registration settings
            Account a3 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 3-IWIISO', // international with invalid iso
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='A',
                Mailing_Address_Book__c = '000123'     
            ); 
              Test.startTest();
            try {
                insert a3; }
            catch(Exception ex) {
                System.assert(ex.getMessage().contains('two character country code') || 
                              ex.getMessage().contains('must be two characters')); }
             Test.stopTest();               
        }
    }
    public static testMethod void TestNextRegistrationNumber()
    {
        Registration.nextRegistrationNumber('US');
        Registration.nextRegistrationNumber('CA');
        Registration.nextRegistrationNumber('AU');
    
    }
    public static testMethod void testNationalChurchWithInvalidISO()
    {
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get church record type
            String RecordTypeId = null;
       //TR  US Church is now US Organization    
      //      List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with default registration settings
            Account a35 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 3-IWIISO', // international with invalid iso
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='XXXXX',
                Mailing_Address_Book__c = '000523',
                Registration_Number__c  ='US123'
            ); 
              Test.startTest();
            try {
                insert a35; }
            catch(Exception ex) {
                System.debug(' Exceptio 227: '+ex.getMessage());
                System.assert(ex.getMessage().contains('STRING_TOO_LONG') || 
                              ex.getMessage().contains('must be two characters')); }
                Test.stopTest();
        }
    }
    public static testMethod void testNationalChurchWithDefaultRegistrationSettings()
    {
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get church record type
            String RecordTypeId = null;
       //TR  US Church is now US Organization    
      //      List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with default registration settings
            Account a4 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 4-NWDS', // national with default settings 
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US',
                Mailing_Address_Book__c = '000123',
                Registration_Number__c='US1234'    
            ); 
              Test.startTest();
            insert a4;
              Test.stopTest();
        }
    }
    
    public static testMethod void testNationalChurchWithCustomRegistrationSettings()
    {
         Test.startTest();
        // get church record type
        String RecordTypeId = null;
       //TR  US Church is now US Organization    
      //      List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }

        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0) { delete settings_list; }

        // insert custom settings
        Church_Registration__c settings;
        settings = new Church_Registration__c(
            Name='RegistrationSettings', 
            Execute_Status__c = 'Added',
            Last_Customer_Number__c = '9000000',
            Enable_Trigger_for_National__c = true, 
            Enable_Trigger_for_International__c = false,
            Enable_Trigger_for_Canada__c = false,
            Enable_Trigger_for_Person_Accounts__c = false,
            Default_Term_Business__c = 'Net 30',
            Default_Term_Business_Unit__c = 'Internal',
            Default_Term_Employee__c = 'Credit Card',
            Default_Term_Missionary__c = 'Internal',
            Default_Term_Individual__c = 'Credit Card',
            Default_Term_International_Church__c = 'Net 30',
            Default_Term_Canada_Church__c = 'Net 30',
            Default_Term_US_Church__c = 'Net 30'
        ); insert settings;
        
        //system.debug([select Id, Name from Church_Registration__c where name='RegistrationSettings']);
        
        // test with registration settings
        Account a5 = new Account(
            RecordTypeId=RecordTypeId, 
            Name='Registration Trigger Test 5-NWCS', // national with custom settings
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Added',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000123'    
        ); 
        
        //system.debug('testNationalChurchWithCustomRegistrationSettings');
        //system.debug(a5);
         
        insert a5;
          Test.stopTest();
    }
    
    public static testMethod void testNationalChurchWithDifferentExecuteStatus()
    {
    Test.startTest();
        // get church record type
        String RecordTypeId = null;
       //TR  US Church is now US Organization    
      //      List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }

        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0) { delete settings_list; }

        // insert custom settings
        Church_Registration__c settings;
        settings = new Church_Registration__c(
            Name='RegistrationSettings', 
            Execute_Status__c = 'Added',
            Last_Customer_Number__c = '9000000',
            Enable_Trigger_for_National__c = true, 
            Enable_Trigger_for_International__c = false,
            Enable_Trigger_for_Canada__c = false,
            Enable_Trigger_for_Person_Accounts__c = false,
            Default_Term_Business__c = 'Net 30',
            Default_Term_Business_Unit__c = 'Internal',
            Default_Term_Employee__c = 'Credit Card',
            Default_Term_Missionary__c = 'Internal',
            Default_Term_Individual__c = 'Credit Card',
            Default_Term_International_Church__c = 'Net 30',
            Default_Term_Canada_Church__c = 'Net 30',
            Default_Term_US_Church__c = 'Net 30'
        ); insert settings;
        
        system.debug([select Id, Name from Church_Registration__c where name='RegistrationSettings']);
        
        // test with registration settings but an execute status set to not equal settings
        Account a6 = new Account(
            RecordTypeId=RecordTypeId, 
            Name='Registration Trigger Test 6-NWDES', // national with different execute status
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Test',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000123'    
        ); 
          
        insert a6;
          Test.stopTest();
    }
    
    
    public static testMethod void testNationalChurchWithoutRegistrationSettings()
    {
     Test.startTest();
        String RecordTypeId = null;
       //TR  US Church is now US Organization    
      //      List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
        
        // test without the registration settings
        List<Church_Registration__c> settings_list = [select Id, Name From Church_Registration__c where Name='RegistrationSettings'];
        if(settings_list.size() > 0) { delete settings_list; }
        
        Account a7 = new Account(
            RecordTypeId=RecordTypeId, 
            Name='Registration Trigger Test 7-NWOS', // national without custom settings
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Added',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000123'        
        ); 
         
        insert a7;
          Test.stopTest();
    }
    
    public static testMethod void testInternationalChurchWithCustomRegistrationSettings()
    {
        Test.startTest();
        // get church record type
        String RecordTypeId = null;
        List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'International Church'];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }

        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0) { delete settings_list; }

        // insert custom settings
        Church_Registration__c settings;
        settings = new Church_Registration__c(
            Name='RegistrationSettings', 
            Execute_Status__c = 'Added',
            Last_Customer_Number__c = '9000000',
            Enable_Trigger_for_National__c = false, 
            Enable_Trigger_for_International__c = true,
            Enable_Trigger_for_Canada__c = false,
            Enable_Trigger_for_Person_Accounts__c = false,
            Default_Term_Business__c = 'Net 30',
            Default_Term_Business_Unit__c = 'Internal',
            Default_Term_Employee__c = 'Credit Card',
            Default_Term_Missionary__c = 'Internal',
            Default_Term_Individual__c = 'Credit Card',
            Default_Term_International_Church__c = 'Net 30',
            Default_Term_Canada_Church__c = 'Net 30',
            Default_Term_US_Church__c = 'Net 30'
        ); insert settings;
        
        // test with registration settings
        Account a8 = new Account(
            RecordTypeId=RecordTypeId, 
            Name='Registration Trigger Test 8-IWCS', // international with custom settings
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Added',
            ISO_Code__c='IN', // San Francisco in India!?... whatever..
            Mailing_Address_Book__c = '000123'    
        ); 
          
        insert a8;
          Test.stopTest();
    }
    
    public static testMethod void testCanadaChurchWithCustomRegistrationSettings()
    {
     Test.startTest();
        // get church record type
        String RecordTypeId = null;
        List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'Canada Church'];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }

        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0) { delete settings_list; }

        // insert custom settings
        Church_Registration__c settings;
        settings = new Church_Registration__c(
            Name='RegistrationSettings', 
            Execute_Status__c = 'Added',
            Last_Customer_Number__c = '9000000',
            Enable_Trigger_for_National__c = false, 
            Enable_Trigger_for_International__c = false,
            Enable_Trigger_for_Canada__c = true,
            Enable_Trigger_for_Person_Accounts__c = false,
            Default_Term_Business__c = 'Net 30',
            Default_Term_Business_Unit__c = 'Internal',
            Default_Term_Employee__c = 'Credit Card',
            Default_Term_Missionary__c = 'Internal',
            Default_Term_Individual__c = 'Credit Card',
            Default_Term_International_Church__c = 'Net 30',
            Default_Term_Canada_Church__c = 'Net 30',
            Default_Term_US_Church__c = 'Net 30',
            Default_Term_Non_Traditional__c = 'Credit Card'
        ); insert settings;
        
        // test with registration settings
        Account a9 = new Account(
            RecordTypeId=RecordTypeId, 
            Name='Registration Trigger Test 9-CWCS', // canada with custom settings
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Added',
            ISO_Code__c='CA', // San Francisco in Canada!?... whatever..
            Mailing_Address_Book__c = '000123',
            Registration_Number__c='US1234'
            
        ); 
        
        insert a9;
         Test.stopTest();
    }
    
    public static testMethod void testBusiness()
    {
     Test.startTest();
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get business record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'Business'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with registration settings
            Account a10 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 10-BWDS', // business with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US'
                //Mailing_Address_Book__c = '000123'    
            ); 
            
            insert a10;
            
            // Make sure Business Account does not have Mailing_Address_Book__c or Registration_Number__c
            System.assertEquals(a10.Mailing_Address_Book__c,null);
            System.assertEquals(a10.Registration_Number__c,null);
        }
         Test.stopTest();
    }
    
    public static testMethod void testBusinessUnit()
    {
     Test.startTest();
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get business unit record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'Business Unit'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with registration settings
            Account a11 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 11-BUWDS', // business unit with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US'
                //Mailing_Address_Book__c = '000123'    
            ); 
            
            insert a11;
        
            // Make sure Business Unit Account does not have Mailing_Address_Book__c or Registration_Number__c
            System.assertEquals(a11.Mailing_Address_Book__c,null);
            System.assertEquals(a11.Registration_Number__c,null);
        }
         Test.stopTest();
    }
    
    public static testMethod void testEmployee()
    {
        Test.startTest();
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get employee record type
            String RecordTypeId = null;
            //List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'Employee'];
            //if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with registration settings
            Account a12 = new Account(
              //  RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 12-BUWDS',
                //FirstName='Registration Trigger',
                //LastName='Test 12-EWDS', // employee with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US',
                Mailing_Address_Book__c = '000123',
                Registration_Number__c='US1234'

            ); 
            
            insert a12;
        }
         Test.stopTest();
    }
    
    public static testMethod void testMissionary()
    {
     Test.startTest();
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get missionary record type
            String RecordTypeId = null;
            //List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'Missionary'];
            //if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with registration settings
            Account a13 = new Account(
              //  RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 13-BUWDS',
                //FirstName='Registration Trigger',
               // LastName='Test 13-MWDS', // missionary with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US',
                Mailing_Address_Book__c = '000123',
                Registration_Number__c='US1234'
            ); 
            
            insert a13;
        }
         Test.stopTest();
    }
    
    public static testMethod void testIndividual()
    {
     Test.startTest();
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get individual record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'Individual'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with registration settings
            Account a14 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 14-BUWDS',
                //FirstName='Registration Trigger',
                //LastName='Test 14-INWDS', // individual with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='US',
                Mailing_Address_Book__c = '000123',
                Registration_Number__c='US1234'

            ); 
            
            insert a14;
        }
         Test.stopTest();
    }
    public static testMethod void testNewRegCountry()
    {
     Test.startTest();
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get individual record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            // test with registration settings
            Account a14 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test New Reg Country',
                //FirstName='Registration Trigger',
                //LastName='Test 14-INWDS', // individual with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added',
                ISO_Code__c='ZZ',
                Type='Church'
                
            ); 
            
            insert a14;
        }
         Test.stopTest();
    }
    /*
    public static testMethod void testKMChurch2()
    {
        // make sure registration settings exist for default use
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0)
        {
            // get business unit record type
            String RecordTypeId = null;
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'KM Church'];
            if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
            
            // test with registration settings
            Account a15 = new Account(
                RecordTypeId=RecordTypeId, 
                Name='Registration Trigger Test 15-KMWDS', // business unit with default settings
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                Default_Terms__c=null, 
                Status__c='Added'
            ); 
            
            insert a15;
        
            // Make sure KM Church Account does not have  Registration_Number__c
            System.assertEquals(a15.Registration_Number__c,null);
            System.assertEquals(a15.ISO_Code__c,null);
        }
    }
    */
    public static testMethod void testVariousUSOrganizations()
    {
     Test.startTest();
        // get church record type
        String RecordTypeId = null;
        List<Account> AcctsToInsert = new List<Account>();
        List<Church_Registration__c> settings_list = [select Id, Name from Church_Registration__c where name='RegistrationSettings'];
        if(settings_list.size() > 0) { delete settings_list; }
        
       //TR  US Church is now US Organization    
      //      List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Church'];
            List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name = 'US Organization'];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }

        // insert custom settings
        Church_Registration__c settings;
        settings = new Church_Registration__c(
            Name='RegistrationSettings', 
            Execute_Status__c = 'Added',
            Last_Customer_Number__c = '9000000',
            Enable_Trigger_for_National__c = true, 
            Enable_Trigger_for_International__c = false,
            Enable_Trigger_for_Canada__c = false,
            Enable_Trigger_for_Person_Accounts__c = false,
            Default_Term_Business__c = 'Net 30',
            Default_Term_Business_Unit__c = 'Internal',
            Default_Term_Employee__c = 'Credit Card',
            Default_Term_Missionary__c = 'Internal',
            Default_Term_Individual__c = 'Credit Card',
            Default_Term_International_Church__c = 'Net 30',
            Default_Term_Non_Traditional__c = 'Credit Card',
            Default_Term_Canada_Church__c = 'Net 30',
            Default_Term_US_Church__c = 'Net 30'
        ); insert settings;
        
        system.debug([select Id, Name from Church_Registration__c where name='RegistrationSettings']);
        
        // test with registration settings but an execute status set to not equal settings
        Account a16 = new Account(
            RecordTypeId=RecordTypeId, 
            Type='YMCA',
            Name='Registration Trigger Test 16-ORGYMCA', // national with different execute status
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Test',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000127',
            Registration_Number__c  ='US127'            
        ); 
        AcctsToInsert.add(a16 );
        Account a17 = new Account(
            RecordTypeId=RecordTypeId, 
            Type='Homeschool',
            Name='Registration Trigger Test 17-ORGHSCHOOL', // national with different execute status
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Test',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000126',
            Registration_Number__c  ='US126'            
        ); 
         AcctsToInsert.add(a17 );
         Account a18 = new Account(
            RecordTypeId=RecordTypeId, 
            Type='Homeschool',
            Name='Registration Trigger Test 18-ORGCHURCH', // national with different execute status
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Test',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000125',
            Registration_Number__c  ='US125'            
        ); 
         AcctsToInsert.add(a18 );
         Account a19 = new Account(
            RecordTypeId=RecordTypeId, 
            Type='Homeschool - Multi-family',
            Name='Registration Trigger Test 19-ORGCHURCH', // national with different execute status
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Test',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000124',
            Registration_Number__c  ='US124'            
        ); 
         AcctsToInsert.add(a19 );
        Account a20 = new Account(
            RecordTypeId=RecordTypeId, 
            Type='Homeschool - Single-family',
            Name='Registration Trigger Test 20-ORGCHURCH', // national with different execute status
            BillingStreet='1600 Amphitheatre Parkway', 
            BillingCity='Mountain View',
            BillingState='CA',
            BillingPostalCode='94043',
            BillingCountry='UNITED STATES',
            Mailing_Street_1__c='The Landmark @ One Market',
            Mailing_Street_2__c='Suite 300',
            Mailing_City__c='San Francisco',
            Mailing_State_Province__c='CA',
            Mailing_Zip_Postal_Code__c='94105',
            Mailing_County__c='San Francisco',
            Mailing_Country__c='UNITED STATES',
            Date_Inactive__c=Date.Today().addDays(90), 
            Default_Terms__c=null, 
            Status__c='Test',
            ISO_Code__c='US',
            Mailing_Address_Book__c = '000123',
            Registration_Number__c  ='US123'        
        ); 
         AcctsToInsert.add(a20 );
        
       /* insert a16;
        insert a17;
        insert a18;
        insert a19;
        insert a20;
        */
        insert AcctsToInsert;
         Test.stopTest();
    }
}