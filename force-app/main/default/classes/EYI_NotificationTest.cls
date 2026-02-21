@isTest
public class EYI_NotificationTest {
    @isTest
    static void testSimpleWrapperUsage() {
        EYI_Notification notif = new EYI_Notification();
        notif.channelType = 'Email';
        notif.recipient = 'user@example.com';
        notif.message = 'Hello';
        notif.attachmentLink = 'https://example.com/file';
        notif.recordOwnerId = UserInfo.getUserId();
        notif.emailTemplateName = 'SampleTemplate';
        notif.notificationName = 'Test Notification';

        System.assertEquals('Email', notif.channelType);
        System.assertEquals('user@example.com', notif.recipient);
        System.assertEquals('Hello', notif.message);
    }
	
}