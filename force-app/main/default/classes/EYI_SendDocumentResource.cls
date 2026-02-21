@RestResource(urlMapping='/DocumentService/*')
global with sharing class EYI_SendDocumentResource {

    // Input structure for each document
    global class DocumentInput {
        public String docName;
        public String docUrl;
        public String doctype;
        public String docDate;
    }

    // Full request structure
    global class FileUploadRequest {
        public String sapCustomerCode;
        public List<DocumentInput> documents;
    }

    // Output structure
    global class FileUploadResponse {
        public String Message;
        public String type;

        public FileUploadResponse(String message, String type) {
            this.Message = message;
            this.type = type;
        }
    }

    @HttpPost
    global static void uploadFiles() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            // Clean up and sanitize raw input
            String rawBody = req.requestBody.toString().replace('\r', ' ').replace('\n', ' ');
            FileUploadRequest requestBody = (FileUploadRequest) JSON.deserialize(rawBody, FileUploadRequest.class);

            // Validate basic input
            if (String.isBlank(requestBody.sapCustomerCode)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new FileUploadResponse('sapCustomerCode is required.', 'E')));
                return;
            }

            if (requestBody.documents == null || requestBody.documents.isEmpty()) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new FileUploadResponse('No documents provided.', 'E')));
                return;
            }

            // Find related Opportunity
            Opportunity opp;
            try {
                System.debug('Searching for Opportunity with sapCustomerCode: ' + requestBody.sapCustomerCode);
                opp = [SELECT Id FROM Opportunity WHERE EYI_SAP_Customer_Number__c = :requestBody.sapCustomerCode LIMIT 1];
             if (opp != null) {
                    System.debug('Found Opportunity with ID: ' + opp.Id);
                }

            } catch (QueryException qe) {
                System.debug('Error occurred while querying Opportunity with sapCustomerCode: ' + requestBody.sapCustomerCode);
                res.statusCode = 404;
                res.responseBody = Blob.valueOf(JSON.serialize(new FileUploadResponse('Opportunity not found.', 'E')));
                return;
            }

            List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();

            for (DocumentInput doc : requestBody.documents) {
                // Skip incomplete docs
                if (String.isBlank(doc.docName)) continue;

                // Sanitize fields
                String safeDocName = doc.docName.replace('\r', ' ').replace('\n', ' ');
                String safeDocType = (doc.doctype != null) ? doc.doctype.replace('\r', ' ').replace('\n', ' ') : '';
                String safeDocUrl  = (doc.docUrl != null)  ? doc.docUrl.replace('\r', ' ').replace('\n', ' ') : '';
                String safeDocDate = (doc.docDate != null) ? doc.docDate.replace('\r', ' ').replace('\n', ' ') : '';

                // Dummy file content
                String fileBody = 'Document Name: ' + safeDocName + '\n' +
                                  'Document Type: ' + safeDocType + '\n' +
                                  'Document Date: ' + safeDocDate + '\n' +
                                  'Document URL: ' + safeDocUrl;

                ContentVersion cv = new ContentVersion();
                cv.Title = safeDocName;
                cv.PathOnClient = safeDocName + '.txt';
                cv.VersionData = Blob.valueOf(fileBody);
                contentVersionsToInsert.add(cv);
            }

            if (contentVersionsToInsert.isEmpty()) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new FileUploadResponse('No valid documents to upload.', 'E')));
                return;
            }

            insert contentVersionsToInsert;

            // Link files to Opportunity
            List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();

            for (ContentVersion cv : contentVersionsToInsert) {
                // Corrected query: get ContentDocumentId from ContentVersion
                ContentVersion ver = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = ver.ContentDocumentId;
                link.LinkedEntityId = opp.Id;
                link.ShareType = 'V'; // Viewer permission
                link.Visibility = 'AllUsers';

                linksToInsert.add(link);
            }

            insert linksToInsert;

            // Return success
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new FileUploadResponse('Files uploaded and linked successfully.', 'S')));

        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new FileUploadResponse('Error: ' + ex.getMessage(), 'E')));
        }
    }
}