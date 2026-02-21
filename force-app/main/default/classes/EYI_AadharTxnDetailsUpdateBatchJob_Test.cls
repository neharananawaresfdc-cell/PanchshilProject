@isTest
public class EYI_AadharTxnDetailsUpdateBatchJob_Test {
    // Helper method to create a test EYI_REC__c record
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
        rec.DigiLocker_Transaction_Id__c= 012;
        rec.is_Aadhar_E_KYC_Completed__c=false ;
        insert rec;
        return rec;
    }
    
    // Simple test case for the batch job
    @isTest
    public static void testBatchJob() {
        // Arrange: Create test record
        EYI_REC__c rec = createTestRecord();
        
        // Create an instance of the batch job
        EYI_AadharTxnDetailsUpdateBatchJob batchJob = new EYI_AadharTxnDetailsUpdateBatchJob();
        
        // Start the test to measure the governor limits used by the batch job
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockAadharResponse());
        Test.setMock(HttpCalloutMock.class, new MockAuthorizationKeyResponse());
        
        // Execute the batch job
        Database.executeBatch(batchJob);
        EYI_AadharTxnDetailsUpdateBatchJob.ResponseAadharDigilockerStatus kd =new  EYI_AadharTxnDetailsUpdateBatchJob.ResponseAadharDigilockerStatus();
        EYI_AadharTxnDetailsUpdateBatchJob.kycdetails kd2 =new EYI_AadharTxnDetailsUpdateBatchJob.kycdetails();
        
        // Stop the test
        Test.stopTest();
        
        
        
        
    }
    public class MockAadharResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            String jsonResponse = '{"respcode":"200", "respdesc":"Success", "status":"Success", "kycdetails": {' +
                '"name":"John Doe", "fname":"Father Name", "dob":"01-01-1990", "gender":"Male", "uid":"1234567890", ' +
                '"address":"Some Address"}}';
            res.setBody(jsonResponse);
            
            return res;
        }
    }
    
    public class MockAuthorizationKeyResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"respcode": "200", "authkey": "mockAuthKey","respdesc":"Success", "status":"Success", "kycdetails": {' +
                '"name":"John Doe", "fname":"Father Name", "dob":"01-01-1990", "gender":"Male", "uid":"1234567890", ' +
                '"address":"Some Address"}}');
            return res;
        }
    }
}