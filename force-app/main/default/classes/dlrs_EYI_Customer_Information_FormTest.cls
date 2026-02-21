/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_EYI_Customer_Information_FormTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_EYI_Customer_Information_a1lTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new EYI_Customer_Information_Form__c());
    }
}