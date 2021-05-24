@isTest(SeeAllData=true)
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
       
        System.assertEquals('GET', req.getMethod());       
        // Create a fake response
        HttpResponse fakeResponse = new HttpResponse();
        fakeResponse.setHeader('Content-Type', 'application/json');
        fakeResponse.setBody('[{"location" : {"lat" : 35.18164480,"lng" : -89.76615270000001}}]');
        fakeResponse.setStatusCode(200);
        
        return fakeResponse;        
    }
}