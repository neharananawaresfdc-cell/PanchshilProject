trigger EYI_CaseTrigger on Case (before update,after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_CaseTrigger').EYI_Active__c){
        if(trigger.isBefore){
            if(trigger.isUpdate){
                EYI_CaseTriggerHandler.generateOTP(trigger.new, trigger.newMap, trigger.oldMap);
                EYI_CaseTriggerHandler.verifyOTP(trigger.new, trigger.newMap, trigger.oldMap);
                EYI_CaseTriggerHandler.beforeUpdate(trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
        if(trigger.isAfter){
            if(trigger.isUpdate){
                System.debug('Inside calling case push notification');
                EYI_CaseTriggerHandler.handleStatusChange(Trigger.oldMap, Trigger.newMap);
            }
        } 
    }
    
}