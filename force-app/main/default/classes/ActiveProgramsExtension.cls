/**************************************************************************************************************************
Programmer: Jen L.
Company:    Awana
Contact:    
Project:    Program_c controller - Displays all active programs for the account.
Created:    04/8/2013
**************************************************************************************************************************/

public class ActiveProgramsExtension {
    
    Account CurrentAccount = null;
    List<Program__c> ActivePrograms = null;
    
    public ActiveProgramsExtension(ApexPages.StandardController controller) {
        CurrentAccount = (Account)controller.getRecord();
        ActivePrograms = [SELECT Account__c, Name,Active__c FROM Program__c WHERE Account__c= :CurrentAccount.Id and Active__c=TRUE];
    }
    
    public List<Program__c> getActivePrograms() { return ActivePrograms; }
    
     public static testMethod void testContactsExtension() 
    {
        Account testAccount = new Account(Name='Dev Church of the Sandbox',ISO_Code__c='US');
        insert testAccount;
        
        Program__c pg = new Program__c(Account__c = testAccount.id, Name ='Program 1',Active__c = true);
        insert pg;
        
        ApexPages.StandardController controller  = new ApexPages.StandardController(testAccount); 
      ActiveProgramsExtension BEC = new ActiveProgramsExtension(controller);
      List<Program__c> ActivePrograms = BEC.getActivePrograms();
    }
}