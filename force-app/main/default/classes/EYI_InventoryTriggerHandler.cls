/* Author: Mrinal Tripathi
* Purpose: Trigger handler for EYI_Inventory__c
* Created date: 19 Feburary 2025
*/
public class EYI_InventoryTriggerHandler {
    public static void handleBeforeUpdate(){
        Boolean IS_StatusChange = false;
        Set<Id> inventoryIds = new Set<Id> ();
        List<String> statusList = new List<String>{'Vacant', 'Refuge', 'Blocked', 'Booked', 'Hold', 'Sold', 'Possesion Given'};
            // Get the field set fields dynamically
            Set<String> fieldSetFields = new Set<String>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('EYI_Inventory__c');
        if (objType != null) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // Replace 'Your_Field_Set_API_Name' with the actual Field Set API Name
            Schema.FieldSet fieldSet = objDescribe.fieldSets.getMap().get('SAP_Inventory_Field_Set');
            
            if (fieldSet != null) {
                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    fieldSetFields.add(field.getFieldPath());
                }
            }
            Boolean hasFieldChanged = false;
            for(EYI_Inventory__c newRecord : (List<EYI_Inventory__c>)Trigger.new){
                EYI_Inventory__c oldRecord = (EYI_Inventory__c)Trigger.oldMap.get(newRecord.Id);
                
                for (String fieldName : fieldSetFields) {
                    if (oldRecord.get(fieldName) != newRecord.get(fieldName)) {
                        hasFieldChanged = true;
                        newRecord.EYI_Is_Syc__c = false;
                        break;
                    }
                }
                if (newRecord.EYI_Inventory_Status__c != oldRecord.EYI_Inventory_Status__c && statusList.contains(newRecord.EYI_Inventory_Status__c)){
                    newRecord.EYI_Is_Syc__c = false;
                    
                    hasFieldChanged = true;
                    IS_StatusChange = true;
                    
                }
                if(hasFieldChanged){
                    newRecord.EYI_Is_updated__c = true;
                    inventoryIds.add(newRecord.Id);
                }
                
            }
            if(inventoryIds.size() == 1){
                EYI_FutureCalloutClass.inventoryDataSync(inventoryIds ,IS_StatusChange);
            }
            
        }
    }
    public static void handleErrorOnOppTag(List<EYI_Inventory__c> invList, Map<Id,EYI_Inventory__c> oldInv){
        Set<Id> opportunityIds = new Set<Id>();

        // Collect Opportunity Ids from the Inventory records being inserted/updated
        for (EYI_Inventory__c inv : invList) {
            if (inv.EYI_Opportunity__c != null) {
                opportunityIds.add(inv.EYI_Opportunity__c);
            }
        }
    
        // Query Opportunities to check for existing inventory tags
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
            [SELECT Id, EYI_Inventory__c FROM Opportunity WHERE Id IN :opportunityIds]
        );
    
        // Iterate through Inventory records and check if the related Opportunity has an inventory tag
        for (EYI_Inventory__c inv : invList) {
            if(inv.EYI_Inventory_Status__c == 'Reserve' && inv.EYI_Inventory_Status__c != oldInv.get(inv.Id).EYI_Inventory_Status__c )
                {
                    inv.EYI_Reserver_Date__c = System.now();
                }
            if (inv.EYI_Opportunity__c != null && inv.EYI_Opportunity__c != oldInv.get(inv.Id).EYI_Opportunity__c) {
                Opportunity opp = opportunityMap.get(inv.EYI_Opportunity__c);
                if (opp != null && opp.EYI_Inventory__c != null ) {
                    inv.addError('The related Opportunity already has an inventory tag.');
                }
            }
        }
    }

    public static void handleUpdateInvIdOnOpp(List<EYI_Inventory__c> invList, Map<Id,EYI_Inventory__c> oldInv){
        List<Opportunity> listOpp = new List<Opportunity>();
        for(EYI_Inventory__c inv:invList){
            if(inv.EYI_Inventory_Status__c == 'Reserve' && inv.EYI_Inventory_Status__c != oldInv.get(inv.Id).EYI_Inventory_Status__c ){
                Opportunity oppRec =  new Opportunity();
                oppRec.Id =inv.EYI_Opportunity__c;
                oppRec.EYI_Inventory__c = inv.Id;
                listOpp.add(oppRec);
            }
        }
        system.debug('listOpp'+listOpp);
        update listOpp;
    }
}