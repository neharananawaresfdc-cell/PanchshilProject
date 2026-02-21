@isTest
public class EYI_VisitConfirmationSMSAlertSchler_Test {
    @testSetup
    static void setupTestData() {
      
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 250; i++) {
            accs.add(new Account(Name = 'Test Account ' + i));
        }
        insert accs;
    }

    @isTest
    static void testScheduleBatch() {
        EYI_VisitConfirmationSMSAlertScheduler.bypassTestGuard = true;
        Test.startTest();
        EYI_VisitConfirmationSMSAlertScheduler.scheduleBatch();
        Test.stopTest();

   
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'VisitConfirmationSMSAlertJob_%'
        ];
        System.assert(jobs.size() > 0, 'Scheduled job should exist');
    }

    @isTest
    static void testExecute() {
        EYI_VisitConfirmationSMSAlertScheduler.bypassTestGuard = true;
        Test.startTest();
        EYI_VisitConfirmationSMSAlertScheduler scheduler = new EYI_VisitConfirmationSMSAlertScheduler();
        scheduler.execute(null);
        Test.stopTest();
     
    }
    @isTest
    static void testExecute2() {
        // Cover the execute method (Test.isRunningTest() will be true, so batch won't run)
        Test.startTest();
        EYI_VisitConfirmationWAppAlertScheduler scheduler = new EYI_VisitConfirmationWAppAlertScheduler();
        EYI_VisitConfirmationWAppAlertScheduler.bypassTestGuard = true;
        scheduler.execute(null);
        Test.stopTest();
        // No assertions needed, just code coverage
    }
  
     @isTest
    static void testScheduleBatch1() {
        // This will cover the scheduleBatch method
        Test.startTest();
            EYI_VisitConfirmationWAppAlertScheduler.scheduleBatch();
        Test.stopTest();
        // Optionally, assert that a job was scheduled
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'VisitConfirmationw_%'];
        System.assert(jobs.size() > 0, 'Scheduled job should exist');
    }
    @isTest
    static void testScheduleBatch2() {
        Test.startTest();
        EYI_VisitConfirmationWAppAlertScheduler.scheduleBatch();
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'VisitConfirmationWhatsAppJob_%'
        ];
        System.assert(jobs.size() > 0, 'Scheduled job should exist');
    }
}