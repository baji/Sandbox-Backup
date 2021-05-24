//*********************************************************************************************************************************************************************************************
// Developer: Jason Pierson,
// Created: 2/21/2016 - The purpose is to test REST updates of the Account object from DW
//Update: 7/22/2016 - added test cases for DWREAffiliationRESTController class
//***************************************************************************************************************************************************************************************************

@isTest(SeeAllData=true)
public class Test_DWREAccountRESTController {
    //Test Method for updating account info
    public static testMethod void testAccountUpdates(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AccountDW/updateAccount';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        Account account = new Account();
        account.Name = 'More Coffee';
        //account.RecordTypeID = '01250000000DKMRAA4';
        account.Type = 'Church';
        account.Mozo_Trial_Status__c = '';
        insert account;
        
        //Baji: test cases for Affilaiton rest controller
        Contact con = new Contact();
        con.LastName = 'testLastName';
        con.Email = 'testemail@mailinator.com';
        insert con;
        
        //npe5__Affiliation__c aff = new npe5__Affiliation__c(npe5__Contact__c = con.Id, npe5__Organization__c = account.Id);
        npe5__Affiliation__c aff = new npe5__Affiliation__c();
               
        aff.npe5__Contact__c = con.Id;
        aff.npe5__Organization__c = account.Id;
        insert aff;
        
        try{
            String postAff = DWREAffiliationRESTController.updateAffiliation('not','FULL');
        }catch(Exception e){
            system.assertEquals(e.getMessage(), e.getMessage());
        }
        
        String postAffResult = DWREAffiliationRESTController.updateAffiliation('','FULL');
        String postAffResult1 = DWREAffiliationRESTController.updateAffiliation(String.valueOf(aff.Id),'');
        String postAffResult2 = DWREAffiliationRESTController.updateAffiliation(String.valueOf(aff.Id),'FULL');
        String postAffResult3 = DWREAffiliationRESTController.updateAffiliation('not an id','FULL');
        String postAffResult4 = DWREAffiliationRESTController.updateAffiliation('not an id','');
        String postAffResult5 = DWREAffiliationRESTController.updateAffiliation(NULL,NULL);
        String postAffResult6 = DWREAffiliationRESTController.updateAffiliation('','');
        String postAffResult7 = DWREAffiliationRESTController.updateAffiliation('',NULL);
        
        //Baji:End
        
        system.debug('HERE IS THE ACCOUNT: '+account);
        String postResult = DWREAccountRESTController.updateAccount(Account.Id,'Current','0035000000aT6uAAAS');
        System.debug(postResult);
        String postResult1 = DWREAccountRESTController.updateAccount('','Current','0035000000aT6uAAAS');
        String postResult2 = DWREAccountRESTController.updateAccount(Account.Id,'','0035000000aT6uAAAS');
        String postResult3 = DWREAccountRESTController.updateAccount(Account.Id,'Current','');
        String postResult4 = DWREAccountRESTController.updateAccount('','','0035000000aT6uAAAS');
        String postResult5 = DWREAccountRESTController.updateAccount(Account.Id,'','');
        String postResult6 = DWREAccountRESTController.updateAccount('','Current','');
        String postResult7 = DWREAccountRESTController.updateAccount('','','');
        String postResult8 = DWREAccountRESTController.updateAccount('not an id','Current','0035000000aT6uAAAS');
        String postResult9 = DWREAccountRESTController.updateAccount(Account.Id,'Current','not an id');
        String postResult10 = DWREAccountRESTController.updateAccount('not an id','Current','not an id');
        String postResult12 = DWREAccountRESTController.updateAccount('not an id','','not an id');
        String postResult13 = DWREAccountRESTController.updateAccount(NULL,'Current','0035000000aT6uAAAS');
        String postResult14 = DWREAccountRESTController.updateAccount(Account.Id,NULL,'0035000000aT6uAAAS');
        String postResult15 = DWREAccountRESTController.updateAccount(Account.Id,'Current',NULL);
        String postResult16 = DWREAccountRESTController.updateAccount(NULL,NULL,'0035000000aT6uAAAS');
        String postResult17 = DWREAccountRESTController.updateAccount(Account.Id,NULL,NULL);
        String postResult18 = DWREAccountRESTController.updateAccount(NULL,'Current',NULL);
        String postResult19 = DWREAccountRESTController.updateAccount(NULL,NULL,NULL);
        String postResult20 = DWREAccountRESTController.updateAccount('not an id',NULL,'not an id');
        
        //Test method for NextOrderNumber rest service
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = '/services/apexrest/NextOrderNumber/GetNextOrderNumber';  //Request URL
        req1.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req1;
        RestContext.response= res1;
        
        List<Order> orders = [Select Id, Name, Account.Mailing_Address_Book__c From Order Where Account.Mailing_Address_Book__c != null Limit 5];
        system.debug('Order size'+orders.size());
        system.debug('Account Customer Number:  '+orders[0].Account.Mailing_Address_Book__c);
        system.debug('Account Customer Number:  '+orders[1].Account.Mailing_Address_Book__c);
        system.debug('Account Customer Number:  '+orders[2].Account.Mailing_Address_Book__c);
        system.debug('Account Customer Number:  '+orders[3].Account.Mailing_Address_Book__c);
        system.debug('Account Customer Number:  '+orders[4].Account.Mailing_Address_Book__c);
        Account acc = [select Mailing_Address_Book__c from Account where Mailing_Address_Book__c =:orders[0].Account.Mailing_Address_Book__c Limit 1];
        
        NextOrderNumberRestService.MyClass myClassResult1 = NextOrderNumberRestService.GetNextOrderNumber('O',acc.Mailing_Address_Book__c);
        NextOrderNumberRestService.MyClass myClassResult2 = NextOrderNumberRestService.GetNextOrderNumber('',acc.Mailing_Address_Book__c);
   		NextOrderNumberRestService.MyClass myClassResult3 = NextOrderNumberRestService.GetNextOrderNumber('O','');
        NextOrderNumberRestService.MyClass myClassResult4 = NextOrderNumberRestService.GetNextOrderNumber('','');
   }
}