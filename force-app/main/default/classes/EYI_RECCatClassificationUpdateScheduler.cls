public without sharing class EYI_RECCatClassificationUpdateScheduler implements Schedulable{
    
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest()) {
            EYI_RECCategoryBatch recCatBatch = new EYI_RECCategoryBatch();
            Database.executeBatch(recCatBatch, 1); 
        }
    }
    
    public static void scheduleBatch() {
        // Get the cron expression from a custom label (make sure it's correctly defined in your org)
        String cronExpression = System.Label.EYI_VisitConfirmationSchedulerCron;
        
        // Generate a dynamic and readable job name with formatted timestamp
        String categoryJobName = 'RecCategoryClassificationUpdate_' + System.now().format('yyyy-MM-dd_HH-mm-ss');
        //String whatsappJobName = 'VisitConfirmationWhatsAppJob_' + System.now().format('yyyy-MM-dd_HH-mm-ss');

        // Schedule the job using the cron expression and formatted job name
        System.schedule(categoryJobName, cronExpression, new EYI_RECCatClassificationUpdateScheduler());
    }

}