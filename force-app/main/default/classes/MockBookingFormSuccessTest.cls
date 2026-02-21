@isTest
private class MockBookingFormSuccessTest {
    @isTest
    static void testMockCalloutResponse() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockBookingFormSuccess());

        // Build a dummy HTTP request (as your actual code would do)
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/booking');
        req.setMethod('GET');

        // Perform the callout using HTTP
        Http http = new Http();
        Test.startTest();
        HttpResponse res = http.send(req);
        Test.stopTest();

        // Validate the mocked response
        System.assertEquals(200, res.getStatusCode(), 'Expected HTTP 200 OK status code');
        
        String responseBody = res.getBody();
        System.assert(responseBody.contains('"esignRequest"'), 'Response should contain esignRequest');
        System.assert(responseBody.contains('"txnid":"123456"'), 'Response should contain txnid');
        System.assert(responseBody.contains('"posturl":"https://signurl.com"'), 'Response should contain posturl');

        // Optionally parse the JSON to verify structure
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertNotEquals(null, jsonMap.get('esignRequest'));
        System.assertEquals('123456', (String) jsonMap.get('txnid'));
        System.assertEquals('https://signurl.com', (String) jsonMap.get('posturl'));
    }
}