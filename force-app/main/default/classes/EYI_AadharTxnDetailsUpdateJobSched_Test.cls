@isTest
public class EYI_AadharTxnDetailsUpdateJobSched_Test {
 @isTest
    static void testScheduleJob() {
        // Use Test.startTest() and Test.stopTest() to ensure proper test context for asynchronous jobs
        Test.startTest();

        // Call the scheduleJob method to schedule the job...
        EYI_AadharTxnDetailsUpdateJobSched.scheduleJob();

     
        Test.stopTest();
    }
    }