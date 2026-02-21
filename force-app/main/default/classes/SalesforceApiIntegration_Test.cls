@isTest
public class SalesforceApiIntegration_Test {
    
    // Mock class to simulate an HTTP response for OAuth token
    public class MockHttpResponseForOAuthToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock a successful OAuth response
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mockAccessToken", "instance_url": "https://mock.salesforce.com"}');
            return res;
        }
    }

    // Mock class to simulate an HTTP response for updating a record
    public class MockHttpResponseForUpdateRecord implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock a successful response from updating a record
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(204);  // No content for successful PATCH
            return res;
        }
    }

    @isTest
    static void testGetOAuthToken() {
        // Register the mock response for OAuth token
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForOAuthToken());

        // Call the method to get the OAuth token
        String accessToken = SalesforceApiIntegration.getOAuthToken();

        // Assert the expected outcome
        
    }

    @isTest
    static void testUpdateRecord() {
        // Register the mock response for updating a record
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForUpdateRecord());

        // Call the method to update a record with a mock record ID and email
        String result = SalesforceApiIntegration.updateRecord('001xx000003DHP5AAQ', 'test@example.com');

        // Assert the expected outcome
        
    }

    @isTest
    static void testUpdateRecordWithError() {
        // Mock a failure response for updating a record
        

        // Register the mock response for the failure case
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForUpdateRecordFailure());

        // Call the method to update a record
        String result = SalesforceApiIntegration.updateRecord('001xx000003DHP5AAQ', 'invalidemail@domain.com');

        // Assert the expected outcome
        
    }
    class MockHttpResponseForUpdateRecordFailure implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(400);  // Bad Request
                res.setBody('{"error": "invalid_request", "error_description": "Invalid data"}');
                return res;
            }
        }
}