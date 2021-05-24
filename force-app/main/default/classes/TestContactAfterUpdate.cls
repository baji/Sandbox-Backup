/*********************************************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            TestContactAfterUpdate
    Original:           11/26/2014 - Used to test Contact update triggers.
    Updated:            09/10/2015 - Added ContactUpdate_Pardot testing to boost coverage.
     Updated:            7/11/2017 - Added SeeAllData=true. by Sohil
 ***********************************************************************************************************/ 
@IsTest
public class TestContactAfterUpdate {
    // Test Synchronzing of Addresses between Contact and its 1x1 Account
    public static testmethod void TestSynchronizeAddresses() {
    
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunContactTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        ConstitIdSeries__c ConstitIdSeries = new ConstitIdSeries__c();
        ConstitIdSeries.Name = 'ConstitIdStartNumber';
        ConstitIdSeries.ConstitSeriesNo__c = 5047150;
        insert ConstitIdSeries;
        
           //RecordType getRecordType = [Select Id from recordType where Name = 'Individual'];
           Id getRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            //RecordType getRecordType = new RecordType(Name='Individual');
             system.debug('<< RECTYPE>> '+getRecordType);
             
        Account acct = new Account();
        
        acct = new Account(Mailing_Street_1__c='323 W 101 Place',
                                    Mailing_City__c='Chicago',
                                    Mailing_State_Province__c='IL',
                                    Mailing_Country__c='United States',
                                    recordtypeId= getRecordType,
                                    Name='Tryring Times Church', ShippingCountry = 'United States');
                                    
                                
        
        insert acct;
        contact ct1 =  new Contact(
                                FirstName = 'Baji',
                                LastName = 'Shaik',
                                MailingStreet ='',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            );  
        insert ct1;
        system.debug('ctss**'+ct1);
        ct1.npe01__SystemAccountProcessor__c = 'One-to-One';
        ct1.MailingCity = 'Bangalore';
        update ct1;
        system.debug('ctssupdate**'+ct1);
        if(ct1.npe01__SystemAccountProcessor__c == 'One-to-One'){ 
            system.debug('dnkey++'+ct1.npe01__SystemAccountProcessor__c);
        }
        else{
            system.debug('monnkey**'+ct1.npe01__SystemAccountProcessor__c);
        }
           // Access Contact and update the  Mailing and Other addresses.
          
           /* List<Contact> cts = new List<Contact>();
          // Missing Mailing Street 
            cts.add(new Contact(
                                FirstName = 'Baji',
                                LastName = 'Shaik',
                                MailingStreet ='',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct,
                                npe01__SystemAccountProcessor__c = 'One-to-One'
                            )); 
            acct.npe01__One2OneContact__c = cts[0].id;
            update acct;
            // Missing Mailing City
            cts.add(new Contact(
                                FirstName = 'Baji',
                                LastName = 'Basha',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = '',
                                MailingCountry = 'United States',
                                MailingPostalCode = '60107',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
            // Missing Mailing Country
            cts.add(new Contact(
                                FirstName = 'Baji',
                                LastName = 'Manila',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = '',
                                MailingPostalCode = '60107',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
                            
           // Missing Mailing Postal  State
           cts.add(new Contact(
                                FirstName = 'Baji',
                                LastName = 'Srinivasan',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
                            
            // Missing Mailing State
             cts.add(new Contact(
                                FirstName = 'Baji',
                                LastName = 'Srinivasan',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '60107',
                                MailingState = '',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            ));
                                
            //Missing Other Street
            cts.add(new Contact(
                                FirstName = 'Kukla',
                                LastName = 'Olivera',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '60107',
                                MailingState = 'IL',
                                OtherStreet ='',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'United States',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
            //Missing Other City            
            cts.add(new Contact(
                                FirstName = 'Doug',
                                LastName = 'Hinjosa',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '60107',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = '',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
           // Missing Other State
          cts.add( new Contact(
                                FirstName = 'Dina',
                                LastName = 'Hinjosa',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '60617',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'United States',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
            // Missing Other Country
             cts.add( new Contact(
                                FirstName = 'Daniella',
                                LastName = 'Hinjosa',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Chicago',
                                MailingCountry = 'United States',
                                MailingPostalCode = '',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'United States',
                                OtherPostalCode = '60011',
                                Account = acct
                            )); 
                            
            // Missing Other Postal Code    
            cts.add( new Contact(
                                FirstName = 'Evita',
                                LastName = 'Hinjosa',
                                MailingStreet ='1 East Bode Rd.',
                                MailingCity = 'Streamwood',
                                MailingCountry = 'United States',
                                MailingPostalCode = '60107',
                                MailingState = 'IL',
                                OtherStreet ='22 E Wacker Dr.',
                                OtherCity = 'Chicago',
                                OtherState = 'IL',
                                OtherCountry = 'UNITED STATES',
                                OtherPostalCode = '',
                                Account = acct
                            ));                         
            insert cts;
            integer maxCts = cts.size();
            for(integer i=0;i< maxCts;i++){
                cts[i].MailingStreet  = '1 East Bode Rd.';
                cts[i].MailingCity = 'Streamwood';
                cts[i].MailingCountry = 'UNITED STATES';
                cts[i].MailingPostalCode = '60107';
                cts[i].MailingState = 'IL';
                cts[i].OtherStreet ='22 E Wacker Dr.';
                cts[i].OtherCity = 'Chicago';
                cts[i].OtherState = 'IL';
                cts[i].OtherCountry = 'UNITED STATES';
                cts[i].OtherPostalCode = '60011';
                cts[i].npe01__SystemAccountProcessor__c = 'One-to-One';
            }       
            
           
            update cts;*/
            
    }//METHOD
    public static testmethod void testContactPardot(){
        // Create Acocunt
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunContactTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        ConstitIdSeries__c ConstitIdSeries = new ConstitIdSeries__c();
        ConstitIdSeries.Name = 'ConstitIdStartNumber';
        ConstitIdSeries.ConstitSeriesNo__c = 5047150;
        insert ConstitIdSeries;
        
        Account a = new Account(Name='Pardot Contact Update');
        insert a;

        Contact c = new Contact(Firstname='Joe',Lastname='Montana');

        insert c;

        //c.Club_Interest__c ='Spanish';
        update c; 

      /*  Test.startTest();
        System.AssertEquals('Spanish',c.Club_Interest__c);
        Test.stopTest(); */

    }//METHOD
}