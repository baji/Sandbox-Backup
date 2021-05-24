public class PurchasingContactsExtension {
    
    Account CurrentAccount = null;
    List<Contact> PurchasingContacts = null;
    
    public PurchasingContactsExtension(ApexPages.StandardController controller) {
        CurrentAccount = (Account)controller.getRecord();
        PurchasingContacts = [SELECT Id, Name, OtherPhone, HomePhone, MobilePhone, Email FROM Contact WHERE AccountId = :CurrentAccount.Id AND Purchasing_Contact__c = True AND Active__c = True ORDER BY Contact.LastModifiedDate DESC];
    }
    
    public List<Contact> getPurchasingContacts() { return PurchasingContacts; }
    
    public static testMethod void testContactsExtension(){
         Account testAccount = new Account(Name='Dev Church of the Sandbox',ISO_Code__c='US');
         Contact con = new Contact(FirstName='Test',LastName='1',Email='test@mailinator.com',Account=testAccount);
         ApexPages.StandardController controller  = new ApexPages.StandardController(testAccount); 
         PurchasingContactsExtension pce = new PurchasingContactsExtension(controller);
         List<Contact> purchasedContacts = pce.getPurchasingContacts();
    }
}