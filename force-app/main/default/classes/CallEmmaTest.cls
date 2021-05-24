/********************************************************************************************************
 Updated:      7/11/2017 - Added SeeAllData=true.
 *****************************************************************************************************************/

@isTest(SeeAllData=true)
public class CallEmmaTest {
    @isTest(SeeAllData=true)
    public static void testCampaignMembersMethod(){
        Test.setMock(HttpCalloutMock.class, new myMock(false));
        Campaign cmpn = new Campaign(Name='Test Campaign');
        Contact c = new Contact(FirstName='Baji',LastName='Basha',Email='test@gmail.com');
        insert cmpn;
        insert c;
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cmpn.Id;
        cm.ContactId = c.Id;
        insert cm;
        List<Id> cmIds = new List<Id>();
        cmIds.add(cm.Id);
        Test.startTest();        
        CallEmma.getEmmaCampaignMember(cmIds);
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    public static void testCallEmmaMethod(){
        Test.setMock(HttpCalloutMock.class, new myMock(false));
        Contact c = new Contact(FirstName='Baji',LastName='Basha',Email='test@gmail.com');
        insert c;
        Test.startTest();
        CallEmma.callEmmaMember(c.FirstName,c.LastName,c.Email,'1234');
        Test.stopTest();
    }
    
}