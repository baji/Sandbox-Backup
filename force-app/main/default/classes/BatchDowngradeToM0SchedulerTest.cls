/*********************************************************************************************************
    Programmer:         Tony W.
    Company:           	Awana
    Contact:            tonyw@awana.org
    Project:            
    Original:          - Update Mozo Level on account when Mozo expiration date has passed.   
****************************************************************************************************************************/
@isTest(SeeAllData=false)
public class BatchDowngradeToM0SchedulerTest {
	 static testMethod void BatchDowngradeToM0_TestMethod (){
            RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
            List<Account>  usOrgAccount = new List<Account>();
             List<String> accountIds = new List<String>();
            List<npe5__Affiliation__c> testAffiliation = new List<npe5__Affiliation__c>();
            Contact c = new Contact();
            
            c.LastName = 'Baji';
            insert c;
            usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                            Name='Test Account',
                                            Mozo_Level__c = 'M1',
                                            MOZO_Expiration_Date__c = system.today(),
                                          	Status__c = 'Added',
                                            Type = 'Church',
                                          	Applicant__c = c.Id,
                                          	Mailing_Address_Book__c = '000123',
       										Registration_Number__c='123',
        									BillingCountry = 'UNITED STATES',
        									BillingStreet  = 'The Landmark @ One Market\nSuite 300',
        									BillingCity = 'San Francisco',
        									BillingPostalCode = '94105',
        									BillingState = 'CA',
        									Undeliverable_Mailing__c  = false,
        									ShippingStreet =  '32364 Lodge Rd',
            								ShippingCity = 'Tollhouse',
    										ShippingPostalCode =  '93667',
    										ShippingState = 'CA',
    										ShippingCountry = 'UNITED STATES', 
    										Shipping_County__c =  'Fresno',
    										Physical_City__c = 'Tollhouse',
    										PhysicalCountry__c = 'UNITED STATES',
    										Physical_State__c = 'CA',
    										Physical_Street_1__c = '32364 Lodge Rd',
    										Physical_Zip__c = '93667',
    										Physical_County__c = 'Fresno',
    										Default_Terms__c = 'NET30'
                                          	
                                     )
            );
            insert usOrgAccount;
            testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[0].Id,npe5__Contact__c = c.Id));
         	testAffiliation[0].Mozo_User_Level__c = 'Full';
            insert testAffiliation;
            Test.startTest();
            BatchDowngradeToM0 DowngradeJob = new  BatchDowngradeToM0();
         	Database.executeBatch( DowngradeJob, 1); // batch size is 1
           	// String sch = '0 50 15 30 6 ? *';
            //String jobID = system.schedule('Downgrade to M0', sch, j);    
            
            Test.stopTest();
        }
}