public with sharing class EYI_SourcingSMRevenueAchievementBatch implements Database.Batchable<sObject>, Database.Stateful {

    private static final String KPI_TYPE = 'Revenue Target';
    private static final String MODULE_TYPE = 'Sourcing';

    public Database.QueryLocator start(Database.BatchableContext BC) {
       Integer fiscalStartMonth = Integer.ValueOf(System.Label.EYI_FINANCIAL_START_MONTH); // April
        Date today = Date.today();
        Integer fiscalYear;
        if (today.month() >= fiscalStartMonth) {
            fiscalYear = today.year() + 1;
        } else {
            fiscalYear = today.year();
        }
        // Fiscal year starts in April of the previous calendar year
        Integer fiscalStartYear = fiscalYear - 1;
        Date fiscalStart = Date.newInstance(fiscalStartYear, fiscalStartMonth, 1);
        Date fiscalEnd = fiscalStart.addYears(1).addDays(-1);
        return Database.getQueryLocator([
            SELECT Id, Name, OwnerId, EYI_Project__c, EYI_Target_Module__c,
                   EYI_Achivements__c, EYI_Target_KPI__c, EYI_Tower__c, EYI_Target_Month_Date__c ,EYI_Target_Start_Date__c,EYI_Target_End_Date__c
            FROM EYI_Target_Management__c 
            WHERE EYI_Target_Start_Date__c >= :fiscalStart
            AND EYI_Target_End_Date__c <= :fiscalEnd
            AND EYI_Target_KPI__c = :KPI_TYPE
            AND EYI_Target_Module__c = :MODULE_TYPE
            AND EYI_Project__c != null
        ]);
    }

    public void execute(Database.BatchableContext BC, List<EYI_Target_Management__c> targetList) {
        // Build keys: OwnerId + Project => Target
        Map<String, EYI_Target_Management__c> targetMap = new Map<String, EYI_Target_Management__c>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        if (targetList != null && (!targetList.isEmpty())) {   
            for (EYI_Target_Management__c target : targetList) {
                if (target.OwnerId != null && target.EYI_Project__c != null) {
                    String key = target.OwnerId + '_' + target.EYI_Project__c;
                    targetMap.put(key, target);
                    ownerIds.add(target.OwnerId);
                    projectIds.add(target.EYI_Project__c);
                }
            }

            Date firstDayOfMonth = Date.today().toStartOfMonth();
            Date firstDayOfNextMonth = firstDayOfMonth.addMonths(1);

            List<EYI_Booking__c> bookingList = [
                SELECT Id, EYI_Project_Name__c, EYI_Opportunity_Name__c,
                    EYI_Opportunity_Name__r.EYI_Sourcing_Manager__c,EYI_Opportunity_Name__r.EYI_Primary_Closing_Manager__c,
                    EYI_Opportunity_Name__r.EYI_Agreement_Value__c,EYI_Actual_Booking_Date__c
                FROM EYI_Booking__c
                WHERE EYI_Actual_Booking_Date__c >= :firstDayOfMonth
                    AND EYI_Actual_Booking_Date__c < :firstDayOfNextMonth
                    AND EYI_Opportunity_Name__c != null
                    AND EYI_Project_Name__c != null
                    AND EYI_Opportunity_Name__r.EYI_Agreement_Value__c > 100
                    AND EYI_Opportunity_Name__r.EYI_Sourcing_Manager__c != null
                    AND EYI_Opportunity_Name__r.EYI_Sourcing_Manager__c IN :ownerIds
                    AND EYI_Project_Name__c IN :projectIds
                    AND EYI_Opportunity_Name__r.EYI_Walk_in_Source__c ='PREC'
            ];

                System.debug('bookingList====> '+bookingList);
            // Aggregate agreement values per Sourcing Manager + Project (de-dupe Opportunities)
            Map<String, Decimal> achievementMap = new Map<String, Decimal>();
            Set<Id> processedOpps = new Set<Id>();

           for (EYI_Booking__c booking : bookingList) {
                Id oppId = booking.EYI_Opportunity_Name__c;
                Id smId = booking.EYI_Opportunity_Name__r.EYI_Sourcing_Manager__c;
                Id cmId = booking.EYI_Opportunity_Name__r.EYI_Primary_Closing_Manager__c;
                Id projectId = booking.EYI_Project_Name__c;

                if (oppId == null || smId == null || projectId == null || processedOpps.contains(oppId)) {
                    continue;
                }

                processedOpps.add(oppId);
                String key = smId + '_' + projectId;

                Decimal agreementValue = booking.EYI_Opportunity_Name__r.EYI_Agreement_Value__c != null
                    ? booking.EYI_Opportunity_Name__r.EYI_Agreement_Value__c
                    : 0;

                // Apply your condition: divide by 2 if SM and CM are the same and value > 0
                if (agreementValue > 0 && smId == cmId) {
                    agreementValue = agreementValue / 2;
                }

                if (achievementMap.containsKey(key)) {
                    achievementMap.put(key, achievementMap.get(key) + agreementValue);
                } else {
                    achievementMap.put(key, agreementValue);
                }
            }

            // Update target achievements if changed
            List<EYI_Target_Management__c> updates = new List<EYI_Target_Management__c>();
            for (String key : targetMap.keySet()) {
                EYI_Target_Management__c target = targetMap.get(key);
                Decimal newAchievement = achievementMap.containsKey(key) ? achievementMap.get(key) : 0;

                if (target.EYI_Achivements__c != newAchievement) {
                    target.EYI_Achivements__c = newAchievement;
                    updates.add(target);
                }
            }
            System.debug('updates====> '+updates);
            if (!updates.isEmpty()) {
                update updates;
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Optional: Add post-processing logic or logs
    }
}