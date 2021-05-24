//*********************************************************************************************************************************************************************************************
// Developer: Shaik Baji,
// Created: 06-10-2014 - Purpose to test all Resr COntrollers for SSO
// Updated: 07/15/2014 - Updated update parameter lists for Subscription Rest Controller and Addrest Rest Controller
// Updated: 11/7/2017 - Added SeeAllData = true by Sohil
//***************************************************************************************************************************************************************************************************

@isTest(SeeAllData = true)
public class Test_GigyaRestController{
    //Test Method for updating Gigya UIDs in contacts
    public static testMethod void testDoPostGigyaUID(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Gigya/updateGigyaUID';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        //Contact con = [select Id,Email,Gigya_UID__c from Contact where Email <> null Limit 1];
        Contact contact = new Contact();
        contact.FirstName = 'Baji';
        contact.LastName = 'Basha';
        contact.Email = 'shaikbaji.a@ecgroup-intl.com';
        contact.Gigya_UID__c = '';
        insert contact;
        
        system.debug('HERE IS CONTACT: '+contact);
        String postResult = GigyaRestController.updateGigyaUID('asdfa',contact.Email);
        String postResult1 = GigyaRestController.updateGigyaUID(null,'');
       
   }
    
    
     


}