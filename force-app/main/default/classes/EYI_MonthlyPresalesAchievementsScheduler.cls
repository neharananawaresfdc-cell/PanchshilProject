global without sharing class EYI_MonthlyPresalesAchievementsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        EYI_MonthlyPresalesAchievementsBatch batchJob = new EYI_MonthlyPresalesAchievementsBatch();
        // Optional: specify batch size (default is 200)
        Database.executeBatch(batchJob, 200);
    }
}