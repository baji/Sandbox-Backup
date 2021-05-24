@isTest
public class DuplicateEmailCountBatchTest {
	@testSetup
    public static void createData(){
        Account acc = new Account(name='Test Account');
        insert acc;
        Contact con = new Contact(firstname='Test',lastName='John',email='test@abc.com');
        insert con;
        Id donationRecordTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='Test Gift',recordtypeid=donationRecordTypeId1,Amount=100,closeDate=Date.today(),stageName='Posted',npsp__Primary_Contact__c=con.id);
        insert opp;
        
        npe5__Affiliation__c aff = new npe5__Affiliation__c( npe5__Organization__c  = acc.Id,npe5__Contact__c = con.Id);
        insert aff;
        
        Order o1 = new Order(name='O-123-0',Status='Order Open', effectiveDate=Date.Today(), AccountId=aff.npe5__Organization__c); 
        insert o1;
        insert new Order_Contact_Role__c(Contact__c = con.Id, Order__c = O1.Id);
        Contact con1 = [SELECT ID,AccountId FROM Contact where id=:con.id];
        Contact con2 = new Contact(firstName='Test 2',lastname='John',accountid=con1.AccountId,email='test@abc.com');
        insert con2;
        npe4__Relationship__c relation = new npe4__Relationship__c(npe4__Contact__c=con1.id,npe4__RelatedContact__c=con2.id,npe4__Type__c='Spouse');
        insert relation;
    }
    @isTest
    public static void testDup(){
        List<Duplicate_Contact_Analyze__c> dupList = new List<Duplicate_Contact_Analyze__c>();
        for(Contact con : [SELECT id,Name,Email FROM Contact where email='test@abc.com']){
            dupList.add(new Duplicate_Contact_Analyze__c(ContactId__c=con.id,Email__c=con.Email,RE_Constit_Rec_Id__c='1234'));
        }
        insert dupList;
        Test.startTest();
        Database.executeBatch(new DuplicateEmailCountBatch());
        Test.stopTest();
        Contact con=[SELECT Id FROM COntact where firstname='test'];
        Duplicate_Contact_Analyze__c dupCheck = [SELECT id,CountOfOpportunity__c,TotalOpportunityAmount__c FROM Duplicate_Contact_Analyze__c where ContactId__c=:con.id];
        System.assertEquals(1, dupCheck.CountOfOpportunity__c);
        System.assertEquals(100, dupCheck.TotalOpportunityAmount__c);
    }
    @isTest
    public static void testDup2(){
        List<Duplicate_Contact_Analyze__c> dupList = new List<Duplicate_Contact_Analyze__c>();
        for(Contact con : [SELECT id,Name,Email FROM Contact where email='test@abc.com']){
            dupList.add(new Duplicate_Contact_Analyze__c(ContactId__c=con.id,Email__c=con.Email,RE_Constit_Rec_Id__c='1234'));
        }
        insert dupList;
        Test.startTest();
        Database.executeBatch(new DuplicateEmailCountBatch(null));
        Test.stopTest();
        Contact con=[SELECT Id FROM COntact where firstname='test'];
        Duplicate_Contact_Analyze__c dupCheck = [SELECT id,CountOfOrder__c,TotalOrderAmount__c FROM Duplicate_Contact_Analyze__c where ContactId__c=:con.id];
        System.assertEquals(1, dupCheck.CountOfOrder__c);
        
    }
    
}