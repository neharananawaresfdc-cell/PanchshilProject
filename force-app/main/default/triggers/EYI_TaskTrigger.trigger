trigger EYI_TaskTrigger on Task (before insert, before update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_TaskTrigger').EYI_Active__c){
        if(trigger.isbefore && trigger.isinsert ){
            EYI_TaskTriggerHandler.handleEscalation(Trigger.new);
        }
    } 
}