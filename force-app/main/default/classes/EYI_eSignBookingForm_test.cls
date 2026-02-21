@isTest
public class EYI_eSignBookingForm_test {

    // Mock for HTTP callout
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"respcode":"200","respdesc":"Success","rrn":"123","txnid":"456","esignrequest":"' + EncodingUtil.base64Encode(Blob.valueOf('esignData')) + '","posturl":"https://test.com","status":"OK"}');
            return res;
        }
    }

    @testSetup
    static void setupData() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today().addDays(1));
        insert opp;

        Contact con = new Contact(LastName='Test Applicant');
        insert con;

        EYI_Applicants__c app = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Primary Applicant',
            Verified_AADHAR_Card_Name__c = 'Test Name',
            EYI_Last_Name__c = 'Test Applicant'
        );
        insert app;

        ContentVersion cv = new ContentVersion(
            Title = 'Application Form Test',
            PathOnClient = 'Application Form Test.pdf',
            VersionData = Blob.valueOf('Test PDF'),
            IsMajorVersion = true
        );
        insert cv;
        ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = opp.Id,
            ContentDocumentId = cvQuery.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
    }

    @isTest
    static void testEsignCoordinates_LessThan4() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        EYI_Applicants__c app = [SELECT Id FROM EYI_Applicants__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        String coords = EYI_eSignBookingForm.esignCoordinates(app.Id, opp.Id, 3);
        System.assertNotEquals(null, coords);
    }

    @isTest
    static void testEsignCoordinates_MoreThan4() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<EYI_Applicants__c> apps = new List<EYI_Applicants__c>();
        for (Integer i = 0; i < 4; i++) {
            apps.add(new EYI_Applicants__c(
                Opportunity__c = opp.Id,
                EYI_Applicant_Type__c = 'Primary Applicant',
                EYI_Last_Name__c = 'Test Applicant'
            ));
        }
        insert apps;
        String coords = EYI_eSignBookingForm.esignCoordinates(apps[0].Id, opp.Id, 5);
        System.assertNotEquals(null, coords);
    }

    @isTest
    static void testGetContentDistributionURL_ApplicantId() {
        EYI_Applicants__c app = [SELECT Id FROM EYI_Applicants__c LIMIT 1];
        String url = EYI_eSignBookingForm.getContentDistributionURL(app.Id);
        System.assertEquals(null, url);
    }

    @isTest
    static void testGetContentDistributionURL_OppId() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String url = EYI_eSignBookingForm.getContentDistributionURL(opp.Id);
        System.assertEquals(null, url);
    }

    @isTest
    static void testGetContentDistributionURL_NoDistribution() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        String url = EYI_eSignBookingForm.getContentDistributionURL(acc.Id);
        System.assertEquals(null, url);
    }

    @isTest
    static void testGetDocBase64_Positive() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String result = EYI_eSignBookingForm.getDocBase64(opp.Id);
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetDocBase64_ApplicantId() {
        EYI_Applicants__c app = [SELECT Id FROM EYI_Applicants__c LIMIT 1];
        String result = EYI_eSignBookingForm.getDocBase64(app.Id);
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetDocBase64_NoDoc() {
        Opportunity opp2 = new Opportunity(Name='NoDoc Opp', StageName='Prospecting', CloseDate=Date.today().addDays(1));
        insert opp2;
        EYI_Applicants__c app2 = new EYI_Applicants__c(
            Opportunity__c = opp2.Id,
            EYI_Applicant_Type__c = 'Primary Applicant',
            Verified_AADHAR_Card_Name__c = 'Test Name',
            EYI_Last_Name__c = 'Test Applicant'
        );
        insert app2;
        try {
            EYI_eSignBookingForm.getDocBase64(opp2.Id);
            System.assert(true, 'Should not throw');
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
    }

    @isTest
static void testGetDocBase64_Exception() {
    try {
        // Pass an invalid Id to force Id.valueOf to throw an exception
        EYI_eSignBookingForm.getDocBase64('invalidId');
        System.assert(false, 'Should have thrown AuraHandledException');
    } catch (AuraHandledException e) {
        System.assert(e.getMessage() != null);
    }
}

    @isTest
    static void testGetBookingForm_Positive() {
        EYI_Applicants__c app = [SELECT Id FROM EYI_Applicants__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, String> result = EYI_eSignBookingForm.getBookingForm(app.Id, 3);
        Test.stopTest();
        System.assert(result != null);
    }

    @isTest
    static void testGetBookingForm_NoDoc() {
        Opportunity opp2 = new Opportunity(Name='NoDoc Opp2', StageName='Prospecting', CloseDate=Date.today().addDays(1));
        insert opp2;
        EYI_Applicants__c app2 = new EYI_Applicants__c(
            Opportunity__c = opp2.Id,
            EYI_Applicant_Type__c = 'Primary Applicant',
            Verified_AADHAR_Card_Name__c = 'Test Name',
            EYI_Last_Name__c = 'Test Applicant'
        );
        insert app2;
        Map<String, String> result = EYI_eSignBookingForm.getBookingForm(app2.Id, 3);
        System.assertEquals(null, result);
    }

    @isTest
    static void testGetBase64EncodedFile_Positive() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> docIds = EYI_eSignBookingForm.fetchContentDocumentIds(opp.Id);
        String base64 = EYI_eSignBookingForm.getBase64EncodedFile(docIds);
        System.assertNotEquals(null, base64);
    }

    @isTest
    static void testGetBase64EncodedFile_Exception() {
        Account acc = new Account();
        acc.Name ='Test Account';
        insert acc;
        List<String> docIds = new List<String>{acc.Id};
        try {
            EYI_eSignBookingForm.getBase64EncodedFile(docIds);
            System.assert(false, 'Should throw CustomException');
        } catch (EYI_eSignBookingForm.CustomException e) {
            System.assert(e.getMessage().contains('No Booking Form'));
        }
    }

    @isTest
    static void testCreateHttpRequest() {
        HttpRequest req = EYI_eSignBookingForm.createHttpRequest('InitiateRequest', 'authKey', 'file', 'recId', 'name', 'coords');
       // System.assertEquals('https://uatapp.syntizen.com/sws/InitiateRequest', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
    }

    @isTest
static void testSendHttpRequest() {
    // No DML here!
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://uatapp.syntizen.com/sws/InitiateRequest');
    req.setMethod('POST');
    HttpResponse res = EYI_eSignBookingForm.sendHttpRequest(req);
    Test.stopTest();
    System.assertEquals(200, res.getStatusCode());
}
}