/************************************************************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            MOZO - Test_Tax2WSDL
    Original:           3/4/2015 - Used to test tax2
************************************************************************************************************************/ 
@IsTest(SeeAllData=true)
 public class Test_Tax2WSDL{
 public static testMethod void testTax2Wsdl()
  {
    Test.setMock(WebServiceMock.class, new Tax2WebServiceMockImpl());  
    Tax2Wsdl tax2OppId = new Tax2Wsdl();
        Tax2Wsdl.Provide_ServicePort AvalaraSrvPort = new Tax2Wsdl.Provide_ServicePort();
        /* KEEP THE FOLLOWING COMMENTED CODE IN CASE TESTOBJECTFACTORY CLASS IS NOT UP TO COVERAGE*/
        RecordType  getRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
        User ouser = [SELECT Id from User where Name = 'Awana Applications' limit 1];    
        Account a2 = new Account();
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
        // Profile portal_profiles = [Select Id, Name From Profile Where  Name  = 'Awana - Head of Household'];

       // Profile UserProfile = portal_profiles;
        Contact c = new Contact(FirstName = 'Marty',
                                LastName = 'Faye',
                                Email='mfaye@mailinator.com');
        insert c;
      /*  User currentOwner = new User(
                                ContactId = c.Id,
                                FirstName='Marty',
                                LastName='Faye',
                                UserName='mfaye@mailinator.com.test',
                                email='mfaye@mailinator.com',
                                alias='mafaye',
                                TimeZoneSidKey = 'America/Chicago',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US', 
                                EmailEncodingKey = 'ISO-8859-1',
                                CommunityNickName = c.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
                                ProfileId =UserProfile.Id);
        insert currentOwner; */
      
        User currentOwner = [SELECT id, Name FROM User WHERE id=:UserInfo.getUserId()];
        
        a2.Name = 'Holy LIfe Church';
        a2.ShippingStreet = '144 Clipper St';
        a2.Mailing_Street_1__c ='2712 41st Ave' ;
        a2.ShippingCity = 'San Francisco';
        a2.Mailing_City__c = 'San Francisco';
        a2.ShippingState = 'CA';
        a2.Mailing_State_Province__c='CA';
        a2.ShippingCountry ='United States';
        a2.Mailing_Country__c='United States';
        a2.ShippingPostalCode = '94116';
        a2.Mailing_Zip_Postal_Code__c = '94116';
        a2.BillingStreet='144 Clipper St';
        a2.Physical_Street_1__c ='2638 16th Ave';
        a2.BillingCity = 'San Francisco';
        a2.Physical_City__c ='San Francisco';
        a2.BillingState ='CA';
        a2.Physical_State__c = 'CA';
        a2.BillingCountry = 'United States';
        a2.PhysicalCountry__c = 'United States';
        a2.BillingPostalCode = '94116';
        a2.Physical_Zip__c = '94114';
        a2.RecordType =getRecordType;
        a2.OwnerId=currentOwner.Id;
        insert a2;
        
        Order testopp = new Order();
        testOpp = TestObjects.NewOpportunity();
        OrderEntryServices.Result result = OrderEntryServices.GetNextOrderNumber('O',a2.Mailing_Address_Book__c); 
        system.debug('<<ORDER NAME>> '+result.StringOutput);
        testOpp.Name = 'O-TEST-111';
        testopp.Type = 'Shipping';
        testopp.Company__c = 'Awana';
        testopp.Order_Type__c = 'SO';
        testopp.Shipping_Address__c= a2.Default_Shipping_Address__c;
        testopp.Ship_to_Name__c = c.FirstName +' '+ c.LastName;
        testopp.Ship_to_First_Name__c = c.FirstName;
        testopp.Ship_to_Last_Name__c = c.LastName;
        testopp.Shipping_Street__c = String.valueOf(a2.ShippingStreet);
        testopp.Shipping_City__c = a2.ShippingCity;
        testopp.Shipping_State__c  =  a2.ShippingState; 
        testopp.Shipping_Zip_Code__c = a2.ShippingPostalCode;
        testopp.Shipping_Country__c =  'UNITED STATES';
        /*testopp.ChargentSFA__Billing_First__c = c.FirstName;
        testopp.ChargentSFA__Billing_Last__c =  c.LastName;  
        testopp.ChargentSFA__Billing_Email__c = 'somebodysorders@mailinator.com';  */
        testopp.OwnerId = ouser.Id;
        testopp.Payment_Terms__c = 'Net 30';
        testopp.Shipping_Type__c = 'Priority Mail'; 
        testopp.Shipping_Code__c = 'PRI';              
        testopp.Shipping_Carrier__c = 'POST';
        testopp.Notes__c ='Tes Order for faux client';
        //system.debug('PriceBook: '+PriceBook);
       // testopp.Pricebook2Id = PriceBook.Id;
        testopp.AccountId = a2.Id;       
        insert testopp; 
       
      // Opportunity testopp = TestObjectFactory.NewOpportunity();
        // Call the method that invokes a callout   
        Test.startTest();
        Decimal output =  AvalaraSrvPort.Provide_Service( String.valueOf(testopp.Id));
         // Verify that a fake result is returned  
          System.assertEquals(2.75, output); 
        Test.stopTest();
        
  }

  public static testMethod void testTax2Request()
  {
    Tax2Request tax2Rq = new Tax2Request();
    Tax2Request.OppID_element tax2Rq_ID = new Tax2Request.OppID_element();
        tax2Rq_ID.ID = '0000345'; 
  }

  public static testMethod void testTax2Response()
  {
    Tax2Response taxPR = new Tax2Response();
    Tax2Response.totalTax_element tte = new Tax2Response.totalTax_element();
        tte.tax = 4.2;
  }

}//CLass