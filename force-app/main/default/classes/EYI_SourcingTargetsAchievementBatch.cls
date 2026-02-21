public with sharing class EYI_SourcingTargetsAchievementBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext BC){
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
            AND EYI_Target_KPI__c != 'Revenue Target'
            AND EYI_Target_Module__c = 'Sourcing'
        ]);

    }

    public void execute(Database.BatchableContext BC, List<EYI_Target_Management__c> targetList){
        Set<Id> ownerIdSet =  new Set<Id>();
        Map<String,EYI_Target_Management__c> monthlyTargetMap = new Map<String,EYI_Target_Management__c>();
        Date monthStart;
        Date monthEnd;
        if(targetList.size() >0){
            EYI_Target_Management__c sampleRecord = targetList[0]; // Since batch size is 1
            monthStart = sampleRecord.EYI_Target_Start_Date__c;
            monthEnd = sampleRecord.EYI_Target_End_Date__c;
            for(EYI_Target_Management__c target:targetList){
                ownerIdSet.add(target.OwnerId);
                if(target.OwnerId != null && target.EYI_Target_KPI__c != null){
                    String key = target.OwnerId + '_' + target.EYI_Target_KPI__c;
                    monthlyTargetMap.put(key,target);
                }
            }
        }
        if (!ownerIdSet.isEmpty()) {
            AggregateResult[] groupedResults = [
                SELECT OwnerId, COUNT(Id) total
                FROM EYI_VP_VC__c
                WHERE OwnerId IN :ownerIdSet
                AND CreatedDate >= :monthStart
                AND CreatedDate <= :monthEnd
                GROUP BY OwnerId
            ];

            for (AggregateResult ar : groupedResults) {
                Id ownerId = (Id) ar.get('OwnerId');
                Integer count = (Integer) ar.get('total');
                String key = ownerId + '_' + 'VC/VP Target';
                EYI_Target_Management__c target = monthlyTargetMap.get(key);
                if(target != null && target.EYI_Target_KPI__c == 'VC/VP Target'){
                    target.EYI_Achivements__c = count;
                }
            }

            Map<String, Integer> managerToCIFCount = new Map<String, Integer>();

            List<EYI_Customer_Information_Form__c> cifList = [SELECT Id, EYI_Opportunity__r.EYI_Sourcing_Manager__c, EYI_Opportunity__r.EYI_Walk_in_Source__c
                                                , CreatedDate ,EYI_Opportunity__r.EYI_Project_Tower_Enquired__c
                                                  FROM EYI_Customer_Information_Form__c
                                                  WHERE EYI_Opportunity__r.EYI_Sourcing_Manager__c IN :ownerIdSet
                                                  AND EYI_Opportunity__r.EYI_Walk_in_Source__c = 'PREC'
                                                  AND CreatedDate >= :monthStart
                                                  AND CreatedDate <= :monthEnd];

            for (EYI_Customer_Information_Form__c cif : cifList) {
                String key = cif.EYI_Opportunity__r.EYI_Sourcing_Manager__c + '_Walkin Achieved';
                if (managerToCIFCount.containsKey(key)) {
                    managerToCIFCount.put(key, managerToCIFCount.get(key) + 1);
                } else {
                    managerToCIFCount.put(key, 1);
                }
            }

            for(String key : managerToCIFCount.keySet()) {
                EYI_Target_Management__c target = monthlyTargetMap.get(key);
                if(target != null && target.EYI_Target_KPI__c == 'Walkin Achieved'){
                    target.EYI_Achivements__c = managerToCIFCount.get(key);
                }
            }
            System.debug('managerToCIFCount===> '+monthlyTargetMap);
            System.debug('managerToCIFCount===> '+managerToCIFCount.values());

            // AggregateResult[] groupedCIFResults = [
            //     SELECT EYI_Sourcing_Manager__c, COUNT(Id) formCount
            //     FROM EYI_Customer_Information_Form__c
            //     WHERE EYI_Sourcing_Manager__c IN :ownerIdSet
            //     AND EYI_Opportunity__r.EYI_Walk_in_Source__c = 'PREC'
            //     AND CreatedDate >= :monthStart
            //     AND CreatedDate <= :monthEnd
            //     GROUP BY EYI_Sourcing_Manager__c
            // ];

            // for (AggregateResult ar : groupedCIFResults) {
            //     Id managerId = (Id) ar.get('EYI_Sourcing_Manager__c');
            //     Integer count = (Integer) ar.get('formCount');
            //     String key = managerId + '_' + 'Walkin Achieved';
            //     EYI_Target_Management__c target = monthlyTargetMap.get(key);
            //     if(target != null && target.EYI_Target_KPI__c == 'Walkin Achieved'){
            //         target.EYI_Achivements__c = count;
            //     }
            // }



            AggregateResult[] groupedRECResults = [
                SELECT OwnerId, COUNT(Id) total
                FROM EYI_REC__c
                WHERE OwnerId IN :ownerIdSet
                AND CreatedDate >= :monthStart
                AND CreatedDate <= :monthEnd
                GROUP BY OwnerId
            ];

            for (AggregateResult ar : groupedRECResults) {
                Id ownerId = (Id) ar.get('OwnerId');
                Integer count = (Integer) ar.get('total');
                String key = ownerId + '_' + 'New CP Empanelment';
                EYI_Target_Management__c target = monthlyTargetMap.get(key);
                if(target != null && target.EYI_Target_KPI__c == 'New CP Empanelment'){
                    target.EYI_Achivements__c = count;
                }
            }

            AggregateResult[] taskResults = [
                SELECT OwnerId, COUNT(Id) taskCount
                FROM Task
                WHERE EYI_REC_Account__c != null
                AND OwnerId IN :ownerIdSet
                AND EYI_Meeting_Status__c != null
                AND CreatedDate >= :monthStart
                AND CreatedDate <= :monthEnd
                AND EYI_Meeting_Status__c  = 'Completed'
                GROUP BY OwnerId
            ];

            for (AggregateResult ar : taskResults) {
                Id ownerId = (Id) ar.get('OwnerId');
                Integer count = (Integer) ar.get('taskCount');
                String key = ownerId + '_' + 'Meeting Target';
                EYI_Target_Management__c target = monthlyTargetMap.get(key);
                if(target != null && target.EYI_Target_KPI__c == 'Meeting Target'){
                    target.EYI_Achivements__c = count;
                }
            }

            System.debug('monthlyTargetMap ==> '+monthlyTargetMap.values());
        }
        if(monthlyTargetMap!=null){
            update monthlyTargetMap.values();
        }
    }

    public void finish(Database.BatchableContext BC){
        Database.executebatch(new EYI_RevenueAchievementBatch());
    }
}