global class EYI_CarParkCalloutBatch implements Database.Batchable<sObject>,Database.AllowsCallouts { 
    
    private List<EYI_Car_Park_Master__c> recordsToProcess;
    private Boolean isFromAura;
    
        // Constructor to accept records when called from Aura
    global EYI_CarParkCalloutBatch(List<EYI_Car_Park_Master__c> records) {
        this.recordsToProcess = records;
        this.isFromAura = true;
    }

    // Default constructor for scheduled execution
    global EYI_CarParkCalloutBatch() {
        this.isFromAura = false;
    }
    
    public List<EYI_Car_Park_Master__c> start(Database.BatchableContext BC) {
        if (isFromAura && recordsToProcess != null && !recordsToProcess.isEmpty()) {
            return [SELECT id,Name,EYI_SAP_Material_Type__c,EYI_Material_Group__c,EYI_Tower__r.EYI_SAP_Plant_ID__c,	EYI_Base_UOM__c,EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,EYI_SAP_Material_Description__c,
                    EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Status__c,EYI_Parking_Number__c,EYI_Distruibution_Channel__c,EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_External_Material_Group__c,
                    EYI_Lab_Office__c,EYI_X_Plant_Mat_Status__c,EYI_Built_up_Area__c,EYI_Floor_Number__c,EYI_SAP_Affordable_Type__c,Configuration__c,EYI_SAP_Profit_Center__c,
                    EYI_Account_Assignment_Group__c,EYI_Sales_Unit__c,EYI_Item_Category__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c
                    from EYI_Car_Park_Master__c WHERE Id IN :recordsToProcess];
        } else{
            List<Dynamic_Batch_Setting__c> batchSettings = [Select id,Last_Batch_Run__c from Dynamic_Batch_Setting__c where name = 'Car Park Sync' LIMIT 1];
            DateTime lastRunDate = (batchSettings.isEmpty()) ? System.now().addDays(-1) : batchSettings[0].Last_Batch_Run__c;
            
            return [SELECT id,Name,EYI_SAP_Material_Type__c,EYI_Material_Group__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Base_UOM__c,EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,EYI_SAP_Material_Description__c,
                    EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Status__c,EYI_Parking_Number__c,EYI_Distruibution_Channel__c,EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_External_Material_Group__c,
                    EYI_Lab_Office__c,EYI_X_Plant_Mat_Status__c,EYI_Built_up_Area__c,EYI_Floor_Number__c,EYI_SAP_Affordable_Type__c,Configuration__c,EYI_SAP_Profit_Center__c,
                    EYI_Account_Assignment_Group__c,EYI_Sales_Unit__c,EYI_Item_Category__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c
                    from EYI_Car_Park_Master__c where EYI_Is_Syc__c=false AND lastmodifieddate > :lastRunDate]; 
        }
    }

    // Execute method - performs the actual logic and the callout
    public void execute(Database.BatchableContext BC, List<EYI_Car_Park_Master__c> scope) {
        EYI_CarParkingSyncLwcController.processCarparkingRecords(scope, true);
        
    }

    // Finish method - after all batches have been processed
    public void finish(Database.BatchableContext BC) {
        List<Dynamic_Batch_Setting__c> batchSettings = [Select id,Last_Batch_Run__c from Dynamic_Batch_Setting__c where name = 'Car Park Sync' LIMIT 1];
        
        if(!batchSettings.isEmpty()) {
            Dynamic_Batch_Setting__c batchSetting = batchSettings[0];
            batchSetting.Last_Batch_Run__c = System.now();
            update batchSetting;
        } else {
            // Create the setting if it doesn't exist
            Dynamic_Batch_Setting__c newBatchSetting = new Dynamic_Batch_Setting__c(
                Name = 'Car Park Sync',
                Last_Batch_Run__c = System.now(),
                Batch_size__c = 20
            );
            insert newBatchSetting;
        }
    }

    
}