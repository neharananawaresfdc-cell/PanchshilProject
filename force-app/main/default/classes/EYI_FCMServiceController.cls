public class EYI_FCMServiceController {
    @Future(callout=true)
    public static void sendNotification(List<String> deviceTokens, String title, String body, String ntype,String caseId) {
        String accessToken = GoogleOAuthHelper.getAccessToken();
        
        if (accessToken == null) {
            System.debug('Failed to get access token');
            return;
        }

        for (String token : deviceTokens) {
            sendSingleNotification(token, title, body, accessToken,ntype,caseId);
        }
    }

    private static void sendSingleNotification(String deviceToken, String title, String body, String accessToken, String ntype,String caseId) {
        
        String projectId = 'panchshil-4a525';
        String endpoint = 'https://fcm.googleapis.com/v1/projects/' + projectId + '/messages:send';

        Map<String, Object> message = new Map<String, Object>{
            'token' => deviceToken,
            'notification' => new Map<String, String>{
                'title' => title,
                'body' => body
            },
            'data' => new Map<String,String>{
                    'ntype' => ntype,
                     'case_id' => caseId
            },
            'android' => new Map<String, Object>{
                'priority' => 'high'
            }
        };

        Map<String, Object> payload = new Map<String, Object>{
            'message' => message
        };
		
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; UTF-8');
        req.setBody(JSON.serialize(payload));
		
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            
        } catch (Exception e) {
            System.debug('Error sending FCM: ' + e.getMessage());
        }
    }
}