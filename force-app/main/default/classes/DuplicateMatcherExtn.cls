/*****************************************************************************************************************************************************************************************
*   Programmer: Vikas Y
*   Company:    Infoglen
*   Contact:    vikas@Infoglen.com
*   Project:    CRM Rewrite
*   Original:   11/28/2017 - Initial purpose for Class is to check Duplicate Accounts and Contacts based on Lead Company and Email.
*   Test:       DuplicateMatcherExtn_Test.cls
*   
**************************************************************************************************************************************************************************************************************/
public with sharing class DuplicateMatcherExtn {

    public List<Account> dupAccounts {get; set;}
    public List<Contact> dupContacts {get; set;}

    public DuplicateMatcherExtn(ApexPages.StandardController controller) {
        //controller.addFields(new List<String>{'FirstName', 'LastName', 'Name', 'Email', 'Company', 'Street', 'City', 'State', 'PostalCode', 'Country'});        
        dupAccounts = new List<Account>();
        dupContacts = new List<Contact>();        
        Set<id> accIds = new Set<id>();
        Set<id> conIds = new Set<id>();
        
        Lead ld = [SELECT id, FirstName, LastName, Name, Email, Company, Street, City, State, PostalCode, Country FROM Lead WHERE Id= :controller.getId()];
        
        if(String.IsNotBlank(ld.Company)){
            for(List<sObject> accList : [FIND :ld.Company IN NAME FIELDS RETURNING Account(id, Name LIMIT 10)]){
                for(Account acc: (List<Account>)accList){
                   accIds.add(acc.id);
                }                
            }
            dupAccounts = [SELECT id, Name, Mailing_Address_Book__c, Physical_City__c, Physical_State__c, Registration_Level__c FROM Account WHERE id IN: accIds];
        }      
        
        if(String.IsNotBlank(ld.Email)){
            for(List<sObject> conList : [FIND :ld.Email IN EMAIL FIELDS RETURNING Contact(id, Email LIMIT 10)]){
                for(Contact con: (List<Contact>)conList){
                   conIds.add(con.id);
                }
            }
            dupContacts = [SELECT id, Name, Email, Phone, AccountId, MailingCity, MailingState FROM Contact WHERE id IN: conIds];            
        }
    }
}