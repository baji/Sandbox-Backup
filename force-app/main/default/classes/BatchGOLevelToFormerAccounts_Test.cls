/*************************************************************************************************************************
    Programmer:   Tony Williams
    Company:      Awana
    Contact:      tonyw@awana.org
    Project:       Batch GO Level To Former
    Description:   Used to Test batch Apex Scheduler to set all L1 - L3 GO Levels on GO Account records  to Former annually.
    Original:     7/13/2017
****************************************************************************************************************************/

@isTest
public class BatchGOLevelToFormerAccounts_Test {
 
    static testMethod void BatchGOLevelToFormerAccounts_TestMethod (){
        RecordType rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];
        Date currentDate = Date.today();
        Integer someYear = currentDate.year();
        String campaignName = 'GO Coordinator Campaign '+someYear;
        List<Account>  usOrgAccount = new List<Account>();
        List<String> accountIds = new List<String>();
        List<npe5__Affiliation__c> testAffiliation = new List<npe5__Affiliation__c>();
        List<Contact> cs = new List<Contact>();
        cs.add(new Contact(FirstName = 'Bilbo',LastName='Baggins',Email = 'bilbob@mailinator.com'));
        cs.add(new Contact(FirstName ='Frodo',LastName='Baggins',Email ='frodob@mailinator.com'));
        cs.add(new Contact(FirstName ='Meri',LastName='Brandibuck',Email ='brandiwise@mailinator.com'));
        cs.add(new Contact(FirstName ='Pippin',LastName='Took',Email ='perigrint@mailinator.com'));
        cs.add(new Contact(FirstName ='Sam',LastName='Gamgee',Email ='samwiseg@mailinator.com'));
        insert cs;
        
        usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                        Name='Test Account 1',
                                        GO_Submission_Date__c =System.Today(),
                                        GO_Level__c = 'Level 1',
                                        Estimated_Club_Size__c = 26,
                                        GO_Missions_Month__c = 'July',
                                        Planning_a_Verse_a_Thon__c = 'Yes',
                                        Status__c = 'Added',
                                        Verse_A_Thon__c = 'April',
                                        Registration_Level__c = 'R1')
                    );
        usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                        Name='Test Account 2',
                                        GO_Submission_Date__c =System.Today(),
                                        GO_Level__c = 'Level 1',
                                        Estimated_Club_Size__c = 26,
                                        GO_Missions_Month__c = 'July',
                                        Planning_a_Verse_a_Thon__c = 'Yes',
                                        Status__c = 'Added',
                                        Verse_A_Thon__c = 'April',
                                        Registration_Level__c = 'R2')
                    );
        usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                        Name='Test Account 3',
                                        GO_Submission_Date__c =System.Today(),
                                        GO_Level__c = 'Level 1',
                                        Estimated_Club_Size__c = 26,
                                        GO_Missions_Month__c = 'July',
                                        Planning_a_Verse_a_Thon__c = 'Yes',
                                        Status__c = 'Added',
                                        Verse_A_Thon__c = 'April',
                                        Registration_Level__c = 'R3')
                    );
        usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                        Name='Test Account 4',
                                        GO_Submission_Date__c =System.Today(),
                                        GO_Level__c = 'Level 1',
                                        Estimated_Club_Size__c = 26,
                                        GO_Missions_Month__c = 'July',
                                        Planning_a_Verse_a_Thon__c = 'Yes',
                                        Status__c = 'Added',
                                        Verse_A_Thon__c = 'April',
                                        Registration_Level__c = 'R2')
                    );
        usOrgAccount.add(new Account (RecordTypeId =rc.Id, 
                                        Name='Test Account 5',
                                        GO_Submission_Date__c =System.Today(),
                                        GO_Level__c = 'Level 1',
                                        Estimated_Club_Size__c = 26,
                                        GO_Missions_Month__c = 'July',
                                        Planning_a_Verse_a_Thon__c = 'Yes',
                                        Status__c = 'Added',
                                        Verse_A_Thon__c = 'April',
                                        Registration_Level__c = 'R3')
                    );
        insert usOrgAccount;
        //5th Affiliation to handle the Formatting of reset GO accounts in the Batch finish method. reaching 100%
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[0].Id,npe5__Contact__c = cs[0].Id, Awana_Role__c = 'Awana GO Coordinator', npe5__Status__c = 'Current'));
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[1].Id,npe5__Contact__c = cs[1].Id, Awana_Role__c = 'Awana at Home Director;Awana GO Coordinator;Awana Ministry Director', npe5__Status__c = 'Current'));
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[2].Id,npe5__Contact__c = cs[2].Id, Awana_Role__c = 'Awana at Home Director;Awana GO Coordinator', npe5__Status__c = 'Current'));
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[3].Id,npe5__Contact__c = cs[3].Id, Awana_Role__c = 'Awana GO Coordinator;Awana Ministry Director', npe5__Status__c = 'Current'));
        testAffiliation.add(new npe5__Affiliation__c (npe5__Organization__c = usOrgAccount[4].Id,npe5__Contact__c = cs[4].Id, Awana_Role__c = 'Awana GO Coordinator;Clubber Parent', npe5__Status__c = 'Current'));

        insert testAffiliation;
        Campaign camp = new Campaign(Name=campaignName, Status='In Progress');
        insert camp;
        
       // List <CampaignMember> deleteMember = [Select Id from CampaignMember where CampaignId =: camp.Id];
       // delete deleteMember;
        /// Commented by Mayur for deployment 12/06/2017
        List<CampaignMember> campMembers = new List<CampaignMember>();
        

        //Don't insert this LIst of Members but let the NewCampaignMembersBeforeInsertMgr handle it.
        campMembers.add(new CampaignMember(ContactId=cs[0].Id, CampaignId=camp.Id));
        campMembers.add(new CampaignMember(ContactId=cs[1].Id, CampaignId=camp.Id));
        campMembers.add(new CampaignMember(ContactId=cs[2].Id, CampaignId=camp.Id));
        campMembers.add(new CampaignMember(ContactId=cs[3].Id, CampaignId=camp.Id));
        campMembers.add(new CampaignMember(ContactId=cs[4].Id, CampaignId=camp.Id));
        
        NewCampaignMembersBeforeInsertMgr.handleNewCampaignMembersBeforeInsert(campMembers);
        
        BatchGOLevelToFormerAccounts batchObj = new BatchGOLevelToFormerAccounts();

        String querySoql 
              = 'Select Id, '
                + ' Name, '
                + ' GO_Submission_Date__c, '
                + ' GO_Level__c, '
                + ' Estimated_Club_Size__c, '
                + ' GO_Missions_Month__c, '
                + ' Verse_A_Thon__c, '
                + ' Planning_a_Verse_a_Thon__c '
                + 'From Account WHERE Registration_Status__c <> \'Dropped\' and Registration_Level__c <> null and Status__c = \'Added\' and RecordType.Name=\'US Organization\' and GO_Level__c in (\'Level 1\', \'Level 2\',\'Level 3\')';   
      
        system.debug('<< QUERY  >> '+querySoql);
        Test.startTest();
        batchObj.query = querySoql;
        Database.executeBatch(batchObj);
        
        BatchGOLevelToFormerSchedule j = new  BatchGOLevelToFormerSchedule();
        String sch = '0 50 15 30 6 ? *';
        String jobID = system.schedule('BatchGOLevel', sch, j);
        
        Test.stopTest();
        
    } // 

} // Class