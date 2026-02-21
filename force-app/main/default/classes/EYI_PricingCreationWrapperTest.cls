@isTest
private class EYI_PricingCreationWrapperTest {

    @isTest
    static void testWrapperInitialization() {
        EYI_PricingCreationWrapper wrapper = new EYI_PricingCreationWrapper();
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.I_MASTER);
        System.assertEquals(0, wrapper.I_MASTER.item.size());
    }

    @isTest
    static void testClsItemDefaultConstructor() {
        EYI_PricingCreationWrapper.cls_item item = new EYI_PricingCreationWrapper.cls_item();

        System.assertEquals('', item.KSCHL);
        System.assertEquals('', item.VKORG);
        System.assertEquals('', item.WERKS);
        System.assertEquals('', item.VTWEG);
        System.assertEquals('', item.MATNR);
        System.assertEquals(0.0, item.KBETR);
        System.assertEquals('', item.KMEIN);
        System.assertEquals('', item.KPEIN);
        System.assertEquals('', item.KRECH);
        System.assertNotEquals(null, item.DATAB);
        System.assertEquals('31-12-9999', item.DATBI);
    }

    @isTest
    static void testClsItemParameterizedConstructor() {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'PRJ001',
            EYI_SAP_Salesorg__c = '1000',
            EYI_SAP_Plant_Code__c = '1100'
        );
        insert project;

        EYI_Project_Unit__c unit = new EYI_Project_Unit__c(
            Name = 'Test Unit',
            EYI_Unit_SAP_Code__c = 'MAT001'
        );
        insert unit;

        EYI_Inventory__c inventory = new EYI_Inventory__c(
            Name = 'Test Inventory',
            EYI_Inventory_Number__c = 'INV001' // ✅ Required field included
        );
        insert inventory;

        EYI_Rate_List__c rateRecord = new EYI_Rate_List__c(
            EYI_Condition_Type__c = 'ZPR0',
            EYI_Project__c = project.Id,
            EYI_Project_Unit__c = unit.Id,
            EYI_Inventory__c = inventory.Id
        );
        insert rateRecord;

        EYI_Rate_List__c fetchedRate = [
            SELECT EYI_Condition_Type__c,
                   EYI_Project__r.EYI_SAP_Salesorg__c,
                   EYI_Project__r.EYI_SAP_Plant_Code__c,
                   EYI_Project_Unit__r.EYI_Unit_SAP_Code__c
            FROM EYI_Rate_List__c
            WHERE Id = :rateRecord.Id
            LIMIT 1
        ];

        EYI_PricingCreationWrapper.cls_item item = new EYI_PricingCreationWrapper.cls_item(fetchedRate);

        System.assertEquals('ZPR0', item.KSCHL);
        System.assertEquals('1000', item.VKORG);
        System.assertEquals('1100', item.WERKS);
        System.assertEquals('MAT001', item.MATNR);
    }
}