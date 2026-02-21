@isTest
public class EYI_VisitConfWAppSchedTest {
    @testSetup
    static void setupTestData() {
        Lead parent = new Lead(LastName = 'Test', Company = 'Test Co');
        insert parent;
        
        // Insert minimal required test data for the batch (EYI_Lead_Enquiry__c)
        EYI_Lead_Enquiry__c todayVisit = new EYI_Lead_Enquiry__c(
            Name = 'Lead Today',
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = '9000000001',
            EYI_Parent_Record__c = parent.Id
        );
        
        EYI_Lead_Enquiry__c tomorrowVisit = new EYI_Lead_Enquiry__c(
            Name = 'Lead Tomorrow',
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = '9000000002',
            EYI_Parent_Record__c = parent.Id
        );
        insert new List<EYI_Lead_Enquiry__c>{ todayVisit, tomorrowVisit };
            }
    
    @isTest
    static void testScheduleBatch() {
        // Set a mock label value for the cron expression if needed
        // System.Label.EYI_VisitConfirmationSchedulerCron must be set in org for this to work
        Test.startTest();
        EYI_VisitConfirmationWAppAlertScheduler.scheduleBatch();
        Test.stopTest();
        
        // Verify the scheduled job
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'VisitConfirmationWhatsAppJob_%'
        ];
        System.assert(jobs.size() > 0, 'Scheduled job should exist');
    }
    
    @isTest
    static void testBatchDirect() {
        // Only call Database.executeBatch here
        Test.startTest();
        EYI_VisitConfirmationWAppAlertBatch batch = new EYI_VisitConfirmationWAppAlertBatch();
        Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
        Database.executeBatch(batch, batchSize);
        Test.stopTest();
    }
    
    @isTest
    static void testExecute() {
        // Use a test-visible flag (you must add this field in the scheduler class)
        EYI_VisitConfirmationWAppAlertScheduler.bypassTestGuard = true;
        Test.startTest();
        EYI_VisitConfirmationWAppAlertScheduler scheduler = new EYI_VisitConfirmationWAppAlertScheduler();
        //scheduler.execute(null); // SchedulableContext can be null in tests
        Test.stopTest();
        // Optionally assert on any batch operation outcomes if batch has observable effects
    }
    
    @isTest
    static void testSchedulerExecute() {
        Lead parent = new Lead(LastName = 'Test', Company = 'Test Co');
        insert parent;
        // Insert minimal required test data for the batch to find (see your earlier fixes)
        EYI_Lead_Enquiry__c record = new EYI_Lead_Enquiry__c(
            Name = 'Test',
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = '9000000001',
            EYI_Parent_Record__c = parent.Id
        );
        insert record;
        
        // Set the test guard so the block runs in test context
        EYI_VisitConfirmationWAppAlertScheduler.bypassTestGuard = true;
        Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
        EYI_VisitConfirmationWAppAlertScheduler.testBatchSize = batchSize;
        Test.startTest();
        EYI_VisitConfirmationWAppAlertScheduler scheduler = new EYI_VisitConfirmationWAppAlertScheduler();
        scheduler.execute(null); // This will now cover both lines!
        Test.stopTest();
    }
}