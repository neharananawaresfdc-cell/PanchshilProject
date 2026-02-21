trigger EYI_LeadTrigger on Lead (before insert,before update,after insert, after update  ) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_LeadTrigger').EYI_Active__c){

  	EYI_Notification_Settings__c customSetting = EYI_Notification_Settings__c.getOrgDefaults();
    EYI_DuplicateDetectorSettings__c duplicateDetectorSetting = EYI_DuplicateDetectorSettings__c.getOrgDefaults();
    if(trigger.isAfter && customSetting.EYI_Is_Notifications_Enabled__c){
        System.debug('inside IsAfter');
       // EYI_NotificationHandler.handleTrigger(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
    }
    if(trigger.isAfter && duplicateDetectorSetting.EYI_Is_DuplicateDetector_Enabled__c){
      //  EYI_LeadTriggerHandler.EYI_LeadTriggerHandler(trigger.newMap, trigger.oldMap);
        DuplicateDetectorClass detector = new DuplicateDetectorClass();
       DuplicateDetectorClass.isDuplicate('Lead_Duplicate','EY_Lead_Duplicate_Detector_rules__mdt',trigger.newMap,trigger.oldMap);
    }
    if((trigger.isInsert || trigger.isUpdate)&& trigger.isBefore){
        system.debug('testBefore');
        EYI_LeadTriggerHandler.updateProjectOnLead(Trigger.new);
    }
    }
}