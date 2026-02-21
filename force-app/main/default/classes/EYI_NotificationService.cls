/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : EY Notification Framework
 * @last modified on  : 11-21-2024
 * @last modified by  : Digambar Ganage 
**/
public without sharing class EYI_NotificationService {
    //Get Notification Data
    public static List<EYI_Notification> getNotifications(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, TriggerOperation operationType) {
        List<EYI_Notification> notifications = new List<EYI_Notification>();
        // Map<Id,Map<String,String>> mergeFieldsMap = new Map<Id,Map<String,String>>();
        //Get Sobject Name
        Id recordId = newRecords.keySet().iterator().next(); 
        Schema.SObjectType objectType = recordId.getSObjectType();
        String objectName = objectType.getDescribe().getName();
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        // Get the map of fields for the object
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<EYI_Assignment_Group__c> groupAssignedDataList = EYI_AssignmentGroupUtility.getGroupAssignedData(System.Label.Presales_Assignment_Group_Label);
        Map<String, List<EYI_Notification_Template__mdt>> notificationsMap = EYI_CustomMetadataUtility.getNotificationsMetadata(objectName);
        String projectName = '';
        EYI_Notification notification;

        Map<Id, String> userNameMap =EYI_LeadEnquiryUtility.getUsersForLeadHistory();

        //Iterate  over the newmap records
        for (SObject newRecord : newRecords.values()) {
            SObject oldRecord = (oldRecords != null && oldRecords.size() > 0)?oldRecords.get(newRecord.Id):newRecords.get(newRecord.Id);
            //System.debug('newRecord.Id ==> '+ newRecord.Id);

            Map<String, Object> changedFields = EYI_FieldChangeDetector.getChangedFields(oldRecord, newRecord);
            //System.debug('changedFields ==> '+changedFields);
            if (!changedFields.isEmpty() && String.valueOf(operationType) == 'AFTER_UPDATE') {
                for(String fieldName : changedFields.keySet()){
                    List<EYI_Notification_Template__mdt> notificationMetadata =  notificationsMap.get(fieldName); //Bulkified it
                    //System.debug('notificationMetadata ==>'+notificationMetadata);
                    if(notificationMetadata != null && !notificationMetadata.isEmpty()){
                        //System.debug('changedFields ==>54');
                        for(EYI_Notification_Template__mdt metaData : notificationMetadata){
                            if (fieldMap.containsKey(metaData.Notification_Trigger_Fields__c) ) {
                                Datetime createdDate = (Datetime)newRecord.get('CreatedDate');
                                Datetime lastModifiedDate = (Datetime)newRecord.get('LastModifiedDate');
                                Long timeDifference = lastModifiedDate.getTime() - createdDate.getTime();
                                Long timeDifferenceInSeconds = timeDifference / 1000;
                                //System.debug('timeDifferenceInSeconds ==> '+timeDifferenceInSeconds);
                                if(metaData.sObject__c == 'EYI_Lead_Enquiry__c'){
                                    if(fieldName == 'OwnerId' && timeDifferenceInSeconds < 7){
                                        notification = CreateNotifications(metaData,newRecord,changedFields);
                                    }else if(fieldName == 'OwnerId' && timeDifferenceInSeconds > 7){
                                        // Lead Assignement alert to new Owner
                                        notification = new EYI_Notification();
                                        notification.channelType = metaData.Channel_Type__c; 
                                        notification.recipient = (String)newRecord.get(metaData.Recipient_Field__c); 
                                        notification.emailTemplateName = metaData.Email_Template__c;
                                        notification.recordId = newRecord.Id;
                                        notification.recordOwnerId = (String)newRecord.get('OwnerId');
                                        notification.message = 'An enquiry has been reassigned to you.\n' +
                                        'Lead ID: '+ (String)newRecord.get('EYI_Lead_Enquiry_Number__c') +'\n' +
                                        'Old lead Owner Name: '+userNameMap.get((String)oldRecord.get('OwnerId')) +'\n' +
                                        'New Lead owner Name: '+userNameMap.get((String)newRecord.get('OwnerId')) +'\n' +
                                        'Client Name: '+ (String)newRecord.get('Name')+'\n' +
                                        'Project Name: {!EYI_Lead_Enquiry__c.EYI_Project_Enquired__c}\n' ;
                                        notification.notificationName = metaData.MasterLabel;
                                        notification.changedFields = changedFields;
                                        notification.notificationName = 'Lead Owner Change Alert!';
                                        notifications.add(notification);
                                        // Notification to Existing Owner
                                        notification = new EYI_Notification();
                                        notification.channelType = 'System Notification';
                                        notification.recipient = (String)oldRecord.get(metaData.Recipient_Field__c); 
                                        notification.emailTemplateName = metaData.Email_Template__c;
                                        notification.recordId = newRecord.Id;
                                        notification.recordOwnerId = (String)newRecord.get('OwnerId');
                                        notification.message = 'We wanted to inform you that the lead you were handling,has been transferred to another user as part of internal reassignments.\n' +
                                        'Lead ID: '+ (String)newRecord.get('EYI_Lead_Enquiry_Number__c') +'\n' +
                                        'Client Name: '+ (String)newRecord.get('Name')+'\n' +
                                        'Project Name: {!EYI_Lead_Enquiry__c.EYI_Project_Enquired__c}\n' ;
                                        notification.notificationName = 'Lead Owner Change Alert!';
                                        notification.changedFields = changedFields;
                                        notifications.add(notification);
                                    }else if((metaData.Notification_Trigger_logic__c == 'Lost' && (String)newRecord.get(metaData.Notification_Trigger_Fields__c) == 'Lost')
                                    || (metaData.Notification_Trigger_logic__c == 'Visit Confirmed' && (String)newRecord.get(metaData.Notification_Trigger_Fields__c) == 'Visit Confirmed')
                                    || (metaData.Notification_Trigger_logic__c == 'No Show' && (String)newRecord.get(metaData.Notification_Trigger_Fields__c) == 'No Show')){
                                        EYI_Notification notificationTL = CreateNotifications(metaData,newRecord,changedFields);
                                        if((metaData.Notification_Trigger_logic__c == 'Visit Confirmed' 
                                            || metaData.Notification_Trigger_logic__c == 'No Show') && metaData.Channel_Type__c == 'Email' && groupAssignedDataList.size()>0){
                                            notificationTL.recipient = groupAssignedDataList[0].EYI_Team_Lead_TL__r.Email;
                                        }else if((metaData.Notification_Trigger_logic__c == 'Lost' || metaData.Channel_Type__c =='System Notification') && groupAssignedDataList.size()>0){
                                            notificationTL.recipient = groupAssignedDataList[0].EYI_Team_Lead_TL__c;
                                        }
                                        if(metaData.Channel_Type__c !='WhatsApp' || metaData.Channel_Type__c != 'SMS'){
                                            notifications.add(notificationTL);
                                        }
                                    }else if(metaData.Notification_Trigger_logic__c == (String)newRecord.get(metaData.Notification_Trigger_Fields__c)){
                                        EYI_Notification notification2= CreateNotifications(metaData,newRecord,changedFields);
                                        notifications.add(notification2);
                                    }
                                }else{
                                    notification = CreateNotifications(metaData,newRecord,changedFields);
                                }
                                if(metaData.Operation_Type__c == 'AFTER_UPDATE' 
                                    && ((String)newRecord.get(metaData.Notification_Trigger_Fields__c) == (String)metaData.Notification_Trigger_logic__c 
                                    || (String)metaData.Notification_Trigger_logic__c =='NO VAL') ){
                                    notifications.add(notification);
                                }
                            }
                        }
                    }
                }
            }else if (String.valueOf(operationType) == 'AFTER_INSERT') {
                for(String fieldName : notificationsMap.keySet()){
                    List<EYI_Notification_Template__mdt> notificationMetadata =  notificationsMap.get(fieldName);
                    System.debug('notificationMetadata ==>101'+notificationMetadata);
                    for(EYI_Notification_Template__mdt metaData : notificationMetadata){
                        if(metadata.sObject__c == 'Task'){
                            if( metaData.Channel_Type__c == 'SMS' || metaData.Channel_Type__c == 'WhatsApp'){
                                notification = new EYI_Notification();
                                notification.channelType = metaData.Channel_Type__c;
                                notification.recipient = 'EYI_Phone__c'; 
                                notification.emailTemplateName = metaData.Email_Template__c;
                                System.debug('New Record ===>'+newRecord);
                                notification.recordId =  (String)newRecord.get('WhatId');
                                notification.recordOwnerId = (String)newRecord.get('OwnerId');
                                notification.notificationName = metaData.MasterLabel;
                            }else{

                            }
                            notifications.add(notification);

                        }else{                      
                            if(fieldMap.containsKey(metaData.recipient_Field__c) && (String)newRecord.get(metaData.Notification_Trigger_Fields__c) == (String)metaData.Notification_Trigger_logic__c){
                                notification = CreateNotifications(metaData,newRecord,changedFields);
                                if((notification.recipient != NULL || notification.recipient !='') && metaData.Operation_Type__c == 'AFTER_INSERT'){
                                    notifications.add(notification);
                                }                            
                            }
                        }
                    }
                }
            }
        }
        Map<Id,List<EYI_MergeFieldsWrapper>> mergefieldsDataMap = getMergeFields(objectName,newRecords);
        if(mergefieldsDataMap.size()>0){
            for(EYI_Notification notificationObj : notifications){
                if(notificationobj != null){
                    List<EYI_MergeFieldsWrapper> mergefieldsDataList = new List<EYI_MergeFieldsWrapper>();
                    if(mergefieldsDataMap.containsKey(notificationObj.recordId)){
                        mergefieldsDataList = mergefieldsDataMap.get(notificationObj.recordId);
                        if(mergefieldsDataList.size()>0){
                            notificationObj.mergeFieldsList = mergefieldsDataList;
                        }
                    }
                }
            }
        }
        return notifications;
    }

    public static EYI_Notification CreateNotifications(EYI_Notification_Template__mdt metaData,SObject newRecord,  Map<String, Object> changedFields) {
        EYI_Notification notification = new EYI_Notification();
        if(metaData.sObject__c == 'EYI_Lead_Enquiry__c'){
            String communicationPreference = (String)newRecord.get('EYI_Client_Communication_Preference__c');
            String recipienttype = (String) metaData.Channel_Type__c;
            if (communicationPreference != null && recipienttype != null) {
                if (!(communicationPreference.contains(recipienttype) || communicationPreference.contains('All'))) {
                    return notification;
                }
            }
        }
        if(newRecord.get('OwnerId') == System.Label.EYI_CTI_User){
            return notification;
        }
        notification.channelType = metaData.Channel_Type__c; 
        System.debug('metaData.Channel_Type__c===>'+metaData.Channel_Type__c);
        if(metaData.Channel_Type__c == 'WhatsApp' || metaData.Channel_Type__c == 'SMS'){
            notification.recipient = metaData.Recipient_Field__c; 
        }else
        if(metaData.recipient_Field__c =='Owner.Email'){
            notification.recipient = 'Owner.Email';
        }
        else{
            notification.recipient = (String)newRecord.get(metaData.Recipient_Field__c); 
        }
        notification.emailTemplateName = metaData.Email_Template__c;
        notification.recordId = newRecord.Id;
        notification.recordOwnerId = (String)newRecord.get('OwnerId');
        if(metaData.sObject__c == 'EYI_Lead_Enquiry__c'){
            notification.projectId = (String)newRecord.get('EYI_Project_Enquired__c');
        }
        notification.message = metaData.Notification_Message__c;
        notification.notificationName = metaData.MasterLabel;
        if(metaData.Attachments__c =='Yes'){
            notification.attachmentLink = metaData.Attachments__c;
        }
        notification.changedFields = changedFields;
        return notification;
    }
        
    /**
     * @description: Get the merge fields from the email templates
     * @param: newRecords: List of new records
     * @return: Map<Id, List<EYI_MergeFieldsWrapper>>
     */
    public static Map<Id, List<EYI_MergeFieldsWrapper>> getMergeFields(String objectName,Map<Id, SObject> newRecords) {
        Map<String, String> fieldstoQuery = new Map<String, String>();
        List<String> fieldList = new List<String>();
        List<String> finalFieldList = new List<String>();
        EYI_MergeFieldsWrapper wrapper;
        List<String> colanFieldList = new List<String>();
        List<SObject> sObjlist = new List<SObject>();
        Map<Id, List<EYI_MergeFieldsWrapper>> mergefieldsDataMap = new Map<Id, List<EYI_MergeFieldsWrapper>>();
        List<EYI_MergeFieldsWrapper> mergeFieldsList;
        String strVal = '';
        String fields = '';
        try {
            for (EYI_Notification_Template__mdt metaData : [SELECT Id, DeveloperName, MasterLabel, Active__c, Attachments__c, Channel_Type__c,
                    Notification_Trigger_Fields__c, Notification_Message__c, Recipient_Field__c, Email_Template__c, Email_Template_Merge_Fields__c,
                    Operation_Type__c, Notification_Trigger_Logic__c
                    FROM EYI_Notification_Template__mdt 
                    WHERE Active__c = true  
                    AND sObject__c = :objectName]) {
                if (metaData.Email_Template_Merge_Fields__c != NULL) {
                    String field = metaData.Email_Template_Merge_Fields__c;
                    if (field.contains(',')) {
                        fieldList = field.split(',');
                        finalFieldList.addAll(fieldList);
                    } else {
                        finalFieldList.add(field);
                    }
                }
            }
    
            for (String str : finalFieldList) {
                colanFieldList = str.split(':');
                String trimmedField = colanFieldList[1].trim();
                String trimmedMergeField = colanFieldList[0].trim();
            
                if (colanFieldList[1] != '' && (!fieldstoQuery.containsKey(trimmedField))) {
                    fields += trimmedField + ',';
                }
                System.debug('trimmedField===>'+trimmedField);
                System.debug('trimmedMergeField===>'+trimmedMergeField);

                fieldstoQuery.put(trimmedField, trimmedMergeField);
            }
          
            Set<Id> idList = newRecords.keySet();
            String queryString = 'SELECT ' + fields + ' Id FROM ' + objectName + ' WHERE Id IN :idList';
            System.debug('Query String: ' + queryString);
            try {
                sObjlist = Database.query(queryString);
            } catch (Exception dm) {
                // Handle exception
            }
    
            if (!sObjlist.isEmpty()) {
                for (SObject obj : sObjlist) {
                    String recordId = (String) obj.get('Id');
                    mergeFieldsList = new List<EYI_MergeFieldsWrapper>(); // Clear the list for each record
    
                    for (String fieldName : fieldstoQuery.keySet()) {
                        if (fieldName.contains('__r') || fieldName.contains('.')) {
                            List<String> splitList = fieldName.split('\\.');
                            if (obj.getSObject(splitList[0]) != null && obj.getSObject(splitList[0]).get(splitList[1]) != null) {
                                if (obj.getSObject(splitList[0]).get(splitList[1]) instanceof DateTime) {
                                    DateTime fieldValue = (DateTime) obj.getSObject(splitList[0]).get(splitList[1]);
                                    strVal = fieldValue.format('dd MMM yyyy hh:mm a');
                                } else {
                                    strVal = (String) obj.getSObject(splitList[0]).get(splitList[1]);
                                }
                                wrapper = new EYI_MergeFieldsWrapper(recordId, fieldName, strVal, fieldstoQuery.get(fieldName));
                                mergeFieldsList.add(wrapper);
                            }else{
                                wrapper = new EYI_MergeFieldsWrapper(recordId, fieldName, '', fieldstoQuery.get(fieldName));
                                mergeFieldsList.add(wrapper);
                            }
                        } else {
                            if (obj.get(fieldName) instanceof DateTime) {
                                DateTime fieldValue = (DateTime) obj.get(fieldName);
                                strVal = fieldValue.format('dd MMM yyyy hh:mm a');
                            } else {
                                strVal = (String) obj.get(fieldName);
                            }
                            wrapper = new EYI_MergeFieldsWrapper(recordId, fieldName, strVal, fieldstoQuery.get(fieldName));
                            mergeFieldsList.add(wrapper);
                        }
                    }
                    mergefieldsDataMap.put(recordId, mergeFieldsList);
                }
            }
        } catch (Exception e) {
            // Handle exception
        }
        return mergefieldsDataMap;
    }


 // public static void sendNotifications(List<EYI_Notification> notifications) {
    //     List<EYI_Notification> SMSNotifications = new List<EYI_Notification>();
    //     List<EYI_Notification> EmailNotifications = new List<EYI_Notification>();
    //     List<EYI_Notification> WhatsappNotifications = new List<EYI_Notification>();
    //     List<EYI_Notification> SysNotifications = new List<EYI_Notification>();

    //     Map<String,List<EYI_Notification>> SMSNotificationsMAp = new Map<String,List<EYI_Notification>>();
    //     Map<String,List<EYI_Notification>> EmailNotifications = new Map<String,List<EYI_Notification>>();
    //     List<EYI_Notification> WhatsappNotifications = new List<EYI_Notification>();
    //     List<EYI_Notification> SysNotifications = new List<EYI_Notification>();

    //     for (EYI_Notification notification : notifications) {
    //         if (notification.attachmentLink != null) {
    //             notification.message += '\nAttachment: ' + notification.attachmentLink;
    //         }
    //         switch on notification.channelType {
    //             when 'SMS'{
    //                 SMSNotifications.add(notification);
    //             }
    //             when 'Email'{
    //                 EmailNotifications.add(notification);
    //             }   
    //             when 'WhatsApp'{
    //                 WhatsappNotifications.add(notification);
    //             }
    //             when 'System Notification'{
    //                 SysNotifications.add(notification);
    //             }
    //         }
    //     }
    //     if(SysNotifications.size()>0){
    //         EYI_SystemNotificationService.send(SysNotifications);
    //         //System.debug('SysNotifications===>'+SysNotifications);
    //     }
    //      if(EmailNotifications.size()>0){
    //          //System.debug('EmailNotifications===>'+EmailNotifications);
    //          EYI_EmailService.send(EmailNotifications);
    //      }
    //     if(SMSNotifications.size()>0){
    //         System.debug('SMSNotifications===>'+SMSNotifications);
    //         EYI_SMSService.send(SMSNotifications);
    //     }
    //     if(WhatsappNotifications.size()>0){
    //         System.debug('WhatsappNotifications===>'+WhatsappNotifications);
    //         EYI_WhatsAppService.send(WhatsappNotifications);
    //     }
 // }
    public static void sendNotifications(List<EYI_Notification> notifications) {
        Map<String, EYI_Notification> EmailNotificationsMap = new Map<String, EYI_Notification>();
        Map<String, EYI_Notification> SysNotificationsMap = new Map<String, EYI_Notification>();
        Map<String, EYI_Notification> SMSNotificationsMap = new Map<String, EYI_Notification>();
        Map<String, EYI_Notification> WhatsappNotificationsMap = new Map<String, EYI_Notification>();
    
        for (EYI_Notification notification : notifications) {
            System.debug('350 notification===>' + notification);

            // if (notification.attachmentLink != null) {
            //     notification.message += '\nAttachment: ' + notification.attachmentLink;
            // }
            if(notification != null){
                String key = notification.channelType + notification.recipient;
                switch on notification.channelType {
                    when 'SMS' {
                        SMSNotificationsMap.put(key, notification);
                    }
                    when 'Email' {
                        EmailNotificationsMap.put(key, notification);
                    }
                    when 'WhatsApp' {
                        WhatsappNotificationsMap.put(key, notification);
                    }
                    when 'System Notification' {
                        SysNotificationsMap.put(key, notification);
                    }
                }
            }
        }
        
    
        if (!SysNotificationsMap.isEmpty()) {
            //EYI_SystemNotificationService.send(new List<EYI_Notification>(SysNotificationsMap.values()));
            System.debug('SysNotifications===>' + SysNotificationsMap.values());
        }
        if (!EmailNotificationsMap.isEmpty()) {
            //EYI_EmailService.send(new List<EYI_Notification>(EmailNotificationsMap.values()));
            System.debug('EmailNotifications===>' + EmailNotificationsMap.values());
        }
        if (!SMSNotificationsMap.isEmpty()) {
            //EYI_SMSService.send(new List<EYI_Notification>(SMSNotificationsMap.values()));
            System.debug('SMSNotifications===>' + SMSNotificationsMap.values());
        }
        if (!WhatsappNotificationsMap.isEmpty()) {
            //EYI_WhatsAppService.send(new List<EYI_Notification>(WhatsappNotificationsMap.values()));
            System.debug('WhatsappNotifications===>' + WhatsappNotificationsMap.values());
        }
    }
}