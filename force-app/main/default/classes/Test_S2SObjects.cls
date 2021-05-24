/*************************************************************************************************************************************************************
Developer:  Chellappa Karimanoor
Company:    Infoglen@Awana
Contact:    ckarimanoor@infoglen.com
Project:    Test Classes
Original:   12/24/2017
Updated:    12/24/2017 (CK) Created new methods to support Data Migration Classes

****************************************************************************************************************************************************************/ 
//@IsTest 
//only private classes can be marked as tests
//test classes cannot be called from another class or trigger
@IsTest(SeeAllData=true)
public class Test_S2SObjects
{  
    //Test Lead Aquisitions    
    public static testmethod void TestInquiries() {
        // Test Acquisition leads
        List<Lead> Leads= new List<Lead>();
        RecordType aqrc = [Select Id from RecordType where Name = 'Acquisition' limit 1];
        
        Leads.add(new Lead(RecordTypeId =aqrc.Id, 
                           FirstName='ACQUISITIOn',
                           LastName='Lead',
                           Company='Test Acquisition Company1',
                           PhysicalStreet1__c ='The Landmark @ One Market',
                           PhysicalStreet2__c = 'Suite 300',
                           PhysicalCity__c =  'San Francisco',
                           PhysicalState__c =  'CA',
                           PhysicalZipCode__c = '94105',
                           Physical_Country__c = 'UNITED STATES',
                           Email = 'acquireleads@mailinator.com',
                           Status = 'New',
                           LeadSource = 'Advertisement', 
                           PositionRole__c = 'Associate Pastor',
                           Missionary_Source__c = 'Prefered Tester',
                           Phone = '(415) 326-7173' ,
                           Street = 'The Landmark @ One Market',
                           City = 'San Francisco',
                           PostalCode = '94105',
                           Country =  'UNITED STATES'
                          )
                 );
        
        Leads.add(new Lead(RecordTypeId =aqrc.Id, 
                           FirstName='ACQUISITIOn',
                           LastName='Lead2',
                           Company='Test Acquisition Company2',
                           PhysicalStreet1__c ='583 19th Ave',
                           PhysicalCity__c =  'San Francisco',
                           PhysicalState__c =  'CA',
                           PhysicalZipCode__c = '94121',
                           Physical_Country__c = 'UNITED STATES',
                           Email = 'acquireleads2@mailinator.com',
                           Status = 'New',
                           LeadSource = 'Advertisement', 
                           PositionRole__c = 'Associate Pastor',
                           Missionary_Source__c = 'Secondary Tester',
                           Phone = '(650) 375-1111 ' ,
                           Street = '189 Cleo Rand Ln',
                           City = 'San Francisco',
                           PostalCode = '94124',
                           Country =  'UNITED STATES'
                          )
                 );
        
        insert Leads;
        Leads[0].Status = 'Agreement Signed';
        Leads[1].Status = 'Agreement Signed';
        update Leads;
    }
    // uses 1 dml, 0 queries
    public static testMethod List<Address__c> NewAddresses()
    {
        List<Address__c> addresses = new List<Address__c>();
        
        addresses.add(new Address__c(
            First_Name__c = 'Test 1',
            Last_Name__c = 'Address 1', 
            Address_Line_1__c = '123 Street',
            Address_Line_2__c = '123 Street', 
            City__c = 'Streamwood', 
            State__c='IL',
            Zip_Code__c='60107',
            County__c='Cook',
            Country__c='UNITED STATES'
        ));
        
        addresses.add(new Address__c(
            First_Name__c = 'Test 2',
            Last_Name__c = 'Address 2', 
            Address_Line_1__c = 'The Landmark @ One Market',
            Address_Line_2__c = 'Suite 300',
            City__c = 'San Francisco', 
            State__c='CA',
            Zip_Code__c='94105',
            County__c='San Francisco',
            Country__c='UNITED STATES'
        ));
        
        addresses.add(new Address__c(
            First_Name__c = 'Test 3',
            Last_Name__c = 'Address 3', 
            Address_Line_1__c = '1600 Amphitheatre Parkway',
            City__c = 'Mountain View', 
            State__c='CA',
            Zip_Code__c='94043',
            County__c='Santa Clara',
            Country__c='UNITED STATES'
        ));
        
        system.debug('Addresses have been inserted. Remember to set the Account__c field on each addresses.');
        
        insert addresses;
        return addresses;
    }
    public static testMethod Contact S2S_FullContact()
    {
        List<Contact> contacts = new List<Contact>();
        
        
        String[] fnames =  new List<String>{'Bilbo'};
            
            String[] lnames = new List<String>{'Baggins'};
                integer nameSize = lnames.size();
        system.debug('<<ENTERING INTO MOZO TEST>> '+lnames.size() ); 
        
        contacts.add(new Contact(FirstName=fnames[0],LastName=lnames[0],Email=fnames[0]+'@mailinator.com'));
        return contacts[0];
    }
    public static testMethod Account S2S_FullAccount()
    {
        RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
        Account someAcct =  new Account(Name='Christian Test Church', Description='Test Church');
        system.debug('<<GOT ACCT VALUE?>> '+someAcct.Description);
        someAcct.RecordTypeId = acctRecordType.Id;
        system.debug('<<ENTERING INTO  acct>> '+someAcct );
        someAcct.ShippingStreet = '5921 Walnut Hill Ln';
        someAcct.ShippingState = 'TX';
        someAcct.ShippingPostalCode = '75230';
        someAcct.ShippingCountry = 'UNITED STATES';
        someAcct.ShippingCity = 'Waco';
        return someAcct;
    }
    public static testMethod Order S2S_NewOrder()
    {
        Order o = new order (
            Status='Order Open', 
            Name='O-TEST-0', 
            effectiveDate=System.Today() 
        );
        
        system.debug('Order has not been inserted. Set the PriceBook2Id and AccountId for this opportunity before insert.');
        
        return o;
    }
    public static testMethod Order S2S_FullOrder()
    {
       User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
        List<Account> accts = new List<Account>();
        accts.add(Test_S2SObjects.S2S_FullAccount());
        List<Contact> contacts = new List<Contact>();
        contacts.add(Test_S2SObjects.S2S_FullContact());
        List<Order> testOrd = new List<Order>();
        testOrd.add(Test_S2SObjects.S2S_NewOrder());
        Id pricebookId = Test.getStandardPricebookId();
        Integer i = 0;
        //OrderEntryServices.Result result = OrderEntryServices.GetNextOrderNumber('O',accts[i].Mailing_Address_Book__c);    
        testOrd[i].Name = 'O-111-';
        testOrd[i].Type = 'Shipping';
        testOrd[i].Company__c = 'Awana';
        testOrd[i].Order_Type__c = 'SO';
        testOrd[i].Shipping_Country__c =  'UNITED STATES';
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
        cOrder.ChargentOrders__Billing_First_Name__c = contacts[i].FirstName;
        cOrder.ChargentOrders__Billing_Last_Name__c = contacts[i].LastName;
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Country__c = 'United States';
        insert cOrder;
        testOrd[i].Chargent_Order__c = cOrder.Id;
        testOrd[i].Promo_code__c= '';
        testOrd[i].OwnerId = ouser.Id;
        testOrd[i].Payment_Terms__c = 'Net 30';
        testOrd[i].Shipping_Type__c = 'Priority Mail'; 
        testOrd[i].Shipping_Code__c = 'PRI';              
        testOrd[i].Shipping_Carrier__c = 'POST';
        testOrd[i].Notes__c ='Tes Order for faux client';
        testOrd[i].Pricebook2Id = pricebookId;
        testOrd[i].AccountId = accts[i].Id;
        system.debug('<< BEFORE ORDER ITEMS >> '+testOrd);
        system.debug('<< ACCOUNTID ORDER ITEMS >> '+testOrd[i].AccountId);
        
        system.debug('Order has not been inserted. Set the PriceBook2Id and AccountId for this Order before insert.');
        
        return testOrd[i];
    }
}