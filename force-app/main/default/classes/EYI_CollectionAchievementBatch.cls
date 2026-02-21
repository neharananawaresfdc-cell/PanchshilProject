global with sharing class EYI_CollectionAchievementBatch implements Database.Batchable<SObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([ SELECT Id, Name,EYI_RM__c,EYI_Project__c,EYI_Tower__c,EYI_Month__c 
        FROM Monthly_Target__c WHERE CreatedDate = THIS_MONTH  ]);
    }
    global void execute(Database.BatchableContext BC, List<Monthly_Target__c> monthlyTargetRec) {
        Set<Id> towerIdSet = new Set<Id>();
        Map<Id,Monthly_Target__c> monthlyTargetMap = new Map<Id,Monthly_Target__c>();
        Map<String,EYI_Collection_Achievement__c> monthlyTargetToPaymentReceiptMap = new Map<String,EYI_Collection_Achievement__c>();
        Map<Id,double> onetoFifteenDemandMap = new Map<Id,double>();
        Map<Id, Double> outStandingAmountMap = new Map<Id, Double>();
        Set<Id> oppIdSet = new Set<Id>();
        Date firstDayOfMonth = Date.today().toStartOfMonth();
        Date lastDayOf15Days = firstDayOfMonth.addDays(14);
        List<Monthly_Target__c> monthlyTargetList = new List<Monthly_Target__c>();
        for(Monthly_Target__c monthlyTarget : monthlyTargetRec){
            towerIdSet.add(monthlyTarget.EYI_Tower__c);
            monthlyTargetMap.put(monthlyTarget.EYI_Tower__c,monthlyTarget);
            Monthly_Target__c mt = new Monthly_Target__c();
            mt.Id = monthlyTarget.Id;
            mt.EYI_Status__c='Closed';
            monthlyTargetList.add(mt);
        }
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<EYI_Payment_Receipt__c> paymentReceiptList =[SELECT Id,EYI_Opportunity__c,EYI_Payment_Status__c,
            EYI_Opportunity__r.EYI_Collectible_Status__c,EYI_Opportunity__r.EYI_Project_Tower_Enquired__c,
            EYI_Amount__c,EYI_Opportunity__r.EYI_Inventory__c,EYI_Opportunity__r.EYI_Project_Enquired__c
            FROM EYI_Payment_Receipt__c 
            WHERE CreatedDate = THIS_MONTH 
            AND EYI_Opportunity__r.EYI_Collectible_Status__c ='Collectible'
            AND EYI_Opportunity__r.EYI_Project_Tower_Enquired__c IN :towerIdSet];

            for (EYI_Payment_Receipt__c paymentReceipt : paymentReceiptList) {
                oppIdSet.add(paymentReceipt.EYI_Opportunity__c);
            }

            List<EYI_Demand__c> allRelevantDemands = [
                SELECT Id, EYI_Tower__c, EYI_Demand_Status__c, EYI_Demand_Payment_Status__c,
                    EYI_Opportunity__c, EYI_Opportunity__r.EYI_Collectible_Status__c,
                    EYI_Actual_Date__c, EYI_Collectible_Status__c, EYI_Billing_Date__c,
                    EYI_Amount_to_be_paid__c 
                FROM EYI_Demand__c
                WHERE EYI_Amount_to_be_paid__c != null
                AND EYI_Opportunity__r.EYI_Collectible_Status__c = 'Collectible'
                AND EYI_Demand_Status__c = 'Open'
                AND (EYI_Billing_Date__c <= :lastDayOf15Days OR EYI_Actual_Date__c <= :lastDayOf15Days)
            ];
            for (EYI_Demand__c demand : allRelevantDemands) {
                Id oppId = demand.EYI_Opportunity__c;
                if (oppId == null || demand.EYI_Amount_to_be_paid__c == null) continue;
                Double currentTotal = onetoFifteenDemandMap.get(oppId);
                if (currentTotal == null) currentTotal = 0;
                onetoFifteenDemandMap.put(oppId, currentTotal + demand.EYI_Amount_to_be_paid__c);
            }
            
            List<EYI_SAP_Report__c> allRelevantSAPReport = [
                SELECT Id, Name, EYI_Outstanding_Amount__c, Opportunity__c,
                    Opportunity__r.Name, RecordType.Name,
                    EYI_Sales_Org__c, EYI_Plant__c, Opportunity__r.EYI_Collectible_Status__c
                FROM EYI_SAP_Report__c 
                WHERE Opportunity__r.EYI_Collectible_Status__c = 'Collectible'
                AND RecordType.Name = 'SAP Outstanding Report'
            ];
            for (EYI_SAP_Report__c sap : allRelevantSAPReport) {
                Id oppId = sap.Opportunity__c;
                if (oppId == null || sap.EYI_Outstanding_Amount__c == null) continue;
                Double current = outStandingAmountMap.get(oppId);
                if (current == null) current = 0;
                outStandingAmountMap.put(oppId, current + sap.EYI_Outstanding_Amount__c);
            }

            for (EYI_Payment_Receipt__c paymentReceipt : paymentReceiptList) {
            Id towerId = paymentReceipt.EYI_Opportunity__r.EYI_Project_Tower_Enquired__c;
            Id inventoryId = paymentReceipt.EYI_Opportunity__r.EYI_Inventory__c;

            String key = String.valueOf(towerId) + '|' + String.valueOf(inventoryId);                
            if (monthlyTargetToPaymentReceiptMap.containsKey(key)) {
                EYI_Collection_Achievement__c achievement = monthlyTargetToPaymentReceiptMap.get(key);
                if (paymentReceipt.EYI_Amount__c != null) {
                    // Safely add amount to CRM Receipt
                    if (achievement.EYI_Achievement_As_Per_CRM_Receipt__c == null) {
                        achievement.EYI_Achievement_As_Per_CRM_Receipt__c = 0;
                    }
                    achievement.EYI_Achievement_As_Per_CRM_Receipt__c += paymentReceipt.EYI_Amount__c;

                    // Safely add to Approved Receipt if status is APPROVE
                    if (paymentReceipt.EYI_Payment_Status__c == 'APPROVE') {
                        if (achievement.EYI_Achievement_Account_Approved_Receipt__c == null) {
                            achievement.EYI_Achievement_Account_Approved_Receipt__c = 0;
                        }
                        achievement.EYI_Achievement_Account_Approved_Receipt__c += paymentReceipt.EYI_Amount__c;
                    }
                }
            } else {
                EYI_Collection_Achievement__c collectionAchievement = new EYI_Collection_Achievement__c();
                collectionAchievement.EYI_Opportunity__c = paymentReceipt.EYI_Opportunity__c;
                collectionAchievement.EYI_Project__c = paymentReceipt.EYI_Opportunity__r.EYI_Project_Enquired__c;
                collectionAchievement.EYI_RM__c = null;
                collectionAchievement.EYI_Tower__c = paymentReceipt.EYI_Opportunity__r.EYI_Project_Tower_Enquired__c;
                collectionAchievement.EYI_Monthly_Target__c = monthlyTargetMap.get(paymentReceipt.EYI_Opportunity__r.EYI_Project_Tower_Enquired__c).Id;
                collectionAchievement.EYI_Unique_Key__c = key;
                String originalName = monthlyTargetMap.get(paymentReceipt.EYI_Opportunity__r.EYI_Project_Tower_Enquired__c).Name;
                String updatedName = originalName.replace('Target', 'Achievement');
                collectionAchievement.Name = updatedName;
                if(!onetoFifteenDemandMap.isEmpty()){
                    collectionAchievement.EYI_Demand_To_Be_Raised_1_15__c = onetoFifteenDemandMap.get(paymentReceipt.EYI_Opportunity__c);
                }
                if(!outStandingAmountMap.isEmpty()){
                    collectionAchievement.EY_O_s_At_The_Start_Of_Month__c = outStandingAmountMap.get(paymentReceipt.EYI_Opportunity__c);
                }
                collectionAchievement.EYI_Achievement_As_Per_CRM_Receipt__c = paymentReceipt.EYI_Amount__c;

                if (paymentReceipt.EYI_Payment_Status__c == 'APPROVE') {
                    collectionAchievement.EYI_Achievement_Account_Approved_Receipt__c = paymentReceipt.EYI_Amount__c;
                }
                monthlyTargetToPaymentReceiptMap.put(key, collectionAchievement);
            }
        }
            System.debug('monthlyTargetToPaymentReceiptMap==>'+monthlyTargetToPaymentReceiptMap.keyset());
            System.debug('monthlyTargetToPaymentReceiptMap==>'+monthlyTargetToPaymentReceiptMap.values());

        if(!monthlyTargetToPaymentReceiptMap.isEmpty()){
            upsert monthlyTargetToPaymentReceiptMap.values() EYI_Unique_Key__c;
        }
        if(!monthlyTargetList.isEmpty()){
            update monthlyTargetList;
        }
    }
    global void finish(Database.BatchableContext BC) {
    System.debug('Batch processing completed.');
    }    
    
}