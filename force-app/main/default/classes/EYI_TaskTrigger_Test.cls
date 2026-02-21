@isTest
public class EYI_TaskTrigger_Test {
    @testSetup
    static void setup() {
        // Insert org-wide custom setting with notifications enabled
        EYI_Notification_Settings__c setting = new EYI_Notification_Settings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            EYI_Is_Notifications_Enabled__c = true
        );
        insert setting;
    }

    @isTest
    static void testBeforeInsert() {
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            EYI_Next_Action_Date_Time__c = System.now().addDays(1),
            EYI_Next_Action_Status__c = 'Follow Up' // Added missing field
        );
        insert t;
        // Assert that handleEscalation was called (if you have static flags or logs)
        System.assertNotEquals(null, t.Id);
    }

    @isTest
    static void testBeforeUpdate() {
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            TaskSubtype = 'Call', // Add this line
            EYI_Next_Action_Status__c = 'Follow Up',
            EYI_Next_Action_Date_Time__c = System.now().addDays(1)
        );
        insert t;
        t.Status = 'Completed';
        // Remove the Next Action Status when task is completed
        t.EYI_Next_Action_Status__c = null;
        update t;
        System.assertEquals('Completed', [SELECT Status FROM Task WHERE Id = :t.Id].Status);
    }

    @isTest
    static void testAfterUpdate_NotificationsDisabled() {
        // Disable notifications
        EYI_Notification_Settings__c setting = EYI_Notification_Settings__c.getOrgDefaults();
        setting.EYI_Is_Notifications_Enabled__c = false;
        upsert setting;
        
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            TaskSubtype = 'Call', // Add this line
            EYI_Next_Action_Date_Time__c = System.now().addDays(1),
            EYI_Next_Action_Status__c = 'Follow Up'
        );
        insert t;
        t.Status = 'Completed';
        // Remove the Next Action Status when task is completed
        t.EYI_Next_Action_Status__c = null;
        update t;
        // Notification handler should be called (if you have static flags or logs)
        System.assertEquals('Completed', [SELECT Status FROM Task WHERE Id = :t.Id].Status);
    }

    @isTest
    static void testTaskWithValidNextActionDateTime() {
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            EYI_Next_Action_Date_Time__c = System.now().addDays(1),
            EYI_Next_Action_Status__c = 'Follow Up' // Added missing field
        );
        insert t;
        System.assertNotEquals(null, t.Id);
        System.assertEquals('Not Started', [SELECT Status FROM Task WHERE Id = :t.Id].Status);
    }

    @isTest
    static void testTaskWithoutNextActionDateTime_ShouldFail() {
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal'
            // Missing EYI_Next_Action_Date_Time__c
        );
        try {
            insert t;
            System.assert(false, 'Expected DmlException was not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Please provide the next action date and time'));
        }
    }

    @isTest
    static void testTaskStatusUpdate_WithValidData() {
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            TaskSubtype = 'Call', // Add this line if you want to test completion
            EYI_Next_Action_Date_Time__c = System.now().addDays(1),
            EYI_Next_Action_Status__c = 'Follow Up'
        );
        insert t;
        
        t.Status = 'In Progress';
        t.EYI_Next_Action_Date_Time__c = System.now().addDays(2);
        t.EYI_Next_Action_Status__c = 'Follow Up';
        update t;
        
        System.assertEquals('In Progress', [SELECT Status FROM Task WHERE Id = :t.Id].Status);
    }

    @isTest
    static void testTaskCompletedStatus() {
        Task t = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            TaskSubtype = 'Call', // Add this line
            EYI_Next_Action_Date_Time__c = System.now().addDays(1),
            EYI_Next_Action_Status__c = 'Follow Up'
        );
        insert t;
        
        t.Status = 'Completed';
        // Remove the Next Action Status when task is completed
        t.EYI_Next_Action_Status__c = null;
        update t;
        
        System.assertEquals('Completed', [SELECT Status FROM Task WHERE Id = :t.Id].Status);
    }

    @isTest
    static void testBulkTaskInsert() {
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < 5; i++) {
            tasks.add(new Task(
                Subject = 'Test Task ' + i,
                Status = 'Not Started',
                Priority = 'Normal',
                EYI_Next_Action_Date_Time__c = System.now().addDays(i + 1),
                EYI_Next_Action_Status__c = 'Follow Up' // Added missing field
            ));
        }
        insert tasks;
        
        System.assertEquals(5, [SELECT COUNT() FROM Task WHERE Subject LIKE 'Test Task%']);
    }
}