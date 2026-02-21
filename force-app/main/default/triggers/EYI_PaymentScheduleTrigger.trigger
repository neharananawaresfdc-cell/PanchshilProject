trigger EYI_PaymentScheduleTrigger on EYI_Payment_Schedule__c (after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_PaymentSchedule').EYI_Active__c){
        if (Trigger.isAfter && Trigger.isUpdate) {
            EYI_UpdateDemandDateTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        } 
    }
}