public with sharing class EYI_PaymentSchedulesUtility {
    @AuraEnabled(cacheable=true)
    public static List<EYI_Payment_Milestone_Usage_Mapping__mdt> getUsageMappingMetadata() {
        //system.debug(PaymentPlanId);
        return [Select Id,MasterLabel,DeveloperName FROM EYI_Payment_Milestone_Usage_Mapping__mdt];
       
    }
    @AuraEnabled(cacheable=true)
    public static List<EYI_Payment_Schedule__c> getPaymentSchedules(String recordId) {
        //system.debug(PaymentPlanId);
        List<EYI_Payment_Schedule__c> fl = new List<EYI_Payment_Schedule__c>();
        List<EYI_Payment_Schedule__c> fl1 = [Select Id,Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c,Payment_Plan__r.EYI_Quote__c,Payment_Plan__r.EYI_Quote__r.OpportunityId,Payment_Plan__r.EYI_Plan_Type__c,EYI_Usage_Description__c,EYI_Usage__c, EYI_Invoice_Percentage__c, EYI_Billing_Date__c,EYI_Due_Amount__c,EYI_Amount_to_be_paid__c,EYI_Payable_Amount__c,EYI_TDS__c,Payment_Plan__r.Project__r.EYI_TDS_Charge__c,Payment_Plan__r.EYI_Quote__r.EYI_Quoatation_Grand_Total__c,EYI_Net_Payable__c,EYI_GST__c,EYI_Actual_Date__c,Payment_Plan__r.EYI_Is_Extended__c,Payment_Plan__r.Project__r.EYI_GST_Pay_Schedule_Charge__c,Payment_Plan__r.Project__r.EYI_NPV_Percent__c,EYI_Milestone_Number__c from EYI_Payment_Schedule__c
                Where Payment_Plan__c = :recordId AND EYI_Actual_Date__c != null ORDER BY EYI_Actual_Date__c ASC];
        fl.addAll(fl1);
        List<EYI_Payment_Schedule__c> fl2 = [Select Id,Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c,Payment_Plan__r.EYI_Quote__c,Payment_Plan__r.EYI_Quote__r.OpportunityId,Payment_Plan__r.EYI_Plan_Type__c,EYI_Usage_Description__c,EYI_Usage__c, EYI_Invoice_Percentage__c, EYI_Billing_Date__c,EYI_Due_Amount__c,EYI_Amount_to_be_paid__c,EYI_Payable_Amount__c,EYI_TDS__c,Payment_Plan__r.Project__r.EYI_TDS_Charge__c,Payment_Plan__r.EYI_Quote__r.EYI_Quoatation_Grand_Total__c,EYI_Net_Payable__c,EYI_GST__c,EYI_Actual_Date__c,Payment_Plan__r.EYI_Is_Extended__c,Payment_Plan__r.Project__r.EYI_GST_Pay_Schedule_Charge__c,Payment_Plan__r.Project__r.EYI_NPV_Percent__c,EYI_Milestone_Number__c from EYI_Payment_Schedule__c
                Where Payment_Plan__c = :recordId AND EYI_Actual_Date__c = null ORDER BY  EYI_Actual_Date__c ASC];
        fl.addAll(fl2);        
        return fl;
       
    }
    @AuraEnabled
    public static String updatePaymentSchedules(List<EYI_Payment_Schedule__c> paymentSchedules) {
        upsert paymentSchedules;
        return 'Success';
    }
    @AuraEnabled
    public static String deletePaymentSchedules(String paymentScheduleId) {
        EYI_Payment_Schedule__c paymentSchedule = new EYI_Payment_Schedule__c();
        paymentSchedule.Id = paymentScheduleId;
        List<EYI_Payment_Schedule__c> paymentSchedules = new List<EYI_Payment_Schedule__c>();
        paymentSchedules.add(paymentSchedule);
        Delete paymentSchedules;
        return 'Success';
    }
}