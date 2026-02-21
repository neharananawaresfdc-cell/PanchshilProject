@isTest
private class ErrorMockResponseTest {

    @isTest
    static void testSimulatedCalloutFailure() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new ErrorMockResponse());

        try {
            // Perform a dummy HTTP callout that will trigger the ErrorMockResponse
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://mock.test/failure');
            req.setMethod('GET');

            Http http = new Http();
            HttpResponse res = http.send(req);

            // The above line should throw exception, so these lines should not run
            System.assert(false, 'CalloutException was expected');

        } catch (CalloutException ex) {
            // This is the expected path
            System.assertEquals('Simulated callout failure', ex.getMessage());
        }
    }
}