/**********************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            AGD-3
    Original:           7/11/2017-  Church signs up for Awana GO.
	Called By:			AccountAfterUpdate (Trigger)
 *********************************************************************************************************************/ 
public class SignUpGOAccounts {
    public static void helper(List<Account> updateGOAccounts){
        
        for(Account anAccount : updateGOAccounts){
            if(anAccount.GO_startDate__c == null){
                anAccount.GO_startDate__c = system.today();
            }
            anAccount.GO_Submission_Date__c =  system.today();
            // Point Expiration date to June 30th of Next Year
            Date december = date.newInstance(anAccount.GO_Submission_Date__c.year(), 12, 31);
            Date june = date.newInstance(anAccount.GO_Submission_Date__c.year(), 06, 30);
            Date todaysDate = anAccount.GO_Submission_Date__c;
            if(todaysDate > june &&  todaysDate <= december){
            	anAccount.GO_End_Date__c =  date.newInstance(anAccount.GO_Submission_Date__c.year() + 1, 06, 30);
            }else{
               	anAccount.GO_End_Date__c =  date.newInstance(anAccount.GO_Submission_Date__c.year(), 06, 30); 
            }
        }
    }
}