@isTest
public class Test_CampDupRemove{
    @testSetup static void setupData(){
        
        Campaign parentCamp = new Campaign();
            parentCamp.Name = 'Camp203';
            parentCamp.IsActive = true;
        Insert parentCamp;

        List<Campaign> listChildCamp = new List<Campaign>();
            listChildCamp.add(new Campaign(Name='Camp203A',ParentId=parentCamp.Id,IsActive=true,Segment_Priority__c='1'));
            listChildCamp.add(new Campaign(Name='Camp203B',ParentId=parentCamp.Id,IsActive=true,Segment_Priority__c='2'));
            listChildCamp.add(new Campaign(Name='Camp203C',ParentId=parentCamp.Id,IsActive=true,Segment_Priority__c='3'));
        Insert listChildCamp;

        Awana_Settings__c aws = new Awana_Settings__c();
            aws.Value__c = 'true';
            aws.Name = 'EnableDeDupCheck';
        Insert aws;

        List<Contact> listCon = new List<Contact>();
            listCon.add(new Contact(LastName='Imran'));
            listCon.add(new Contact(LastName='Naheeda'));
            listCon.add(new Contact(LastName='Imaad'));
            listCon.add(new Contact(LastName='Jyothi'));
        Insert listCon;

        List<CampaignMember> listCampMem = new List<CampaignMember>();
            listCampMem.add(new CampaignMember(ContactId=listCon[0].Id,CampaignId=listChildCamp[0].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[1].Id,CampaignId=listChildCamp[0].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[0].Id,CampaignId=listChildCamp[1].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[1].Id,CampaignId=listChildCamp[1].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[2].Id,CampaignId=listChildCamp[1].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[0].Id,CampaignId=listChildCamp[2].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[2].Id,CampaignId=listChildCamp[2].Id,Status='Sent'));
            listCampMem.add(new CampaignMember(ContactId=listCon[3].Id,CampaignId=listChildCamp[2].Id,Status='Sent'));
        Insert listCampMem;

    }

    static testMethod void testMethod1(){
        String parentId = [SELECT Id FROM Campaign WHERE Name='Camp203' LIMIT 1].Id;
         Campaign cmp = new Campaign();
        Apexpages.StandardController stdController = new Apexpages.StandardController(cmp);
        test.startTest();
        CampDupRemove cmpDup = new CampDupRemove(stdController);
        CampDupRemove.duplicateRemove(parentId);
        test.stopTest();
        List<Campaign> listPriority = [SELECT Id FROM Campaign WHERE parentId=:parentId AND Segment_Priority__c ='2'];
        system.assertEquals(listPriority.size(),1);
    }

    static testMethod void testMethod2(){
        String parentId = [SELECT Id FROM Campaign WHERE Name='Camp203' LIMIT 1].Id;
        PageReference pageRef = Page.RemoveDuplicateMembers;
            pageref.getparameters().put('id',parentId);
        Test.setCurrentPage(pageRef);
        Campaign cmp = new Campaign();
        Apexpages.StandardController stdController = new Apexpages.StandardController(cmp);
        test.startTest();
        CampDupRemove cmpDup = new CampDupRemove(stdController);
        CampDupRemove.removeDuplicate();
        test.stopTest();
        List<Campaign> listPriority = [SELECT Id FROM Campaign WHERE parentId=:parentId AND Segment_Priority__c ='3'];
        system.assertEquals(listPriority.size(),1);
    }

    static testMethod void testMethod3(){
    
        Campaign cam = new Campaign();
            cam.Name = 'Camp203G';
            cam.ParentId = [SELECT Id FROM Campaign WHERE Name='Camp203' LIMIT 1].Id;
            cam.Segment_Priority__c = '1';
        Database.SaveResult result = Database.insert(cam, false);
         System.assertEquals('Duplicate priority under parent campaign',result.getErrors()[0].getMessage());

        Campaign camp = [SELECT Id,Name,Segment_Priority__c FROM Campaign WHERE Name='Camp203A' LIMIT 1];
            camp.Segment_Priority__c = '2';
         Database.SaveResult result1 = Database.update(camp, false);
          System.assertEquals('Duplicate priority under parent campaign',result1.getErrors()[0].getMessage());
    }
}