public class EYI_DocData {
	 @AuraEnabled(cacheable=true)
    public static String getRecordsId(String accId) {
        List<Id> lsOfCont = new List<Id>();
        List<ContentDocumentLink> lsOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:accId];
        String idString='';
        for(integer i=0;i<lsOfCDL.size();i++){
            if(i == lsOfCDL.size()-1){
                idString+= lsOfCDL[i].ContentDocumentId;
            }else{
                idString+= lsOfCDL[i].ContentDocumentId + ',';
            }
            
        }
        System.debug('IDs are '+idString);
        return idString;
    }
    @AuraEnabled
    public static List<String> getData(String accountId) {
        System.debug('Account ID is: ' + accountId);
    
        // Result list to return base64-encoded file content
        List<String> lsOfFiles = new List<String>();
    
        // Step 1: Get ContentDocumentLink records
        List<ContentDocumentLink> lsOfCDL = [
            SELECT Id, LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :accountId
        ];
    
        // Step 2: Extract ContentDocumentIds
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : lsOfCDL) {
            documentIds.add(link.ContentDocumentId);
        }
    
        // Step 3: Fetch ContentVersion records with size check
        List<ContentVersion> lsOfCV = [
            SELECT Id, Title,VersionData, FileExtension, ContentSize 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :documentIds
            AND Title != 'REC_Merged_PDF.pdf'
            AND FileExtension = 'pdf'
        ];
    
        // Step 4: Process each file
        Integer maxTotalSizeKB = 5000; // Max combined size ~5MB (adjust as needed)
        Integer currentTotalSizeKB = 0;
        List<String> invoiceFiles = new List<String>();
    	List<String> otherFiles = new List<String>();
    
        for (ContentVersion cv : lsOfCV) {
           
            // Check total combined size to avoid Apex string limits
            
    
            String encoded = EncodingUtil.base64Encode(cv.VersionData);
            if (cv.Title != null && cv.Title.toLowerCase().contains('invoice')) {
                invoiceFiles.add(encoded); // Add to beginning group
                System.debug('Invoice file added: ' + cv.Title);
            } else {
                otherFiles.add(encoded); // Add to remaining group
                System.debug('Other file added: ' + cv.Title);
            }
            //lsOfFiles.add(encoded);
    
            System.debug('Added file: ' + cv.Id + ' (' + cv.FileExtension + ', ' + cv.ContentSize + ' KB)');
        }
    	lsOfFiles.addAll(invoiceFiles);
    	lsOfFiles.addAll(otherFiles);
        System.debug('Total files added: ' + lsOfFiles.size());
        return lsOfFiles;
    }
    
   @AuraEnabled
    public static String createContentVersion(String base64Pdf, String fileName, String recordId) {
        try {
            System.debug('Base64 size: ' + base64Pdf.length());
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Pdf);
            insert contentVersion;

            System.debug('Inserted ContentVersion Id: ' + contentVersion.Id);
            
            ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
            System.debug('Inserted ContentVersion ContentDocumentId: ' + insertedContentVersion.ContentDocumentId);
            
            ContentDocumentLink docLink = new ContentDocumentLink();
            docLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
            docLink.LinkedEntityId = recordId;
            docLink.ShareType = 'V';
            docLink.Visibility = 'AllUsers';
            insert docLink;

            System.debug('File saved and linked successfully');
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception in createContentVersion: ' + e);
            throw new AuraHandledException('Error saving file: ' + e.getMessage());
        }
    }

}