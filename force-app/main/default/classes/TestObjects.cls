/*************************************************************************************************************************************************************
Programmer: Matthew Keefe
Developer:  Tony Williams
Company:    Awana
Contact:    mattk@awana.org
Project:    Test Classes
Original:   09/24/2010
Updated:    03/12/2012 (TW) Created code segment to automatically calculated the latest customer ID.
Updated:    04/25/2013 - Removing JDE Item variables in  test cases.
Updated:    07/03/2014 - Added test Team Member method.
Updated:    09/04/2014 - <FRT Reconstruct> Added test case for the PB Integraton for Weight FRT.
Updated:    09/23/2014 - <FRT RECONTSRUCT>  Created a mock  WSDL call out for Freight becasue SFDC  can't really have test methods calling Web services 
Updated:    09/29/2014 - Added new method  - NewOne2OneContact - to help test Affiliation Church Roles and make sure a default string is assigned to it.
Updated:    08/09/2015 - Added 3 new methhods: FullOpportunity, FullAccount, FullContact.
****************************************************************************************************************************************************************/ 
//@IsTest 
//only private classes can be marked as tests
//test classes cannot be called from another class or trigger
@IsTest(SeeAllData=true)
public class TestObjects
{  
    // uses 3 dml, 4 queries
    public static testmethod User NewUser()
    {
        double randomdbl = math.random()*9999;
        integer randomint = Integer.valueOf(randomdbl.round());
        string usernumber = String.valueOf(randomint);
        
        User u = new User();
        u.FirstName = 'Tester';
        u.LastName = 'Extrordinaire';
        u.UserName = 'mattk+TestUser_'+usernumber+'@awana.org';
        u.Email = 'mattk+TestUser_'+usernumber+'@awana.org';
        //u.ProfileId = [Select Id, Name From Profile Where Name like '%Portal User%' OR Name like '%Commander%' Limit 1].Id;
        u.ProfileId = [Select Id, Name From Profile Where Name like '%User%' OR Name like '%Customer%' Limit 1].Id;
        u.ContactId = NewContact().Id;
        u.CommunityNickName = 'Tester+'+usernumber;
        u.Alias = 't'+usernumber;
        u.TimeZoneSidKey = 'America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        
        //insert u;
        try{
            insert u;
        }
        catch(DMLException e){
            system.debug('retry!');
            //update u;
        }
        return u;
    }
    
    // uses 2 dml, 3 queries
    public static testmethod Contact NewContact()
    {
        List<Account> Accounts = NewAccounts();
        string TestChurchId = null;
        
        system.debug(Accounts);
        
        for(Account a : Accounts)
        {
            if(a != null)
            {
                if(a.Name != null)
                {
                    system.debug('***'+a);
                    if(a.Name.toLowerCase().contains('church'))
                    {
                        TestChurchId = a.Id; 
                    }
                }
            }
        }
        system.debug('<< WHAT TEST CHURCH '+TestChurchId+' >>');
        Contact TestContact = NewGenericContact();
        TestContact.AccountId=TestChurchId;
        
        insert TestContact;
        return TestContact;
    }
    //***SSO
      public static User createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId,
                                UserRoleId = roleId);
        /*try{
            insert tuser;
        }
        catch(DMLException e){
            system.debug('retry!');
            
        }*/
        return tuser;
    }   
    // uses 0 dml; 0 queries
    public static testmethod Contact NewGenericContact()
    {
        return new Contact(
            FirstName='Test',
            LastName='Contact',
            Title='Tester Extrordinaire',
            Salutation='Mr.',
            OtherStreet='123 Sesame Street',
            OtherState='IL',
            OtherPostalCode='60612',
            OtherCity='Chicago',
            Email='mattk+TestContact@awana.org',
            MailingStreet='1 E Bode Road',
            MailingState='IL',
            MailingPostalCode='60107',
            MailingCity='Streamwood',
            MailingCountry='UNITED STATES',
            Mail_Code__c='Send Mail',
            Home_County__c='Cook',
            Active__c=true
        );
    }
    
    // uses 1 dml, 3 queries
    public static testmethod List<Account> NewAccounts()
    {
        List<Account> accounts = new List<Account>();
        List<RecordType> recordtypes = NewAccountRecordTypes();
        //TW 3-12-2012
        Integer index = 0;
        Boolean found_matchCN = true;
        
        Integer counter = 0;
        //Church_Registration__c CR = null;
        NewChurchRegistration();
        List<Church_Registration__c> custID=[Select Last_Customer_Number__c from Church_Registration__c];
        system.debug('custID-list'+custID);
        integer someID = Integer.valueOf(custID[0].Last_Customer_Number__c);
        system.debug('someID-'+someID);
        List<Account> accts = [Select Id,Account_on_Hold__c, Mailing_Address_Book__c FROM Account where Mailing_Address_Book__c =: custID[0].Last_Customer_Number__c  limit 1];
        system.debug('accts-'+accts);
        someID++;
        while(found_MatchCN)
        {
            if(accts == null  || (accts!=null && accts.size()>0 && accts[index].Mailing_Address_Book__c != String.valueOf(someID)))
            {
                found_MatchCN = false;
                someID--;        
                //system.debug('<< LATEST CN .VS. MAB >> '+custID[0] +' '+accts[index].Mailing_Address_Book__c );        
            }
            else
            {
                someID++;
                system.debug('<< NEXT CN LOOP>> '+someID);
                found_MatchCN = false;
            }
            index++;
        }    
        //END TW: 3-123-2012
        counter = someID; // Get current Customer Number so far...
        system.debug('NewAccountRecordTypes'+NewAccountRecordTypes());
        for(RecordType r : NewAccountRecordTypes())
        {
            counter++;
            
            Account a = NewCustomAccount();
            system.debug('**After NewCustomAccount a'+a);
            a.Mailing_Address_Book__c = String.valueOf(counter); //TW 3-12-2012
            //TW: 1-10-2012: This is to try and fix the duplicate Mailing_Address_Book error in the test results.
            //if(count==4) {++count;}
            // a.Mailing_Address_Book__c = '000000'+ count;
            //TW: END
            a.RecordTypeId = r.Id;
            a.ShippingCountry = 'UNITED STATES';
            a.PhysicalCountry__c = 'UNITED STATES';
            a.Mailing_Country__c='UNITED STATES';
            system.debug(' *** '+a.Name);
            accounts.add(a);
            
        }
        // insert accounts;
        try{
            upsert accounts;
            custID[0].Last_Customer_Number__c = String.valueOf(counter);
            update custID[0];
        }
        catch(DMLException e)
        {
            // upsert accounts;
        }
        return accounts;
    }
    //***SSO
    // uses 0 dml, 0 queries
    public static testmethod Account NewGenericAccount()
    {
        return new Account(
            BillingStreet='1600 Amphitheatre Parkway', // Google HQ
            BillingCity='Mountain View',
            BillingPostalCode='94043',
            BillingState='CA',
            BillingCountry='UNITED STATES',
            ShippingStreet='The Landmark at One Market\nSuite 300', 
            ShippingCity='San Francisco',
            ShippingPostalCode='94105',
            ShippingState='CA',
            ShippingCountry='UNITED STATES',
            Description = 'ECLIPSE TEST'
        );
    }
    
    // uses 1 dml, 2 queries
    public static testmethod npe5__Affiliation__c NewCustomAffiliation()
    {
        //Account acct = NewCustomAccount();
        Contact TestContact = NewContact();
        system.debug('COntactID: '+TestContact.Id);
        
        //acct.Name = 'AffTest';
        // acct.Account_on_Hold__c = false;
        // acct.Status__c = 'Added';
        // insert acct;
        // system.debug('AccountID: '+acct.Id);
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Mailing_Address_Book__c = '000123'; 
        insert a2;
        npe5__Affiliation__c aff = new npe5__Affiliation__c(npe5__Organization__c = a2.id, npe5__Contact__c = TestContact.Id);
        
        
        insert aff;
        return aff;
        
    }
    
    
    // uses 1 dml, 2 queries
    public static testmethod Account NewCustomAccount()
    {
        Account a = NewGenericAccount();
        a.name = 'Caledonia Baptist Church';
        a.Mailing_Address_Book__c = registration.nextCustomerNumber();
        a.Registration_Number__c = 'TEST'+String.valueOf(DateTime.Now().second())+String.valueOf
            (DateTime.Now().millisecond());
        a.Registration_Date__c = Date.Today().addDays(-1);
        
        a.ISO_Code__c='US';
        a.Status__c='Added';
        a.Account_on_Hold__c = false;
        a.Mailing_County__c='Santa Clara'; // AKA Billing County
        a.Shipping_County__c='San Francisco'; // Shipping County
        
        a.Mailing_Street_1__c='The Landmark @ One Market';
        a.Mailing_Street_2__c='Suite 300';
        a.Mailing_City__c='San Francisco';
        a.Mailing_State_Province__c='CA';
        a.Mailing_Zip_Postal_Code__c='94105';
        a.Mailing_County__c='San Francisco';
        a.Mailing_Country__c='UNITED STATES';
        a.Description =  'ECLIPSE TEST';
        a.BillingStreet='1600 Amphitheatre Parkway';
        a.BillingCity='Mountain View';
        a.BillingPostalCode='94043';
        a.BillingState='CA';
        a.BillingCountry='UNITED STATES';
        a.ShippingStreet='The Landmark at One Market\nSuite 300';
        a.ShippingCity='San Francisco';
        a.ShippingPostalCode='94105';
        a.ShippingState='CA';
        a.ShippingCountry='UNITED STATES';
        a.Description = 'ECLIPSE TEST';
        system.debug('account a'+a);
        return a;
    }
    
    // uses 0 dml, 1 queries
    public static testmethod List<RecordType> NewAccountRecordTypes()
    {
        List<RecordType> recordtypes = [SELECT Id, Name FROM RecordType WHERE 
                                        SobjectType='Account' and IsActive=true];
        return recordtypes;
    }
    
    // uses 0 dml, 0 queries
    public static testMethod Order NewOpportunity()
    {
        Order o = new Order (
            Status='Order Open', 
            Name='O-TEST-0', 
            EffectiveDate=System.Today() 
        );
        
        system.debug('Order has not been inserted. Set the PriceBook2Id and AccountId for this opportunity before insert.');
        
        return o;
    }
    public static testMethod Order NewOrder()
    {
        Order o = new order (
            Status='Order Open', 
            Name='O-TEST-0', 
            effectiveDate=System.Today() 
        );
        
        system.debug('Order has not been inserted. Set the PriceBook2Id and AccountId for this opportunity before insert.');
        
        return o;
    }
    // uses 0 dml, 0 queries
    public static testMethod Order FullOpportunity()
    {
        User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
        List<Account> accts = new List<Account>();
        accts.add(TestObjects.FullAccount());
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestObjects.FullContact());
        List<Order> testOpp = new List<Order>();
        testOpp.add(TestObjects.NewOpportunity());
        Id pricebookId = Test.getStandardPricebookId();
        Integer i = 0;
        //OrderEntryServices.Result result = OrderEntryServices.GetNextOrderNumber('O',accts[i].Mailing_Address_Book__c);    
        testOpp[i].Name = 'O-111-';
        testOpp[i].Type = 'Shipping';
        testOpp[i].Company__c = 'Awana';
        testOpp[i].Order_Type__c = 'SO';
        testOpp[i].Shipping_Country__c =  'UNITED STATES';
        /*testOpp[i].ChargentSFA__Billing_First__c = contacts[i].FirstName;
testOpp[i].ChargentSFA__Billing_Last__c =  contacts[i].LastName;  
testOpp[i].ChargentSFA__Billing_Email__c = 'somebodysorders@mailinator.com';  
*/
        testOpp[i].OwnerId = ouser.Id;
        testOpp[i].Payment_Terms__c = 'Net 30';
        testOpp[i].Shipping_Type__c = 'Priority Mail'; 
        testOpp[i].Shipping_Code__c = 'PRI';              
        testOpp[i].Shipping_Carrier__c = 'POST';
        testOpp[i].Notes__c ='Tes Order for faux client';
        testOpp[i].Pricebook2Id = pricebookId;
        testOpp[i].AccountId = accts[i].Id;
        system.debug('<< BEFORE ORDER ITEMS >> '+testOpp);
        system.debug('<< ACCOUNTID ORDER ITEMS >> '+testOpp[i].AccountId);
        
        system.debug('Opportunity has not been inserted. Set the PriceBook2Id and AccountId for this opportunity before insert.');
        
        return testOpp[i];
    }
    public static testMethod Order FullOrder()
    {
       User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
        List<Account> accts = new List<Account>();
        accts.add(TestObjects.FullAccount());
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestObjects.FullContact());
        List<Order> testOrd = new List<Order>();
        testOrd.add(TestObjects.NewOrder());
        Id pricebookId = Test.getStandardPricebookId();
        Integer i = 0;
        //OrderEntryServices.Result result = OrderEntryServices.GetNextOrderNumber('O',accts[i].Mailing_Address_Book__c);    
        testOrd[i].Name = 'O-111-';
        testOrd[i].Status= 'Order Open';
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
    
    public static testMethod Account FullAccount()
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
    
    public static testMethod Contact FullContact()
    {
        List<Contact> contacts = new List<Contact>();
        
        
        String[] fnames =  new List<String>{'Bilbo'};
            
            String[] lnames = new List<String>{'Baggins'};
                integer nameSize = lnames.size();
        system.debug('<<ENTERING INTO MOZO TEST>> '+lnames.size() ); 
        
        contacts.add(new Contact(FirstName=fnames[0],LastName=lnames[0],Email=fnames[0]+'@mailinator.com'));
        return contacts[0];
    }
    // uses 0 dml, 0 queries
    /*public static testMethod ChargentSFA__Transaction__c NewTransaction()
{
ChargentSFA__Transaction__c t = new ChargentSFA__Transaction__c (
ChargentSFA__Type__c='Authorization',
ChargentSFA__Response_Status__c='Approved',
ChargentSFA__Response_Message__c='Approved',
ChargentSFA__Payment_Method__c='Credit Card',
ChargentSFA__Gateway_ID__c='V12345678901',
ChargentSFA__Description__c='000001', 
ChargentSFA__Credit_Card_Type__c='Visa',
ChargentSFA__Credit_Card_Number__c='4111111111111111',
ChargentSFA__Credit_Card_Name__c='Order Entry',
ChargentSFA__Billing_State__c='IL',
ChargentSFA__Billing_Postal_Code__c='60107',
ChargentSFA__Billing_Last__c='Entry',
ChargentSFA__Billing_First__c='Order',
ChargentSFA__Billing_Country__c='UNITED STATES',
ChargentSFA__Billing_City__c='Streamwood',
ChargentSFA__Billing_Address__c='1 E Bode Road',
ChargentSFA__Authorization__c='123456',
ChargentSFA__Amount__c=2
);

system.debug('Transaction has not been inserted. Set the ChargentSFA__Opportunity__c field before insert.');

return t;
}
*/    
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
    
    // uses 1 dml, 0 queries
    public static testmethod PriceBook2 NewPriceBook()
    {
        PriceBook2 TestPriceBook = new PriceBook2(Name='Test PriceBook');
        
        insert TestPriceBook;
        return TestPriceBook;
    }
    // uses 1 dml, 0 queries
    public static testmethod Company__c NewCompanies()
    {
        Company__c TestCompany = new Company__c(Name='Test Company');
        
        insert TestCompany;
        return TestCompany;
    }
    
    // uses 1 dml, 0 queries
    public static testmethod List<Product2> NewProducts()
    {
        List<Product2> Products = new List<Product2>();
        
        Products.add( new Product2(
            IsActive=true,Name='Test Item 99990',ProductCode='99990',List_Price__c=1.25,Row__c='A',Bin__c='1',
            Quantity__c=0,Quantity_Reserved__c=0,Non_inventory_Item__c=true,Line_Type__c='S - Stock Inventory Item',Weight__c = 0.70) ); 
        Products.add( new Product2(
            IsActive=true,Name='Test Item 99991',ProductCode='99991',List_Price__c=1.50,Row__c='A',Bin__c='2',
            Quantity__c=50,Quantity_Reserved__c=50,Line_Type__c='S - Stock Inventory Item',Weight__c = 0.57) );
        Products.add( new Product2(IsActive=true,Name='Test Item 99992',ProductCode='99992',List_Price__c=1.75,Row__c='A',Bin__c='3',
                                   Quantity__c=200,Quantity_Reserved__c=400,Line_Type__c='S - Stock Inventory Item',Weight__c = 0.69) );
        Products.add( new Product2(
            IsActive=true,Name='Test Item 99993',ProductCode='99993',List_Price__c=2.00,Row__c='A',Bin__c='4',
            Quantity__c=1000,Quantity_Reserved__c=0,Force_Backorder__c=true,Line_Type__c='S - Stock Inventory Item',Weight__c = 0.83) );
        Products.add( new Product2(
            IsActive=true,Name='Test Item 99994',ProductCode='99994',List_Price__c=2.25,Row__c='A',Bin__c='5',
            Quantity__c=10000,Quantity_Reserved__c=0,Line_Type__c='S - Stock Inventory Item',Weight__c = 0.90) );
        Products.add( new Product2(
            IsActive=true,Name='Test Item 99995',ProductCode='99995',List_Price__c=0,Row__c='A',Bin__c='6',
            Quantity__c=0,Quantity_Reserved__c=0,Line_Type__c='F - Freight', Weight__c = 0.0) );
        Products.add( new Product2(
            IsActive=true,Name='Test Item 99996',ProductCode='99996',List_Price__c=0,Row__c='A',Bin__c='7',
            Quantity__c=0,Quantity_Reserved__c=0,Line_Type__c='T - Text', Weight__c = 0.0) );
        Products.add( new Product2(
            IsActive=true,Name='Test Customer Service Adjustment 99997',ProductCode='99997',List_Price__c=0,Row__c='A',Bin__c='8',
            Quantity__c=0,Quantity_Reserved__c=0,Line_Type__c='N - Non-Stock', Weight__c = 0.0) );
        Products.add( new Product2(
            IsActive=true,Name='Test Discount 99998',ProductCode='99998',List_Price__c=0,Row__c='A',Bin__c='9',
            Quantity__c=0,Quantity_Reserved__c=0,Line_Type__c='N - Non-Stock', Weight__c = 0.0) );
        
        Products.add( new Product2(
            IsActive=true,Name='Test KM Discount 99999',ProductCode='99999',List_Price__c=15.95,Row__c='A',Bin__c='10',
            Quantity__c=0,Quantity_Reserved__c=0,Line_Type__c='SB - Subscription', Weight__c = 0.0) );
        
        insert Products;
        return Products;
    }
    
    // uses 4 dml, 1 query
    public static testmethod List<PriceBookEntry> NewPriceBookEntries()
    {
        PriceBook2 PriceBook = NewPriceBook();
        List<Product2> Products = NewProducts();
        List<PriceBookEntry> StandardPriceBookEntries = new List<PriceBookEntry>();
        List<PriceBookEntry> PriceBookEntries = new List<PriceBookEntry>();
        
        sObject StandardPriceBook = [select ID from Pricebook2 where IsStandard = TRUE];
        
        for(Product2 p : Products)
        {
            StandardPriceBookEntries.add(new PriceBookEntry
                                         
                                         (Product2Id=p.Id,PriceBook2Id=StandardPriceBook.Id,UnitPrice=p.List_Price__c,UseStandardPrice=false,IsActive
                                          
                                          =true));
        }
        
        try { insert StandardPriceBookEntries; } catch(Exception ex) { return null; system.debug('***** Failed to generate StandardPriceBookEntries ***** '+ex); }
        
        for(Product2 p : Products)
        {
            PriceBookEntries.add(new PriceBookEntry
                                 
                                 (Product2Id=p.Id,PriceBook2Id=PriceBook.Id,UnitPrice=p.List_Price__c,UseStandardPrice=false,IsActive=true));
        }
        
        try { insert PriceBookEntries; } catch(Exception ex) { return null; system.debug('***** Failed to generate PriceBookEntries ***** '+ex); }
        
        return PriceBookEntries;
    }
    
    // uses 6 dml, 5 queries
    public static testmethod List<OrderItem> NewOpportunityLineItems()
    {
        Contact TestContact = TestObjects.NewContact();
        Order Order = TestObjects.NewOpportunity();
        
        List<PricebookEntry> OrderPricebookEntryList = TestObjects.NewPriceBookEntries();
        Pricebook2 Pricebook = [Select Id, Name From Pricebook2 Where Id = :OrderPriceBookEntryList
                                
                                [0].PriceBook2Id];
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Mailing_Address_Book__c = '000123'; 
        insert a2;
        Order.AccountId = a2.id;
        Order.Pricebook2Id = Pricebook.Id;
        Order.Payment_Terms__c = 'Net 30';
        insert Order;
        
        List<OrderItem> AllLineItems = new List<OrderItem>();
        
        for(PricebookEntry PBE : OrderPricebookEntryList)
        {
            OrderItem LineItem = new OrderItem(
                Quantity      = 1, 
                PriceBookEntryId  = PBE.Id, 
                UnitPrice      = 0.01, 
                OrderId    = Order.Id, 
                Line_Type__c    = 'S - Stock Inventory Item' 
            );
            
            AllLineItems.add(LineItem);
        }
        
        return AllLineItems;
    }
    //=========================
    /*
public static testmethod void TestPMM() {

//create test users use production one...
User awana  = [Select Id,Name from User where Name='Awana Applications' Limit 1];
User guest  = [Select Id,Name from User where Name='Delores Larson' limit 1];
User cguest = [Select Id,Name from User where Name='Jason Pierson' limit 1];
User kguest = [Select Id,Name from User where Name='Jennifer Lainson' limit 1];

RecordType MAreq = [Select Id,Name from RecordType where Name = 'Ministry Advancement'];
//create test account
List<Account> a = new List<Account>(); 
a.add(new Account(
name    = 'Teston',
Primary_Moves_Manager__c = kguest.Id
));
a.add(
new Account(
name    = 'Teston1',
Primary_Moves_Manager__c = guest.Id
));
a.add(
new Account(
name    = 'Teston2',
Primary_Moves_Manager__c = cguest.Id
)); 
insert a;
String testStr= '';

testStr+=(String)a[0].Id+',';
testStr+=(String)a[1].Id+',';
testStr+=(String)a[2].Id+',';

system.debug('<<Account>> '+a);
system.debug('<<ID>> '+testStr);

//create test opportunity   
List<Opportunity> o = new List<Opportunity>();
o.add(new Opportunity(
Name            = 'Test Oppty',
AccountId       = a[0].Id,
CloseDate       = Date.today(),
RecordTypeId        = MAreq.Id,
Interest__c     = 'Adopt a Club',
StageName       = 'In Progress',
Type            = 'Donation',
Region__c       = 'Central America',
OwnerId     = awana.Id  )); 
system.debug('<<OPP0>> '+o[0]);
insert o;
system.debug('<<OPP1>> '+o[0]);
OpportunityAfterInsertManager.handleOpportunityAfterInsert(o);

// Now Let's see what the OPP OTM looks like because there should be one created
List<OpportunityTeamMember> OTMall = [SELECT id, UserId, OPPORTUNITYACCESSLEVEL,OpportunityId
FROM OpportunityTeamMember
WHERE OpportunityId =: o[0].Id
];  

system.debug('<<ACCT>> '+a[0]);
system.debug('<<OPP>> '+o[0]);
system.debug('<<OTM>> '+OTMall);
system.assertEquals(1, OTMall.size() );

//Now update the Account's PMM
a[0].Primary_Moves_Manager__c=cguest.Id;
update a;
PrimaryMovesManager2.handlePrimaryMovesMgr2Updates(testStr);

//We should see an updated Primary Moves Manager value in OTM object
//re-query
OTMall = [SELECT id, UserId, OPPORTUNITYACCESSLEVEL
FROM OpportunityTeamMember
WHERE OpportunityId =: o[0].Id
];  

system.debug('<<OTM>> '+OTMall);
system.assertEquals(1, OTMall.size() );
User testvar = new User();
a[0].Primary_Moves_Manager__c =testvar.Id;

o[0].AccountId= a[0].Primary_Moves_Manager__c;
update a;
testStr=a[0].Id+',';
update o;
PrimaryMovesManager2.handlePrimaryMovesMgr2Updates(testStr);

OTMall = [SELECT id, UserId, OPPORTUNITYACCESSLEVEL
FROM OpportunityTeamMember
WHERE OpportunityId =: o[0].Id
];  

system.debug('<<ACCT>> '+a[0]);
system.debug('<<OPP>> '+o[0]);
system.debug('<<OTM>> '+OTMall);

system.assertEquals(1, OTMall.size() );

// Now delete PMM from Account
a[0].Primary_Moves_Manager__c=null;
update a;
delete OTMALL;
system.debug('<<ACCT>> '+a[0]);
system.debug('<<OPP>> '+o[0]);

a[0].Primary_Moves_Manager__c =testvar.Id;
update a;
testStr=a[0].Id+',';
PrimaryMovesManager2.handlePrimaryMovesMgr2Updates(testStr);
system.debug('<<OPP>> '+o[0]);
OTMall = [SELECT id, UserId, OPPORTUNITYACCESSLEVEL,OpportunityId
FROM OpportunityTeamMember
WHERE OpportunityId =: o[0].Id
];  
system.assertEquals(0, OTMall.size() );
}
*/
    // Test Geo codes for accOunts
    public static testmethod void TestGeoCodes() {
        List<String> accountIds = new List<String>();
        RecordType rc = [Select Id from RecordType where Name = 'US Organization' limit 1];
        List<Account>  someUSOrg = new LIst<Account>();
        someUSOrg.add(new Account (RecordTypeId =rc.Id, 
                                   Name='Test US ORG GEO CODES',
                                   Physical_Street_1__c ='The Landmark @ One Market',
                                   Physical_Street_2__c = 'Suite 300',
                                   Physical_City__c =  'San Francisco',
                                   Physical_State__c =  'CA',
                                   Physical_Zip__c = '94105'
                                  )
                     );
        someUSOrg.add(new Account (RecordTypeId =rc.Id, 
                                   Name='Test US ORG GEO CODES 2',
                                   Physical_Street_1__c ='The Landmark @ Two Market',
                                   Physical_Street_2__c = 'Suite 302',
                                   Physical_City__c =  'San Francisco',
                                   Physical_State__c =  'CA',
                                   Physical_Zip__c = '94105'
                                  )
                     );
        
        insert someUSOrg;           
        someUSOrg[0].Physical_County__c = 'San Francisco';
        update someUSOrg;
        AccountHelper ah = new AccountHelper(someUSOrg[0].Id);
        accountIds.add(JSON.serialize(ah));  
        //Shaik: added code for the callout test coverage 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        GeoLocationCallouts.getLocation(accountIds);
        
    }
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
    
    //Test Sending Emails when a New Affiliation is added to a contact.   
    public static testmethod void TestSendEmailForNewAffiliations() {
        
        //create test users use production one...
        
        RecordType MAreq = [Select Id,Name from RecordType where SObjectType = 'Account' and Name = 'US Organization'];
        //create test account
        List<Account> a = new List<Account>(); 
        
        a.add(new Account(
            name  = 'Teston',
            RecordType = MAreq,
            Type = 'Church'
        ));
        a.add(
            new Account(
                name  = 'Teston1',
                RecordType = MAreq,
                Type ='Homeschool - Single-family'
            ));
        
        insert a;
        
        // Create Contacts.
        List<Contact> c = new List<Contact>();
        c.add(new Contact(FirstName = 'Nelia',LastName= 'Baggins', AccountId=a[0].Id));
        c.add(new Contact(FirstName = 'Frodo',LastName= 'Baggins', AccountId=a[1].Id));  
        insert c;
        
        
        List<npe5__Affiliation__c> affs = new List<npe5__Affiliation__c>();
        //npe5__Affiliation__c aff1 = new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c = a[0].Id, npe5__Contact__c=c[0].Id) ; 
        affs.add(new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c = a[0].Id, npe5__Contact__c=c[0].Id) );
        affs.add(new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c = a[1].Id, npe5__Contact__c=c[1].Id) );
        
        
        affs[0].Awana_Role__c = 'Club Secretary';
        affs[0].Awana_Role_Text__c = '';
        affs[1].Awana_Role__c = 'Commander';
        affs[1].Awana_Role_Text__c = '';
        
        insert affs;
        List<String> cIds = new List<String>();
        for(Contact acontact: c){
            cIds.add(acontact.Id);
            
        }
        /*
delete tstcontact;
delete tstaccount;
*/
        
    }
    // TW 6-3-2014: Add the followng lines later onde Update_Awana_Role_Text tigger has been pushed to production because the other new Triggers for SSO aren't ready for deployment yet
    
    //Testing ContactAfterInsert Trigger
    
    
    //Testing AccountAfterInsert - Account Team Member Trigger
    public static testmethod void TestTeamMember() {
        //User awana  = [Select Id,Name from User where Name='Awana Applications' Limit 1];
        //User guest  = [Select Id,Name from User where Name='Delores Larson' limit 1];
        //User cguest = [Select Id,Name from User where Name='Jason Pierson' limit 1];
        //User kguest = [Select Id,Name from User where Name='Jennifer Lainson' limit 1];
        List<User> userList = [Select Id,Name from User where Profile.Name = 'System Administrator' and isActive = true limit 3];
        List<Account> a = new List<Account>(); 
        a.add(new Account(
            name    = 'Teston',
           // OwnerId = kguest.Id
           OwnerId = userList[2].Id
        ));      
        List<ID> acctIDS = new List<ID>();            
        insert a;
        acctIDS.add(a[0].Id);
        List<AccountTeamMember> ATMs = new List<AccountTeamMember>();
        Test.startTest();
        //.add(new AccountTeamMember(TeamMemberRole='State Director',UserId=a[0].OwnerId,AccountId=a[0].Id));
        ATMS.add(new AccountTeamMember(TeamMemberRole='GMAT Support Team',UserId=userList[1].Id,AccountId=a[0].Id));
        ATMS.add(new AccountTeamMember(TeamMemberRole='State Director',UserId=a[0].OwnerId,AccountId=a[0].Id));    
        insert ATMS;
        
        Test.stopTest();
        System.assertEquals(2,ATMS.size());
        a[0].OwnerId = userList[0].Id;
        update a; 
        /* Commented by Mayur for deployment
        //TeamMemberAccounts.handler(a, acctIDS);
        */
        System.assertEquals(2,ATMS.size()); // Without manual help from Keep Team Member option we will only get the State Director 
        
        
    }
    
    public static testmethod void TestAccountSetup() {
        
        //create test users use production one...
        /*
Contact tstcontact = TestObjects.NewGenericContact();
insert tstcontact;
Account tstaccount = TestObjects.NewGenericAccount();
tstaccount.Type = 'Church';
tstaccount.Status__c = 'Added';
tstaccount.Name = 'TestAffiliation2';
insert tstaccount;
npe5__Affiliation__c newAff = new npe5__Affiliation__c(npe5__Organization__c = tstaccount.Id, npe5__Contact__c = tstcontact.Id, Awana_Role__c='COmmander', Authorized_Purchaser__c = true);
insert newAff;
delete newAff;
npe5__Affiliation__c newAff1 = new npe5__Affiliation__c(npe5__Organization__c = tstaccount.Id, npe5__Contact__c = tstcontact.Id, Church_Role__c='Pastor / Associated Pastor', Authorized_Purchaser__c = true);
insert newAff1;
delete newAff1;
npe5__Affiliation__c newAff2 = new npe5__Affiliation__c(npe5__Organization__c = tstaccount.Id, npe5__Contact__c = tstcontact.Id, Awana_Role__c='COmmander', Authorized_Purchaser__c = true, Historical__c = true);
insert newAff2;
delete newAff2;
npe5__Affiliation__c newAff3 = new npe5__Affiliation__c(npe5__Organization__c = tstaccount.Id, npe5__Contact__c = tstcontact.Id, Awana_Role__c='Club Leader', Authorized_Purchaser__c = true);
insert newAff3;
delete newAff3;
*/
        // Testing for 1x1 Contact and Affiliation creation and UPdate Awana Role Text    
        RecordType MAreq = [Select Id,Name from RecordType where SObjectType = 'Account' and Name = 'US Organization' ];
        //create test account
        List<Account> a = new List<Account>(); 
        
        a.add(new Account(
            name  = 'Teston',
            RecordType = MAreq,
            Type = 'Church'
        ));
        a.add(
            new Account(
                name  = 'Teston1',
                RecordType = MAreq,
                Type ='Homeschool - Single-family'
            ));
        
        insert a;
        
        // Create Contacts.
        List<Contact> cs = new List<Contact>();
        cs.add(new Contact(FirstName = 'Nelia',LastName= 'Baggins', AccountId=a[0].Id));
        cs.add(new Contact(FirstName = 'Frodo',LastName= 'Baggins', AccountId=a[1].Id));  
        insert cs;
        
        List<npe5__Affiliation__c> affs = new List<npe5__Affiliation__c>();
        //npe5__Affiliation__c aff1 = new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c = a[0].Id, npe5__Contact__c=c[0].Id) ; 
        affs.add(new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c = a[0].Id, npe5__Contact__c=cs[0].Id) );
        affs.add(new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c = a[1].Id, npe5__Contact__c=cs[1].Id) );
        
        
        affs[0].Awana_Role__c = 'Club Secretary';
        affs[0].Awana_Role_Text__c = '';
        affs[1].Awana_Role__c = 'Commander';
        affs[1].Awana_Role_Text__c = '';
        
        insert affs;
        List<String> cIds = new List<String>();
        for(Contact cid : cs){
            cIds.add(String.valueOf(cid.Id));
        }
        InsertOne2OneAccountMgr.handler(cIds);
        /*
delete tstaccount;
delete tstcontact;
*/
    }
    
    static testMethod void TestAcquisitionLeadInsert(){
        List<RecordType> Rec = [Select Id, Name from RecordType where Name='Acquisition' Limit 1 ];// Change this type back to 'Aquisition after testing'
        User awanaAppRec = [Select Id from User where Name = 'Awana Applications' limit 1];
        
        //Account acct = [Select Id from Account where RecordType.Name = 'US Organization' and Account_On_Hold__c = false and Status__c = 'Added' limit 1];
        Account acct = [Select Id from Account where RecordType.Name = 'US Organization' and Status__c = 'Added' limit 1];
        
        npe5__Affiliation__c aff = [Select npe5__Contact__c from npe5__Affiliation__c where npe5__Organization__c =: acct.id limit 1]; 
        // Create a lead
        
        Lead alead = new Lead(FirstName= 'Rafael',LastName = 'Palmero',Street= '1614 Millbrook St',City = 'Salem',State = 'VA',MailStatus__c = 'Mail',PostalCode = '24153', AcountID__c = acct.Id,
                              Company = 'Heavenly Chorus BibleSchool',  ContactID__c = aff.npe5__Contact__c,Country = 'UNITED STATES',Status='Agreement Signed',IsConverted = false,Phone='(757) 426-6200',RecordTypeId=Rec[0].Id, OwnerId = awanaAppRec.Id);
        alead.PostalCode = '24152';
        insert alead;
        system.debug('<<Acq LEAD>> '+alead);
    }
    
    
    
    public testmethod static void TestProdWSDL() {
        
        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGenerator());
        
    }
    /*
public static testmethod void NewOne2OneContact()
{

Contact c  = new Contact(FirstName='Doug',LastName='Fairbanks',LeadSource ='Conference');
insert c;
List<String> contactIDs = new List<String>();
contactIDs.add(String.valueOf(c.Id));
InsertOne2OneAccountMgr.handler(contactIDs);
}
*/
    //*********************************************************************************************
    // NewGenericOpportunity: All you have to do is add products separately in your calling routine.
    // The most complete opportunity template for creating test opportunities
    //**********************************************************************************************
    /*
public static testmethod Opportunity NewGenericOpportunity(){
List<Opportunity> Orders = new List<Opportunity>();
List<Id> contactIds = new List<Id>();
List<Id> orgIds = new List<Id>();
User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
RecordType rec = [Select Id from RecordType where SObjectType = 'Opportunity' and Name = 'Orders'];
List<npe5__Affiliation__c> affs = [Select Id,Other_Role__c,npe5__Organization__c,npe5__Status__c, npe5__Contact__c 
FROM npe5__Affiliation__c 
WHERE npe5__Organization__r.RecordType.Name = 'US Organization' and Authorized_Purchaser__c = true limit 1];

for(npe5__Affiliation__c aff : affs){
orgIds.add(aff.npe5__Organization__c);
contactIds.add(aff.npe5__Contact__c);   
}
List<Account> a=[Select Id, Default_Shipping_Address__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry 
from Account WHERE Id =: orgIds];
List<Contact> c=[SELECT Id,FirstName,LastName
FROM Contact WHERE Id =: contactIds];
// Create a new Advocate Order and add 3 Adocate line items
List<Opportunity> testOpp = new List<Opportunity>();
List<OrderEntryServices> rAdvFRT = new List<OrderEntryServices>();
List<PriceBook2> PriceBooks = [SELECT Id, Name FROM PriceBook2 WHERE isActive = true ORDER BY Name ASC];
string PriceBookNames = ''; // PriceBookNames is for an error message to list the available price books
string PriceBookName = 'Catalog Price Book';
PriceBook2 PriceBook = null;
for(PriceBook2 pb : PriceBooks) 
{  
if(PriceBookName != null)
{
if(pb.Name.toLowerCase().contains(PriceBookName.toLowerCase())) { PriceBook = pb; }
}
}

Integer i = 0;
testOpp.add(TestObjects.NewOpportunity());
testOpp[i].Name = testOpp[i].Name+00+i;
testOpp[i].Type = 'Shipping';
testOpp[i].Company__c = 'Awana';
testOpp[i].Order_Type__c = 'SO';
testOpp[i].Shipping_Address__c= a[0].Default_Shipping_Address__c;
testOpp[i].Ship_to_Name__c = c[0].FirstName +' '+ c[0].LastName;
testOpp[i].Ship_to_First_Name__c = c[0].FirstName;
testOpp[i].Ship_to_Last_Name__c = c[0].LastName;
testOpp[i].Shipping_Street__c = String.valueOf(a[0].ShippingStreet);
testOpp[i].Shipping_City__c = a[0].ShippingCity;
testOpp[i].Shipping_State__c  =   a[0].ShippingState; 
testOpp[i].Shipping_Zip_Code__c = a[0].ShippingPostalCode;
testOpp[i].Shipping_Country__c =  'UNITED STATES';
testOpp[i].ChargentSFA__Billing_First__c = c[0].FirstName;
testOpp[i].ChargentSFA__Billing_Last__c =  c[0].LastName;  
testOpp[i].ChargentSFA__Billing_Email__c = 'somebodysorders@mailinator.com';  
testOpp[i].OwnerId = ouser.Id;
testOpp[i].Payment_Terms__c = 'Net 30';
testOpp[i].Shipping_Type__c = 'Priority Mail'; 
testOpp[i].Shipping_Code__c = 'PRI';              
testOpp[i].Shipping_Carrier__c = 'POST';
testOpp[i].Notes__c ='Tes Order for faux client';
testOpp[i].Payment_Terms__c = 'Net30';
system.debug('PriceBook: '+PriceBook);
testOpp[i].Pricebook2Id = PriceBook.Id;
system.debug('<< BEFORE ORDER ITEMS >> '+testOpp);
testOpp[i].Pricebook2Id = PriceBook.Id;
return testOpp[i];
} 

*/  
    
    public static testmethod Church_Registration__c NewChurchRegistration()
    {
        Church_Registration__c RegistrationSettings = new Church_Registration__c();
        RegistrationSettings.Name = 'RegistrationSettings 1';
        RegistrationSettings.CurrencyIsoCode = 'USD';
        RegistrationSettings.Default_Term_Business_Unit__c = 'Internal';
        RegistrationSettings.Default_Term_Business__c = 'Net 30';
        RegistrationSettings.Default_Term_Canada_Church__c = 'Net 30';
        RegistrationSettings.Default_Term_Employee__c ='Credit Card';
        RegistrationSettings.Default_Term_Individual__c = 'Credit Card';
        RegistrationSettings.Default_Term_International_Church__c = 'Net 30';
        RegistrationSettings.Default_Term_KM_Church__c = 'Credit Card';
        RegistrationSettings.Default_Term_Missionary__c = 'Internal';
        RegistrationSettings.Default_Term_Non_Traditional__c = 'Credit Card';
        RegistrationSettings.Default_Term_US_Church__c= 'Net 30';
        RegistrationSettings.Enable_Trigger_for_Canada__c=true;
        RegistrationSettings.Enable_Trigger_for_International__c=true;
        RegistrationSettings.Enable_Trigger_for_National__c=true;
        RegistrationSettings.Enable_Trigger_for_Person_Accounts__c=true;
        RegistrationSettings.Execute_Status__c='Added';
        RegistrationSettings.Last_Customer_Number__c='5191254';
        insert RegistrationSettings;
        
        return RegistrationSettings;
    }
    /* Commented by Mayur for deployment 12/06/17
    // Create subscription for Account
    public static testmethod Subscription__c NewSubscription()
    {
        Account a = NewGenericAccount();
        a.name = 'Subscription Account';
        insert a;
        Subscription__c sub = new Subscription__c();
        sub.name = 'Test Subscription';
        sub.Account__c = a.id;
        return sub;
        
    }
    Mayur comment Ends*/
    public static testmethod npe5__Affiliation__c NewAffiliation()
    {
        Account a = NewGenericAccount();
        a.name = 'Subscription Account';
        a.Mailing_Address_Book__c = 'US'+Math.roundToLong(Math.random()*100000);//'000163'; 
        insert a;
        Contact TestAffContact = NewGenericContact();
        TestAffContact.AccountId=a.Id;
        insert TestAffContact;
        npe5__Affiliation__c aff = new npe5__Affiliation__c();
        aff.npe5__Organization__c = a.id;
        aff.npe5__Contact__c = TestAffContact.id;
        return aff;
        
    }
}// cLASS