/***************************************************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    InsertOne2OneAccountMgr
    Project:    Salesforce
    Original:   05/16/2014  - Creates a 1-1 account from contact once a Convert button has been clicked on a Lead record.
    Updated:    09/17/2014 - Added Church Role of 'Church Staff Member' to the new Affiliation.
    Updated:    11/06/2014 - Updated code to assure that the Account gets an attachment as well as the Contact. Somehow during the last update the Contact got both attachments 
    Updated:    09/27/2017 - <ASP-421> When a lead has been converted store the Lead's Inquiry Source to the Account's Lead_SOurce__c field.
    Called By:  ContactAfterInsert
  **************************************************************************************************************************************************************************/
public class  InsertOne2OneAccountMgr { 
    public class InsertOne2OneAccountException extends Exception{} 
    /**********************************************************************************************************************
     * Method:  handleCreateContacts
     * Inputs:  List<Contact> newContacts - The list of contacts which will be used to create new 1-1 contacts and affiliations.
     *          
     * Output:  None.
     * Purpose: Createsa 1-1 account from the contact and updates the affiliation fields: Authorized Purchaser and Status.
     * SOQL:    0
     * DML:     2
    **************************************************************************************************************************/
    @future (callout=true) // Need to wait until after the Lead has been converted to an affiliation and the contact has been inserted
    public static void handler(List<String> newContactIds ){
        //1. Create blank accounts and tie each contact to an acocunt thus making this a One-to-One account
        List<Contact> newContacts = [Select Id,AccountId, FirstName, LastName,LeadSource from Contact where Id in: newContactIds];
        Map<Id,String> newAccounts = new Map<Id,String>();
        RecordType individualRT = [Select Id from RecordType where Name = 'Individual' limit 1];
        List<Account> accounts = new List<Account>();
        for(List<Contact> contacts : [Select Id,AccountId, FirstName, LastName,LeadSource from Contact where Id in: newContactIds]){
            for(Contact cs : contacts){
                //Set up Account to store Lead Source from contact
                newAccounts.put(cs.AccountId,cs.LeadSource);
               
                //Set the contact to a 1x1 account
                cs.AccountId =null;
                cs.npe01__SystemAccountProcessor__c='One-to-One';
                //cs.npe01__SYSTEMIsIndividual__c=true;
                cs.OtherCountry = 'UNITED STATES'; 
                system.debug('Contacts: '+ cs);
                system.debug('<<Contacts Lead Source: >>'+ cs.LeadSource);
            }
             // Controlling heap size for contact list
            Database.update(newContacts);
        }
        //Store Contact Lead Source values into Account Lead Source field.
        for(List<Account> getLeadsources :  [Select Id,Lead_Source__c from Account where Id in: (newAccounts.keySet())]){
            for(Account anAccount : getLeadSources){
                anAccount.Lead_Source__c = newAccounts.get(anAccount.Id);
                accounts.add(anAccount);
            }
            // Controlling heap size for account list
            Database.update(accounts);
        }
        
        List<Attachment> attachments = [Select ParentId,Body,Name from Attachment where ParentId in: newContacts];
        system.debug('ATTACHMENTS: '+attachments);
       
        //2. Now get the affiliation linked to this new contact and change it's status from 'Former' to 'Current' and make contact the Authorized Purchaser for now.
        List<npe5__Affiliation__c> contactAffs = [Select npe5__Contact__c,npe5__Organization__c,npe5__Status__c, Authorized_Purchaser__c from npe5__Affiliation__c  where npe5__Contact__c in: newContactIds];
        if(contactAffs.size() > 0 ){
            for(npe5__Affiliation__c aff : contactaffs){
                aff.npe5__Status__c = 'Current';
                aff.Authorized_Purchaser__c = true;
                aff.Church_Role__c = 'Church Staff Member'; // 9-17-2014: Add Church Staff Mmeber as new Affiliation Church Role.
            }
            
            update contactAffs;
            
            //3.  Now attach the Inquiry attachments to the Affiliation from the Contacts   
            List<Attachment>addAttachments = new List<Attachment>();
            for(npe5__Affiliation__c aff : contactAffs ){
                for(Attachment att : attachments ){
                    if(aff.npe5__Contact__c == att.ParentId){
                        system.debug('CONTACT: '+aff.npe5__Contact__c);
                        //addAttachments.add(new Attachment(ParentId=aff.npe5__Contact__c,Body=att.Body,Name=att.Name));
                        addAttachments.add(new Attachment(ParentId=aff.npe5__Organization__c,Body=att.Body,Name=att.Name));
                        system.debug('ATTACHMENTS - PRESAVED: '+addAttachments);
                    }
                }
            }
            if(addAttachments.size() > 0){
                upsert addAttachments;
                system.debug('ATTACHMENTS -SAVED: '+addAttachments);
            }
        }// contactaffs > 0
     
  }// handler
  
 

}//class