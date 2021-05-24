/***************************************************************************************************************************************************************************************
    Programmer: S. Baji.  
    Company:    Awana
    Contact:    
    Project:    
    Description: Tests the ConvertInquiry class: 
    Created:    07/20/2018 - S. Baji
    Updated:    07/30/2018 - <ASP-1249> (Blake S)  Added new test leads.
***************************************************************************************************************************************************************************************/

@isTest(SeeAllData=true)
public class Test_ConvertInquiry {
    @isTest(SeeAllData=true)
    public static void testConvertInquiry(){
        Contact c = new Contact(FirstName='Test',LastName='Contact',Email='testemail@mailinator.com');
        insert c;
        Account a = new Account(Name='Test Account',BillingState='IL',BillingCountry='United States',PhysicalCountry__c='United States');
        insert a;
        
        Lead l = [select AlreadyRunningAwana__c,AnticipatedStartDate__c,ChildrensMinistryMidweek__c,ChildrensMinistrySunday__c,Church_Attendance__c,
                     Comments__c,Denomination__c,FamiliarityWithAwana__c,Lead_Source__c,PhysicalCity__c,Physical_Country__c,PhysicalCounty__c,
                     PhysicalState__c,PhysicalStreet1__c,PhysicalStreet2__c,PhysicalStreet3__c,PhysicalStreet4__c,PhysicalZipCode__c,PrimaryEthnicGroup__c,Existing_Contact__c,Existing_Account__c,
                     Undeliverable_Physical__c,Undeliverable_Billing_Address__c,npe01__Preferred_Email__c,npe01__Preferred_Phone__c,FirstName,LastName,Email,Company,Phone,Fax,Website,
                     HasOptedOutOfEmail,PositionRole__c,MobilePhone,Street,City,State,Postalcode,Country,County__c,Work_Phone__c,CustomerNotes__c From Lead where Existing_Contact__c = null Limit 1];
        Lead l1 = [select AlreadyRunningAwana__c,AnticipatedStartDate__c,ChildrensMinistryMidweek__c,ChildrensMinistrySunday__c,Church_Attendance__c,
                     Comments__c,Denomination__c,FamiliarityWithAwana__c,Lead_Source__c,PhysicalCity__c,Physical_Country__c,PhysicalCounty__c,
                     PhysicalState__c,PhysicalStreet1__c,PhysicalStreet2__c,PhysicalStreet3__c,PhysicalStreet4__c,PhysicalZipCode__c,PrimaryEthnicGroup__c,Existing_Contact__c,Existing_Account__c,
                     Undeliverable_Physical__c,Undeliverable_Billing_Address__c,npe01__Preferred_Email__c,npe01__Preferred_Phone__c,FirstName,LastName,Email,Company,Phone,Fax,Website,
                     HasOptedOutOfEmail,PositionRole__c,MobilePhone,Street,City,State,Postalcode,Country,County__c,Work_Phone__c,CustomerNotes__c From Lead where Existing_Account__c = null Limit 1];
        Lead l2 = [select AlreadyRunningAwana__c,AnticipatedStartDate__c,ChildrensMinistryMidweek__c,ChildrensMinistrySunday__c,Church_Attendance__c,
                     Comments__c,Denomination__c,FamiliarityWithAwana__c,Lead_Source__c,PhysicalCity__c,Physical_Country__c,PhysicalCounty__c,
                     PhysicalState__c,PhysicalStreet1__c,PhysicalStreet2__c,PhysicalStreet3__c,PhysicalStreet4__c,PhysicalZipCode__c,PrimaryEthnicGroup__c,Existing_Contact__c,Existing_Account__c,
                     Undeliverable_Physical__c,Undeliverable_Billing_Address__c,npe01__Preferred_Email__c,npe01__Preferred_Phone__c,FirstName,LastName,Email,Company,Phone,Fax,Website,
                     HasOptedOutOfEmail,PositionRole__c,MobilePhone,Street,City,State,Postalcode,Country,County__c,Work_Phone__c,CustomerNotes__c From Lead where Existing_Contact__c = null AND Existing_Account__c = null Limit 1];
        Lead l3 = new Lead(LastName='TestLead',LeadSource='Test',Existing_Contact__c=c.Id,Existing_Account__c=a.Id,Company='TestChurch');
        //upsert l1;
        l1.Existing_Contact__c=c.Id;
        l1.Existing_Account__c=a.Id;
        l1.Physical_Country__c = 'UNITED STATES';
        update l1;
        
        Lead l4 = [select AlreadyRunningAwana__c,AnticipatedStartDate__c,ChildrensMinistryMidweek__c,ChildrensMinistrySunday__c,Church_Attendance__c,
                     Comments__c,Denomination__c,FamiliarityWithAwana__c,Lead_Source__c,PhysicalCity__c,Physical_Country__c,PhysicalCounty__c,
                     PhysicalState__c,PhysicalStreet1__c,PhysicalStreet2__c,PhysicalStreet3__c,PhysicalStreet4__c,PhysicalZipCode__c,PrimaryEthnicGroup__c,Existing_Contact__c,Existing_Account__c,
                     Undeliverable_Physical__c,Undeliverable_Billing_Address__c,npe01__Preferred_Email__c,npe01__Preferred_Phone__c,FirstName,LastName,Email,Company,Phone,Fax,Website,
                     HasOptedOutOfEmail,PositionRole__c,MobilePhone,Street,City,State,Postalcode,Country,County__c,Work_Phone__c,CustomerNotes__c,
                     pi__Needs_Score_Synced__c,pi__campaign__c,pi__comments__c,pi__conversion_date__c,pi__conversion_object_name__c,pi__conversion_object_type__c,pi__created_date__c,
                     pi__first_activity__c,pi__first_touch_url__c,pi__first_search_term__c,pi__first_search_type__c,pi__grade__c,pi__pardot_hard_bounced__c,pi__last_activity__c,
                     pi__Pardot_Last_Scored_At__c,pi__notes__c,pi__score__c,pi__url__c,Best_Time_to_Call__c,Temperature__c,
                     pi__utm_campaign__c,pi__utm_content__c,pi__utm_medium__c,pi__utm_source__c,pi__utm_term__c,Club_Interest__c From Lead where Existing_Contact__c = NULL AND Existing_Account__c = NULL Limit 1];
        
        
        List<Task> t = new List<Task>();

        t.add(new task(
        WhoID = l1.id,
        Subject='Test',
        Status='New',
        Type='Call',
        Priority='Normal'));        
        
        t.add(new task(
        WhoID = l4.id,
        Subject='Test',
        Status='New',
        Type='Call',
        Priority='Normal'));
        
        insert t;
                
        Test.startTest();
            
        ConvertInquiry.inqryConversion(l1.Id);
          
        ConvertInquiry.inqryConversion(l4.Id);
        Test.stopTest();
    }
}