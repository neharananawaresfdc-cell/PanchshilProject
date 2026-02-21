@isTest
public class MockSAPCalloutResponse implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Create a new mock response
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        
        // Mock the response body (replace with your expected JSON structure)
        String mockJsonResponse = '{"EX_OUTPUT": {' +
                         '"item": [' +
                         '{' +
                         '"CustomerNo": "0010000927", ' +
                         '"OutstandingAmt": 1500.00' +
                         '},' +
                         '{' +
                         '"CustomerNo": "0010000928", ' +
                         '"OutstandingAmt": 2500.50' +
                         '}' +
                         ']' +
                         '}}';

        res.setBody(mockJsonResponse);
        res.setHeader('Content-Type', 'application/json');
        
        return res;
    }
}