global without sharing class EYI_LeadNoShowScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        LeadNoShowBatch batch = new LeadNoShowBatch();
        Database.executeBatch(batch, 200); // 200 records per batch
    }
}