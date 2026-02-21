trigger EYI_DeviationPlanTrigger on EYI_Deviation_Plan__c (before update, after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_DeviationPlanTrigger').EYI_Active__c){

        if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            EYI_DeviationPlanTriggerHandler.makeRejectionCommentMandatory(Trigger.new,Trigger.oldMap);
        }
    }
    }

}