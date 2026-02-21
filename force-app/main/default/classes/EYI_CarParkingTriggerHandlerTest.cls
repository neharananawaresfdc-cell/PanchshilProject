@isTest
public class EYI_CarParkingTriggerHandlerTest {

    @isTest
    static void testHandleBeforeUpdate_FieldChangedAndFutureCallout() {
        // Test that EYI_Is_Syc__c is set to false when EYI_Built_up_Area__c changes
        EYI_Project__c proj = new EYI_Project__c(Name='Test Project', EYI_Project_Code__c='P001');
        insert proj;

        EYI_Tower__c tower = new EYI_Tower__c(Name='Tower 1', EYI_Project_Name__c=proj.Id);
        insert tower;
		
       	EYI_Inventory__c inv = new EYI_Inventory__c(
    		Name = 'Test Inventory',
    		EYI_Inventory_Number__c = 'INV-TEST-001'
		);
		insert inv;
        
        EYI_Car_Park_Master__c carPark = new EYI_Car_Park_Master__c(
            EYI_Built_up_Area__c = 500,
            EYI_Is_Syc__c = true,
            EYI_Parking_Number__c = 'P1',
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Inventory__c = inv.Id
            // Remove EYI_Rate_List__c and EYI_Parking_Type__c unless you confirm their correct API names and types
        );
        insert carPark;
		
        Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock());
        
        Test.startTest();
        carPark.EYI_Built_up_Area__c = 600;
        update carPark;
        Test.stopTest();

        EYI_Car_Park_Master__c updated = [
            SELECT EYI_Is_Syc__c FROM EYI_Car_Park_Master__c WHERE Id = :carPark.Id
        ];
        System.assertEquals(false, updated.EYI_Is_Syc__c, 'EYI_Is_Syc__c should be set to false when area changes');
    }

    @isTest
    static void testHandleBeforeUpdate_MultipleRecords_NoFutureCallout() {
        // Test that multiple records are handled correctly
        EYI_Project__c proj1 = new EYI_Project__c(Name='Test Project 1', EYI_Project_Code__c='P002');
        EYI_Project__c proj2 = new EYI_Project__c(Name='Test Project 2', EYI_Project_Code__c='P003');
        insert new List<EYI_Project__c>{proj1, proj2};

        EYI_Tower__c tower1 = new EYI_Tower__c(Name='Tower 1', EYI_Project_Name__c=proj1.Id);
        EYI_Tower__c tower2 = new EYI_Tower__c(Name='Tower 2', EYI_Project_Name__c=proj2.Id);
        insert new List<EYI_Tower__c>{tower1, tower2};

        EYI_Inventory__c inv1 = new EYI_Inventory__c(
    		Name = 'Test Inv 1',
    		EYI_Inventory_Number__c = 'INV-MULTI-1'
		);

        EYI_Inventory__c inv2 = new EYI_Inventory__c(
    		Name = 'Test Inv 2',
    		EYI_Inventory_Number__c = 'INV-MULTI-2'
		);

        insert new List<EYI_Inventory__c>{inv1, inv2};
        
        EYI_Car_Park_Master__c carPark1 = new EYI_Car_Park_Master__c(
            EYI_Built_up_Area__c = 300, EYI_Is_Syc__c = true, EYI_Parking_Number__c = 'P2', EYI_Project__c = proj1.Id, EYI_Tower__c = tower1.Id, EYI_Inventory__c = inv1.Id
        );
        EYI_Car_Park_Master__c carPark2 = new EYI_Car_Park_Master__c(
            EYI_Built_up_Area__c = 400, EYI_Is_Syc__c = true, EYI_Parking_Number__c = 'P3', EYI_Project__c = proj2.Id, EYI_Tower__c = tower2.Id, EYI_Inventory__c = inv2.Id
        );
        insert new List<EYI_Car_Park_Master__c>{carPark1, carPark2};
		
        Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock());
            
        Test.startTest();
        carPark1.EYI_Built_up_Area__c = 310;
        carPark2.EYI_Built_up_Area__c = 420;
        update new List<EYI_Car_Park_Master__c>{carPark1, carPark2};
        Test.stopTest();

        List<EYI_Car_Park_Master__c> updated = [
            SELECT EYI_Is_Syc__c FROM EYI_Car_Park_Master__c WHERE Id IN :new List<Id>{carPark1.Id, carPark2.Id}
        ];
        for (EYI_Car_Park_Master__c cp : updated) {
            System.assertEquals(false, cp.EYI_Is_Syc__c, 'EYI_Is_Syc__c should be set to false for all updated records');
        }
    }

    @isTest
    static void testNoFieldChange_IsSycRemainsTrue() {
        // Test that EYI_Is_Syc__c remains true if EYI_Built_up_Area__c is not changed
    	EYI_Project__c proj = new EYI_Project__c(Name='Test Project N', EYI_Project_Code__c='P00N');
   		insert proj;

    	EYI_Tower__c tower = new EYI_Tower__c(Name='Tower N', EYI_Project_Name__c=proj.Id);
    	insert tower;

    	EYI_Inventory__c inv = new EYI_Inventory__c(
        	Name = 'Test Inventory',
        	EYI_Inventory_Number__c = 'INV-TEST-007'
    	);
    	insert inv;

    	EYI_Car_Park_Master__c carPark = new EYI_Car_Park_Master__c(
        	EYI_Built_up_Area__c = 950,
        	EYI_Is_Syc__c = true,
        	EYI_Parking_Number__c = 'P7',
        	EYI_Project__c = proj.Id,
        	EYI_Tower__c = tower.Id,
        	EYI_Inventory__c = inv.Id // <-- THIS LINE FIXES THE ERROR
    	);
    	insert carPark;
		Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock());
        Test.startTest();
        update carPark;
        Test.stopTest();

        EYI_Car_Park_Master__c updated = [
            SELECT EYI_Is_Syc__c FROM EYI_Car_Park_Master__c WHERE Id = :carPark.Id
        ];
        System.assertEquals(true, updated.EYI_Is_Syc__c, 'EYI_Is_Syc__c should remain true if area does not change');
    }

    @isTest
    static void testIsSycInitiallyFalse() {
        // Test that EYI_Is_Syc__c remains false if it is already false
        EYI_Project__c proj = new EYI_Project__c(Name='Test Project 4', EYI_Project_Code__c='P005');
        insert proj;

        EYI_Tower__c tower = new EYI_Tower__c(Name='Tower 4', EYI_Project_Name__c=proj.Id);
        insert tower;

        EYI_Inventory__c inv = new EYI_Inventory__c(
    		Name = 'Test Inventory',
    		EYI_Inventory_Number__c = 'INV-TEST-005'
		);
		insert inv;

		EYI_Car_Park_Master__c carPark = new EYI_Car_Park_Master__c(
    		EYI_Built_up_Area__c = 800,
    		EYI_Is_Syc__c = false,
    		EYI_Parking_Number__c = 'P5',
    		EYI_Project__c = proj.Id,
    		EYI_Tower__c = tower.Id,
    		EYI_Inventory__c = inv.Id 
		);
		insert carPark;
		Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock());
        Test.startTest();
        carPark.EYI_Built_up_Area__c = 900;
        update carPark;
        Test.stopTest();

        EYI_Car_Park_Master__c updated = [
            SELECT EYI_Is_Syc__c FROM EYI_Car_Park_Master__c WHERE Id = :carPark.Id
        ];
        System.assertEquals(false, updated.EYI_Is_Syc__c, 'EYI_Is_Syc__c should remain false if it was already false');
    }

    @isTest
    static void testInsertPath() {
        // Test that EYI_Is_Syc__c is true on insert
        EYI_Project__c proj = new EYI_Project__c(Name='Test Project 5', EYI_Project_Code__c='P006');
        insert proj;

        EYI_Tower__c tower = new EYI_Tower__c(Name='Tower 5', EYI_Project_Name__c=proj.Id);
        insert tower;

        EYI_Inventory__c inv = new EYI_Inventory__c(
    		Name = 'Test Inventory',
    		EYI_Inventory_Number__c = 'INV-TEST-006'
		);
		insert inv;
		
        Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock());
        
		EYI_Car_Park_Master__c carPark = new EYI_Car_Park_Master__c(
    		EYI_Built_up_Area__c = 900,
    		EYI_Is_Syc__c = true,
    		EYI_Parking_Number__c = 'P6',
    		EYI_Project__c = proj.Id,
	    	EYI_Tower__c = tower.Id,
    		EYI_Inventory__c = inv.Id 
		);
		insert carPark;

        EYI_Car_Park_Master__c inserted = [
            SELECT EYI_Is_Syc__c, EYI_Built_up_Area__c FROM EYI_Car_Park_Master__c WHERE Id = :carPark.Id
        ];
        System.assertEquals(true, inserted.EYI_Is_Syc__c, 'EYI_Is_Syc__c should be true on insert');
    }

    @isTest
    static void testUpdateWithSameValue() {
    	EYI_Project__c proj = new EYI_Project__c(Name='Test Project', EYI_Project_Code__c='P008');
    	insert proj;

    	EYI_Tower__c tower = new EYI_Tower__c(Name='Tower 8', EYI_Project_Name__c=proj.Id);
    	insert tower;

        EYI_Inventory__c inv = new EYI_Inventory__c(
        	Name = 'Test Inventory',
        	EYI_Inventory_Number__c = 'INV-TEST-008'
    	);
    	insert inv;
        
    	EYI_Car_Park_Master__c carPark = new EYI_Car_Park_Master__c(
        	EYI_Built_up_Area__c = 1000,
        	EYI_Is_Syc__c = true,
        	EYI_Parking_Number__c = 'P8',
        	EYI_Project__c = proj.Id,
        	EYI_Tower__c = tower.Id,
            EYI_Inventory__c = inv.Id
    	);
    	insert carPark;
        
		Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock());
        
        Test.startTest();
        carPark.EYI_Built_up_Area__c = 1000;// No actual change
        update carPark;
        Test.stopTest();

        EYI_Car_Park_Master__c updated = [
            SELECT EYI_Is_Syc__c FROM EYI_Car_Park_Master__c WHERE Id = :carPark.Id
        ];
        System.assertEquals(true, updated.EYI_Is_Syc__c, 'EYI_Is_Syc__c should remain true if value does not change');
    }
}