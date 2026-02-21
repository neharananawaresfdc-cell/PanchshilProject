public with sharing class EYI_DigitalLeadEscalationReportScheduler implements Schedulable {
    
    // The execute method which will run when the scheduled job executes
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest()) {
            //EYI_DigitalLeadEscalationReportBatch batch = new EYI_DigitalLeadEscalationReportBatch();
            // Execute the batch job with a batch size of 1
            Database.executeBatch(new EYI_DigitalLeadEscalationReportBatch(), 1);
        }
    }

    // Method to schedule the batch job using a cron expression
    public static void scheduleBatch() {
        // Get the cron expression from a custom label (ensure the label is defined in your org)
        String cronExpression = System.Label.EYI_ReportSchedulerCron;
        
        // Generate a dynamic and unique job name using a readable format
        String jobName = 'PresalesOpenTasksReportBatch_' + System.now().format('yyyy-MM-dd_HH-mm-ss');
        
        // Schedule the job with the cron expression
        System.schedule(jobName, cronExpression, new EYI_DigitalLeadEscalationReportScheduler());
    }
}