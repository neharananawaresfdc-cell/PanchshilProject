trigger EYI_LeadEnquiryTrigger on EYI_Lead_Enquiry__c (before insert,before update,after insert, after update  ) {
   
    //EYI_Notification_Settings__c customSetting = EYI_Notification_Settings__c.getOrgDefaults();
    //if(trigger.isAfter && customSetting.EYI_Is_Notifications_Enabled__c){
      // EYI_NotificationHandler.handleTrigger(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
    //}
    if(EYI_Trigger_Control__mdt.getInstance('EYI_LeadEnquiryTrigger').EYI_Active__c){
    if(trigger.isbefore && trigger.isinsert){
        EYI_LeadEnquiryTriggerHandler.updateEscalationTimeOnEnquiry(Trigger.new);
       // EYI_LeadEnquiryTriggerHandler.updateParentOwnerTLLostLead(Trigger.new);
    }
    if(trigger.isAfter && trigger.isupdate){
        EYI_LeadEnquiryTriggerHandler.updateDNCOnAllRecords(Trigger.new);
       EYI_LeadEnquiryTriggerHandler.shareRecordAccesstoLeasingTeam(Trigger.oldMap,Trigger.newMap);
        EYI_LeadEnquiryTriggerHandler.shareRecordAccess(Trigger.new,Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isinsert){
        EYI_LeadEnquiryTriggerHandler.updateTotalCountOnLead(Trigger.new);
        
    }
       
            
        
    if(trigger.isbefore && (trigger.isinsert || trigger.isupdate)){
        system.debug('enter in condition');
        EYI_LeadEnquiryTriggerHandler.updateProjectOnLead(Trigger.new,Trigger.oldMap);
    }
    }
}