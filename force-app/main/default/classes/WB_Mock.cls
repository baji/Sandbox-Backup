/************************************************************************************************************************************************************************************
    Programmer:        Baji Shaik.
    Company:            Awana
    Project:            WhiteBox
 ---------------
  Called By: PostShipmentRequest__Test
 ***************************************************************************************************************************************************************************************/ 

@isTest
global class WB_Mock implements HttpCalloutMock {  
   
    Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    global WB_Mock(Boolean isMockResponseSuccessful) {
        this.isMockResponseSuccessful  = isMockResponseSuccessful;
    }
    global HttpResponse respond(HttpRequest rqst) {
        HttpResponse fakeResponse = new HttpResponse();
        if (this.isMockResponseSuccessful) {
            //fakeResponse.setHeader('Content-Type', 'application/xml');
            fakeResponse.setHeader('Content-Type', 'application/json');
            //fakeResponse.setBody('<?xml version="1.0" encoding="UTF-8" ?><response><shipments><shipment id="6013782" orderID="XML001" /></shipments><warnings></warnings><errors></errors></response>');
            fakeResponse.setBody('{"orderId":2237276}');
            
            fakeResponse.setStatusCode(200);
        }
        else {
            fakeResponse.setStatusCode(400);
            fakeResponse.setStatus('400');
        }
        return fakeResponse;
    }
}