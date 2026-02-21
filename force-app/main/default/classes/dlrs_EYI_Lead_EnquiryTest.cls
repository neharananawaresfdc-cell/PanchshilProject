/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_EYI_Lead_EnquiryTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_EYI_Lead_EnquiryTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new EYI_Lead_Enquiry__c());
    }
}