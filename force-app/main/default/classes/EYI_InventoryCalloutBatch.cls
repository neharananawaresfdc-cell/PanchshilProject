global class EYI_InventoryCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts { 
    
    private List<EYI_Inventory__c> recordsToProcess;
    private Boolean isFromAura;
    private Boolean isPatchOperation = true;
    // Constructor to accept records when called from Aura
    global EYI_InventoryCalloutBatch(List<EYI_Inventory__c> records, Boolean isPatchOperation) {
        this.recordsToProcess = records;
        this.isFromAura = true;
        this.isPatchOperation = isPatchOperation;
    }
    // Default constructor for scheduled execution
    global EYI_InventoryCalloutBatch() {
        this.isFromAura = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (isFromAura && recordsToProcess != null && !recordsToProcess.isEmpty()) {
            return Database.getQueryLocator([SELECT Id, EYI_Project__r.EYI_SAP_Salesorg__c, EYI_OC_Received_Date__c, EYI_Project__r.EYI_SAP_Plant_Code__c,
                                                 EYI_Inventory_Number__c,EYI_SAP_Material_Type__c,EYI_SAP_Material_Description__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c,
                                                 EYI_Inventory_Type__c,EYI_UOM__c,EYI_Material_Group__c,EYI_Super_Built_up_Area__c, EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,
                                                 EYI_Carpet_Area__c,EYI_Garden_Area__c,EYI_Built_up_Area__c,EYI_Common_Area__c,EYI_Terrace_Area__c,EYI_Balcony_Area__c, EYI_Tower__r.EYI_SAP_Plant_ID__c,
                                                 EYI_Inventory_Status__c,EYI_Inventory_Floor_No__c, EYI_View_based_on_Directions__c,Configuration__c,Name, EYI_Typology__c,
                                                 EYI_View_based_on_Amenities__c ,EYI_SAP_Affordable_Type__c,EYI_SAP_Profit_Center__c, EYI_Saleable_Area__c FROM EYI_Inventory__c WHERE Id IN :recordsToProcess]);
        } else {
            Dynamic_Batch_Setting__c batchSetting = [SELECT Id, Last_Batch_Run__c FROM Dynamic_Batch_Setting__c WHERE Name = 'Inventory Sync'];
            
            return Database.getQueryLocator([SELECT id, EYI_Project__r.EYI_SAP_Salesorg__c, EYI_OC_Received_Date__c, EYI_Project__r.EYI_SAP_Plant_Code__c,
                                                 EYI_Inventory_Number__c, EYI_SAP_Material_Type__c,EYI_SAP_Material_Description__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c,
                                                 EYI_Inventory_Type__c,EYI_UOM__c,EYI_Material_Group__c,EYI_Super_Built_up_Area__c, EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c, //EYI_SAP_Plant_Code__c
                                                 EYI_Carpet_Area__c,EYI_Garden_Area__c,EYI_Built_up_Area__c,EYI_Common_Area__c,EYI_Terrace_Area__c,EYI_Balcony_Area__c, EYI_Tower__r.EYI_SAP_Plant_ID__c,
                                                 EYI_Inventory_Status__c,EYI_Inventory_Floor_No__c, EYI_View_based_on_Directions__c,Configuration__c,Name, EYI_Typology__c,
                                                 EYI_View_based_on_Amenities__c ,EYI_SAP_Affordable_Type__c,EYI_SAP_Profit_Center__c, EYI_Saleable_Area__c FROM EYI_Inventory__c 
                                             WHERE EYI_Is_Syc__c = false 
                                             AND EYI_Is_updated__c = true 
                                             AND LastModifiedDate >= :batchSetting.Last_Batch_Run__c]);
        }
    }

    global void execute(Database.BatchableContext BC, List<EYI_Inventory__c> scope) {
        EYI_InventorySyncLwcController.processInventoryRecords(scope, isPatchOperation, false);
        for (EYI_Inventory__c inv : scope) {
            inv.EYI_Is_updated__c = false;
        }   
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        if (!isFromAura) { // Only update batch setting when called from Scheduler
            Dynamic_Batch_Setting__c batchSetting = [SELECT Id, Last_Batch_Run__c FROM Dynamic_Batch_Setting__c WHERE Name = 'Inventory Sync'];
            batchSetting.Last_Batch_Run__c = System.now();
            update batchSetting;
        }
    }
}