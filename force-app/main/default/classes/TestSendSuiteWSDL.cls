/***************************************** 
 Programmer: Tony Williams
    Company:      Awana
    Contact:      tonyw@awana.org
    Project:    NA - SendSUiteWSDL.
    Description:    Testing of Sendsuite FRT WSDL
  Module Tested:   wwwApprouterComConnectorsWsdl(Response, Request)
    Created:      01/10/2016
    ---------------------------
**********************************************/
@isTest 
public class TestSendSuiteWSDL {

    
    
    public static testmethod void TestSSuiteRequest() {
        wwwApprouterComConnectorsRequest11 ssuiteReq = new wwwApprouterComConnectorsRequest11();
        wwwApprouterComConnectorsRequest11.SSRequest_element  ssre = new wwwApprouterComConnectorsRequest11.SSRequest_element();
        wwwApprouterComConnectorsRequest11.shippingMethod_element  sme = new wwwApprouterComConnectorsRequest11.shippingMethod_element();
        wwwApprouterComConnectorsRequest11.SendSuiteShipment_element ssse = new wwwApprouterComConnectorsRequest11.SendSuiteShipment_element();
        //wwwApprouterComConnectorsResponse11.SSRequest_element ssrqe;
    }
    public static testmethod void TestSSuiteResponse() {
       wwwApprouterComConnectorsResponse11 ssuiteResp = new wwwApprouterComConnectorsResponse11();
        wwwApprouterComConnectorsResponse11.carrier_element sse =   new wwwApprouterComConnectorsResponse11.carrier_element();     
        wwwApprouterComConnectorsResponse11.shippingMethod_element sspshme = new  wwwApprouterComConnectorsResponse11.shippingMethod_element();   
       //wwwApprouterComConnectorsResponse11.SSRequest_element ssrqe;       
       wwwApprouterComConnectorsResponse11.SSResponse_element ssre;
    }
    public  static testmethod void TesSSuitePBWsdl() {
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
        Test.startTest();
            // Call the method that invokes a callout   but add an acocunt with these parameter values:
            TestSendSuiteWSDL da = new TestSendSuiteWSDL();
            wwwApprouterComConnectorsResponse11.SSResponse_element output = sSuiteStub.Provide_Service(10.75,dummyAcct.ShippingStreet,dummyAcct.ShippingCity,dummyAcct.ShippingState,dummyAcct.ShippingPostalCode,'UNITED STATES','R', dummyAcct.Mailing_Address_Book__c,'SFDC',false); 
        Test.stopTest();
    }
}