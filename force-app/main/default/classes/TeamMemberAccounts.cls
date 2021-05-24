/**************************************************************************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            CRM Rewrite
    Original:           9/29/2016 - <SFDC-209> When a dropped church has been set to Pending from Sales team, after the account becomes added verify the State Director is the Account Owner and the 
                                       ... only record for the new Account Team, object.
    Update:             02/03/2018 - <CRM REWRITE> - removed @Future statement from method accountHealthAccessHandler because it caused asynchronous error.
    Update:             02/26/2018 - <ASP_914>  -  Updated TeamMemberAccount Handler method name to Handler1
    Update              03/24/2018 - <ASP-1039> - Optimized to avoid SOQL Governor Limits and handled County typos using try/catch
	Updated:      		04/04/2018 - <ASP-1048> - Bug Fix: Mixed DML Exception issue.
    Update:				08-09-2018 - <ASP-1288> - Adding GO Club Outreach Specialist to Account Team.

	Called By: AccountAfterUpdate Trigger
    Tested By: TestTeamMemberAccounts Class
 ********************************************************************************************************************************************************************************/ 
public with sharing class TeamMemberAccounts { 
    /* 
     * Method:  handleOpportunityInsert
     * Inputs:  List of Accounts which have ownership updates to be matched with their ATMs (Account Team Member)
     * Purpose: To verify that we will have a State Director whether due to updating the ATM or creating a new one.
     * SOQL:    1
     * DML:     2
     */
  public class handlerException extends Exception{} 
/***************************************************************************************************************************************************
   Method: handler: Makes sure that Primary Missionaries are assigned as Account Team Memebrs programmatically
****************************************************************************************************************************************************/
    public static void handler(List<Account> Accts,List<ID> acctIDS){
        List<AccountTeamMember> insert_ATM_FieldDirs = new List<AccountTeamMember>();
        List<AccountTeamMember> insert_ATM_WGroupLdrs = new List<AccountTeamMember>(); 
        List<AccountTeamMember> insert_ATM_PMissions = new List<AccountTeamMember>();  
        List<AccountTeamMember> insert_GO_Specialist = new List<AccountTeamMember>(); 
        List<Id> ownerIDs = new List<Id>();
        Boolean foundStateDir = false;
        // Old ATM Roles must go because we don't know how if these users are still available.
       List<AccountTeamMember> delete_ATMS = [Select AccountID,UserId,TeamMemberRole from AccountTeamMember  WHERE TeamMemberRole in ('Field Director','Work Group Leader','Primary Missionary','GO Club Outreach Specialist')  and AccountId in : acctIDs];
       if(delete_ATMS.size() > 0){ 
            delete delete_ATMS;
        }
        
        system.debug('<<NUMBER OF QUERIES In TOTAL : '+Limits.getLimitQueries());
        
        //For each account selected go and get the Account Team Mebmers while  updating the account owner.
       List<US_Counties__c> uscs = [Select Name,State_Name__c,Field_Director__c, Work_Group_Leader__c, Primary_Missionary__c,GO_Club_Outreach_Specialist__c from US_Counties__c  ORDER BY State_Name__c, Name Asc];

        Map<String,List<US_Counties__c>> usCounties = new Map<String,List<US_Counties__c>>();

        for(US_Counties__c usc : uscs){
            if(!usCounties.containsKey(usc.Name)){
                usCounties.put(usc.Name,new List<US_Counties__c>());
            }
            usCounties.get(usc.Name).add(usc);
        }

        for(Account a: Accts){
            if(usCounties.containsKey(a.Physical_County__c)){
                for(US_Counties__c a_county : usCounties.get(a.Physical_County__c)){
                    if(a_county.State_Name__c == a.Physical_State__c){
                        insert_ATM_FieldDirs.add(new AccountTeamMember(UserId=a_county.Field_Director__c, AccountId=a.Id,TeamMemberRole='Field Director')); 
                        insert_ATM_WGroupLdrs.add(new AccountTeamMember(UserId=a_county.Work_Group_Leader__c, AccountId=a.Id,TeamMemberRole='Work Group Leader'));
                        insert_ATM_PMissions.add(new AccountTeamMember(UserId=a_county.Primary_Missionary__c, AccountId=a.Id,TeamMemberRole='Primary Missionary'));
                        insert_GO_Specialist.add(new AccountTeamMember(UserId=a_county.GO_Club_Outreach_Specialist__c, AccountId=a.Id,TeamMemberRole='GO Club Outreach Specialist'));
                        ownerIDS.add(a_county.Primary_Missionary__c);
                        break;
                    }
                }
            }
        }
    //6. - Insert All ATMs
   system.debug('<<NUMBER OF QUERIES Used : '+Limits.getQueries());
    if(insert_ATM_FieldDirs.size() > 0){ 
        Database.UpsertResult[] lsr = Database.upsert(insert_ATM_FieldDirs,false);
    }
    if(insert_ATM_WGroupLdrs.size() > 0){ 
        Database.SaveResult[] lsr = Database.insert(insert_ATM_WGroupLdrs,false);
    }
    
     if(insert_ATM_PMissions.size() > 0){ 
        Database.SaveResult[] lsr = Database.insert(insert_ATM_PMissions,false);
    }
        
     if(insert_GO_Specialist.size() > 0){ 
        Database.SaveResult[] lsr = Database.insert(insert_GO_Specialist,false);
    }
    
    system.debug('ATMS FOR INSERTED State Dirs: '+insert_ATM_FieldDirs);
    system.debug('ATMS FOR INSERTED Work Group Leaders: '+insert_ATM_WGroupLdrs);
    system.debug('ATMS FOR INSERTED Primary Missionaries: '+insert_ATM_PMissions);
    system.debug('ATMS FOR INSERTED GO Club Outreach Specialist: '+insert_GO_Specialist);   
    }//Handler 1
   
/***************************************************************************************************************************************************
   Method: handler: VP for US Missionaries handler: Simply adds an ATM team role for VPs
****************************************************************************************************************************************************/
    public static void handler(List<Account> newAccts){
        system.debug('<<INSIDE VP Of US Missionaries Handler >> '+newAccts);
        List<AccountTeamMember> insert_ATM_VPs = new List<AccountTeamMember>();
        List<GroupMember> vpUser = [Select UserOrGroupId From GroupMember where Group.Name = 'VP of Account Team' limit 1];
        for(Account someAccount : newAccts){
            insert_ATM_VPs.add(new AccountTeamMember(UserId=vpUser[0].UserOrGroupId, AccountId=someAccount.Id,TeamMemberRole='VP of US Missionaries'));   
        }
        User usr = [Select Id From User where Id =: UserInfo.getUserId()];
        	if(insert_ATM_VPs.size() > 0){ 
            	Database.SaveResult[] lsr = Database.insert(insert_ATM_VPs,false);
     
    	}
    }// Handler 2
  
}//Class