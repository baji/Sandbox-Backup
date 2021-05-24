/***************************************************************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    Used for Testing Coverage for Send Suite WSDL
    Created:    1/11/2016 
 **************************************************************************************************************************************************************************************/
@isTest
global class SSuiteWebServiceMockImpl implements WebServiceMock{
    global void doInvoke(  
           Object stub,  
           Object request,  
           Map<string, Object> response,  
           String endpoint,  
           String soapAction,  
           String requestName,  
           String responseNS,  
           String responseName,  
           String responseType) {  
         wwwApprouterComConnectorsResponse11.SSResponse_element respElement = new wwwApprouterComConnectorsResponse11.SSResponse_element();  
       respElement.success = true;  
       response.put('response_x', respElement);   
   }  
}