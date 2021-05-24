/****************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    General (All cases)
    Description: Genertates code coverage for trigger UpdateOrder.
*******************************************************************************************************************************************/
 
@isTest(SeeAllData=true)
public without sharing class UpdateOrder_Test {
    @isTest(SeeAllData=true)
    public static void TestUpdateOrder70001(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
       	Test.startTest();
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001') And IsActive = true limit 1];
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
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70001
    
    @isTest(SeeAllData=true)
    public static void TestUpdateOrder70011(){
        //for order null condition
    	 OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
        Test.startTest();
        	
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
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
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
	Test.stopTest();
     
    }// 70011
     @isTest(SeeAllData=true)
    public static void TestUpdateOrder70011M(){
        //for order null condition
       	OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
        Test.startTest();
        	
        	//Id priceBookId = Test.getStandardPricebookId();
        	Ord.AccountId  = a.Id;
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
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
			insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70011M
 	@isTest(SeeAllData=true)
   public static void TestUpdateOrder70012(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
       
       	Test.startTest();
        	//Id priceBookId = Test.getStandardPricebookId();
       		PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70012') And IsActive = true limit 1];
        	for(PriceBookEntry apbe : PBE){
            	if (apbe.Product2.ProductCode == '70001'){
                	insertPrice = 99.00;
            	}else{
                	insertPrice = 260.00;
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
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70012
     @isTest(SeeAllData=true)
    public static void TestUpdateOrder70012M(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
      	Test.startTest();
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70012') And IsActive = true limit 1];
        	for(PriceBookEntry apbe : PBE){
            	if (apbe.Product2.ProductCode == '70001'){
                	insertPrice = 99.00;
            	}else{
                	insertPrice = 260.00;
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
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70012M
   @isTest(SeeAllData=true)
   public static void TestUpdateOrder70013(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
       
      	Test.startTest();
         	
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70013') And IsActive = true limit 1];
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
            	Ord.Registration_Product__c = 'R1';
            	Upsert Ord;
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70013
      @isTest(SeeAllData=true)
    public static void TestUpdateOrder70013M(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
       	Test.startTest();
         	
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70013') And IsActive = true limit 1];
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
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70013M
   @isTest(SeeAllData=true)
   public static void TestUpdateOrder70014(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
       
     	Test.startTest();
         	
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70014') And IsActive = true limit 1];
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
            	Ord.Registration_Product__c = 'R1';
            	Upsert Ord;
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
		Test.stopTest();
     
    }// 70014
     @isTest(SeeAllData=true)
    public static void TestUpdateOrder70014M(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
 		Test.startTest();
        	
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70014') And IsActive = true limit 1];
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
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
	Test.stopTest();
     
    }// 70013M
   @isTest(SeeAllData=true)
   public static void TestUpdateOrder70005(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
         Test.startTest();
         	
        	//Id priceBookId = Test.getStandardPricebookId();
       		PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = 'R1';
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70005') And IsActive = true limit 1];
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
                	Estimated_Weight__c = 0,
                	Upgrade_Level__c = 'M2'
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
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
	Test.stopTest();
     
    }// 70005
    @isTest(SeeAllData=true)
   public static void TestUpdateOrder70005U(){// Hits last Else stmt for 70005
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
       
        Test.startTest();
         	
        	//Id priceBookId = Test.getStandardPricebookId();
       		PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70005') And IsActive = true limit 1];
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
                	Estimated_Weight__c = 0,
                	Upgrade_Level__c = 'M2'
              );
            	itemList.add(LineItem);
       			++orderCnt;
                
        	}// LOOP
        	if(itemList.size() > 0){
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
	Test.stopTest();
     
    }// 70005U
    @isTest(SeeAllData=true)
   public static void TestUpdateOrder81605(){
        //for order null condition
        OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
         Test.startTest();
         	
        	//Id priceBookId = Test.getStandardPricebookId();
       		PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = 'R1';
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001','81605') And IsActive = true limit 1];
        	for(PriceBookEntry apbe : PBE){
            	if (apbe.Product2.ProductCode == '70001'){
                	insertPrice = 99.00;
                   
            	}else{
                	insertPrice = 0.00;
                    
                    
            	}
					OrderItem LineItem = new OrderItem(
            		Quantity            = 1,
                	PricebookEntryId    = PBE[orderCnt].Id, 
                	OrderId       = Ord.Id, 
                	Line_Type__c        = 'N - Non-Stock',
                	Price_of_Discount__c = 0,
                    Downloadable_Product_URL__c = 'https://www.awana.org',
                	UnitPrice = insertPrice,
               		PreOrder_Backorder_Handling__c= 'backorder',
                	Estimated_Weight__c = 0
              		);
            	itemList.add(LineItem);
       			++orderCnt;
                
        	}// LOOP
        	if(itemList.size() > 0){
            	//Ord.Registration_Product__c = 'R1';
            	//Upsert Ord;
				insert itemList;
        	}
        	Ord.Status = 'Order Submitted';
        	upsert Ord;
        	Ord.Status = 'Order Confirmed';
        	upsert Ord;
	Test.stopTest();
     
    }// Downloadables
     @isTest(SeeAllData=true)
    public static void TestUpdateOrderDeleteR1(){
        //for order null condition
    	 OrderEntryServices.removeDiscount(null,new List<String>());
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
        
        Test.startTest();
        	
        	//Id priceBookId = Test.getStandardPricebookId();
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
        	Id priceBookId = pbForId.PriceBook2.Id;
        	Ord.AccountId  = a.Id;
        	Ord.Pricebook2Id = pricebookId;
        	Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ord);
        	Ord.Registration_Product__c = null;
        	insert Ord;
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ord.PriceBook2Id and Product2.ProductCode in ('70001') And IsActive = true limit 1];
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
        	delete itemList;
        	
	Test.stopTest();
     
    }// TestUpdateOrderDeleteItem
    @isTest(SeeAllData=true)
    public static void TestUpdateOrderDeleteM1(){
        //for order null condition
    	OrderEntryServices.removeDiscount(null,new List<String>());
       // Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.FullAccount();
        Contact c =  TestObjects.FullContact();
       	c.email = 'sbaji@mailinator.com';
        insert c;
        a.Name='Test Account';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        a.ShippingCountry = 'United States';
        a.ShippingCity = 'Streamwood';
        a.ShippingState = 'IL';
        a.ShippingPostalCode = '60107';
        a.ShippingStreet = '1 E Bode Road';
     	a.Registration_Level__c = 'R0';
        a.MOZO_Level__c = 'M0';
        a.Registration_Status__c = 'Dropped';
       	a.Applicant__c = c.Id;
        a.BillingCountry = 'United States';
        a.BillingCity = 'Chicago';
		a.BillingState = 'IL';
        a.BillingPostalCode = '60628';
       	upsert a;
     	c.AccountId = a.id; 
        upsert c;
       // Decimal[] prices = new Decimal[]{200.00,260.00,300.00,400.00};
        Decimal[] prices = new Decimal[]{200.00,260.00,300.00};    
      //  String[] Codes= new String[]{'M1','M2','M3','M4'};
        String[] Codes= new String[]{'M1','M2','M3'};    
       // String[] productCodes = new String[]{'70011','70012','70013','70014'};
        String[] productCodes = new String[]{'70011','70012','70013'};
        List<Order> Ords = new List<Order>();
        Test.startTest();
        for(Integer i=0;i < productCodes.size(); i++){
        	//Id priceBookId = Test.getStandardPricebookId();
        	// CREATE ORDERS HERE JUST USING NAme with counter index
        	PriceBookEntry pbForID = [Select Id,PriceBook2.Id From PriceBookEntry Where PriceBook2.Name like '%Standard Price%' limit 1];
            Ords.add(new Order(Name='TEST CHURCH'+i));
        	Id priceBookId = pbForId.PriceBook2.Id;
            Ords[i].EffectiveDate = system.today();
            Ords[i].Status = 'Order Open';          
        	Ords[i].AccountId  = a.Id;
        	Ords[i].Pricebook2Id = pricebookId;
        	Ords[i].ExtraEmail__c = 'someone@someone.com,test@test.com';
        	system.debug('##ORDER'+Ords);
        	Ords[i].Registration_Product__c = null;
        	insert Ords[i];
        
        	insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ords[i].Id);
       		Decimal insertPrice = 0.0;
        	Integer orderCnt = 0;
       		List<OrderItem> itemList = new List<OrderItem>();
 			List<PriceBookEntry> PBE = [Select Id,Product2.ProductCode  From PriceBookEntry Where PriceBook2.Id = :Ords[i].PriceBook2Id and Product2.ProductCode =: productCodes[i] And IsActive = true limit 1];
        	for(PriceBookEntry apbe : PBE){
            	if (apbe.Product2.ProductCode == '70001'){
                	insertPrice = 99.00;
            	}else{
                	insertPrice = prices[i];
            	}
				OrderItem LineItem = new OrderItem(
            		Quantity            = 1,
                	PricebookEntryId    = PBE[orderCnt].Id, 
                	OrderId       = Ords[i].Id, 
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
            	Ords[i].Registration_Product__c = Codes[i];
            	Upsert Ords[i];
				insert itemList;
        	}
        	delete itemList;
        }
	Test.stopTest();
     
    }// TestUpdateOrderDeleteM1
   
     
}//Class