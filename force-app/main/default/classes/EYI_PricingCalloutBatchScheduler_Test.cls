@isTest
public class EYI_PricingCalloutBatchScheduler_Test {
    @isTest
    static void testExecute() {
       
        Dynamic_Batch_Setting__c setting = new Dynamic_Batch_Setting__c(
            Name = 'Rate List Sync',
            Batch_size__c = 20
        );
        insert setting;
        Test.startTest();
        EYI_PricingCalloutBatchScheduler scheduler = new EYI_PricingCalloutBatchScheduler();
        scheduler.execute(null);
        Test.stopTest();

        System.assert(true, 'Scheduler executed without error');
    }
}