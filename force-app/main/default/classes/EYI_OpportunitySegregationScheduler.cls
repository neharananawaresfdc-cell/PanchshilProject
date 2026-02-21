public with sharing class EYI_OpportunitySegregationScheduler implements Schedulable{
    
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest()) {
            EYI_OpportunitySegregationBatch recCatBatch = new EYI_OpportunitySegregationBatch();   Database.executeBatch(recCatBatch, 1); 
        }
    }
    
    public static void scheduleBatch() {
        // Get the cron expression from a custom label (make sure it's correctly defined in your org)
        String cronExpression = System.Label.EYI_Opportunity_SegregationCron;
        String categoryJobName = 'EYI_OpportunitySegregationBatch__' + System.now().format('yyyy-MM-dd_HH-mm-ss');
        System.schedule(categoryJobName, cronExpression, new EYI_OpportunitySegregationScheduler());
    }
}