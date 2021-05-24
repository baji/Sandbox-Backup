/**********************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            CRM Rewrite
    Original:           02/03/2018   - Adds new Primary Misisonary to a new account.
	Called By: AccountBeforeUpdate Trigger
 *********************************************************************************************************************/ 

public with sharing class AddNewAccountOwner {
	public static void helper(List<Account> updateNewAccountOwners){
        for(Account anAccount : updateNewAccountOwners){
            system.debug('<<STATE>> '+anAccount.Physical_State__c+' <<COUNTY>> '+anAccount.Physical_County__c);
            for(US_Counties__c uscs : [Select Primary_Missionary__c from US_Counties__c WHERE  State_Name__c =: anAccount.Physical_State__c and Name =: anAccount.Physical_County__c]){
                system.debug('<<MISSIONARY>> '+uscs.Primary_Missionary__c+' <<OLD MISSIONARY >> '+anAccount.Owner.Id);
                anAccount.OwnerId = uscs.Primary_Missionary__c;
        	} 
       }
      
    }
    
}