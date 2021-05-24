/*****************************************************************************************************************************************************************************************
*   Programmer: Tony Williams
*   Company:    Awana
*   Contact:    tonyw@awana.org
*   Project:    For General Account Updates. Different tasks will be dispatched based on functionality.
*   Original:   06/30/2014 - Initial purpose for trigger is to check Team Member Manager Owner updates.
*   Test:       TestAccountAFterUpdate.cls
*   =========================================
*                If there was an Account ownership change , then update the Team Memeber Manager State Director with the Account's new OwnerID.
*   Updated:     12-01-14 Update Person Account Mailing and Physical Addresses if the account's  Billing and Shipping Address have been changed.
*   Updated:     2-25-2015 Commented out the SOQL statements and used RecordType.Name instead of RecordType.Id      
*   Updated:    8-12-2015 Added assign statement to make sure that Physical Country is not Empty. It needs a default value.             
*   Updated:    04-02-2016 Added updated for SFDC 32: When A mozo trial is cancelled by CCare or End of Trial Date is reached on the Account.
*   Updated:    5/4/2016 - <SFDC-62> - Removed the segment of code that guards against Duplicate Account History records for Mozo Registration Levels.
*   Updated:    8/20/2016 - <SFDC-165> - Added the Historical field and Contact of the Affiliation object to guard against updating any historical Affiliations or Affiliations where Contact 
*        ...EMail is Nullfor MFT(Mozo Free Trial) cancellations
*   Updated:    9/29/2016 - <SFDC-209>  When a dropped church has been set to Pending from Sales team, after the account becomes added verify the State Director is the Account Owner and the 
*                                       ... only record for the new Account Team, object.
*   Updated     11/22/2016 - <SFDC-268>  Added condtion to check for Dropped - to - Renewed Account Statuses when adding Account Onwers and STate Directors.
*   Updated     03/20/2017 - <CE-91> - Added updates for VP of US Ministries
*   Updated     10/16/2017 - <ASP-448> - Refactored code to add new Account Team Member Roles to the object. Removed manual setting or Account Owner which is now auto9matically handled by AccountBeforeUpdate
*   Updated     10/16/2017 - <ASP-448> - Removed Address Synchronization for Person Accuonts since we no longer use them.
*   Updated     12/07/2017 - <ASP-707> - Included condition to also update account team members if Phsyical County has changed. (Calls Flow: ) 
*   Updated:    02/05/2018 - <ASP-866> - Added condition to check Physical County value in order to  rebuild the Account Team.
*   Updated:    02/19/2018 - <ASP-904b> - Added condition to also check Account Owner Changes for creating Account Teams. 
*   Updated:    04/09/2018 - <NMM-18> - Substitute registration_Level__c with MOZO_Level__c and R1 with M0 for MFT (Mozo Free Trial)
*   Updated:    08/09/2018 - <ASP-1288> - Uppdated code segment to look for Reg Levl of R1  in order to load Accounts with account team members including GO Club Outreach Specilaist.
**************************************************************************************************************************************************************************************************************/
trigger AccountAfterUpdate on Account (after update) {  
    Integer acctLimit = Trigger.new.size();             //Get the size of updated accounts.
    List<Account> UpdateAccountList = new List<Account>();    // List to hold all updated TMM fields for an account
    List<Account> deleteATMList = new List<Account>();    // List to hold all updated TMM fields for an account
    List<Account> UpdateRegLevelList = new List<Account>();    // List to hold all updated TMM fields for an account
    List<ID> acctIDs = new List<ID>();
    String default_registration_reason = 'Registration History record automatically added for Membership';
    //List<Account> clonedAccounts = new List<Account>();
    Account modifiedAccount;
    Account clonedAccount; 
    List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' AND SobjectType='Account' limit 1]; //By mayur-  Added Sobject condition as there is another record type on affiliation with same name
    List<RecordType> getCARecordType = [Select Id from recordType where Name = 'Canada Church' AND SobjectType='Account' limit 1]; 
    List<ID> deleteATMIDList = new List<ID>();
    List<Account>  newAccountsList = new List<Account>();
    List<Id> cancelledTrialAccountIDs = new List<Id>();
    List<Account> OtherAccounts = new List<Account>();  // List to hold all other non-PMM Account tasks. 
    Integer counter = 0;
    system.debug('<< PENDING  WAS CALLED>>'); 
    //1. Check past and current state of the updated Account Records to see if its PMM value has changed.
    for(Integer aCnt = 0; aCnt < acctLimit; aCnt++){ 
          //B.<<For Team Member Manager:>> Check to see if the Owner Id has changed on US Organizations
        system.debug('<<OLD OWNER >> '+Trigger.old[aCnt].OwnerId+' <<NEW OWNER>> '+Trigger.new[aCnt].OwnerId);
         if(Trigger.new[aCnt].RecordTypeId == getUSRecordType[0].Id || Trigger.new[aCnt].RecordTypeId == getCARecordType[0].Id){ //11-23-2014 Added conditional using Record Type as a flag to process for US Orgs only.
             if(/*(Trigger.new[aCnt].Registration_Status__c == 'New' && Trigger.old[aCnt].Registration_Status__c ==null) || 
                 (Trigger.new[aCnt].Registration_Status__c == 'Reinstated'  && Trigger.old[aCnt].Registration_Status__c =='Dropped') ||*/
                 (Trigger.new[aCnt].Physical_County__c != Trigger.old[aCnt].Physical_County__c) ||
                    (Trigger.new[aCnt].Registration_Level__c == 'R1' && Trigger.old[aCnt].Registration_Level__c == 'R0') ||
                 (Trigger.old[aCnt].OwnerId != Trigger.new[aCnt].OwnerId)) { 
                    UpdateAccountList.add(Trigger.new[aCnt]);
                    acctIDs.add(Trigger.new[aCnt].Id);  
                    deleteATMIDList.add(Trigger.new[aCnt].Id);
                    system.debug('<< DELETE ATM  LIST >> '+deleteATMIDList);  
                    //Add the new ATm of VP US Ministries.
                    newAccountsList.add(Trigger.new[aCnt]);
                    system.debug('<< NEW ACCOUNTS LIST FOR VPS >>'+newAccountsList);
                
            }//< counties, New Owner, newly Added? >
            //Make sure that you check this separately from UpdateAccountList because in this case the owner ID won;t change but you still need to call TeamMemberAccounts to get the new ATM
          
         
         }// If US or Canada
    }// FOR
      
    
    //2. <<For Team Member Manager:>> Displatch for processing which accounts are handled by what account hadling classes       
    if(deleteATMIDList.size() > 0){
        List<AccountTeamMember> deleteATMs = new List<AccountTeamMember>();
        List<AccountTeamMember> deleteOldATMs = new List<AccountTeamMember>();
        deleteOldATMs = [Select AccountID,UserId,TeamMemberRole from AccountTeamMember where AccountId in : deleteATMIDList];
        for(AccountTeamMember ATM :deleteOldATMs){
            deleteATMs.add(ATM);            
            system.debug('<<ATM STATE DIR LIST >> '+ATM);
         }//LOOP
         if(deleteATMs.size() > 0){
            delete deleteATMs;
         }
    } 
     
    if(UpdateAccountList.size() > 0){
        system.debug('<<TMACCTS>> '+UpdateAccountList);
        TeamMemberAccounts.handler(UpdateAccountList,acctIDs);      // Go process the TMM accounts
    }  
    if(newAccountsList.size() > 0){
        system.debug('<< NEW ACCOUNTS LIST IN TMA CALLOUT>> '+newAccountsList);
        TeamMemberAccounts.handler(newAccountsList);                //Go process the new Account's TMM with VP of Ministries as the first Teamrole
    }
   
}