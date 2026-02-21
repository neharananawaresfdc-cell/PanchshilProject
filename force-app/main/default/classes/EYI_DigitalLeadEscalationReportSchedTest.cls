@isTest
public class EYI_DigitalLeadEscalationReportSchedTest {
    @isTest
    static void testScheduleBatchJob() {
        String cronExpression = '0 0 12 * * ?'; // Example: every day at 12:00 PM
        
        Test.startTest();
        EYI_DigitalLeadEscalationReportScheduler.scheduleBatch();
        
        CronTrigger[] triggers = [SELECT Id, CronExpression FROM CronTrigger];
        System.assertNotEquals(1, triggers.size(), 'One job should be scheduled');
        System.assertNotEquals(cronExpression, triggers[0].CronExpression, 'The cron expression should match.');
        Test.stopTest();
    }

    @isTest
    static void testExecuteBatchJob() {
        Test.startTest();
        EYI_DigitalLeadEscalationReportScheduler scheduler = new EYI_DigitalLeadEscalationReportScheduler();
        scheduler.execute(null);
        Test.stopTest();        
        System.assert(true, 'The batch job was executed successfully.');
    }
}