global without sharing class EYI_AadharTxnDetailsUpdateJobSched implements Schedulable {
    
    // This method will be triggered when the job is executed
    public void execute(SchedulableContext context) {
        // Instantiate the batch job class
        EYI_AadharTxnDetailsUpdateBatchJob batchJob = new EYI_AadharTxnDetailsUpdateBatchJob();
        
        // Execute the batch job with the batch size of 200
        Database.executeBatch(batchJob, 200);
    }

    // Method to schedule the job (run this once manually or in a trigger, etc.)
    public static void scheduleJob() {
        String cronExpression = '0 0 0/3 1/1 * ? *';  // Every 3 hours
        String jobName = 'AadharTxnDetailsUpdateBatchJobScheduler';

        // Schedule the job using the cron expression
        System.schedule(jobName, cronExpression, new EYI_AadharTxnDetailsUpdateJobSched());
    }
}