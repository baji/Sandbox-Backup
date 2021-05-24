/******************************************************************************************************************
*   Programmer: Tony Williams
*   Company:    Awana
*   Contact:    tonyw@awana.org
*   Project:    Update_Awana_Role_Text
*   Original:   05/03/2013 - To update the Awana Role Text field of an Affiliation based on its Awana Role Field.
*   Updated:    07/03/2014 - Contact's Awana Role field will now be updated to equal the Affiliation Awana Role Field.                        
*******************************************************************************************************************/
trigger Update_Awana_Role_Text on npe5__Affiliation__c (before insert,before update) {
    Map<Id,String> mp = new Map<Id,String>();
    List<Contact>  cs = new List<Contact>();
    List<npe5__Affiliation__c> Affroles = new List<npe5__Affiliation__c>();
    for(npe5__Affiliation__c ao : Trigger.new) {
        ao.Awana_Role_Text__c =ao.Awana_Role__c;
        mp.put(ao.npe5__Contact__c,ao.Awana_Role__c);
        system.debug('ROLE TEXT: '+ao.Awana_Role_Text__c+' MAP : '+mp );
        // Other multi-value fields can go in here
    }
    /// Get Contact from the affiliation Id
    cs = [Select Id, Awana_Role__c from Contact where Id in: mp.keySet()];
     system.debug('CONTACT: '+cs );
    // Update the contgact Awana Role with that of it's related Affiliation Awana Role field
    for(Contact c : cs){
        c.Awana_Role__c = mp.get(c.Id);
        c.Awana_Role_Text__c = c.Awana_Role__c;
        System.debug('<< ROLE:>> '+c.Awana_Role__c+' <<ROLE TEXT>> '+c.Awana_Role_Text__c);
    }
    try{
        if(cs.size() > 0){
            update cs;
        }
    }
    catch(Exception ex){
         system.debug('Something when  wrong during DML update see: '+ ex);
    }
    
}