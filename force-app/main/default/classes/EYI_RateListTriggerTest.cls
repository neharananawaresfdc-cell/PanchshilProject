@isTest
private class EYI_RateListTriggerTest {

    @isTest
    static void testBeforeInsertTrigger() {
        EYI_Global_Charges__c globalCharge = new EYI_Global_Charges__c(
            Name = 'Test Global Charge',
			EYI_SAP_Condition_Type__c = 'ZBP0',
            EYI_SAP_Calculation_Type__c = 'Fixed Amount'
        );
        insert globalCharge;

        EYI_Project__c project = new EYI_Project__c(Name = 'Test Project',EYI_Project_Code__c = '123456');
        insert project;

        EYI_Tower__c tower = new EYI_Tower__c(Name = 'Test Tower');
        insert tower;
        
        EYI_Inventory__c inv = new EYI_Inventory__c(Name = '1502',EYI_Active__c = true,EYI_Inventory_Number__c = '2134324');
		insert inv;
        Project_Charges__c projectCharge = new Project_Charges__c(
            EYI_Global_Charges__c = globalCharge.Id,
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_Project__c = project.Id,
            EYI_Tower__c = tower.Id,
            EYI_Active__c = true
        );
        insert projectCharge;

        EYI_Rate_List__c rateList = new EYI_Rate_List__c(
            EYI_Project__c = project.Id,
            EYI_Tower__c = tower.Id,
            EYI_Global_Charges__c = globalCharge.Id,
            EYI_Inventory__c = inv.Id
        );

        Test.startTest();
        insert rateList;
        Test.stopTest();
    }

    @isTest
    static void testBeforeUpdateTrigger() {
        // Create and insert a record
        //
        EYI_Global_Charges__c globalCharge = new EYI_Global_Charges__c(
            Name = 'Test Global Charge',
            EYI_SAP_Condition_Type__c = 'ZBP0',
            EYI_SAP_Calculation_Type__c = 'Fixed Amount'
        );
        insert globalCharge; 
        EYI_Project__c project = new EYI_Project__c(Name = 'Test Project',EYI_Project_Code__c = '123456');
        insert project;

        EYI_Tower__c tower = new EYI_Tower__c(Name = 'Test Tower');
        insert tower;
        
        EYI_Inventory__c inv = new EYI_Inventory__c(Name = '1502',EYI_Active__c = true,EYI_Inventory_Number__c = '2134324');
        insert inv;
        EYI_Rate_List__c rateList = new EYI_Rate_List__c(
			EYI_Project__c = project.Id,
            EYI_Tower__c = tower.Id,
			EYI_Inventory__c = inv.Id
            // Add any required fields that are part of the field set
        );
        insert rateList;

        // Simulate a field change
        rateList.EYI_Global_Charges__c = globalCharge.Id;

        Test.startTest();
        update rateList;
        Test.stopTest();
    }
    @isTest
    static void testAfterInsert() {
        // Prepare test data
        EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'PRJ001'
        );

        Test.startTest();
        insert proj;
        Test.stopTest();

        // You can optionally query to confirm the record was inserted
        EYI_Project__c inserted = [SELECT Id, Name FROM EYI_Project__c WHERE Id = :proj.Id];
        System.assertEquals('Test Project', inserted.Name);
    }

    @isTest
    static void testAfterUpdateWithSameProjectCode() {
        // Insert initial record
        EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'PRJ001'
        );
        insert proj;

        // Update record without changing EYI_Project_Code__c
        proj.Name = 'Updated Project Name';
        Test.startTest();
        update proj;
        Test.stopTest();

        EYI_Project__c updated = [SELECT Id, Name FROM EYI_Project__c WHERE Id = :proj.Id];
        System.assertEquals('Updated Project Name', updated.Name);
    }

    @isTest
    static void testAfterUpdateWithChangedProjectCode() {
        // Insert initial record
        EYI_Project__c proj = new EYI_Project__c(
            Name = 'Project Change Test',
            EYI_Project_Code__c = 'OLD_CODE'
        );
        insert proj;

        // Update with changed EYI_Project_Code__c — should be skipped by the trigger
        proj.EYI_Project_Code__c = 'NEW_CODE';
        proj.Name = 'Changed Code Project';
        Test.startTest();
        update proj;
        Test.stopTest();

        // Optional validation
        EYI_Project__c updated = [SELECT EYI_Project_Code__c FROM EYI_Project__c WHERE Id = :proj.Id];
        System.assertEquals('NEW_CODE', updated.EYI_Project_Code__c);
    }
}