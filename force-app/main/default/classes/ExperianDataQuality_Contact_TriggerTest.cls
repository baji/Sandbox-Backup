@isTest(SeeAllData=true)
public with sharing class ExperianDataQuality_Contact_TriggerTest {
     public static testmethod void InsertContactTest() {
        Contact contact = new Contact(LastName='Smith');
        insert contact;  

        contact.LastName = 'xyz';
        update contact;
    }
}