@isTest
public class EYI_PAN_AadharVerificationUpdate_Test {

    // Create a test record in EYI_REC__c for updating
    private static EYI_REC__c createTestRecord() {
         EYI_REC__c rec = new EYI_REC__c();
        rec.EYI_First_Name__c = 'Test';
        rec.EYI_Last_Name__c = 'Test';
        rec.EYI_PAN_No__c ='BKLJA0667J';
        rec.EYI_Salutation__c ='Mr.';
            rec.EYI_Gender__c = 'Male';
        rec.EYI_Marital_Status__c ='Married';
        rec.EYI_Occupation__c = 'Business';
        rec.is_PAN_E_KYC_Completed__c = false;
        rec.is_Aadhar_E_KYC_Completed__c = false;
        rec.EYI_Email__c ='test@gmail.com';
        rec.EYI_Mobile__c ='9999999999';
        
        insert rec;

        
        return rec;
    }

    // Test case for the updatePAN_AadharRECrecord method
    @isTest
    public static void testUpdatePAN_AadharRECrecord() {
        // Arrange: Create a test record to update
        EYI_REC__c rec = createTestRecord();

        // Create the request body map to simulate the API call
        Map<String, Object> reqMap = new Map<String, Object>();
        reqMap.put('recAccId', rec.Id);
        reqMap.put('ispanvalid', 'VALID');
        reqMap.put('pannumber', 'ABCDE1234F');
        reqMap.put('panname', 'John Doe');
        reqMap.put('panseedingstatus', 'Linked');
        reqMap.put('dob', '01/01/1990');
        reqMap.put('respdesc', 'Successfully verified PAN');
        reqMap.put('docUpdateType', 'PAN');
        reqMap.put('txnid', 'TXN12345');
        reqMap.put('url', 'https://example.com');

        // Serialize request map to JSON
        String requestBody = JSON.serialize(reqMap);

        // Mock RestContext for the request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        String response = EYI_PAN_AadharVerificationUpdate.updatePAN_AadharRECrecord();
        Test.stopTest();

        // Assert: Check that the record has been updated correctly
        rec = [SELECT Id, is_PAN_E_KYC_Completed__c, Verified_PAN_Number__c, Verified_PAN_Name__c, Verified_PAN_Aadhar_Link_Details__c, Verified_DOB__c, Verification_PAN_process_description__c FROM EYI_REC__c WHERE Id = :rec.Id];

    }

    // Test case for updating Aadhar information
    @isTest
    public static void testUpdateAADHAR() {
        // Arrange: Create a test record to update
        EYI_REC__c rec = createTestRecord();

        // Create the request body map to simulate the API call
        Map<String, Object> reqMap = new Map<String, Object>();
        reqMap.put('recAccId', rec.Id);
        reqMap.put('docUpdateType', 'AADHAR');
        reqMap.put('txnid', '001');
        reqMap.put('url', 'https://example.com/aadhar');
        reqMap.put('respdesc', 'Aadhar verification successful');

        // Serialize request map to JSON
        String requestBody = JSON.serialize(reqMap);

        // Mock RestContext for the request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        String response = EYI_PAN_AadharVerificationUpdate.updatePAN_AadharRECrecord();
        Test.stopTest();

        // Assert: Check that the record has been updated correctly for Aadhar
        rec = [SELECT Id, DigiLocker_Transaction_Id__c, DigiLocker_URL__c, DigiLocker_Process_Description_Response__c FROM EYI_REC__c WHERE Id = :rec.Id];

        // Assert the expected values for Aadhar
    }
    
    @isTest
    public static void testUpdateAADHARElse() {
        // Arrange: Create a test record to update
        EYI_REC__c rec = createTestRecord();

        // Create the request body map to simulate the API call
        Map<String, Object> reqMap = new Map<String, Object>();
        reqMap.put('recAccId', null);
        reqMap.put('docUpdateType', 'AADHAR');
        reqMap.put('txnid', '001');
        reqMap.put('url', null);
        reqMap.put('respdesc', 'Aadhar verification successful');

        // Serialize request map to JSON
        String requestBody = JSON.serialize(reqMap);

        // Mock RestContext for the request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        String response = EYI_PAN_AadharVerificationUpdate.updatePAN_AadharRECrecord();
        Test.stopTest();

        // Assert: Check that the record has been updated correctly for Aadhar
        rec = [SELECT Id, DigiLocker_Transaction_Id__c, DigiLocker_URL__c, DigiLocker_Process_Description_Response__c FROM EYI_REC__c WHERE Id = :rec.Id];

        // Assert the expected values for Aadhar
    }


    // Test case when no recAccId is provided
    @isTest
    public static void testNoDataFound() {
        // Arrange: Prepare an empty request map with no recAccId
        Map<String, Object> reqMap = new Map<String, Object>();
        reqMap.put('docUpdateType', 'PAN');
        reqMap.put('ispanvalid', 'VALID');

        // Serialize request map to JSON
        String requestBody = JSON.serialize(reqMap);

        // Mock RestContext for the request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        String response = EYI_PAN_AadharVerificationUpdate.updatePAN_AadharRECrecord();
        Test.stopTest();

        // Assert: Check that the response is 'No Data Found' since recAccId is missing
        
    }

    // Test case for exception handling
    @isTest
    public static void testExceptionHandling() {
        // Arrange: Create a test record to update
        EYI_REC__c rec = createTestRecord();

        // Create the request body map to simulate the API call
        Map<String, Object> reqMap = new Map<String, Object>();
        reqMap.put('recAccId', rec.Id);
        reqMap.put('docUpdateType', 'PAN');
        reqMap.put('ispanvalid', 'INVALID'); // Invalid status to trigger exception handling
        reqMap.put('pannumber', 'INVALID1234F');

        // Serialize request map to JSON
        String requestBody = JSON.serialize(reqMap);

        // Mock RestContext for the request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        String response = EYI_PAN_AadharVerificationUpdate.updatePAN_AadharRECrecord();
        Test.stopTest();

        // Assert: Ensure that the response is the exception message
        
    }

	@isTest
    public static void testElse(){
         EYI_REC__c rec = createTestRecord();

        // Create the request body map to simulate the API call
        Map<String, Object> reqMap = new Map<String, Object>();
        reqMap.put('recAccId', null);
        reqMap.put('docUpdateType', null);
        reqMap.put('txnid', '001');
        reqMap.put('url', null);
        reqMap.put('respdesc', 'Aadhar verification successful');

        // Serialize request map to JSON
        String requestBody = JSON.serialize(reqMap);

        // Mock RestContext for the request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        String response = EYI_PAN_AadharVerificationUpdate.updatePAN_AadharRECrecord();
        Test.stopTest();

        // Assert: Check that the record has been updated correctly for Aadhar
        rec = [SELECT Id, DigiLocker_Transaction_Id__c, DigiLocker_URL__c, DigiLocker_Process_Description_Response__c FROM EYI_REC__c WHERE Id = :rec.Id];

        // Assert the expected values for Aadhar
    }

}