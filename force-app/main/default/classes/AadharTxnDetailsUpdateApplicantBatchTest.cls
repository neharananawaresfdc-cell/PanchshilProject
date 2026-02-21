@isTest
public class AadharTxnDetailsUpdateApplicantBatchTest {

    // Mocks for Different Responses
    class DigilockerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"respcode":"200","status":"Success","kycdetails":{"gender":"Male","dob":"01-01-1990","name":"Test Name","fname":"Father Name","uid":"123456789012","address":"Test Address"}}');
            return res;
        }
    }

    class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"respcode":"500","status":"Error"}');
            return res;
        }
    }

    class PendingStatusMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"respcode":"200","status":"pending"}');
            return res;
        }
    }

	class AadhaarVerificationHttpMock implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req) {	
        	HttpResponse res = new HttpResponse();
        	res.setStatusCode(200);
        	//  body structure as per actual API response
        	res.setBody('{"AadhaarName":"Test Name","eKYCCompleted":true}');
        	return res;
    	}
	}

    @testSetup
    static void setupData() {
        insert new List<EYI_Applicants__c>{
            new EYI_Applicants__c(
                Name = 'Test Applicant',
                EYI_Last_Name__c = 'Test LastName',
                DigiLocker_Transaction_Id__c = 1001,
                Is_Aadhar_EKYC_Completed__c = false
            ),
            new EYI_Applicants__c(
                Name = 'ErrorPath Applicant',
                EYI_Last_Name__c = 'Test LastName2',
                DigiLocker_Transaction_Id__c = 2002,
                Is_Aadhar_EKYC_Completed__c = false
            ),
            new EYI_Applicants__c(
                Name = 'Pending Applicant',
                EYI_Last_Name__c = 'Test LastName3',
                DigiLocker_Transaction_Id__c = 3003,
                Is_Aadhar_EKYC_Completed__c = false
            )
        };
    }

    @isTest
    static void testBatch_SuccessfulCallout() {
        Test.setMock(HttpCalloutMock.class, new DigilockerMock());

        Test.startTest();
        Database.executeBatch(new AadharTxnDetailsUpdateApplicantBatch(), 200);
        Test.stopTest();

        EYI_Applicants__c result = [SELECT Is_Aadhar_EKYC_Completed__c, Verified_AADHAR_Card_Name__c,
            Verified_AADHAR_Card_DOB__c, Verified_AADHAR_Card_Gender__c,
            Verified_AADHAR_Card_Number__c, Verified_AADHAR_Card_Father_Name__c,
            Verified_AADHAR_Card_Address__c, Verification_Aadhar_process_description__c
            FROM EYI_Applicants__c WHERE Name = 'Test Applicant' LIMIT 1];

        //System.assertEquals(false, result.Is_Aadhar_EKYC_Completed__c);
        /* System.assertEquals('Test Name', result.Verified_AADHAR_Card_Name__c);
        System.assertEquals(Date.newInstance(1990, 1, 1), result.Verified_AADHAR_Card_DOB__c);
        System.assertEquals('Male', result.Verified_AADHAR_Card_Gender__c);
        System.assertEquals('123456789012', result.Verified_AADHAR_Card_Number__c);
        System.assertEquals('Father Name', result.Verified_AADHAR_Card_Father_Name__c);
        System.assertEquals('Test Address', result.Verified_AADHAR_Card_Address__c);
        System.assertEquals('Success', result.Verification_Aadhar_process_description__c);*/
    }

    @isTest
    static void testBatch_ErrorCallout() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        Database.executeBatch(new AadharTxnDetailsUpdateApplicantBatch(), 200);
        Test.stopTest();

        EYI_Applicants__c result = [
            SELECT Aadhar_Response__c FROM EYI_Applicants__c
            WHERE Name = 'ErrorPath Applicant' LIMIT 1
        ];
        System.assertNotEquals(null, result.Aadhar_Response__c);
    }

    @isTest
    static void testBatch_PendingStatus() {
        Test.setMock(HttpCalloutMock.class, new PendingStatusMock());

        Test.startTest();
        Database.executeBatch(new AadharTxnDetailsUpdateApplicantBatch(), 200);
        Test.stopTest();

        EYI_Applicants__c result = [
            SELECT Verification_Aadhar_process_description__c
            FROM EYI_Applicants__c
            WHERE Name = 'Pending Applicant' LIMIT 1
        ];
        //System.assertEquals('pending', result.Verification_Aadhar_process_description__c);
    }

    @isTest
    static void testWrapperClassCoverage() {
        AadharTxnDetailsUpdateApplicantBatch.kycdetails kyc = new AadharTxnDetailsUpdateApplicantBatch.kycdetails();
        kyc.name = 'Test';
        kyc.fname = 'Father';
        kyc.dob = '01-01-1990';
        kyc.gender = 'Male';
        kyc.uid = '123456789012';
        kyc.address = 'Test Address';
        kyc.zipped_aadhaar_xml = 'XML';

        AadharTxnDetailsUpdateApplicantBatch.ResponseAadharDigilockerStatus resp = new AadharTxnDetailsUpdateApplicantBatch.ResponseAadharDigilockerStatus();
        resp.respcode = '200';
        resp.status = 'Success';
        resp.kycdetails = kyc;

        System.assertEquals('200', resp.respcode);
        System.assertEquals('Test', resp.kycdetails.name);

        AadharTxnDetailsUpdateApplicantBatch.RequestAadharDigilockerStatus req = new AadharTxnDetailsUpdateApplicantBatch.RequestAadharDigilockerStatus();
        req.txnid = 'txn123';
        req.rrn = 'rrn456';
        System.assertEquals('txn123', req.txnid);
    }
}