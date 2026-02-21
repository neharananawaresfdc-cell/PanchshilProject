global without sharing class EYI_SAP_OutstandingBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Start the batch process
        EYI_SAP_OutstandingBatch batchJob = new EYI_SAP_OutstandingBatch();
        Database.executeBatch(batchJob,10);
    }
}