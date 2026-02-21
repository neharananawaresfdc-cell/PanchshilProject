@isTest
private class EYI_PricingTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            Name = 'Test Inventory',
            EYI_Inventory_Number__c = 'INV-001',
            EYI_Saleable_Area__c = 123.456,
            EYI_RERA_Carpet_Area__c = 0
        );
        insert inventory;

        EYI_Global_Charges__c charge = new EYI_Global_Charges__c(
            Name = 'Test Charge',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'Material'
        );
        insert charge;

        List<EYI_Rate_List__c> rateList = new List<EYI_Rate_List__c>{
            // Test Case 1: Normal value with decimal
            new EYI_Rate_List__c(
                EYI_Inventory__c = inventory.Id,
                EYI_Condition_Type__c = 'Base Price',
                EYI_Calculation_Mode__c = 'Saleable Area',
                EYI_Calculation_Type__c = 'Quantity',
                EYI_Rate__c = 10,
                EYI_Pricing_Amount__c = 123,
                EYI_is_Sync_SAP__c = true,
                EYI_Global_Charges__c = charge.Id
            ),
            // Test Case 2: Amount = NULL
            new EYI_Rate_List__c(
                EYI_Inventory__c = inventory.Id,
                EYI_Pricing_Amount__c = 0,
                EYI_is_Sync_SAP__c = true,
                EYI_Global_Charges__c = charge.Id
            ),
            // Test Case 3: Amount with zero paise
            new EYI_Rate_List__c(
                EYI_Inventory__c = inventory.Id,
                EYI_Rate__c = 100,
                EYI_Calculation_Type__c = 'Fixed Amount',
                EYI_Pricing_Amount__c = 500,
                EYI_Condition_Type__c = 'Base Price',
                EYI_Calculation_Mode__c = 'Saleable Area',
                EYI_is_Sync_SAP__c = true,
                EYI_Global_Charges__c = charge.Id
            )
        };
        insert rateList;
    }

    @isTest
    static void testConvert_AllScenarios() {
        List<EYI_Rate_List__c> rates = [
            SELECT Id, Amount__c, EYI_Grand_Total_Value_in_Words__c
            FROM EYI_Rate_List__c
        ];

        Test.startTest();
        EYI_PricingTriggerHandler.convert(rates);
        Test.stopTest();

        List<EYI_Rate_List__c> updated = [
            SELECT Amount__c, EYI_Grand_Total_Value_in_Words__c
            FROM EYI_Rate_List__c
        ];

        for (EYI_Rate_List__c r : updated) {
            if (r.Amount__c == null) {
                System.assertEquals(null, r.EYI_Grand_Total_Value_in_Words__c);
            } else {
                System.assertNotEquals(null, r.EYI_Grand_Total_Value_in_Words__c);
            }
        }
    }
}