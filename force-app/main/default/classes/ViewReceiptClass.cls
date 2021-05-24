/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    02/19/2018 - <CRM - 130> Track down the opportunity which influenced the level change in Account
***************************************************************************************************************************************************************************************************************************************** **************/

public with sharing class ViewReceiptClass {

    public ViewReceiptClass(ApexPages.StandardSetController controller) {

    }
    public PageReference redirectToList() { 
      Schema.DescribeSObjectResult result = Receipt__c.SObjectType.getDescribe(); 
      PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
      pageRef.setRedirect(true); 
      return pageRef; 
}
}