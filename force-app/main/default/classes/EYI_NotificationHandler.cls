/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : EY Notification Framework
 * @last modified on  : 11-04-2024
 * @last modified by  : Digambar Ganage 
**/
public with sharing class EYI_NotificationHandler {
    public static void handleTrigger(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords, TriggerOperation operationType) {
        List<EYI_Notification> notifications = EYI_NotificationService.getNotifications(newRecords, oldRecords, operationType);
        System.debug('notifications>>>>>>>>>>>>>>> '+notifications);
        // EYI_NotificationService.sendNotifications(notifications);fications);
        // // Example: Sending a notification
        // EYI_NotificationService.sendNotification(
        //     new EYI_Notification(
        //         'Email',)
        // // Example: Adding an attachment link
        // Blob attachment = Blob.valueOf('Sample attachment content');
        // String attachmentLink = EYI_AttachmentService.uploadAndGetLink(attachment, 'SampleFile.txt');
        // for (EYI_Notification notification : notifications) {
        //     notification.attachmentLink = attachmentLink;
        // }

        if(notifications.size() > 0){
            EYI_NotificationService.sendNotifications(notifications);
        }
    }
}