/******************************************************************************************************************
    Programmer:         Tony W
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            ControllerToUpdateDWRE
    Original:           4/21/2016 - Tests DWRE using Http Callous with ETags.
---------------
  Called By: DWREController_Test and BatchEndMozoFreeTrialAccounts
 *****************************************************************************************************************/ 
@isTest
public class myMockETag implements HttpCalloutMock {  
    Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    public myMockETag(Boolean isMockResponseSuccessful) {
        this.isMockResponseSuccessful  = isMockResponseSuccessful;
    }
    public HttpResponse respond(HttpRequest rqst) {
        HttpResponse fakeResponse = new HttpResponse();
        if (this.isMockResponseSuccessful) {
            fakeResponse.setHeader('Content-Type', 'application/json');
            fakeResponse.setHeader('Etag', 'asdfasdfasdfasdfasfdas1225151asd6f1asd5f1as531df35ads1f');
            fakeResponse.setBody('[{"long_name" : "St. Tammany Parish","short_name" : "St Tammany Parish","types" : [ "administrative_area_level_2", "political" ] ' +
            '},{"location" : {"lat" : 35.18164480,"lng" : -89.76615270000001},"access_token" : "asdfas51651asdfas"}]');
            fakeResponse.setStatusCode(200);
        }
        else {
            fakeResponse.setStatusCode(400);
            fakeResponse.setStatus('Bad request');
        }
        return fakeResponse;
    }
}