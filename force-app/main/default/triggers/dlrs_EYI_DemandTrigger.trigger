/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_EYI_DemandTrigger on EYI_Demand__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(EYI_Demand__c.SObjectType);
    
    if(trigger.isAfter && trigger.isUpdate){
         DemandTriggerHandler.handleStatusChange(Trigger.oldMap, Trigger.newMap);
    }
}