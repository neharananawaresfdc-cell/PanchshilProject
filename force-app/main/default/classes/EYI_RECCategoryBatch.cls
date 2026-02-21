public class EYI_RECCategoryBatch implements Database.Batchable<SObject>,Database.stateful {
    
    public String query;
    // Constructor to initialize the query
    public EYI_RECCategoryBatch() {
        query = 'SELECT Id FROM EYI_REC__c';
    }
    // Start method for batch processing
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    // Execute method for batch processing
    public void execute(Database.BatchableContext bc, List<EYI_REC__c> records) {    
        // Step 1: Collect the REC IDs from the provided list of records
        Set<Id> recIds = new Set<Id>();
        for (EYI_REC__c rec : records) {
            recIds.add(rec.Id); // Add the ID of each record to the set
        }
        EYI_RECCategoryService.updateRecCategories(recIds);
        EYI_RECCategoryService.updateRecProjectCategories(recIds);
    }
    // Finish method after batch completes
    public void finish(Database.BatchableContext bc) {
        // Optionally, log or notify the completion
        System.debug('Batch process for updating REC Categories is complete');
    }
}