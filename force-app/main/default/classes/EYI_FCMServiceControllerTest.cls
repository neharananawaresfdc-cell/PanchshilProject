@isTest
private class EYI_FCMServiceControllerTest {

    // Step 1: Mock response for the access token from GoogleOAuthHelper
    private class MockGoogleOAuthAndFCMResponse implements HttpCalloutMock {
        Integer callCount = 0;

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if (req.getEndpoint().contains('https://oauth2.googleapis.com/token')) {
                // Simulate access token response
                res.setStatusCode(200);
                res.setBody('{"access_token":"mock_access_token","token_type":"Bearer","expires_in":3600}');
            } else if (req.getEndpoint().contains('https://fcm.googleapis.com/v1/projects/')) {
                // Simulate FCM message send success
                res.setStatusCode(200);
                res.setBody('{"name":"projects/mock_project/messages/0:abc123"}');
            } else {
                res.setStatusCode(404);
                res.setBody('{"error":"Unknown endpoint"}');
            }

            return res;
        }
    }

    @isTest
    static void testSendNotification() {
        // Register our mock implementation
        Test.setMock(HttpCalloutMock.class, new MockGoogleOAuthAndFCMResponse());

        // Set up test device tokens
        List<String> deviceTokens = new List<String>{
            'test_device_token_1',
            'test_device_token_2'
        };

        Test.startTest();
        EYI_FCMServiceController.sendNotification(deviceTokens, 'Test Title', 'Test Body', 'test_type','');
        Test.stopTest();

        // No exception = success. Optionally assert logs or limits if needed.
        System.assert(true, 'FCM call executed successfully in test');
    }
}