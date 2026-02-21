public with sharing class EYI_MonthlyTargetReceivedAmtBatch implements Database.Batchable<SObject>, Database.Stateful {
        // Query for the records you want to process
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, name, EYI_Project_Name__c, EYI_Project_Name__r.Name
                                        , EYI_Project_Name__r.EYI_Target_Percentage__c ,EYI_Relationship_Manager__c
                                        ,EYI_Project_Name__r.EYI_SAP_Salesorg__c,EYI_SAP_Delivery_Plant_Code__c
                                        FROM EYI_Tower__c WHERE CreatedDate = THIS_MONTH
        ]);
    }

    // Logic to process each batch of records
    public void execute(Database.BatchableContext BC, List<EYI_Tower__c> towerList) {
        Decimal currMonCollectibleAmt = 0;
        Map<String,Id> demandIdMap =  new Map<String,Id>();
        Map<String,Id> targetIdMap =  new Map<String,Id>();
        List<EYI_Demand__c> demandUpdateList = new List<EYI_Demand__c>();
        List<Monthly_Target__c> monTargetToBeInserted = new List<Monthly_Target__c>();
        Map<String, EYI_Tower__c> towerMap = new Map<String, EYI_Tower__c>();
        Map<String, Decimal> outstandingAmountMap = new Map<String, Decimal>();
        List<Monthly_Target__c> targetsToUpdate = new List<Monthly_Target__c>();
        
        Set<String> salesOrgSet = new Set<String>();
		Set<String> plantCodeSet = new Set<String>();
        Date firstDayOfMonth = Date.today().toStartOfMonth();
        Date lastDayOf15Days = firstDayOfMonth.addDays(14);

        for (EYI_Tower__c tower : towerList) {
            String salesOrg = tower.EYI_Project_Name__r.EYI_SAP_Salesorg__c;
            String plantCode = tower.EYI_SAP_Delivery_Plant_Code__c;
            // Only proceed if both parts of the key are non-null
            if (salesOrg != null && plantCode != null) {
                salesOrgSet.add(salesOrg);
                plantCodeSet.add(plantCode);

                String key = salesOrg + '-' + plantCode;

                // Store one record per unique key (later records will overwrite earlier ones)
                towerMap.put(key, tower);
            }
        }
        List<EYI_SAP_Report__c> allRelevantDemands =[ SELECT Id,name,EYI_Billed_Amt_Debit_Note_Amt__c,
            Opportunity__r.name,RecordType.name,EYI_Sales_Org__c,EYI_Plant__c ,Opportunity__r.EYI_Collectible_Status__c
            FROM EYI_SAP_Report__c WHERE 
            EYI_Sales_Org__c IN :salesOrgSet
            AND EYI_Plant__c IN :plantCodeSet
            AND Opportunity__r.EYI_Collectible_Status__c = 'Collectible'
            AND RecordType.name='SAP Outstanding Report'];

        for (EYI_SAP_Report__c report : allRelevantDemands) {
            String salesOrg = report.EYI_Sales_Org__c;
            String plant = report.EYI_Plant__c;

            // Skip if either part of the key is null
            if (salesOrg == null || plant == null) {
                continue;
            }

            String key = salesOrg + '-' + plant;

            // Default to 0 if no amount, then add
            Decimal currentAmount = report.EYI_Billed_Amt_Debit_Note_Amt__c != null ? report.EYI_Billed_Amt_Debit_Note_Amt__c : 0;
            if (outstandingAmountMap.containsKey(key)) {
                outstandingAmountMap.put(key, outstandingAmountMap.get(key) + currentAmount);
            } else {
                outstandingAmountMap.put(key, currentAmount);
            }
        }
        System.debug('outstandingAmountMap====>'+outstandingAmountMap);
        List<Monthly_Target__c> monthlyTargetList = [SELECT Id,EYI_Tower__c,EYI_Project__c	, EYI_Project__r.EYI_SAP_Salesorg__c, EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c
                                                    FROM Monthly_Target__c
                                                    WHERE Createddate = THIS_MONTH];
        
        for (Monthly_Target__c target : monthlyTargetList) {
            Monthly_Target__c  mTarget =  new Monthly_Target__c();
            String salesOrg = target.EYI_Project__r?.EYI_SAP_Salesorg__c;
            String plant = target.EYI_Tower__r?.EYI_SAP_Delivery_Plant_Code__c;

            if (salesOrg == null || plant == null) {
                continue; // skip if any part is null
            }

            String key = salesOrg + '-' + plant;

            if (towerMap.containsKey(key) && outstandingAmountMap.containsKey(key) && outstandingAmountMap.get(key) != null) {

                mTarget.EYI_Received_Amount__c =  outstandingAmountMap.get(key);
                System.debug('targetsToUpdate key====>'+key);
                System.debug(' outstandingAmountMap.get(key)====>'+ outstandingAmountMap.get(key));
                mTarget.Id = target.Id;
                System.debug('targetsToUpdate====>'+mTarget);
                targetsToUpdate.add(mTarget);
            }
            
        }
        
        System.debug('targetsToUpdate====>'+targetsToUpdate);

        if (!targetsToUpdate.isEmpty()) {
            update targetsToUpdate;
        }

    }

    // Optional logic after batch finishes
    public void finish(Database.BatchableContext BC) {
        EYI_CollectionAchievementBatch collectionbatch = new EYI_CollectionAchievementBatch();
        Database.executeBatch(collectionbatch, 1);
    }
}