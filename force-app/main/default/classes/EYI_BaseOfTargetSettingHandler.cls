public with sharing class EYI_BaseOfTargetSettingHandler {
    public static void calculateBasedOnDate(List<EYI_Demand__c> demandList, Map<Id,EYI_Demand__c> oldMap) {
        Set<Id> monTargetIds = new Set<Id>();
    
        Date firstHalfStart = Date.today().toStartOfMonth();
        Date firstHalfEnd = firstHalfStart.addDays(14);
        Date secondHalfStart = firstHalfEnd.addDays(1);
        Date secondHalfEnd = firstHalfStart.addMonths(1).addDays(-1);

        for(EYI_Demand__c demandObj : demandList) {
            if (demandObj.EYI_Demand_Raise_Date__c != null 
                    && oldMap != null 
                    && oldMap.containsKey(demandObj.Id) 
                    && demandObj.EYI_Demand_Raise_Date__c != oldMap.get(demandObj.Id).EYI_Demand_Raise_Date__c 
                    && demandObj.EYI_Project__c != null 
                    && demandObj.EYI_Relationship_Manager__c != null) {
                        monTargetIds.add(demandObj.EYI_Monthly_Target__c);
                }
        }
        Map<Id,Decimal> monTarMapFirstHalf = new Map<Id,Decimal>();
        Map<Id,Decimal> monTarMapSecHalf = new Map<Id,Decimal>();

        for(AggregateResult ar1 : [SELECT EYI_Monthly_Target__c, SUM(EYI_Amount_to_be_paid__c) amtRaisedinFirstHalf FROM EYI_Demand__c
                                 WHERE EYI_Monthly_Target__c IN :monTargetIds and EYI_Demand_Raise_Date__c > :firstHalfStart
                                 and EYI_Demand_Raise_Date__c < :firstHalfEnd
                                 and EYI_Demand_Raise_Date__c != null
                                 GROUP by EYI_Monthly_Target__c])
        {
            monTarMapFirstHalf.put((Id)ar1.get('EYI_Monthly_Target__c'), (Decimal)ar1.get('amtRaisedinFirstHalf'));
        }

        for(AggregateResult ar2 : [SELECT EYI_Monthly_Target__c, SUM(EYI_Amount_to_be_paid__c) amtRaisedinFirstHalf FROM EYI_Demand__c
                                 WHERE EYI_Monthly_Target__c IN :monTargetIds and EYI_Demand_Raise_Date__c > :secondHalfStart
                                 and EYI_Demand_Raise_Date__c < :secondHalfEnd
                                 GROUP by EYI_Monthly_Target__c])
        {
            monTarMapSecHalf.put((Id)ar2.get('EYI_Monthly_Target__c'), (Decimal)ar2.get('amtRaisedinFirstHalf'));
        }

        List<Monthly_Target__c> monTarToUpdate = new List<Monthly_Target__c>();
        for(Id monTarId : monTargetIds) {
            Monthly_Target__c monTarObj = new Monthly_Target__c(Id = monTarId);
            monTarObj.EYI_Demand_Raised_1st_to_15th__c = monTarMapFirstHalf.containsKey(monTarId) ? monTarMapFirstHalf.get(monTarId) : 0;
            monTarObj.EYI_Demand_Raised_16th_to_30th__c = monTarMapSecHalf.containsKey(monTarId) ? monTarMapSecHalf.get(monTarId) : 0;
            monTarObj.EYI_Overall_Outstanding_Amount1__c = monTarObj.EYI_Demand_Raised_1st_to_15th__c + monTarObj.EYI_Demand_Raised_16th_to_30th__c;
            monTarToUpdate.add(monTarObj);
        }

        try{
            if(!monTarToUpdate.isEmpty()) {
                update monTarToUpdate;
            }
        }
        catch(exception e) {
            system.debug('Error' +  e);
        }
        

    }
}