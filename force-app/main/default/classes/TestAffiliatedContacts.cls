/******************************************************************************************************************
    Programmer:         Tony Williams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            SFDC-63 (JIRA) 
    Original:           5/3/2016  - Used to test AffiliationContacts Controller
    Updated:            08/16/2017 - <ASP-139> chnages testing to use Awana Ministry Directors  (commander).
    Updated:        11/7/2017 Added SeeAllData = true by Sohil
****************************************************************************************************************************/

@isTest(SeeAllData = true)
public  class TestAffiliatedContacts {
    public static testMethod void testAffiliatedContactsExtension(){
        List<Account> usOrgs = new List<Account>();
            ID recNo = [SELECT ID from RecordType where SOBjectType = 'Account' and Name = 'US Organization'].Id;

            usOrgs .add(new Account(Name='Test2 EV Free Church',RecordTypeId=String.ValueOf(recNo),Type='Church', 
            Docusign_Contact_Email__c='ppipers@mailinator.com', BillingStreet='1611 N Hermitage Ave# 305',
            BillingCity='Chicago',BillingState='IL',Billing_County__c='Cook',
            BillingPostalCode='60622',Phone='773-914-4422', Status__c='Pending',
            Shipping_First_Name__c=null, Shipping_Last_Name__c='Pipers',
        
            ShippingCountry ='UNITED STATES',
            Shipping_County__c = 'Cook',
            BillingCountry='UNITED STATES'
            ));
            insert usOrgs[0];
            // Create a Contact from Affiliation
            Contact someContact = new Contact(
                FirstName = 'Pat',
                LastName = 'Tester',
                Email = 'pattester@mailinator.com'
            );
        
            upsert someContact;
            npe5__Affiliation__c someAffiliation = new npe5__Affiliation__c( npe5__Organization__c=usOrgs[0].Id, 
            npe5__Contact__c=someContact.Id,
            Awana_Role_Text__c ='Awana at Home Director; Awana Ministry Director; Commander',
            Awana_Role__c ='Awana at Home Director; Awana Ministry Director; Commander',      
            Church_Role__c = 'Missions Pastor',
            npe5__Status__c = 'Current',
            Mozo_User_Level__c = 'FULL' );

            upsert someAffiliation;
        
            Test.startTest();
            ApexPages.StandardController controller  = new ApexPages.StandardController(usOrgs[0]); 
            system.debug('<< CONTROLLER >> '+controller);
            AffiliationContactExtension BEC = new AffiliationContactExtension(controller);
            List<npe5__Affiliation__c> pcAffiliations= BEC.getpcAffiliations();
            system.debug('<< AFFILIATIONS >> '+pcAffiliations);
            BEC.GetHasPreviousRecords();
            BEC.GetHasNextRecords();
            BEC.getSetControllerPageSize();
            BEC.getSetControllerPageNumber();
            BEC.getSetControllerResultSize();
            system.assertNotEquals(0,BEC.getpcAffiliationLimit());
            BEC.setpcAffiliationLimit(0);
            BEC.QueryNextRecords();
            BEC.QueryPreviousRecords();
            Test.stopTest();
    }
}