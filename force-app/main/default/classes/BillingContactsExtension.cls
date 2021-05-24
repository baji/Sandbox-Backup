public class BillingContactsExtension {
    
    Account CurrentAccount = null;
    List<Contact> BillingContacts = null;
    
    public BillingContactsExtension(ApexPages.StandardController controller) {
        CurrentAccount = (Account)controller.getRecord();
        BillingContacts = [SELECT Id, Name, OtherPhone, HomePhone, MobilePhone, Email FROM Contact WHERE AccountId = :CurrentAccount.Id AND Billing_Contact__c = True AND Active__c = True ORDER BY Contact.LastModifiedDate DESC];
    }
    
    public List<Contact> getBillingContacts() { return BillingContacts; }
    
     public static testMethod void testContactsExtension() 
    {
    	Account testAccount = new Account(Name='Dev Church of the Sandbox',ISO_Code__c='US');
    	
    	ApexPages.StandardController controller  = new ApexPages.StandardController(testAccount); 
      BillingContactsExtension BEC = new BillingContactsExtension(controller);
      List<Contact> billingContacts = BEC.getBillingContacts();
    }
}