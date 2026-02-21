public class EYI_UpdateDemandDateTriggerHandler {
    public static void handleAfterUpdate(Map<Id,EYI_Payment_Schedule__c> newMap, Map<Id, EYI_Payment_Schedule__c> oldMap){
        List<EYI_Demand__c> recordsToUpdate = new List<EYI_Demand__c>();
        Set<Id> paymentScheduleIds = new Set<Id>();
        for (Id payId : newMap.keySet()) {
            EYI_Payment_Schedule__c newPay = newMap.get(payId);
            EYI_Payment_Schedule__c oldPay = oldMap.get(payId);
            
            if (newPay.EYI_Actual_Date__c != oldPay.EYI_Actual_Date__c) {
                paymentScheduleIds.add(payId);
                system.debug(paymentScheduleIds);
            }
        }
        if (!paymentScheduleIds.isEmpty()){
            
            for(EYI_Demand__c dem : [select id,EYI_Actual_Date__c, EYI_Payment_Schedule__c from EYI_Demand__c where EYI_Payment_Schedule__c IN:paymentScheduleIds]){
                
               dem.EYI_Actual_Date__c = newMap.get(dem.EYI_Payment_Schedule__c).EYI_Actual_Date__c;
                recordsToUpdate.add(dem);
            }
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
                System.debug('Updated rec --> ' + recordsToUpdate);
            }
            
        }
        
        
    }
    
}