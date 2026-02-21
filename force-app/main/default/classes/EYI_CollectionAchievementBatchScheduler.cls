global without sharing class EYI_CollectionAchievementBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date today = Date.today();
        Date lastDay = today.toStartOfMonth().addMonths(1).addDays(-1);
        
        // Run batch only if today is the last day of the month
        if (today == lastDay) {
            Database.executeBatch(new EYI_CollectionAchievementBatch(), 200);
        }
    }
    public static void scheduleMe(){
        String cronExp = '0 0 23 * * ?'; // Every day at 11:00 PM
        System.schedule('EYI_CollectionAchievementBatchScheduler', cronExp, new EYI_CollectionAchievementBatchScheduler());

    }
}