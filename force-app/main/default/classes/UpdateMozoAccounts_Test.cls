/****************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    General (All cases)
    Description: Performs dispatch calls to various class methods for vairious tasks based on post-Opportunity updates.
    Updated:    3/9/2015 - <MOZO> - Updated to include  Mozo Registration Level updates based on the Registration Products. 
    Updated:    5/26/2015 - <MOZO> - Updated Mozo section to also filter in Credits as long as there is a Registration Product that exists.
    Updated:    8/2/2015 - <MOZO> - Updated this module to add Downgrade Credits test.
    Updated:    03/22/2016 - <MEM 375> - Updated to this feature Mozo Trail Cancelled after (R4) Purchase
    Updated:    04/09/2018 - <NMM17> - Testing New Mozo Membership
*******************************************************************************************************************************************/
 
@isTest(SeeAllData=true)
public without sharing class UpdateMozoAccounts_Test {
   
  
     public static TestMethod void TestMozoAccounts2(){
            
        //for order null condition
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
        c.AccountId = a.id;
        c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
        a.Applicant__c = c.Id;
        upsert a;   
        
        Test.startTest();
        Id priceBookId = Test.getStandardPricebookId();
        Ord.AccountId  = a.Id;
        Ord.Pricebook2Id = pricebookId;
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        system.debug('##ORDER'+Ord);
        
        insert Ord;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
        Decimal insertPrice = 0.0;
        Integer orderCnt = 0;
        List<OrderItem> itemList = new List<OrderItem>();
        List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70011') And IsActive = true limit 1];
        for(PriceBookEntry apbe : PBE){
            if (apbe.Product2.ProductCode == '70001'){
                    insertPrice = 99.00;
            }else{
                    insertPrice = 200.00;
            }
            OrderItem LineItem = new OrderItem(
                Quantity            = 1,
                PricebookEntryId    = PBE[orderCnt].Id, 
                OrderId       = Ord.Id, 
                Line_Type__c        = 'N - Non-Stock',
                Price_of_Discount__c = 0,
                UnitPrice = insertPrice,
                PreOrder_Backorder_Handling__c= 'backorder',
                Estimated_Weight__c = 0
              );
            itemList.add(LineItem);
            ++orderCnt;
                
        }// LOOP
        if(itemList.size() > 0){
            Ord.Registration_Product__c = 'R1';
            Upsert Ord;
            insert itemList;
        }
        Ord.Status = 'Order Submitted';
         ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
          cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
          cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
          cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
          cOrder.ChargentOrders__Billing_Country__c = 'United States';
          insert cOrder;
          Ord.Chargent_Order__c = cOrder.Id;
        upsert Ord;
        Ord.Status = 'Order Confirmed';
        upsert Ord;
  
       Test.stopTest();
    }// TestMozoAccounts
    
   
    public static Testmethod void Purchase70011Test(){
       Order Ord = TestObjects.FullOrder();
        RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account' limit 1];
        Account a =  new Account(Name='Christian Test Church', Description='Test Church', type='Church',RecordTypeId=acctRecordType.Id);
        system.debug('<<GOT ACCT VALUE?>> '+a.Description);
        a.RecordTypeId = acctRecordType.Id;
        system.debug('<<ENTERING INTO  acct>> '+a );
        a.ShippingStreet = '5921 Walnut Hill Ln';
        a.ShippingState = 'TX';
        a.ShippingPostalCode = '75230';
        a.ShippingCountry = 'UNITED STATES';
        a.ShippingCity = 'Waco';
        Contact c = new Contact(FirstName='Baji', LastName='Shaik', Email= 'sbaji@mailinator.com');
        insert c;
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.Date_Inactive__c = system.today();
        a.Applicant__c = c.Id;
        Test.startTest();
            a.Registration_Level__c = 'R1';
            a.MOZO_Level__c = 'M0';
            a.Registration_Status__c = 'New';
            insert a;
            //Id priceBookId = Test.getStandardPricebookId();
            PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
            Id priceBookId = pbForId.PriceBook2.Id;
            Ord.AccountId  = a.Id;
            Ord.Pricebook2Id = pricebookId;
            Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
            system.debug('##ORDER'+Ord);
          
            insert Ord;
          	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
            Decimal insertPrice = 0.0;
            Integer orderCnt = 0;
            List<OrderItem> itemList = new List<OrderItem>();
            List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001','70011') And IsActive = true limit 1];
            for(PriceBookEntry apbe : PBE){
                if (apbe.Product2.ProductCode == '70001'){
                        insertPrice = 99.00;
                }else{
                        insertPrice = 200.00;
                }
                OrderItem LineItem = new OrderItem(
                        Quantity            = 1,
                        PricebookEntryId    = PBE[orderCnt].Id, 
                        OrderId       = Ord.Id, 
                        Line_Type__c        = 'N - Non-Stock',
                        Price_of_Discount__c = 0,
                        UnitPrice = insertPrice,
                        PreOrder_Backorder_Handling__c= 'backorder',
                        Estimated_Weight__c = 0
                    );
              itemList.add(LineItem);
              ++orderCnt;
                
            }// LOOP
        if(itemList.size() > 0){
            Ord.Registration_Product__c = '1M1';
            Upsert Ord;
            insert itemList;
        }    
        // Ord.Registration_Product__c = 'R1M1';
        Ord.Status = 'Order Submitted';
         ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
          cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
          cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
          cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
          cOrder.ChargentOrders__Billing_Country__c = 'United States';
          insert cOrder;
          Ord.Chargent_Order__c = cOrder.Id;
        upsert Ord;
        Ord.Status = 'Order Confirmed';
       
        upsert Ord;

        /*
        List<Account> mozoAccounts = [Select Id,Cast_Iron_Bypass__c,Registration_Date__c,Registration_Status__c, Registration_Level__c,MOZO_Expiration_Date__c, Date_Inactive__c,Status__c, Mozo_Trial_Status__c FROM Account WHERE Id =: ord.AccountId and RecordType.Name in ('Canada Church','US Organization') ]; 
        Map<Id,Order> mozoMap = new Map<Id,Order>();
        mozoMap.put(Ord.AccountId,Ord);
        UpdateMozoAccounts.handler(mozoAccounts,mozoMap);*/
        Test.stopTest();
     }
      
    public static testMethod void Purchase70012Test(){
        Order Ord = TestObjects.FullOrder();
        RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account' limit 1];
        Account a =  new Account(Name='Christian Test Church', Description='Test Church', type='Church',RecordTypeId=acctRecordType.Id);
        system.debug('<<GOT ACCT VALUE?>> '+a.Description);
        a.RecordTypeId = acctRecordType.Id;
        system.debug('<<ENTERING INTO  acct>> '+a );
        a.ShippingStreet = '5921 Walnut Hill Ln';
        a.ShippingState = 'TX';
        a.ShippingPostalCode = '75230';
        a.ShippingCountry = 'UNITED STATES';
        a.ShippingCity = 'Waco';
        Contact c = new Contact(FirstName='Baji', LastName='Shaik', Email= 'sbaji@mailinator.com');
        insert c;
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.Date_Inactive__c = system.today();
        a.Applicant__c = c.Id;
        Test.startTest();
            a.Registration_Level__c = 'R1';
            a.MOZO_Level__c = 'M0';
            a.Registration_Status__c = 'Renewed';
        	a.MOZO_Expiration_Date__c= system.today().addDays(256);
            insert a;
            //Id priceBookId = Test.getStandardPricebookId();
            PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
            Id priceBookId = pbForId.PriceBook2.Id;
            Ord.AccountId  = a.Id;
            Ord.Pricebook2Id = pricebookId;
            Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
            system.debug('##ORDER'+Ord);
          
            insert Ord;
          	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
            Decimal insertPrice = 0.0;
            Integer orderCnt = 0;
            List<OrderItem> itemList = new List<OrderItem>();
            List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001','70011') And IsActive = true limit 1];
            for(PriceBookEntry apbe : PBE){
                if (apbe.Product2.ProductCode == '70001'){
                        insertPrice = 99.00;
                }else{
                        insertPrice = 200.00;
                }
                OrderItem LineItem = new OrderItem(
                        Quantity            = 1,
                        PricebookEntryId    = PBE[orderCnt].Id, 
                        OrderId       = Ord.Id, 
                        Line_Type__c        = 'N - Non-Stock',
                        Price_of_Discount__c = 0,
                        UnitPrice = insertPrice,
                        PreOrder_Backorder_Handling__c= 'backorder',
                        Estimated_Weight__c = 0
                    );
              itemList.add(LineItem);
              ++orderCnt;
                
            }// LOOP
        if(itemList.size() > 0){
            Ord.Registration_Product__c = 'R1M1';
            Upsert Ord;
            insert itemList;
        }    
        // Ord.Registration_Product__c = 'R1M1';
        Ord.Status = 'Order Submitted';
         ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
          cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
          cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
          cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
          cOrder.ChargentOrders__Billing_Country__c = 'United States';
          insert cOrder;
          Ord.Chargent_Order__c = cOrder.Id;
        upsert Ord;
        Ord.Status = 'Order Confirmed';
       
        upsert Ord;
        Test.stopTest();
     } 
      
      public static TestMethod void Purchase70014Test(){
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c = TestObjects.FullContact();
        c.Email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.Applicant__c = c.Id;
        Test.startTest();
            a.Registration_Level__c = 'R1';
            a.MOZO_Level__c = 'M4';
            a.Registration_Status__c = 'Renewed';
          	a.MOZO_Expiration_Date__c= system.today();
            insert a;
            //Id priceBookId = Test.getStandardPricebookId();
            PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
            Id priceBookId = pbForId.PriceBook2.Id;
            Ord.AccountId  = a.Id;
            Ord.Pricebook2Id = pricebookId;
            Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
            system.debug('##ORDER'+Ord);
            insert Ord;
            insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
          insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
            Decimal insertPrice = 0.0;
            Integer orderCnt = 0;
            List<OrderItem> itemList = new List<OrderItem>();
            List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001','70014') And IsActive = true limit 1];
            for(PriceBookEntry apbe : PBE){
                if (apbe.Product2.ProductCode == '70001'){
                        insertPrice = 99.00;
                }else{
                        insertPrice = 400.00;
                }
                OrderItem LineItem = new OrderItem(
                        Quantity            = 1,
                        PricebookEntryId    = PBE[orderCnt].Id, 
                        OrderId       = Ord.Id, 
                        Line_Type__c        = 'N - Non-Stock',
                        Price_of_Discount__c = 0,
                        UnitPrice = insertPrice,
                        PreOrder_Backorder_Handling__c= 'backorder',
                        Estimated_Weight__c = 0
                    );
              itemList.add(LineItem);
              ++orderCnt;
                
            }// LOOP
        if(itemList.size() > 0){
            Ord.Registration_Product__c = 'R1M4';
            Upsert Ord;
            insert itemList;
        } 
        Ord.Status = 'Order Submitted';
        ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
          cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
          cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
          cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
          cOrder.ChargentOrders__Billing_Country__c = 'United States';
          insert cOrder;
          Ord.Chargent_Order__c = cOrder.Id;  
        upsert Ord;
        Ord.Status = 'Order Confirmed';
          
        upsert Ord;
        Test.stopTest();
          
     } 
    public static TestMethod void Purchase70013Test(){
		          
        RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account' limit 1];
        Account a =  new Account(Name='Christian Test Church', Description='Test Church', type='Church',RecordTypeId=acctRecordType.Id);
        system.debug('<<GOT ACCT VALUE?>> '+a.Description);
        a.RecordTypeId = acctRecordType.Id;
        system.debug('<<ENTERING INTO  acct>> '+a );
        a.ShippingStreet = '5921 Walnut Hill Ln';
        a.ShippingState = 'TX';
        a.ShippingPostalCode = '75230';
        a.ShippingCountry = 'UNITED STATES';
        a.ShippingCity = 'Waco';
        Contact c = new Contact(FirstName='Baji', LastName='Shaik', Email= 'sbaji@mailinator.com');
        insert c;
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.Date_Inactive__c = system.today();
        a.Applicant__c = c.Id;
        Test.startTest();
            a.Registration_Level__c = 'R1';
            a.MOZO_Level__c = 'M3';
        	a.MOZO_Expiration_Date__c= system.today().addDays(100);
            //a.Registration_Status__c = null;
            insert a;
          	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
            Id priceBookId = pbForId.PriceBook2.Id;
          	User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
          	
 			Order Ord = new order(
            	Status='Order Open', 
            	Name='O-TEST-0', 
            	effectiveDate=System.Today() ,
           		AccountId=a.Id,
        		Type = 'Shipping',
        		Company__c = 'Awana',
        		Order_Type__c = 'SO',
        		Shipping_Country__c =  'UNITED STATES',
        		Promo_code__c= '',
        		Payment_Terms__c = 'Net 30',
        		Shipping_Type__c = 'Priority Mail', 
        		Shipping_Code__c = 'PRI',              
        		Shipping_Carrier__c = 'POST',
        		Notes__c ='Tes Order for faux client',
       			Pricebook2Id = pricebookId,
                ExtraEmail__c='someone@someone.com,test@test.com' 
        	);
            system.debug('##ORDER'+Ord);
          
            insert Ord;
          	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
            Decimal insertPrice = 0.0;
            Integer orderCnt = 0;
            List<OrderItem> itemList = new List<OrderItem>();
            List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001','70013') And IsActive = true limit 1];
            for(PriceBookEntry apbe : PBE){
                if (apbe.Product2.ProductCode == '70001'){
                        insertPrice = 99.00;
                }else{
                        insertPrice = 300.00;
                }
                OrderItem LineItem = new OrderItem(
                        Quantity            = 1,
                        PricebookEntryId    = PBE[orderCnt].Id, 
                        OrderId       = Ord.Id, 
                        Line_Type__c        = 'N - Non-Stock',
                        Price_of_Discount__c = 0,
                        UnitPrice = insertPrice,
                        PreOrder_Backorder_Handling__c= 'backorder',
                        Estimated_Weight__c = 0
                    );
              itemList.add(LineItem);
              ++orderCnt;
                
            }// LOOP
        if(itemList.size() > 0){
            Ord.Registration_Product__c = 'R1M1';
            Upsert Ord;
            insert itemList;
        }    
        // Ord.Registration_Product__c = 'R1M1';
        Ord.Status = 'Order Submitted';
         ChargentOrders__ChargentOrder__c COrder = new ChargentOrders__ChargentOrder__c();
        
          cOrder.ChargentOrders__Billing_First_Name__c = 'Test FName';
          cOrder.ChargentOrders__Billing_Last_Name__c = 'Test LName';
          cOrder.ChargentOrders__Billing_Email__c = 'somebodysorders@mailinator.com'; 
          cOrder.ChargentOrders__Billing_Country__c = 'United States';
          insert cOrder;
          Ord.Chargent_Order__c = cOrder.Id;
        upsert Ord;
        Ord.Status = 'Order Confirmed';
       
        upsert Ord;
        Test.stopTest();
     }
}//Class