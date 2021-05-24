/******************************************************************************************************************
    Programmer:         Ayesha Zulkha
    Company:            Infoglen
    Contact:            ayesha@infoglen.com
    Project:            Tests BatchGetUSCounties
    Original:           4/21/2016 - Tests Geo Codes
---------------
    Called By: BatchGetUSCountiesTest.cls
 *****************************************************************************************************************/ 
@isTest
global class BatchGetUSCountiesMock implements HttpCalloutMock {  
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"results" : [{"address_components" : [{"long_name" : "95050","short_name" : "95050","types" :'+
        '[ "postal_code" ]},{"long_name" : "Santa Clara","short_name" : "Santa Clara","types" :[ "locality", "political" ]},'+
        '{"long_name" : "Santa Clara County","short_name" : "Santa Clara County","types" : [ "administrative_area_level_2", "political"'+
         ']},{"long_name" : "California","short_name" : "CA","types" : [ "administrative_area_level_1", "political" ]},'+
         '{"long_name" : "United States","short_name" : "US","types" : [ "country", "political" ]}], "formatted_address" : '+
         '"Santa Clara, CA 95050, USA","geometry" : {"bounds" : {"northeast" : {"lat" : 37.37448000000001,"lng" : -121.9308761},'+
         '"southwest" : {"lat" : 37.32314,"lng" : -121.9702899}},"location" : {"lat" : 37.3539663,"lng" : -121.9529992 },"location_type" :'+
         '"APPROXIMATE","viewport" : {"northeast" : {"lat" : 37.37448000000001,"lng" : -121.9308761},"southwest" : {"lat" : 37.32314, "lng" :'+
          '-121.9702899}}},"place_id" : "ChIJkyN3003Kj4ARP-4TcpEoJuA","types" : [ "postal_code" ]}],"status" : "OK" }');
        res.setStatusCode(200);
        return res;
    }
}