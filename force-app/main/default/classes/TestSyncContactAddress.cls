/***************************************************************************************************************************************************************************
    Programmer:   Mayur Soni
    Company:      Infoglen
    Contact:      mayur@infoglen.com
    Description:  Test class for SynchAccountAddresswithContactAddress class and ContactAfterUpdate trigger
    Original:   26/12/2017 - In the ContactAfterUpdate trigger a deprecated field of npsp package is used which can't be cover 
 **************************************************************************************************************************************************************************/
@isTest
public class TestSyncContactAddress{

    @isTest
    public static void testOneToOneAccountContact(){
        
        Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunAccountTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        Awana_Settings__c custmPRMSetting =  new Awana_Settings__c();
        custmPRMSetting.Name = 'RunPRMTrigger';
        custmPRMSetting.Value__c = 'true';
        insert custmPRMSetting;
    
        
        npe01__Contacts_And_Orgs_Settings__c setting = new npe01__Contacts_And_Orgs_Settings__c(npe01__Account_Processor__c='One-to-One');
        insert setting;
        
        Contact con = TestObjects.FullContact();
        con.MailingStreet ='';
        con.MailingCity = 'Streamwood';
        con.MailingCountry = 'United States';
        con.MailingPostalCode = '';
        con.OtherStreet ='22 E Wacker Dr.';
        con.OtherCity = 'Chicago';
        con.OtherState = 'IL';
        con.OtherCountry = 'UNITED STATES';
        con.OtherPostalCode = '60011';
        con.npe01__SystemAccountProcessor__c = 'One-to-One';
        try{
        insert con;
        }catch(exception e){
            system.debug('error---'+e);
        }
        
        //System.debug('Con List'+[SELECT Id,Name,npe01__SystemAccountProcessor__c FROM Contact][0].npe01__SystemAccountProcessor__c);
        //System.debug('Account List'+[SELECT Id,Name,RecordType.Name,npe01__One2OneContact__c FROM Account]);
        
        con.MailingStreet  = '1 East Bode Rd.';
        con.MailingCity = 'Streamwood';
        con.MailingCountry = 'UNITED STATES';
        con.MailingPostalCode = '60107';
        con.MailingState = 'IL';        
        con.OtherStreet ='22 E Wacker Dr.';
        con.OtherCity = 'Chicago';
        con.OtherState = 'IL';
        con.OtherCountry = 'UNITED STATES';
        con.OtherPostalCode = '60011';
        
        update con;
        
        List<Contact> contactList = Database.query('SELECT '+String.join(new List<String>(Schema.SObjectType.Contact.fields.getMap().keySet()),',') +' FROM Contact');
        //List<Account> accList = Database.query('SELECT '+String.join(new List<String>(Schema.SObjectType.Account.fields.getMap().keySet()),',') +' FROM Account WHERE BillingCountry = \'UNITED STATES\'');
         List<Account> accList = new List<Account>();
         Account account = new Account(Name='John Smith',BillingStreet='445 Hamilton Ave',Mailing_Address_Book__c='001234',BillingCountry = 'UNITED STATES'
        ,Registration_Number__c='US9876',Mailing_Country__c = 'UNITED STATES', PhysicalCountry__c = 'UNITED STATES',ShippingStreet = '445 Hamilton Ave',ShippingCity= 'Streamwood',ShippingState= 'IL',ShippingPostalCode = '60107',
         ShippingCountry = 'UNITED STATES');
        insert account;        
        accList.add(account);
        SynchAccountAddresswithContactAddress.handler(contactList,accList);
        System.assert(contactList[0].MailingCountry ==accList[0].Mailing_Country__c);
        System.assert('UNITED STATES' ==accList[0].PhysicalCountry__c);
        con.MailingCountry = '';
        con.OtherCountry = '';
        //update con;
        
        contactList = Database.query('SELECT '+String.join(new List<String>(Schema.SObjectType.Contact.fields.getMap().keySet()),',') +' FROM Contact');
        //accList = Database.query('SELECT '+String.join(new List<String>(Schema.SObjectType.Account.fields.getMap().keySet()),',') +' FROM Account WHERE BillingCountry = \'UNITED STATES\'');
        SynchAccountAddresswithContactAddress.handler(contactList,accList);
        System.assert('UNITED STATES'==accList[0].Mailing_Country__c);
        System.assert('UNITED STATES' ==accList[0].PhysicalCountry__c);
        
        
        
    }
}