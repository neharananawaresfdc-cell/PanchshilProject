global without sharing class EYI_SAP_AgeingBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        // Define dynamic due days to pass into the batch constructor
        Map<String, String> dueDaysMap = new Map<String, String>{
            'DueDays1' => '30',
            'DueDays2' => '60',
            'DueDays3' => '90',
            'DueDays4' => '120',
            'DueDays5' => '150',
            'DueDays6' => '180',
            'DueDays7' => '365',
            'DueDays8' => '720'
        };
        
        // Create an instance of the batch class
        EYI_SAP_AgeingBatch batchInstance = new EYI_SAP_AgeingBatch(dueDaysMap);
        
        // Execute the batch with a scope size (e.g., 50)
        Database.executeBatch(batchInstance, 10);
    }
}