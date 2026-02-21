public with sharing class EYI_ManagerRevenueAchievementBatch implements Database.Batchable<SObject>,Database.Stateful {

    private static final String KPI_TYPE = 'Revenue Target';
    private static final String MODULE_TYPE = 'Revenue';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Return only managers who have target records
        return Database.getQueryLocator([
            SELECT Id, OwnerId FROM EYI_Target_Management__c WHERE EYI_Target_KPI__c = :KPI_TYPE 
        ]);
    }

    public void execute(Database.BatchableContext BC, List<EYI_Target_Management__c> scope) {
        Set<Id> tlIds = new Set<Id>();
        for (EYI_Target_Management__c t : scope) {
            tlIds.add(t.OwnerId);
        }

        // Step 1: Build User Manager Map (who reports to whom)
        Map<Id, List<Id>> managerToUsers = new Map<Id, List<Id>>();
        List<User> users = [SELECT Id, ManagerId FROM User WHERE IsActive = true];
        for (User u : users) {
            if (u.ManagerId != null) {
                if (!managerToUsers.containsKey(u.ManagerId)) {
                    managerToUsers.put(u.ManagerId, new List<Id>());
                }
                managerToUsers.get(u.ManagerId).add(u.Id);
            }
        }

        // Step 2: Fiscal Year Window
        Integer fiscalStartMonth = Integer.valueOf(System.Label.EYI_FINANCIAL_START_MONTH);
        Date today = Date.today();
        Integer fiscalYear = today.month() >= fiscalStartMonth ? today.year() + 1 : today.year();
        Integer fiscalStartYear = fiscalYear - 1;
        Date fiscalStart = Date.newInstance(fiscalStartYear, fiscalStartMonth, 1);
        Date fiscalEnd = fiscalStart.addYears(1).addDays(-1);

        // Step 3: Fetch all target records of reportees
        Set<Id> allReporteeIds = new Set<Id>();
        for (Id tlId : tlIds) {
            if (managerToUsers.containsKey(tlId)) {
                allReporteeIds.addAll(managerToUsers.get(tlId));
            }
        }

        Map<Id, List<EYI_Target_Management__c>> tlToReporteeTargets = new Map<Id, List<EYI_Target_Management__c>>();
        if (!allReporteeIds.isEmpty()) {
            List<EYI_Target_Management__c> reporteeTargets = [
                SELECT Id, OwnerId,
                    EYI_Jan_Achievement__c, EYI_Feb_Achievement__c, EYI_March_Achievement__c,
                    EYI_April_Achievement__c, EYI_May_Achievement__c, EYI_Jun_Achievement__c,
                    EYI_July_Achievement__c, EYI_Aug_Achievement__c, EYI_Sept_Achievement__c,
                    EYI_Oct_Achievement__c, EYI_Nov_Achievement__c, EYI_Dec_Achievement__c,
                    EYI_Q1_Gold_Achievement__c, EYI_Q2_Gold_Achievement__c, EYI_Q3_Gold_Achievement__c, EYI_Q4_Gold_Achievement__c,
                    EYI_Q1_Commercial_Achievement__c, EYI_Q2_Commercial_Achievement__c, EYI_Q3_Commercial_Achievement__c, EYI_Q4_Commercial_Achievement__c,
                    EYI_Q1_Platinum_Achievement__c, EYI_Q2_Platinum_Achievement__c, EYI_Q3_Platinum_Achievement__c, EYI_Q4_Platinum_Achievement__c
                FROM EYI_Target_Management__c
                WHERE OwnerId IN :allReporteeIds
                AND EYI_Target_KPI__c = :KPI_TYPE
                AND EYI_Target_Module__c = :MODULE_TYPE
                AND EYI_Target_Start_Date__c >= :fiscalStart
                AND EYI_Target_End_Date__c <= :fiscalEnd
            ];

            // Group reportee targets by their manager
            for (EYI_Target_Management__c t : reporteeTargets) {
                for (Id managerId : managerToUsers.keySet()) {
                    if (managerToUsers.get(managerId).contains(t.OwnerId)) {
                        if (!tlToReporteeTargets.containsKey(managerId)) {
                            tlToReporteeTargets.put(managerId, new List<EYI_Target_Management__c>());
                        }
                        tlToReporteeTargets.get(managerId).add(t);
                    }
                }
            }
        }

        // Step 4: Aggregate & Update TL Records
        List<EYI_Target_Management__c> updates = new List<EYI_Target_Management__c>();

        for (EYI_Target_Management__c tlTarget : scope) {
            Id tlId = tlTarget.OwnerId;
            List<EYI_Target_Management__c> repTargets = tlToReporteeTargets.get(tlId);

            if (repTargets == null || repTargets.isEmpty()) continue;

            Map<String, Decimal> fieldTotals = new Map<String, Decimal>();

            for (EYI_Target_Management__c rep : repTargets) {
                for (String fieldName : getAllAchievementFields()) {
                    Decimal val = (Decimal)rep.get(fieldName);
                    if (val != null) {
                        Decimal existing = fieldTotals.containsKey(fieldName) ? fieldTotals.get(fieldName) : 0;
                        fieldTotals.put(fieldName, existing + val);
                    }
                }
            }


            for (String fieldName : fieldTotals.keySet()) {
                tlTarget.put(fieldName, fieldTotals.get(fieldName));
            }

            updates.add(tlTarget);
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }


    public void finish(Database.BatchableContext BC) {
        // Optional logging or email
    }

    private void collectAllReportees(Id managerId, Map<Id, List<Id>> mgrMap, Set<Id> result) {
        if (!mgrMap.containsKey(managerId)) return;
        for (Id uid : mgrMap.get(managerId)) {
            if (result.add(uid)) {
                collectAllReportees(uid, mgrMap, result);
            }
        }
    }

    private List<String> getAllAchievementFields() {
        return new List<String>{
            'EYI_Jan_Achievement__c', 'EYI_Feb_Achievement__c', 'EYI_March_Achievement__c',
            'EYI_April_Achievement__c', 'EYI_May_Achievement__c', 'EYI_Jun_Achievement__c',
            'EYI_July_Achievement__c', 'EYI_Aug_Achievement__c', 'EYI_Sept_Achievement__c',
            'EYI_Oct_Achievement__c', 'EYI_Nov_Achievement__c', 'EYI_Dec_Achievement__c',
            'EYI_Q1_Gold_Achievement__c', 'EYI_Q2_Gold_Achievement__c', 'EYI_Q3_Gold_Achievement__c', 'EYI_Q4_Gold_Achievement__c',
            'EYI_Q1_Commercial_Achievement__c', 'EYI_Q2_Commercial_Achievement__c', 'EYI_Q3_Commercial_Achievement__c', 'EYI_Q4_Commercial_Achievement__c',
            'EYI_Q1_Platinum_Achievement__c', 'EYI_Q2_Platinum_Achievement__c', 'EYI_Q3_Platinum_Achievement__c', 'EYI_Q4_Platinum_Achievement__c'
        };
    }
}