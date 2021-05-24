/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Project:   NA - Test Coverage - Mock web service call out used to test Tax 2 Wsdl for Web Service Call outs 
    Original:  2/23/215
    Called BY: Tax2Wsdl Test class testTax2Wsdl
 ***********************************************************************************************************************************************/

@isTest(seeAllData=true)
global class Tax2WebserviceMockImpl implements WebServiceMock  {
     global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            Tax2Response.totalTax_element respElement = 
            new Tax2Response.totalTax_element();
            respElement.tax = 2.75;
            response.put('response_x', respElement); 
   }
}