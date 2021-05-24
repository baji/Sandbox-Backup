/********************************************************************************************************
 Updated:      7/11/2017 - Added SeeAllData=true.
 Updated:      26/12/2017 - Mayur Soni -Added testContactAffWithAttch to test with attachment
 *****************************************************************************************************************/

@isTest(seeAllData=true)
public class TestContactAfterInsert {
 // Create and Account 
   
    public static testmethod void  testContacts(){
        Account a = new Account(Name='TestContactAfterInsert');
       // insert a;
        
        //Contact c = new Contact(FirstName = 'Elena',LastName = 'Trump',Email='ilTrumpa@mailinator.com',LeadSource = 'Advertisement');
        //insert c;
        
        Contact c = [select Id,LastName,FirstName,Email,LeadSource from Contact where LastName !=: '' Limit 1];
        npe5__Affiliation__c aff = new npe5__Affiliation__c(npe5__Organization__c=a.Id, npe5__Contact__c=c.Id );
        //insert aff;
    }
    
    public static testMethod void testContactAffWithAttch(){
        Account acc = TestObjects.FullAccount();
        insert acc;
        /*
        Contact c = new Contact(FirstName = 'Elena',
                                        LastName = 'Trump',
                                        Email='ilTrumpa@mailinator.com',
                                        LeadSource = 'Advertisement',AccountId=acc.Id);
        
        */
        
        Test.startTest();
        //insert c;
        Contact c = [select Id,LastName,FirstName,Email,LeadSource from Contact where LastName !=: '' Limit 1];
        
        npe5__Affiliation__c aff = new npe5__Affiliation__c(npe5__Organization__c=acc.Id, npe5__Contact__c=c.Id );
        insert aff;
        
        Attachment att = new Attachment();
        att.name = 'test attachment';
        att.body = Blob.valueOf('Test attachment body');
        att.ParentId = c.id;
        insert att;
        //System.debug('===Affiliations=== '+[SELECT Id,Name,npe5__Organization__c,npe5__Contact__c FROM npe5__Affiliation__c]);
        
        Test.stopTest();
        //Account accRec = [SELECT Id,name,Lead_Source__c FROM Account where Id=:acc.Id];
        //Contact con = [SELECT Id,Name,LeadSource FROM Contact WHERE Id=:c.Id];
        //List<Attachment> affAttachments = [SELECT Id,Name FROM Attachment WHERE Parentid=:acc.Id];
        //System.assert(accRec.Lead_Source__c == c.LeadSource);
        //System.assert(!affAttachments.isEmpty());
               
    }
}