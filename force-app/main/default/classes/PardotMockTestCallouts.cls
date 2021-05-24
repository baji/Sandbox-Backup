@isTest
public class PardotMockTestCallouts implements HttpCalloutMock {  
    Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    public PardotMockTestCallouts(Boolean isMockResponseSuccessful) {
        this.isMockResponseSuccessful  = isMockResponseSuccessful;
        system.debug('***'+isMockResponseSuccessful);
    }
    public HttpResponse respond(HttpRequest rqst) {
        HttpResponse fakeResponse = new HttpResponse();
		
        if (this.isMockResponseSuccessful) {
            fakeResponse.setHeader('Content-Type', 'XML');
            //fakeResponse.setBody('[{"input_index":0,"candidate_index":0,"delivery_line_1":"1 E Bode Rd","last_line":"Streamwood IL 60107-6657","delivery_point_barcode":"601076657011","components":{"primary_number":"1","street_predirection":"E","street_name":"Bode","street_suffix":"Rd","city_name":"Streamwood","state_abbreviation":"IL","zipcode":"60107","plus4_code":"6657","delivery_point":"01","delivery_point_check_digit":"1"},"metadata":{"record_type":"S","zip_type":"Standard","county_fips":"17031","county_name":"Cook","carrier_route":"C048","congressional_district":"08","rdi":"Commercial","elot_sequence":"0001","elot_sort":"A","latitude":42.03892,"longitude":-88.17897,"precision":"Zip9","time_zone":"Central","utc_offset":-6,"dst":true},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y","footnotes":"B#N#"}}]');
            fakeResponse.setBody('<?xml version="1.0" encoding="UTF-8"?><rsp stat="ok" version="1.0"><api_key>8e5dff905a607dd1bcad674866bb2e65</api_key></rsp>');
            fakeResponse.setStatusCode(200);
            fakeResponse.setStatus('OK');
        }
        else {
            fakeResponse.setHeader('Content-Type', 'XML');
            fakeResponse.setStatusCode(400);
            fakeResponse.setStatus('fail');
        }
        return fakeResponse;
    }
}