@restResource(urlMapping='/FCM/*')
global class EYI_PublishNotification {

    @HTTPPOST
    global static void createFCMRecord(){
       /* try{
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            //Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            System.debug('fcm requestBody '+requestBody);
            //System.debug('FCM payload : '+payload);
        }*/
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Parse the JSON body
            String requestBody = req.requestBody.toString();
            System.debug('FCM requestBody : '+requestBody);
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            System.debug('FCM payload : '+payload);
            String custNo = (String)payload.get('Customer__c');
            EYI_FCM_Detail__c fcmObj = new EYI_FCM_Detail__c();
            if(custNo != null){
            	fcmObj.EYI_Opportunity__c = [Select Id from Opportunity Where EYI_SAP_Customer_Number__c =:custNo ].Id; 
                fcmObj.EYI_App_Version__c = (String)payload.get('App_Version__c');
               	fcmObj.EYI_Source__c = (String)payload.get('Source__c');
                fcmObj.EYI_OS_Version__c = (String)payload.get('OS_Version__c');
                fcmObj.EYI_Model__c = (String)payload.get('Model__c');
                fcmObj.EYI_Type__c = (String)payload.get('Type_A_I__c');
                fcmObj.EYI_Custom_Device_ID__c = (String)payload.get('Custom_Device_ID__c');
                fcmObj.EYI_Customer__c = (String)payload.get('Customer__c');
                fcmObj.EYI_Login_Mobile_No__c = (String)payload.get('Login_mobile_no__c');
                fcmObj.EYI_Login_Email_Id__c = (String)payload.get('Login_email_no__c');
                System.debug('FCM_ID_Action__c : '+ payload.get('FCM_ID_Action__c'));
                fcmObj.EYI_FCM_ID_Action__c = (String)payload.get('FCM_ID_Action__c');
                System.debug('fcmObj.EYI_FCM_ID_Action__c : '+ fcmObj.EYI_FCM_ID_Action__c);
                List<EYI_FCM_Detail__c> existingRecords = [SELECT Id FROM EYI_FCM_Detail__c 
                                                           WHERE EYI_Custom_Device_ID__c = :(String)payload.get('Custom_Device_ID__c') LIMIT 1];
                if (!existingRecords.isEmpty()) {
                fcmObj.Id = existingRecords[0].Id;
                	update fcmObj;
            	} else {
                	insert fcmObj;
            	}
               res.statusCode = 200;
               res.responseBody = Blob.valueOf('Success'); 
            }
        }
        catch(Exception e){
            System.debug('Error : '+e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
}