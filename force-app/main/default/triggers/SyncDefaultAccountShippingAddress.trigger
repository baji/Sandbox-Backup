/*****************************************
    Programmer: Matthew Keefe
    Company:    Awana
    Contact:    mattk@awana.org
    Project:    Order Entry in Salesforce
    Updated:    5/18/2010
    Updated:    7/2/2010 - changed comparison on update to match case (using string.equals())
    Updated:    6/7/2012 - Added Shippinig First Name and Shipping Last Name checks.
    Updated:    9-7-12 Removed the else conditions from Shipping Lastname
 *****************************************/

trigger SyncDefaultAccountShippingAddress on Account (before update, before insert, after insert) 
{
Awana_Settings__c custmSetting =  Awana_Settings__c.getValues('RunAccountTrigger');       

    if (custmSetting != null && Boolean.valueOf(custmSetting.value__c)){
        List<Account> oldAccounts = Trigger.old;
        List<Account> allAccounts = Trigger.new;
        List<Account> allAccountsWithShippingAddressChanges = new List<Account>();
         
        List<Address__c> addressesToUpdate = new List<Address__c>();
    
        for(Integer i=0; i<allAccounts.size(); i++) 
        {
            Boolean changes = false;
            
            // get the current account
            Account currentAccount = allAccounts[i];
            
            if(Trigger.isUpdate)
            {
                // get the account before changes were made
                Account oldAccount = oldAccounts[i]; 
                //TW: 6/7/2012  - Check if the shipping first name has chqanged
                
                if(oldAccount.Shipping_First_Name__c != currentAccount.Shipping_First_Name__c) 
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.Shipping_First_Name__c != null) {
                        if(!oldAccount.Shipping_First_Name__c.equals(currentAccount.Shipping_First_Name__c)) { changes = true; } }
                    
                    if(currentAccount.Shipping_First_Name__c != null) {
                        if(!currentAccount.Shipping_First_Name__c.equals(oldAccount.Shipping_First_Name__c)) { changes = true; } }
                    
                }
                //TW: 6/7/2012  - Check if the shipping last name has chqanged
                if(oldAccount.Shipping_Last_Name__c != currentAccount.Shipping_Last_Name__c) 
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.Shipping_Last_Name__c != null) {
                        if(!oldAccount.Shipping_Last_Name__c.equals(currentAccount.Shipping_Last_Name__c)) { changes = true; } }
                   
                    if(currentAccount.Shipping_Last_Name__c != null) {
                        if(!currentAccount.Shipping_Last_Name__c.equals(oldAccount.Shipping_Last_Name__c)) { changes = true; } }
                    
                }
                
                // check if the address has changed
                if(oldAccount.ShippingStreet != currentAccount.ShippingStreet) 
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.ShippingStreet != null) {
                        if(!oldAccount.ShippingStreet.equals(currentAccount.ShippingStreet)) { changes = true; } }
                    if(currentAccount.ShippingStreet != null) {
                        if(!currentAccount.ShippingStreet.equals(oldAccount.ShippingStreet)) { changes = true; } }
                }
                if(oldAccount.ShippingCity != currentAccount.ShippingCity)
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.ShippingCity != null) {
                        if(!oldAccount.ShippingCity.equals(currentAccount.ShippingCity)) { changes = true; } }              
                    if(currentAccount.ShippingCity != null) {
                        if(!currentAccount.ShippingCity.equals(oldAccount.ShippingCity)) { changes = true; } }
                }
                if(oldAccount.ShippingPostalCode != currentAccount.ShippingPostalCode)
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.ShippingPostalCode != null) {
                        if(!oldAccount.ShippingPostalCode.equals(currentAccount.ShippingPostalCode)) { changes = true; } }              
                    if(currentAccount.ShippingPostalCode != null) {
                        if(!currentAccount.ShippingPostalCode.equals(oldAccount.ShippingPostalCode)) { changes = true; } }
                }
                if(oldAccount.ShippingState != currentAccount.ShippingState)
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.ShippingState != null) {
                        if(!oldAccount.ShippingState.equals(currentAccount.ShippingState)) { changes = true; } }                
                    if(currentAccount.ShippingState != null) {
                        if(!currentAccount.ShippingState.equals(oldAccount.ShippingState)) { changes = true; } }
                }
                if(oldAccount.ShippingCountry != currentAccount.ShippingCountry)
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.ShippingCountry != null) {
                        if(!oldAccount.ShippingCountry.equals(currentAccount.ShippingCountry)) { changes = true; } }                
                    if(currentAccount.ShippingCountry != null) {
                        if(!currentAccount.ShippingCountry.equals(oldAccount.ShippingCountry)) { changes = true; } }
                }
                if(oldAccount.Shipping_County__c != currentAccount.Shipping_County__c)
                { 
                    changes = true; 
                }
                else
                {
                    if(oldAccount.Shipping_County__c != null) {
                        if(!oldAccount.Shipping_County__c.equals(currentAccount.Shipping_County__c)) { changes = true; } }              
                    if(currentAccount.Shipping_County__c != null) {
                        if(!currentAccount.Shipping_County__c.equals(oldAccount.Shipping_County__c)) { changes = true; } }
                }
            }
            else
            {
                // if the trigger is an insert (only options are insert and update, so must be insert if not update)
                // there are changes to the shipping address if the shipping address is not null
               //TW: 6/7/2012  - Check if the shipping last name has chqanged
                if(currentAccount.ShippingStreet != null) { changes = true; }
                if(currentAccount.ShippingCity != null) { changes = true; }
                if(currentAccount.ShippingPostalCode != null) { changes = true; }
                if(currentAccount.ShippingState != null) { changes = true; }
                if(currentAccount.ShippingCountry != null) { changes = true; }
                if(currentAccount.Shipping_County__c != null) { changes = true; }  
                if(currentAccount.Shipping_First_Name__c != null) {changes = true;}
                if(currentAccount.Shipping_Last_Name__c != null) {changes = true;}
            }
            
            if(changes == true) { allAccountsWithShippingAddressChanges.add(currentAccount); }
        }
        
        // if there are no accounts with Shipping Address changes, just end the trigger and return
        if(allAccountsWithShippingAddressChanges.size() == 0) { return; }
        
        // for all of the accounts with changes, get the currentAccount
        for(Account currentAccount : allAccountsWithShippingAddressChanges)
        {
            Address__c currentAddress; // placeholder account
            
            // check to see if there is a default address record
            // if no address is marked as the default
            if(currentAccount.Default_Shipping_Address__c == null)
            {
                currentAddress = new Address__c(); // make a new address
            }
            // otherwise, copy the information to the address 
            // (especially the Id so the upsert does not insert a new address)
            //TW: 6/7/2012  - Check if the shipping last name has chqanged
            else
            {
                currentAddress = new Address__c(
                    Id = currentAccount.Default_Shipping_Address__c,
                    First_Name__c = currentAccount.Default_Shipping_Address__r.First_Name__c,
                    Last_Name__c = currentAccount.Default_Shipping_Address__r.Last_Name__c,
                    Account__c = currentAccount.Default_Shipping_Address__r.Account__c,
                    Address_Line_1__c = currentAccount.Default_Shipping_Address__r.Address_Line_1__c,
                    Address_Line_2__c = currentAccount.Default_Shipping_Address__r.Address_Line_2__c,
                    City__c = currentAccount.Default_Shipping_Address__r.City__c,
                    State__c = currentAccount.Default_Shipping_Address__r.State__c,
                    Zip_Code__c = currentAccount.Default_Shipping_Address__r.Zip_Code__c,
                    County__c = currentAccount.Default_Shipping_Address__r.County__c,
                    Country__c = currentAccount.Default_Shipping_Address__r.Country__c
                );
            }
             
            // the currentAddress should never be null, but just in case
            if(currentAddress != null)
            {
                // if the shipping street is not null, split it properly into two fields based on the newline character
                if(currentAccount.ShippingStreet != null) 
                {
                    String[] currentShippingStreet = currentAccount.ShippingStreet.split('\n');
                    if(currentShippingStreet.size() > 0) {
                        currentAddress.Address_Line_1__c = currentShippingStreet[0];
                        currentAddress.Address_Line_2__c = null; }
                    if(currentShippingStreet.size() > 1) {
                        currentAddress.Address_Line_1__c = currentShippingStreet[0];
                        currentAddress.Address_Line_2__c = currentShippingStreet[1]; }
                }
                // otherwise, it was null; make sure the address is updated accordingly 
                else
                {
                    currentAddress.Address_Line_1__c = null;
                    currentAddress.Address_Line_2__c = null;
                }
                         
                // copy fields to the address from the account shipping address
                //TW: 09-07-12: Added new fields First Name and Last Name .
                currentAddress.Account__c = currentAccount.Id;
                currentAddress.First_Name__c = currentAccount.Shipping_First_Name__c;
                currentAddress.Last_Name__c = currentAccount.Shipping_Last_Name__c;
                currentAddress.City__c = currentAccount.ShippingCity;
                currentAddress.State__c = currentAccount.ShippingState;
                currentAddress.Zip_Code__c = currentAccount.ShippingPostalCode;
                currentAddress.County__c = currentAccount.Shipping_County__c;
                currentAddress.Country__c = currentAccount.ShippingCountry;
                
                // set the default checkbox on the address
                currentAddress.Default_Shipping_Address__c = true;
                
                // que the currentAddress for insert or update 
                // (remember this address to process after all accounts have been looped through)
                addressesToUpdate.add(currentAddress);
            }
        }
        
        // to cut down on the number of DML calls (insert/update) process all addresses at once
        // update the list of addresses
        try
        {
            upsert addressesToUpdate;
        }
        catch(Exception exc)
        {
            for(Address__c a : addressesToUpdate)
            {
                a.addError('The address you have entered is not valid. Please check the country you have entered against the ISO Names listed at: http://www.iso.org/iso/english_country_names_and_code_elements.');
            }
        }
        
        // if the trigger is occurring before insert set the default address
        // this cannot be done after insert
        if(Trigger.isBefore) 
        {
            // cleanup and set all the default addresses
            for(Address__c address : addressesToUpdate)
            {
                // for all of the accounts with changes, get the currentAccount (yes again, required for cleanup)
                for(Account currentAccount : allAccountsWithShippingAddressChanges)
                {
                    if(address.Account__c == currentAccount.Id)
                    {   // set the default address
                        currentAccount.Default_Shipping_Address__c = address.Id;
                    }
                }
            }
        }
    }
}