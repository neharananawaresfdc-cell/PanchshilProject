/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_EYI_Car_Park_MasterTrigger on EYI_Car_Park_Master__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(EYI_Car_Park_Master__c.SObjectType);
}