@isTest
public class DRMUpdateCodeToHouseHoldTest{

    @TestSetup
    public static void testDataCreate(){
        Awana_Settings__c awanaSettings = new Awana_Settings__c(Name='EnableDeDupCheck',Value__c='false');
        insert awanaSettings;
        Contact con = new Contact(
            lastName='Test last',
            FirstName='Test first',
            Constituent_Id__c = '112233',
            RE_Constit_Rec_Id__c = '1234',
            Constituent_Code__c = 'Individual;Former Board Member',
            Constituent_Solicit_Code__c='No Appeals;Requested No Email',
            Missionary_Salutation__c='Test',
            Major_Donor_Salutation__c='Missionary Test',
            RE_Primary_Addresee__c='Mr. Test',
            RE_Primary_Salutation__c='Test',
            RE_Sub_set__c='B',
            MailingStreet='121 Blvd',
            MailingCity='San Jose',
            MailingState='CA',
            MailingCountry='United States',
            MailingPostalCode='12345',
            Home_County__c='US'
        );
        insert con;
    }

    @isTest
    public static void testBatch(){
        System.debug('Contact detail : '+[SELECT Id,AccountId,FirstName,Constituent_Code__c FROM Contact]);
        Test.startTest();
        DRMUpdateCodeToHouseHold batch = new DRMUpdateCodeToHouseHold('');
        Database.executeBatch(batch);
        Test.stopTest();
    }
}