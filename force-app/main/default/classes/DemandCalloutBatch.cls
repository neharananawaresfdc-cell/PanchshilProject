public class DemandCalloutBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private Map<Id, Date> demandDataMap;
    private String action;
    private Integer chunkSize;

    public DemandCalloutBatch(Map<Id, Date> inputDemandMap, String actionType, Integer chunkSizeSetting) {
        this.demandDataMap = inputDemandMap;
        this.action = actionType;
        this.chunkSize = chunkSizeSetting;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id FROM EYI_Demand__c WHERE Id IN :demandDataMap.keySet()
        ]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {

        List<Id> demandIds = new List<Id>();
        for (SObject s : scope) {
            demandIds.add((Id) s.get('Id'));
        }

        List<EYI_Demand__c> demands = [
            SELECT Id, EYI_Billing_Date__c, EYI_Opportunity__r.EYI_Distribution_Channel__c,
                   EYI_IsOtherChargeDemand__c, EYI_SAP_Demand_Number__c, EYI_Demand_Cancellation_Number__c,
                   EYI_Opportunity__r.EYI_SAP_Customer_Number__c, EYI_Booking__r.EYI_SAP_Sales_Order_Number__c,
                   EYI_Project__r.EYI_SAP_Salesorg__c, EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c,
                   EYI_Actual_Date__c, EYI_Amount_to_be_paid__c, EYI_Usage__c, EYI_Usage_Description__c,
                   EYI_SAP_Milestone_Code__c
            FROM EYI_Demand__c WHERE Id IN :demandIds
        ];

        Map<String, Id> chunkKeyMap = new Map<String, Id>();
        for (EYI_Demand__c demand : demands) {
            String key =
                (demand.EYI_Opportunity__r != null && demand.EYI_Opportunity__r.EYI_SAP_Customer_Number__c != null
                    ? demand.EYI_Opportunity__r.EYI_SAP_Customer_Number__c : '') +
                (demand.EYI_Booking__r != null && demand.EYI_Booking__r.EYI_SAP_Sales_Order_Number__c != null
                    ? demand.EYI_Booking__r.EYI_SAP_Sales_Order_Number__c : '') +
                (demand.EYI_Usage__c != null ? demand.EYI_Usage__c : '');
            chunkKeyMap.put(key, demand.Id);
        }

        try {
            HttpResponse res = EY_SAP_Gateway.blockDemandCall(demandDataMap, demands, action);
            system.debug('Status Code ==> '+res.getStatusCode());
            system.debug('Body ==> '+res.getBody());
            // Check for success)
            if (res != null && res.getStatusCode() == 200) {
                EYI_InventoryMatrixController.ParsedItemWrapper wrapper =
                    EYI_InventoryMatrixController.extractTypesFromResponse(res.getBody(), action);

                System.debug('>>> SAP Success: Parsed Message — ' + wrapper.message);

                if (!chunkKeyMap.isEmpty()) {
                    EYI_InventoryMatrixController.updateDemands(chunkKeyMap, demandDataMap, wrapper.parsedItems);
                    logHttpFailure(demands, res, 'SAP call returned 200');

                }
            } else {
                logHttpFailure(demands, res, 'SAP call returned non-200');
            }

        } catch (Exception ex) {
            logException(demands, ex);
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('>>> BATCH FINISHED');
    }

    private void logHttpFailure(List<EYI_Demand__c> demands, HttpResponse res, String reason) {
        List<CalloutLog__c> logs = new List<CalloutLog__c>();
        for (EYI_Demand__c d : demands) {
            logs.add(new CalloutLog__c(
                Endpoint__c = 'SAP Demand API',
                RequestBody__c = 'Records: ' + demands.size(),
                ResponseBody__c = res != null ? res.getBody() : 'null response',
                Type__c = 'ERROR',
                HttpStatusCode__c = res != null ? res.getStatusCode() : 0,
                //Description__c = reason + ' | ID: ' + d.Id,
                RequestTime__c = System.now(),
                ResponseTime__c = System.now()
            ));
        }
        insert logs;
    }

    private void logException(List<EYI_Demand__c> demands, Exception ex) {
        List<CalloutLog__c> logs = new List<CalloutLog__c>();
        for (EYI_Demand__c d : demands) {
            logs.add(new CalloutLog__c(
                Endpoint__c = 'SAP Demand API',
                RequestBody__c = 'Records: ' + demands.size(),
                ResponseBody__c = ex.getMessage(),
                Type__c = 'EXCEPTION',
                HttpStatusCode__c = 0,
                //Description__c = 'Line: ' + ex.getLineNumber() + ' | ID: ' + d.Id,
                RequestTime__c = System.now(),
                ResponseTime__c = System.now()
            ));
        }
        insert logs;
    }
}