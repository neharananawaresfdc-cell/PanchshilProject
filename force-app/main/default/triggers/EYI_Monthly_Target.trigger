trigger EYI_Monthly_Target on Monthly_Target__c (before insert, after update, before update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_Monthly_Target').EYI_Active__c){
        if(trigger.isAfter && trigger.isupdate){
            EYI_Monthly_TargetTriggerHandler.shareRecordAccessMTtoRM(Trigger.new,Trigger.oldMap);
        }
    } 
}