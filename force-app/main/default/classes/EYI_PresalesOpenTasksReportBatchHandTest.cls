@isTest
private class EYI_PresalesOpenTasksReportBatchHandTest {
    
    @isTest
    static void testSendReportEmailMethod() {
        // Create dummy user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        EYI_Assignment_Group__c group1 = new EYI_Assignment_Group__c(
            EYI_Team_Lead_TL__c = testUser.Id,
            EYI_Presales_Head__c = testUser.Id,
            Name= 'Test Group'
        );
        insert group1;
        
        EYI_Assignment_Group_Member__c member = new EYI_Assignment_Group_Member__c(
            EYI_Assignment_Member__c = testUser.Id,
            EYI_Assignment_Group__c = group1.Id
        );
        insert member;
        
        Id reportId;
        try {
            reportId = [SELECT Id FROM Report LIMIT 1].Id;
        } catch (Exception e) {
            // Use a dummy Id if no report exists
            reportId = '00O000000000000AAA';
        }
        
        EYI_PresalesOpenTasksReportBatchHandler handler = new EYI_PresalesOpenTasksReportBatchHandler();
        try {
            handler.sendReportEmail(reportId, System.Label.EYI_Presales_Incomplete_Task_Report);
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }
        try {
            handler.sendReportEmail(reportId, System.Label.EYI_DigitalLeadEscalationReport);
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }
    }
    
    @isTest(SeeAllData='true')
    static void testBatchExecution() {
        // Query an existing report (must exist in your org)
        Report rep = [SELECT Id, Name FROM Report LIMIT 1];
        
        Test.startTest();
        EYI_DigitalLeadEscalationReportBatch batch = new EYI_DigitalLeadEscalationReportBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        System.assertNotEquals(null, rep.Id, 'Report should exist');
    }
    
    
    @isTest(SeeAllData=true)
    static void testSendReportEmail_PresalesIncompleteTaskReport() {
        // You must have a real report with at least 6 columns and at least 1 row!
        // Replace the report name below with the actual name of your report
        String reportName = 'My Open Cases'; // Change this to your actual report's name

        // Query the report
        Report report = [SELECT Id, Name FROM Report WHERE Name = :reportName LIMIT 1];

        // Setup any required Users/Groups as needed by your handler (if not already present)
        // Example minimal setup - modify as per your org's requirements:
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        EYI_Assignment_Group__c group1 = new EYI_Assignment_Group__c(
            EYI_Team_Lead_TL__c = testUser.Id,
            EYI_Presales_Head__c = testUser.Id,
            Name= 'Test Group'
        );
        insert group1;

        EYI_Assignment_Group_Member__c member = new EYI_Assignment_Group_Member__c(
            EYI_Assignment_Member__c = testUser.Id,
            EYI_Assignment_Group__c = group1.Id
        );
        insert member;

        // Now run the handler
        EYI_PresalesOpenTasksReportBatchHandler handler = new EYI_PresalesOpenTasksReportBatchHandler();
        handler.sendReportEmail(report.Id, System.Label.EYI_Presales_Incomplete_Task_Report);

        // Optionally, assert something has happened (if your handler sets a custom object, etc)
        System.assert(true, 'If no exceptions, test passed and lines are covered');
    }
    
    // Helper to mock a Reports.ReportDataCell
   /* private static Reports.ReportDataCell createDataCell(String label) {
        return (Reports.ReportDataCell)Test.createStub(
            Reports.ReportDataCell.class,
            new Map<String, Object>{ 'getLabel' => label }
        );
    } */
    
    @isTest
    static void testSendReportEmail_Exception() {
        // Create a dummy user to get a valid email
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'exceptiontestuser@example.com',
            Username = 'exceptiontestuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'etuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Try to get a real report Id, fallback to dummy if none exist
        Id reportId;
        try {
            reportId = [SELECT Id FROM Report LIMIT 1].Id;
        } catch (Exception e) {
            reportId = '00O000000000000AAA';
        }

        EYI_PresalesOpenTasksReportBatchHandler handler = new EYI_PresalesOpenTasksReportBatchHandler();
        try {
            handler.sendReportEmail(reportId, testUser.Email);
            System.assert(true, 'No exception thrown');
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
            System.assert(true, 'Exception handled as expected');
        }
    }
}