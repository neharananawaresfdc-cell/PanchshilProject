trigger EYI_RECAccountTrigger on EYI_REC__c (after insert, after update) {
    EYI_Trigger_Control__mdt triggerSettings = EYI_Trigger_Control__mdt.getInstance('EYI_RECAccountTrigger');
    if(triggerSettings != NULL && triggerSettings.EYI_Active__c) {
        if (Trigger.isAfter && Trigger.isInsert) {
            EYI_RECHandler.createRecMappings(Trigger.newMap);
        }
    }
}