@isTest
public class EYI_InventoryCalloutBatchTest {

    // Mock class for HTTP callouts
    public class EYIHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Helper to create required test data
    private static Map<String, Id> createTestData(Boolean isSynced, Boolean isUpdated) {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'PRJ-001',
            EYI_SAP_Salesorg__c = 'SORG',
            EYI_SAP_Plant_Code__c = 'PLT1'
        );
        insert project;

        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Test Tower',
            EYI_Project_Name__c = project.Id,
            EYI_SAP_Delivery_Plant_Code__c = 'DPL1',
            EYI_SAP_Plant_ID__c = 'PID1'
        );
        insert tower;

        EYI_Inventory__c inventory = new EYI_Inventory__c(
            EYI_Project__c = project.Id,
            EYI_Tower__c = tower.Id,
            EYI_Inventory_Number__c = 'INV-001',
            EYI_Is_Syc__c = isSynced,
            EYI_Is_updated__c = isUpdated,
            Name = 'Test Inventory'
        );
        insert inventory;

        Dynamic_Batch_Setting__c batchSetting = new Dynamic_Batch_Setting__c(
            Name = 'Inventory Sync',
            Last_Batch_Run__c = System.now().addDays(-2)
        );
        insert batchSetting;

        return new Map<String, Id>{
            'projectId' => project.Id,
            'towerId' => tower.Id,
            'inventoryId' => inventory.Id
        };
    }

    @isTest
    static void testAuraBatchPatchOperation() {
        Test.setMock(HttpCalloutMock.class, new EYIHttpCalloutMock());
        createTestData(false, true);
        List<EYI_Inventory__c> invList = [SELECT Id FROM EYI_Inventory__c];
        Test.startTest();
        EYI_InventoryCalloutBatch batch = new EYI_InventoryCalloutBatch(invList, true);
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    @isTest
    static void testAuraBatchNonPatchOperation() {
        Test.setMock(HttpCalloutMock.class, new EYIHttpCalloutMock());
        createTestData(false, true);
        List<EYI_Inventory__c> invList = [SELECT Id FROM EYI_Inventory__c];
        Test.startTest();
        EYI_InventoryCalloutBatch batch = new EYI_InventoryCalloutBatch(invList, false);
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    @isTest
    static void testScheduledBatch() {
        Test.setMock(HttpCalloutMock.class, new EYIHttpCalloutMock());
        createTestData(false, true);
        Test.startTest();
        EYI_InventoryCalloutBatch batch = new EYI_InventoryCalloutBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        // Optionally verify the batch setting updated
        Dynamic_Batch_Setting__c bs = [SELECT Last_Batch_Run__c FROM Dynamic_Batch_Setting__c WHERE Name = 'Inventory Sync'];
        System.assertEquals(bs.Last_Batch_Run__c.date(), System.now().date(), 'Batch setting date should be updated');
    }

    @isTest
    static void testExecuteEmptyScope() {
        Test.setMock(HttpCalloutMock.class, new EYIHttpCalloutMock());
        Test.startTest();
        EYI_InventoryCalloutBatch batch = new EYI_InventoryCalloutBatch();
        batch.execute(null, new List<EYI_Inventory__c>());
        Test.stopTest();
    }
}