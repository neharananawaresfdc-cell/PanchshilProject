trigger EYI_CommentTrigger on EYI_Comments__c (after insert) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_Comment').EYI_Active__c){
        if(trigger.isAfter && trigger.isInsert){
            EYI_CommentTriggerHandler.handleStatusChange(Trigger.New);
        }
    } 
}