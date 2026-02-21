trigger EYI_OpportunityTrigger on Opportunity ( after insert, after update  ) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_OpportunityTrigger').EYI_Active__c){
        if (Trigger.isAfter && Trigger.isUpdate) {
            for (Opportunity opp : Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                
                if (EYI_CustomerMasterSyncLwcController.hasSignificantChanges(oldOpp, opp)) {
                    EYI_CustomerMasterSyncLwcController.syncToSAP(opp.Id);
                }
            }
            OpprtunityHandler.handleStatusChange(Trigger.oldMap, Trigger.newMap);
        }
        
        
        //Commented the below code by Rishikesh as it was not being used anywhere
        /*
EYI_Notification_Settings__c customSetting = EYI_Notification_Settings__c.getOrgDefaults();
if(trigger.isAfter && customSetting.EYI_Is_Notifications_Enabled__c){
//  EYI_NotificationHandler.handleTrigger(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}*/
    } 
}