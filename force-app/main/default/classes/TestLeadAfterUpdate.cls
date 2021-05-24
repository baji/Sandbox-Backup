@isTest
private class TestLeadAfterUpdate {
    
      @isTest static void testAfterUpdate(){
          
        Awana_Settings__c myCSTest1 = new Awana_Settings__c();
        myCSTest1.name = 'RunLeadTrigger';
        myCSTest1.Value__c = 'true';
        insert myCSTest1;
        
        Awana_Settings__c myCSTest2 = new Awana_Settings__c();
        myCSTest2.name = 'ExecuteInquiryTrigger';
        myCSTest2.Value__c = 'true';
        insert myCSTest2;
                
        Awana_Settings__c myCSTest3 = new Awana_Settings__c();
        myCSTest3.name = 'ExecuteREMigrationAction';
        myCSTest3.Value__c = 'true';
        insert myCSTest3;
        
        Awana_Settings__c myCSTest4 = new Awana_Settings__c();
        myCSTest4.name = 'ExecuteTaskTrigger';
        myCSTest4.Value__c = 'true';
        insert myCSTest4;
        
        
        RecordType usorg = [Select Id from RecordType where SObjectType = 'Account' and Name = 'US Organization'];
           
           Lead thisLead = new Lead(Company='Dev Test Org',
            IsConverted = false,
            Status='New',
            FirstName= 'Tester',
            LastName = 'One',
            Email= 'Tester1@mailinator.com',
            Phone='(503) 312-6669',
            LeadSource = 'NYC',
            Club_Interest__c = 'Parents & Family',
            Missionary_Source__c = 'Awana Applications',
            PhysicalStreet1__c = '5424 SE 84th Ave',
            PhysicalCity__c = 'Portland',
            PhysicalState__c = 'OR',
            PhysicalZipCode__c = '97266',
            Physical_Country__c = 'United States');
            insert thisLead;
        
            List<Task> theseTasks = new List<Task>();
            theseTasks.add(new Task( 
                              Subject = 'Call',
                              ReminderDateTime=system.today(),
                              Status='Not Started',
                                WhoId = thisLead.Id));

            theseTasks.add(new Task(
                              Subject = 'Church Visit',
                              ReminderDateTime=system.today(),
                              Status='Not Started',
                            WhoId = thisLead.Id));
      try{
            insert theseTasks;
       }catch(Exception ex){
            system.debug('<< TASKS ERR MESSAGE>> '+ex.getMessage());
        }
        
        system.debug('<< LEAD >> '+thisLead);
//Simulate the DocuSign Process of creating both the account and the contact for the Lead thuse closing it.      
        
        List<Event> theseEvents = new List<Event>();
        theseEvents.add(new Event(
                        Type='Email',
                        Description='Test',
                        WhoId = thisLead.Id,
                        DurationInMinutes=10,
                        ActivityDateTime= System.now()
                    ));
        theseEvents.add(new Event(
                        Type='Call',
                        Description='Test2',
                        WhoId = thisLead.Id,
                        DurationInMinutes=10,
                        ActivityDateTime= System.now()
                    ));
        try{
        insert theseEvents;   
        }catch(Exception ex){
            system.debug('<< EVENTS ERR MESSAGE>> '+ex.getMessage());
        }
                Account thisAccount = new Account(Name='Dev Test Org', Status__c = 'Pending', Type='US Church', RecordTypeId=usorg.Id );
        Contact thisContact = new Contact(FirstName='Tester', LastName='One',Email='Tester1@mailinator.com');
        Date tempDate = date.today();
        Integer month = tempDate.month();
        Integer day = tempDate.day();
        Integer year = tempDate.year();
        year++;
        Opportunity thisOpp = new Opportunity(Name='Tester-O', StageName='Order Open', CloseDate=date.newInstance(year+2, month, day));
        upsert thisAccount;
        upsert thisContact; 
        upsert thisOpp;
        thisLead.AcountID__c = thisAccount.Id;
        thisLead.ContactID__c = thisContact.Id;
        update thisLead;    
        
        system.debug('thisLead.owner--'+thisLead.owner);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(thisLead.id);
      
    Test.startTest();
        LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
              
    Test.stopTest();
      }
      }