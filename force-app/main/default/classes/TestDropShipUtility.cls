/****************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    (Drop Ship casess)
    Description: Performs SFDC Testing of Drop Ship Utility class.
    Created:    06/26/2017 - <ASP-214>  
*******************************************************************************************************************************************/
@isTest
private class TestDropShipUtility {
    private static testmethod void TestSetupDropShip(){
        RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
        // Now Set up the Registration level, STatus and Epxiration Date for each ofthe three in order to perform the series of tests.
        Date tempDate = Date.today();
        Integer month = tempDate.month();
        Integer day = tempDate.day();
        Integer year = tempDate.year();
        
        //1. Create Account
        List<Account> accounts = new List<Account>(); 
              
         accounts.add(new Account(Name='Christian Test Church', 
                        Description='Test Church', 
                        Registration_Level__c = 'R2',
                        Registration_Status__c = null,
                        RecordTypeId = acctRecordType.Id,
                        ShippingStreet = '5921 Walnut Hill Ln',
                        Cast_Iron_Bypass__c='0',
                        Mozo_Trial_Status__c = 'Former',
                        ShippingState = 'TX',
                        ShippingPostalCode = '75230',
                        ShippingCountry = 'UNITED STATES',
                        ShippingCity = 'Waco'));
        insert accounts;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName='Pecos',
                                 LastName='Bill',
                                 Email='riogrande@mailinator.com'));
        // Affiliations
        insert contacts;
        List<npe5__Affiliation__c> affiliations = new List<npe5__Affiliation__c>();
        affiliations.add(new npe5__Affiliation__c(npe5__Contact__c=contacts[0].Id,
                                                 npe5__Organization__c= accounts[0].Id,
                                                 Church_Role__c='Pastor Associate Pastor',
                                                 Mozo_User_Level__c ='Full'));
        
        // Opportunities
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        List<Order> opportunities = new List<Order>();
        opportunities.add(new Order(Name ='O-DropShipUtiltiy',
                                        AccountId=accounts[0].Id,
                                        Shipping_Address__c= accounts[0].Default_Shipping_Address__c,
                                        Ship_to_Name__c = contacts[0].FirstName +' '+ contacts[0].LastName,
                                        Ship_to_First_Name__c = contacts[0].FirstName,
                                        Ship_to_Last_Name__c = contacts[0].LastName,
                                        Shipping_Street__c = String.valueOf(accounts[0].ShippingStreet),
                                        Shipping_City__c = accounts[0].ShippingCity,
                                        Shipping_State__c  =   accounts[0].ShippingState,
                                        Shipping_Zip_Code__c = accounts[0].ShippingPostalCode,
                                        EffectiveDate = Date.newInstance(year, month, day),
                                        Status = 'Order Open',
                                    	Chargent_Order__c = cn.Id,
                                        Account_Updated__c = false,
                                        Description = 'Email: tonyw@mailinator.com;Phone: 847-525-9749;Race Date is 05/01/2017'));
        
        // INsert the account and then change thge Stagename to Submitted
        insert opportunities;  
        opportunities[0].status = 'Order Submitted';
        opportunities[0].Order_Submitted__c = system.today();
        upsert opportunities;
        DropShipUtility.SendEmailCheckRaceDate(opportunities);
        
    }
    
        
}