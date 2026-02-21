global without sharing class EYI_EsignTxnUpdateApplicantBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        EYI_EsignTxnUpdateApplicantBatch batchJob = new EYI_EsignTxnUpdateApplicantBatch(); 
        Database.executeBatch(batchJob, 25);
     }
}