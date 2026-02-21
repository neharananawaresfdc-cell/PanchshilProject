public with sharing class EYI_MonTargetReceivedAmtBatchScheduler implements Schedulable {
   public void execute(SchedulableContext sc) {
        Database.executeBatch(new EYI_MonthlyTargetReceivedAmtBatch(), 200);
    }

    public static void scheduleNextRun() {
        Date nextMonth = Date.today().addMonths(1);
        Integer lastDay = Date.daysInMonth(nextMonth.year(), nextMonth.month());
        DateTime nextRunDate = DateTime.newInstance(nextMonth.year(), nextMonth.month(), lastDay, 0, 0, 0);
        
        // Format cron expression for midnight run
        String cron = '0 0 23 ' + nextRunDate.day() + ' ' + nextRunDate.month() + ' ? ' + nextRunDate.year();

        // Name must be unique per job
        String jobName = 'EYI_Monthly Collection Received Job' + nextRunDate.format('yyyyMMdd');

        System.schedule(jobName, cron, new EYI_MonTargetReceivedAmtBatchScheduler());
    }
}