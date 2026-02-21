public with sharing class EYI_VisitConfirmationSMSAlertScheduler implements Schedulable {
     @TestVisible private static Boolean bypassTestGuard = false;
    // This method will be called when the scheduled job executes
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest() || bypassTestGuard) {
            EYI_VisitConfirmationSMSAlertBatch smsBatch = new EYI_VisitConfirmationSMSAlertBatch();
            Database.executeBatch(smsBatch, 1); 
        }
    }

    // Method to schedule the batch job using a cron expression
    public static void scheduleBatch() {
        // Get the cron expression from a custom label (make sure it's correctly defined in your org)
        String cronExpression = System.Label.EYI_VisitConfirmationSchedulerCron;
        
        // Generate a dynamic and readable job name with formatted timestamp
        String smsJobName = 'VisitConfirmationSMSAlertJob_' + System.now().format('yyyy-MM-dd_HH-mm-ss');
        //String whatsappJobName = 'VisitConfirmationWhatsAppJob_' + System.now().format('yyyy-MM-dd_HH-mm-ss');

        // Schedule the job using the cron expression and formatted job name
        System.schedule(smsJobName, cronExpression, new EYI_VisitConfirmationSMSAlertScheduler());
    }
}