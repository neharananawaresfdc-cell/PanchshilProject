@RestResource(urlMapping='/getDocumentsFromSalesforce')
global class DocumentServiceMobileApp {

    global class DocumentRequest {
        public String sapCustomerCode;
        public List<String> documentName;
    }

    global class DocumentResponse {
        public String docName;
        public String docUrl;
        public String docType;
        public String docDate;
    }

    global class UploadRequest {
        public String sapCustomerCode;
        public List<UploadDocument> documents;
    }

    global class UploadDocument {
        public String docName;
        public String fileName;
        public String type;
        public String base64Data;
    }

    global class UploadResponse {
        public String message;
        public String type;

        public UploadResponse(String msg, Boolean isSuccess) {
            this.message = msg;
            this.type = isSuccess ? 'Success' : 'Error';
        }
    }
    @HttpGet
    global static Map<String, List<DocumentResponse>> getDocuments() {
        List<DocumentResponse> documents = new List<DocumentResponse>();

        RestRequest req = RestContext.request;
        DocumentRequest input;
        try {
            input = (DocumentRequest) JSON.deserialize(req.requestBody.toString(), DocumentRequest.class);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid JSON format: ' + e.getMessage());
        }

        if (input == null || input.sapCustomerCode == null) {
            return new Map<String, List<DocumentResponse>>{ 'documents' => documents };
        }

        // Step 1: Get Opportunity
        List<Opportunity> oppList = [
            SELECT Id,Name,EYI_Inventory__r.EYI_Tower__c
            FROM Opportunity 
            WHERE EYI_SAP_Customer_Number__c = :input.sapCustomerCode 
            LIMIT 1
        ];
        //System.debug('Opp Name : '+oppList[0].Name);
        if (oppList.isEmpty()) return new Map<String, List<DocumentResponse>>{ 'documents' => documents };
        Opportunity opp = oppList[0];

        // Step 2: Determine parent records for each document type
        Map<String, List<Id>> docParentMap = new Map<String, List<Id>>();
		System.debug('input.documentName : '+input.documentName);
        for (String name : input.documentName) {
            if (String.isBlank(name)) continue;
            String lowered = name.toLowerCase();

            if (lowered.contains('agreement')) {
                docParentMap.put('Agreement', new List<Id>{ opp.Id });
            }
            if (lowered.contains('nameconfirmationform')) {
                docParentMap.put('NCF', new List<Id>{ opp.Id });
            }
            if (lowered.contains('constructionupdates')) {
               docParentMap.put('Construction update', new List<Id>{ opp.EYI_Inventory__r.EYI_Tower__c });
            }
            if (lowered.contains('tdschallans')) {
               docParentMap.put('TDS Challan', new List<Id>{ opp.Id });
            }

            if (lowered.contains('welcomeletter')) {
                 docParentMap.put('Welcome Letter', new List<Id>{ opp.Id });
                /*List<Id> ids = new List<Id>();
                for (EYI_Booking__c b : [
                    SELECT Id FROM EYI_Booking__c WHERE EYI_Opportunity_Name__c = :opp.Id
                ]) {
                    ids.add(b.Id);
                }
                if (!ids.isEmpty()) docParentMap.put('Welcome Letter', ids);*/
            }

            if (lowered.contains('bookingformandproposal')) {
                docParentMap.put('Application', new List<Id>{ opp.Id });
                /*List<Id> ids = new List<Id>();
                for (EYI_Booking__c b : [
                    SELECT Id FROM EYI_Booking__c WHERE EYI_Opportunity_Name__c = :opp.Id
                ]) {
                    ids.add(b.Id);
                }
                if (!ids.isEmpty()) docParentMap.put('Booking Form', ids);*/
            }
            

            if (lowered.contains('allotmentletter')) {
                List<Id> ids = new List<Id>();
                for (Quote q : [
                    SELECT Id FROM Quote WHERE OpportunityId = :opp.Id
                ]) {
                    ids.add(q.Id);
                }
                if (!ids.isEmpty()) docParentMap.put('Quotation', ids);
            }

            
        }
        System.debug('docParentMap : '+docParentMap);
        // Step 3: Retrieve files via ContentDocumentLink and build public URLs
        for (String docLabel : docParentMap.keySet()) {
            List<Id> parentIds = docParentMap.get(docLabel);
            system.debug('parentIds ==> '+parentIds);
			if (parentIds == null || parentIds.isEmpty()) continue;
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :parentIds
            ];

            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                docIds.add(link.ContentDocumentId);
            }
            if (docIds.isEmpty()) continue;
             List<ContentVersion> versions = new List<ContentVersion>();

             if(docLabel == 'TDS Challan'){
                versions = [
                    SELECT Id, Title, FileExtension, ContentDocumentId, CreatedDate 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :docIds AND Title LIKE :('%' + docLabel + '%')
                    ORDER BY CreatedDate DESC
                ];
             }else{
                versions = [
                    SELECT Id, Title, FileExtension, ContentDocumentId, CreatedDate 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :docIds 
                    AND Title LIKE :('%' + docLabel + '%')
                    ORDER BY CreatedDate DESC Limit 1
                ];
             }
           System.debug('versions : '+versions);

            for (ContentVersion file : versions) {
                String publicUrl;

                List<ContentDistribution> existingLinks = [
                    SELECT DistributionPublicUrl 
                    FROM ContentDistribution 
                    WHERE ContentVersionId = :file.Id 
                    LIMIT 1
                ];

                if (!existingLinks.isEmpty()) {
                    publicUrl = existingLinks[0].DistributionPublicUrl;
                } else {
                    ContentDistribution dist = new ContentDistribution();
                    dist.Name = file.Title + ' Public Link';
                    dist.ContentVersionId = file.Id;
                    dist.PreferencesAllowOriginalDownload = true;
                    dist.PreferencesAllowViewInBrowser = true;
                    dist.PreferencesNotifyOnVisit = false;
                    insert dist;

                    // Re-query to ensure DistributionPublicUrl is populated
                    dist = [
                        SELECT DistributionPublicUrl 
                        FROM ContentDistribution 
                        WHERE Id = :dist.Id 
                        LIMIT 1
                    ];
                    publicUrl = dist.DistributionPublicUrl;
                }
                String displayName = (docLabel == 'TDS Challan') ? 'TDS Challan' : file.Title;
                DocumentResponse res = new DocumentResponse();
                res.docName = displayName;
                res.docType = file.FileExtension;
                res.docDate = String.valueOf(file.CreatedDate);
                res.docUrl = publicUrl;
                documents.add(res);
            }
        }
        system.debug('documents ==> '+documents);
		return new Map<String, List<DocumentResponse>>{ 'documents' => documents };
           
    }
    
    @HttpPost
    global static UploadResponse uploadDocs() {
        try {
            // Parse and validate input
            UploadRequest input = (UploadRequest) JSON.deserialize(RestContext.request.requestBody.toString(), UploadRequest.class);
            if (input == null || String.isBlank(input.sapCustomerCode) || input.documents == null || input.documents.isEmpty()) {
                return new UploadResponse('Invalid request: missing data.', false);
            }
			System.debug('input.documents : '+input.documents);
            System.debug('input.sapCustomerCode : '+input.sapCustomerCode);
            // Fetch the related Opportunity
            List<Opportunity> oppList = [
                SELECT Id 
                
                FROM Opportunity 
                WHERE EYI_SAP_Customer_Number__c = :input.sapCustomerCode 
                LIMIT 1
            ];
            if (oppList.isEmpty()) {
                return new UploadResponse('No Opportunity found for SAP Customer Code.', false);
            }
            Opportunity opp = oppList[0];

            // Upload and link each document
            for (UploadDocument doc : input.documents) {
                if (String.isBlank(doc.base64Data) || String.isBlank(doc.fileName)) {
                    continue;
                }

                // Create ContentVersion
                ContentVersion cv = new ContentVersion();
                cv.Title = doc.fileName + '.' + doc.type;
                cv.PathOnClient = doc.fileName + '.' + doc.type;               
                cv.VersionData = EncodingUtil.base64Decode(doc.base64Data);
                insert cv;

                // Fetch ContentDocumentId
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = [
                    SELECT ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id = :cv.Id 
                    LIMIT 1
                ].ContentDocumentId;

                // Link to Opportunity
                link.LinkedEntityId = opp.Id;
                link.ShareType = 'V';
                link.Visibility = 'AllUsers';
                insert link;
            }

            return new UploadResponse('Documents uploaded successfully', true);

        } catch (Exception e) {
            return new UploadResponse('Upload failed: ' + e.getMessage(), false);
        }
    }
    
}