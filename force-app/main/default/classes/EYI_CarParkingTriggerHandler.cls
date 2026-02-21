/* Author: Mrinal Tripathi
* Purpose: Trigger handler for EYI_Car_Park_Master__c
* Created date: 19 Feburary 2025
*/
public class EYI_CarParkingTriggerHandler {
    public static void handleBeforeUpdate(){
        Set<Id> carParkingIds = new Set<Id> ();
        Map<id, EYI_Car_Park_Master__c> Oldmap = (Map<id, EYI_Car_Park_Master__c>)trigger.oldmap;
        // Get the field set fields dynamically
        Set<String> fieldSetFields = new Set<String>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('EYI_Car_Park_Master__c');
        if (objType != null) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // Replace 'Your_Field_Set_API_Name' with the actual Field Set API Name
            Schema.FieldSet fieldSet = objDescribe.fieldSets.getMap().get('SAP_Car_Park_Fields');
            
            if (fieldSet != null) {
                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    fieldSetFields.add(field.getFieldPath());
                }
            }
            for(EYI_Car_Park_Master__c newRecord : (List<EYI_Car_Park_Master__c>) Trigger.new){
                Boolean hasFieldChanged = false;
                EYI_Car_Park_Master__c oldRecord = (EYI_Car_Park_Master__c) Trigger.oldMap.get(newRecord.Id);
                for (String fieldName : fieldSetFields) {
                    if (oldRecord.get(fieldName) != newRecord.get(fieldName)) {
                        hasFieldChanged = true;
                        newRecord.EYI_Is_Syc__c = false;
                        break;
                    }
                }
                if(hasFieldChanged){
                    carParkingIds.add(newRecord.Id);
                }
                
            }
            if(carParkingIds.size() == 1){
                EYI_FutureCalloutClass.carParkingDataSync(carParkingIds);
            }
        }
    }
    public static void updateratelists(List<EYI_Car_Park_Master__c> carparks, Map<Id,EYI_Car_Park_Master__c> oldCarParkData ){
        Map<Id, List<EYI_Car_Park_Master__c>> mapOfInventoryIdToCarParks = new Map<Id, List<EYI_Car_Park_Master__c>>();

        // Iterate through the EYI_Car_Park_Master__c records
        for (EYI_Car_Park_Master__c carPark : carparks) {
            // Get the EYI_Inventory__c Id
            Id inventoryId = carPark.EYI_Inventory__c;
            if (oldCarParkData != null && oldCarParkData.size() > 0) {
                if (inventoryId == null 
                    && oldCarParkData.containsKey(carPark.Id) 
                    && oldCarParkData.get(carPark.Id) != null 
                    && oldCarParkData.get(carPark.Id).EYI_Inventory__c != null) {
                    
                    inventoryId = oldCarParkData.get(carPark.Id).EYI_Inventory__c;
                }
            }

		
            // Check if the map already contains the EYI_Inventory__c Id as a key
            if (mapOfInventoryIdToCarParks.containsKey(inventoryId)) {
                // Add the current EYI_Car_Park_Master__c record to the list of car parks associated with the EYI_Inventory__c Id
                mapOfInventoryIdToCarParks.get(inventoryId).add(carPark);
            } else {
                // Create a new list with the current EYI_Car_Park_Master__c record and put it in the map with the EYI_Inventory__c Id as the key
                mapOfInventoryIdToCarParks.put(inventoryId, new List<EYI_Car_Park_Master__c>{ carPark });
            }
        }
        Map<Id,EYI_Inventory__c> taggedInventory =  new Map<Id, EYI_Inventory__c>();
		List<EYI_Inventory__c> listInv = [Select Id, EYI_Project__c,EYI_Tower__c FROM EYI_Inventory__c WHERE Id IN :mapOfInventoryIdToCarParks.keySet()];
        for(EYI_Inventory__c inv:listInv){
            taggedInventory.put(inv.id,inv);
        }
       // Map<Id,EYI_Inventory__c> taggedInventory = new Map<Id,EYI_Inventory__c>([Select Id, EYI_Project__c,EYI_Tower__c FROM EYI_Inventory__c WHERE Id IN :mapOfInventoryIdToCarParks.keySet()]);
        List<EYI_Rate_List__c> rateLists = [
        SELECT Id, EYI_Inventory__c, EYI_Condition_Type__c, EYI_Amount__c, EYI_Pricing_Amount__c, EYI_Pricing_Percentage__c, EYI_Pricing_Quantity__c
        FROM EYI_Rate_List__c
        WHERE EYI_Inventory__c IN :mapOfInventoryIdToCarParks.keySet()];

        // Prepare a map of EYI_Inventory__c Id and a list of EYI_Rate_List__c records
        Map<Id, List<EYI_Rate_List__c>> mapOfInventoryIdToRateLists = new Map<Id, List<EYI_Rate_List__c>>();
        for (EYI_Rate_List__c rateList : rateLists) {
            Id inventoryId = rateList.EYI_Inventory__c;
            if (!mapOfInventoryIdToRateLists.containsKey(inventoryId)) {
                mapOfInventoryIdToRateLists.put(inventoryId, new List<EYI_Rate_List__c>());
            }
            mapOfInventoryIdToRateLists.get(inventoryId).add(rateList);
        }
        
        List<AggregateResult> fourwheelerresults = [
        SELECT EYI_Inventory__c, SUM(EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c) totalCarParkingCharge
        FROM EYI_Car_Park_Master__c
        WHERE EYI_Inventory__c IN :mapOfInventoryIdToCarParks.keySet() AND (EYI_SAP_Material_Description__c = 'Big Car' OR EYI_SAP_Material_Description__c = 'Small Car')
        GROUP BY EYI_Inventory__c
        ];

        // Prepare a map of EYI_Inventory__c Id and the sum of car parking charge
        Map<Id, Decimal> mapOfInventoryIdToCarParkingChargeSum = new Map<Id, Decimal>();
        for (AggregateResult result : fourwheelerresults) {
            Id inventoryId = (Id) result.get('EYI_Inventory__c');
            Decimal totalCarParkingCharge = (Decimal) result.get('totalCarParkingCharge');
            mapOfInventoryIdToCarParkingChargeSum.put(inventoryId, totalCarParkingCharge);
        }

        List<AggregateResult> twowheelerresults = [
        SELECT EYI_Inventory__c, SUM(EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c) totalCarParkingCharge
        FROM EYI_Car_Park_Master__c
        WHERE EYI_Inventory__c IN :mapOfInventoryIdToCarParks.keySet() AND EYI_SAP_Material_Description__c = 'Two Wheeler'
        GROUP BY EYI_Inventory__c
        ];

        // Prepare a map of EYI_Inventory__c Id and the sum of car parking charge
        Map<Id, Decimal> mapOfInventoryIdTotwowheelerParkingChargeSum = new Map<Id, Decimal>();
        for (AggregateResult result : twowheelerresults) {
            Id inventoryId = (Id) result.get('EYI_Inventory__c');
            Decimal totalCarParkingCharge = (Decimal) result.get('totalCarParkingCharge');
            mapOfInventoryIdTotwowheelerParkingChargeSum.put(inventoryId, totalCarParkingCharge);
        }   
        List<EYI_Rate_List__c> updatedRateLists = new List<EYI_Rate_List__c>();
        for (Id inventoryId : mapOfInventoryIdToCarParks.keySet()) {

            //EYI_Inventory__c inventory = new EYI_Inventory__c(Id = inventoryId);
            List<EYI_Rate_List__c> rateListsToProcess = mapOfInventoryIdToRateLists.get(inventoryId);
            EYI_Rate_List__c infraRL = new EYI_Rate_List__c();
            EYI_Rate_List__c twowheelerRL = new EYI_Rate_List__c();
            if(rateListsToProcess != null && !rateListsToProcess.isEmpty()) {
                for(EYI_Rate_List__c rateList : rateListsToProcess) {

                    if(rateList.EYI_Condition_Type__c != null  && rateList.EYI_Condition_Type__c == 'Infra Charges'){
                        infraRL = rateList;
                    }
                    else if(rateList.EYI_Condition_Type__c != null  && rateList.EYI_Condition_Type__c == '2 Wheeler Charges'){
                        twowheelerRL = rateList;
                    }
                }
            }
            if(infraRL.Id != null){

                Decimal sumOfParkingCharge = mapOfInventoryIdToCarParkingChargeSum.get(inventoryId);
                infraRL.EYI_Pricing_Amount__c = sumOfParkingCharge;

                updatedRateLists.add(infraRL);
            }
            else{
                if(taggedInventory.containsKey(inventoryId) && taggedInventory.get(inventoryId) != null) {
                infraRL.EYI_Inventory__c = inventoryId;
                infraRL.EYI_Condition_Type__c = 'Infra Charges';
                infraRL.EYI_Pricing_Amount__c = mapOfInventoryIdToCarParkingChargeSum.get(inventoryId);
                infraRL.EYI_Project__c = taggedInventory.get(inventoryId).EYI_Project__c;
                infraRL.EYI_Tower__c = taggedInventory.get(inventoryId).EYI_Tower__c;
                infraRL.EYI_Calculation_Type__c = 'Fixed Amount';
                infraRL.EYI_Calculation_Mode__c = 'Saleable Area';
                updatedRateLists.add(infraRL);
                }
            }
            if(twowheelerRL.Id != null){
                Decimal sumOfParkingCharge = mapOfInventoryIdTotwowheelerParkingChargeSum.get(inventoryId);
                twowheelerRL.EYI_Pricing_Amount__c = sumOfParkingCharge;

                updatedRateLists.add(twowheelerRL);
            }
            else{
                if(taggedInventory.containsKey(inventoryId) && taggedInventory.get(inventoryId) != null) {
                twowheelerRL.EYI_Inventory__c = inventoryId;
                twowheelerRL.EYI_Condition_Type__c = '2 Wheeler Charges';
                twowheelerRL.EYI_Pricing_Amount__c = mapOfInventoryIdTotwowheelerParkingChargeSum.get(inventoryId);
                twowheelerRL.EYI_Project__c = taggedInventory.get(inventoryId).EYI_Project__c;
                twowheelerRL.EYI_Tower__c = taggedInventory.get(inventoryId).EYI_Tower__c;
                twowheelerRL.EYI_Calculation_Type__c = 'Fixed Amount';
                twowheelerRL.EYI_Calculation_Mode__c = 'Saleable Area';
                updatedRateLists.add(twowheelerRL);
                }
            }
        }
        if(!updatedRateLists.isEmpty()){
            System.debug(updatedRateLists.size() + ' records inserted');
            System.debug(updatedRateLists);
            upsert updatedRateLists;
        }
    }
}