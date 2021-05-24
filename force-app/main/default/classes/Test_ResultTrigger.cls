@isTest(seeAllData=true)
public class Test_ResultTrigger {

    static testMethod void testResultTrigger(){
        Account a = new Account(Name='Test Account',BillingState='IL',BillingCountry='United States',PhysicalCountry__c='United States');
        insert a;
        Contact c = new Contact(FirstName='Test',LastName='Contact',Email='testemail@mailinator.com',Accountid=a.id);
        insert c;
        
        WE_FW8_NP__WESearchResult__c w = new WE_FW8_NP__WESearchResult__c(WE_FW8_NP__Contact__c=c.id);
        insert w;
    }
}