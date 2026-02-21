public class AccountCalloutHelper {

    @future (callout=true)
    public static void makePANValidateCallout(String recAccountId) {
        
        EYI_REC__c acc = [SELECT Id,Name,EYI_First_Name__c,EYI_Last_Name__c,IsPANeKYCDone__c,EYI_PAN_No__c,EYI_Birth_Date__c FROM EYI_REC__c WHERE Id = :recAccountId LIMIT 1];
        
        //get API details
        APIConfiguration__mdt apiconfig = [select Label,ApiEndPoint__c,HeaderParameters__c,RequestMethod__c 
                                from APIConfiguration__mdt Where Label ='PanVerification'];

        // Create an HTTP object and set up the request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiconfig.ApiEndPoint__c);
        request.setMethod(apiconfig.RequestMethod__c);
        request.setHeader('Content-Type', apiconfig.HeaderParameters__c);
		
        // Create JSON body
        String jsonBody = '{"pannumber": "' + acc.EYI_PAN_No__c + '", "rrn": "' + acc.Name + '"}';
        request.setBody(jsonBody);
        // Make the callout and capture the response
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            // Process the successful response here
            System.debug('Response from callout: ' + response.getBody());
            String jsonResponse = response.getBody();
            Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
            String receivedPAN = (String)parsedResponse.get('pan');
            String firstName = (String)parsedResponse.get('first_name');
            String middleName = (String)parsedResponse.get('middle_name');
            String lastName = (String)parsedResponse.get('last_name');
            Date dateOfBirth = (Date)parsedResponse.get('dob');
            
            if (receivedPAN != null && receivedPAN == acc.EYI_PAN_No__c && 
                dateOfBirth != null && dateOfBirth == acc.EYI_Birth_Date__c &&
               	firstName != null && firstName == acc.EYI_First_Name__c &&
               	lastName != null && lastName == acc.EYI_Last_Name__c) {
                acc.IsPANeKYCDone__c = true;
                update acc;
            }
            
        } else {
            // Handle any error scenarios
            System.debug('Error in callout: ' + response.getStatusCode());
        }
    }
}