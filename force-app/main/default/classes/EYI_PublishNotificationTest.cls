@IsTest
public class EYI_PublishNotificationTest {
    @IsTest
    static void testCreateFCMRecord_InsertNew() {
        // Step 1: Insert test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            EYI_SAP_Customer_Number__c = '123456'
        );
        insert opp;

        // Step 2: Build JSON request body
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'Customer__c' => '123456',
            'App_Version__c' => '1.2.3',
            'Source__c' => 'Android',
            'OS_Version__c' => '11.0',
            'Model__c' => 'Pixel 5',
            'Type_A_I__c' => 'A',
            'Custom_Device_ID__c' => 'device-001',
            'Login_mobile_no__c' => '9876543210',
            'Login_email_no__c' => 'test@example.com',
            'FCM_ID_Action__c' => 'LOGIN'
        });

        // Step 3: Setup the REST context
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/FCM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Step 4: Call the method
        EYI_PublishNotification.createFCMRecord();

        // Step 5: Assert record inserted
        List<EYI_FCM_Detail__c> results = [SELECT Id, EYI_Customer__c, EYI_Custom_Device_ID__c FROM EYI_FCM_Detail__c WHERE EYI_Custom_Device_ID__c = 'device-001'];
        System.assertEquals(1, results.size());
        System.assertEquals('123456', results[0].EYI_Customer__c);
    }

    @IsTest
    static void testCreateFCMRecord_UpdateExisting() {
        // Insert Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Update Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            EYI_SAP_Customer_Number__c = '654321'
        );
        insert opp;

        // Insert an existing FCM record
        EYI_FCM_Detail__c existing = new EYI_FCM_Detail__c(
            EYI_Custom_Device_ID__c = 'device-002',
            EYI_Customer__c = '654321'
        );
        insert existing;

        // Prepare updated payload
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'Customer__c' => '654321',
            'App_Version__c' => '2.0.1',
            'Source__c' => 'Android',
            'OS_Version__c' => '12.0',
            'Model__c' => 'Samsung S21',
            'Type_A_I__c' => 'I',
            'Custom_Device_ID__c' => 'device-002',
            'Login_mobile_no__c' => '9988776655',
            'Login_email_no__c' => 'update@example.com',
            'FCM_ID_Action__c' => 'LOGOUT'
        });

        // Setup REST context
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/FCM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call method
        EYI_PublishNotification.createFCMRecord();

        // Validate update
        EYI_FCM_Detail__c updated = [SELECT EYI_App_Version__c, EYI_Model__c, EYI_Login_Email_Id__c FROM EYI_FCM_Detail__c WHERE Id = :existing.Id];
        System.assertEquals('2.0.1', updated.EYI_App_Version__c);
        System.assertEquals('Samsung S21', updated.EYI_Model__c);
        System.assertEquals('update@example.com', updated.EYI_Login_Email_Id__c);
    }

    @IsTest
    static void testInvalidCustomer_NoInsert() {
        // Invalid (no Opportunity)
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'Customer__c' => '999999', // No matching Opportunity
            'Custom_Device_ID__c' => 'device-003'
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/FCM/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        EYI_PublishNotification.createFCMRecord();

        // Should not insert since Opportunity not found
        List<EYI_FCM_Detail__c> results = [SELECT Id FROM EYI_FCM_Detail__c WHERE EYI_Custom_Device_ID__c = 'device-003'];
        System.assertEquals(0, results.size());
    }

}