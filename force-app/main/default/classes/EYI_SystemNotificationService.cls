/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : EY Notification Framework
 * @last modified on  : 11-06-2024
 * @last modified by  : Digambar Ganage
**/
public with sharing class EYI_SystemNotificationService {
    
    public static void notifyUsers(List<EYI_Notification> notificationList) {
        System.debug('notificationList[i].message====>'+notificationList);
        try {
            // Get the Id for our custom notification type
            CustomNotificationType notificationType = [ SELECT Id, DeveloperName 
                                                        FROM CustomNotificationType 
                                                        WHERE DeveloperName = 'EYI_Custom_Notification'];
            for (Integer i = 0; i < notificationList.size(); i++) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle(notificationList[i].notificationName);
                String MessageBody = (String)notificationList[i].message;
                for(EYI_MergeFieldsWrapper field : notificationList[i].mergeFieldsList){
                    /*if(messageBody.contains(field.replaceField) && field.fieldValue!=null){
                        messageBody = messageBody.replace(field.replaceField, field.fieldValue);
                    }*/
                     if(messageBody.contains(field.replaceField)){
                           messageBody = (field.fieldValue!=null) ? messageBody.replace(field.replaceField, field.fieldValue) 
                                        : messageBody.replace(field.replaceField,'');
                    }
                }
                System.debug('messageBody====>'+messageBody);
                notification.setBody(messageBody);
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(notificationList[i].recordId);
                // notification.setBody('Please check the case details');
                System.debug('notificationList[i].message====>'+notificationList[i].message);
                // notification.RecipientId = UserInfo.getUserId();
                Set<String> recipientIds = new Set<String>();
                recipientIds.add((Id)notificationList[i].recipient);
                if(recipientIds.size() > 0) {
                    notification.send(recipientIds);
                }
            }            
        }catch (Exception e) {
        }
    }
    
    @InvocableMethod(label='Send System Notification' description='Send System Notification')
    public static void send(List<EYI_Notification> notifications){
        // System.debug('notifications ' + notifications[0]);
        // Set<String> recipientsIds = new Set<String>();
        // recipientsIds.add(UserInfo.GetUserId());
        if(notifications.size() > 0) {
            notifyUsers(notifications);
        }
    }
}