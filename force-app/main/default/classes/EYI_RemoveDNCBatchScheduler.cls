global without sharing class EYI_RemoveDNCBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        EYI_RemoveDNCBatch batch = new EYI_RemoveDNCBatch();
        Database.executeBatch(batch, 200); // 200 records per batch
    }
}