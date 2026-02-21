trigger EYI_ProjectTrigger on EYI_Project__c (after insert, after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_Project').EYI_Active__c){
    EYI_ProjectSyncToMobileApp.handleProjectSync(Trigger.new,Trigger.oldMap,Trigger.isInsert, Trigger.isUpdate);
    }
}