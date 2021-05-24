/****************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Testing International Lead Acquisitions 
    Created:    10/22/2017 - <ASP-606,481> - If Phsyical Country is not US then assigned the lead to Chris Greten and sets Status to 'International'
    Conditions:  Test condtion for an international lead be it puerto rico, canada or any other international country.
 --------------------------------------
Class: UpdateInternationalInquiryOwner.cls  
 *******************************************************************************************************************************************/
 
@isTest(SeeAllData=true) // Had to use this because of an Emma Trigger issue.
private class UpdateInternationalInquiryOwner_Test {

    static testMethod void TestInternationalLead()
    {   
        List<User> lowner = [Select Id from User where Firstname = 'Awana' and Lastname = 'Applications'];      

        List<RecordType> aqs = [Select Id from RecordType where SObjectType = 'Lead' and Name = 'Acquisition' limit 1];
        List<Lead> ldNew = new List<Lead>();
        ldNew.add(new Lead(FirstName= 'Raul',LastName = 'Alonzo', Company = 'Test', MailStatus__c = 'Both',Physical_Country__c = 'Venezuela', Email='Raulonzo@mailinator.com',RecordTypeId=aqs[0].Id,
                         OwnerId=lowner[0].Id)
                 );
        ldNew.add(new Lead(FirstName= 'Arletta',LastName = 'Villareal', Company = 'Test', MailStatus__c = 'Both',Physical_Country__c = 'Puerto Rico', Email='avillarealo@mailinator.com',RecordTypeId=aqs[0].Id,
                         OwnerId=lowner[0].Id)
                 );
        ldNew.add(new Lead(FirstName= 'Hubert',LastName = 'Delacroix', Company = 'Test', MailStatus__c = 'Both',Physical_Country__c = 'Canada', Email='delacroix@mailinator.com',RecordTypeId=aqs[0].Id,
                         OwnerId=lowner[0].Id)
                 );
        if(ldNew.size() > 0){
            Database.insert(ldNew);
        }
        List<Id> leadIds = new List<Id>();
        for(Lead alead : ldNew){
            leadIds.add(alead.Id);
        }
        Test.startTest();
        UpdateInternationalInquiryOwner.getInternationalInquiry(leadIds);
        Test.stopTest();
    }
}