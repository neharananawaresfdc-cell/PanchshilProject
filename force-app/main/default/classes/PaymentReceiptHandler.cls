public class PaymentReceiptHandler {

    public static void processFromReceipts(List<EYI_Payment_Receipt__c> receipts) {
        Set<Id> receiptIds = new Set<Id>();
        for (EYI_Payment_Receipt__c pr : receipts) {
            receiptIds.add(pr.Id);
        }
        if (!receiptIds.isEmpty()) {
        processFromReceiptIds(receiptIds);
        }
    }

    public static void processFromReceiptIds(Set<Id> receiptIds) {
        if (receiptIds.isEmpty()) return;
        List<EYI_Payment_Line_Item__c> lineItems = [
            SELECT Id, EYI_Billing_Document__c, EYI_Payment_Receipt__c
            FROM EYI_Payment_Line_Item__c
            WHERE EYI_Payment_Receipt__c IN :receiptIds AND EYI_Billing_Document__c != null
        ];
            if (lineItems == null || lineItems.isEmpty()) return;
        
        Map<String, Set<Id>> docNumToReceiptIds = new Map<String, Set<Id>>();
        for (EYI_Payment_Line_Item__c pli : lineItems) {
            if (!docNumToReceiptIds.containsKey(pli.EYI_Billing_Document__c)) {
                docNumToReceiptIds.put(pli.EYI_Billing_Document__c, new Set<Id>());
            }
            docNumToReceiptIds.get(pli.EYI_Billing_Document__c).add(pli.EYI_Payment_Receipt__c);
        }

        if (docNumToReceiptIds == null || docNumToReceiptIds.isEmpty()) return;

        //Fetch matching demands
        List<EYI_Demand__c> matchedDemands = [
            SELECT Id, EYI_SAP_Demand_Number__c
            FROM EYI_Demand__c
            WHERE EYI_SAP_Demand_Number__c IN :docNumToReceiptIds.keySet()
        ];
         
        if (matchedDemands == null || matchedDemands.isEmpty()) return;
        
        //Prepare all possible demand-receipt mappings
        Set<String> mappingKeys = new Set<String>();
        for (EYI_Demand__c demand : matchedDemands) {
            for (Id receiptId : docNumToReceiptIds.get(demand.EYI_SAP_Demand_Number__c)) {
                mappingKeys.add(demand.Id + '-' + receiptId);
            }
        }

        if (mappingKeys.isEmpty()) return;

        Set<Id> demandIds = new Set<Id>();
        Set<Id> receiptIdSet = new Set<Id>();
        for (String key : mappingKeys) {
            List<String> parts = key.split('-');
            if (parts.size() == 2) {
                demandIds.add((Id) parts[0]);
                receiptIdSet.add((Id) parts[1]);
            }
        }

        Set<String> existingKeys = new Set<String>();
        for (EYI_Demand_Receipt_Mapping__c drm : [
            SELECT EYI_Demand__c, EYI_Bank_Payment_Receipt__c
            FROM EYI_Demand_Receipt_Mapping__c
            WHERE EYI_Demand__c IN :demandIds AND EYI_Bank_Payment_Receipt__c IN :receiptIdSet
        ]) {
            existingKeys.add(drm.EYI_Demand__c + '-' + drm.EYI_Bank_Payment_Receipt__c);
        }
        
        //Insert missing mappings
        List<EYI_Demand_Receipt_Mapping__c> newMappings = new List<EYI_Demand_Receipt_Mapping__c>();
        for (EYI_Demand__c demand : matchedDemands) {
            for (Id receiptId : docNumToReceiptIds.get(demand.EYI_SAP_Demand_Number__c)) {
                String key = demand.Id + '-' + receiptId;
                if (!existingKeys.contains(key)) {
                    newMappings.add(new EYI_Demand_Receipt_Mapping__c(
                        EYI_Demand__c = demand.Id,
                        EYI_Bank_Payment_Receipt__c = receiptId
                    ));
                }
            }
        }

        if (!newMappings.isEmpty()) {
            insert newMappings;
        }
    }

    public static void cleanUpDeletedLineItems(Set<Id> receiptIds) {
        if (receiptIds.isEmpty()) return;

        // Get remaining document numbers for the receipts
        Map<Id, Set<String>> receiptToRemainingDocNums = new Map<Id, Set<String>>();
        for (EYI_Payment_Line_Item__c pli : [
            SELECT EYI_Payment_Receipt__c, EYI_Billing_Document__c
            FROM EYI_Payment_Line_Item__c
            WHERE EYI_Payment_Receipt__c IN :receiptIds AND EYI_Billing_Document__c != null
        ]) {
            if (!receiptToRemainingDocNums.containsKey(pli.EYI_Payment_Receipt__c)) {
                receiptToRemainingDocNums.put(pli.EYI_Payment_Receipt__c, new Set<String>());
            }
            receiptToRemainingDocNums.get(pli.EYI_Payment_Receipt__c).add(pli.EYI_Billing_Document__c);
        }

        // Get all mappings for these receipts
        List<EYI_Demand_Receipt_Mapping__c> mappingsToDelete = new List<EYI_Demand_Receipt_Mapping__c>();
        for (EYI_Demand_Receipt_Mapping__c drm : [
            SELECT Id, EYI_Demand__r.EYI_SAP_Demand_Number__c, EYI_Bank_Payment_Receipt__c
            FROM EYI_Demand_Receipt_Mapping__c
            WHERE EYI_Bank_Payment_Receipt__c IN :receiptIds
        ]) {
            Set<String> remainingDocNums = receiptToRemainingDocNums.get(drm.EYI_Bank_Payment_Receipt__c);
            if (remainingDocNums == null || !remainingDocNums.contains(drm.EYI_Demand__r.EYI_SAP_Demand_Number__c)) {
                mappingsToDelete.add(drm);
            }
        }

        if (!mappingsToDelete.isEmpty()) {
            delete mappingsToDelete;
        }
    }
    
    public static void updateDemandStatusForApprovedReceipts(Set<Id> approvedReceiptIds) {
        if (approvedReceiptIds.isEmpty()) return;

        //Get mappings for approved receipts
        List<EYI_Demand_Receipt_Mapping__c> mappings = [
            SELECT Id, EYI_Demand__c, EYI_Bank_Payment_Receipt__c
            FROM EYI_Demand_Receipt_Mapping__c
            WHERE EYI_Bank_Payment_Receipt__c IN :approvedReceiptIds
        ];

        Map<Id, Set<Id>> receiptToDemandMap = new Map<Id, Set<Id>>();
        Set<Id> allDemandIds = new Set<Id>();
        for (EYI_Demand_Receipt_Mapping__c drm : mappings) {
            if (!receiptToDemandMap.containsKey(drm.EYI_Bank_Payment_Receipt__c)) {
                receiptToDemandMap.put(drm.EYI_Bank_Payment_Receipt__c, new Set<Id>());
            }
            receiptToDemandMap.get(drm.EYI_Bank_Payment_Receipt__c).add(drm.EYI_Demand__c);
            allDemandIds.add(drm.EYI_Demand__c);
        }

        if (allDemandIds.isEmpty()) return;

        //Fetch Demands and Receipts
        Map<Id, EYI_Demand__c> demandMap = new Map<Id, EYI_Demand__c>(
            [SELECT Id, EYI_Amount_to_be_paid__c, EYI_Demand_Payment_Status__c FROM EYI_Demand__c WHERE Id IN :allDemandIds]
        );

        Map<Id, EYI_Payment_Receipt__c> receiptMap = new Map<Id, EYI_Payment_Receipt__c>(
            [SELECT Id, EYI_Amount__c FROM EYI_Payment_Receipt__c WHERE Id IN :approvedReceiptIds]
        );

        //Case 1 - One Receipt → Many Demands
        List<EYI_Demand__c> demandsToUpdate = new List<EYI_Demand__c>();
        for (Id receiptId : receiptToDemandMap.keySet()) {
            Set<Id> demandIds = receiptToDemandMap.get(receiptId);
            Decimal totalDemandAmount = 0;

            for (Id demandId : demandIds) {
                if (demandMap.containsKey(demandId)) {
                    totalDemandAmount += demandMap.get(demandId).EYI_Amount_to_be_paid__c;
                }
            }

            Decimal receiptAmount = receiptMap.containsKey(receiptId) ? receiptMap.get(receiptId).EYI_Amount__c : 0;

            if (totalDemandAmount == receiptAmount) {
                for (Id demandId : demandIds) {
                    EYI_Demand__c demand = demandMap.get(demandId);
                    if (demand != null && demand.EYI_Demand_Payment_Status__c != 'Completed') {
                        demand.EYI_Demand_Payment_Status__c = 'Completed';
                        demandsToUpdate.add(demand);
                    }
                }
            }
        }

        // Case 2 - One Demand → Many Receipts
        // Get all mappings for the involved demands (to get all receipts linked)
        List<EYI_Demand_Receipt_Mapping__c> demandMappings = [
            SELECT EYI_Demand__c, EYI_Bank_Payment_Receipt__c
            FROM EYI_Demand_Receipt_Mapping__c
            WHERE EYI_Demand__c IN :allDemandIds
        ];

        Map<Id, Set<Id>> demandToReceiptMap = new Map<Id, Set<Id>>();
        Set<Id> receiptIdsForDemands = new Set<Id>();

        for (EYI_Demand_Receipt_Mapping__c drm : demandMappings) {
            if (!demandToReceiptMap.containsKey(drm.EYI_Demand__c)) {
                demandToReceiptMap.put(drm.EYI_Demand__c, new Set<Id>());
            }
            demandToReceiptMap.get(drm.EYI_Demand__c).add(drm.EYI_Bank_Payment_Receipt__c);
            receiptIdsForDemands.add(drm.EYI_Bank_Payment_Receipt__c);
        }

        Map<Id, EYI_Payment_Receipt__c> allReceiptsMap = new Map<Id, EYI_Payment_Receipt__c>(
            [SELECT Id, EYI_Amount__c, EYI_Payment_Status__c FROM EYI_Payment_Receipt__c WHERE Id IN :receiptIdsForDemands]
        );

        for (Id demandId : demandToReceiptMap.keySet()) {
            Decimal approvedTotal = 0;
            Set<Id> relatedReceipts = demandToReceiptMap.get(demandId);

            Boolean allApproved = true;
            for (Id receiptId : relatedReceipts) {
                EYI_Payment_Receipt__c pr = allReceiptsMap.get(receiptId);
                if (pr != null && pr.EYI_Payment_Status__c == 'APPROVE') {
                    approvedTotal += pr.EYI_Amount__c;
                } else {
                    allApproved = false;
                }
            }

            EYI_Demand__c demand = demandMap.get(demandId);
            if (allApproved && demand != null && approvedTotal == demand.EYI_Amount_to_be_paid__c && demand.EYI_Demand_Payment_Status__c != 'Completed') {
                demand.EYI_Demand_Payment_Status__c = 'Completed';
                demandsToUpdate.add(demand);
            }
        }

        if (!demandsToUpdate.isEmpty()) {
            update demandsToUpdate;
        }
    }
    public static void handleStatusChange(Map<Id, EYI_Payment_Receipt__c> oldMap, Map<Id, EYI_Payment_Receipt__c> newMap){
        Map<Id, List<String>> oppIdToPRNames = new Map<Id, List<String>>();

    // Step 1: Collect Opportunity IDs and Demand Names grouped by Opportunity
    for (Id demandId : newMap.keySet()) {
        EYI_Payment_Receipt__c oldReceipt = oldMap.get(demandId);
        EYI_Payment_Receipt__c newReceipt = newMap.get(demandId);

        if (oldReceipt.EYI_Payment_Status__c != 'APPROVE' && newReceipt.EYI_Payment_Status__c == 'APPROVE') {
            Id oppId = newReceipt.EYI_Opportunity__c;
            if (oppId != null) {
                if (!oppIdToPRNames.containsKey(oppId)) {
                    oppIdToPRNames.put(oppId, new List<String>());
                }
                oppIdToPRNames.get(oppId).add(newReceipt.Name);
            }
        }
    }
	
    if (oppIdToPRNames.isEmpty()) {
        return; // Nothing to notify
    }

    // Step 2: Query device tokens for all Opportunities involved
    Set<Id> oppIds = oppIdToPRNames.keySet();
    List<EYI_FCM_Detail__c> fcmDetails = [
        SELECT EYI_Custom_Device_ID__c,EYI_Opportunity__c
        FROM EYI_FCM_Detail__c 
        WHERE EYI_Opportunity__c IN :oppIds AND EYI_Custom_Device_ID__c != null
    ];
        
       if(fcmDetails.isEmpty()){
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

    // Step 3: Send notifications per Opportunity with demand names included
    String title = 'Payment Processed Successfully';

    for (Id oppId : oppIdToPRNames.keySet()) {
        List<String> demandNames = oppIdToPRNames.get(oppId);
        String demandsListStr = String.join(demandNames, ', ');

        String body = 'Payment Receipt status changed to Approved: ' + demandsListStr;

        List<String> tokens = oppIdToDeviceTokens.get(oppId);
                 
              
        if (tokens != null && !tokens.isEmpty()) {
            EYI_FCMServiceController.sendNotification(tokens, title, body, 'payment_receipt','');
        }
    }
    }
}