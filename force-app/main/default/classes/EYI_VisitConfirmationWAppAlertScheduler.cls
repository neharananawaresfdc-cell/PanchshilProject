public with sharing class EYI_VisitConfirmationWAppAlertScheduler implements Schedulable {
    @TestVisible private static Boolean bypassTestGuard = false;
    @TestVisible private static Integer testBatchSize = 1;
    
    // This method will be called when the scheduled job executes
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest() || bypassTestGuard) {
            // Instantiate and execute the batch class with a batch size of 1
            EYI_VisitConfirmationWAppAlertBatch batch = new EYI_VisitConfirmationWAppAlertBatch();
            Integer batchSize = (!Test.isRunningTest() ? 1 : testBatchSize);
            Database.executeBatch(batch, batchSize);
        }
    }

    // Method to schedule the batch job using a cron expression
    public static void scheduleBatch() {
        // Get the cron expression from a custom label (make sure it's correctly defined in your org)
        String cronExpression = System.Label.EYI_VisitConfirmationSchedulerCron;
        
        // Generate a dynamic and readable job name with formatted timestamp
        String whatsappJobName = 'VisitConfirmationWhatsAppJob_' + System.now().format('yyyy-MM-dd_HH-mm-ss');

        // Schedule the job using the cron expression and formatted job name
        System.schedule(whatsappJobName, cronExpression, new EYI_VisitConfirmationWAppAlertScheduler());
    }
}