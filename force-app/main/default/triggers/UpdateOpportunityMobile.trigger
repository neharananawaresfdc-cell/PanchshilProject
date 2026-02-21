trigger UpdateOpportunityMobile on EYI_Applicants__c (after insert, after update) {
    if(EYI_Trigger_Control__mdt.getInstance('UpdateOpportunityMobile').EYI_Active__c){
        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                EYI_ApplicantTriggerHandler.updateOpportunityMobiles(Trigger.new);
            }
            if(Trigger.isUpdate){
                EYI_ApplicantTriggerHandler.handleStatusChange(Trigger.oldMap,Trigger.newMap);
            }
        }
    }
}