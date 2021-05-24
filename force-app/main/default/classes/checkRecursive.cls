/*
Purpose - Class to handle recursive handling of triggers. 
Author - CK
*/

public Class checkRecursive
{
    private static boolean run = true;
    private static boolean runOrderSubmit = true;
    
    public static boolean batchUpdate = false;
    
    public static string batchStatus ='';
    //Added by Mayur
    @TestVisible
    private static boolean runDuplicateContact = true; 
    
    @TestVisible
    private static boolean runDuplicateAccount = true;
    
    public static boolean runOnce()
    {
        if(run)
        {
         run=false;
         return true;
        }
        else
        {
            return run;
        }
    }
    
    public static boolean runOnceOrderSubmit()
    {
        if(runOrderSubmit)
        {
         runOrderSubmit=false;
         return true;
        }
        else
        {
            return runOrderSubmit;
        }
    }
    
    public static boolean runOnceDuplicateContact(){
        if(runDuplicateContact)
        {
         runDuplicateContact = false;
         return true;
        }
        else
        {
            return runDuplicateContact;
        }
    }
    
    public static boolean runOnceDuplicateAccount(){
        if(runDuplicateAccount)
        {
         runDuplicateAccount = false;
         return true;
        }
        else
        {
            return runDuplicateAccount;
        }
    } 
    public static void setBatchStatus(String batchString){
        batchStatus = batchString;
    } 
    
    
}