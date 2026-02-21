/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_EYI_Car_Parking_ChargeTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_EYI_Car_Parking_ChargeTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new EYI_Car_Parking_Charge__c());
    }
}