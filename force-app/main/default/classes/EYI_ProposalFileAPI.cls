@RestResource(urlMapping='/getProposalForms/*')
global with sharing class EYI_ProposalFileAPI {

    global class FileRequest {
        public String email;
        public String phone;
    }

    global class FileResponse {
        public String opportunityId;
        public String opportunityName;
        public String email;
        public String phone;
        public String projectName;
        public String fileUrl;
        public String error;
    }

    global class UnitResponse {
        public String opportunityId;
        public String opportunityName;
        public String email;
        public String phone;
        public List<InventoryWrapper> inventoryList;
        public String error;
    }

    global class InventoryWrapper {
        public String inventoryNumber;
        public String towerName;
        public Decimal saleableArea;
        public Decimal totalArea;
        public Integer twoWheelerCount;
        public Integer carParkCount;
    }

    @HttpPost
    global static String handleRequest() {
        RestRequest req = RestContext.request;
        String action = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        FileRequest input = (FileRequest) JSON.deserialize(req.requestBody.toString(), FileRequest.class);

        if (action == 'proposal') {
            return JSON.serialize(fetchCustomerFiles(input));
        } else if (action == 'unitDetails') {
            return JSON.serialize(fetchUnitDetails(input));
        } else {
            FileResponse r = new FileResponse();
            r.error = 'Invalid endpoint. Use /proposal or /unitDetails';
            return JSON.serialize(new List<FileResponse>{ r });
        }
    }

    // === Optimized bulk-safe Customer Files API ===
    private static List<FileResponse> fetchCustomerFiles(FileRequest input) {
        List<FileResponse> responses = new List<FileResponse>();

        if ((input.email == null || input.email == '') && (input.phone == null || input.phone == '')) {
            FileResponse r = new FileResponse();
            r.error = 'Email or phone is required';
            responses.add(r);
            return responses;
        }

        // Query Opportunities
        List<Opportunity> oppList = [
            SELECT Id, Name, EYI_Project_Enquired__r.Name,
                   EYI_Alternate_Email__c, EYI_Email__c, EYI_Mobile_Number__c
            FROM Opportunity
            WHERE (EYI_Email__c = :input.email AND EYI_Email__c != null)
               OR (EYI_Alternate_Email__c = :input.email AND EYI_Alternate_Email__c != null)
               OR (EYI_Mobile_Number__c = :input.phone AND EYI_Mobile_Number__c != null)
            LIMIT 10
        ];

        if (oppList.isEmpty()) {
            FileResponse r = new FileResponse();
            r.error = 'No opportunities found for provided email/phone';
            responses.add(r);
            return responses;
        }

        // Collect Opportunity Ids
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity o : oppList) oppIds.add(o.Id);

        // Query ContentDocumentLinks for Application Form files
        Map<Id, ContentDocumentLink> oppFileMap = new Map<Id, ContentDocumentLink>();
        Set<Id> contentVersionIds = new Set<Id>();

        if (!oppIds.isEmpty()) {
            for (ContentDocumentLink cdl : [
                SELECT ContentDocumentId,
                       ContentDocument.Title,
                       ContentDocument.LatestPublishedVersionId,
                       LinkedEntityId,
                       ContentDocument.CreatedDate
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :oppIds
                AND ContentDocument.Title LIKE '%Application Form%'
                ORDER BY ContentDocument.CreatedDate DESC
            ]) {
                if (!oppFileMap.containsKey(cdl.LinkedEntityId)) {
                    oppFileMap.put(cdl.LinkedEntityId, cdl);
                    contentVersionIds.add(cdl.ContentDocument.LatestPublishedVersionId);
                }
            }
        }

        // Query existing ContentDistributions in bulk
        Map<Id, ContentDistribution> existingDistributionMap = new Map<Id, ContentDistribution>();
        if (!contentVersionIds.isEmpty()) {
            for (ContentDistribution cd : [
                SELECT Id, ContentVersionId, DistributionPublicUrl
                FROM ContentDistribution
                WHERE ContentVersionId IN :contentVersionIds
            ]) {
                existingDistributionMap.put(cd.ContentVersionId, cd);
            }
        }

        // Prepare new ContentDistributions in bulk
        List<ContentDistribution> toInsertCD = new List<ContentDistribution>();

        for (Opportunity opp : oppList) {
            FileResponse r = new FileResponse();
            r.email = opp.EYI_Email__c;
            r.phone = opp.EYI_Mobile_Number__c;
            r.opportunityId = opp.Id;
            r.opportunityName = opp.Name;
            r.projectName = opp.EYI_Project_Enquired__r != null ? opp.EYI_Project_Enquired__r.Name : null;

            if (oppFileMap.containsKey(opp.Id)) {
                ContentDocumentLink cdl = oppFileMap.get(opp.Id);

                if (existingDistributionMap.containsKey(cdl.ContentDocument.LatestPublishedVersionId)) {
                    r.fileUrl = existingDistributionMap.get(cdl.ContentDocument.LatestPublishedVersionId).DistributionPublicUrl;
                } else {
                    // Queue for insertion
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = 'Proposal File for ' + opp.Name;
                    cd.ContentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
                    cd.PreferencesAllowViewInBrowser = true;
                    cd.PreferencesAllowOriginalDownload = true;
                    toInsertCD.add(cd);

                    // Temporarily store reference for URL after insert
                    existingDistributionMap.put(cdl.ContentDocument.LatestPublishedVersionId, cd);
                }

            } else {
                r.error = 'No Application Form file found';
            }

            responses.add(r);
        }

        // Insert all new ContentDistributions in bulk
        if (!toInsertCD.isEmpty()) {
            insert toInsertCD;

            // Update the fileUrl in responses after insert
            for (FileResponse r : responses) {
                if (r.fileUrl == null && oppFileMap.containsKey(r.opportunityId)) {
                    ContentDocumentLink cdl = oppFileMap.get(r.opportunityId);
                    ContentDistribution cd = existingDistributionMap.get(cdl.ContentDocument.LatestPublishedVersionId);
                    r.fileUrl = cd.DistributionPublicUrl;
                }
            }
        }

        return responses;
    }

    // === Unit Details API ===
    private static List<UnitResponse> fetchUnitDetails(FileRequest input) {
        List<UnitResponse> responses = new List<UnitResponse>();

        if ((input.email == null || input.email == '') && (input.phone == null || input.phone == '')) {
            UnitResponse r = new UnitResponse();
            r.error = 'Email or phone is required';
            responses.add(r);
            return responses;
        }

        List<Opportunity> oppList = [
            SELECT Id, Name, EYI_Project_Enquired__r.Name,
                   EYI_Alternate_Email__c, EYI_Email__c, EYI_Mobile_Number__c,
                   EYI_Inventory__c,
                   EYI_Inventory__r.EYI_Inventory_Number__c,
                   EYI_Inventory__r.EYI_Tower__r.Name,
                   EYI_Inventory__r.EYI_Saleable_Area_Sq_mt__c,
                   EYI_Inventory__r.EYI_Total_Area__c,
                   EYI_Inventory__r.EYI_Two_Wheeler_Count__c,
                   EYI_Inventory__r.EYI_Car_Park_Count__c
            FROM Opportunity
            WHERE (EYI_Email__c = :input.email AND EYI_Email__c != null)
               OR (EYI_Alternate_Email__c = :input.email AND EYI_Alternate_Email__c != null)
               OR (EYI_Mobile_Number__c = :input.phone AND EYI_Mobile_Number__c != null)
            LIMIT 10
        ];

        for (Opportunity opp : oppList) {
            UnitResponse r = new UnitResponse();
            r.opportunityId = opp.Id;
            r.opportunityName = opp.Name;
            r.email = opp.EYI_Email__c;
            r.phone = opp.EYI_Mobile_Number__c;
            r.inventoryList = new List<InventoryWrapper>();

            if (opp.EYI_Inventory__r != null) {
                InventoryWrapper invDetail = new InventoryWrapper();
                invDetail.inventoryNumber = opp.EYI_Inventory__r.EYI_Inventory_Number__c;
                invDetail.towerName = opp.EYI_Inventory__r.EYI_Tower__r != null ? opp.EYI_Inventory__r.EYI_Tower__r.Name : null;
                invDetail.saleableArea = opp.EYI_Inventory__r.EYI_Saleable_Area_Sq_mt__c;
                invDetail.totalArea = opp.EYI_Inventory__r.EYI_Total_Area__c;
                invDetail.twoWheelerCount = (Integer) opp.EYI_Inventory__r.EYI_Two_Wheeler_Count__c;
                invDetail.carParkCount = (Integer) opp.EYI_Inventory__r.EYI_Car_Park_Count__c;

                r.inventoryList.add(invDetail);
            }

            responses.add(r);
        }

        return responses;
    }
}