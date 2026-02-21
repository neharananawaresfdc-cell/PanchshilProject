global without sharing class AadharTxnDetailsUpdateAppBatchSchedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        AadharTxnDetailsUpdateApplicantBatch batchJob = new AadharTxnDetailsUpdateApplicantBatch(); 
        Database.executeBatch(batchJob, 25);
     }
}