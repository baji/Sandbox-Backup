/***************************************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Salesforce
    Description:General Test Class for Affiliations
    Original:   09/11/2015  - Created to Test Affiliations for Advocacy
    Updated:      7/11/2017 - Added SeeAllData=true.
 *****************************************************************************************************************/

@isTest(SeeAllData=true)
public class Test_AffiliationsAfterUpdate{
    public static testmethod void testAdvocacy(){
    // Create an account
    Profile prf = [SELECT id FROM Profile WHERE name = 'System Administrator' LIMIT 1];
    User usr = [select Id from User where Name = 'Demandware' LIMIT 1];//we are not creating user as see all data is true and user is available//TestObjects.createTestUser(null, prf.id, '', 'Demandware');
    //Insert usr;
    Account a = new Account(Name='TestAffUpdate');
    insert a;

    //Create Contact
    List<Contact> contacts = new List<Contact>();
    contacts.add(new Contact(FirstName='Bill', LastName = 'Bojangles', Email='tapping@mailinator.com'));
    contacts.add(new Contact(FirstName='Francine', LastName = 'McCutchin', Email='franmc@mailinator.com'));
        contacts.add(new Contact(FirstName='Bilbo', LastName = 'Baggins', Email='bilbobag@mailinator.com'));
    insert contacts;    
    // Create Affiliation
    List<npe5__Affiliation__c> affs = new List<npe5__Affiliation__c>();
    affs.add( new npe5__Affiliation__c(npe5__Organization__c = a.Id, npe5__Contact__c=contacts[0].Id, Other_Role__c = 'Advocate', npe5__Status__c = 'Pending', Church_Role__c ='',Awana_Role__c ='Senior Pastor;Awana Ministry Director'));
    affs.add( new npe5__Affiliation__c(npe5__Organization__c = a.Id, npe5__Contact__c=contacts[1].Id, Other_Role__c = 'Advocate', npe5__Status__c = 'Pending', Church_Role__c = 'Commander',Awana_Role__c ='Senior Pastor' ));
    affs.add( new npe5__Affiliation__c(npe5__Organization__c = a.Id, npe5__Contact__c=contacts[2].Id, Other_Role__c = 'Advocate', npe5__Status__c = 'Pending', Church_Role__c = 'Commander',Awana_Role__c ='Senior Pastor' ));

        insert affs;

    //1. Tests for Advocacy
    Test.startTest();
       affs[0].Church_Role__c = 'Executive Director';
      affs[0].npe5__Status__c = 'Former';
      affs[1].Awana_Role__c = 'Senior Pastor;Awana Ministry Director';
           affs[1].Church_Role__c = 'Pastor';
          affs[1].npe5__Status__c ='Former';
          affs[2].Other_Role__c = 'Advocate';
          affs[2].npe5__Status__c ='Current';
        update affs;
        /*
        affs.clear();
        affs.add( new npe5__Affiliation__c(npe5__Organization__c = a.Id, npe5__Contact__c=contacts[2].Id, Other_Role__c = '', npe5__Status__c = 'Pending', Church_Role__c = 'Commander',Awana_Role__c ='Senior Pastor' ));
        insert affs;
        affs[0].Other_Role__c = 'Advocate';
        affs[0].npe5__Status__c ='Current';
        update affs;
        */
    Test.stopTest();

  }
}//Class