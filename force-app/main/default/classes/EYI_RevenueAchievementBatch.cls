public with sharing class EYI_RevenueAchievementBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Category-wise achievements stored here (optional use later)
    Map<Id, Map<String, Decimal>> userCategoryAchievementMap = new Map<Id, Map<String, Decimal>>();
    private static final String KPI_TYPE = 'Revenue Target';
    private static final String MODULE_TYPE = 'Revenue';
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
            SELECT Id, Name, OwnerId, EYI_Project__c, EYI_Target_Module__c,EYI_Achivements__c
            , EYI_Target_KPI__c, EYI_Tower__c, EYI_Target_Month_Date__c ,EYI_Target_Start_Date__c,EYI_Target_End_Date__c
            FROM EYI_Target_Management__c 
            WHERE EYI_Target_Start_Date__c >= :fiscalStart
            AND EYI_Target_End_Date__c <= :fiscalEnd
            AND EYI_Target_KPI__c = :KPI_TYPE
            AND EYI_Target_Module__c = :MODULE_TYPE
        ]);
    }
    public void execute(Database.BatchableContext BC, List<EYI_Target_Management__c> targetList) {
        List<EYI_Target_Management__c> targetsToUpdate = new List<EYI_Target_Management__c>();
        Map<Id, EYI_Target_Management__c> userTargetMap = new Map<Id, EYI_Target_Management__c>();

        for (EYI_Target_Management__c t : targetList) {
            userTargetMap.put(t.OwnerId, t);
        }

        Set<Id> userIds = userTargetMap.keySet();

        // Fetch bookings related to Closing or Sourcing Managers in our target list
        List<EYI_Booking__c> bookings = [
            SELECT Id, EYI_Actual_Booking_Date__c, EYI_Opportunity_Name__r.Id,
                   EYI_Opportunity_Name__r.EYI_Agreement_Value__c,
                   EYI_Opportunity_Name__r.EYI_Primary_Closing_Manager__c,
                   EYI_Opportunity_Name__r.EYI_Sourcing_Manager__c,
                   EYI_Project_Name__r.EYI_Residential_Type__c       
            FROM EYI_Booking__c
            WHERE (EYI_Opportunity_Name__r.EYI_Primary_Closing_Manager__c IN :userIds
               OR EYI_Opportunity_Name__r.EYI_Sourcing_Manager__c IN :userIds)
			   AND EYI_Actual_Booking_Date__c = THIS_FISCAL_YEAR
			   AND EYI_Actual_Booking_Date__c != NULL
               AND EYI_Opportunity_Name__r.EYI_Agreement_Value__c >0
            AND EYI_Opportunity_Name__r.StageName NOT IN ('Sales Lost', 'Cancelled')
        ];
        System.debug('Bookings: ' + bookings);
        // Monthly and category achievement map
        Map<Id, Map<String, Decimal>> userMonthAchievementMap = new Map<Id, Map<String, Decimal>>();

        for (EYI_Booking__c booking : bookings) {
            Date bookingDate = booking.EYI_Actual_Booking_Date__c;
            if (bookingDate == null){
                continue;
            }

            Opportunity opp = booking.EYI_Opportunity_Name__r;
            if (opp == null){
                continue;
            }
            List<String> monthAbbr = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
            
            Decimal agreementValue = opp.EYI_Agreement_Value__c != null ? opp.EYI_Agreement_Value__c : 0;
            Id closingManager = opp.EYI_Primary_Closing_Manager__c;
            Id sourcingManager = opp.EYI_Sourcing_Manager__c;
            String category = booking.EYI_Project_Name__r != null ? booking.EYI_Project_Name__r.EYI_Residential_Type__c : 'Unknown';

            Set<Id> allUsersToCredit = new Set<Id>();
            if (closingManager != null && userIds.contains(closingManager)) {
                allUsersToCredit.add(closingManager);
            }
            if (sourcingManager != null && userIds.contains(sourcingManager)) {
                allUsersToCredit.add(sourcingManager);
            }
            System.debug('allUsersToCredit====> '+allUsersToCredit);

            for (Id uid : allUsersToCredit) {
                Decimal valueToAdd=0;
                if (sourcingManager == null) {
                    // If either is null, full agreement value
                    valueToAdd = agreementValue;
                } else if (closingManager == sourcingManager) {
                    // Same manager, split once (not double)
                    valueToAdd = agreementValue ;
                } else {
                    // Different managers, each gets half
                    valueToAdd = agreementValue / 2;
                }
                String monthLabel = monthAbbr[bookingDate.month() - 1];
                String baseKey = monthLabel;
                // Regular monthly achievement
                if (!userMonthAchievementMap.containsKey(uid)) {
                    userMonthAchievementMap.put(uid, new Map<String, Decimal>());
                }
                Map<String, Decimal> monthMap = userMonthAchievementMap.get(uid);
                if (!monthMap.containsKey(baseKey)) {
                    monthMap.put(baseKey, 0);
                }
                monthMap.put(baseKey, monthMap.get(baseKey) + valueToAdd);
                System.debug('agreementValue ======>'+agreementValue);
                System.debug('valueToAdd======> '+valueToAdd);

                System.debug('closingManager ===> '+closingManager);
                System.debug('sourcingManager====> '+sourcingManager);
                System.debug('bookingDate ===> '+bookingDate);
                System.debug('monthMap====> '+monthMap);

                // Category bifurcation: e.g., Jan_Gold, Feb_Commercial
                String catKey = getFiscalQuarter(bookingDate) + '_' + category;
                if (!userCategoryAchievementMap.containsKey(uid)) {
                    userCategoryAchievementMap.put(uid, new Map<String, Decimal>());
                }
                Map<String, Decimal> catMap = userCategoryAchievementMap.get(uid);
                if (!catMap.containsKey(catKey)) {
                    catMap.put(catKey, 0);
                }
                catMap.put(catKey, catMap.get(catKey) + valueToAdd);
                System.debug('closingManager ===> '+closingManager);
                System.debug('sourcingManager====> '+sourcingManager);
                System.debug('bookingDate ===> '+bookingDate);
                System.debug('valueToAdd====> '+valueToAdd);
                System.debug('category====> '+category);
                System.debug('catMap====> '+catMap);
            }
        }
        
        System.debug('categoryAchievementMap====> '+userCategoryAchievementMap);
        // Update Target Records
        for (Id uid : userMonthAchievementMap.keySet()) {
            EYI_Target_Management__c t = userTargetMap.get(uid);
            if (t == null) {continue;}

            Map<String, Decimal> monthData = userMonthAchievementMap.get(uid);
            Map<String, Decimal> quarterData = userCategoryAchievementMap.get(uid);

            // Month to field API mapping (adjust based on your org)
            Map<String, String> monthFieldMap = new Map<String, String>{
                'Jan' => 'EYI_Jan_Achievement__c',
                'Feb' => 'EYI_Feb_Achievement__c',
                'Mar' => 'EYI_March_Achievement__c',
                'Apr' => 'EYI_April_Achievement__c',
                'May' => 'EYI_May_Achievement__c',
                'Jun' => 'EYI_Jun_Achievement__c',
                'Jul' => 'EYI_July_Achievement__c',
                'Aug' => 'EYI_Aug_Achievement__c',
                'Sep' => 'EYI_Sept_Achievement__c',
                'Oct' => 'EYI_Oct_Achievement__c',
                'Nov' => 'EYI_Nov_Achievement__c',
                'Dec' => 'EYI_Dec_Achievement__c'
            };

            for (String month : monthData.keySet()) {
                String fieldAPI = monthFieldMap.get(month);
                if (fieldAPI != null) {
                    Decimal val = monthData.get(month);
                    t.put(fieldAPI, val);
                }
            }
            Map<String, String> quarterFieldMap = new Map<String, String>{
                'Q1_Platinum'   => 'EYI_Q1_Platinum_Achievement__c',
                'Q2_Platinum'   => 'EYI_Q2_Platinum_Achievement__c',
                'Q3_Platinum'   => 'EYI_Q3_Platinum_Achievement__c',
                'Q4_Platinum'   => 'EYI_Q4_Platinum_Achievement__c',
                'Q1_Commercial' => 'EYI_Q1_Commercial_Achievement__c',
                'Q2_Commercial' => 'EYI_Q2_Commercial_Achievement__c',
                'Q3_Commercial' => 'EYI_Q3_Commercial_Achievement__c',
                'Q4_Commercial' => 'EYI_Q4_Commercial_Achievement__c',
                'Q1_Gold'       => 'EYI_Q1_Gold_Achievement__c',
                'Q2_Gold'       => 'EYI_Q2_Gold_Achievement__c',
                'Q3_Gold'       => 'EYI_Q3_Gold_Achievement__c',
                'Q4_Gold'       => 'EYI_Q4_Gold_Achievement__c'
            };
            for (String quarter : quarterData.keySet()) {
                String fieldAPI = quarterFieldMap.get(quarter);
                if (fieldAPI != null) {
                    Decimal val = quarterData.get(quarter);
                    t.put(fieldAPI, val);
                }
            }

            targetsToUpdate.add(t);
        }
        system.debug('targetsToUpdate====>'+targetsToUpdate);

        if (!targetsToUpdate.isEmpty()) {
            update targetsToUpdate;
        }
    }
    public static String getFiscalQuarter(Date inputDate) {
        Integer month = inputDate.month();
        
        if (month >= 4 && month <= 6) {
            return 'Q1';
        } else if (month >= 7 && month <= 9) {
            return 'Q2';
        } else if (month >= 10 && month <= 12) {
            return 'Q3';
        } else { // months 1–3
            return 'Q4';
        }
    }

    public void finish(Database.BatchableContext BC) {
        EYI_ManagerRevenueAchievementBatch batch = new EYI_ManagerRevenueAchievementBatch();
        Database.executeBatch(batch,200);
        // You can log or use userCategoryAchievementMap here for debugging/reporting if needed
    }
}