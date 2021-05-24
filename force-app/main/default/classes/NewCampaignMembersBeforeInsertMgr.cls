/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Salesforce
    Description:All-purpose class used for Opportunities fired Before Insert.
    Original:   12/07/2012  - Class will update the  Campaign Members Account ID field if null using the Member's Contact Account ID field.                          
    Updated:    09/15/2015 - Updated the test cases to test campaigns more thoroughly.
    Updated:	07/26/2016 - (Baji) Updated to include GO Territory Physical Address
    Updated:	08/29/2016 - OPtimized the code to avoid SOQL governor limits when massive campaign contact files are loaded.
  ***********************************************************************************************************************************************/
public class NewCampaignMembersBeforeInsertMgr {
    public class NewCampaignMembersBeforeInsertException extends Exception{}  
    public static void handleNewCampaignMembersBeforeInsert(List<CampaignMember> newCampMs){
        Map<Id,Id> ContactMap = new Map<Id,Id>();
        //For each member, grab their respective Contact Ids so that we can get the Account IDs for them.
        system.debug('HERE IS NEW MEMBER LIST: '+newCampMs);
        for(CampaignMember cm : newCampMs){ 
            ContactMap.put(cm.ContactId,cm.ContactId);
            system.debug('CONTACTID: '+cm.ContactId);
        }
        
        /*
        List<Contact> contacts = [Select AccountId, Account.GO_Territory__c,
        Account.Mailing_Address_Book__c,
        Account.Physical_City__c,
        Account.Physical_State__c,from Contact where Id in: ContactMap.keySet()];
        */
        //For each Campaign Member who has a null AccountID, populate their Acocunt ID with the Contact Object's  Account ID
       // if(contacts.size() > 0){
            for(CampaignMember cm : newCampMs){
                if(cm.AccountID__c == null){
                    //if(contacts.size() > 0){ <<< THe statement below should only count as 1 SOQL query against governor limits. >>>
                        for(Contact cs : [Select AccountId, Account.GO_Territory__c,Account.Mailing_Address_Book__c,Account.Physical_City__c,Account.Physical_State__c from Contact where Id in: ContactMap.keySet()]){
                            if(cm.ContactId == cs.Id){
                                system.debug('WE SHOULD GET HERE: '+cs.AccountId);
                                //Baji: Update to add Account GO Territory,Physical State,CustomerID to Newly addded CampaignMember.
                               // Account a = [select GO_Territory__c,Mailing_Address_Book__c,Physical_City__c,Physical_State__c From Account where Id=:cs.AccountId];
                                cm.AccountID__c = cs.AccountId;
                                cm.Account_CustomerID__c = cs.Account.Mailing_Address_Book__c;
                                cm.AccountGOTerritory__c = cs.Account.GO_Territory__c;
                                cm.AccountPhysicalCity__c = cs.Account.Physical_City__c;
                                cm.AccountPhysicalState__c = cs.Account.Physical_State__c;
                            }
                        }
                    //}
                }
            }
        //}
    }
    public static testMethod void NewCampaignMembersBeforeInsertManager(){
    // Create an Account
    Test.startTest();
            List<RecordType> rec = [Select Id from RecordType Where SobjectType = 'Account' and Name = 'US Organization'];
           String RecordTypeId = rec[0].id;
            Account a1 = new Account(
                Name='Batch Registration Object Update Test', 
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                RecordTypeId =RecordTypeId, 
                Status__c='Added',
                Description = 'ECLIPSE TEST'
                //Geolocation__Latitude__s = 1.0,
                //Geolocation__Longitude__s= 1.0
            ); 
             insert a1;
            
            Account a2 = new Account(
                Name='Batch Registration Object Update Test', 
                BillingStreet='1600 Amphitheatre Parkway', 
                BillingCity='Mountain View',
                BillingState='CA',
                BillingPostalCode='94043',
                BillingCountry='UNITED STATES',
                Mailing_Street_1__c='The Landmark @ One Market',
                Mailing_Street_2__c='Suite 300',
                Mailing_City__c='San Francisco',
                Mailing_State_Province__c='CA',
                Mailing_Zip_Postal_Code__c='94105',
                Mailing_County__c='San Francisco',
                Mailing_Country__c='UNITED STATES',
                Date_Inactive__c=Date.Today().addDays(90), 
                RecordTypeId =RecordTypeId, 
                Status__c='Added',
                Description = 'ECLIPSE TEST'
                //Geolocation__Latitude__s = 1.0,
                //Geolocation__Longitude__s= 1.0
            ); 
             insert a2;
        // Create a Contact
        
        
         Contact c1 = new Contact(AccountID=a1.id,FirstName='Tony', LastName='Williams');
         insert c1;
         
          Contact c2 = new Contact(AccountID=a2.id,FirstName='Tony', LastName='Melindez');
         insert c2;
       
         // Create a  valid Campaign 
        Campaign camp1 = new Campaign(
            Name='Just Testing',IsActive=true, Status='In Progress');
            insert camp1;
        
        //Create an Invalid Campaign
        Campaign camp2 = new Campaign(
            Name='Just Testing2',IsActive=true, Status='In Progress');
            insert camp2;   
            
        // Create a Campaign member from Conatct
        system.debug('CAMPID: '+camp1.id);
        system.debug('CAMPID: '+camp2.id);
        
        CampaignMember  campmember1 = new CampaignMember(CampaignId=camp1.id,AccountId__c=null,ContactId=c1.id);
        system.debug('CAMP Mem: '+campmember1);
        CampaignMember  campmember2 = new CampaignMember(CampaignId=camp2.id,AccountId__c=null,contactId=c1.id);      
        List<CampaignMember> testCampMS = new List<CampaignMember>();
        testCampMS.add(campmember1);
        testCampMS.add(campmember2);
        insert testCampMS;
        NewCampaignMembersBeforeInsertMgr.handleNewCampaignMembersBeforeInsert(testCampMS);
        Test.stopTest(); 
       
    }//Test
}