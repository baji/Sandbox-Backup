@isTest(SeeAllData=true)
public with sharing class ExperianDataQuality_Account_TriggerTest {
    public static testmethod void InsertAccountTest() {
        Account account = new Account(Name='John Smith',BillingStreet='445 Hamilton Ave',Mailing_Address_Book__c='001234',BillingCountry = 'UNITED STATES'
        ,Registration_Number__c='US9876',ShippingStreet = '445 Hamilton Ave',ShippingCity= 'Streamwood',ShippingState= 'IL',ShippingPostalCode = '60107',
         ShippingCountry = 'UNITED STATES');
        insert account;        
    }
}