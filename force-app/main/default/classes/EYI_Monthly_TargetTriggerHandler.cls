public class EYI_Monthly_TargetTriggerHandler {
    public static void shareRecordAccessMTtoRM(List<Monthly_Target__c> enquiryList, Map<id,Monthly_Target__c> oldMap){
        List<Monthly_Target__Share> shareRecords = new List<Monthly_Target__Share>();
        Map<Id,Id> sharetoRM = new Map<Id,Id>();
        Map<Id,Id> deleteAccess = new Map<Id,Id>();

        for(Monthly_Target__c mt: enquiryList){
            if(mt.EYI_RM__c != null ){
                sharetoRM.put(mt.id,mt.EYI_RM__c);
                
                

            }
            if(oldMap.get(mt.Id).EYI_RM__c != null && oldMap.get(mt.Id).EYI_RM__c != null && oldMap.get(mt.Id).EYI_RM__c != mt.EYI_RM__c){
                deleteAccess.put(mt.Id,oldMap.get(mt.Id).EYI_RM__c);
            }
        }
        List<Monthly_Target__Share> shareRecordsToDelete = new List<Monthly_Target__Share>();

        for(Id leadId :sharetoRM.keySet() ){
           // EYI_Lead_Enquiry__Share enquiryShare = new EYI_Lead_Enquiry__Share();
            Monthly_Target__Share leadShare = new Monthly_Target__Share();
                leadShare.ParentId = leadId;           // The Lead record to be shared
                leadShare.UserOrGroupId = sharetoRM.get(leadId);     // The User with whom the record will be shared
                leadShare.AccessLevel = 'Read';  // Access level (e.g., 'Read' or 'Edit')
                leadShare.RowCause = 'Manual';
                shareRecords.add(leadShare);
        }
        if (!shareRecords.isEmpty()) {
            insert shareRecords;
        }
        system.debug('deleteAccess'+deleteAccess);
        List<Monthly_Target__Share> existingShareRecords = [ 
        SELECT Id, ParentId, UserOrGroupId 
        FROM Monthly_Target__Share 
        WHERE ParentId IN :deleteAccess.keySet() 
          AND UserOrGroupId IN :deleteAccess.values()
        ];
        system.debug('existingShareRecords'+existingShareRecords);
        for (Monthly_Target__Share shareRecord : existingShareRecords) {
            system.debug('shareRecord'+shareRecord);
            // Check if the sharing record matches the correct user and lead, then add it to the delete list
            if (deleteAccess.containsKey(shareRecord.ParentId) && 
            deleteAccess.get(shareRecord.ParentId) == shareRecord.UserOrGroupId) {
                system.debug('deleteAccess222'+deleteAccess);
                shareRecordsToDelete.add(shareRecord);
            }
        }
        if (!shareRecordsToDelete.isEmpty()) {
            system.debug('shareRecordsToDelete'+shareRecordsToDelete);
            try {
                delete shareRecordsToDelete;
            } catch (DmlException e) {
                System.debug('Error deleting sharing records: ' + e.getMessage());
            }
        }
    }
}