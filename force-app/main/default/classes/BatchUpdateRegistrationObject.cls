/*****************************************
    Programmer: Matthew Keefe
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Salesforce
    Original:   03/09/2010
    Updated:    06/04/2010 - readying for production 
    Updated:    03/22/2011 - updated for custom settings
    Updated:    01/26/2012 - (TW) Moved update_account flag to within the Account Processing loop and generlized email msg. literal strings
    Updated     02/05/2012 - (TW) Updated comment for Accounts updated in FinishEmail. Changed OwnerShip to Awana Application.
    Updated     10/25/2012 - (TR) Updated for US Church to US Organization account record type name change.
    ** Execute Anonymous Code **     
    -- Count Registrations --
    Integer i = [Select count() From Registration_History__c Where CreatedById = '00550000000vuyG']; system.debug(i);

    -- Delete Registrations --
    List <Registration_History__c> registrations = [Select Id From Registration_History__c Where CreatedById = '00550000000vuyG' Limit 9999];
    delete registrations;

    -- Execute Batch -- 
    BatchUpdateRegistrationObject job = new BatchUpdateRegistrationObject(); 
    job.finishEmailList = new String[] {'mattk@awana.org'}; ID batchprocessid = Database.executeBatch(job, 100); 
 *****************************************/
global class BatchUpdateRegistrationObject implements Database.Batchable<sObject>     
{
    // global variables
    global final Registration_History_Setting__c settings;
    
    global String query;
    global Boolean test;
    
    global String[] finishEmailList;
    
    // constructor
    global BatchUpdateRegistrationObject() 
    {
        List<Registration_History_Setting__c> all_settings = [Select Id, 
            Enable_for_Canada_Accounts__c, 
            Enable_for_International_Accounts__c, 
            Enable_for_United_States_Accounts__c, 
            Update_Account_Status_on_Renew__c, 
            Account_Hold_on_Expiraiton_Date__c, 
            Drop_Grace_Period_in_Days__c, 
            Drop_Expired_Accounts__c,
            Finish_Email_List__c,  
            Limit__c
            From Registration_History_Setting__c];
        
        if(!all_settings.isEmpty()) 
        { 
            settings = all_settings[0]; 
        } 
        else 
        { 
            settings = new Registration_History_Setting__c(
                Enable_for_International_Accounts__c=false,Enable_for_Canada_Accounts__c=false,Enable_for_United_States_Accounts__c=true);
        }
        
        if(settings.Drop_Grace_Period_in_Days__c == null)
        {
            settings.Drop_Grace_Period_in_Days__c = 30;
        }
    }
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        if(query == null) 
        {
            query = 
                'Select Id, Name, Batch_Status__c, RecordTypeId, RecordType.Name, Status__c, ' 
                + 'Account_on_Hold__c, Hold_Comments__c, Date_Inactive__c, Reason_Dropped__c, Registration_Date__c ' 
                + 'From Account '
          //TR  US Church is now US Organization    
             //  + 'Where RecordType.Name like \'%Church%\' ';
               + 'Where (RecordType.Name like \'%Church%\' Or RecordType.Name like \'%Organization%\')';
           
            // if the settings dictate, ignore certain record types
      //TR  US Church is now US Organization     
         // if(!settings.Enable_for_United_States_Accounts__c) { query += 'And RecordType.Name != \'US Church\' '; }            // ignore US (National) Churches
          if(!settings.Enable_for_United_States_Accounts__c) { query += 'And RecordType.Name != \'US Organization\' '; }      // ignore US (National) Organizations
            if(!settings.Enable_for_International_Accounts__c) { query += 'And RecordType.Name != \'International Church\' '; } // ignore International Churches 
            if(!settings.Enable_for_Canada_Accounts__c) { query += 'And RecordType.Name != \'Canada Church\' '; }               // ignore Canada Churches
            
            if(test != null) { if(test) { query += ' And Status__c=\'Test\' '; } }
            
            if(settings.Limit__c > 0) { query += ' Limit ' + String.valueOf(settings.Limit__c); }
            
            query += ' ';
        }
        
        system.debug(query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug(settings);
        
        Registration_History__c registration = null;
        List<Registration_History__c> registrations = null;
        List<Registration_History__c> registrations_to_insert = new List<Registration_History__c>();
        List<Account> accounts_to_update = new List<Account>();
        
        string default_registration_reason = 'Registration History record automatically added';
        
        boolean update_account;
        
        for(sObject s : scope)
        {
            // TW: 1-26-2010 Moved update_account to within loop in order to reset the flag for each account
            update_account = false;
            //TW: END
            Account a = (Account)s;
            
            registration = null;
            registrations = [Select Id, Name, Account__c, Status__c, Reason__c From Registration_History__c Where Account__c=:a.Id Order By Name DESC];
            
            system.debug(registrations);
            
            if(registrations.size() > 0) // if there is a registration history record
            {
                registration = registrations[0]; // set the registration object
                system.debug(registration);
                
                if(a.Status__c != null)
                {
                    // insert a new registration if the status is different
                    if(registration.Status__c != a.Status__c) { 
                        registrations_to_insert.add(new Registration_History__c(
                            Account__c=a.Id, Status__c=a.Status__c, Reason__c=default_registration_reason,
                            Registration_Date__c = a.Registration_Date__c, // account registration date 
                            Expiration_Date__c = a.Date_Inactive__c)); } // expiration date
                }
            }
            else // if there's not a registration record, lets make sure there will be 
            { 
                if(a.Status__c != null)
                {
                    registrations_to_insert.add(new Registration_History__c(
                        Account__c=a.Id, Status__c=a.Status__c, Reason__c=default_registration_reason,
                        Registration_Date__c = a.Registration_Date__c, // account registration date 
                        Expiration_Date__c = a.Date_Inactive__c)); // expiration date 
                }
            } 
            
            // auto-renew if settings dictate
            if(settings.Update_Account_Status_on_Renew__c)
            {
                if(a.Status__c != null)
                {
                    if(a.Status__c.toLowerCase().contains('renewed'))
                    {
                        update_account = true;
                        a.Status__c = 'Added';
                        if(a.Date_Inactive__c != null) { a.Date_Inactive__c = a.Date_Inactive__c.addYears(1); }
                        a.Account_On_Hold__c = false;
                        registrations_to_insert.add(new Registration_History__c(
                            Account__c=a.Id, Status__c=a.Status__c, Reason__c=default_registration_reason+' because the Account Status was Renewed',
                            Registration_Date__c = a.Registration_Date__c, // account registration date 
                            Expiration_Date__c = a.Date_Inactive__c)); // expiration date
                    }
                }
            }
            
            // auto-hold if settings dictate
            if(settings.Account_Hold_on_Expiraiton_Date__c)
            {
                // don't do anything if the account's date inactive field does not have a value
                if(a.Date_Inactive__c != null)
                {
                    // if expiration date (date inactive) has passed (today is greater than date inactive), put account on hold
                    if(Date.Today() > a.Date_Inactive__c)
                    {
                        if(!a.Account_On_Hold__c) 
                        {
                            a.Account_On_Hold__c = true; update_account = true;
                        }
                    }
                }

                if(a.Account_On_Hold__c)
                {
                    boolean registration_history_contains_hold = false;
                    
                    for(Integer i=0; i<2; i++)
                    {
                        //system.debug(i); system.debug(registrations.size());
                        
                        if(i+1 < registrations.size())
                        {
                            if(registrations[i].Status__c != null) {
                                if(registrations[i].Reason__c.toLowerCase().contains('hold')) {
                                    registration_history_contains_hold = true; } }
                        }
                    }
                    
                    if(!registration_history_contains_hold)
                    {
                        registrations_to_insert.add(new Registration_History__c(
                            Account__c=a.Id, Status__c=a.Status__c, Reason__c='Account Hold: expiration date (date inactive) has passed',
                            Registration_Date__c = a.Registration_Date__c, // account registration date 
                            Expiration_Date__c = a.Date_Inactive__c)); // expiration date
                    }
                }
            }
            
            // auto-drop if settings dictate
            if(settings.Drop_Expired_Accounts__c)
            {
                // don't do anything if the account's date inactive field does not have a value
                if(a.Date_Inactive__c != null)
                {
                    // if expiration date (date inactive) plus the grace period has passed (today is greater than date inactive plus grace), drop the account
                    if(Date.Today() > a.Date_Inactive__c.addDays(settings.Drop_Grace_Period_in_Days__c.intValue()))
                    {
                        if(a.Status__c != null) 
                        {
                            if(!a.Status__c.toLowerCase().contains('dropped'))
                            {
                                update_account = true;
                                a.Status__c = 'Dropped';
                                if(!a.Account_On_Hold__c) { a.Account_On_Hold__c = true; }
                                registrations_to_insert.add(new Registration_History__c(
                                    Account__c=a.Id, Status__c='Dropped', 
                                    Reason__c='The grace period (of '+String.valueOf(settings.Drop_Grace_Period_in_Days__c)+' days) for passing an expiration date (date inactive) has passed', 
                                    Registration_Date__c = a.Registration_Date__c, // account registration date 
                                    Expiration_Date__c = a.Date_Inactive__c)); // expiration date
                            } 
                        }
                    }
                }
            }
            
            // if any previous conditions changed the account, add the account to the update list
            // a variable is used to prevent adding twice
            if(update_account)
            {
                accounts_to_update.add(a);
            }
        }
        
        for(Account temp_account : accounts_to_update) {
            temp_account.Batch_Status__c = String.valueOf(Date.Today()); }
        
        try
        {
            // the database.dml methods must be used here to allow partial success (as indicated by the false boolean parameter) 
            if(!accounts_to_update.isEmpty()) { Database.update(accounts_to_update,false); }
            if(!registrations_to_insert.isEmpty()) { Database.insert(registrations_to_insert,false); } 
        } catch(Exception exc) { system.debug(exc); }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(settings.Finish_Email_List__c != null)
        {
            string emails = settings.Finish_Email_List__c;
            emails = emails.replaceAll('[\t ]*','');
            finishEmailList = emails.split(',');
            
            if(finishEmailList.size() > 0)
            {
                if(finishEmailList[0].length() > 1)
                {
                    // get created/updated registration historys
                    String registrationsProcessed = ' ';
                    String accountsProcessed = ' ';
                    DateTime dtYesterday = DateTime.now().addHours(-6);
                    
                    Integer upperLimit = 50000;
                    Decimal count = 0;
                    
                    count = [Select count() From Registration_History__c Where LastModifiedDate > :dtYesterday Limit :upperLimit];
                    //count = countRegistrationsAdded;
                    registrationsProcessed += String.valueOf(count);
                    if(count==upperLimit) { registrationsProcessed += '+'; }
                    registrationsProcessed += ' Registration History object(s) processed within the last 6 hours. ';
                    
                    String dToday = '%'+String.valueOf(Date.Today())+'%';
                    count = [Select count() From Account Where Batch_Status__c like :dToday Limit :upperLimit];
                    //count = countAccountsUpdated;
                    accountsProcessed += String.valueOf(count);
                    if(count==upperLimit) { accountsProcessed += '+'; } 
                    //TW: 1-26-2012: Removed the on-hold,drop status of the following string 
                    accountsProcessed += ' Account object(s) updated within the last 24 hours. ';
                    //TW: End
                    // begin to define email object
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    mail.setToAddresses(finishEmailList);
                    mail.setReplyTo('mattk@awana.org');
                    mail.setSenderDisplayName('Batch Processing');
                    mail.setSubject('Registration History Batch Process Completed');
                    mail.setPlainTextBody('Batch Process has completed. \n'+registrationsProcessed+'\n'+accountsProcessed);
                    
                    // send email
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    system.debug(result);
                }
            }
        }
    }
    
    public static testMethod void testBatch() 
    {
        // Get the Test settings replacing the set settings
        
        Registration_History_Setting__c settings;
        
        List<Registration_History_Setting__c> all_settings = [Select Id From Registration_History_Setting__c];
        if(!all_settings.isEmpty()) { delete all_settings; }
        
        settings = new Registration_History_Setting__c(
            Name = 'Registration History Test Settings',
            Enable_for_Canada_Accounts__c = true, 
            Enable_for_International_Accounts__c = true, 
            Enable_for_United_States_Accounts__c = true, 
            Update_Account_Status_on_Renew__c = true, 
            Account_Hold_on_Expiraiton_Date__c = true, 
            Drop_Grace_Period_in_Days__c = 30, 
            Drop_Expired_Accounts__c = true,
            Finish_Email_List__c = 'tonyw@awana.org, tonyw+test@awana.org', 
            Limit__c = 100
        ); insert settings;
        
        all_settings = [Select Id, Name, Enable_for_Canada_Accounts__c, Enable_for_International_Accounts__c, 
            Enable_for_United_States_Accounts__c, Update_Account_Status_on_Renew__c, Account_Hold_on_Expiraiton_Date__c, 
            Drop_Grace_Period_in_Days__c, Drop_Expired_Accounts__c, Finish_Email_List__c, Limit__c From Registration_History_Setting__c];
        system.debug(all_settings);
        
        // Create some test accounts - this simulates one execute.
        // Important - the Salesforce.com test framework only allows you to test one execute.    
        
        String RecordTypeId = null;
     //TR US Church is now US Organization  and only the US is changing
      //  List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name like '%Church%' And Name != 'International Church' And Name != 'Canada Church'];
        List<RecordType> rec = [Select Id, Name From RecordType Where SobjectType = 'Account' And Name like '%Organization%' And (Name != 'International Church' And Name != 'Canada Church')];
        if(rec.size() > 0) { RecordTypeId = rec[0].Id; }
        
        List<Account> acc = new List<Account>();
        List<Registration_History__c> reg = new List<Registration_History__c>();
        /*
        for(integer i = 1; i<=3; i++)
        {
            Account a = new Account(  // Renewed test.
                Name='Batch Registration Object Update Test '+i, 
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
                RecordTypeId=RecordTypeId, 
                Status__c='Test'
            ); 
            
            acc.add(a);
        } Loop
        */
        // add another test to run through 
        acc.add(
            new Account(
                Name='Batch Registration Object Update Test 4', 
                BillingStreet='Google\n1600 Amphitheatre Parkway', 
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
                Date_Inactive__c=Date.Today().addDays(-90), 
                RecordTypeId=RecordTypeId, 
                Status__c='Test'
            )
        );
        
        // add another test to run through
       
        acc.add(
            new Account(
                Name='Batch Registration Object Update Test 5', 
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
                RecordTypeId=RecordTypeId, 
                Status__c='Test'
            )
        );
        
        // add another test to run through 
        acc.add(
            new Account(
                Name='Batch Registration Object Update Test 6', 
                BillingStreet='Google\n1600 Amphitheatre Parkway', 
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
                Date_Inactive__c=Date.Today().addDays(-90), 
                RecordTypeId=RecordTypeId, 
                Status__c='Dropped'
            )
        ); 
        
        acc.add(
            new Account(
                Name='Batch Registration Object Update Test 7', 
                BillingStreet='Google\n1600 Amphitheatre Parkway', 
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
                Date_Inactive__c=Date.Today(), 
                RecordTypeId=RecordTypeId, 
                Status__c='Test'
            )
        );
        
        insert acc;
        
        system.debug(acc);
        
        for(Account a : acc)
        {
             
            if(a.Name.contains('5')) {
                system.debug('<<Updating Registration History: Test - 5>>');
                reg.add(new Registration_History__c(
                    Account__c=a.Id, Status__c='Test', Reason__c='This registration object is for testing only!')
                ); }
              
            if(a.Name.contains('6')) {
                system.debug('<<Updating Registration History: Dropped - 6>>');
                reg.add(new Registration_History__c(
                    Account__c=a.Id, Status__c='Dropped', Reason__c='This registration object is for testing only!')
                ); }
               
            if(a.Name.contains('6')) {
                system.debug('<<Updating Registration History: Test - 6>>');
                reg.add(new Registration_History__c(
                    Account__c=a.Id, Status__c='Test', Reason__c='Hold; This registration object is for testing only!')
                ); }
                
            if(a.Name.contains('7')) {
                system.debug('<<Updating Registration History: Test - 7>>');
                reg.add(new Registration_History__c(
                    Account__c=a.Id, Status__c='Test', Reason__c='This registration object is for testing only!')
                ); }
        }

        insert reg;
        system.debug(reg);
        
        Test.StartTest();
        system.debug('*** Test Started ***');

        // run batch
        BatchUpdateRegistrationObject job = new BatchUpdateRegistrationObject();
        job.test = true;
        ID batchprocessid = Database.executeBatch(job, 10);
        
        BatchUpdateRegistrationOnSchedule sch1 = new BatchUpdateRegistrationOnSchedule();
        String sch = '0 50 15 30 6 ? *';
        String jobID = system.schedule('Registration', sch, sch1);
        
        system.debug('*** Test Finished ***');
        Test.StopTest();  
    }
}