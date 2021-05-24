/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Salesforce
    Description:All-purpose class used for Opportunities fired Before Insert.
    Original:   5/17/2016   - Class will update GO Territory and GO Specialist when the GO Territory object is updated for a Physical state. 
  ***********************************************************************************************************************************************/
public without sharing class GOTerritoryAfterUpdatetMgr { // Need to override the Go Specialist access so I can write it to then Account
    public class GOTerritoryAfterUpdatetMgrException extends Exception{}  
    public static void handler(Map<String,GO_Club_Territories__c> mapTerritories){
        RecordType rec = [Select Id From RecordType where Name='US Organization' AND SobjectType='Account'];    
        List<Account>updateAccountsList = new List<Account>();
        if(mapTerritories.size() > 0){
            List<Account> gotAccounts = new List<Account>();
            // Go through all accounts and get the territoy values from the Map.
            for(Account thisAccount : [Select Physical_State__c,GO_Territory__c from Account where Status__c = 'Added' and RecordType.Id =: rec.Id and  Physical_State__c in:mapTerritories.keySet() limit 1000]){
                GO_Club_Territories__c a_Territory = mapTerritories.get(thisAccount.Physical_State__c);
                //if(thisAccount.GO_Club_Outreach_Specialist__r.Name != 'Chris Dunrud'){ // Update all ikf the specialist is not Chris Dunrud
                    thisAccount.GO_Territory__c = a_Territory.GO_Territory__c;
                    //thisAccount.GO_Club_Outreach_Specialist__c  = a_Territory.GO_Club_Outreach_Specialist__c; this field is mentioned as not used in final sheet so commenting the line
                    //thisAccount.GO_Notes__c = thisAccount.GO_Club_Outreach_Specialist__r.Name +' is the GO Specialist.';
                    updateAccountsList.add(thisAccount);
                //}
                    //system.debug(' << ACCOUNT >> '+a_Territory.GO_Club_Outreach_Specialist__r.Name);
            }
            if(updateAccountsList.size() > 0){
                update updateAccountsList;
            }
        }
    }
}