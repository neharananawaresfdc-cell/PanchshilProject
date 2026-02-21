trigger EYI_InventoryTrigger on EYI_Inventory__c (after Update,before Update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_InventoryTrigger').EYI_Active__c){
        if(Trigger.IsBefore && Trigger.IsUpdate){
            EYI_InventoryTriggerHandler.handleBeforeUpdate();
           EYI_InventoryTriggerHandler.handleErrorOnOppTag(trigger.new,Trigger.oldMap);
        }
        if(Trigger.IsAfter && Trigger.IsUpdate){
            EYI_InventoryTriggerHandler.handleUpdateInvIdOnOpp(trigger.new, Trigger.oldMap);
        }
    }
}