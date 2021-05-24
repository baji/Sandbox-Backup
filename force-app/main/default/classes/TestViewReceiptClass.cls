/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Test class for ViewReceiptClass
***************************************************************************************************************************************************************************************************************************************** **************/

@IsTest
public class TestViewReceiptClass{
     @testSetup 
    static void createReceipt() {
        // Create common test accounts
        List<Receipt__c> testAccts = new List<Receipt__c>();
        for(Integer i=0;i<20;i++) {
            testAccts.add(new Receipt__c(Name = 'TestAcct'+i));
        }
        insert testAccts;        
    }
    public static testMethod void redirectToList(){
         List <Receipt__c> acctList = [SELECT ID FROM Receipt__c];
        Test.startTest();
        Test.setCurrentPage(Page.View_Receipts_Page);
        ApexPages.StandardSetController  sc = new ApexPages.StandardSetController (acctList);
        ViewReceiptClass testEmp = new ViewReceiptClass(sc);
        testEmp.redirectToList();
        
    }
}