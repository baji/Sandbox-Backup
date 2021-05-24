/******************************************************************************************************************
*   Programmer: Tony Williams
*   Company:    Awana
*   Contact:    tonyw@awana.org
*   Project:    For General Contact Updates. Different tasks will be dispatched based on functionality.
*   Original:   11/25/2014 - Initial purpose for trigger is to check Sunchroniztion between Contact addresses and its 1X1 Account 
*                           
*******************************************************************************************************************/

trigger ContactAfterUpdate on Contact (after update) {
   Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunContactTrigger');   
    
   if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){ 
        List<Contact> storedContacts = new List<Contact>(); 
        List<Id> storedContactIds =  new List<Id>();
        Integer contactlimit = Trigger.new.size();
        for(Integer i =0; i < contactlimit; i++){
                system.debug('triggerfirsstrecird++'+Trigger.old[i]);
                system.debug('triggerdnkey++'+Trigger.old[i].npe01__SystemAccountProcessor__c);
                //if(Trigger.old[i].npe01__SystemAccountProcessor__c == 'One-to-One'){ //Make sure this is only for One-to-One contacts
                    if(Trigger.new[i].MailingStreet != Trigger.old[i].MailingStreet ||
                        Trigger.new[i].MailingCity != Trigger.old[i].MailingCity ||
                        Trigger.new[i].MailingState != Trigger.old[i].MailingState ||
                        Trigger.new[i].MailingCountry != Trigger.old[i].MailingCountry ||
                        Trigger.new[i].MailingPostalCode != Trigger.old[i].MailingPostalCode ||
                        Trigger.new[i].OtherStreet != Trigger.old[i].OtherStreet ||
                        Trigger.new[i].OtherCity != Trigger.old[i].OtherCity ||
                        Trigger.new[i].OtherState != Trigger.old[i].OtherState ||
                        Trigger.new[i].OtherCountry != Trigger.old[i].OtherCountry ||
                        Trigger.new[i].OtherPostalCode != Trigger.old[i].OtherPostalCode
                        ){
                        storedContacts.add(Trigger.new[i]);
                        storedContactIds.add(Trigger.old[i].Id); // Used to get the 1x1 accounts for these contact Ids.
                        system.debug('<<CONTACT ID: >> '+storedContactIds);
                    }//IF
                //}//IF
            //<.. Else Do something else with these non-1X1 contacts...>>
        }//FOR
    
        // <<Address Synchronization>> Get all Individual Accounts that match the updated 1-1 contacts
        List<Account> accountsList = [Select Id, Mailing_Street_1__c,npe01__One2OneContact__c, 
            Mailing_City__c, Mailing_State_Province__c, Mailing_Country__c, Mailing_Zip_Postal_Code__c,
            Physical_Street_1__c, Physical_City__c, Physical_State__c, PhysicalCountry__c, Physical_Zip__c
            FROM Account Where RecordType.Name = 'Individual' and npe01__One2OneContact__c in:storedContactIds];
    
        if(accountsList.size() > 0){
            SynchAccountAddresswithContactAddress.handler(storedContacts,accountsList);   
        }
    }
    
}