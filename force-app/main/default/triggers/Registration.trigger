/*****************************************
    Programmer: Matthew Keefe
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Account Registration in Salesforce
    Updated:    02/11/2010
    Updated: (TW)08/13/2012 Making sure that KM Churches do not get Registration Numbers. Added Km Default Termms to Church registration.
    Updated: (TW)08/17/2012 Adedd SOQL Query to retrieve KM Church Record Type for  previous 08/13/2012 updates.
    Updated: (TW)08/27/2012 Updated rec Record Type field to KMCRec for clarification referring to KM Church Id.
    Updated: (TW)09-06-2012: Added Satellite church update because we do not want to add ISO numbers nor registration IDs for these church types.
    Conditions: 
    Updated:(TW) 10-23-2012 Substituting 'US Church' with 'US Orgnaization' while also allowing Default Payment terms for Homeschool Account Type. 
    Updated:    06/05/2015 - Updated the Person Accounts condition to include Business Accounts so that Cutomer IDs will be auto-generated.
    --------------------------------------
    This trigger will generate a new 
    Customer Number, Registration Number, and Default Terms IF:
     - Church Account Registration Number is NULL and 
     - Church Account Mailing Address Book is NULL and 
     - Church Account Default Term is NULL
    OR
     - Person Account Mailing Address is NULL and 
     - Person Account is a Person Account and 
     - Person Account Default Term is NULL

 *****************************************/
 
trigger Registration on Account (before insert, before update) {
   List<Account> allChurchesOrPersons = Trigger.new;
    List<Account> registrationChurchesOrPersons = new List<Account>();
    //TW: 09-06-2012: Added satellite checking in order to by pass registrations
    boolean isSATChurch = false;
    //1-12-2015 Added checkRecursion to avoid triggers firing more than once for a transaction such as thie followiing:
   Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');   
    
   if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
    for(Integer i=0; i<allChurchesOrPersons.size(); i++) 
    {   // get the current church or person
        Account church_or_person = allChurchesOrPersons[i];
        // do not continue if the customer id and(/or) registration id are filled in 
        if( (church_or_person.Registration_Number__c != null && church_or_person.Mailing_Address_Book__c != null && church_or_person.Default_Terms__c != null) ||  
            (church_or_person.Mailing_Address_Book__c != null &&  church_or_person.Default_Terms__c != null) ) //church_or_person.IsPersonAccount == true &&
        { 
            system.debug('Invalid conditions for Registration.trigger - Account: '+allChurchesOrPersons[i].Id); 
        }
        else
        { 
            registrationChurchesOrPersons.add(allChurchesOrPersons[i]); 
        }
    }
    
    if(registrationChurchesOrPersons.size() == 0) { return; }
    //TW 10-23-2012:  Adding new Non-Traditional Default Term in SOQL query.
    List<RecordType> accountTypes = [select SobjectType, Name, Id from RecordType where SobjectType = 'Account'];
    List<Church_Registration__c> settings_list = [select Id, Name, Execute_Status__c, 
        Enable_Trigger_for_National__c, Enable_Trigger_for_International__c, Enable_Trigger_for_Canada__c, 
        EnabLe_Trigger_for_Person_Accounts__c, 
        Default_Term_Business__c, Default_Term_Business_Unit__c, Default_Term_Employee__c, Default_Term_Missionary__c, 
        Default_Term_Individual__c,Default_Term_KM_Church__c, Default_Term_International_Church__c, Default_Term_Canada_Church__c, 
        Default_Term_US_Church__c,Default_Term_Non_Traditional__c
        from Church_Registration__c where name='RegistrationSettings'];
    
    Church_Registration__c settings;
    if(settings_list.size() > 0) 
    { 
        settings = settings_list[0]; 
    }
    else
    {
        /*
        settings = new Church_Registration__c(
            Name='RegistrationSettings',
            Execute_Status__c = 'Added',
            Last_Customer_Number__c = '9000000',
            Enable_Trigger_for_National__c = true, 
            Enable_Trigger_for_International__c = true,
            Enable_Trigger_for_Canada__c = true,
            Enable_Trigger_for_Person_Accounts__c = true,
            Default_Term_Business__c = 'Net 30',
            Default_Term_Business_Unit__c = 'Internal',
            Default_Term_Employee__c = 'Credit Card',
            Default_Term_Missionary__c = 'Internal',
            Default_Term_Individual__c = 'Credit Card',
            Default_Term_International_Church__c = 'Net 30',
            Default_Term_Canada_Church__c = 'Net 30',
            Default_Term_US_Church__c = 'Net 30'
        );
        
        insert settings;
        */
        
        system.debug('Empty or non-existing  Church Settings'); 
        return;
    }
    
     string execute_status = settings.Execute_Status__c;
    
    //TW 8-17-2012 Added SOQL for KM Church comparisons.
    //27th Dec'17 commented by Ayesha- KM Church record type is deprecated
    //RecordType KMCrec = [Select Id from recordType where SObjectType = 'Account' and RecordType.Name = 'KM Church'];
    
    for(Account church_or_person : registrationChurchesOrPersons)
    {
    
        boolean correctChurchType = false;
        boolean correctPersonType = false;
        
        //Verify Church and Oganizations Here:
        for(RecordType accountType : accountTypes) 
        {
            //TW: 10-23-2012 Substitute old Recordt Type = 'Church' with new Record Type 'US Organization'  and account type = 'Church for Satellite Church condition.
            //if(accountType.Name.contains('Church') && !isSATChurch)
            if(church_or_person.RecordTypeId == accountType.Id){
                //if((accountType.Name.contains('Organization') || accountType.Name.contains('Church')) && !isSATChurch){
                    //if((accountType.Name.contains('Organization') || accountType.Name.contains('Church') ) && !isSATChurch){
                    //SF-288 exclude contains Organization. It should work for 'US Organization' only.
                    if((accountType.Name == 'US Organization'  || accountType.Name.contains('Church') ) && !isSATChurch){
                    system.debug('AccountType.Name contains Church');
                    //SF-288 exclude contains Organization. It should work for 'US Organization' only.
                    if(settings.Enable_Trigger_for_National__c && settings.Enable_Trigger_for_International__c && settings.Enable_Trigger_for_Canada__c && accountType.Name != 'Organization') {
                        correctChurchType = true; }
                    else
                    {
                        
                        if((accountType.Name == 'US Organization') && settings.Enable_Trigger_for_National__c) { 
                            correctChurchType = true; }
                        if(accountType.Name == 'International Church' && settings.Enable_Trigger_for_International__c) {
                            correctChurchType = true; }
                        if(accountType.Name == 'Canada Church' && settings.Enable_Trigger_for_Canada__c) {
                            correctChurchType = true; }
                    } 
                     // make sure there is a correct ISO_Code__c before continuing
                    if(church_or_person.Status__c == execute_status && accountType.Name != 'KM Church' ){
                        string country_code_error_message = 'A two character country code is required to create a registration number.';
                        string country_code_length_error_message = 'The country code must be two characters to create a registration number.';
                        
                        if(accountType.Name.contains('International') || accountType.Name.contains('Canada'))
                        {
                            system.debug('AccountTypeName contains International');
                            
                            if(church_or_person.ISO_Code__c != null)
                            {
                                if(church_or_person.ISO_Code__c.length() < 2) { church_or_person.ISO_Code__c.addError(country_code_length_error_message); return; }
                            }
                            else 
                            { 
                                church_or_person.ISO_Code__c.addError(country_code_error_message+' You supplied: '+church_or_person.ISO_Code__c);
                                return; 
                            }
                        }
                        else
                        {
                            system.debug('AccountTypeName does not contain International');
                            
                            if(church_or_person.ISO_Code__c == null) 
                            { 
                                system.debug('ISO Code is null; setting to US');
                                church_or_person.ISO_Code__c = 'US'; 
                            }
                        }
                    }//IF != KM Church  
                }// IF !=SAT
                
                // Verify Individual Accounts Here:
                system.debug('AccountType.Name = Individual Churches');
                //Added by CK Infoglen for including Household Account to generate the Customer Number
                if(accountType.Name.contains('Individual') || accountType.Name.contains('Missionary') || accountType.Name.contains('Household')  || 
                    accountType.Name.contains('Employee') || accountType.Name == 'Business')
                { // 06/05/2015:  See header for explaination of update for this date.
                    system.debug('AccountType.Name contains Individual, Missionary, or Employee. Type Match: '+string.valueOf(church_or_person.RecordTypeId == accountType.Id)+', RecordTypeId='+church_or_person.RecordTypeId+' AccountType='+accountType.Id);
                
                    if(church_or_person.RecordTypeId == accountType.Id) {
                        system.debug('Account.RecordTypeId MATCHES Individual, Missionary, or Employee'); 
                    
                        if(settings.Enable_Trigger_for_Person_Accounts__c) { correctPersonType = true; } 
                    }
                }
                if(church_or_person.Default_Terms__c == null){
                    if(accountType.Name == 'Business') { church_or_person.Default_Terms__c = settings.Default_Term_Business__c; }
                    if(accountType.Name == 'Business Unit') { church_or_person.Default_Terms__c = settings.Default_Term_Business_Unit__c; }
                    //TW: 10-23-2012 With the new Record Type 'US Organization' being substituted 
                    //if(accountType.Name == 'US Church') { church_or_person.Default_Terms__c = settings.Default_Term_US_Church__c; }
                    if(accountType.Name == 'US Organization' && church_or_person.Type == 'Church') { church_or_person.Default_Terms__c = settings.Default_Term_US_Church__c; }
                    if(accountType.Name == 'US Organization' && church_or_person.Type != 'Church') { church_or_person.Default_Terms__c = settings.Default_Term_Non_Traditional__c; }
                    //End 10-23-2012
                    if(accountType.Name == 'International Church') { church_or_person.Default_Terms__c = settings.Default_Term_International_Church__c; }
                    if(accountType.Name == 'Canada Church') { church_or_person.Default_Terms__c = settings.Default_Term_Canada_Church__c; }
                    if(accountType.Name == 'Missionary') { church_or_person.Default_Terms__c = settings.Default_Term_Missionary__c; }
                    if(accountType.Name == 'Employee') { church_or_person.Default_Terms__c = settings.Default_Term_Employee__c; }
                    if(accountType.Name == 'Individual') { church_or_person.Default_Terms__c = settings.Default_Term_Individual__c; }
                    //Added by CK Infoglen for Household
                     if(accountType.Name.contains('Household') ) { church_or_person.Default_Terms__c = settings.Default_Term_Individual__c; }
                    //8-15-2012 add a line for KM Churches for default terms to include Default_Terms in the settings list for KM Church as 'Credit Card'               
                    if(accountType.Name == 'KM Church') { church_or_person.Default_Terms__c = settings.Default_Term_KM_Church__c; }
                }// IF DEFAULT TERMS
                //            ******* Generate new Registration Number and/or Customer Number Section *******
                system.debug('******* Correct Church Type: '+String.valueOf(correctChurchType)+' Correct Person Type: '+String.valueOf(correctPersonType)+'; ');
                
                //Verify ISO Registration Codes Here:
                if(correctChurchType == true) {
                    system.debug('CorrectChurchType is true; getting a new registration number (pending validation) ');
            
                    if(church_or_person.Status__c == execute_status){
                    //TW: 08-13-2012:  Making sure that KM Churches do not get Registration Numbers.
                    //27th Dec'17 modified by Ayesha- KM Church record type is deprecated
                    if(church_or_person.Registration_Number__c == null){
                        try
                        {
                            if(church_or_person.ISO_Code__c == null) {church_or_person.ISO_Code__c = 'US';}
                            church_or_person.Registration_Number__c = registration.nextRegistrationNumber(church_or_person.ISO_Code__c);
                        }
                        catch(Exception e)
                        {
                            church_or_person.ISO_Code__c.addError('There was an error generating a new Registration Number for this account. A two character country code is required to create a registration number.');
                            church_or_person.Registration_Number__c.addError('Country Code: '+church_or_person.ISO_Code__c+'. '+'Could not generate a registration number and customer number from this Country. '+e.getMessage());
                        }
                    }
                }
            }//IF ISO Registration 
            
            //Verify Cusomter IDs here:
            if(correctChurchType == true || correctPersonType == true || accountType.Name == 'Organization'){
                system.debug('CorrectPersonType is true OR CorrectChurchType is true; getting a new customer number (pending validation) ');
            
                if( (church_or_person.Status__c == execute_status && correctChurchType == true) || (correctPersonType == true) ){
                    if( church_or_person.Mailing_Address_Book__c == null ){
                        try
                        {
                            church_or_person.Mailing_Address_Book__c = registration.nextCustomerNumber();
                        
                        }
                        catch(Exception e)
                        {
                            church_or_person.Mailing_Address_Book__c.addError('Could not generate a customer number. '+e.getMessage());
                        }
                    }
                }
            }//IF CUSTOMER ID
        }//If == RECORD TYPE 
    }//Inner For
    
   
  }// OUter FOR
  }
     }// Trigger