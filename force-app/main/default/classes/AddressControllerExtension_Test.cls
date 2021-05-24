@IsTest
public class AddressControllerExtension_Test {    
    public static testMethod void testAddressControllerExtension (){
         
         Account testAccount = new Account(Name='Dev Church of the Sandbox',ISO_Code__c='US');
         ApexPages.StandardController controller  = new ApexPages.StandardController(testAccount); 
         AddressControllerExtension pce = new AddressControllerExtension(controller);
         
         AddressEDQPageLoad__c apd = new AddressEDQPageLoad__c(Name='abc',value__c = '123');
         
         try{
             insert apd;
         }catch(Exception e){
             system.debug('---'+e.getmessage());
         }
         AddressControllerExtension.getAddressEDQCustomSetting('abc','345');
         
         AddressControllerExtension.insertAddressEDQCustomSetting('123','3456');
         
         AddressControllerExtension.deleteAddressEDQCustomSetting('123');
         
         
    }
    
    public static testMethod void testMethodAddressControllerExtension (){
         Account testAccount = new Account(Name='Dev Church of the Sandbox',ISO_Code__c='US');
         ApexPages.StandardController controller  = new ApexPages.StandardController(testAccount); 
         AddressControllerExtension pce = new AddressControllerExtension(controller);
         
         AddressControllerExtension.getAddressEDQCustomSetting('abc','345');
    }
}