/**************************************************************************************************************************
Programmer: Jen L.
Company:    Awana
Contact:    
Project:    Ministry Advancement Opportunity controller - Displays all MA opportunities for a contact.
Created:    04/8/2013
Updated:    04/09/2013 - (Tony W) Updated test cases and the query  to specifically use Database.query method for Contact.AccountId access
**************************************************************************************************************************/
public class MAOppContactExtension {
    
    Contact CurrentContact {get;set;}
    List<Opportunity> MAOpps = new List<Opportunity>();
    
    public MAOppContactExtension(ApexPages.StandardController stdcontroller) {
        this.CurrentContact = (Contact)stdcontroller.getRecord();
        system.debug('<CONTACT> '+this.CurrentContact);
//1. get Miniistry Advancement ID
        RecordType rec = [Select Id From RecordType where Name='Ministry Advancement'];
        String query = '';
        query = 'Select AccountId FROM Contact '
                + 'Where Id = \'' + CurrentContact.Id + '\' '  
                + 'limit 1';  
//2. using Data.query method , get the Conatct object 's account ID.                
         Contact CurrentAcctId = Database.query(query); 
//3. using the Contact's Account ID and record Type ID, get the MA Opportunities.               
         try{
                 if(CurrentAcctId != null){
                  MAOpps = [SELECT Id, Name,Type,Interest__c,StageName,CreatedDate FROM Opportunity WHERE AccountId=:CurrentAcctId.AccountId and RecordTypeId=:rec.Id ORDER BY CreatedDate DESC];
                    system.debug('<MAOPPS> '+MAOpps );
                 }
             
         }
         catch(Exception ex){
              ApexPages.addMessages(ex);   
         }
    }
//4. Display the opportunities to the VF Page
    public List<Opportunity> getMAOpps() { return MAOpps; }
    
     public static testMethod void testContactsExtension() 
    {
        PageReference MAOpportunities_Contact;            // define an instance of the page
        Account testAccount =gettestChurchAccount();  //new Account(Name='Dev Church of the Sandbox',ISO_Code__c='US');
       
        Contact TestContact = getTestContact();
        Opportunity MAOPP = getMAOpportunity();
        Test.startTest();
        // Create a page reference
            MAOpportunities_Contact  = Page.MAOpportunities_Contact;
            ApexPages.StandardController controller  = new ApexPages.StandardController(TestContact); 
            MAOppContactExtension BEC = new MAOppContactExtension(controller);
            List<Opportunity> MAOpps = BEC.getMAOpps();
      Test.stopTest();
    }
    
    public static testMethod Contact getTestContact()
    {
        List<Contact> cons = [Select Id, FirstName, LastName, Email, AccountId From Contact 
            Where Email = 'mattk+portal_informationupdate_test@awana.org' limit 1];
        
        if(cons.size() <= 0)
        {
            cons.add(new Contact(
                FirstName='Test',
                LastName='User',
                Email='mattk+portal_informationupdate_test@awana.org', 
                AccountId = getTestChurchAccount().Id));
            upsert cons;
        }

        return cons[0];
    }

    public static testMethod Account getTestChurchAccount()
    {
        List<Account> accts = [Select Id, Name From Account 
            Where Name = 'Dev Church of the Sandbox' limit 1];
        
        if(accts.size() <= 0)
        {
            accts.add(new Account(Name='Dev Church of the Sandbox',Type = '%Church%',
                RecordTypeId=[Select Id, Name From RecordType Where SObjectType='Account' And Name like '%Organization%' Limit 1].Id));
            upsert accts;
        }
        
        return accts[0];
    }
    
     public static testMethod Opportunity getMAOpportunity()
    {
        RecordType recTest = [Select Id From RecordType where Name='Ministry Advancement'];
        RecordType recTest1 = [Select Id From RecordType where Name='Orders'];
        Opportunity o = new Opportunity (
            StageName='Order Open', 
            Name='O-TEST-0', 
            CloseDate=System.Today(),
            RecordTypeId= rectest.Id, 
            AccountId=getTestChurchAccount().Id
        );
         Opportunity o1 = new Opportunity (
            StageName='Order Open', 
            Name='O-TEST-1', 
            CloseDate=System.Today(),
            RecordTypeId= rectest1.Id, 
            AccountId=getTestChurchAccount().Id
        );
        insert o;
        insert o1;
        system.debug('Opportunity has not been inserted. Set the PriceBook2Id and AccountId for this opportunity before insert.');
        
        return o;
    }
}