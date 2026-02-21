@isTest
private class MockSAPCalloutResponseTest {
    
    @isTest
    static void testSAPMockCalloutCoverage() {
        // Create an instance of the mock
        MockSAPCalloutResponse mock = new MockSAPCalloutResponse();
        
        // Create a dummy HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://sap.example.com/api/outstanding');
        req.setMethod('GET');

        // Call the respond() method directly to get coverage
        HttpResponse res = mock.respond(req);

        // Validate response values
        System.assertEquals(200, res.getStatusCode(), 'Expected HTTP 200');
        System.assert(res.getBody().contains('"CustomerNo": "0010000927"'), 'Expected mock customer data');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Expected application/json content type');

        // Optionally parse and validate structure
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> exOutput = (Map<String, Object>) jsonMap.get('EX_OUTPUT');
        List<Object> items = (List<Object>) exOutput.get('item');
        System.assertEquals(2, items.size(), 'Expected 2 items in response');
    }
}