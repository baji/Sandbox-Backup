@IsTest(seeAllData=true)
public class TestDonationCounter{

     public static testMethod void UpdateDonation(){
        
        
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'TestAcc';
        insert acc;
          
        //Contact c = new Contact(LastName = 'Baji',FirstName='Basha');
        //insert c;
        Contact c = [select Id,Name From Contact Limit 1];
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
        Name            = 'Test Oppty',
        AccountId       = acc.Id,
        Amount          = 300,
        CloseDate       = Date.today(),
        UTM_Source__c   = 'myawana-dev',
        First_Donation__c = false,
        npsp__Primary_Contact__c = c.id,
        recordtypeid = donationRecordTypeId,
        StageName       = 'Posted'));
        insert o;
  
        Test.startTest();
        //insert cn;
        //insert o;
        Opportunity op = [select Id,CreatedDate,AccountID,UTM_Source__c,(Select ContactId,Contact.Name From OpportunityContactRoles) FROM Opportunity where Id =: o[0].Id];
        DonationCounter.updateDonationCounter(op.Id);
        Test.stopTest();
    }
}