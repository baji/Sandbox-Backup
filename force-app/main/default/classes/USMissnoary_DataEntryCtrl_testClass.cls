@isTest(SeeAllData=false)
private class USMissnoary_DataEntryCtrl_testClass {

    static testMethod void usmnryDataEntryTest(){
         Profile portal_profiles = [Select Id, Name From Profile Where  Name  = 'Awana Customer Care'];
        Profile UserProfile = portal_profiles;
         Contact c = new Contact(FirstName = 'Marty',
                                LastName = 'Faye',
                                Email='mfaye@mailinator.com');
        User currentOwner = new User(
                                //ContactId = c.Id,
                                FirstName='shaik',
                                LastName='baji',
                                UserName='mfaye@mailinator.com.test',
                                email='mfaye@mailinator.com',
                                alias='mafaye',
                                TimeZoneSidKey = 'America/Chicago',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US', 
                                EmailEncodingKey = 'ISO-8859-1',
                                CommunityNickName = c.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
                                ProfileId =UserProfile.Id);
        insert currentOwner;            
        Test.startTest();
                     
        ID oppRID = [SELECT Id from RecordType where name = 'Orders'].Id;
        ID oppmaRID = [Select Id from RecordType where name = 'Ministry Advancement'].Id;
        
        //usmnry_DataEntryController_forTest usdc = new usmnry_DataEntryController_forTest();
        USMissinoary_DataEntryCtrl usdc = new USMissinoary_DataEntryCtrl();
        
        Account account1 = new Account(Name='Test1',Type='Church');
        
        insert account1;
        
        usdc.s = account1.Id;
        string searchText;        
         string state;         
        string searchtextCID; 
        boolean inactiveCheckbox;
             
        usdc.searchtextCID = 'chennai';
        usdc.searchText = 'shaik';
        usdc.state = 'TN';                      
        usdc.inactiveCheckbox=false;
            
        string Err;
        usdc.Err = 'Records not found for your search';
        usdc.Err = '';
        
        
        List<Account> searchResults = new List<Account>();
        List<Account> searchResults1 = new List<Account>();
        usdc.search();
        
        usdc.searchtextCID = '';
        usdc.searchText = 'shaik';
        usdc.state = '';                     
        usdc.inactiveCheckbox=false;
        
        usdc.search();
                
        usdc.searchText = '';
        usdc.searchtextCID = 'Irvine';
        usdc.state = '';                     
        usdc.inactiveCheckbox=false;
        
        usdc.search();
                
        usdc.searchText = '';
        usdc.searchtextCID = '';
        usdc.state = 'CA';                     
        usdc.inactiveCheckbox=false;
        
        usdc.search();
        
        usdc.searchText = '';
        usdc.searchtextCID = 'Irvine';
        usdc.state = 'CA';                     
        usdc.inactiveCheckbox=false;
        
        usdc.search();
        
        usdc.searchText = 'shaik';
        usdc.searchtextCID = 'Irvine';
        usdc.state = '';                     
        usdc.inactiveCheckbox=false;
        
        usdc.search();
               
        usdc.searchText = '';
        usdc.searchtextCID = 'bbbb';
        usdc.state = 'ddd';                     
        usdc.inactiveCheckbox=false;
        usdc.Err = 'Records not found for your search';
        usdc.search();
        
        usdc.searchText = 'aaaa';
        usdc.searchtextCID = 'bbbb';
        usdc.state = 'ddd';                     
        usdc.inactiveCheckbox=false;
        usdc.Err = 'Records not found for your search';
        usdc.search();
        
        usdc.searchText = 'aaaa';
        usdc.inactiveCheckbox=false;
        usdc.Err = 'Records not found for your search';
        usdc.search();
        
      //test cases for check true  
        usdc.searchtextCID = '';
        usdc.searchText = 'shaik';
        usdc.state = '';                     
        usdc.inactiveCheckbox=true;
        
        usdc.search();
                
        usdc.searchText = '';
        usdc.searchtextCID = 'Irvine';
        usdc.state = '';                     
        usdc.inactiveCheckbox=true;
        
        usdc.search();
                
        usdc.searchText = '';
        usdc.searchtextCID = '';
        usdc.state = 'CA';                     
        usdc.inactiveCheckbox=true;
        
        usdc.search();
                
        usdc.searchText = 'shaik';
        usdc.searchtextCID = 'Irvine';
        usdc.state = 'CA';                     
        usdc.inactiveCheckbox=true;
        
        usdc.search();
               
        usdc.searchText = '';
        usdc.searchtextCID = 'Irvine';
        usdc.state = 'CA';                     
        usdc.inactiveCheckbox=true;
        
        usdc.search();
        
        usdc.searchText = 'shaik';
        usdc.searchtextCID = 'Irvine';
        usdc.state = '';                     
        usdc.inactiveCheckbox=true;
        
        usdc.search();
        
            
        Contact contact = new Contact();
        Contact contact1 = new Contact(LastName='testContact1',FirstName='testContact1',Email='baji@test.com',Phone='9789922724',AccountId=account1.id);
        insert contact1;
        
        // Account
        List<Account> accs1 = [select Id,Name,Phone,Fax,Website,Mailing_Address_Book__c,
                                Physical_City__c,Physical_Zip__c,Physical_State__c,Denomination__c,
                                Church_Attendance__c,Primary_Ethnic_Group__c,Primary_Moves_Manager__c,Primary_Moves_Manager__r.Id
                                From Account where id=:account1.id];
        
        accs1 = usdc.getNewm();
        
        Account acc = [select Id,Name,Phone,Fax,Website,Mailing_Address_Book__c,
                       Physical_City__c,Physical_Zip__c,Physical_State__c,Denomination__c,
                       Church_Attendance__c,Primary_Ethnic_Group__c,Primary_Moves_Manager__c,Primary_Moves_Manager__r.Id
                       From Account where id=:account1.id];
                       
        acc = usdc.getAct();              
        
        //Contact
        List<Contact> conList = [select Id,Name,Email,HomePhone,MobilePhone,Church_Role__c,Awana_Role__c                                 
                                 From Contact where Account.Id = :account1.id and Active__c = true ORDER By Name ASC];
        conList = usdc.getCons();
        
        List<Contact> sconList = [select Id,LastName,FirstName,Email,MobilePhone,Church_Role__c,Awana_Role__c From Contact where Id = :contact1.id];
        sconList = usdc.getScon();
        
        Contact con = [select Id,Name,Email,HomePhone,MobilePhone,Church_Role__c,Awana_Role__c                                 
                       From Contact where Account.Id = :account1.id and Active__c = true ORDER By Name ASC];
        
        con = usdc.getCnt();
        
        contact1 = usdc.getCon();  
        
        usdc.accedit();
        usdc.edit();
        usdc.getSelected();
        
        //Opportunity
        Opportunity opp = new Opportunity(RecordTypeId=String.ValueOf(oppRID),Name='testOpp',Type='Donation',closeDate= system.today(),stageName='Prospecting',AccountId=account1.id);
        insert opp;
        Opportunity opp2 = new Opportunity(RecordTypeId=String.ValueOf(oppRID),Name='MA-testOpp',Type='Donation',closeDate= system.today(),stageName='Prospecting',AccountId=account1.id);
        insert opp2; 
        usdc.getSelectedopp();
        
        Opportunity maopp = new Opportunity(RecordTypeId=String.ValueOf(oppmaRID),Name='MA-testOpp1',Type='Ministry Connection',closeDate= system.today(),stageName='Prospecting',AccountId=account1.id);
        insert maopp;
        usdc.getOpp();
        
                
        
        List<Opportunity> oppList = [select Id,Name,Type,CloseDate,StageName From Opportunity where Account.Id = :account1.id and RecordTypeId =: oppRID];
        oppList = usdc.getOpps();
        
        List<Opportunity> oppListSingle = [select Id,Name,Type,CloseDate,StageName From Opportunity where Id = : opp2.id];
        oppListSingle = usdc.getSinopp();
                      
        //Task        
        Task t = new Task(whatid=opp2.id,whoid=contact1.id,Subject='call',ActivityDate=system.today(),Type='meeting',Priority='Low',Status='Completed');
        insert t;
        
        List<Task> taskList = [select Id,OwnerId,whoId,whatId,Subject,Type,ActivityDate,Priority,Status From Task where whatid = :opp2.Id]; 
        taskList = usdc.getTasks();
                
        List<Task> staskList = [select Id,OwnerId,whoId,whatId,Subject,Type,ActivityDate,Priority,Status From Task where whatid = :opp2.Id]; 
        staskList = usdc.getEdittask();
        
        Task tas = [select Id,OwnerId,whoId,whatId,Subject,Type,ActivityDate,Priority,Status From Task where whatid = :opp2.Id]; 
        tas = usdc.getTasknew();
       
        Task tsk1 = usdc.getMytask();  
                      
        usdc.oppedit(); 
        usdc.oppUpdate();      
        usdc.taskedit();
        usdc.addEdit();
        usdc.canaddEdit();
        usdc.canEdit();
        usdc.conCancel();
        usdc.oppCancel();
        usdc.taskCancel();
        usdc.oppTypeCancel();
        usdc.updateAddress();
        usdc.updateAccount();
        usdc.taskUpdate();
        usdc.taskSave();
        usdc.update1();
        usdc.update2();
        usdc.conSave();
        
            
        OpportunityContactRole role = new OpportunityContactRole(opportunityId=maopp.id,contactId=contact1.id);
        insert role;
        OpportunityContactRole opprole = new OpportunityContactRole(opportunityId=maopp.id,contactId=contact1.id);
        OpportunityContactRole opprole1 = new OpportunityContactRole(opportunityId=opp2.id,contactId=contact1.id);
       
        insert opprole;
        
        //upsert opprole1;
        OpportunityContactRole role1 = usdc.getRole();
        
        OpportunityContactRole opcr = usdc.getOpprole();
        
       
         
        User u = [Select Id, Name from User where firstname='shaik' AND Lastname='baji' Limit 1];
        OpportunityTeamMember oppteam = new OpportunityTeamMember(opportunityId=opp2.id,userId=u.id);
        insert oppteam;
        
        OpportunityTeamMember oppteam2 = usdc.getOtm();
        
        OpportunityTeamMember oppteam1 = usdc.getOppteam();
        
        OpportunityTeamMember oppteam1single = [select Id,TeamMemberRole,UserID From OpportunityTeamMember where OpportunityId =: opp2.id Limit 1];
               
        usdc.oppSave();
        
        Opportunity optnew = new Opportunity(RecordTypeId=String.ValueOf(oppmaRID),Name='MA-testOpp2',Type='Ministry Connection',closeDate= system.today(),stageName='Prospecting',AccountId=account1.id);
        insert optnew;
                
         Opportunity op = [select Id,Name,OwnerId,Created_Date_Time__c,Interest__c,Region__c,Country__c,Project_Code__c,Probability,Type,CloseDate,StageName,
                         (select ContactId from OpportunityContactRoles Limit 1)
                          From Opportunity where Id =: maopp.Id];
        system.debug('***********op****************'+op);                  
        op = usdc.getOptnew();
        
        optnew.Name='MA-testOpp2';
        optnew.StageName='Prospecting';
        optnew.Type='Donation';
        update optnew;
        
        opprole.contactId=contact1.id;
        update opprole;
        
                               
        usdc.oppUpdate();
        Test.stopTest();      
      }
}