global class EYI_TDSOutstandingSchedular implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Start the batch process
        EYI_TDSOutstandingBatch batchJob = new EYI_TDSOutstandingBatch();
        Database.executeBatch(batchJob,1);
    }
}