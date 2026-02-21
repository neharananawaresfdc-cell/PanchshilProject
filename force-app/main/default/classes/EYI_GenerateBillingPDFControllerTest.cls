@isTest
public class EYI_GenerateBillingPDFControllerTest {

    // Mock class for the HTTP callout
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Mocking expected response body
            String mockBody = '{"n0:ZSD_EXPORT_FORMS_TO_SFResponse":{"EX_PDF":"' +
                              EncodingUtil.base64Encode(Blob.valueOf('Test PDF Content')) +
                              '"}}';
            res.setBody(mockBody);
            return res;
        }
    }

    @isTest
    static void testGetGeneratingFile_Success() {
        // Register mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Prepare test JSON string
        String testRequestJson = '{"BILLDOC":"1234","BUKRS":"1000","GJAHR":"2023","BELNR":"5678","TYPE":"INV"}';

        // Call method under test
        Test.startTest();
        String result = EYI_GenerateBillingPDFController.getGeneratingFile(testRequestJson);
        Test.stopTest();

        System.assertNotEquals(null, result, 'PDF string should not be null');
        System.assertNotEquals('', result, 'PDF string should not be empty');
    }

    @isTest
    static void testGetGeneratingFile_NullRequest() {
        Test.startTest();
        String result = EYI_GenerateBillingPDFController.getGeneratingFile(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Result should be null when request is null');
    }

    @isTest
    static void testGetBooking_WithAccount() {
        // Create test Account and related Opportunity
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAcc.Id
        );
        insert testOpp;

        // Create test Booking record
        EYI_Booking__c booking = new EYI_Booking__c(
            //Name = 'Test Booking',
            EYI_Opportunity_Name__c = testOpp.Id
        );
        insert booking;

        Test.startTest();
        List<EYI_Booking__c> result = EYI_GenerateBillingPDFController.getBooking(testAcc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.size() > 0, 'Booking list should return at least one record');
    }

    @isTest
    static void testGetBooking_BlankId() {
        Test.startTest();
        List<EYI_Booking__c> result = EYI_GenerateBillingPDFController.getBooking('');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Booking list should be empty for blank AccountId');
    }
    @isTest
    static void testRequestWrapperCoverage() {
        EYI_GenerateBillingPDFController.RequestWrapper req = new EYI_GenerateBillingPDFController.RequestWrapper();
        req.DocumentNo = '1234';
        req.CompanyCode = '1000';
        req.AccountingDocNo = '5678';
        req.FiscalYear = '2023';
        req.DocumentType = 'INV';
        
        System.assertEquals('1234', req.DocumentNo);
    }

}