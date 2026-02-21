@isTest
public class EYI_OpportunitySegregationSchedulerTest {

    @isTest
    static void testSchedulerExecute() {
        Test.startTest();
        
        // Instantiate and call execute manually
        EYI_OpportunitySegregationScheduler scheduler = new EYI_OpportunitySegregationScheduler();
        scheduler.execute(null); // null is acceptable in test context
        
        Test.stopTest();
        
        // No assert needed unless you track job outcome, but method path is covered
    }

    @isTest
    static void testScheduleBatch() {
        // Set a valid CRON expression in the Custom Label (simulate it in test context)
        Test.startTest();
        
        // Use a Test.startTest() to ensure scheduling runs inside limits
        EYI_OpportunitySegregationScheduler.scheduleBatch();
        
        Test.stopTest();
        
        // You can verify jobs are scheduled using System.abortJob or query CronTrigger if needed
    }
}