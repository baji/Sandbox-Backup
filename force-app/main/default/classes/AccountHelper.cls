/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Project:    Salesforce SSO
    Original:   3/11/2013  -Public class helps us retrieve Geo Codes by packing all IDs into a string (deserializing)  to avoid problems with ...
    					 	Asynchronous Methods like GeoLocationCallouts
    Updated: 	5/21/2014 - Updated to test GEO codes.
    Called BY: 
 ***********************************************************************************************************************************************/
public with sharing class AccountHelper {
    
    public String Id {set; get;}

    public AccountHelper(String accId) {
        Id = accId;
    }
}