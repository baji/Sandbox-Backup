/*************************************************************************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Test Classes
    Original:           6/03/2010 - Used to test GeoCode Classes and triggers.
    Updated:            1/5/2014 - Added a Person Account to test Account Geo Codes for when the account is Updated and none of the physical address fields have changed.
    Updated:            02/10/2015 - Removed Record Type so that international churches can display Geo Codes too.
    Updated:            7/11/2017 - Added SeeAllData=true. by Sohil
    Updated:            02/03/2018 - <CRM REWRITE> - Added additional testing which includes the Mock callout
	Updated:			02/27/2018 - <ASP-832> - UPdated Test code to run successfully when creating new accounts which adheres to updates in ASP-775 (Baji)
 ***********************************************************************************************************************************************************/ 
@isTest (SeeAllData=true)
public with sharing class TestGeoCodes {
 // Test Geo codes for acocunts
        public static testmethod void testGeoLocMethod(){
        List<String> accountIds = new List<String>();
        //RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
        Id usOrgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();    
        List<Account>  usOrgAccount = new List<Account>();
        Contact c = new Contact(FirstName='Baji',LastName='Basha',Email='test@gmail.com');
        insert c;
        User u = [select Id from User where Id !=: '' and Alias =: 'sbaji' Limit 1];
            
        usOrgAccount.add(new Account (RecordTypeId =usOrgRecTypeId, 
                                            Name='Test Account',
                                            Physical_Street_1__c ='323 W 101st',
                                            Physical_City__c =  'Chicago',
                                            Physical_State__c =  'IL',
                                            Physical_Zip__c = '60628',
                                            PhysicalCountry__c = 'United States',
                                            Status__c = 'Pending',
                                      		Applicant__c=c.Id,
                                      		OwnerId = u.Id
                                     )
                        );
                    
        
        insert usOrgAccount;
            
         npe5__Affiliation__c aff = new npe5__Affiliation__c(Church_Role__c='Test Role',npe5__Contact__c=c.Id,npe5__Organization__c=usOrgAccount[0].Id);
        insert aff;
        usOrgAccount[0].Physical_Street_1__c =  '1 East Bode Rd';    
        usOrgAccount[0].Physical_City__c =  'Streamwood';
        usOrgAccount[0].Physical_Zip__c =  '60107';
        usOrgAccount[0].Status__c = 'Added';
        
        update usOrgAccount;
        
        AccountHelper ah1 = new AccountHelper(usOrgAccount[0].Id);
        accountIds.add(JSON.serialize(ah1));
        Test.setMock(HttpCalloutMock.class, new myMock(true));
            
        
        User u1 = [select Id from User where Id !=: '' and Alias =: 'AKann' Limit 1];
        AccountTeamMember atm = new AccountTeamMember();
        AccountTeamMember atmPRM = new AccountTeamMember();
        AccountTeamMember atmSRM = new AccountTeamMember();
        Id prmId,srmId,accId;    
        atm.UserId = u.Id;
        atm.TeamMemberRole = 'Primary Missionary';
        atm.AccountId = usOrgAccount[0].Id;
        
        atmPRM.UserId = u.Id;
        atmPRM.TeamMemberRole = 'Primary Relationship Manager';
        atmPRM.AccountId = usOrgAccount[0].Id;
        
        atmSRM.UserId = u.Id;
        atmSRM.TeamMemberRole = 'Secondary Relationship Manager';
        atmSRM.AccountId = usOrgAccount[0].Id;
        insert atm;
        insert atmPRM;
        insert atmSRM;
        usOrgAccount[0].Primary_Moves_Manager__c = u.Id;
        usOrgAccount[0].Secondary_Relationship_Manager__c = u.Id;
        update usOrgAccount[0];
            
        Test.startTest();
        GeoLocationCallouts.getLocation(accountIds);
        usOrgAccount[0].OwnerId = u1.Id;    
        update usOrgAccount[0];
        Test.stopTest();
    }
}