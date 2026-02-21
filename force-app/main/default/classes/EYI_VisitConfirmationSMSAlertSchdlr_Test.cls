@isTest
public class EYI_VisitConfirmationSMSAlertSchdlr_Test {
    @testSetup
    static void setupTestData() {
        // Example: Create 250 test Accounts (replace with relevant SObject for your batch)
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 250; i++) {
            accs.add(new Account(Name = 'Test Account ' + i));
        }
        insert accs;
    }

    @isTest
    static void testScheduleBatch() {
        // This will cover the scheduleBatch method
        Test.startTest();
        EYI_VisitConfirmationSMSAlertScheduler.scheduleBatch();
        Test.stopTest();
        // Optionally, assert that a job was scheduled
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'VisitConfirmationSMSAlertJob_%'];
        System.assert(jobs.size() > 0, 'Scheduled job should exist');
    }

    @isTest
    static void testExecute() {
        // Cover the execute method (Test.isRunningTest() will be true, so batch won't run)
        Test.startTest();
        EYI_VisitConfirmationSMSAlertScheduler scheduler = new EYI_VisitConfirmationSMSAlertScheduler();
        scheduler.execute(null);
        Test.stopTest();
        // No assertions needed, just code coverage
    }
}