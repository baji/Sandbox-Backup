/*********************************************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            TestTeamMemberAccounts
    Original:          09/22/2016 - Used to testAccount Team Member updates described in JIRA <SFDC-205>. 
    Updated:            03/20/2017 - <CE-91> - Added updates for VP of US Ministries
    Updated:            08/10/2018 - <ASP-1288> - Tetsing the new GO Club Outreach Specialist and VP of Missionaries
 ***********************************************************************************************************/ 
@isTest(SeeAllData=true)
public class TestTeamMemberAccounts {
    public static User us,us1;
   
   @isTest static void TestTeamMemberInserts() 
   {
        // Get the necessary VP of Missionaries, Primary Missionary, GO Specialist and WF Leader from a state and then ...
        // Create a new account and ser the Reg Level to R0 and then set the Reg LEvel To R1 (Make sure Applicant and  Agreement are set)
        // // Test the Account Teams of that Account to See if both VP and GO Specilaists are in there. Also Verify Account Owner
        // 
        User appAwana = [Select Id FROM USer where Alias = 'awanaap1' limit 1];
        Account a2 = new Account();
        Contact c = new Contact(FirstName = 'Illiana',
        LastName = 'Faye',
        Email='illfaye@mailinator.com');
        insert c;
        List<US_Counties__c>   uscs = [SELECT Id, State_Name__c, Name, Primary_Missionary__c,Field_Director__c,GO_Club_Outreach_Specialist__c,VP_of_US_Field_Operations__c,Work_Group_Leader__c From US_Counties__c WHERE Name='Washington' and State_Name__c='MN' Limit 1];
       
            Id getUSRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
            a2.Name = 'Account 2';
            a2.Status__c = 'Added';
            a2.ShippingStreet = '10645 Pond Curv';
            a2.Mailing_Street_1__c ='702 Scruggs St' ;
            a2.ShippingCity = 'Woodbury';
            a2.Mailing_City__c = 'Waycross';
            a2.ShippingState = 'MN';
            a2.Registration_Level__c = 'R0';
            a2.Mailing_State_Province__c='GA';
            a2.ShippingCountry ='United States';
            a2.Mailing_Country__c='United States';
            a2.ShippingPostalCode = '55129';
            a2.Mailing_Zip_Postal_Code__c = '31501';
            a2.BillingStreet='503 Scruggs St';
            a2.Physical_Street_1__c ='8906 Saint Croix Rd';
            a2.BillingCity = 'Waycross';
            a2.Physical_City__c ='Woodbury';
            a2.BillingState ='CA';
            a2.Physical_State__c = 'MN';
            a2.BillingCountry = 'United States';
            a2.PhysicalCountry__c = 'United States';
            a2.Physical_County__c = 'Washington';
            a2.BillingPostalCode = '31501';
            a2.Physical_Zip__c = '55125';
            a2.RecordTypeId =  getUSRecordType;//getRecordType;
            a2.OwnerId=userinfo.getUserId();
            a2.Mailing_Address_Book__c = '000125'; 
            a2.Applicant__c = c.Id;
            a2.Agreement_Signed__c = system.today();
           insert a2;
            List<npe5__Affiliation__c> affList =  new List<npe5__Affiliation__c>();
            affList.add(new npe5__Affiliation__c(npe5__Contact__c=c.Id,npe5__Organization__c=a2.Id,Church_Role__c='Commander'));
       Test.startTest();
       a2.Registration_Level__c = 'R1';
       update a2;
       List<AccountTeamMember> atm = [Select AccountID,UserId,TeamMemberRole from AccountTeamMember  WHERE TeamMemberRole in ('Field Director','Work Group Leader','Primary Missionary','GO Club Outreach Specialist','VP of US Field Operations')  and AccountId  =: a2.Id];
      // system.assertNotEquals(null, atm[3].UserId); // Test the existence of GO Specialist
      // system.assertNotEquals(null, atm[4].UserId);// Test the existence of VP of Missionaries
       Test.stopTest();
       
   }    

      
}