@isTest
private class EYI_DocumentServiceTest {

    // Mock class to simulate the external callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendDocumentToExternalSystem() {
        // Register the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create test EYI_DMS__c record
        EYI_DMS__c testDoc = new EYI_DMS__c(
           // Name = 'Test Doc',
            EYI_Document_Name__c = 'Brochure',
            EYI_Document_Link__c = 'https://example.com/doc.pdf'
        );
        insert testDoc;

        // Call the future method
        Test.startTest();
        EYI_DocumentService.sendDocumentToExternalSystem(testDoc.Id);
        Test.stopTest();

        // Optionally validate the record was used (if needed)
        EYI_DMS__c insertedDoc = [SELECT Id, Name, EYI_Document_Name__c, EYI_Document_Link__c FROM EYI_DMS__c WHERE Id = :testDoc.Id];
       // System.assertEquals('Test Doc', insertedDoc.Name);
    }

    @isTest
    static void testDocumentPayloadConstructor() {
        // Just testing the inner class DocumentPayload explicitly
        EYI_DMS__c testDoc = new EYI_DMS__c(
           // Name = 'Test Payload',
            EYI_Document_Name__c = 'Brochure',
            EYI_Document_Link__c = 'https://example.com/contract.pdf'
        );
        insert testDoc;

        // Simulate SOQL fetch with CreatedDate
        EYI_DMS__c fetched = [SELECT EYI_Document_Name__c, Name, EYI_Document_Link__c, CreatedDate FROM EYI_DMS__c WHERE Id = :testDoc.Id];

        EYI_DocumentService.DocumentPayload payload = new EYI_DocumentService.DocumentPayload(fetched);

        System.assertEquals(fetched.Name, payload.document_name);
        System.assertEquals(fetched.EYI_Document_Name__c, payload.document_type);
        System.assertEquals(fetched.EYI_Document_Link__c, payload.document_link);
        System.assertNotEquals(null, payload.created_date); // Just making sure date string exists
    }
}