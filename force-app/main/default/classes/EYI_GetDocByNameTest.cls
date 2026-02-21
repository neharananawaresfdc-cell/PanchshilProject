@isTest
private class EYI_GetDocByNameTest {

    @TestSetup
    static void setupContentData() {
        // Create a test ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile.pdf',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert cv;

        // Ensure the ContentDocument is available for query
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        // Query ContentDocument to confirm LatestPublishedVersionId
        ContentDocument doc = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
            WHERE Id = :insertedCV.ContentDocumentId
            LIMIT 1
        ];
    }

    @isTest
    static void testGeneratePublicUrlsSuccess() {
        Map<String, Object> params = new Map<String, Object>{
            'fileName' => 'TestFile.pdf'
        };
        String jsonBody = JSON.serialize(params);

        simulateRestContext(jsonBody);

        List<EYI_GetDocByName.GeneratePublicUrlResponse> result =
            EYI_GetDocByName.generatePublicUrls();

        System.assertEquals(1, result.size());
        System.assertEquals('TestFile.pdf', result[0].fileNames[0]);
        System.assertNotEquals(null, result[0].publicUrl);
        System.assertEquals(null, result[0].error);
    }

    @isTest
    static void testMissingFileNameParameter() {
        Map<String, Object> params = new Map<String, Object>{ }; // Empty map
        String jsonBody = JSON.serialize(params);

        simulateRestContext(jsonBody);

        List<EYI_GetDocByName.GeneratePublicUrlResponse> result =
            EYI_GetDocByName.generatePublicUrls();

        System.assertEquals(1, result.size());
        System.assertEquals('Error: fileName query parameter is required.', result[0].error);
        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testDocumentNotFound() {
        Map<String, Object> params = new Map<String, Object>{
            'fileName' => 'NoMatchFile.pdf'
        };
        String jsonBody = JSON.serialize(params);

        simulateRestContext(jsonBody);

        List<EYI_GetDocByName.GeneratePublicUrlResponse> result =
            EYI_GetDocByName.generatePublicUrls();

        System.assertEquals(1, result.size());
        System.assert(result[0].message.contains('No documents found with the name:'));
        System.assertEquals(null, result[0].error);
    }

    /*
    @isTest
    static void testInvalidJSONFormat() {
        simulateRestContext('bad json here'); // Invalid input
    
        List<EYI_GetDocByName.GeneratePublicUrlResponse> result =
            EYI_GetDocByName.generatePublicUrls();
    
        // Assert expected error handling
        System.assertEquals(1, result.size());
        System.assertNotEquals(null, result[0].error);
        System.assert(result[0].error.startsWith('An error occurred:'));
        System.assertEquals(500, RestContext.response.statusCode);
    }*/


    // Utility to simulate REST request context
    private static void simulateRestContext(String body) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/documentSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
    }
}