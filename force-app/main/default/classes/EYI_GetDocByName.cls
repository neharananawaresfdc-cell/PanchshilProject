@RestResource(urlMapping='/documentSearch/*')
global without sharing class EYI_GetDocByName {

    // Define the response class
    global class GeneratePublicUrlResponse {
        public String publicUrl;
        public List<String> fileNames;
        public String message;
        public String error;

        public GeneratePublicUrlResponse() {
            fileNames = new List<String>();
        }
    }

    @HttpGet
    global static List<GeneratePublicUrlResponse> generatePublicUrls() {
        // Create a list to hold the responses
        List<GeneratePublicUrlResponse> responses = new List<GeneratePublicUrlResponse>();

        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the raw request body as a string

        // Step 2: Parse the request body (JSON) to extract the fileName
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        String fileName = (String) params.get('fileName');
        
        // Check if fileName is provided
        if (String.isEmpty(fileName)) {
            RestContext.response.statusCode = 400;
            GeneratePublicUrlResponse errorResponse = new GeneratePublicUrlResponse();
            errorResponse.error = 'Error: fileName query parameter is required.';
            responses.add(errorResponse);
            return responses;
        }

        try {
            // Step 1: Query for ContentDocuments with the matching fileName
            List<ContentDocument> documents = [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument 
                WHERE Title = :fileName  // Filtering by file name
            ];

            // Step 2: Check if any documents are found
            if (documents.isEmpty()) {
                GeneratePublicUrlResponse response = new GeneratePublicUrlResponse();
                response.message = 'No documents found with the name: ' + fileName;
                responses.add(response);
                return responses;
            }

            // Step 3: Prepare to create ContentDistribution records for the documents
            List<ContentDistribution> distributions = new List<ContentDistribution>();
            Set<Id> latestVersionId = new Set<Id>();

            for (ContentDocument doc : documents) {
                GeneratePublicUrlResponse response = new GeneratePublicUrlResponse();
                response.fileNames.add(doc.Title);  // Add the document's title to fileNames

                ContentDistribution dist = new ContentDistribution();
                dist.Name = 'Public Link for ' + doc.Title;
                dist.ContentVersionId = doc.LatestPublishedVersionId;  // Correct usage of ContentVersionId
                dist.PreferencesNotifyOnVisit = false;
                dist.PreferencesAllowViewInBrowser = true;
                distributions.add(dist);
                latestVersionId.add(doc.LatestPublishedVersionId);

                // Add the response to the list after processing each document
                responses.add(response);
            }

            // Step 4: Insert ContentDistribution records
            if (!distributions.isEmpty()) {
                insert distributions;
            }

            // Step 5: Query the inserted ContentDistribution records to get the ContentDownloadUrl
            List<ContentDistribution> insertedDistributions = [
                SELECT ContentVersionId, ContentDownloadUrl 
                FROM ContentDistribution 
                WHERE ContentVersionId IN :latestVersionId
            ];

            // Map ContentVersionId to the download URL
            Map<Id, String> versionToUrlMap = new Map<Id, String>();
            for (ContentDistribution dist : insertedDistributions) {
                versionToUrlMap.put(dist.ContentVersionId, dist.ContentDownloadUrl);
            }

            // Step 6: Add URLs to each response in the list
            for (GeneratePublicUrlResponse response : responses) {
                for (ContentDocument doc : documents) {
                    if (versionToUrlMap.containsKey(doc.LatestPublishedVersionId)) {
                        response.publicUrl = versionToUrlMap.get(doc.LatestPublishedVersionId);
                    }
                }
            }

        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            GeneratePublicUrlResponse errorResponse = new GeneratePublicUrlResponse();
            errorResponse.error = 'An error occurred: ' + e.getMessage();
            responses.add(errorResponse);
        }

        return responses;
    }
}