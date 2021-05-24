/*
 * Purpose   : This test class covers the affiliation trigger code for the DRM org-to-Org affiliations.
 * Developer : Mayur Soni(msoni@apttus.com) 
*/
@isTest
public class AffiliationAfterUpdateTest{
    
    @TestSetup
    public static void testDataCreate(){
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
       
         Account a2 = new Account();
         Account aUS2 = new Account();    
         Account aUS3 = new Account();    
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
            insert a2;
           
            aUS2.Type = 'Church';
            aUS2.Name='Account Org 2';
            aUS2.ShippingStreet = '455 Loomis Ave SE';
            aUS2.Mailing_Street_1__c ='835 Woodley Dr NW' ;
            aUS2.ShippingCity = 'Atlanta';
            aUS2.Mailing_City__c = 'Atlanta';
            aUS2.ShippingState = 'GA';
            aUS2.Mailing_State_Province__c='GA';
            aUS2.ShippingCountry ='United States';
            aUS2.Mailing_Country__c='United States';
            aUS2.ShippingPostalCode = '30318';
            aUS2.Mailing_Zip_Postal_Code__c = '30318';
            aUS2.BillingStreet='455 Loomis Ave SE';
            aUS2.Physical_Street_1__c ='835 Woodley Dr NW';
            aUS2.BillingCity = 'Atlanta';
            aUS2.Physical_City__c ='Atlanta';
            aUS2.BillingState ='GA';
            aUS2.Physical_State__c = 'GA';
            aUS2.BillingCountry = 'United States';
            aUS2.PhysicalCountry__c = 'United States';
            aUS2.BillingPostalCode = '30318';
            aUS2.Physical_Zip__c = '30318';
            aUS2.Registration_Level__c = 'R1';
            aUS2.Mozo_Trial_Status__c = 'Current';
            aUS2.Mozo_Trial_End_Date__c = system.today();
            aUS2.RecordType =getUSRecordType[0];
            aUS2.OwnerId=userinfo.getUserId();
            aUS2.Status__c = 'Pending';
            aUS2.Health_Status__c ='Don\'t Know';
            aUS2.Mailing_Address_Book__c = '000123'; 
            insert aUS2;
            
            aUS3.Type = 'Church';
            aUS3.Name='Account Org 3';
            aUS3.ShippingStreet = '455 Loomis Ave SE';
            aUS3.Mailing_Street_1__c ='835 Woodley Dr NW' ;
            aUS3.ShippingCity = 'Atlanta';
            aUS3.Mailing_City__c = 'Atlanta';
            aUS3.ShippingState = 'GA';
            aUS3.Mailing_State_Province__c='GA';
            aUS3.ShippingCountry ='United States';
            aUS3.Mailing_Country__c='United States';
            aUS3.ShippingPostalCode = '30318';
            aUS3.Mailing_Zip_Postal_Code__c = '30318';
            aUS3.BillingStreet='455 Loomis Ave SE';
            aUS3.Physical_Street_1__c ='835 Woodley Dr NW';
            aUS3.BillingCity = 'Atlanta';
            aUS3.Physical_City__c ='Atlanta';
            aUS3.BillingState ='GA';
            aUS3.Physical_State__c = 'GA';
            aUS3.BillingCountry = 'United States';
            aUS3.PhysicalCountry__c = 'United States';
            aUS3.BillingPostalCode = '30318';
            aUS3.Physical_Zip__c = '30318';
            aUS3.Registration_Level__c = 'R1';
            aUS3.Mozo_Trial_Status__c = 'Current';
            aUS3.Mozo_Trial_End_Date__c = system.today();
            aUS3.RecordType =getUSRecordType[0];
            aUS3.OwnerId=userinfo.getUserId();
            aUS3.Status__c = 'Pending';
            aUS3.Health_Status__c ='Don\'t Know';
            aUS3.Mailing_Address_Book__c = '000124'; 
            insert aUS3;
            
            
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
                RE_Sub_set__c='B'
            );
            insert con; 
            
            npe5__Affiliation__c aff = new npe5__Affiliation__c(
                                    npe5__Organization__c = a2.id,
                                    Related_Account__c = aUS2.Id,
                                    npe5__Contact__c=con.id,
                                    Organization_Relation__c ='Subscription Giftee',
                                    Organization_Reciprocal_Relation__c ='Subscription Gifter'
                                    );
            insert aff;
    }
    
    @isTest
    Public static void testOrgAffiliation(){
        Account org1 = [SELECT Id,Name FROM Account WHERE Name='Account Org 1'];
        Account org2 = [SELECT Id,Name FROM Account WHERE Name='Account Org 2'];
        Account org3 = [SELECT Id,Name FROM Account WHERE Name='Account Org 3'];
        Contact con = [SELECT Id,name FROM Contact WHERE LastName='Test last' AND Firstname='Test first'];
        Test.startTest();
        
        npe5__Affiliation__c mainAff = [SELECT Id,npe5__Organization__c ,Related_Account__c,Organization_Relation__c,Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c =:org1.id];
        
        List<npe5__Affiliation__c> recipAff = [SELECT Id,npe5__Organization__c ,Related_Account__c,Organization_Relation__c,Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c =:mainAff.Related_Account__c];
        System.assert(!recipAff.isEmpty());
        
        //update scenario
        mainAff.Related_Account__c = org3.id;
        update mainAff;
        
        List<npe5__Affiliation__c> recipAff1 = [SELECT Id,npe5__Organization__c ,Related_Account__c,Organization_Relation__c,Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c =:org3.id];
        System.assert(!recipAff1.isEmpty());
        
        Test.stopTest();
        
        
    }
    
    @isTest
    Public static void testOrgAffiliationUpdate(){
        Account org1 = [SELECT Id,Name FROM Account WHERE Name='Account Org 1'];
        Account org2 = [SELECT Id,Name FROM Account WHERE Name='Account Org 2'];
        Account org3 = [SELECT Id,Name FROM Account WHERE Name='Account Org 3'];
        Contact con = [SELECT Id,name FROM Contact WHERE LastName='Test last' AND Firstname='Test first'];
        Test.startTest();
        
        npe5__Affiliation__c mainAff = [SELECT Id,npe5__Organization__c ,Related_Account__c,Organization_Relation__c,Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c =:org1.id];
        
        
        //update scenario
        mainAff.Organization_Relation__c = 'Foundation';
        mainAff.Organization_Reciprocal_Relation__c = 'Foundation donor';
        update mainAff;
        
        List<npe5__Affiliation__c> aff = [SELECT Id,npe5__Organization__c ,Related_Account__c,Organization_Relation__c,Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c =:org1.id];
        
        List<npe5__Affiliation__c> recipAff1 = [SELECT Id,npe5__Organization__c ,Related_Account__c,Organization_Relation__c,Organization_Reciprocal_Relation__c FROM npe5__Affiliation__c WHERE npe5__Organization__c =:org2.id];
        System.assert(!recipAff1.isEmpty());
        System.assert(recipAff1[0].Organization_Relation__c  ==aff[0].Organization_Reciprocal_Relation__c);
        
        delete aff;
        Test.stopTest();
        
    }
}