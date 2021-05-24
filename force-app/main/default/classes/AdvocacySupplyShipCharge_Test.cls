/***************************************************************************************************************************************************************************************
    Programmer: Tony W.  
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    <Advocacy>
    Description: Create a Shipping Charge Opportunity against Advocacy Department (43)  
    Created:    10/27/2014 - AdvocacySupplyShipCharge_Test
***************************************************************************************************************************************************************************************/
@isTest(seeAllData=true)
public class AdvocacySupplyShipCharge_Test {
  // Have to call Orders to pick once a PT has been created so use OrderEntryStatus
  
  public static testmethod void TestAdvocacySupplyShipCharge(){
        List<order> Orders = new List<order>();
        List<Id> contactIds = new List<Id>();
        List<Id> orgIds = new List<Id>();
        //User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];
        RecordType rec = [Select Id from RecordType where SObjectType = 'Opportunity' and Name = 'Orders'];  // get Orders record type

        List<npe5__Affiliation__c> affs = [Select Id,Other_Role__c,npe5__Organization__c,npe5__Status__c, npe5__Contact__c 
                                           FROM npe5__Affiliation__c 
                                           WHERE npe5__Organization__r.RecordType.Name = 'US Organization' and Authorized_Purchaser__c = true limit 3];
      
        for(npe5__Affiliation__c aff : affs){
            orgIds.add(aff.npe5__Organization__c);
            contactIds.add(aff.npe5__Contact__c);   
        }
        List<Account> a=[Select Id, Default_Shipping_Address__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry 
                        from Account WHERE Id =: orgIds];
        List<Contact> c=[SELECT Id,FirstName,LastName
                        FROM Contact WHERE Id =: contactIds];
      
        // Create a new Advocate Order and add 3 Adocate line items
        // 
        List<Order> testOpp = new List<Order>();
        Integer aff_Limit = 1;//affs.size();
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
      for(Integer i=0;i < aff_Limit; i++){
        
        testOpp.add(TestObjects.NewOrder());
        testOpp[i].Name = testOpp[i].Name+00+i;
        testOpp[i].AccountId = a[0].id;
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
       /* testOpp[i].ChargentSFA__Billing_First__c = c[0].FirstName;
        testOpp[i].ChargentSFA__Billing_Last__c =  c[0].LastName;  
        testOpp[i].ChargentSFA__Billing_Email__c = 'somebodysorders@mailinator.com';  
        */
            //testOpp[i].OwnerId = ouser.Id;
        testOpp[i].Payment_Terms__c = 'Net 30';
        testOpp[i].Shipping_Type__c = 'Priority Mail'; 
        testOpp[i].Shipping_Code__c = 'PRI';              
        testOpp[i].Shipping_Carrier__c = 'POST';
        //testOpp[i].Notes__c ='Tes Order for faux client';
        system.debug('PriceBook: '+PriceBook);
        testOpp[i].Pricebook2Id = PriceBook.Id;
        system.debug('<< BEFORE ORDER ITEMS >> '+testOpp);
      
        
        
        
           
    }  //LOOP
    Test.startTest();
    insert testOpp; 
      //==================Create Opportunity Line Item===============================
      for(Integer i=0;i<aff_Limit;i++){
        OrderEntryServices.AddProduct(testOpp[i].Id,'21303',1,0,0,'','S - Stock Inventory Item');
        //OrderEntryServices.AddProduct(testOpp[i].Id,'21306',1,0,0,'','S - Stock Inventory Item');
        //OrderEntryServices.AddProduct(testOpp[i].Id,'21307',1,0,0,'','S - Stock Inventory Item');
        OrderEntryServices.AddProduct(testOpp[i].Id,'43490',1,7.50,0,'','F - Freight');
        OrderEntryServices.AddProduct(testOpp[i].Id,'57779',1,1.50,0,'','T - Text Line');
      }
   //==================Set Cretain Frt Line Item Descriptions with Exception messages to test code exceptions===============================
    system.debug('<< OPP AFTER ORDER ITEMS >> '+testOpp); 
    
   //=====================CALL TRIGGER OpportunityAfterUpdate with  1st FOR LOOP below=================================
    for(Integer i=0;i<aff_Limit;I++){
        testOpp[i].Status = 'Order Being Fulfilled';
        
    }
   //=====================FORCE TRIGGER OpportunityAfterUpdate To Call AdvocacySupplyShipCharge Class=================================   
    Update testOpp;
    for(Integer i=0;i<aff_Limit;I++){
        testOpp[i].Opportunity_Source__c = 'Advocacy';
        testOpp[i].Status = 'Order Invoiced';  
    }
      
    Update testOpp; 
    Test.stoptest();
      
   //==================== Test Each OLI Individually into the clas Module ========================
  
     

  }// TestAdvocacySupplyShipCharge
}//Class