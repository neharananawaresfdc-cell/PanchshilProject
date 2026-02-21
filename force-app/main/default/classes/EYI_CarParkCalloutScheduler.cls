global class EYI_CarParkCalloutScheduler {
    global void execute(SchedulableContext sc) {
        // Fetch batch size from Custom Metadata
        Dynamic_Batch_Setting__c batchSetting = [SELECT Batch_size__c FROM Dynamic_Batch_Setting__c WHERE Name = 'Car Park Sync' LIMIT 1];
        
        // Default batch size if not set
        Integer batchSize = (batchSetting.Batch_size__c != null) ? Integer.valueOf(batchSetting.Batch_size__c) : 20;
        
        // Execute the batch job
        EYI_CarParkCalloutBatch batchJob = new EYI_CarParkCalloutBatch();
        Database.executeBatch(batchJob, batchSize);
    }
}