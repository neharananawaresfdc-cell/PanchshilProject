public class EYI_CommentTriggerHandler {
    public static void handleStatusChange(List<EYI_Comments__c> newCommentList){
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, List<String>> oppIdToNCFNames = new Map<Id, List<String>>();
        Map<Id, Id> caseIdToOppId = new Map<Id, Id>();
        
        for (EYI_Comments__c cmnt : newCommentList) {
            if (cmnt.EYI_Synced_Case__c != null) {
                caseIdSet.add(cmnt.EYI_Synced_Case__c);
            }
        }
        
        List<Case> caseList = [
            SELECT Id, EYI_Opportunity__c 
            FROM Case 
            WHERE Id IN :caseIdSet
        ];
        
        for (Case cs : caseList) {
            if (cs.EYI_Opportunity__c != null) {
                caseIdToOppId.put(cs.Id, cs.EYI_Opportunity__c);
            }
        }

        // Build the Opportunity → List of Comment Names
        for (EYI_Comments__c ecm : newCommentList) {
            Id oppId = caseIdToOppId.get(ecm.EYI_Synced_Case__c);
            if (oppId != null) {
                if (!oppIdToNCFNames.containsKey(oppId)) {
                    oppIdToNCFNames.put(oppId, new List<String>());
                }
                oppIdToNCFNames.get(oppId).add(ecm.Name);
            }
        }

        if (oppIdToNCFNames.isEmpty()) {
            return; // Nothing to notify
        }

        Set<Id> oppIds = oppIdToNCFNames.keySet();
        List<EYI_FCM_Detail__c> fcmDetails = [
            SELECT EYI_Custom_Device_ID__c, EYI_Opportunity__c
            FROM EYI_FCM_Detail__c 
            WHERE EYI_Opportunity__c IN :oppIds AND EYI_Custom_Device_ID__c != null
        ];
        
        if (fcmDetails.isEmpty()) {
            return;
        }

        // Map Opportunity Id → List of Device Tokens
        Map<Id, List<String>> oppIdToDeviceTokens = new Map<Id, List<String>>();
        for (EYI_FCM_Detail__c detail : fcmDetails) {
            if (!oppIdToDeviceTokens.containsKey(detail.EYI_Opportunity__c)) {
                oppIdToDeviceTokens.put(detail.EYI_Opportunity__c, new List<String>());
            }
            oppIdToDeviceTokens.get(detail.EYI_Opportunity__c).add(detail.EYI_Custom_Device_ID__c);
        }

        String title = 'Case Comment is Created';

        for (Id oppId : oppIdToNCFNames.keySet()) {
            List<String> demandNames = oppIdToNCFNames.get(oppId);
            String demandsListStr = String.join(demandNames, ', ');
            String body = 'Case Comment is Created: ' + demandsListStr;

            List<String> tokens = oppIdToDeviceTokens.get(oppId);
            if (tokens != null && !tokens.isEmpty()) {
                // Find one caseId linked to this oppId
                Id caseId = null;
                for (Id cId : caseIdToOppId.keySet()) {
                    if (caseIdToOppId.get(cId) == oppId) {
                        caseId = cId;
                        break;
                    }
                }

                if (caseId != null) {
                    EYI_FCMServiceController.sendNotification(tokens, title, body, 'case_update', caseId);
                }
            }
        }
    }
}