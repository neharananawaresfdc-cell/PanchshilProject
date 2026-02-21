@RestResource(urlMapping='/getCase/*')
global class EYI_GetCaseRecords {
    
    @HttpGet
    global static GetCaseWrapper.CaseResponseWrapper findRelatedCases() {
        List<GetCaseWrapper.CaseResponse> caseResponses = new List<GetCaseWrapper.CaseResponse>();
        Map<Id, List<GetCaseWrapper.DocumentDetail>> caseDocumentDetails = new Map<Id, List<GetCaseWrapper.DocumentDetail>>();
        
        Set<Id> caseIds = new Set<Id>();
        Set<String> caseNumbers = new Set<String>();
        Set<String> sap_customer_codes = new Set<String>();
        String requestBody;
        
        try {
            RestRequest req = RestContext.request;
            requestBody = req.requestBody.toString();
            
            List<GetCaseWrapper.CaseRequest> requestList = 
                (List<GetCaseWrapper.CaseRequest>) JSON.deserialize(requestBody, List<GetCaseWrapper.CaseRequest>.class);
            
            for (GetCaseWrapper.CaseRequest request : requestList) {
                if (String.isNotBlank(request.CaseId) || String.isNotBlank(request.CaseNumber)) {
                    if (String.isNotBlank(request.CaseId)) {
                        caseIds.add(request.CaseId);
                    }
                    if (String.isNotBlank(request.CaseNumber)){
                        caseNumbers.add(request.CaseNumber);
                    }
                } 
                else if (String.isNotBlank(request.sap_customer_codes)) {
                    sap_customer_codes.add(request.sap_customer_codes);
                }
            }
            System.debug('CaseNumbers-->' + caseNumbers);
            
            List<Case> caseRecords = new List<Case>();
            if (!caseIds.isEmpty() || !caseNumbers.isEmpty()) {
                caseRecords = [
                    SELECT Id, CaseNumber, Subject, EYI_Case_Sub_Category__c, 
                    EYI_Case_Category__c, Description, Status, Type, Priority, CreatedDate,
                    (SELECT Id, CreatedById, CreatedDate, EYI_Mobile_App_Comments__c,CreatedBy.Name,EYI_Synced_Case__r.EYI_Opportunity__r.Name,CreatedBy.Profile.Name FROM Comments__r ORDER BY CreatedDate DESC) // Subquery for comments
                    FROM Case
                    WHERE Id IN :caseIds OR CaseNumber IN :caseNumbers ORDER BY CreatedDate DESC
                ];
                System.debug('caseRecords-->' + caseRecords);
            } 
            else if (!sap_customer_codes.isEmpty()) {
                caseRecords = [
                    SELECT Id, CaseNumber, Subject, EYI_Case_Sub_Category__c, 
                    EYI_Case_Category__c, Description, Status, Type, Priority, CreatedDate,
                    (SELECT Id, CreatedById, CreatedDate, EYI_Mobile_App_Comments__c,CreatedBy.Name,EYI_Synced_Case__r.EYI_Opportunity__r.Name,CreatedBy.Profile.Name FROM Comments__r ORDER BY CreatedDate DESC) // Subquery for comments
                    FROM Case
                    WHERE EYI_Opportunity__r.EYI_SAP_Customer_Number__c IN :sap_customer_codes ORDER BY CreatedDate DESC
                ];
            }
            System.debug('caseRecords-->' + caseRecords);
            
            if(!caseRecords.isEmpty()){
                Set<Id> caseIdSet = new Set<Id>();
                for(Case caseIter: caseRecords){
                    caseIdSet.add(caseIter.Id);
                }
                System.debug('caseIdSet--' + caseIdSet);
                if(!caseIdSet.isEmpty()){
                    caseDocumentDetails = getCaseDocumentPublicUrls(caseIdSet);
                    System.debug('caseDocumentDetails-->' + caseDocumentDetails);
                }           
            }
            
            for (Case c : caseRecords) 
            {
                Datetime createdDate =  c.CreatedDate.addMinutes(330);
                GetCaseWrapper.CaseResponse caseResponse = new GetCaseWrapper.CaseResponse(
                    c.Id, c.CaseNumber, c.Subject, c.Status,  
                    c.EYI_Case_Sub_Category__c, c.EYI_Case_Category__c, c.Description, c.Type, c.Priority, createdDate
                );
                
                if (caseDocumentDetails.containsKey(c.Id)) {
                    caseResponse.documentLinks = caseDocumentDetails.get(c.Id);
                } else {
                    caseResponse.documentLinks = new List<GetCaseWrapper.DocumentDetail>();
                }
                
                // Populate comments 
                if (c.Comments__r != null && !c.Comments__r.isEmpty()) {
                    List<GetCaseWrapper.CommentDetail> comments = new List<GetCaseWrapper.CommentDetail>();
                    for (EYI_Comments__c comment : c.Comments__r) {
                        String commentedBy = '';
                        if(comment.CreatedBy.Profile.Name =='Integration User'){
                           commentedBy =  comment.EYI_Synced_Case__r.EYI_Opportunity__r.Name;
                        }else{
                        	commentedBy = comment.CreatedBy.Name;
                        }
                        comments.add(new GetCaseWrapper.CommentDetail(
                            comment.CreatedById, 
                            comment.createdDate, 
                            comment.EYI_Mobile_App_Comments__c,
                            commentedBy
                        ));
                    }
                    caseResponse.comments = comments;
                } else {
                    caseResponse.comments = new List<GetCaseWrapper.CommentDetail>();
                }
                
                caseResponses.add(caseResponse);
            }
            
            return new GetCaseWrapper.CaseResponseWrapper(
                !caseResponses.isEmpty(), 
                caseResponses.isEmpty() ? 'No records found ' : 'Records retrieved successfully',
                caseResponses
            );
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            
            return new GetCaseWrapper.CaseResponseWrapper(
                false, e.getMessage(), new List<GetCaseWrapper.CaseResponse>()
            );
        }
    }
    
   /* public static Map<Id, List<GetCaseWrapper.DocumentDetail>> getCaseDocumentPublicUrls(Set<Id> caseIds) {
        System.debug('### Input Case IDs: ' + caseIds);
        
        Map<Id, List<GetCaseWrapper.DocumentDetail>> casePublicUrls = new Map<Id, List<GetCaseWrapper.DocumentDetail>>();
        
        // Return empty map if no case IDs provided
        if (caseIds == null || caseIds.isEmpty()) {
            return casePublicUrls;
        }
        
        Map<Id, List<Id>> caseToContentMap = new Map<Id, List<Id>>();
        List<ContentDocumentLink> contentLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :caseIds
        ];
        
        System.debug('### Retrieved ContentDocumentLinks: ' + contentLinks);
        
        for (ContentDocumentLink link : contentLinks) {
            if (!caseToContentMap.containsKey(link.LinkedEntityId)) {
                caseToContentMap.put(link.LinkedEntityId, new List<Id>());
            }
            caseToContentMap.get(link.LinkedEntityId).add(link.ContentDocumentId);
        }
        
        System.debug('### Case to Content Map: ' + caseToContentMap);
        
        if (caseToContentMap.isEmpty()) {
            return casePublicUrls;
        }
        
        Set<Id> contentDocIds = new Set<Id>();
        for (List<Id> ids : caseToContentMap.values()) {
            contentDocIds.addAll(ids);
        }
        
        Map<Id, ContentDocument> contentDocs = new Map<Id, ContentDocument>([
            SELECT Id, LatestPublishedVersionId 
            FROM ContentDocument 
            WHERE Id IN :contentDocIds
        ]);

        Map<Id, ContentVersion> contentVersions = new Map<Id, ContentVersion>([
            SELECT Id, FileType,Title
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocIds
        ]);
        
        System.debug('### Retrieved ContentDocuments: ' + contentDocs);
        System.debug('### Retrieved ContentVersions: ' + contentVersions);
        
        List<ContentDistribution> newDistributions = new List<ContentDistribution>();
        Map<Id, Id> versionToCaseMap = new Map<Id, Id>();
        
        for (Id caseId : caseToContentMap.keySet()) {
            if (!casePublicUrls.containsKey(caseId)) {
                casePublicUrls.put(caseId, new List<GetCaseWrapper.DocumentDetail>());
            }
            
            for (Id contentId : caseToContentMap.get(caseId)) {
                if (contentDocs.containsKey(contentId)) {
                    ContentDocument doc = contentDocs.get(contentId);
                    ContentVersion cv = contentVersions.get(doc.LatestPublishedVersionId);

                    if (cv != null) {
                        ContentDistribution dist = new ContentDistribution();
                        dist.Name = 'Public Link for ' + doc.Id;
                        dist.ContentVersionId = doc.LatestPublishedVersionId;
                        dist.PreferencesNotifyOnVisit = false;
                        dist.PreferencesAllowViewInBrowser = true;
                        newDistributions.add(dist);
                        
                        versionToCaseMap.put(doc.LatestPublishedVersionId, caseId);
                    }
                }
            }
        }
        
        System.debug('### ContentDistribution records to be inserted: ' + newDistributions);
        
        if (!newDistributions.isEmpty()) {
            insert newDistributions;
            System.debug('### Inserted ContentDistributions');
            
            Map<Id, String> versionIdToUrl = new Map<Id, String>();
            List<ContentDistribution> insertedDistributions = [
                SELECT ContentVersionId, ContentDownloadUrl,DistributionPublicUrl
                FROM ContentDistribution 
                WHERE ContentVersionId IN :versionToCaseMap.keySet()
            ];
            
            for (ContentDistribution dist : insertedDistributions) {
                versionIdToUrl.put(dist.ContentVersionId, dist.DistributionPublicUrl);
            }
            
            System.debug('### VersionId to Download URL Map: ' + versionIdToUrl);
            
            for (Id versionId : versionIdToUrl.keySet()) {
                Id caseId = versionToCaseMap.get(versionId);
                String fileType = '';
                String docName ='';
                if (contentVersions.containsKey(versionId)) {
                    fileType = contentVersions.get(versionId).FileType;
                }
                if (contentVersions.containsKey(versionId)) {
                    docName = contentVersions.get(versionId).Title;
                }
                
                if (casePublicUrls.containsKey(caseId)) {
                    casePublicUrls.get(caseId).add(new GetCaseWrapper.DocumentDetail(versionIdToUrl.get(versionId), fileType, docName));
                }
            }
        }
        
        System.debug('### Final Case Public URLs with Types: ' + casePublicUrls);
        return casePublicUrls;
    }*/
   public static Map<Id, List<GetCaseWrapper.DocumentDetail>> getCaseDocumentPublicUrls(Set<Id> caseIds) {
    System.debug('### Input Case IDs: ' + caseIds);

    Map<Id, List<GetCaseWrapper.DocumentDetail>> casePublicUrls = new Map<Id, List<GetCaseWrapper.DocumentDetail>>();

    if (caseIds == null || caseIds.isEmpty()) {
        return casePublicUrls;
    }

    // Step 1: Get all ContentDocumentLinks for the Cases
    Map<Id, List<Id>> caseToContentDocMap = new Map<Id, List<Id>>();
    List<ContentDocumentLink> contentLinks = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :caseIds
    ];

    for (ContentDocumentLink link : contentLinks) {
        if (!caseToContentDocMap.containsKey(link.LinkedEntityId)) {
            caseToContentDocMap.put(link.LinkedEntityId, new List<Id>());
        }
        caseToContentDocMap.get(link.LinkedEntityId).add(link.ContentDocumentId);
    }

    if (caseToContentDocMap.isEmpty()) {
        return casePublicUrls;
    }

    // Step 2: Get ContentDocuments and collect LatestPublishedVersionIds
    Set<Id> contentDocIds = new Set<Id>();
    for (List<Id> docIds : caseToContentDocMap.values()) {
        contentDocIds.addAll(docIds);
    }

    Map<Id, ContentDocument> contentDocs = new Map<Id, ContentDocument>([
        SELECT Id, LatestPublishedVersionId
        FROM ContentDocument
        WHERE Id IN :contentDocIds
    ]);

    Set<Id> latestVersionIds = new Set<Id>();
    for (ContentDocument doc : contentDocs.values()) {
        latestVersionIds.add(doc.LatestPublishedVersionId);
    }

    // Step 3: Get ContentVersions by LatestPublishedVersionId
    Map<Id, ContentVersion> contentVersions = new Map<Id, ContentVersion>([
        SELECT Id, FileType, Title
        FROM ContentVersion
        WHERE Id IN :latestVersionIds
    ]);

    // Step 4: Create ContentDistributions and map them
    List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
    Map<Id, Id> versionToCaseMap = new Map<Id, Id>();

    for (Id caseId : caseToContentDocMap.keySet()) {
        casePublicUrls.put(caseId, new List<GetCaseWrapper.DocumentDetail>());

        for (Id contentDocId : caseToContentDocMap.get(caseId)) {
            if (contentDocs.containsKey(contentDocId)) {
                Id versionId = contentDocs.get(contentDocId).LatestPublishedVersionId;
                if (versionId != null && contentVersions.containsKey(versionId)) {
                    ContentDistribution dist = new ContentDistribution();
                    dist.Name = 'Public Link for ' + contentDocId;
                    dist.ContentVersionId = versionId;
                    dist.PreferencesNotifyOnVisit = false;
                    dist.PreferencesAllowViewInBrowser = true;
                    distributionsToInsert.add(dist);

                    versionToCaseMap.put(versionId, caseId);
                }
            }
        }
    }

    if (!distributionsToInsert.isEmpty()) {
        insert distributionsToInsert;

        List<ContentDistribution> insertedDistributions = [
            SELECT ContentVersionId, DistributionPublicUrl
            FROM ContentDistribution
            WHERE ContentVersionId IN :versionToCaseMap.keySet()
        ];

        Map<Id, String> versionIdToUrl = new Map<Id, String>();
        for (ContentDistribution dist : insertedDistributions) {
            versionIdToUrl.put(dist.ContentVersionId, dist.DistributionPublicUrl);
        }

        for (Id versionId : versionIdToUrl.keySet()) {
            Id caseId = versionToCaseMap.get(versionId);
            ContentVersion cv = contentVersions.get(versionId);
            if (caseId != null && cv != null) {
                casePublicUrls.get(caseId).add(
                    new GetCaseWrapper.DocumentDetail(
                        versionIdToUrl.get(versionId),
                        cv.FileType,
                        cv.Title
                    )
                );
            }
        }
    }

    System.debug('### Final Case Public URLs with Types: ' + casePublicUrls);
    return casePublicUrls;
}


    
}