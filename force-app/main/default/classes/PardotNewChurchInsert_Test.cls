@isTest(SeeAllData=true)
public class PardotNewChurchInsert_Test {
    @isTest(SeeAllData=true)
    public static void testPardotMethod(){
        Contact c = new Contact(FirstName='Baji',LastName='Basha',Email='test@gmail.com');
        insert c;
        Account acc = new Account(Name='TestAccount',Phone='9789922724',Physical_City__c='Ongole',Physical_State__c='IL',PhysicalCountry__c='United States',Physical_County__c='RPR',Physical_Zip__c='60013',Church_Attendance__c='100',Language__c='Hindi',Most_Recent_Date_Added__c=system.TODAY(),Applicant__c=c.Id);
        insert acc;
        npe5__Affiliation__c aff = new npe5__Affiliation__c(Church_Role__c='Test Role',npe5__Contact__c=c.Id,npe5__Organization__c=acc.Id);
        insert aff;
        Test.setMock(HttpCalloutMock.class, new PardotMockTestCallouts(true));
        Test.startTest();        
        Dom.Document doc = new Dom.Document();
        PardotNewChurchInsert.createProspect(acc.Name,c.FirstName,c.LastName,c.Email);
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    public static void testCallPardotMethod(){
        //Test.setMock(HttpCalloutMock.class, new myMock(true));
        Contact c1 = new Contact(FirstName='Test',LastName='Baji',Email='newpardottest@gmail.com');
        insert c1;
        Account acc = new Account(Name='TestAccount1',Phone='9789922724',Applicant__c=c1.Id);
        insert acc;
        
        List<Id> accIds = new List<Id>();
        accIds.add(acc.Id);
        Account acc1 = [select Id,Name,Applicant__c from Account where Id IN :accIds];
        //accIds.add(acc1.Id);
        Test.startTest();
        PardotNewChurchInsert.createAccountTOProspect(accIds);
        Test.stopTest();
    }
    
}