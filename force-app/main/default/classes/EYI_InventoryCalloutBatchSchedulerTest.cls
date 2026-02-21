@isTest
public class EYI_InventoryCalloutBatchSchedulerTest {
    @isTest
    static void testScheduler() {
        Dynamic_Batch_Setting__c dbs = new Dynamic_Batch_Setting__c(
            Name = 'Inventory Sync',
            Batch_size__c = 10
        );
        insert dbs;

        EYI_Inventory__c inv = new EYI_Inventory__c(
            Name = 'Test Inventory',
            EYI_Inventory_Number__c = 'INV-001'
        );
        insert inv;

        EYI_InventoryCalloutBatchScheduler scheduler = new EYI_InventoryCalloutBatchScheduler();
        String cronExp = '0 0 0 1 1 ? 2099';

        Test.startTest();
        System.schedule('Test Inventory Batch Scheduler', cronExp, scheduler);
        Test.stopTest();
    }
}