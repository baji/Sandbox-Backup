@isTest(SeeAllData=true) 
private class Report_Accounts_by_Role_Test {

    static testMethod void reportAccountByRole() {
        // Create The Accounts
        List<Account> a2 = new List<Account>();
        a2.add(new Account(Name='Holy Light Church'));
        insert a2;
        RecordType  getRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
        Profile portal_profiles = [Select Id, Name From Profile Where  Name  = 'Awana Customer Care'];
        Profile UserProfile = portal_profiles;
        Contact c = new Contact(FirstName = 'Marty',
                                LastName = 'Faye',
                                Email='mfaye@mailinator.com');
        insert c;
        User currentOwner = new User(
                                //ContactId = c.Id,
                                FirstName='Marty',
                                LastName='Faye',
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
        User currentOwnerMgr = new User(
                                //ContactId = c.Id,
                                FirstName='Linda',
                                LastName='Moya',
                                UserName='lmoya@mailinator.com.test',
                                email='lmoya@mailinator.com',
                                alias='lmoya',
                                TimeZoneSidKey = 'America/Chicago',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US', 
                                EmailEncodingKey = 'ISO-8859-1',
                                CommunityNickName = c.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
                                ProfileId =UserProfile.Id);
        insert currentOwnerMgr;
        a2[0].ShippingStreet = '144 Clipper St';
        a2[0].Mailing_Street_1__c ='2712 41st Ave' ;
        a2[0].ShippingCity = 'San Francisco';
        a2[0].Mailing_City__c = 'San Francisco';
        a2[0].ShippingState = 'CA';
        a2[0].Mailing_State_Province__c='CA';
        a2[0].ShippingCountry ='United States';
        a2[0].Mailing_Country__c='United States';
        a2[0].ShippingPostalCode = '94116';
        a2[0].Mailing_Zip_Postal_Code__c = '94116';
        a2[0].BillingStreet='144 Clipper St';
        a2[0].Physical_Street_1__c ='2638 16th Ave';
        a2[0].BillingCity = 'San Francisco';
        a2[0].Physical_City__c ='San Francisco';
        a2[0].BillingState ='CA';
        a2[0].Physical_State__c = 'CA';
        a2[0].BillingCountry = 'United States';
        a2[0].PhysicalCountry__c = 'United States';
        a2[0].BillingPostalCode = '94116';
        a2[0].Physical_Zip__c = '94114';
        a2[0].RecordType =getRecordType;
        a2[0].OwnerId=currentOwner.Id;
        update a2;
        
        Test.startTest();
        
        system.debug('<<A2 Account >> '+a2);    
        ApexPages.StandardSetController con = new ApexPages.StandardSetController([select Id,Name From Account where Id =: a2[0].Id]);
        PageReference pageRef = Page.Report_Accounts_and_Contacts_by_Role;
        Test.setCurrentPage(pageRef);
        
        Report_Accounts_by_Role_Controller tc = new Report_Accounts_by_Role_Controller();
        Report_Accounts_by_Role_Controller tc1 = new Report_Accounts_by_Role_Controller();
        Report_Accounts_by_Role_Controller tc2 = new Report_Accounts_by_Role_Controller();
        
        ApexPages.currentPage().getParameters().put('Export','true');
        ApexPages.currentPage().getParameters().put('Export','false');
        system.debug('<<ARE WE EXPORT? >> '+tc.isExport);
        tc.pickedValue = 'IL';
        tc.pickedAwanaRole = 'Commander';
        tc.pickedValue1  = 'IL';
        tc.pickedChurchRole = 'Pastor/Associate Pastor';
        User User1 = [Select Id from User where Name = 'Linda Moya' limit 1];
        Account acc = [Select Id,OwnerId from Account Limit 1];
        tc.aUser.OwnerId = String.valueOf(acc.OwnerId);
        tc.usr.ManagerId = String.valueOf(User1.Id);        
        tc.isExport = true;
        tc.isExport = false;         
        tc.reportResults();
        tc.addCampaign();       
        tc.export();        
        tc.PREVIOUS();
        tc.NEXT();
        tc.searchResults = (List<Account>)con.getRecords();
        
        tc1.pickedValue = 'IL';
        tc1.pickedAwanaRole = 'Commander';
        tc1.pickedValue1  = 'IL';
        tc1.pickedChurchRole = 'test';
        tc1.usr.ManagerId = null;        
        tc1.isExport = true;
        tc1.isExport = false;         
        tc1.reportResults();
        system.debug('<<TC1 Roles BEFORE CAMPAIGN >> '+tc1);
        tc1.addCampaign();       
        tc1.export();        
        tc1.PREVIOUS();
        tc1.NEXT();
        tc1.searchResults = (List<Account>)con.getRecords();
        
        tc2.pickedValue = 'test';
        tc2.pickedAwanaRole = 'test';
        tc2.pickedValue1  = 'IL';
        tc2.pickedChurchRole = 'Pastor/Associate Pastor';        
        User User2 = [Select Id from User where Name = 'Linda Moya' limit 1];
        Account acc1 = [Select Id,OwnerId from Account Limit 1];
        tc2.aUser.OwnerId = String.valueOf(acc1.OwnerId);
        tc2.usr.ManagerId = String.valueOf(User2.Id);        
        tc2.isExport = true;
        tc2.isExport = false;         
        tc2.reportResults();
         system.debug('<<TC2 Roles BEFORE CAMPAIGN >> '+tc2);
        tc2.addCampaign();       
        tc2.export();        
        tc2.PREVIOUS();
        tc2.NEXT();
        tc2.searchResults = (List<Account>)con.getRecords();
        
        Boolean next = tc.hasNext;
        Boolean previous = tc.hasPrevious;
        
        Test.stopTest();
      
    }
    
        static testMethod void reportAccountByRole_Export(){
            Test.startTest();
                Report_Accounts_by_Role_Export tc1 = new Report_Accounts_by_Role_Export();
                Report_Accounts_by_Role_Export tc2 = new Report_Accounts_by_Role_Export();
                Report_Accounts_by_Role_Export tc3 = new Report_Accounts_by_Role_Export();
                PageReference pageRef = Page.Report_Accounts_Contacts_by_Role_Export;
                
                tc1.aRole = 'Commander';      
                tc1.aState = 'test';
                tc1.cRole = 'Pastor/Associate Pastor';      
                User User1 = [Select Id from User where Name = 'Awana Applications' limit 1];
                tc1.usrId = String.valueOf(User1.Id);                           
                List<Account> aList = tc1.getAllResults();
                
                tc2.aRole = 'test';
                tc2.cRole = 'Pastor/Associate Pastor';
                tc2.aState = 'IL';
                tc2.usrId = '';        
                List<Account> aList1 = tc2.getAllResults();
                
                tc3.aRole = 'Commander';
                tc3.cRole = 'Youth Pastor';
                tc3.aState = 'IL';
                User User2 = [Select Id from User where Name = 'Awana Applications' limit 1];
                tc3.usrId = String.valueOf(User2.Id);        
                List<Account> aList2 = tc3.getAllResults();
            Test.stopTest();
            
        }
 
      static testMethod void reportAccountByRole_TestMethod(){
          List<Account> a2 = new List<Account>();
            a2.add(new Account(Name='Holy Light Church'));
            insert a2;
          
          Report_Accounts_by_Role_Controller tc = new Report_Accounts_by_Role_Controller();
          User u = TestObjects.NewUser();
          tc.usrid = u.id;
          tc.u = u.name;
          ApexPages.StandardSetController con = new ApexPages.StandardSetController([select Id,Name From Account where Id =: a2[0].Id]);
          List<Account> accList = tc.searchResults;
          
          tc.hasNext = true;
          tc.hasPrevious =  false;
          
          Test.startTest();
          
              tc.pickedAwanaRole = 'test';
              tc.pickedChurchRole = 'test';
              tc.reportResults();
              
              Report_Accounts_by_Role_Export tc1 = new Report_Accounts_by_Role_Export();
              tc1.aRole = 'test'; 
              tc1.cRole = 'test';
              tc1.aState = 'commander';
              PageReference pageRef = Page.Report_Accounts_Contacts_by_Role_Export;
              
              Test.setCurrentPageReference(new PageReference('Page.Report_Accounts_Contacts_by_Role_Export')); 
              System.currentPageReference().getParameters().put('aRole', 'test');
              System.currentPageReference().getParameters().put('cRole', 'test');
              System.currentPageReference().getParameters().put('aState', 'test');
              
              System.currentPageReference().getParameters().put('Export', 'true');
              
              //tc.addCampaign();
              tc.export();
              
          Test.stopTest();
          
    }   
    
    static testMethod void reportAccountByRole_Test() {
        // Create The Accounts
        List<Account> a2 = new List<Account>();
        a2.add(new Account(Name='Holy Light Church'));
        insert a2;
        RecordType  getRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
        Profile portal_profiles = [Select Id, Name From Profile Where  Name  = 'Awana Customer Care'];
        Profile UserProfile = portal_profiles;
        Contact c = new Contact(FirstName = 'Marty',
                                LastName = 'Faye',
                                Email='mfaye@mailinator.com');
        insert c;
        User currentOwner = new User(
                                //ContactId = c.Id,
                                FirstName='Marty',
                                LastName='Faye',
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
        User currentOwnerMgr = new User(
                                //ContactId = c.Id,
                                FirstName='Linda',
                                LastName='Moya',
                                UserName='lmoya@mailinator.com.test',
                                email='lmoya@mailinator.com',
                                alias='lmoya',
                                TimeZoneSidKey = 'America/Chicago',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US', 
                                EmailEncodingKey = 'ISO-8859-1',
                                CommunityNickName = c.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
                                ProfileId =UserProfile.Id);
        insert currentOwnerMgr;
        a2[0].ShippingStreet = '144 Clipper St';
        a2[0].Mailing_Street_1__c ='2712 41st Ave' ;
        a2[0].ShippingCity = 'San Francisco';
        a2[0].Mailing_City__c = 'San Francisco';
        a2[0].ShippingState = 'CA';
        a2[0].Mailing_State_Province__c='CA';
        a2[0].ShippingCountry ='United States';
        a2[0].Mailing_Country__c='United States';
        a2[0].ShippingPostalCode = '94116';
        a2[0].Mailing_Zip_Postal_Code__c = '94116';
        a2[0].BillingStreet='144 Clipper St';
        a2[0].Physical_Street_1__c ='2638 16th Ave';
        a2[0].BillingCity = 'San Francisco';
        a2[0].Physical_City__c ='San Francisco';
        a2[0].BillingState ='CA';
        a2[0].Physical_State__c = 'CA';
        a2[0].BillingCountry = 'United States';
        a2[0].PhysicalCountry__c = 'United States';
        a2[0].BillingPostalCode = '94116';
        a2[0].Physical_Zip__c = '94114';
        a2[0].RecordType =getRecordType;
        a2[0].OwnerId=currentOwner.Id;
        update a2;
        
        Test.startTest();
        
        system.debug('<<A2 Account >> '+a2);    
        ApexPages.StandardSetController con = new ApexPages.StandardSetController([select Id,Name From Account where Id =: a2[0].Id]);
        PageReference pageRef = Page.Report_Accounts_and_Contacts_by_Role;
        Test.setCurrentPage(pageRef);
        
         
        Report_Accounts_by_Role_Controller tc = new Report_Accounts_by_Role_Controller();
        
        User u = TestObjects.NewUser();
          tc.usrid = u.id;
          
        Report_Accounts_by_Role_Controller tc1 = new Report_Accounts_by_Role_Controller();
        Report_Accounts_by_Role_Controller tc2 = new Report_Accounts_by_Role_Controller();
        
        tc.pickedValue = 'IL';
        tc.pickedAwanaRole = 'Commander';
        tc.pickedValue1  = 'IL';
        tc.pickedChurchRole = 'Pastor/Associate Pastor';
        User User1 = [Select Id from User where Name = 'Linda Moya' limit 1];
        Account acc = [Select Id,OwnerId from Account Limit 1];
        tc.aUser.OwnerId = String.valueOf(acc.OwnerId);
        tc.usr.ManagerId = String.valueOf(User1.Id);        
        tc.isExport = true;
        tc.isExport = false;         
        tc.reportResults();
        //tc.addCampaign();       
        tc.export();        
        tc.PREVIOUS();
        tc.NEXT();
        tc.searchResults = (List<Account>)con.getRecords();
        
        ApexPages.currentPage().getParameters().put('aState','test1');
        ApexPages.currentPage().getParameters().put('aRole','test1');
        ApexPages.currentPage().getParameters().put('cState','test1');
        ApexPages.currentPage().getParameters().put('cRole','test');
        ApexPages.currentPage().getParameters().put('usrId',u.id); 
        tc2.usr.ManagerId = String.valueOf(User1.Id);
        tc2.usrId = User1.id;
        tc2.addCampaign();
        
       ApexPages.currentPage().getParameters().put('aRole','test'); 
       ApexPages.currentPage().getParameters().put('cRole','test1');
       ApexPages.currentPage().getParameters().put('usrId',u.id); 
        tc2.usrId = u.id;
        tc2.addCampaign();
      
        
       ApexPages.currentPage().getParameters().put('aRole','test'); 
       ApexPages.currentPage().getParameters().put('cRole','test');
       ApexPages.currentPage().getParameters().put('usrId',User1.id); 
        tc2.usrId = u.id;
        tc2.addCampaign();
        
        Test.stopTest();
    }
    
}