public class EYI_ApplicantTriggerHandler {
    
    public static void updateOpportunityMobiles(List<EYI_Applicants__c> newList) {
        Set<Id> oppIds = new Set<Id>();
        for (EYI_Applicants__c app : newList) {
            if (app.Opportunity__c != null) {
                oppIds.add(app.Opportunity__c);
            }
        }
        if (oppIds.isEmpty()) return;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, EYI_Mobile_Number__c, EYI_Applicant2_Mobile__c, EYI_Applicant3_Mobile__c, 
                    EYI_Applicant4_Mobile__c, EYI_Applicant5_Mobile__c, EYI_Applicant6_Mobile__c,
                    (SELECT Id, EYI_Applicant_Type__c, EYI_Mobile_Number__c FROM Applicants__r ORDER BY CreatedDate)
             FROM Opportunity
             WHERE Id IN :oppIds]
        );

        List<Opportunity> updatedOpportunities = new List<Opportunity>();

        for (Opportunity opp : oppMap.values()) {
            List<EYI_Applicants__c> applicants = opp.Applicants__r;
            Opportunity updatedOpp = new Opportunity(Id = opp.Id);

            Integer coApplicantIndex = 2;
            Boolean primaryUpdated = false;

            for (EYI_Applicants__c app : applicants) {
                if (String.isNotBlank(app.EYI_Mobile_Number__c) && String.isNotBlank(app.EYI_Applicant_Type__c)) {
                    String applicantType = app.EYI_Applicant_Type__c.trim().toLowerCase();

                    if (applicantType == 'primary' && !primaryUpdated) {
                        updatedOpp.EYI_Mobile_Number__c = app.EYI_Mobile_Number__c;
                        primaryUpdated = true;
                    } else if (applicantType == 'co-applicant' && coApplicantIndex <= 6) {
                        String fieldName = 'EYI_Applicant' + coApplicantIndex + '_Mobile__c';
                        updatedOpp.put(fieldName, app.EYI_Mobile_Number__c);
                        coApplicantIndex++;
                    }
                }
            }

            updatedOpp.EYI_AutomationBypassDatetime__c = Datetime.now(); 
            updatedOpportunities.add(updatedOpp);
        }

        if (!updatedOpportunities.isEmpty()) {
            update updatedOpportunities;
        }
    }
    
    public static void handleStatusChange(Map<Id, EYI_Applicants__c> oldMap, Map<Id, EYI_Applicants__c> newMap) {
    // Map of Opportunity Id → List of Demand Names whose status changed to "Demand Raised"
    Map<Id, List<String>> oppIdToDemandNames = new Map<Id, List<String>>();

    // Step 1: Collect Opportunity IDs and Demand Names grouped by Opportunity
    for (Id demandId : newMap.keySet()) {
        EYI_Applicants__c oldDemand = oldMap.get(demandId);
        EYI_Applicants__c newDemand = newMap.get(demandId);

        if (oldDemand.isKYCDone__c != true && newDemand.isKYCDone__c == true) {
            Id oppId = newDemand.Opportunity__c;
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
    String title = 'Update Customer KYC';

    for (Id oppId : oppIdToDemandNames.keySet()) {
        List<String> demandNames = oppIdToDemandNames.get(oppId);
        String demandsListStr = String.join(demandNames, ', ');

        String body = 'KYC is completed: ' + demandsListStr;

        List<String> tokens = oppIdToDeviceTokens.get(oppId);
        if (tokens != null && !tokens.isEmpty()) {
           EYI_FCMServiceController.sendNotification(tokens, title, body, 'kyc_done','');
        }
    }
}
}