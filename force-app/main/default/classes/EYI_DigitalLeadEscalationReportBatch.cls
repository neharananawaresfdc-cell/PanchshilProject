public with sharing class EYI_DigitalLeadEscalationReportBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to fetch records
        return Database.getQueryLocator([SELECT Id, DeveloperName FROM Report WHERE DeveloperName = :System.Label.EYI_DigitalLeadEscalationReport]);
    }
    
    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<Report> scope) {
        EYI_PresalesOpenTasksReportBatchHandler handler = new EYI_PresalesOpenTasksReportBatchHandler();
        // Process each record in the scope
        for (Report rep : scope) {
            handler.sendReportEmail(rep.Id,System.Label.EYI_DigitalLeadEscalationReport);
        }
    }
    
    // Finish method to perform post-processing operations
    public void finish(Database.BatchableContext BC) {
        // Send an email or log the completion
        System.debug('Batch processing completed.');
    }
}