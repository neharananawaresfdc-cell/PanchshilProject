public class SalesforceApiIntegration {


    // Step 1: Get OAuth access token
    public static String getOAuthToken() {
        List<APIConfiguration__mdt> apimdt = [select id, UserName__c,Password__c,Consumer_Key__c,Consumer_Secret__c from APIConfiguration__mdt where DeveloperName='Salesforce_Call' limit 1];
        if(!apimdt.isEmpty()){
        String authUrl = URL.getOrgDomainUrl() + '/services/oauth2/token';
        String clientId = apimdt[0].Consumer_Key__c;  // Replace with your connected app client ID
        String clientSecret = apimdt[0].Consumer_Secret__c;  // Replace with your connected app client secret
        String username = apimdt[0].UserName__c;
        String password = apimdt[0].Password__c;  // Append security token

        HttpRequest req = new HttpRequest();
        req.setEndpoint(authUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      // req.setHeader('Content-Type', 'application/json');
        
        String body = 'grant_type=password' +
                      '&client_id=' + clientId +
                      '&client_secret=' + clientSecret +
                      '&username=' + username +
                      '&password=' + password;
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = (String) authResponse.get('access_token');
            //String instanceUrl = (String) authResponse.get('instance_url');
            //return instanceUrl + '/services/data/v52.0/';
            return accessToken;
        } else {
            return 'OAuth authentication failed. Status: ' + res.getStatusCode();
        }
       }
        return null;
    }

    // Step 2: Update a record using the authenticated API call
    public static String updateRecord(String recordId, String email) {
        try {
            String apiUrl = getOAuthToken() + 'sobjects/Contact/' + recordId;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('PATCH');
            req.setHeader('Authorization', 'Bearer ' + 'YOUR_ACCESS_TOKEN');  // Replace with actual access token
            req.setHeader('Content-Type', 'application/json');
            
            String requestBody = JSON.serialize(new Map<String, Object> {
                'Email' => email
            });
            req.setBody(requestBody);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 204) {
                return 'Record updated successfully';
            } else {
                throw new CustomException('Failed to update record. Status: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    public class CustomException extends Exception {}


}