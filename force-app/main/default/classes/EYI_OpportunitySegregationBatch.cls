global with sharing class EYI_OpportunitySegregationBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [SELECT Id, Name, StageName FROM Opportunity]
        );
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        Map<Id, Opportunity> oppUpdateMap = new Map<Id, Opportunity>();
        Map<Id, EYI_SAP_Report__c> opportunityToSAPMap = new Map<Id, EYI_SAP_Report__c>();

        for (Opportunity opp : scope) {
            opportunityIdSet.add(opp.Id);
        }

        List<EYI_SAP_Report__c> sapReports = [
            SELECT Id, Opportunity__c, EYI_Ageing_Delay_Days__c
            FROM EYI_SAP_Report__c
            WHERE Opportunity__c IN :opportunityIdSet
            AND EYI_Ageing_Delay_Days__c != NULL
        ];

        // Pick max EYI_Ageing_Delay_Days__c per opportunity
        for (EYI_SAP_Report__c report : sapReports) {
            Id oppId = report.Opportunity__c;

            if (!opportunityToSAPMap.containsKey(oppId) ||
                report.EYI_Ageing_Delay_Days__c > opportunityToSAPMap.get(oppId).EYI_Ageing_Delay_Days__c) {
                opportunityToSAPMap.put(oppId, report);
            }
        }

        // Build updated Opportunity records
        for (Id oppId : opportunityToSAPMap.keySet()) {
            EYI_SAP_Report__c report = opportunityToSAPMap.get(oppId);
            Integer delay = report.EYI_Ageing_Delay_Days__c.intValue();

            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.EYI_AutomationBypassDatetime__c = System.now();
            opp.EYI_Collection_Ageing__c = delay;

            if (delay > 60) {
                opp.EYI_Segregation__c = 'Red';
            } else if (delay > 30) {
                opp.EYI_Segregation__c = 'Amber';
            } else {
                opp.EYI_Segregation__c = 'Green';
            }

            oppUpdateMap.put(oppId, opp);
        }

        opportunityList.addAll(oppUpdateMap.values());

        if (!opportunityList.isEmpty()) {
            update opportunityList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch completed successfully.');
    }
}