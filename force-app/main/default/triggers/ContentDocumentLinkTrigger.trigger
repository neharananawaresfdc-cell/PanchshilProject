trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    Map<Id, String> docMap = new Map<Id, String>();
    
    for (ContentDocumentLink cdl : Trigger.new) {
        if (cdl.LinkedEntityId.getSObjectType() == Opportunity.SObjectType) {
            Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :cdl.LinkedEntityId LIMIT 1];
            docMap.put(cdl.ContentDocumentId, opp.StageName);
        }
    }

    if (!docMap.isEmpty()) {
        List<ContentVersion> versionUpdate = new List<ContentVersion>();
        
        for (ContentVersion cv : [SELECT Id, ContentDocumentId, Title FROM ContentVersion 
                                  WHERE ContentDocumentId IN :docMap.keySet() 
                                  AND IsLatest = TRUE]) {
            String stage = docMap.get(cv.ContentDocumentId);
            cv.Title = cv.Title + ' (' + stage + ')';
            versionUpdate.add(cv);
        }
        
        if (!versionUpdate.isEmpty()) {
            update versionUpdate;
        }
    }
}