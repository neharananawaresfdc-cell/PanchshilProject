trigger EYI_PricingTrigger on EYI_Rate_List__c (after update, before update,before insert) {
    
    if(EYI_Trigger_Control__mdt.getInstance('EYI_PricingTrigger').EYI_Active__c){
    Set<Id> PricingIds = new Set<Id>();

    if (Trigger.isBefore && Trigger.isUpdate) {
        // Get the field set fields dynamically
        System.debug('Rate list trigger fired');
        EYI_PricingTriggerHandler.handleBeforeUpdate();
    }
    
    if (Trigger.isBefore && Trigger.isInsert) {
        EYI_RateListTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    }
}