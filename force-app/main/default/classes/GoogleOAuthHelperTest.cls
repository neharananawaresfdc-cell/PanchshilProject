@isTest
private class GoogleOAuthHelperTest {

    // Mock class to simulate HTTP response from Google's OAuth endpoint
    private class MockGoogleOAuthResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('https://oauth2.googleapis.com/token', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"access_token":"fake_token_123","token_type":"Bearer","expires_in":3600}');
            return res;
        }
    }

    @isTest
    static void testGetAccessToken() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new MockGoogleOAuthResponse());

        // Create a static resource mock content (sample JSON content with fake key)
        String fakeJson = JSON.serialize(new Map<String, Object>{
            'private_key' => '-----BEGIN PRIVATE KEY-----\\nMIIEowIBAAKCAQEAsamplefakekeydatahere==\\n-----END PRIVATE KEY-----',
            'client_email' => 'test-service-account@myproject.iam.gserviceaccount.com'
        });

        // Create a Static Resource in memory for test context
        StaticResource fakeSR = [SELECT Body FROM StaticResource WHERE Name = 'GoogleServiceAccountKey' LIMIT 1];

        //insert fakeSR;

        // Use Test.startTest/stopTest to capture limits
        Test.startTest();
        String token = GoogleOAuthHelper.getAccessToken();
        Test.stopTest();

        System.assertEquals('fake_token_123', token, 'Access token did not match expected mock value');
    }
}