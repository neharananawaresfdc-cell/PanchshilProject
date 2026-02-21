trigger EYI_CIFRecordsTrigger on EYI_Customer_Information_Form__c (before insert,before update, after insert, after update  ) {
    
    // EYI_Notification_Settings__c customSetting = EYI_Notification_Settings__c.getOrgDefaults();
    // if(trigger.isAfter && customSetting.EYI_Is_Notifications_Enabled__c){
    //    EYI_NotificationHandler.handleTrigger(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
    // }
}