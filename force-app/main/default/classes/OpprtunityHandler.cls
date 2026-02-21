public class OpprtunityHandler {
 public static void handleStatusChange(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Map<Id, List<String>> oppIdToNCFNames = new Map<Id, List<String>>();
	Boolean isNCFChanged = false;
    Boolean isRegistrationComplete =false;
    // Step 1: Collect Opportunity IDs and Demand Names grouped by Opportunity
    for (Id oppId : newMap.keySet()) {
        Opportunity oldOpp = oldMap.get(oppId);
        Opportunity newOpp = newMap.get(oppId);

        if (oldOpp.EYI_NCF_Status__c != 'Received' && newOpp.EYI_NCF_Status__c == 'Received') {
            isNCFChanged = true;
            //Id oppObjId = newOpp.ID;
            if (oppId != null) {
                if (!oppIdToNCFNames.containsKey(oppId)) {
                    oppIdToNCFNames.put(oppId, new List<String>());
                }
                oppIdToNCFNames.get(oppId).add(newOpp.Name);
            }
        }
         if (oldOpp.Registration_Date__c == null && newOpp.Registration_Date__c != null) {
            isRegistrationComplete = true;
            //Id oppObjId = newOpp.ID;
            if (oppId != null) {
                if (!oppIdToNCFNames.containsKey(oppId)) {
                    oppIdToNCFNames.put(oppId, new List<String>());
                }
                oppIdToNCFNames.get(oppId).add(newOpp.Name);
            }
        }
    }

    if (oppIdToNCFNames.isEmpty()) {
        return; // Nothing to notify
    }

    // Step 2: Query device tokens for all Opportunities involved
    Set<Id> oppIds = oppIdToNCFNames.keySet();
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
    String title = '';

    for (Id oppId : oppIdToNCFNames.keySet()) {
        List<String> demandNames = oppIdToNCFNames.get(oppId);
        String demandsListStr = String.join(demandNames, ', ');
        String body = '';
        
        if(isNCFChanged == true){
          title = 'NCF Approved';
          body = 'NCF status changed to Received: ' + demandsListStr;   
        }
        if(isRegistrationComplete == true){
          title = 'Registration Date Finalized';
          body = 'Registration finalization: ' + demandsListStr;   
        }
        

        List<String> tokens = oppIdToDeviceTokens.get(oppId);
        if (tokens != null && !tokens.isEmpty()) {
            if(isNCFChanged == true){
              EYI_FCMServiceController.sendNotification(tokens, title, body, 'ncf_changed','');  
            }
            if(isRegistrationComplete == true){
               EYI_FCMServiceController.sendNotification(tokens, title, body, 'registration_confirmed',''); 
            }
            
        }
    }
    }
}