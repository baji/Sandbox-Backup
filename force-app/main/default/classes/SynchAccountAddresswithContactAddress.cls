/***************************************************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    SynchAccountAddresswithContactAddress
    Original:   11/24/2014  - Synchronizes (Updates) a  1x1 Account's Mailing and Physical Addresse with those of its Contact's Mailing and Other address.
    Update:		1/6/2015	- Added check tp make sure ApexApplication emails don't get sent  due to updates done on accounts with null countries.
   	Update:		1/26/2015 - Added new Null Country Field handling for contact's Physical and/or Mailing Country field. This stops ApexApplication exceptions from being emailed to an Admin inbox.
    Called By:  ContactAfterUpdate
  **************************************************************************************************************************************************************************/

public class SynchAccountAddresswithContactAddress {
	 
    public class SynchAccountAddressException extends Exception{} 
    /**********************************************************************************************************************
     * Method:  handler
     * Inputs:  List<Contact> updatedContacts - The list of contacts
     *			List<Account> accountsToUpdate - List of 1x1 Addresses which correspond to the accounts
     *          
     * Output:  None.
     * Purpose: Createsa 1-1 account from the contact and updates the affiliation fields: Authorized Purchaser and Status.
     * SOQL:    0
     * DML:     1
    **************************************************************************************************************************/
    // Need to wait until after the Lead has been converted to an affiliation and the contact has been inserted
    public static void handler(List<Contact> updatedContacts,List<Account> accountsToUpdate ){
    	//1-26-2015 need to clone and update the contact if there is a 
    	 for(Account a : accountsToUpdate ){
    		for(Contact c : updatedContacts){
    			if(a.npe01__One2OneContact__c == c.Id){
    				a.Mailing_Street_1__c = c.MailingStreet;
    				a.Mailing_City__c = c.MailingCity;
    				a.Mailing_State_Province__c = c.MailingState;
    				a.Mailing_Country__c = c.MailingCountry;
    				
    				// TW: 1-06-2015 Code to handle issues with null country. If eiither is null ten assign it the other's valoue else ...
					//...default both of them to 'UNITED 'STATES'
    				if( c.MailingCountry != null){
    					a.Mailing_Country__c = c.MailingCountry;
    				}
    				else{
    					a.Mailing_Country__c = 'UNITED STATES';
    				}
    				//END
    				
    				a.Mailing_Zip_Postal_Code__c = c.MailingPostalCode;
    				a.Physical_Street_1__c = c.OtherStreet;
    				a.Physical_City__c = c.OtherCity;
    				a.Physical_State__c = c.OtherState;
    				    				
    				// TW: 1-06-2015 Code to handle issues with null country. If eiither is null ten assign it the other's valoue else ...
					//...default both of them to 'UNITED 'STATES'
    				if(c.OtherCountry != null){
    					a.PhysicalCountry__c = c.OtherCountry;
    				}
    				else{
    					a.PhysicalCountry__c = 'UNITED STATES';
    						
    				}
    				//END
    				
    				a.Physical_Zip__c = c.OtherPostalCode;
    				system.debug('CONTACT :'+c+' Account: '+a);		 
    				
    			}//IF 
    		}// For - Contacts
    		
    		
    	}//For - Accounts
    	
    	try{
    			
			system.debug('<<ACCTS>> '+accountsToUpdate);
				if(accountsToUpdate.size() > 0){				
    				update accountsToUpdate;
				}
    			
    		}catch(SynchAccountAddressException SAAEx){
    			system.debug('Fatal error when synching  account addresses');
    		}
    		
    	
    }
    
}