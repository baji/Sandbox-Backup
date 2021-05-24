//*********************************************************************************************************************************************************************************************
// Developer: Shaik Baji,
// Modified by Tony Williams
// Created: 06-10-2014 - Purpose to test all Resr COntrollers for SSO
// Updated: 07/15/2014 - Updated update parameter lists for Subscription Rest Controller and Addrest Rest Controller
  //  Updated:        11/7/2017 Added SeeAllData = true by Sohil
//****************************************************************************************************************************/

@isTest(SeeAllData = true)
public class Test_RestServiceController {
    //Test Method for updating the Contact/Profile
    static testMethod void testDoPostContactUpdate(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/RestAccounts/updateContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
       // Contact con = [select Id,FirstName,LastName,HomePhone,MobilePhone,Birthdate  from Contact Limit 1];
        Contact con = new Contact(
                        FirstName = 'Rafael',
                        LastName = 'Aguilara',
                        MobilePhone = '90222334455',
                        HomePhone = '7788996654',
                        Birthdate = Date.newInstance(1964, 2, 17)
                    );
        insert con;
        
        /* Commented by Mayur for deployment 12/06/17 as Subscription__c is not used
        //String postResult = RestResourceController.updateContact(String.valueOf(con.Id),con.FirstName,con.LastName,'1122334455','05/20/2014','7788996655');
        //String postResult1 = RestResourceController.updateContact('asdfas002','TestFirst','TestLast','1112223334','','4567891234');
        Mayur Comment ends*/ 
    }
    //Test Method for getting the connections
    static testMethod void testDoGet(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         Contact con = new Contact(
                        FirstName = 'Rafael',
                        LastName = 'Aguilara',
                        MobilePhone = '90222334455',
                        HomePhone = '7788996654',
                        Birthdate =  Date.newInstance(1964, 2, 17)
                    );
        insert con;
        //Contact contact = [select Id,Name from Contact where Active__c = true Limit 1];
                              
       // req.requestURI = '/services/apexrest/Connections/displayConnections/'+contact.Id;  
        req.requestURI = '/services/apexrest/Connections/displayConnections/'+con.Id; 
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
        
        List<npe5__Affiliation__c> results;
        
        results = ConnectionRestController.displayConnections();       
    
    }
    //Test Method for getting subscription
    static testMethod void testDoGetSubscription(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert contact;        
                     
        req.requestURI = '/services/apexrest/Subscription/displaySubscriptions/'+contact.Id;  
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Contact results;
        
        /* Commented by Mayur for deployment 12/06/17 as Subscription__c is not used
        
        results = SubscriptionRestController.displaySubscriptions();
        Mayur Comment ends*/ 
    }
    //Test Method for updating the subscriptions
    static testMethod void testDoPostSubscription(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Subscription/updateSubscriptions';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        String Country = '';
        
        Contact subcs = new Contact();
        subcs.FirstName = 'Baji';
        subcs.LastName = 'Basha';
        subcs.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert subcs; 
        
        Contact subcs1 = new Contact();
        subcs1.FirstName = 'Baji';
        subcs1.LastName = 'Basha';
        subcs1.Email = ''; 
        insert subcs1;
        
        //Contact subcs = [select FirstName,LastName, Email,OtherCountry,Awana_Store_Newsletter__c,ART_Announcements_Newsletter__c,Awana_Youth_Ministry_Newsletter__c,Awana_Hispanic_Ministry_Newsletter__c,Daily_Blog__c From Contact where Name <> null Limit 1];
        Country = subcs.OtherCountry;
        if(subcs.OtherCountry == null  || subcs.OtherCountry == ''){
             //subcs = [select FirstName,LastName, Email,MailingCountry,Awana_Store_Newsletter__c,ART_Announcements_Newsletter__c,Awana_Youth_Ministry_Newsletter__c,Awana_Hispanic_Ministry_Newsletter__c,Daily_Blog__c From Contact Limit 1];   
             Country = subcs.MailingCountry;
        }
        
        /* Commented by Mayur for deployment 12/06/17 as Subscription__c is not used
        
        String postResult = SubscriptionRestController.updateSubscriptions(subcs.FirstName,subcs.LastName,subcs.Email, Country,true,true,true,true,true);
        String postResult1 = SubscriptionRestController.updateSubscriptions('Test','Tester','test@ecgroup-intl.com','UNITED STATES',true,true,true,true,true);
        Mayur Comment ends*/ 
    }
    //Test Method for updating the address
    static testMethod void testDoPostAddressUpdate(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Address/updateAddress';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        Account account = new Account();
        account.Name = 'Baji Basha';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert contact;
        
        //Account account = [select Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry From Account Limit 1];
        //Contact contact = [select Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry From Contact Limit 1];
        
        String postResult = AddressRestController.updateAddress(String.valueOf(contact.Id),String.valueOf(account.Id),'1354 Nightingale','Bartlett','IL','60111','United States','1354 Nightingale','Bartlett','IL','60111','United States','1354 Nightingale','Bartlett','IL','60111','United States','1354 Nightingale','Bartlett','IL','60111','United States');
        String postResult1 = AddressRestController.updateAddress('adfa003','asdfas001','1354 Nightingale','Bartlett','IL','60111','United States','1354 Nightingale','Bartlett','IL','60111','United States','1354 Nightingale','Bartlett','IL','60111','United States','1354 Nightingale','Bartlett','IL','60111','United States');        
    }
    
    //Test Method for adding the address
    static testMethod void testDoPostAddress(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddAddress/insertAddress';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        Account account = new Account();
        account.Name = 'Baji Basha';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert contact;
        
        //Account account = [select Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry From Account Limit 1];
        //Contact contact = [select Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry From Contact Limit 1];
        
        String postResultAcc = AddressRestControllerNew.insertAddress('Billing',String.valueOf(contact.Id),String.valueOf(account.Id),'1354 Nightingale','Bartlett','IL','60111','United States');
        String postResultAcc1 = AddressRestControllerNew.insertAddress('Shipping',String.valueOf(contact.Id),String.valueOf(account.Id),'1354 Nightingale','Bartlett','IL','60111','United States');
        
        String postResultCon = AddressRestControllerNew.insertAddress('Mailing',String.valueOf(contact.Id),String.valueOf(account.Id),'1354 Nightingale','Bartlett','IL','60111','United States');
        String postResultCon1 = AddressRestControllerNew.insertAddress('Other',String.valueOf(contact.Id),String.valueOf(account.Id),'1354 Nightingale','Bartlett','IL','60111','United States');
        
       
        String postResultError = AddressRestControllerNew.insertAddress('work','adsfa003','asdfsa001','1354 Nightingale','Bartlett','IL','60111','United States');       
    }
    
    //Test method for NewConnection
    static testMethod void testDoPostNew(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/NewConnection/insertConnection';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        //Account account = [select Id,Name from Account Limit 1];
        //Contact contact = [select Id,Name from Contact Limit 1];
        
        Account account = new Account();
        account.Name = 'Baji Basha';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert contact;
        
        String postResult = ConnectionRestControllerNew.insertConnection(String.valueOf(account.Id),String.valueOf(contact.Id),'Game Director','Youth Pastor / Director');
        String postResult1 = ConnectionRestControllerNew.insertConnection('asdf001','asdfa003','Game Director','Youth Pastor / Director');
        
    }
    //Test method for DeleteConnection
    static testMethod void testDoPostDelete(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DeleteConnection/deleteConnection';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        Account account = new Account();
        account.Name = 'Baji Basha';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert contact;
        
        //npe5__Affiliation__c aff = [select Id,Awana_Role__c,Church_Role__c,npe5__Contact__c,npe5__Organization__c,Other_Role__c,npe5__Status__c  From npe5__Affiliation__c Limit 1];
        
        npe5__Affiliation__c aff =  new npe5__Affiliation__c();
        aff.Awana_Role__c = 'Game Director';
        aff.Church_Role__c = 'Youth Pastor / Director';
        aff.npe5__Contact__c = contact.Id;
        aff.npe5__Organization__c = account.Id;
        aff.Other_Role__c = 'Church Staff Member';
        aff.npe5__Status__c = 'Current';
        insert aff;
        
        String postResult = ConnectionRestControllerDelete.deleteConnection(String.valueOf(aff.Id));
        String postResult1 = ConnectionRestControllerDelete.deleteConnection('asdf001');
        
    }
    
    //Test Method for updating the connections
    static testMethod void testDoPost(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Connections/updateConnections';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        //npe5__Affiliation__c aff = [select Id,Awana_Role__c,Church_Role__c,npe5__Contact__c,npe5__Organization__c,Other_Role__c,npe5__Status__c  From npe5__Affiliation__c Limit 1];
        
        Account account = new Account();
        account.Name = 'Baji Basha';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com'; 
        insert contact;
        
        npe5__Affiliation__c aff =  new npe5__Affiliation__c();
        aff.Awana_Role__c = 'Game Director';
        aff.Church_Role__c = 'Youth Pastor / Director';
        aff.npe5__Contact__c = contact.Id;
        aff.npe5__Organization__c = account.Id;
        aff.Other_Role__c = 'Church Staff Member';
        aff.npe5__Status__c = 'Current';
        insert aff;
        
        String postResult = ConnectionRestController.updateConnections(String.valueOf(aff.Id),'Game Director','Youth Pastor / Director','','current');
        String postResult1 = ConnectionRestController.updateConnections('asdfas002','Game Director','Youth Pastor / Director','','current');
        
    }
    
    
    /*
    //Test Method for updating Gigya UIDs in contacts
    static testMethod void testDoPostGigyaUID(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Gigya/updateGigyaUID';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        Contact con = [select Id,Email,Gigya_UID__c from Contact where Email <> null Limit 1];
        
        String postResult = GigyaRestController.updateGigyaUID('asdfsdaf',con.Email);
        //String postResult1 = GigyaRestController.updateGigyaUID('asdf','assa');
       
    }
    */
}