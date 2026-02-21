public with sharing class EYI_CaseTriggerHandler {
    public static void generateOTP(list<Case> newList, map<Id, Case> newMap, map<Id, Case> oldMap){
        for(Case c : newList){
            if((c.EYI_Case_Category__c == 'Complaints_PrePossession' || c.EYI_Case_Category__c == 'Complaints_PostPossession') && c.Status == 'Resolved' && oldMap.get(c.Id).Status != 'Resolved'){
                Integer otp = (Integer)(Math.random() * 900000) + 100000;
                c.Generated_OTP__c = String.valueOf(otp);
                c.EYI_Enter_OTP__c = null;
            }
        }
    } 
    
    public static void verifyOTP(list<Case> newList, map<Id, Case> newMap, map<Id, Case> oldMap){
        for(Case c : newList){
            if((c.EYI_Case_Category__c == 'Complaints_PrePossession' || c.EYI_Case_Category__c == 'Complaints_PostPossession') && c.Status == 'Resolved' && oldMap.get(c.Id).Status == 'Resolved' && c.EYI_Enter_OTP__c !=null){
                if(c.EYI_Enter_OTP__c == c.Generated_OTP__c){
                    c.Status = 'Closed';
                    c.EYI_Case_Closed_Date_Time__c = System.now();
                }else{
                    c.EYI_Enter_OTP__c.addError('Wrong OTP');
                }
            }
        }
    }
    
    public static void beforeUpdate(list<Case> newList, map<Id, Case> newMap, map<Id, Case> oldMap){
        for(Case c : newList){
            if((c.EYI_Case_Category__c == 'Complaints_PrePossession' || c.EYI_Case_Category__c == 'Complaints_PostPossession') && c.Status == 'Closed' && oldMap.get(c.Id).Status != 'Closed' && oldMap.get(c.Id).Status != 'Resolved'){
                c.Status.adderror('Please mark resolved case status');
            }
        }
    }
    
    public static void handleStatusChange(Map<Id, Case> oldMap, Map<Id, Case> newMap){
        Map<Id, List<String>> oppIdToCaseNames = new Map<Id, List<String>>();
        
        // Step 1: Collect Opportunity IDs and Demand Names grouped by Opportunity...
        for (Id caseId : newMap.keySet()) {
            Case oldCase = oldMap.get(caseId);
            Case newCase = newMap.get(caseId);
            
            if (oldCase.Status != newCase.Status) {
                if (newCase.EYI_Opportunity__c != null) {
                    if (!oppIdToCaseNames.containsKey(newCase.EYI_Opportunity__c)) {
                        oppIdToCaseNames.put(newCase.EYI_Opportunity__c, new List<String>());
                    }
                    oppIdToCaseNames.get(newCase.EYI_Opportunity__c).add(newCase.CaseNumber);
                }
            }
        }
        
        if (oppIdToCaseNames.isEmpty()) {
            return; // Nothing to notify
        }
        
        // Step 2: Query device tokens for all Opportunities involved
        Set<Id> oppIds = oppIdToCaseNames.keySet();
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
        
        // Step 3: Send notifications per Opportunity with demand names included
        String title = 'Status Updated';
        
        for (Id oppId : oppIdToCaseNames.keySet()) {
            List<String> demandNames = oppIdToCaseNames.get(oppId);
            String demandsListStr = String.join(demandNames, ', ');
            String body = 'Case status is updated: ' + demandsListStr;   
            
            List<String> tokens = oppIdToDeviceTokens.get(oppId);
            if (tokens != null && !tokens.isEmpty()) {
                // Get one related caseId with status change to include in notification
                Id caseId = null;
                for (Id cId : newMap.keySet()) {
                    Case newCase = newMap.get(cId);
                    Case oldCase = oldMap.get(cId);
                    if (newCase.EYI_Opportunity__c == oppId && oldCase.Status != newCase.Status) {
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