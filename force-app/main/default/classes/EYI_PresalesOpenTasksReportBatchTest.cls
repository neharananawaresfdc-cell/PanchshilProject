@isTest
public with sharing class EYI_PresalesOpenTasksReportBatchTest {
    @isTest
    static void testScheduleBatch() {
        // Create required Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        // Create required User
        User u = new User(
            Username = 'testuser4_' + System.currentTimeMillis() + '@example.com.test',
            Alias = 'tuser4',
            Email = 'testuser4@example4.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert u;

        // Create Assignment Groups if needed by your factory
        // Example (update object/fields as per your org):
        EYI_Assignment_Group__c ag1 = new EYI_Assignment_Group__c(Name=System.Label.Presales_Assignment_Group_Label);
        EYI_Assignment_Group__c ag2 = new EYI_Assignment_Group__c(Name=System.Label.EYI_ClosingManagerGroupName);
        EYI_Assignment_Group__c ag3 = new EYI_Assignment_Group__c(Name=System.Label.EYI_PresalesL3EscalationGroupLabel);
        insert new List<EYI_Assignment_Group__c>{ag1, ag2, ag3};

        EYI_PresalesOpenTaskReportBatchScheduler.bypassTestGuard = true; // Bypass guard
        Test.startTest();
        System.debug('testScheduleBatch4Start');
        Database.executeBatch(new EYI_PresalesOpenTasksReportBatch(),1);
        Test.stopTest();
    }
  @isTest(seeAllData=true)
    static void testBatchExecuteWithRealReport() {
        // Find a real report in your org (update the DeveloperName below to one that exists)
        String reportDevName = System.Label.EYI_Presales_Incomplete_Task_Report;

        // Query for an existing Report (must exist in your org)
        Report rep = [SELECT Id FROM Report WHERE DeveloperName = :reportDevName LIMIT 1];

        // Now run the batch process
        Test.startTest();
        Database.executeBatch(new EYI_PresalesOpenTasksReportBatch(), 1);
        Test.stopTest();

        // Optionally, you can assert something if your handler logs/test-flags anything
    }
     @isTest
    static void testBatchExecuteWithRealReport1() {
        EYI_PresalesOpenTaskReportBatchScheduler.bypassTestGuard = true; // Bypass guard
        // Now run the batch process
        Test.startTest();
        EYI_PresalesOpenTaskReportBatchScheduler scheduler = new EYI_PresalesOpenTaskReportBatchScheduler();
        scheduler.execute(null);
        Test.stopTest();

        // Optionally, you can assert something if your handler logs/test-flags anything
    }
      @isTest
    static void testBatchExecuteWithRealReport2() {
        EYI_PresalesOpenTaskReportBatchScheduler.bypassTestGuard = true; // Bypass guard
        // Now run the batch process
        Test.startTest();
        //EYI_PresalesOpenTasksReportBatchScheduler scheduler = new EYI_PresalesOpenTasksReportBatchScheduler();
        EYI_PresalesOpenTaskReportBatchScheduler.scheduleBatch();
        Test.stopTest();

        // Optionally, you can assert something if your handler logs/test-flags anything
    }
}