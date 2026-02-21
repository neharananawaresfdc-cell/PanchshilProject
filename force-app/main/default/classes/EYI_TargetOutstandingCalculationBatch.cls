global with sharing class EYI_TargetOutstandingCalculationBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([ SELECT Id ,EYI_Project_Tower_Enquired__c FROM Opportunity WHERE StageName 
        NOT IN ('Cancelled', 'Sales Lost')]);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
                System.debug('scope===>'+scope);

        Set<Id> oppIds = new Set<Id>();
        Map<Id, Decimal> towerToDemandSum = new Map<Id, Decimal>();
        Decimal totalDemandAmount = 0;
        List<Monthly_Target__c> targetList = new List<Monthly_Target__c>();
        for (Opportunity opp : scope) {
            oppIds.add(opp.Id);
        }
       for (AggregateResult ar : [
            SELECT EYI_Tower__c tower, SUM(EYI_Amount_to_be_paid__c) total
            FROM EYI_Demand__c
            WHERE EYI_Demand_Status__c IN ('Open', 'Demand Sent', 'Demand Raised')
                AND EYI_Demand_Payment_Status__c = 'Pending'
                AND EYI_Opportunity__c IN :oppIds
                AND EYI_Billing_Date__c = THIS_MONTH
            GROUP BY EYI_Tower__c
        ]) {
            Id towerId = (Id)ar.get('tower');
            Decimal totalAmount = (Decimal)ar.get('total');

            system.debug('ar tower =====> ' + towerId);
            system.debug('ar total =====> ' + totalAmount);

            if (totalAmount != null) {
                if (!towerToDemandSum.containsKey(towerId)) {
                    // If not present, put directly
                    towerToDemandSum.put(towerId, totalAmount);
                } else {
                    // If present, get and update (or just update)
                    Decimal existingAmount = towerToDemandSum.get(towerId); // optional use
                    towerToDemandSum.put(towerId, totalAmount); // replace or update
                }
            }
        }

                System.debug('towerToDemandSum===>'+towerToDemandSum);

        for (Monthly_Target__c target: [SELECT Id,EYI_Tower__c	 from Monthly_Target__c WHERE Createddate= THIS_MONTH]) {
                if(towerToDemandSum.containsKey(target.EYI_Tower__c)) {
                    Monthly_Target__c updateTarget = new Monthly_Target__c();
                    updateTarget.Id = target.Id;
                    updateTarget.EYI_Tower__c = target.EYI_Tower__c;
                    updateTarget.EYI_Overall_Outstanding_Amount1__c = towerToDemandSum.get(target.EYI_Tower__c);
                            System.debug('updateTarget===>'+updateTarget);

                    if(updateTarget.EYI_Overall_Outstanding_Amount1__c > 0){
                        targetList.add(updateTarget);
                    }
                } 
        }
        System.debug('targetList===>'+targetList);
        if(targetList.size()>0){
            update targetList;
        }
    }
 
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch processing completed.');
    }
}