@RestResource(urlMapping='/AccountDW/*')
global class DWREAccountRESTController {
    @HttpPost
    global static String updateAccount(String accountid,String mozotrialstatus,String mozotrialcontactid) {
        try {
            if(accountid != null && accountid != '' && accountid InstanceOf ID) {
                List<Account> accountList = [select Mozo_Trial_Status__c,Mozo_Free_Trial_ContactID__c from Account where id =:accountid];
                List<Account> upList = new List<Account>();
                
                for(Account a:accountList){
                    if(mozotrialstatus != null && mozotrialstatus != ''){a.Mozo_Trial_Status__c = mozotrialstatus;} else {return 'Trial Status is blank';}
                    if(mozotrialcontactid != null && mozotrialcontactid != '' && mozotrialcontactid InstanceOf ID){a.Mozo_Free_Trial_ContactID__c = mozotrialcontactid;} else {return 'Trial Contact ID is blank';}
                    upList.add(a);
                }
                update upList;
                return 'success';
            }
            else {
                return 'Account ID is blank';
            }
        } catch (Exception e) {
            String errorMessage = e.getMessage() + ', Line:' + e.getLineNumber();
            return errorMessage;
        }            
    }
}