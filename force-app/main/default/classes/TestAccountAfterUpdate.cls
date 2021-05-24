/*********************************************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            TestAccountAfterUpdate
    Original:       11/26/2014 - Used to test Contact update triggers.
    Updated:        03/20/2017 - <CE-91> - Added updates for VP of US Ministries
    Updated:        06/21/2017 - <ASP-210>- ChatterUtility calls to create record feeds for Health and Reg Status
	Updated:		04/07/2018 - <NMM-18> -  Updated test to include new Mozo Levels M0 and removed R1 as the member/Mozo combo.
 ***********************************************************************************************************/ 
 
@isTest(SeeAllData=true)

private class TestAccountAfterUpdate {  // Test Synchronzing of Addresses between Contact and its 1x1 Account
   static testmethod void TestAccountsAfterUpdate() {
            //RecordType  getRecordType= [Select Id from RecordType where Name = 'Individual_Person' and SObjectType = 'Account'];
            //List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
       		Id getUSRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
            List<Account> accountList = new List<Account>();
       List<String> stringList = new List<String>();
       stringList.add('Hickory DIckory DOck');
       stringList.add('The Mouse Ran Up The CLock');
            //Create the  codes
            Account a2 = new Account();
            Account aUS2 = new Account();
            Account aUS3 = new Account();    
        Contact c1 = new Contact(FirstName = 'Rita',
                       LastName = 'Marzullo',
                       Email='rmarzullo@mailinator.com');
           insert c1;
           Contact c2 = new Contact(FirstName = 'Vito',
                       LastName = 'Marzullo',
                       Email='rmarzullo@mailinator.com');
           insert c2;
             Contact c = new Contact(FirstName = 'Illiana',
                       LastName = 'Faye',
                       Email='illfaye@mailinator.com');
             insert c;
              US_Counties__c     usc = new US_Counties__C(name = 'United States',State_Name__c = 'GA');
             insert usc;
            
            a2.Name = 'Account 2';
       		a2.Status__c = 'Added';
            a2.ShippingStreet = '503 Scruggs St';
            a2.Mailing_Street_1__c ='702 Scruggs St' ;
            a2.ShippingCity = 'Waycross';
            a2.Mailing_City__c = 'Waycross';
            a2.ShippingState = 'GA';
            a2.Mozo_Free_Trial_ContactID__c = c.Id;
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
            a2.RecordTypeId =  getUSRecordType;//getRecordType;
            a2.OwnerId=userinfo.getUserId();
            a2.Mozo_Trial_Status__c = 'Current';
            a2.Mozo_Trial_End_Date__c = system.today();
            a2.Mailing_Address_Book__c = '000125'; 
       		a2.Applicant__c = c.Id;
           insert a2;
            List<npe5__Affiliation__c> affList =  new List<npe5__Affiliation__c>();
            affList.add(new npe5__Affiliation__c(npe5__Contact__c=c.Id,npe5__Organization__c=a2.Id,Church_Role__c='Commander'));
          //0. Test Opportunity and tie it to a2 Account
             Opportunity o2 = new Opportunity(AccountId=a2.Id, Name='TestAfterUpdate-1',StageName='Order Open', Registration_Product__c='M2',closedate=Date.today());
            upsert o2;
           
            o2.StageName = 'Order Submitted';
            update o2;
        
           // 1.  Get the first two street addresses to test and see if they have changed once step 2 has updated below
           String compareMailing =a2.Mailing_Street_1__c;   

           String comparePhysical = a2.Physical_Street_1__c;
           // 2. Change Acont Address to dummy address - SalesForce HQ Address  
        a2.Status__c = 'Added';
        a2.ShippingStreet  = '1150 Wyland Dr SW';
        a2.ShippingState = 'GA';
        a2.ShippingCountry = 'UNITED STATES';
        a2.ShippingCity = 'Atlanta';
        a2.ShippingPostalCode = '30310';
        a2.BillingStreet ='1955 Marvin Ln SW';
        a2.BillingCity = 'Atlanta';
        a2.BillingState = 'GA';
        a2.BillingCountry = 'UNITED STATES';
        a2.BillingPostalCode = '30310';
        a2.Mailing_Address_Book__c = '000124'; 
       	a2.Applicant__c = c2.Id;
        update a2;
        accountList.add(a2);
       affList.add(new npe5__Affiliation__c(npe5__Contact__c=c2.Id,npe5__Organization__c=a2.Id,Church_Role__c='Commander'));
 // ==============================Now get US Organizations ============================================
       List<UserRole> vpRole = [Select Id from UserRole where Name = 'VP of US Missionaries'];
        List<User> changeOwner = [Select Id from User where Id =: UserInfo.getUserId()];
         List<User> vpUser = [Select Id from User where UserRoleId =: vpRole[0].Id and isActive = true];
            
          aUS2.Type = 'Church';
            aUS2.Name='Sample Test Church';
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
       		aUS2.MOZO_Level__c = 'M0';
            aUS2.Mozo_Trial_Status__c = 'Current';
            aUS2.Mozo_Trial_End_Date__c = system.today();
            aUS2.RecordTypeId =getUSRecordType;
            aUS2.OwnerId=userinfo.getUserId();
            aUS2.Status__c = 'Pending';
            aUS2.Health_Status__c ='Don\'t Know';
            aUS2.Mailing_Address_Book__c = '000123'; 
       		aUS2.Applicant__c = c1.Id;
            insert aUS2;
            aUS2.OwnerId=changeOwner[0].Id;
       		affList.add(new npe5__Affiliation__c(npe5__Contact__c=c1.Id,npe5__Organization__c=a2.Id,Church_Role__c='Commander'));
            List<AccountTeamMember> chosenATMs = new List<AccountTeamMember>();
            chosenATMs.add(new AccountTeamMember(AccountId=aUS2.Id, UserId=aUS2.OwnerId,TeamMemberRole = 'Primary Missionary'));
            insert chosenATMs;
            
            Test.startTest();
       			 npe5__Affiliation__c aff2 = new npe5__Affiliation__c(npe5__Organization__c =aUS2.Id,npe5__Contact__c= c1.Id,Church_Role__c='Church Volunteer');
        		insert aff2;
                aUS2.Status__c ='Added';
                aUS2.Registration_Status__c  = 'New';
                aUS2.Health_Status__c = 'Everything Is OK';
       			aUS2.Applicant__c = c1.Id;
                update aUS2;
       			List<Id> ids = new List<Id>();
                ids.add(aUS2.Id);
                accountList.add(aUS2);
       			TeamMemberAccounts.handler(accountList,ids);
           Test.stopTest();
       
  }
}