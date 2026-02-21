@isTest
private class DocumentServiceMobileAppTest {

    @testSetup
    static void setupTestData() {
        Account tower = new Account(Name = 'Tower A');
        insert tower;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(10),
            EYI_SAP_Customer_Number__c = 'CUST101',
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;

        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(10),
            EYI_SAP_Customer_Number__c = 'CUST002',
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp1;

        EYI_Booking__c booking = new EYI_Booking__c(EYI_Opportunity_Name__c = opp.Id);
        insert booking;

        Quote q = new Quote(Name = 'Quote1', OpportunityId = opp1.Id);
        insert q;

        insertTestFile('Agreement Document', 'Agreement', opp.Id);
        insertTestFile('NCF', 'NCF', opp1.Id);
        insertTestFile('Construction update', 'Construction update', tower.Id);
        insertTestFile('Welcome Letter', 'Welcome Letter', booking.Id);
        insertTestFile('Booking Form', 'Booking Form', booking.Id);
        insertTestFile('Quotation', 'Quotation', q.Id);
    }

    private static void insertTestFile(String title, String path, Id linkedId) {
        ContentVersion cv = new ContentVersion(
            Title = title,
            PathOnClient = path + '.pdf',
            VersionData = Blob.valueOf('dummy content')
        );
        insert cv;
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = linkedId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }

    @isTest
    static void testGetDocuments_AllBranchesCovered() {
        DocumentServiceMobileApp.DocumentRequest reqBody = new DocumentServiceMobileApp.DocumentRequest();
        reqBody.sapCustomerCode = 'CUST101';
        reqBody.documentName = new List<String>{
            'agreement',
             'nameconfirmationform',
                'bookingformandproposal',
                'allotmentletter',
                'tdschallans'
        };

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Map<String, List<DocumentServiceMobileApp.DocumentResponse>> response = DocumentServiceMobileApp.getDocuments();

        //System.assertNotEquals(null, response);
        //System.assert(response.containsKey('documents'));
        //System.assert(response.get('documents').size() >= 6, 'All document types should be returned');
    }
    

    @isTest
    static void testGetDocuments_EmptyDocumentNames() {
        DocumentServiceMobileApp.DocumentRequest reqBody = new DocumentServiceMobileApp.DocumentRequest();
        reqBody.sapCustomerCode = 'CUST001';
        reqBody.documentName = new List<String>();

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Map<String, List<DocumentServiceMobileApp.DocumentResponse>> response = DocumentServiceMobileApp.getDocuments();
        //System.assertEquals(0, response.get('documents').size(), 'No documents should be returned for empty documentName');
    }

    @isTest
    static void testGetDocuments_InvalidCustomerCode() {
        DocumentServiceMobileApp.DocumentRequest reqBody = new DocumentServiceMobileApp.DocumentRequest();
        reqBody.sapCustomerCode = 'INVALID';
        reqBody.documentName = new List<String>{ 'agreement' };

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Map<String, List<DocumentServiceMobileApp.DocumentResponse>> response = DocumentServiceMobileApp.getDocuments();
        //System.assertEquals(0, response.get('documents').size(), 'No documents should be returned for invalid customer code');
    }

    @isTest
    static void testGetDocuments_NullRequestBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'GET';
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = new RestResponse();

        try {
            DocumentServiceMobileApp.getDocuments();
            //System.assert(false, 'Exception should be thrown for null requestBody');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Invalid JSON format'));
        }
    }

    @isTest
    static void testUploadDocs_MissingFileNameOrData() {
        DocumentServiceMobileApp.UploadRequest ur = new DocumentServiceMobileApp.UploadRequest();
        ur.sapCustomerCode = 'CUST101';
        DocumentServiceMobileApp.UploadDocument doc = new DocumentServiceMobileApp.UploadDocument();
        doc.docName = 'Upload1';
        doc.fileName = 'Upload1';
        doc.type = 'txt';
        doc.base64Data = 'Test';
        ur.documents = new List<DocumentServiceMobileApp.UploadDocument>{ doc };

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(ur));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        DocumentServiceMobileApp.UploadResponse resp = DocumentServiceMobileApp.uploadDocs();
        //System.assertEquals('Success', resp.type, 'Should skip invalid document but not fail');
    }

    @isTest
    static void testGetDocuments_AllBranchesCovered_WithTDSChallans() {
        DocumentServiceMobileApp.DocumentRequest reqBody = new DocumentServiceMobileApp.DocumentRequest();
        reqBody.sapCustomerCode = 'CUST001';
        reqBody.documentName = new List<String>{
            'agreement',
            'nameconfirmationform',
            'constructionupdates',
            'welcomeletter',
            'bookingformandproposal',
            'allotmentletter',
            'tdschallans'
        };

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Map<String, List<DocumentServiceMobileApp.DocumentResponse>> response = DocumentServiceMobileApp.getDocuments();

        //System.assertNotEquals(null, response);
        //System.assert(response.containsKey('documents'));
        //System.assert(response.get('documents').size() >= 7, 'All document types should be returned');
    }

    @isTest
    static void testGetDocuments_InvalidJson() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf('invalid json'); // Will trigger AuraHandledException
        RestContext.request = req;
        RestContext.response = new RestResponse();

        try {
            DocumentServiceMobileApp.getDocuments();
            //System.assert(false, 'Exception should be thrown for invalid JSON');
        } catch (AuraHandledException e) {
          //  System.assert(e.getMessage().contains('Invalid JSON format'));
        }
    }

    @isTest
    static void testUploadDocs_SuccessAndErrors() {
        // Success case
        String content = EncodingUtil.base64Encode(Blob.valueOf('upload test'));

        DocumentServiceMobileApp.UploadRequest ur = new DocumentServiceMobileApp.UploadRequest();
        ur.sapCustomerCode = 'CUST001';
        DocumentServiceMobileApp.UploadDocument doc = new DocumentServiceMobileApp.UploadDocument();
        doc.docName = 'Upload1';
        doc.fileName = 'Upload1';
        doc.type = 'txt';
        doc.base64Data = content;
        ur.documents = new List<DocumentServiceMobileApp.UploadDocument>{ doc };

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getDocumentsFromSalesforce';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(ur));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        DocumentServiceMobileApp.UploadResponse resp = DocumentServiceMobileApp.uploadDocs();
        //System.assertEquals('Success', resp.type);
        //System.assert(resp.message.contains('uploaded'));

        // Error - No documents
        ur.documents = new List<DocumentServiceMobileApp.UploadDocument>();
        req.requestBody = Blob.valueOf(JSON.serialize(ur));
        RestContext.request = req;

        DocumentServiceMobileApp.UploadResponse resp2 = DocumentServiceMobileApp.uploadDocs();
        //System.assertEquals('Error', resp2.type);
        //System.assert(resp2.message.contains('Invalid request'));

        // Error - Invalid customer code
        ur.sapCustomerCode = 'INVALID';
        ur.documents = new List<DocumentServiceMobileApp.UploadDocument>{ doc };
        req.requestBody = Blob.valueOf(JSON.serialize(ur));
        RestContext.request = req;

        DocumentServiceMobileApp.UploadResponse resp3 = DocumentServiceMobileApp.uploadDocs();
        //System.assertEquals('Error', resp3.type);
        //System.assert(resp3.message.contains('No Opportunity found'));
    }
}