public class DemandTriggerHandler {

   public static void handleStatusChange(Map<Id, EYI_Demand__c> oldMap, Map<Id, EYI_Demand__c> newMap) {
    // Map of Opportunity Id → List of Demand Names whose status changed to "Demand Raised"
    Map<Id, List<String>> oppIdToDemandNames = new Map<Id, List<String>>();

    // Step 1: Collect Opportunity IDs and Demand Names grouped by Opportunity
    for (Id demandId : newMap.keySet()) {
        EYI_Demand__c oldDemand = oldMap.get(demandId);
        EYI_Demand__c newDemand = newMap.get(demandId);

        if (oldDemand.EYI_Demand_Status__c != 'Demand Raised' && newDemand.EYI_Demand_Status__c == 'Demand Raised') {
            Id oppId = newDemand.EYI_Opportunity__c;
            if (oppId != null) {
                if (!oppIdToDemandNames.containsKey(oppId)) {
                    oppIdToDemandNames.put(oppId, new List<String>());
                }
                oppIdToDemandNames.get(oppId).add(newDemand.Name);
            }
        }
    }

    if (oppIdToDemandNames.isEmpty()) {
        return; // Nothing to notify
    }

    // Step 2: Query device tokens for all Opportunities involved
    Set<Id> oppIds = oppIdToDemandNames.keySet();
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
    String title = 'New Demand Requested';

    for (Id oppId : oppIdToDemandNames.keySet()) {
        List<String> demandNames = oppIdToDemandNames.get(oppId);
        String demandsListStr = String.join(demandNames, ', ');

        String body = 'Demand status changed to Demand Raised for: ' + demandsListStr;

        List<String> tokens = oppIdToDeviceTokens.get(oppId);
        if (tokens != null && !tokens.isEmpty()) {
            EYI_FCMServiceController.sendNotification(tokens, title, body, 'demand_letter','');
        }
    }
}

}