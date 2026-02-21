/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_EYI_Customer_Information_a1lTrigger on EYI_Customer_Information_Form__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(EYI_Customer_Information_Form__c.SObjectType);
}