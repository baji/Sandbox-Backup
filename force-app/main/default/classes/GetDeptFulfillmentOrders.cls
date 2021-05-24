/***************************************************************************************************************************************************************************************
    Programmer: Tony W.
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    <ALL> creates opportunities containing any Kit Packet items in Salesforce for any Department.
    Created:    10/07/2014
***************************************************************************************************************************************************************************************/

public class GetDeptFulfillmentOrders{ 
    public class GetDeptFulfillmentOrdersException extends Exception{}
        public static void handler(List<Address__c> Addresses, List<Product2> productList,String customerID, String projectType,String purchaserEmail){
        //1. Get the list of MORE Products and the Marketing Department for MORE
        	system.debug('<<Addresses>> '+Addresses+' <<ACCT NAME>> '+Addresses[0].Account__c);
       //   List<Product2> productList = [Select p.ProductCode, p.List_Price__c, p.Line_Type__c From Product2 p where ProductCode in ('97796') ];  
        	List<Account> someDept = [Select Id,BillingStreet,BillingState,Billing_County__c,BillingPostalCode, BillingCountry, BillingCity,Shipping_Address_Book__c, Shipping_Last_Name__c, Shipping_First_Name__c, ShippingStreet,ShippingState,ShippingPostalCode, ShippingCountry,ShippingCity  from Account WHERE Mailing_Address_Book__c =:customerID LIMIT 1];
        	if(someDept.size() > 0){
            	String affiliateID = String.valueOf(someDept[0].Id);
        
        //2. Get Contact Purchaser of Dept.
            	npe5__Affiliation__c GetAffPurchaser = [Select npe5__Contact__c from npe5__Affiliation__c where Authorized_Purchaser__c = true and npe5__Organization__c =: someDept[0].Id limit 1]; 
            	system.debug('PURCHASERID: '+GetAffPurchaser.npe5__Contact__c);
            	Contact purchaser = [Select Id, FirstName, LastName,MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity,Email,Phone from Contact where Id =: String.valueOf(GetAffPurchaser.npe5__Contact__c) limit 1];
            	system.debug('PURCHASER CONTACT: '+purchaser );
            	Fulfill_Orders( Addresses, productList, purchaser,someDept, customerID, projectType, purchaserEmail);  //NOTE: Add Department and its contact email  parameter when Thara gives it
        	}//If SomeDept > 0
    }//Handler
    private static void Fulfill_Orders(List<Address__c> Addresses, List<Product2> productList,Contact purchaser, List<Account> someDept, String customerId,String projectType, String purchaserEmail){
		system.debug('<<Addresses>> '+Addresses);
        List<Opportunity> allOrders = new List<Opportunity>();
        RecordType rec = [Select Id from RecordType where SObjectType = 'Opportunity' and Name = 'Orders'];  // get Orders record type
        User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
        //OrderEntryServices.Result r = new OrderEntryServices.Result();
        OrderEntryServices.Result rOrderTF = new OrderEntryServices.Result(); // Helps with naming scope convention
        OrderEntryServices.Result NextOrderNameResult = new OrderEntryServices.Result();
        // For all MORE Showing Addresses that were inserted, ceate the fulfillment order
        String PriceBookName = 'Catalog Price Book';
        try{
        	for(Address__c someAddress : Addresses){
            	system.debug('<<ADDRESS>> '+someAddress);
            	if(Test.isRunningTest()){
                	if(someAddress.First_Name__c=='TestEXCEPTION'){
                    		throw new GetDeptFulfillmentOrdersException();
                	}  
            	}// Running Test 
                Opportunity autoOrder = new Opportunity();
            	NextOrderNameResult = OrderEntryServices.GetNextOrderNumber('O',customerId );
        		autoOrder.Name = NextOrderNameResult.StringOutput;
            	PriceBook2 PriceBook = [SELECT Id, Name FROM PriceBook2 WHERE isActive = true and Name =: PriceBookName  limit 1];
            	autoOrder.CurrencyISOCode ='USD'; 
            	autoOrder.StageName = 'Order Open';
            	autoOrder.CloseDate = Date.Today();
            	autoOrder.PriceBook2Id = PriceBook.Id;
            	autoOrder.Company__c = 'Awana';  
            	autoOrder.AccountID = someDept[0].Id;
            	system.debug('<<Saved Order >> '+autoOrder); 
            	autoOrder.RecordTypeId = rec.Id;
            	autoOrder.Type = 'Shipping';
            	autoOrder.Order_Type__c = 'SO';
            	autoOrder.Shipping_Address__c = someAddress.Id;
            	autoOrder.Ship_to_Name__c = someAddress.First_Name__c +' '+someAddress.Last_Name__c;
            	autoOrder.Ship_to_First_Name__c = someAddress.First_Name__c;
            	autoOrder.Ship_to_Last_Name__c = someAddress.Last_Name__c;
            	autoOrder.Shipping_Street__c = someAddress.Address_Line_1__c;
            	autoOrder.Shipping_City__c = someAddress.City__c;
            	autoOrder.Shipping_State__c =  someAddress.State__c;
            	autoOrder.Shipping_Zip_Code__c = someAddress.Zip_Code__c;
            	if(someAddress.Country__c == null || someAddress.Country__c ==''){
                	someAddress.Country__c = 'UNITED STATES';
            	}
                autoOrder.Shipping_Country__c = someAddress.Country__c;
                /*autoOrder.ChargentSFA__Billing_First__c = purchaser.FirstName;
            	autoOrder.ChargentSFA__Billing_Last__c = purchaser.LastName;
            	autoOrder.ChargentSFA__Billing_Phone__c = purchaser.Phone;
            	autoOrder.ChargentSFA__Billing_Email__c = purchaserEmail;
            	autoOrder.ChargentSFA__Billing_Address__c = someDept[0].BillingStreet;
            	autoOrder.ChargentSFA__Billing_City__c = someDept[0].BillingCity;
            	autoOrder.ChargentSFA__Billing_Zip__c = someDept[0].BillingPostalCode;
            	autoOrder.ChargentSFA__Billing_State__c = someDept[0].BillingState;
            	autoOrder.ChargentSFA__Billing_Country__c = someDept[0].BillingCountry;*/
            	autoOrder.Billing_County__c = someDept[0].Billing_County__c;
            	autoOrder.OwnerId = ouser.Id;
            	autoOrder.Payment_Terms__c = 'Internal';
            	autoOrder.Shipping_Type__c = 'Standard';
            	autoOrder.Shipping_Code__c = 'Standard';              
            	autoOrder.Shipping_Carrier__c = 'Rate Shop';
            	autoOrder.Notes__c =projectType+' Kit for customer account: '+someAddress.Account__c;
                autoOrder.Opportunity_Source__c = 'Customer Service';
            	system.debug('<< BEFORE ORDER ITEMS >> '+autoOrder);
                allOrders.add(autoOrder);
        	}// Address Loop 
            if(allOrders.size() > 0){
                OrderEntryServices.Result rOrder = new OrderEntryServices.Result(); 
            	List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>();
    			upsert allOrders; // Get Opp Ids
                // Get Line Items
                for(Opportunity autoOrder : allOrders){// Test just this right now
                   contactRoles.add(new OpportunityContactRole(ContactId = purchaser.Id, OpportunityId = autoOrder.Id));
                   for(Product2 p2 : productList){
                    	rOrder= OrderEntryServices.AddProduct(autoOrder.Id, p2.ProductCode, 1, p2.List_Price__c,0,'',p2.Line_Type__c);  
                	}
                   	rOrderTF = OrderEntryServices.AddProduct(autoOrder.Id,'43490',1,7.50,0,'','F - Freight');
                   	system.debug('<<FTT: rOrderTF>> '+(OpportunityLineItem)rOrderTF.ObjectOutput);
                   	rOrderTF = OrderEntryServices.AddProduct(autoOrder.Id,'57779',1,0,0,'','T - Text Line');
                   	system.debug('<<TAX: rOrderTF>> '+(OpportunityLineItem)rOrderTF.ObjectOutput);
                    autoOrder.StageName = 'Order Submitted';
                }// Loop for  Order
                upsert allOrders;
                if(contactRoles.size() > 0){
                	insert contactRoles;
                }
            }
        }catch(GetDeptFulfillmentOrdersException gdfoe){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        		String[] toAddresses = new String[] {'tonyw@awana.org','jenniferl@awana.org'};
        		mail.setToAddresses(toAddresses);
        		mail.setSubject('Apex Order Errors for Project -->'+projectType);
        		mail.setPlainTextBody
             		('Unrecoverable Exception from Order Fullfilment See: '+gdfoe);
        		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail  });  
    	}// Catch 
        
    }//Method FulFill_Orders
	
}// Class GetDeptFulfillmentOrders