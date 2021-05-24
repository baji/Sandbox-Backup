/************************************************************************************************************************************************************************************
    Programmer:        Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Newgistics
    Original:           12/01/2018 -<EW-25> Used for testing Newgistics code PostShipmentRequest.cls
 ---------------
  Called By: PostShipmentRequest__Test
 ***************************************************************************************************************************************************************************************/ 

@isTest
global class Newgistics_Mock implements HttpCalloutMock {  
   
    Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    global Newgistics_Mock(Boolean isMockResponseSuccessful) {
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
            fakeResponse.setStatus('Bad request');
        }
        return fakeResponse;
    }
}