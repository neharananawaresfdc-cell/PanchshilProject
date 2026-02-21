@RestResource(urlMapping='/ConstructionUpdates/*')
global class EYI_ConstructionUpdateResource {
    
    // Input class supporting both single and multiple customercodes 
    public class ConstructionUpdateInput {
        public String sap_customer_code;
        public List<String> sap_customer_codes;
    }
    
    public class ConstructionUpdate {
        public String doc_url;
        public String construction_name;
        public Date date_of_update;
        
        public ConstructionUpdate(String docUrl, String name, Date updateDate) {
            this.doc_url = docUrl;
            this.construction_name = name;
            this.date_of_update = updateDate;
        }
    }
    
    public class ConstructionUpdateOutput {
        public List<ConstructionUpdate> construction_updates;
        
        public ConstructionUpdateOutput(List<ConstructionUpdate> updates) {
            this.construction_updates = updates;
        }
    }
    
    @HttpPost
    global static void getConstructionUpdates() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        ConstructionUpdateInput input;
        try {
            input = (ConstructionUpdateInput) JSON.deserialize(req.requestBody.toString(), ConstructionUpdateInput.class);
        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"Invalid input JSON: ' + e.getMessage() + '"}');
            return;
        }
        
        Set<String> customerNumberSet = new Set<String>();
        if (input != null) {
            if (!String.isBlank(input.sap_customer_code)) {
                customerNumberSet.add(input.sap_customer_code);
            }
            if (input.sap_customer_codes != null) {
                for (String b : input.sap_customer_codes) {
                    if (!String.isBlank(b)) {
                        customerNumberSet.add(b);
                    }
                }
            }
        }
        
        if (customerNumberSet.isEmpty()) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"At least one Customer Code Number is required"}');
            return;
        }
        
        List<Opportunity> opportunitys = [SELECT Id, Name, EYI_Project_Tower_Enquired__c, EYI_Project_Tower_Enquired__r.Name, 
                                          LastModifiedDate FROM Opportunity WHERE EYI_SAP_Customer_Number__c  IN :customerNumberSet];
        
        // Collect all unique Tower IDs from the fetched bookings
        Set<Id> towerIds = new Set<Id>();
        for (Opportunity bk : opportunitys) {
            if (bk.EYI_Project_Tower_Enquired__c != null) {
                towerIds.add(bk.EYI_Project_Tower_Enquired__c);
            }
        }
        
        Map<Id, ContentVersion> latestConstructionUpdateFiles = new Map<Id, ContentVersion>();
        
        if (!towerIds.isEmpty()) {
            // Step 1: Find ContentDocumentIds linked to the relevant EYI_Project_Tower_Enquired__c records
            List<ContentDocumentLink> cdlList = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :towerIds
            ];
            
            Set<Id> contentDocumentIds = new Set<Id>();
            Map<Id, Id> docIdToTowerIdMap = new Map<Id, Id>(); // Map ContentDocumentId to LinkedEntityId (TowerId)
            for(ContentDocumentLink cdl : cdlList) {
                contentDocumentIds.add(cdl.ContentDocumentId);
                docIdToTowerIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            
            if (!contentDocumentIds.isEmpty()) {
                // Step 2: Query ContentVersions, filtering by ContentDocumentId and title,
                // and order to easily find the latest.
                List<ContentVersion> relevantContentVersions = [
                    SELECT Id, Title, ContentDocumentId, LastModifiedDate, FileExtension
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :contentDocumentIds
                    AND Title LIKE '%Construction Update%'
                    ORDER BY LastModifiedDate DESC // Order by date to get the latest easily
                ];
                
                // Iterate through relevant ContentVersions to find the LATEST for each Tower
                for (ContentVersion cv : relevantContentVersions) {
                    Id currentTowerId = docIdToTowerIdMap.get(cv.ContentDocumentId); // Get the TowerId for this ContentDocument
                    if (currentTowerId != null) {
                        // If this is the first 'Construction Update' found for this tower, or it's newer
                        if (!latestConstructionUpdateFiles.containsKey(currentTowerId) ||
                            cv.LastModifiedDate > latestConstructionUpdateFiles.get(currentTowerId).LastModifiedDate) {
                                latestConstructionUpdateFiles.put(currentTowerId, cv);
                            }
                    }
                }
            }
        }
        
        List<ConstructionUpdate> constructionUpdates = new List<ConstructionUpdate>();
        
        for (Opportunity bk : opportunitys) {
            String fileUrl = ''; // Default to empty string
            String fileName = 'No Construction Update'; // Default message
            Date fileLastModifiedDate = null;
            
            // Check if we found a file for this booking's tower
            if (bk.EYI_Project_Tower_Enquired__c != null && latestConstructionUpdateFiles.containsKey(bk.EYI_Project_Tower_Enquired__c)) {
                ContentVersion latestCv = latestConstructionUpdateFiles.get(bk.EYI_Project_Tower_Enquired__c);
                
                // Construct the file URL
                // This URL is for internal Salesforce access (authenticated user required)
                fileUrl = URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + latestCv.Id;
                fileName = latestCv.Title;
                fileLastModifiedDate = latestCv.LastModifiedDate.date();
            }
            
            ConstructionUpdate cu = new ConstructionUpdate(
                fileUrl,
                fileName,
                fileLastModifiedDate
            );
            constructionUpdates.add(cu);
        }
        
        ConstructionUpdateOutput output = new ConstructionUpdateOutput(constructionUpdates);
        
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(output));
    }
}