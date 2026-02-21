/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_EYI_Payment_ScheduleTrigger on EYI_Payment_Schedule__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(EYI_Payment_Schedule__c.SObjectType);
}