/***************************************************************************************************************************************************************************************
Programmer: Matthew Keefe
Company:    Awana
Contact:    mattk@awana.org
Project:    Testing Order Entry in Salesforce
Updated:    10/16/2012 - Removed testing calls to AddSubscription() method in Order Entry
Updated:    07/30/2013 -  Added Call to Submit Order to Test Opportunity Source field.
Updated:    08/31/2013 - Added Price Discount and Promo Code as parameters for AddProduct in OE
Updated:    07/08/2014 - Added THE 4TH argument  - Organization Id  - for GetPriceBookByCompany. Substituted individual rec types for list of rec types of this method call out.
Update:     07/21/2014 - Changed parameter lists for CalculateFrieghtOnOpportunity.
Updated:    07/22/2014 - <FRT RESCONTRUCT> Added CalcultaeFrieghtByWeight(), ProcessLIneItems(), and added paramteres for CalcultaeFreightOnOpportunity
Updated:    07/22/2014 - <FRT RECONTSRUCT> commented out obsolete methods GetPriceBook(), GetOrderedPriceBook(), GetPriceBookByAccount(), SubmitApproval()
Updated:    09/12/2014 - <FRT RECONTSRUCT> Enhanced several test cases to get better coverage 
Updated:  04/20/2015  - <MOZO> Adedd new test case for Mozo Upgrade.
Updated:  05/13/2015  - <MOZO> Adedd two new parameters for GetUpgradeRate: Promo Code and Discount.
Updated:   03-09-2018 - <ASP 874> Added test SendDownloadbles 
Updated:    09-18-2018 - <ASP-1340> - Removed issue with MENA access line 771 and also commented out anything having to do with Security Code.
**************************************************************************************************************************************************************************************/ 
@isTest (seeAllData = True)
global class OrderEntryServicesTest
{   
    public static testmethod void TestResult()
    {       
        OrderEntryServices.Result r;
        r = new OrderEntryServices.Result();
        r = new OrderEntryServices.Result(false);
        r = new OrderEntryServices.Result(false,'blank');
        r = new OrderEntryServices.Result(false,'blank','blank');
        r = new OrderEntryServices.Result(false,'blank',1.01);
        r = new OrderEntryServices.Result(false,'blank',new List<String>());
        r = new OrderEntryServices.Result(false,'blank', new Account(Name='Test Account 1'));
        r = new OrderEntryServices.Result(false,'blank', new List<Account>());
        r = new OrderEntryServices.Result(false,'blank', new List<decimal>());
        r = new OrderEntryServices.Result(true,'blank','blank',new Account(Name='Test Account 1'));
        r = new OrderEntryServices.Result(true,'blank',1.01,new Account(Name='Test Account 2'));
        r = new OrderEntryServices.Result(true,'blank','blank',1.01,new Account(Name='Test Account 3'));
    }
    public static testmethod void TestPOrderTriggerRan(){
        OrderEntryServices.hasProcessOrderTriggerRan();
    }
    
    public static testmethod void TestNextOrderNumber()
    {
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Contact c = TestObjects.NewGenericContact();
        c.accountid = a.id;
        insert c;
        npe5__Affiliation__c aff = new npe5__Affiliation__c( npe5__Organization__c  = a.Id,npe5__Contact__c = c.Id);
        
        insert aff;
        // test generic opportunity for random account
        OrderEntryServices.Result result = OrderEntryServices.GetNextOrderNumber('O',aff.npe5__Organization__r.Mailing_Address_Book__c); 
        // test null prefix
        result = OrderEntryServices.GetNextOrderNumber(null,a.Mailing_Address_Book__c); 
        
        // test null address book number / customer number
        result = OrderEntryServices.GetNextOrderNumber('O',null); 
        result = OrderEntryServices.GetNextOrderNumber('O','#$@%'); 
        // test an Address which is too long to test catch blocks?
        String tooLong = String.valueOf(aff.npe5__Organization__c);
        tooLong = tooLong + tooLong;
        result = OrderEntryServices.GetNextOrderNumber('O',tooLong); 
        String NextOrderNumber = OrderENtryServices.NextOrderNumber('O',null);
        
        // test account salesforce id
        result = OrderEntryServices.GetNextOrderNumberByAccountId('O',aff.npe5__Organization__c);
        result = OrderEntryServices.GetNextOrderNumberByAccountId('O',a.Id);
        // test account salesforce id with null id
        result = OrderEntryServices.GetNextOrderNumberByAccountId('O',null);
        //system.debug('**** TEST 1 ****');
        //Create Chargent Order
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Country__c = 'United States';
        insert cOrder;
        
        Order o1 = new Order(name='O-'+aff.npe5__Organization__r.Mailing_Address_Book__c+'-0',Status='Order Open', effectiveDate=Date.Today(), AccountId=aff.npe5__Organization__c,Chargent_Order__c = cOrder.Id); 
        insert o1;
        Order o3 = new Order(name='O-'+aff.npe5__Organization__r.Mailing_Address_Book__c+'-1',Status='Order Open',effectiveDate=Date.Today(), AccountId=aff.npe5__Organization__c,Chargent_Order__c = cOrder.Id); 
        insert o3;
        result = OrderEntryServices.GetNextOrderNumber('O',aff.npe5__Organization__r.Mailing_Address_Book__c); 
        result = OrderEntryServices.GetNextOrderNumber('O',a.Mailing_Address_Book__c); 
        system.debug(result); 
        delete o1; delete o3;
        Account a2 = [Select Id,Name,Mailing_Address_Book__c, a.RecordType.Name From Account a where a.RecordType.Name = 'Individual' limit 1];
        // Now do 1-1 Accounts 
        result = OrderEntryServices.GetNextOrderNumber('O',a2.Mailing_Address_Book__c); 
        Order o2 = new Order(name='O-'+a2.Mailing_Address_Book__c+'-0',Status='Order Open',effectiveDate=Date.Today(), AccountId=a2.Id,Chargent_Order__c = cOrder.Id); 
        insert o2;
        Order o4 = new Order(name='O-'+a2.Mailing_Address_Book__c+'-1',Status='Order Open',effectiveDate=Date.Today(), AccountId=a2.Id,Chargent_Order__c = cOrder.Id); 
        insert o4;
        result = OrderEntryServices.GetNextOrderNumber('O',a2.Mailing_Address_Book__c); 
        delete o2; delete o4;
        // test non-numeric customer ID.
        result = OrderEntryServices.GetNextOrderNumber('O',' '); 
    }
    
    public static testmethod void TestGetAddressCountries()
    {
        
        OrderEntryServices.GetAddressCountries();
    }
    public static testmethod void TestCalculateOrderEntryStage(){
     //   try{
        Test.startTest();
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Id priceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbe = [select id, name, CurrencyIsoCode from PriceBookEntry where Pricebook2id =:priceBookId];
        Ord.AccountId  = a.Id;
        Ord.Pricebook2Id = pricebookId;
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        Ord.CurrencyIsoCode = 'CAD';
        system.debug('##ORDER'+Ord);
        insert Ord;
        Contact c = TestObjects.FullContact();
        insert c;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
        
        OrderEntryServices.AddProduct(Ord.Id,'99001',10,10,0,'','S - Stock Inventory Item');
        //OrderEntryServices.AddProduct(O.Id,'43490',1,1,0,'','frieght');
        List<String> orderItemIds = new List<String>();
        for(OrderItem oItem: [SELECT ID FROM OrderItem WHERE OrderId=:Ord.id]){
            orderItemIds.add(oItem.id);
        } 
        
        system.debug('<< ORDER ITEMS>> '+orderItemIds);
        OrderEntryServices.UpdateCreditCard(Ord.Id, 'Visa', 'Test Contact', '4111111111111111', '12', '2020', '123');
        OrderEntryServices.AuthorizeCreditCard(Ord.Id);
        OrderEntryServices.CalculateOrderEntryStage(Ord.Id);
       
        
        // Verify Stage With Sales Credit at Stage < 3 (Just before FRT)
        OrderEntryServices.Result R = OrderEntryServices.GetNextOrderNumber('C',a.Mailing_Address_Book__c);
        String NextOName = R.StringOutput;
        
        Ord = new Order(name=NextOName,Status='Order Open',effectiveDate=Date.Today(), AccountId=a.Id, Company__c = 'Awana', Payment_Terms__c = 'Credit Card'); 
        Ord.Payment_Terms__c = 'sales credit';
        Ord.AccountId = a.Id;
        upsert Ord;
        OrderEntryServices.CalculateOrderEntryStage(Ord.Id);
            
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Country__c = 'United States';
        insert cOrder;
        ChargentOrders__Transaction__c ctOrder = [Select Id,ChargentOrders__Order__c,c.ChargentOrders__Type__c, c.ChargentOrders__Response_Status__c, c.ChargentOrders__Response_Message__c,c.ChargentOrders__Amount__c From ChargentOrders__Transaction__c c limit 1];
        ctOrder.ChargentOrders__Order__c = Ord.Id;
        ctOrder.ChargentOrders__Response_Message__c = 'Approved';
        ctOrder.ChargentOrders__Type__c = 'Authorization';
        ctOrder.ChargentOrders__Response_Status__c='OK';
        ctOrder.ChargentOrders__Amount__c = 500.00;
       // upsert ctOrder;
        Ord.Chargent_Order__c = cOrder.Id;
        ord.Payment_Terms__c='credit card';
        upsert Ord;
            List<ChargentOrders__Transaction__c> tx =OrderEntryServices.GetTransactions(ord.chargent_Order__c);
        
            system.debug(' LINE ITEM IDs OrderEntryServices.GetTransactions(ord.chargent_Order__c);'+orderItemIds);
            update Ord; 
            system.debug('<< ORDER TOTAL: AddProduct >> '+Ord.TotalAmount);
            OrderEntryServices.CalculateOrderEntryStage(ctOrder.ChargentOrders__Order__c);
            system.debug('<< CHARGENT ORDERS >> '+ctOrder.ChargentOrders__Order__c);
            ctOrder.ChargentOrders__Amount__c = 0;
            //upsert ctOrder;
            OrderEntryServices.CalculateOrderEntryStage(ctOrder.ChargentOrders__Order__c);
       Test.stopTest();
    }
     public static testmethod void TestValidateOrder()
    {
        Contact TestContact = TestObjects.NewGenericContact();
        order Ord = TestObjects.FullOrder();
        
        List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Registration_Number__c='123';
        a2.Mailing_Address_Book__c='000123';
        insert a2;
        Ord.AccountId = a2.id;
        Ord.Pricebook2Id = OrderPriceBookEntryList[0].PriceBook2Id;
        Ord.Payment_Terms__c = 'Net 30';
        
        upsert Ord;
        
        // test valid billing and shipping adddresses
        Ord.Shipping_Street__c = 'The Landmark @ One Market\nSuite 300';
        Ord.Shipping_City__c = 'San Francisco';
        Ord.Shipping_State__c = 'CA';
        Ord.Shipping_Zip_Code__c = '94105';
        Ord.Shipping_Country__c = 'UNITED STATES';
        OrderEntryServices.ValidateOrderAddress(Ord);
        // test null Billng Country
        OrderEntryServices.ValidateOrderAddress(Ord);
        
        // test null shipping address
        
        Ord.Shipping_Country__c = null;
        OrderEntryServices.ValidateOrderAddress(Ord);
        
        // test blank billing address
        OrderEntryServices.ValidateOrderAddress(Ord);
        
        // test blank shipping address
        Ord.Shipping_Street__c = '';
        Ord.Shipping_City__c = '';
        Ord.Shipping_State__c = '';
        Ord.Shipping_Zip_Code__c = '';
        Ord.Shipping_Country__c = '';
        OrderEntryServices.ValidateOrderAddress(Ord);
        // test blank shipping address
        Ord.Shipping_Street__c = null;
        Ord.Shipping_Country__c = 'united states';
        OrderEntryServices.ValidateOrderAddress(Ord); 
        
        Ord.Shipping_Street__c = null;
        Ord.Shipping_City__c = 'Chicago';
        Ord.Shipping_State__c = 'IL';
        Ord.Shipping_Zip_Code__c = '60628';
        Ord.Shipping_Country__c = 'Canada';
        OrderEntryServices.ValidateOrderAddress(Ord);
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Address__c = 'The Landmark @ One Market\nSuite 300';
        cOrder.ChargentOrders__Billing_City__c = 'San Francisco';
        cOrder.ChargentOrders__Billing_State_Province__c = 'CA';
        cOrder.ChargentOrders__Billing_Zip_Postal__c = '94105';
        cOrder.ChargentOrders__Billing_Country__c = 'UNITED STATES';
        insert cOrder;
       //  try{
            Ord.Chargent_Order__c = cOrder.Id;
            //Ord.Chargent_Order__r.ChargentOrders__Billing_Address__c = 'UNITED STATES';
            //Validate the Order .
            OrderEntryServices.ValidateOrderAddress(Ord);
      //   }catch(NullPointerException ne){
      //       system.debug(ne.getMessage());
       //  }
    }
    /* code cleanup NEW-92
     public static testmethod void TestMapShippingTableTypeToShipCode(){
      //  try{
        List<RecordType> rc = [Select Id from RecordType where name = 'US Organization' limit 1]; 
        OrderEntryServices.Result r = new OrderEntryServices.Result();
        Account a = TestObjects.FullAccount();
        //a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        a.ShippingStreet =  '32364 Lodge Rd';
        a.ShippingCity = 'Tollhouse';
        a.ShippingPostalCode =  '93667';
        a.ShippingState = 'CA';
        a.ShippingCountry = 'UNITED STATES'; 
        a.Shipping_County__c =  'Fresno';
  
        a.Physical_City__c = 'Tollhouse';
        a.PhysicalCountry__c = 'UNITED STATES';
        a.Physical_State__c = 'CA';
        a.Physical_Street_1__c = '32364 Lodge Rd';
        a.Physical_Zip__c = '93667';
        a.Physical_County__c = 'Fresno';
        a.Default_Terms__c = 'NET30';
        a.RecordTypeId=rc[0].Id;
        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__r.RecordType.Name = 'US Organization' and 
                                   npe5__Organization__r.Mailing_Address_Book__c <> null  and npe5__Organization__r.Account_On_Hold__c <> true 
                                   and Authorized_Purchaser__c = true limit 1];
        Account a2  =  [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where  a.Id =: Aff.npe5__Organization__c limit 1] ; 
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a2.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< anOrder >> '+someOrder);
        
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
      
        system.debug('<<ORDER>> '+someOrder); 
        someOrder.Shipping_Street__c  = a2.ShippingStreet;
        someOrder.Shipping_City__c = a2.ShippingCity;
        someOrder.Shipping_State__c = a2.ShippingState;
        someOrder.Shipping_Zip_Code__c = a2.ShippingPostalCode;
        someOrder.Shipping_Country__c = 'United States';
        update someOrder;
        Test.startTest();
        someOrder.Shipping_Type__c = 'Standard';
        someOrder.Shipping_Carrier__c = 'Rate Shop';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'Standard';
        someOrder.Shipping_Carrier__c =  'UPS';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'Pickup (Penny Ln)';
        someOrder.Shipping_Carrier__c = 'Pickup';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'Pickup (Bode Rd)';
        someOrder.Shipping_Carrier__c = 'Pickup';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'Two Day';
        someOrder.Shipping_Carrier__c = 'UPS';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'One Day';
        someOrder.Shipping_Carrier__c = 'UPS';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'One Day';
        someOrder.Shipping_Carrier__c = 'Rate Shop';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
         someOrder.Shipping_Type__c = 'Priority International';
        someOrder.Shipping_Carrier__c = 'Rate Shop';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'Two Day';
        someOrder.Shipping_Carrier__c = 'Rate Shop';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'One Day';
        someOrder.Shipping_Carrier__c = 'UPI';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        someOrder.Shipping_Type__c = 'Standard';
        someOrder.Shipping_Carrier__c = 'USPS Postal';
        OrderEntryServices.MapShippingTableTypeToShipCode(someOrder);
        Test.stopTest();
     //    }catch(NullPointerException ne){
     //       system.debug('Null Pointer Exception - someorder'+ne.getMessage());
      //  }   
    }
    code cleanup */
    
    /* code cleanup NEW-92
     public static testmethod void TestMapShippingCodeToShippingType(){
      //  try{
        List<RecordType> rc = [Select Id from RecordType where name = 'US Organization' limit 1]; 
        OrderEntryServices.Result r = new OrderEntryServices.Result();
        Account a = TestObjects.FullAccount();
       // a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__r.RecordType.Name = 'US Organization' and 
                                   npe5__Organization__r.Mailing_Address_Book__c <> null  and npe5__Organization__r.Account_On_Hold__c <> true 
                                   and Authorized_Purchaser__c = true limit 1];
        Account a2  =  [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where  a.Id =: Aff.npe5__Organization__c limit 1] ; 
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a2.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< anOrder >> '+someOrder);
        
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
      
        system.debug('<<ORDER>> '+someOrder); 
        someOrder.Shipping_Street__c  = a2.ShippingStreet;
        someOrder.Shipping_City__c = a2.ShippingCity;
        someOrder.Shipping_State__c = a2.ShippingState;
        someOrder.Shipping_Zip_Code__c = a2.ShippingPostalCode;
        someOrder.Shipping_Country__c = 'United States';
        someOrder.Payment_Terms__c = 'Net30';
        someOrder.Shipping_Code__c = 'U2D';
        someOrder.Shipping_Carrier__c = 'UPS';
        update someOrder;
        Test.startTest();
        String OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'UPS 2nd Day Air');
        someOrder.Shipping_Code__c = 'UPG';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'UPS Ground');   
        someOrder.Shipping_Code__c = 'U3D';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'UPS 3 Day Select');   
        someOrder.Shipping_Code__c = 'HPIC';
        someOrder.Shipping_Carrier__c ='Pickup';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'Pickup (Bode Rd)');  
        someOrder.Shipping_Code__c = 'PIC';
        someOrder.Shipping_Carrier__c ='Pickup';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'Pickup (Penny Ln)'); 
        someOrder.Shipping_Code__c = 'UNS';
        someOrder.Shipping_Carrier__c ='UPS';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'UPS Next Day Air Saver'); 
        someOrder.Shipping_Code__c = 'UND';
        someOrder.Shipping_Carrier__c ='UPS';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'UPS Next Day Air'); 
        someOrder.Shipping_Code__c = 'PRI';
        someOrder.Shipping_Carrier__c ='POST';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'Priority Mail'); 
        someOrder.Shipping_Code__c = '1CL';
        someOrder.Shipping_Carrier__c ='POST';
        OType = OrderEntryServices.MapShippingCodeToShippingType1(someOrder,someOrder.Shipping_Code__c);
        system.assertEquals(OType, 'Standard Post'); 
        Test.stopTest();   
     //   }catch(NullPointerException ne){
    //        system.debug('Null Pointer Exception for someOrder variable '+ne);
    //    }
    }
    code cleanup */
    public static testmethod void TestCreateOrder(){
     //   try{
        OrderEntryServices.Result result;
        List<RecordType> rc = [Select Id,Name from RecordType where name = 'US Organization' limit 1];  
        List<RecordType> rch = [Select Id,Name from RecordType where name = 'Household Account' limit 1];  
        // test bad contact
        Account a = TestObjects.FullAccount();
        a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        a.ShippingStreet =  '32364 Lodge Rd';
        a.ShippingCity = 'Tollhouse';
        a.ShippingPostalCode =  '93667';
        a.ShippingState = 'CA';
        a.ShippingCountry = 'UNITED STATES'; 
        a.Shipping_County__c =  'Fresno';
  
        a.Physical_City__c = 'Tollhouse';
        a.PhysicalCountry__c = 'UNITED STATES';
        a.Physical_State__c = 'CA';
        a.Physical_Street_1__c = '32364 Lodge Rd';
        a.Physical_Zip__c = '93667';
        a.Physical_County__c = 'Fresno';
        a.Default_Terms__c = 'NET30'; 
        a.RecordTypeId=rc[0].Id;
        insert a;  
        Contact c = TestObjects.NewGenericContact();
        c.AccountId=a.Id;
        insert c;
        a.Applicant__c = c.Id;
        update a; 
        //Test Bas Contact
         //for matching error
         
        OrderEntryServices.Result r = OrderEntryServices.CreateOrder('abc123574838627','Catalog','Order',null,'Awana'); system.debug(result);
        System.assert(r.Message.contains('The ContactId provided could not be found'));
        //for Mailing address book blank check
        a.Mailing_Address_Book__c = null;
        update a;
         r = OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book','Order',System.Today(),'Awana');
        System.assert(r.Message.contains('does not have a valid Customer Number'));
        //for Account_on_Hold__c=true check
        a.Mailing_Address_Book__c = '000123';
        a.Account_on_Hold__c=true;
        update a;
         r = OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book','Order',System.Today(),'Awana');
        System.assert(r.Message.contains('is on hold and is currently not allowed'));
        //invalid pricebook
        a.Account_on_Hold__c=false;
        update a;
        r = OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book2','Order',System.Today(),'Awana');
        System.assert(r.Message.contains('please provide a valid PriceBookName'));
        //invalid ordertype
        r = OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book',null,System.Today(),'Awana');
        System.assert(r.Message.contains('OrderType is required'));
        // Order is credit type and date is blank
        r = OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book','credit',null,'Awana');
        System.assert(r.Message.contains('OriginalOrderDate is required for Credit OrderType'));
        a.BillingCountry = '';
        a.BillingStreet  = '';
        a.BillingCity = ' ';
        a.BillingPostalCode = ' ';
        a.BillingState = '';
        a.Undeliverable_Mailing__c = true;
        a.Account_on_Hold__c=false;
        update a;
        r =OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book','credit',Date.Today(),'Awana');  
        a.BillingCountry = 'Canada';
        a.BillingStreet  = ''; 
        a.Undeliverable_Mailing__c = true;
        update a;
    r =OrderEntryServices.CreateOrder(c.Id,'Canada Pricebook','credit',Date.Today(),'Awana');  
        a.BillingStreet  = '2667 Bur Oak Ave'; 
        a.Undeliverable_Mailing__c = false;
        update a;
    r =OrderEntryServices.CreateOrder(c.Id,'Canada Pricebook','credit',Date.Today(),'Awana');  
        r =OrderEntryServices.CreateOrder(c.Id,'Canada Pricebook','LOL',Date.Today(),'Awana'); 
        // Test Valid United States Billing info
        a.BillingCountry = 'United States';
        a.BillingStreet = '323 W 101 Place';
        a.Undeliverable_Mailing__c = false;
        a.BillingCity = 'Chicago';
        a.BillingPostalCode = '60628-1490';
        a.BillingState = 'IL';
        update a;
        
        r =OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book','Order',Date.Today(),'Awana');
        // test Household account
        a.RecordTypeId = rch[0].Id;
        update a;
        r =OrderEntryServices.CreateOrder(c.Id,'Catalog Price Book','Order',Date.Today(),'Awana');
        //**************
        // turn off church registration / customer number generator
        List<Church_Registration__c> RegistrationSettings = [Select Id, Enable_Trigger_For_Canada__c, Enable_Trigger_For_International__c, 
                                                             Enable_Trigger_For_National__c, Enable_Trigger_For_Person_Accounts__c From Church_Registration__c];
        
        // disable registration settings
        if(RegistrationSettings.size() > 0)
        {
            for(Church_Registration__c settings : RegistrationSettings) 
            {
                settings.Enable_Trigger_For_Canada__c = false;
                settings.Enable_Trigger_For_International__c = false;
                settings.Enable_Trigger_For_National__c = false;
                settings.Enable_Trigger_For_Person_Accounts__c = false;
            }
            
            system.debug('<< SETTINGS '+RegistrationSettings+' >>');
            // update RegistrationSettings;
            
        }
        
         // re-enable registration settings
        if(RegistrationSettings.size() > 0)
        {
            for(Church_Registration__c settings : RegistrationSettings) 
            {
                settings.Enable_Trigger_For_Canada__c = true;
                settings.Enable_Trigger_For_International__c = true;
                settings.Enable_Trigger_For_National__c = true;
                settings.Enable_Trigger_For_Person_Accounts__c = true;
            }
            
            //  update RegistrationSettings;
        }
     //   }catch(NullPointerException ne){
    //        system.debug(ne.getMessage());
     //   }
            
       
    }
    /* code cleanup NEW-92
    public static testmethod void TestProcessLineItems(){
     //   try{
         Account a = TestObjects.FullAccount();
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__r.RecordType.Name = 'US Organization' and 
                                   npe5__Organization__r.Mailing_Address_Book__c <> null  and npe5__Organization__r.Account_On_Hold__c <> true 
                                   and Authorized_Purchaser__c = true limit 1];
        Account a2  =  [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where  a.Id =: Aff.npe5__Organization__c limit 1] ; 
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a2.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< anOrder >> '+someOrder);       // test valid billing and shipping adddresses
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
  
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Address__c = 'The Landmark @ One Market\nSuite 300';
        cOrder.ChargentOrders__Billing_City__c = 'San Francisco';
        cOrder.ChargentOrders__Billing_State_Province__c = 'CA';
        cOrder.ChargentOrders__Billing_Zip_Postal__c = '94105';
        cOrder.ChargentOrders__Billing_Country__c = 'UNITED STATES';
        cOrder.ChargentOrders__Shipping_Country__c = 'UNITED STATES';
        insert cOrder;
        someOrder.AccountId = a2.Id;
        someOrder.Chargent_Order__c = cOrder.id;
        someOrder.Direct_Ship_Flag__c = true;
        someOrder.Shipping_Country__c = 'UNITED STATES';
        someOrder.Payment_Terms__c = 'To Be Billed';
        update someOrder; 
        Test.startTest();
        OrderEntryServices.AddProduct(someOrder.Id,'79345',2,7.99,0,'1.00','S - Stock Inventory Item');
        OrderEntryServices.AddProduct(someOrder.Id,'43490',1,7.99,0,'','F - Freight'); 
        OrderEntryServices.AddProduct(someOrder.Id,'57779',1,.99,0,'','T - Text Line');
        someOrder.Payment_Terms__c = 'Net 30';
        update someOrder; 
        OrderEntryServices.ProccessLineItems1(someOrder.Id,true);
        Account a3 = [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where Mailing_Address_Book__c = '4' limit 1];     
        someOrder.AccountId = a3.Id;
        someOrder.Payment_Terms__c = 'To Be Billed';
        someOrder.Shipping_Country__c = 'Canada';
        update someOrder; 
        OrderEntryServices.ProccessLineItems1(someOrder.Id,false);
        Test.stopTest();
        // Now add order Line Items manually to avoid SOQL limits   
      
       
    }
    code cleanup */
    
    /* code cleanup NEW-92
    public static testmethod void TestCalculateFreightByWeight()
    {
     //   try{
        OrderEntryServices.Result r = new OrderEntryServices.Result();
        Account a = TestObjects.FullAccount();
     //   a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__r.RecordType.Name = 'US Organization' and 
                                   npe5__Organization__r.Mailing_Address_Book__c <> null  and npe5__Organization__r.Account_On_Hold__c <> true 
                                   and Authorized_Purchaser__c = true limit 1];
        Account a2  =  [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where  a.Id =: Aff.npe5__Organization__c limit 1] ; 
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a2.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< anOrder >> '+someOrder);
        
       
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
        
        system.debug('<<ORDER>> '+someOrder); 
        someOrder.Shipping_Street__c  = a2.ShippingStreet;
        someOrder.Shipping_City__c = a2.ShippingCity;
        someOrder.Shipping_State__c = a2.ShippingState;
        someOrder.Shipping_Zip_Code__c = a2.ShippingPostalCode;
        someOrder.Shipping_Country__c = 'United States';
        someOrder.Payment_terms__c = 'Sales Credit';
        update someOrder;
        OrderEntryServices.SaveOrder(someOrder,'test@test.com','123456789');
        OrderEntryServices.CalculateFreightByWeight(someOrder.Id,'R');
        someOrder.Payment_terms__c = 'Credit Card';
        OrderEntryServices.AddProduct(someOrder.Id,'79345',2,7.99,0,'','S - Stock Inventory Item');
        OrderEntryServices.AddProduct(someOrder.Id,'57779',2,1.99,0,'','T - Text Line'); 
        OrderEntryServices.SaveOrder(someOrder,'test@test.com','123456789');    
       // OrderEntryServices.SaveOrder(someOrder,'test@test.com','123456789');
        Test.startTest();
        OrderEntryServices.CalculateFreightByWeight(someOrder.Id,'R');
            
        Test.setMock(WebServiceMock.class, new SSuiteWebServiceMockImpl());  
        Account dummyAcct =new Account(
        Name='Dev Church of the Sandbox Test',
        Status__c = 'Added',
        Date_Inactive__c = Date.Today().addYears(1),
        ShippingStreet = '1275 Stuart Rd NE',
        ShippingCity = 'Cleveland,',
        ShippingPostalCode = '37312',
        ShippingState = 'TN',
        ShippingCountry = 'UNITED STATES',
        BillingCountry = 'UNITED STATES'
            ); 
        wwwApprouterComConnectorsWsdl TestWSDL = new wwwApprouterComConnectorsWsdl();
        wwwApprouterComConnectorsWsdl.Provide_ServicePort sSuiteStub = new wwwApprouterComConnectorsWsdl.Provide_ServicePort();
        sSuiteStub.timeout_x = 60000; 
        system.debug(sSuiteStub.endpoint_x);
        
        // Call the method that invokes a callout   but add an acocunt with these parameter values:
        TestSendSuiteWSDL da = new TestSendSuiteWSDL();
        wwwApprouterComConnectorsResponse11.SSResponse_element output = sSuiteStub.Provide_Service(10.75,dummyAcct.ShippingStreet,dummyAcct.ShippingCity,dummyAcct.ShippingState,dummyAcct.ShippingPostalCode,'UNITED STATES','R', dummyAcct.Mailing_Address_Book__c,'SFDC',false); 
        Test.stopTest();
    
    }
    */
    
    public static testmethod void TestMENABackOrders(){
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test Church';
        a.BillingCountry ='OMAN';
        a.Account_On_Hold__c = false;   
        RecordType IntChurchRecType = [Select Id from RecordType where Name = 'International Church' limit 1];
        a.recordtypeId = IntChurchRecType.id;
        a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        insert a;   
       Account a2 = [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where a.RecordType.Name = 'International Church' and Mailing_Address_Book__c <> null  
                      and a.PhysicalCountry__c ='QATAR' limit 1];
        system.debug('<<Accounts>> '+a2);
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        //aff.npe5__Contact__c = TestAffContact.id;
        npe5__Affiliation__c Aff =[Select npe5__Contact__c from npe5__Affiliation__c where npe5__Organization__c =: a.Id and Authorized_Purchaser__c = true limit 1];
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< anOrder >> '+someOrder);       // test valid billing and shipping adddresses
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
    
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Country__c = 'United States';
        //cOrder.ChargentOrders__Billing_City__c= 'Ruwi';
        cOrder.ChargentOrders__Shipping_Country__c= 'United States';
        
        insert cOrder;
        
        someOrder.Chargent_Order__c = cOrder.Id;
        someOrder.Payment_Terms__c = 'PrePay';
        upsert someOrder; 
        OrderEntryServices.AddProduct(someOrder.Id,'79345',1,34.99,0,'','S - Stock Inventory Item');
        OrderEntryServices.AddProduct(someOrder.Id,'43490',1,5.75,0,'','F - Freight'); 
        
        OrderEntryServices.MENABackOrders(someOrder.Id);
    }
    
    public static testmethod void TestCalculateTaxOnOpportunity(){
   //   try{
        OrderEntryServices.Result r = new OrderEntryServices.Result();
        Account a = TestObjects.FullAccount();
     //   a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__r.RecordType.Name = 'US Organization' and 
                                   npe5__Organization__r.Mailing_Address_Book__c <> null  and npe5__Organization__r.Account_On_Hold__c <> true 
                                   and Authorized_Purchaser__c = true limit 1];
        Account a1  =  [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where  a.Id =: Aff.npe5__Organization__c limit 1] ; 
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a1.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< anOrder >> '+someOrder);
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
        
        system.debug('<<ORDER>> '+someOrder); 
        someOrder.Shipping_Street__c  = a1.ShippingStreet;
        someOrder.Shipping_City__c = a1.ShippingCity;
        someOrder.Shipping_State__c = a1.ShippingState;
        someOrder.Shipping_Zip_Code__c = a1.ShippingPostalCode;
        someOrder.Shipping_Country__c = 'United States';
        someOrder.Payment_terms__c = 'Sales Credit';
        update someOrder;
        OrderEntryServices.SaveOrder(someOrder,'test@test.com','123456789');
        //OrderEntryServices.CalculateFreightByWeight(someOrder.Id,'R');
        someOrder.Payment_terms__c = 'Credit Card';
        OrderEntryServices.AddProduct(someOrder.Id,'79345',2,7.99,0,'','S - Stock Inventory Item'); 
        OrderEntryServices.AddProduct(someOrder.Id,'57779',2,1.99,0,'','T - Text Line'); 
        OrderEntryServices.CalculateTaxOnOpportunity(someOrder.Id);
        Test.setMock(WebServiceMock.class, new Tax2WebServiceMockImpl()); 
        
        Tax2Wsdl tax2OppId = new Tax2Wsdl();
        Tax2Wsdl.Provide_ServicePort AvalaraSrvPort = new Tax2Wsdl.Provide_ServicePort();
        
        RecordType  getRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
        User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];    
        Account a2 = new Account();
        List<PriceBook2> PriceBooks = [SELECT Id, Name FROM PriceBook2 WHERE isActive = true ORDER BY Name ASC];
        string PriceBookNames = ''; // PriceBookNames is for an error message to list the available price books
        string PriceBookName = 'Catalog Price Book';
        PriceBook2 PriceBook = null;
        for(PriceBook2 pb : PriceBooks) {  
            if(PriceBookName != null){
                if(pb.Name.toLowerCase().contains(PriceBookName.toLowerCase())) { PriceBook = pb; }
            }
        }      
       // Call the method that invokes a callout   
       Test.startTest();
        OrderEntryServices.CalculateTaxOnOpportunity(someOrder.Id);
        Decimal output =  AvalaraSrvPort.Provide_Service( String.valueOf(someOrder.Id));
               
         // Verify that a fake result is returned  
         System.assertEquals(2.75, output); 
        Test.stopTest();
     //   }catch(NullPointerException ne){
        //    system.debug(ne.getMessage());
       // }
    }
        public static testmethod void TestOutsideVendor(){
        Contact TestContact = TestObjects.NewGenericContact();
        Order Order1 = TestObjects.FullOrder();
        
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Registration_Number__c='123';
        a2.Mailing_Address_Book__c='000123';
        insert a2;
        List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        Pricebook2 Pricebook = [Select Id, Name From Pricebook2 Where Id = :OrderPriceBookEntryList[0].PriceBook2Id];
        Order1.Company__c = 'Awana';
        Order1.Shipping_Country__c = 'UNITED STATES';
        Order1.AccountId = a2.id;
        Order1.Pricebook2Id = Pricebook.Id;
        Order1.Payment_Terms__c = 'Outside Vendor';
        
        upsert Order1;
        
        // test valid billing and shipping adddresses
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Address__c = 'The Landmark @ One Market\nSuite 300';
        cOrder.ChargentOrders__Billing_City__c = 'San Francisco';
        cOrder.ChargentOrders__Billing_State_Province__c = 'CA';
        cOrder.ChargentOrders__Billing_Zip_Postal__c = '94105';
        cOrder.ChargentOrders__Billing_Country__c = 'UNITED STATES';
        cOrder.ChargentOrders__Shipping_Country__c = 'UNITED STATES';
        
        insert cOrder;
        Order1.Chargent_Order__c = cOrder.id;
        Order1.Shipping_Street__c = 'The Landmark @ One Market\nSuite 300';
        Order1.Shipping_City__c = 'San Francisco';
        Order1.Shipping_State__c = 'CA';
        Order1.Shipping_Zip_Code__c = '94105';
        Order1.Shipping_Country__c = 'SAUDI ARABIA';
        Order1.Payment_Terms__c = 'Credit Card';
        update Order1;
        Test.startTest();
            OrderEntryServices.ValidateOrderAddress(Order1);      
            OrderEntryServices.CalculateFreightOnOpportunity(Order1.Id,'All Non-Stock',0,'UPS2A');
            // Test with a Canadian church
            Order1.Shipping_Street__c = '14 Tourangeau';
            Order1.Shipping_City__c = 'Gatineau';
            Order1.Shipping_State__c = 'QC';
            Order1.Shipping_Zip_Code__c = 'J8L 4M3';
            Order1.Shipping_Country__c = 'CANADA';
            Order1.Payment_Terms__c = 'Credit Card';
            update Order1;
            OrderEntryServices.CalculateFreightOnOpportunity(Order1.Id,'Stock',1.0,'UPS2A');
        Test.stopTest();
    }
    public static testmethod void CalculateFreightOnOpportunity(){
       // Contact TestContact = TestObjects.NewContact();
        Order Order1 = TestObjects.FullOrder();
        
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Registration_Number__c='123';
        a2.Mailing_Address_Book__c='000123';
        insert a2;
        //List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        //Pricebook2 Pricebook = [Select Id, Name From Pricebook2 Where Id = :OrderPriceBookEntryList[0].PriceBook2Id];
        Id priceBookId = Test.getStandardPricebookId();
        Order1.AccountId  = a2.Id;
        Order1.Pricebook2Id = priceBookId;
        Order1.Shipping_Street__c = 'The Landmark @ One Market\nSuite 300';
        Order1.Shipping_City__c = 'San Francisco';
        Order1.Shipping_State__c = 'CA';
        Order1.Shipping_Zip_Code__c = '94105';
        Order1.Company__c = 'Awana';
        Order1.Shipping_Country__c = 'UNITED STATES';
        Order1.Payment_Terms__c = 'Credit Card';
        upsert Order1;
        /*
        // Awana International Canada Order at Net 30
        Account acctAIC = [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where Mailing_Address_Book__c = '4' limit 1 ] ; 
        Order OrderAIC = TestObjects.FullOrder();
        OrderAIC.AccountId  = acctAIC.Id;
        OrderAIC.Pricebook2Id = priceBookId;
        OrderAIC.Shipping_Street__c = acctAIC.ShippingStreet;
        OrderAIC.Shipping_City__c = acctAIC.ShippingCity;
        OrderAIC.Shipping_State__c = acctAIC.ShippingState;
        OrderAIC.Shipping_Zip_Code__c = acctAIC.ShippingPostalCode;
        OrderAIC.Company__c = 'Awana';
        OrderAIC.Shipping_Country__c = 'UNITED STATES';
        OrderAIC.Payment_Terms__c = 'Net 30';
        upsert OrderAIC;
        */
        Test.startTest();
            OrderEntryServices.CalculateFreightOnOpportunity(Order1.Id,'Non-Stock',0,'UPS2A');
            //OrderEntryServices.CalculateFreightOnOpportunity(Order1.Id,'PB Failed',0,'UPS2A');
            //OrderEntryServices.CalculateFreightOnOpportunity(OrderAIC.Id,'Stock',0,'UPS2A');
            //OrderAIC.Shipping_Country__c = ' ';
            //OrderEntryServices.CalculateFreightOnOpportunity(OrderAIC.Id,'Stock',0,'UPS2A');
                        
        Test.stopTest();
    }
    public static testmethod void TestCalculateFreight(){
        Double FreightAmount = null;
        FreightAmount = OrderEntryServices.CalculateFreight('standard', 10);
        FreightAmount = OrderEntryServices.CalculateFreightDetail('standard', 10).DecimalOutput;
        FreightAmount = OrderEntryServices.CalculateFreightDetail('two', 10).DecimalOutput;
        FreightAmount = OrderEntryServices.CalculateFreightDetail('one', 10).DecimalOutput;
        FreightAmount = OrderEntryServices.CalculateFreightDetail('pickup', 10).DecimalOutput;
        FreightAmount = OrderEntryServices.CalculateFreightDetail('asdfjkl', 10).DecimalOutput;
        FreightAmount = OrderEntryServices.CalculateFreightDetail('', -50).DecimalOutput;
        
        List<Shipping_Cost__c> ShippingCosts = [Select Id From Shipping_Cost__c];
        delete ShippingCosts;
        
        FreightAmount = OrderEntryServices.CalculateFreightDetail('standard', 10).DecimalOutput;
    }
   public static testmethod void TestGetCompanies(){
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test Church1';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Contact c = TestObjects.NewGenericContact();
        c.accountid = a.id;
        insert c;
        
        OrderEntryServices.GetCompanies(c.Id,a.id);
        
    }
    public static testmethod void TestGetPriceBookByCompany(){
   // try{
        
        Contact houseContact = new Contact(Firstname='Teresa', LastName='Blake',Email='teresablack@mailinator.com');
        insert houseContact;
        Account houseAccount = new Account(Name='Blake Household', npe01__One2OneContact__c = houseContact.Id, Type='Household',    npsp__Number_of_Household_Members__c=1);
        insert houseAccount;
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
         Account individualAccount = new Account(Name='Sarah Groves', recordTypeId= recordTypeId);
       
       Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
     
       Account record = new Account();
       record.Name = 'Calvary Community Journey Resource Center';  
       record.RecordTypeId =  devRecordTypeId;    
       insert record;
       
       Contact con = new Contact();
       con.LastName = 'Test';
       con.FirstName = 'FirstTime';
       insert con;
             
       npe5__Affiliation__c acc = new npe5__Affiliation__c();
       acc.npe5__Organization__c = record.Id;
       acc.npe5__Contact__c = con.Id;
       insert acc;
       
        npe5__Affiliation__c affs0 = [Select Id, npe5__Contact__r.Id,npe5__Organization__r.RecordTypeId from npe5__Affiliation__c where npe5__Organization__r.RecordType.Name = 'US Organization' 
                                      and npe5__Organization__r.Registration_Level__c <> null and npe5__Organization__r.Registration_Level__c <> 'R0' limit 1];
        npe5__Affiliation__c affbu= [Select npe5__Contact__r.Id,npe5__Organization__r.RecordTypeId from npe5__Affiliation__c where npe5__Organization__r.RecordType.Name = 'Business Unit' 
                                     limit 1];
        npe5__Affiliation__c affbz= [Select npe5__Contact__r.Id,npe5__Organization__r.RecordTypeId from npe5__Affiliation__c where npe5__Organization__r.RecordType.Name = 'Business' 
                                     and npe5__Organization__r.Name='LifeWay' limit 1];
        npe5__Affiliation__c affbz2= [Select npe5__Contact__r.Id,npe5__Organization__r.RecordTypeId from npe5__Affiliation__c where npe5__Organization__r.RecordType.Name = 'Business' 
                                     and npe5__Organization__r.Name='Christianbook' limit 1]; 
        npe5__Affiliation__c affbz3= [Select npe5__Contact__r.Id,npe5__Organization__r.RecordTypeId from npe5__Affiliation__c where npe5__Organization__r.RecordType.Name = 'Business' 
                                     and npe5__Organization__r.Name='Calvary Community Journey Resource Center' limit 1]; 
         
        affbu.Authorized_Purchaser__c = true;
        affbu.Other_Role__c = 'Employee';
        affbz.Other_Role__c = 'Missionary';
        affs0.Authorized_Purchaser__c = true;
        upsert affbu;
        upsert affs0;
        upsert affbz;
             
        OrderEntryServices.GetPriceBookByCompany(affs0.npe5__Contact__c,affs0.npe5__Organization__r.RecordTypeId,'',affs0.npe5__Organization__c);
        OrderEntryServices.GetPriceBookByCompany(affbu.npe5__Contact__c,affbu.npe5__Organization__r.RecordTypeId,'',affbu.npe5__Organization__c);
        OrderEntryServices.GetPriceBookByCompany(affbz.npe5__Contact__c,affbz.npe5__Organization__r.RecordTypeId,'',affbz.npe5__Organization__c);
        OrderEntryServices.GetPriceBookByCompany(affbz2.npe5__Contact__c,affbz2.npe5__Organization__r.RecordTypeId,'',affbz2.npe5__Organization__c);
        OrderEntryServices.GetPriceBookByCompany(affbz3.npe5__Contact__c,affbz3.npe5__Organization__r.RecordTypeId,'',affbz3.npe5__Organization__c);
        OrderEntryServices.GetPriceBookByCompany(houseContact.Id,'Household Account','Household Account',houseAccount.Id);
    
    }
    public static testmethod void TestAddProduct(){
        OrderEntryServices.AddProduct('12345678901234A5', '', 1, null, null, null,null);
        // Using 1-1 Account to calculate the staging.
        Account a2 = [Select Id,Name,Mailing_Address_Book__c, a.RecordType.Name From Account a where a.RecordType.Name = 'Individual' limit 1];
        Order Ord = TestObjects.FullOrder();
        
        List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        
        Ord.AccountId = a2.Id;
        Ord.Pricebook2Id = OrderPriceBookEntryList[0].PriceBook2Id;
        Ord.Payment_Terms__c = 'Net 30';
        upsert Ord;
        
        List<PriceBookEntry> ProductsToAdd = [Select Product2.ProductCode From PriceBookEntry Where CreatedDate > :Date.Today() And Product2.Name like 'Test%' Limit 1];
        for(PricebookEntry Item : ProductsToAdd)
        {
            system.debug('***** PriceBookEntry ***** '+Item);
            OrderEntryServices.Result AddResult = OrderEntryServices.AddProduct(Ord.Id, Item.Product2.Id, 1, 5.95, 2.95,'Sales Promotion', 'S - Stock Inventory Item');
            system.debug('***** AddResult ***** '+AddResult);
        }
        
        // add duplicate line
        OrderEntryServices.Result AddResult = OrderEntryServices.AddProduct(Ord.Id, ProductsToAdd[0].Product2.Id, 1, 5.95,null,null, 'S - Stock Inventory Item');
        
        OrderEntryServices.ConsolidateDuplicateLineItems(Ord.Id);
        
        ord.Payment_Terms__c = 'Sales Credit'; update ord;
        
        if(OrderPriceBookEntryList[0] != null)
        {
            OrderEntryServices.AddProduct(Ord.Id, OrderPriceBookEntryList[0].Product2.ProductCode, 1, 5.95, null,null, 'S - Stock Inventory Item');
        }
        
        OrderEntryServices.GetOrderAmounts1(Ord.Id);
        
        List<OrderItem> Lines = [Select Id From OrderItem Where OrderId = :Ord.Id];
        if(Lines[0] != null) { OrderEntryServices.RemoveProduct(Lines[0].Id); }
        
        OrderEntryServices.RemoveFreightAndTax(Ord.Id);
        OrderEntryServices.RemoveAllProducts(Ord.Id);
    } 
    public static testmethod void testCreateAffiliateOrderNegative(){
         List<RecordType> rc = [Select Id from RecordType where name = 'US Organization' limit 1]; 
        Account a = TestObjects.FullAccount();
        a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
         a.ShippingStreet =  '32364 Lodge Rd';
    a.ShippingCity = 'Tollhouse';
    a.ShippingPostalCode =  '93667';
    a.ShippingState = 'CA';
    a.ShippingCountry = 'UNITED STATES'; 
    a.Shipping_County__c =  'Fresno';
  
    a.Physical_City__c = 'Tollhouse';
    a.PhysicalCountry__c = 'UNITED STATES';
    a.Physical_State__c = 'CA';
    a.Physical_Street_1__c = '32364 Lodge Rd';
    a.Physical_Zip__c = '93667';
    a.Physical_County__c = 'Fresno';
    a.Default_Terms__c = 'NET30';
      a.RecordTypeId=rc[0].Id;
        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        
        String cID = String.valueOf(affi.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+affi.npe5__Contact__c);
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Registration_Number__c='US444561';
        a2.Mailing_Address_Book__c='000190';
        insert a2;
        //for matching error
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a2.Id);
        System.assert(r.Message.contains('The ContactId provided could not be found'));
        //for Mailing address book blank check
        a.Mailing_Address_Book__c = '';
        update a;
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        System.assert(r.Message.contains('does not have a valid Customer Number'));
        //for Account_on_Hold__c=true check
        a.Mailing_Address_Book__c = '000123';
        a.Account_on_Hold__c=true;
        update a;
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a.Id);
        System.assert(r.Message.contains('is on hold and is currently not allowed'));
        //invalid pricebook
        a.Account_on_Hold__c=false;
        update a;
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book2','Order',System.Today(),'Awana',a.Id);
        System.assert(r.Message.contains('please provide a valid PriceBookName'));
        //invalid ordertype
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book',null,System.Today(),'Awana',a.Id);
        System.assert(r.Message.contains('OrderType is required'));
        // Order is credit type and date is blank
        r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','credit',null,'Awana',a.Id);
        System.assert(r.Message.contains('OriginalOrderDate is required for Credit OrderType'));
      
        a.BillingCountry = '';
        a.BillingStreet  = '';
        a.BillingCity = ' ';
        a.BillingPostalCode = ' ';
        a.BillingState = '';
        a.Undeliverable_Mailing__c = true;
        a.Account_on_Hold__c=false;
        update a;
        r =OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','credit',Date.Today(),'Awana', a.Id);  
        a.BillingCountry = 'Canada';
        a.BillingStreet  = ''; 
        a.Undeliverable_Mailing__c = true;
        update a;
    r =OrderEntryServices.CreateAffiliateOrder(cID,'Canada Pricebook','credit',Date.Today(),'Awana', a.Id);  
        a.BillingStreet  = '2667 Bur Oak Ave'; 
        a.Undeliverable_Mailing__c = false;
        update a;
    r =OrderEntryServices.CreateAffiliateOrder(cID,'Canada Pricebook','credit',Date.Today(),'Awana', a.Id);  
    }
    public static testmethod void testResendConfirmationEmail(){
        Test.startTest();
      //  Contact TestContact = TestObjects.NewGenericContact();
        Contact TestContact = TestObjects.FullContact();
        insert TestContact;
        order Ord = TestObjects.FullOrder();
        
        List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        
        Account a2 = TestObjects.FullAccount();
        a2.Name = 'Test Account';
        a2.Registration_Number__c='123';
        a2.Mailing_Address_Book__c='000123';
        insert a2;
        Ord.AccountId = a2.id;
        Ord.Pricebook2Id = OrderPriceBookEntryList[0].PriceBook2Id;
        Ord.Payment_Terms__c = 'Net 30';
        ord.ExtraEmail__c = 'test@test.com';
        upsert Ord;
        
        //for exception coverage
        OrderEntryServices.resendConfirmationEmail(Ord.Id);
        
        Order_Contact_Role__c ocr = new Order_Contact_Role__c(Contact__c=TestContact.Id,Order__c=Ord.id);
        insert ocr;
        
        OrderEntryServices.resendConfirmationEmail(Ord.Id);
        Ord.Payment_Terms__c = 'Sales Credit';
        upsert Ord;
        OrderEntryServices.resendConfirmationEmail(Ord.Id);
        Test.stopTest();
    }
     public static testmethod void testGetAllPriceBooks(){
        
        Account acc= TestObjects.FullAccount();
        acc.Name = 'Test Account';
        acc.Registration_Number__c='123';
        acc.Mailing_Address_Book__c='000123';
        insert acc;
        Test.startTest();
            OrderEntryServices.GetAllPriceBooks(acc.Id);
            Account accIntl = [Select Id from Account WHERE RecordType.Name = 'International Church' limit 1];
            OrderEntryServices.GetAllPriceBooks(accIntl.Id);
        Test.stopTest();
    }
    public static testmethod void TestMozoProRate(){
        
        Account mozoAccount  = [Select Id,Name,Mailing_Address_Book__c,Registration_Level__c,Date_Inactive__c, ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where a.RecordType.Name = 'US Organization' and 
                                Mailing_Address_Book__c <> null  and Account_On_Hold__c <> true and Registration_Level__c = 'R1' limit 1]; 
        List<Order> mozoOpps = new List<Order>();
        mozoOpps.add(TestObjects.FullOrder());
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
        mozoOpps[0].AccountId = mozoAccount.Id;
        mozoOpps[0].Pricebook2Id = PriceBook.Id;
        insert mozoOpps;
        system.debug('mozoOpps--'+mozoOpps);
        List<PricebookEntry> pbs = [SELECT  id,Productcode,Product2.id,Unitprice,Product2.Line_Type__c from PricebookEntry where ProductCode  = '70005'  limit 1];
        OrderEntryServices.AddProduct(mozoOpps[0].Id,pbs[0].ProductCode,1,pbs[0].UnitPrice,0,'',pbs[0].Product2.Line_Type__c);
        
        
       //PricebookEntry pbe = new PricebookEntry(pricebook2id=PriceBook.id, product2id=pbs[0].Product2.id,unitprice=1.0, isActive=true);
       //insert pbe;
       
       PricebookEntry pbe2 = [SELECT Productcode FROM PricebookEntry WHERE pricebook2id =:PriceBook.id Limit 1];
           
           Orderitem oitem = new Orderitem();
           oitem.OrderId = mozoOpps[0].Id;
           oitem.Quantity = 1;
           oitem.UnitPrice = 200;
           oitem.Upgrade_Level__c = 'U1';
           oitem.PricebookEntryId = pbe2.Id;
           insert oitem;
        
        OrderItem someOli = [Select UnitPrice, Upgrade_Level__c From OrderItem Where OrderId=: mozoOpps[0].Id];
        List<OrderItem> Oli = new List<OrderItem>();
        Oli.add(someOli);
        Oli.add(oitem);
        OrderEntryServices.GetUpgradeRate(50.02,'R2', 20.00, 'Spring-SummerS Sale',Oli[0]);
        OrderEntryServices.GetUpgradeRate(50.02,'R2', 0, '',Oli[0]);
        // GetUpgradeRate(decimal UpgradePrice, string UpgradeLevel, decimal UpgradeDiscount, string UpgradePromoCode, OpportunityLineItem LineItem)
    }
    public static testmethod void testRemoveDiscount(){
        Test.startTest();
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Id priceBookId = Test.getStandardPricebookId();
        O.AccountId  = a.Id;
        O.Pricebook2Id = pricebookId;
        O.ExtraEmail__c = 'someone@someone.com,test@test.com';
        O.CurrencyIsoCode = 'CAD';
        system.debug('##ORDER'+O);
        insert o;
        Contact c = TestObjects.FullContact();
        insert c;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = O.Id);
        
        OrderEntryServices.AddProduct(O.Id,'99001',10,10,0,'','S - Stock Inventory Item');
        //OrderEntryServices.AddProduct(O.Id,'43490',1,1,0,'','frieght');
        List<String> orderItemIds = new List<String>();
        for(OrderItem oItem: [SELECT ID FROM OrderItem WHERE OrderId=:o.id]){
            orderItemIds.add(oItem.id);
        }
        //without applying discount
        OrderEntryServices.removeDiscount(o.Id,orderItemIds);
        //apply promocode
        OrderEntryServices.applyDiscount(o.id,orderItemIds,'GET10',10,false);
        //remove discount
        OrderEntryServices.removeDiscount(o.Id,orderItemIds);
        
        Test.stopTest();
    }
    public static testmethod void testGetTransactions(){
        Test.startTest();
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Id priceBookId = Test.getStandardPricebookId();
        O.AccountId  = a.Id;
        O.Pricebook2Id = pricebookId;
        O.ExtraEmail__c = 'someone@someone.com,test@test.com';
        system.debug('##ORDER'+O);
        insert o;
        Order ord = [SELECT Id,Chargent_Order__C from Order WHERE id=:o.id];
        OrderEntryServices.GetTransactions(ord.chargent_Order__c);
        Test.stopTest();
    }
     public static testmethod void TestToBeBilled(){
       // try{
     List<RecordType> rc = [Select Id from RecordType where name = 'US Organization' limit 1];  
        Account a = TestObjects.FullAccount();
       // a.ISO_Code__c = 'CA';
        a.Mailing_Address_Book__c = '000123';
        a.Registration_Number__c='123';
        a.BillingCountry = 'UNITED STATES';
        a.BillingStreet  = 'The Landmark @ One Market\nSuite 300';
        a.BillingCity = 'San Francisco';
        a.BillingPostalCode = '94105';
        a.BillingState = 'CA';
        a.Undeliverable_Mailing__c  = false;
        a.ShippingStreet =  '32364 Lodge Rd';
        a.ShippingCity = 'Tollhouse';
        a.ShippingPostalCode =  '93667';
        a.ShippingState = 'CA';
        a.ShippingCountry = 'UNITED STATES'; 
        a.Shipping_County__c =  'Fresno';
  
        a.Physical_City__c = 'Tollhouse';
        a.PhysicalCountry__c = 'UNITED STATES';
        a.Physical_State__c = 'CA';
        a.Physical_Street_1__c = '32364 Lodge Rd';
        a.Physical_Zip__c = '93667';
        a.Physical_County__c = 'Fresno';
        a.Default_Terms__c = 'NET30';
        a.RecordTypeId=rc[0].Id;

        insert a;  
        npe5__Affiliation__c affi = TestObjects.NewAffiliation();
        affi.npe5__Organization__c = a.id;
        affi.Authorized_Purchaser__c = true;
        insert affi;
        npe5__Affiliation__c Aff =[Select Id,
                                   npe5__Organization__r.Id,
                                   npe5__Organization__r.Name,
                                   npe5__Organization__r.Mailing_Address_Book__c,
                                   npe5__Organization__r.ShippingCountry,
                                   npe5__Organization__r.ShippingStreet,
                                   npe5__Organization__r.ShippingCity,
                                   npe5__Organization__r.ShippingState,
                                   npe5__Organization__r.ShippingPostalCode, 
                                   npe5__Organization__r.RecordType.Name,
                                   npe5__Contact__c
                                   From npe5__Affiliation__c  where  npe5__Organization__r.RecordType.Name = 'US Organization' and 
                                   npe5__Organization__r.Mailing_Address_Book__c <> null  and npe5__Organization__r.Account_On_Hold__c <> true 
                                   and Authorized_Purchaser__c = true limit 1];
        Account a2  =  [Select Id,Name,Mailing_Address_Book__c,ShippingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, a.RecordType.Name From Account a where  a.Id =: Aff.npe5__Organization__c limit 1] ; 
        //String cID = String.valueOf(contactId.Id);
        String cID = String.valueOf(Aff.npe5__Contact__c);
        system.debug('CONTACT ROLE: '+Aff.npe5__Contact__c);
        OrderEntryServices.Result r = OrderEntryServices.CreateAffiliateOrder(cID,'Catalog Price Book','Order',System.Today(),'Awana',a2.Id);
        Order someOrder = (Order)r.ObjectOutput;
        system.debug('<< Result >> '+r);       // test valid billing and shipping adddresses
        system.debug('<< anOrder >> '+someOrder);       // test valid billing and shipping adddresses
        Integer rcount = 0;
        OrderEntryServices.Result rs = new OrderEntryServices.Result();
        List<PriceBookEntry> PBs = [Select Product2.ProductCode,UnitPrice From PricebookEntry where Product2.isActive=true and Pricebook2.Name = 'Catalog Price Book'  AND Product2.Line_Type__c like '%- Stock%' and isActive = true  limit 5];
      
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Address__c = 'The Landmark @ One Market\nSuite 300';
        cOrder.ChargentOrders__Billing_City__c = 'San Francisco';
        cOrder.ChargentOrders__Billing_State_Province__c = 'CA';
        cOrder.ChargentOrders__Billing_Zip_Postal__c = '94105';
        cOrder.ChargentOrders__Billing_Country__c = 'UNITED STATES';
        cOrder.ChargentOrders__Shipping_Country__c = 'UNITED STATES';
        
        insert cOrder;
        someOrder.Chargent_Order__c = cOrder.id;
        someOrder.Shipping_Country__c = 'UNITED STATES';
        someOrder.Payment_Terms__c = 'To Be Billed';
        update someOrder;  
         Test.startTest();
            OrderEntryServices.ValidateOrderAddress(someOrder);
            OrderEntryServices.CalculateFreightOnOpportunity(someOrder.Id,'Stock',76.9,'UPS2A');
            OrderEntryServices.CalculateTaxOnOpportunity(someOrder.Id);
            OrderEntryServices.Result r1 = OrderEntryServices.SubmitOrder(someOrder.Id,'order');
            someOrder.Shipping_Type__c = 'USPS';
            someOrder.Payment_Terms__c = 'Credit Card';
            update someOrder;
            r1 = OrderEntryServices.SubmitOrder(someOrder.Id,'order');
         Test.stopTest();
         /*
        }catch(NullPointerException 
            system.debug('Null Pointer Exception for someOrder variable '+ne);
        }
        */
    }
    public static testmethod void TestAddAndUpdateAddresses(){
        Contact TestContact = TestObjects.NewGenericContact();
        Account TestAccount = [Select Name,Id from Account Where Status__c='Added' and RecordType.Name='US Organization' Limit 1];
        
        npe5__Affiliation__c aff = new npe5__Affiliation__c(npe5__Organization__c=TestAccount.Id, npe5__COntact__c=TestContact.Id);
        
        Address__c TestAddress = null;
        
        List<Address__c> TestAddresses = TestObjects.NewAddresses();
    
        // Make sure account != null
        TestAddress = [Select Id, Name, Account__c, Default_Shipping_Address__c, First_Name__c, Last_Name__c,  
                       Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, County__c, Country__c, 
                       (Select Id From orders1__r), (Select Id From orders__r)  
                       From Address__c  Where default_Shipping_Address__c = true and Account__c != null limit 1]; 
        
        //SUbstitute real ID for Lysander for Account ID because this one returns a null.
        OrderEntryServices.GetAddresses(TestAddress.Account__c);
        
        // test blank accountid
        OrderEntryServices.AddAddress(null, TestContact.FirstName, TestContact.LastName, TestAddress.Address_Line_1__c, TestAddress.Address_Line_2__c, 
                                      TestAddress.City__c, TestAddress.State__c, TestAddress.Zip_Code__c, TestAddress.County__c, TestAddress.Country__c);
        
        // test invalid accountid
        OrderEntryServices.AddAddress('123456789012345', TestContact.FirstName, TestContact.LastName, TestAddress.Address_Line_1__c, TestAddress.Address_Line_2__c, 
                                      TestAddress.City__c, TestAddress.State__c, TestAddress.Zip_Code__c, TestAddress.County__c, TestAddress.Country__c);
        
        // test invalid country
        OrderEntryServices.AddAddress(TestAddress.Account__c, TestContact.FirstName, TestContact.LastName, TestAddress.Address_Line_1__c, TestAddress.Address_Line_2__c, 
                                      TestAddress.City__c, TestAddress.State__c, TestAddress.Zip_Code__c, TestAddress.County__c, 'AWANATOPIA');
        
        // test valid accountid
        OrderEntryServices.AddAddress(TestAddress.Account__c, TestContact.FirstName, TestContact.LastName, TestAddress.Address_Line_1__c, TestAddress.Address_Line_2__c, 
                                      TestAddress.City__c, TestAddress.State__c, TestAddress.Zip_Code__c, TestAddress.County__c, TestAddress.Country__c);
        
        OrderEntryServices.GetAddresses(TestAddress.Account__c);   
        Order Ord = TestObjects.FullOrder();
        
        List<PricebookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        Pricebook2 Pricebook = [Select Id, Name From Pricebook2 Where Id = :OrderPriceBookEntryList[0].PriceBook2Id];
        
        system.debug('Pricebook2Id: '+Pricebook.Id);
        system.debug('Pricebook2.Name: '+Pricebook.Name);
        Account accTest = TestObjects.NewGenericAccount();
        accTest.Name = 'AFF-Test Church3';
        accTest.Registration_Number__c='123';
        accTest.Mailing_Address_Book__c='000123';
        insert accTest;
        Ord.AccountId = accTest.Id;
        
        Ord.Pricebook2Id = Pricebook.Id;
        Ord.Payment_Terms__c = 'Net 30';
        Test.startTest();
        upsert Ord;
        if(TestAddresses != null) 
        { 
            if(!TestAddresses.IsEmpty()) 
            {
                for(Address__c A : TestAddresses)
                {
                    OrderEntryServices.UpdateOrderBillingAddress(Ord.Id, A.Id);
                    OrderEntryServices.UpdateOrderShippingAddress(Ord.Id, A.Id);
                }
                
                OrderEntryServices.RemoveAddress('123456789012345');
                OrderEntryServices.RemoveAddress(TestAddresses[0].Id);
                //OrderEntryServices.updateAccBillAddress(Ord.AccountId,'101','Seattle','NY','69807','UNITED STATES');
                //OrderEntryServices.UpdateAddNewOrderShippingAddress(TestAddresses[0].Id,Ord.Id,'Test1','Test2','101','101','seattle','NY','69807','UNITED STATES');
                
                
            } 
        }
        Test.stopTest();        
    }
    public static testmethod void TestAuthorizeCreditCard(){
        // User GeneratedTestUser = TestObjects.NewUser();
        // User TestUser = [Select Id, ContactId, Contact.AccountId From User Where Id = :GeneratedTestUser.Id];
        
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test Church';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Contact c = TestObjects.NewGenericContact();
        c.accountid = a.id;
        insert c;
        npe5__Affiliation__c aff = new npe5__Affiliation__c( npe5__Organization__c  = a.Id,npe5__Contact__c = c.Id);
        
        insert aff;
        
        //Order Ord = TestObjects.NewOrder();
        Order Ord = TestObjects.FullOrder();
        System.debug('>> Order :'+ord);
        System.debug('>> Order Billing Order : '+ord.Chargent_Order__r.ChargentOrders__Billing_First_Name__c);
        List<PricebookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        Pricebook2 Pricebook = [Select Id, Name From Pricebook2 Where Id = :OrderPriceBookEntryList[0].PriceBook2Id];
        
        system.debug('Pricebook2Id: '+Pricebook.Id);
        system.debug('Pricebook2.Name: '+Pricebook.Name);
        
        //Order.AccountId = TestUser.Contact.AccountId;
        Ord.AccountId = aff.npe5__Organization__c;
        Ord.Pricebook2Id = Pricebook.Id;
        Ord.Payment_Terms__c = 'Credit Card';
        insert Ord;
        
        OrderEntryServices.UpdateCreditCard(Ord.Id, 'Visa', 'Test Contact', '4111111111111111', '12', '2020', '123');
        OrderEntryServices.AuthorizeCreditCard(Ord.Id);
        
        OrderEntryServices.UpdateCreditCard(Ord.Id, 'Visa', 'Test Contact', '411111111111', '123', '20200', '1234');
        OrderEntryServices.AuthorizeCreditCard(Ord.Id);
        
        OrderEntryServices.UpdateCreditCard(Ord.Id, 'Visa', 'Test Contact', '411111111111', '.5', '.123', '.25');
        OrderEntryServices.AuthorizeCreditCard(Ord.Id);
        
        OrderEntryServices.AuthorizeCreditCard(Ord.Id); 
    }
    public static testmethod void TestOrderEntry(){
        //User GeneratedTestUser = TestObjects.NewUser();
        //insert GeneratedTestUser;
        //User TestUser = [Select Id, ContactId, Contact.AccountId From User Where Id = :GeneratedTestUser.Id];
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test Church2';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Order Order1 = TestObjects.FullOrder();
        
        List<PricebookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
        Pricebook2 Pricebook = [Select Id, Name From Pricebook2 Where Id = :OrderPriceBookEntryList[0].PriceBook2Id];
        
        system.debug('Pricebook2Id: '+Pricebook.Id);
        system.debug('Pricebook2.Name: '+Pricebook.Name);
        Order1 .Company__c = 'KidzMatter';
        Order1.AccountId = a.id;
        Order1.Pricebook2Id = Pricebook.Id;
        Order1.Payment_Terms__c = 'Net 30';
        upsert Order1;
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
        cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
        cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
        cOrder.ChargentOrders__Billing_Address__c = 'The Landmark @ One Market\nSuite 300';
        cOrder.ChargentOrders__Billing_City__c = 'San Francisco';
        cOrder.ChargentOrders__Billing_State_Province__c = 'CA';
        cOrder.ChargentOrders__Billing_Zip_Postal__c = '94105';
        cOrder.ChargentOrders__Billing_Country__c = 'UNITED STATES';
        cOrder.ChargentOrders__Shipping_Country__c = 'UNITED STATES';
        
        cOrder.ChargentOrders__Billing_First_Name__c= 'Test'; 
        cOrder.ChargentOrders__Billing_Last_Name__c ='Contact';
        cOrder.ChargentOrders__Card_Number__c = null; 
        cOrder.ChargentOrders__Card_Month_Indicator__c= '12'; 
        cOrder.ChargentOrders__Card_Year_Indicator__c= '2020'; 
       // cOrder.ChargentOrders__Card_Security_Code__c= '123';
        cOrder.ChargentOrders__Card_Number__c = '4111111111111111';
        cOrder.ChargentOrders__Card_Type__c = 'Visa';
        insert cOrder;
        
        Order1.Chargent_Order__c = cOrder.Id;
        Order1.effectiveDate= Date.Today();
        Order1.CurrencyIsoCode = 'USD';
        Order1.Order_Number__c = '00000767';
        Order1.Payment_Terms__c = 'Credit Card';
        Order1.Ship_to_Name__c = 'Random Order';
        Order1.Shipping_Carrier__c = 'Rate Shop';
        Order1.Shipping_City__c = 'Decatur';
        Order1.Shipping_Country__c = 'UNITED STATES';
        Order1.Shipping_State__c = 'IL';
        Order1.Shipping_Street__c = '215 N Main St';
        Order1.Shipping_Type__c = 'One Day';
        Order1.Shipping_Zip_Code__c = '625231208';
        Order1.Billing_Address__c = null;
        Order1.Billing_County__c = null;
        Order1.Purchase_Order__c = null;
        Order1.Shipping_Address__c = null;
        Order1.Shipping_County__c = null;
        
        List<OrderItem> AllLineItems = new List<OrderItem>();
        
        for(PricebookEntry PBE : OrderPricebookEntryList)
        {
            OrderItem LineItem = new OrderItem(
                Quantity            = 1, 
                PriceBookEntryId    = PBE.Id, 
                UnitPrice           = 0.01, 
                OrderId = Order1.Id, 
                Price_of_Discount__c = 10.0,
                Promo_Code__c = 'Summer Sale',
                Line_Type__c        = 'S - Stock Inventory Item' 
            );
            
            AllLineItems.add(LineItem);
        }
        system.debug('<< '+Order1.Company__c+' >>');
        Test.startTest();
        OrderEntryServices.SaveOrder(Order1,'test@test.com','123345678');
        //TW: 07/30/2013 - Added Call to Submit Order to Test Opportunity Source field.
        OrderEntryServices.Result r1 = OrderEntryServices.SubmitOrder(Order1.Id,'');
        
        Test.stopTest();
    }
    
    //SF-321 
     public static testmethod void testPriceBookChange(){
         
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        
        //Id priceBookId = Test.getStandardPricebookId();
        
        
      
       Product2 p = new Product2(
            IsActive=true,Name='Test Item 99990',ProductCode='99990',List_Price__c=1.25,Row__c='A',Bin__c='1',
            Quantity__c=0,Quantity_Reserved__c=0,Non_inventory_Item__c=true,Line_Type__c='S - Stock Inventory Item',Weight__c = 0.70
            
            ); 
        insert p;
        Id pricebookId = Test.getStandardPricebookId();
     
    pricebookEntry standardPrice = new PricebookEntry();
    standardPrice.Pricebook2Id = pricebookId;
    standardPrice.Product2Id = p.Id;
    standardPrice.UnitPrice = 1;
    standardPrice.IsActive = true;
    standardPrice.UseStandardPrice = false;
    insert standardPrice ;
    
    standardPrice = [SELECT Id,Pricebook2.Name,Pricebook2.IsStandard FROM PricebookEntry where Id=:standardPrice.Id];
    
   
    O.AccountId  = a.Id;
        O.Pricebook2Id = pricebookId;
        O.ExtraEmail__c = 'someone@someone.com,test@test.com';
        insert o;
        
      Contact c = TestObjects.FullContact();
        insert c;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = O.Id);
        
    OrderItem i = new OrderItem();
    i.OrderId = o.id;
    i.Quantity = 24;
    i.UnitPrice = 240;
    i.Product2id = p.id;
    i.PricebookEntryId=standardPrice.id;
    insert i;
        
        //OrderEntryServices.AddProduct(O.Id,'99001',10,10,0,'','S - Stock Inventory Item');
        List<String> orderItemIds = new List<String>();
        for(OrderItem oItem: [SELECT ID FROM OrderItem WHERE OrderId=:o.id]){
            orderItemIds.add(oItem.id);
        }
        Test.startTest(); 
        OrderEntryServices.changeAllProductPricing(o.id,standardPrice.Pricebook2.Name);
        Test.StopTest();
     
     }
    
    
    
    public static testmethod void testApplyDiscount(){
        
        //for order null condition
        OrderEntryServices.applyDiscount(null,null,'GET10',10,true);
        
        Order o = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        
        
        Id priceBookId = Test.getStandardPricebookId();
        O.AccountId  = a.Id;
        O.Pricebook2Id = pricebookId;
        O.ExtraEmail__c = 'someone@someone.com,test@test.com';
        O.CurrencyIsoCode = 'CAD';
        system.debug('##ORDER'+O);
        insert o;
 
        Contact c = TestObjects.FullContact();
        insert c;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = O.Id);
        
        OrderEntryServices.AddProduct(O.Id,'99001',10,10,0,'','S - Stock Inventory Item');
        List<String> orderItemIds = new List<String>();
        for(OrderItem oItem: [SELECT ID FROM OrderItem WHERE OrderId=:o.id]){
            orderItemIds.add(oItem.id);
        }
        Test.startTest();
        
        OrderEntryServices.applyDiscount(o.id,orderItemIds,'GET10',10,false);
        //for already applied
        OrderEntryServices.applyDiscount(o.id,orderItemIds,'GET10',10,false);
        OrderEntryServices.UpdateOrderBillingPhone(o.id,'8965437897');
        
        Test.stopTest();
    }
    public static testmethod void testFoundProductWithPricebook(){
        Test.startTest();
        List<Product2> p2 = OrderEntryServices.FindProductWithPriceBook('79345','Catalog Price Book');
         p2 = OrderEntryServices.FindProductWithPriceBook('Puggles Backpack','Catalog Price Book');
         OrderEntryServices.FindProduct('Puggles Backpack');
        Test.stopTest();
    }
   
}//Class