/**************************************************************************************************************************************************************************************************************** 
    Programmer: Urvashi Dagara
    Developer:  Urvashi Dagara
    Company:    Infoglen
    Contact:    urvashi.dagara@infoglen.org
    Created:    08/19/2019 - <SMS-52> - Test class for SSAccountAddressVerification controller. 
  ***************************************************************************************************************************************************************************************************************************************** **************/
@isTest
public class SSAccountAddressVerificationTest{
    
    //This function is testing for billing address.
    @isTest static void testMethodForBill() {
    
        //Get the first test account.
        Account acc = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SSAccountAddressVerification controller = new SSAccountAddressVerification(sc);
        
        //Modify account billing address.
        acc.BillingStreet = '1400 N Lake Shore Dr';
        acc.BillingCity = 'Chicago';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '60610-1674';
        acc.BillingCountry = 'USA';
        
        controller.showBillEdit();        
        controller.accVal = JSON.serialize(acc);       
        controller.saveAccount();
        
        Account reQueryAcc = [SELECT Billing_Address_Validation_Status__c FROM Account WHERE Name='TestAcct0' LIMIT 1];
        System.assertEquals(reQueryAcc.Billing_Address_Validation_Status__c,'Verified');
       
    }
    
    //This function is testing for shipping address.
    @isTest static void testMethodForShip() {
    
        //Get the first test account.
        Account acc = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SSAccountAddressVerification controller = new SSAccountAddressVerification(sc);
        
        //Modify account shipping address.
        acc.ShippingStreet = '1600 Amphitheatre Pkwy';
        acc.ShippingCity = 'Mountain View';
        acc.ShippingState = 'CA';
        acc.ShippingPostalCode = '94043-1351';
        acc.ShippingCountry = 'US';
        
        controller.showShipEdit();
        controller.accVal = JSON.serialize(acc);       
        controller.saveAccount();
        
        Account reQueryAcc = [SELECT Shipping_Address_Validation_Status__c FROM Account WHERE Name='TestAcct0' LIMIT 1];
        System.assertEquals(reQueryAcc.Shipping_Address_Validation_Status__c,'Verified');
        
    }
    
    //This function is testing for physical address.
    @isTest static void testMethodForPhysical() {
    
        //Get the first test account.
        Account acc = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SSAccountAddressVerification controller = new SSAccountAddressVerification(sc);
        
        //Modify account physical address.
        acc.Physical_Street_1__c = '3380 146th Pl SE';
        acc.Physical_City__c = 'Bellevue';
        acc.Physical_State__c = 'WA';
        acc.Physical_Zip__c = ' 98007-6480';
        acc.PhysicalCountry__c = 'USA';
        
        controller.showPhysEdit();
        controller.accVal = JSON.serialize(acc);       
        controller.saveAccount();
        
        Account reQueryAcc = [SELECT Physical_Address_Validation_Status__c FROM Account WHERE Name='TestAcct0' LIMIT 1];
        System.assertEquals(reQueryAcc.Physical_Address_Validation_Status__c,'Verified');
    }
    
    //This function is testing for Mailing address.
    @isTest static void testMethodForMail() {
    
        //Get the first test account.
        Account acc = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SSAccountAddressVerification controller = new SSAccountAddressVerification(sc);
        
        //Modify account mailing address.
        acc.Mailing_Street_1__c = '3380 146th Pl SE';
        acc.Mailing_City__c = 'Bellevue';
        acc.Mailing_State_Province__c = 'WA';
        acc.Mailing_Zip_Postal_Code__c = ' 98007-6480';
        acc.Mailing_Country__c = 'USA';
        
        controller.showMailEdit();
        controller.accVal = JSON.serialize(acc);       
        controller.saveAccount();
                
        controller.hideBillEdit();
        
        Account reQueryAcc = [SELECT Mailing_Address_Validation_Status__c FROM Account WHERE Name='TestAcct0' LIMIT 1];
        System.assertEquals(reQueryAcc.Mailing_Address_Validation_Status__c,'Verified');
        
    }

    @testSetup static void setupdTestData() {       
     
        //Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;      
    }
}