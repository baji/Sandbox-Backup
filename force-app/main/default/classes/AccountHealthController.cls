/**************************************************************************************************************************************************************************************************************** 
    Programmer: Tony Williams
    Developer:  Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    CRM Experience
    Created:    10/11/2016 - <SFDC-237> When a an account's Health picklist is changed verify that thecolor-coded status info reflects the option selected.
    Updated:    01/09/2017 - <CE-64> Baji Shaik added purple color code for 'Unresponsive' option.
  ***************************************************************************************************************************************************************************************************************************************** **************/

public class AccountHealthController {
    Account acct;
    final static String CODE_BLUE = '#0000ff'; 
    final static String CODE_GREEN ='#006600'; 
    final static String CODE_RED = '#ff0000'; 
    final static String CODE_YELLOW ='#cc9900';
    final static String CODE_PURPLE = '#800080';
    final static String CODE_WHITE ='#ffffff';
     ApexPages.standardController m_sc = null;
    public AccountHealthController(ApexPages.standardController sc){
        m_sc = sc;
        acct = (Account)sc.getRecord();
        acct = [Select Account_Health__c from Account where Id=: acct.Id];

    }
    public String getWhichColor(){

        if(acct.Account_Health__c == 'Everything Is OK'){
            return CODE_GREEN;
        }
        if(acct.Account_Health__c == 'Don\'t Know'){
            return CODE_BLUE;
        }
        if(acct.Account_Health__c == 'Problems: Don\'t Know How To Fix'){
            return CODE_RED;
        }

        if(acct.Account_Health__c == 'Problems: Can Fix'){
            return CODE_YELLOW;
        }
        
        if(acct.Account_Health__c == 'Unresponsive'){
            return CODE_PURPLE;
        }
        return CODE_WHITE;

    }
    
}