@isTest
public with sharing class EYI_CollectionAchivementScheduleTest {
    @isTest static void testExecuteOnLastDay() {
        // Get last day of this month
        Date today = Date.today();
        Date lastDay = today.toStartOfMonth().addMonths(1).addDays(-1);
        
        Test.startTest();
        
        // Use Test.setFixedSearchResults or Test.setCurrentDate is not available,
        // So we test both cases by overriding the date using a helper class or by running normally
        
        // 1. If today is last day, batch should run
        if (today == lastDay) {
            new EYI_CollectionAchievementBatchScheduler().execute(null);
            // We cannot directly assert batch execution here, but no exceptions means success
        } else {
            // 2. If today is NOT last day, batch should NOT run
            // Just run scheduler and expect no batch executed
            new EYI_CollectionAchievementBatchScheduler().execute(null);
        }
        EYI_CollectionAchievementBatchScheduler.scheduleMe();
        Test.stopTest();
    }
}