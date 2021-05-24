/***************************************************************************************************************************************************************************************
    Programmer: Urvashi Dagara.  
    Company:    Awana
    Contact:    urvashi.dagara@infoglen.com
    Description: Test checkRecursive 
    Created:    12/17/2020 - checkRecursive_Test
***************************************************************************************************************************************************************************************/
@isTest
public class checkRecursive_Test {
    
     public static testMethod void testRecursiveCheck(){
        checkRecursive.runOnce();
        checkRecursive.runOnceOrderSubmit();
        checkRecursive.runOnceDuplicateContact();
        checkRecursive.runOnceDuplicateAccount();
    }


}