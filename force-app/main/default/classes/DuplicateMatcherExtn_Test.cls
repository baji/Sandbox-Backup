/*****************************************************************************************************************************************************************************************
*   Programmer: Vikas Y
*   Company:    Infoglen
*   Contact:    vikas@Infoglen.com
*   Project:    CRM Rewrite
*   Original:   11/28/2017 - Testing of DuplicateMatcherExt
*	Updated:		08-242018 -<ASP-1248> -(Tony W) 
*   Test:       DuplicateMatcherExtn_Test.cls
*   
**************************************************************************************************************************************************************************************************************/

@isTest(SeeAllData=true)
public class DuplicateMatcherExtn_Test {
   static testmethod void duplicateMatcher_test(){       
       Account acc = new Account();
       acc.Name  = 'Test Company';
       insert acc;
       
       Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'Test@Dup.com';
        Insert con;
       
       Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead';
        ld.Email = 'Test@Dup.com';
        ld.Company = 'Test Company';
        ld.Stages__c = 'New Lead';
        ld.Status = 'Open - Not Contacted';
        upsert ld;
       
       DuplicateMatcherExtn dupExtn = new DuplicateMatcherExtn(new ApexPages.StandardController(ld));      
   }
}