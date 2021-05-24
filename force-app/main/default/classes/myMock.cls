/************************************************************************************************************************************************************************************
    Programmer:         Shaik Baji
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Test Geo Codes
    Original:           4/21/2016 - Tests Geo Codes
    Updated: (Tony W)  10/19/2017 - <ASP-587> - Added County string to the FakeResponse.SetBody method;
  Updated: (Tony W)  01/29/2018 - <ASP-832> - (Tony W.) Using Smarty Streets Server JSON  Response string instead of Google API JSON Responseto get Counties and other meta data (Plus 4)
---------------
  Called By: TestGEoCodes.cls
 ***************************************************************************************************************************************************************************************/ 
@isTest
public class myMock implements HttpCalloutMock {  
    Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    public myMock(Boolean isMockResponseSuccessful) {
        this.isMockResponseSuccessful  = isMockResponseSuccessful;
    }
    public HttpResponse respond(HttpRequest rqst) {
        HttpResponse fakeResponse = new HttpResponse();
        if (this.isMockResponseSuccessful) {
            fakeResponse.setHeader('Content-Type', 'application/json');
            fakeResponse.setBody('[{"input_index":0,"candidate_index":0,"delivery_line_1":"1 E Bode Rd","last_line":"Streamwood IL 60107-6657","delivery_point_barcode":"601076657011","components":{"primary_number":"1","street_predirection":"E","street_name":"Bode","street_suffix":"Rd","city_name":"Streamwood","state_abbreviation":"IL","zipcode":"60107","plus4_code":"6657","delivery_point":"01","delivery_point_check_digit":"1"},"metadata":{"record_type":"S","zip_type":"Standard","county_fips":"17031","county_name":"Cook","carrier_route":"C048","congressional_district":"08","rdi":"Commercial","elot_sequence":"0001","elot_sort":"A","latitude":42.03892,"longitude":-88.17897,"precision":"Zip9","time_zone":"Central","utc_offset":-6,"dst":true},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y","footnotes":"B#N#"}}]');
            fakeResponse.setStatusCode(200);
        }
        else {
            fakeResponse.setStatusCode(400);
            fakeResponse.setStatus('Bad request');
        }
        return fakeResponse;
    }
}