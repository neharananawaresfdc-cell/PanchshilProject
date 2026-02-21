public with sharing class EYI_PresalesOpenTaskReportBatchScheduler implements Schedulable {
     @TestVisible private static Boolean bypassTestGuard = false;
    // This method will be called when the scheduled job executes
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest() || bypassTestGuard) {
            // Instantiate and execute the batch class with a batch size of 1
            EYI_PresalesOpenTasksReportBatch batch = new EYI_PresalesOpenTasksReportBatch();
            Database.executeBatch(batch, 1);
        }
    }

    // Method to schedule the batch job using a cron expression
    public static void scheduleBatch() {
        // Get the cron expression from a custom label (make sure it's correctly defined in your org)
        String cronExpression = System.Label.EYI_ReportSchedulerCron;
        
        // Generate a dynamic and readable job name with formatted timestamp
        String jobName = 'PresalesOpenTasksReportBatch_' + System.now().format('yyyy-MM-dd_HH-mm-ss');
        
        // Schedule the job using the cron expression and formatted job name
        System.schedule(jobName, cronExpression, new EYI_PresalesOpenTaskReportBatchScheduler());
    }
}