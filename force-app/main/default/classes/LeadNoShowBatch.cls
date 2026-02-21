global class LeadNoShowBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Get all Leads with a past Proposed Visit Date and not marked as Visit Done
        return Database.getQueryLocator([
            SELECT Id, EYI_Lead_Status__c, EYI_Site_Visit_Date__c
            FROM EYI_Lead_Enquiry__c
            WHERE EYI_Site_Visit_Date__c < TODAY
            AND EYI_Lead_Status__c = 'Visit Confirmed' 
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
     system.debug('scope'+scope);   
        List<EYI_Lead_Enquiry__c> leadsToUpdate = new List<EYI_Lead_Enquiry__c>();

        for (SObject s : scope) {
            EYI_Lead_Enquiry__c l = (EYI_Lead_Enquiry__c) s;
            l.EYI_Lead_Status__c = 'No Show';
            l.EYI_AutomationBypassDatetime__c = System.now();
            leadsToUpdate.add(l);
        }
		system.debug('leadsToUpdate'+leadsToUpdate);   
        if (!leadsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(leadsToUpdate, false); // false = partial update allowed
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Failed to update record: ' + leadsToUpdate[i].Id + ' Error: ' + err.getMessage());
                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optional: Add logic like sending notification or logging
        System.debug('LeadNoShowBatch finished running.');
    }
}