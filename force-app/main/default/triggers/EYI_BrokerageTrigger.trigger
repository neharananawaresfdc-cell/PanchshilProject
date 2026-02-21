trigger EYI_BrokerageTrigger on EYI_Brokerage__c (before update, after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_BrokerageTrigger').EYI_Active__c){
        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                EYI_BrokerageTriggerHandler.makeRejectionCommentMandatory(Trigger.new,Trigger.oldMap);
            }
        }
    }
}