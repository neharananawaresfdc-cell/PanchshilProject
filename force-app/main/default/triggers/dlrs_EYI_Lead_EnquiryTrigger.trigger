/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_EYI_Lead_EnquiryTrigger on EYI_Lead_Enquiry__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(EYI_Lead_Enquiry__c.SObjectType);
}