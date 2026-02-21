public class EYI_OpportunityFiles {
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getOpportunityFiles(Id opportunityId){
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docVersionLink : docs) {
                mapIdTitle.put(docVersionLink.ContentDocumentId, docVersionLink.Title);
            }
            return mapIdTitle;
    }
}