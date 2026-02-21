global class EYI_PricingCalloutBatchJob implements Database.Batchable<sObject>,Database.AllowsCallouts { 
    
    public List<EYI_Rate_List__c> start(Database.BatchableContext BC) {
        Dynamic_Batch_Setting__c batchSetting = [Select id,Last_Batch_Run__c from Dynamic_Batch_Setting__c where name = 'Rate List Sync'];
       
        return [select id,EYI_Condition_Type__c,EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Project__r.EYI_SAP_Plant_Code__c, EYI_Pricing_Amount__c,EYI_Pricing_Percentage__c,
                                     EYI_Pricing_Quantity__c,EYI_Calculation_Type__c,EYI_Distruibution_Channel__c,
                                     EYI_Inventory__r.EYI_SAP_Material_Code__c
                                     from EYI_Rate_List__c where EYI_is_Sync_SAP__c=false AND EYI_Non_Master_Price__c=false  AND lastmodifieddate > :batchSetting.Last_Batch_Run__c]; 
    }

    // Execute method - performs the actual logic and the callout
    public void execute(Database.BatchableContext BC, List<EYI_Rate_List__c> scope) {
        EYI_PricingCallout.processPricingRecords(scope,false);
    }

    // Finish method - after all batches have been processed
    public void finish(Database.BatchableContext BC) {
       Dynamic_Batch_Setting__c batchSetting = [Select id,Last_Batch_Run__c from Dynamic_Batch_Setting__c where name = 'Rate List Sync'];
        batchSetting.Last_Batch_Run__c = System.now();
        update batchSetting;
    }

    
}