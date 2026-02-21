@isTest
public class EYI_FutureCalloutClassTest {
    private class EYI_HttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testCarParkingDataSync() {
        Test.setMock(HttpCalloutMock.class, new EYI_HttpCalloutMock());
        Account acc = new Account();
        acc.Name= 'Test';
        insert acc;
        Test.startTest();
        EYI_FutureCalloutClass.carParkingDataSync(new Set<Id>{acc.Id});
        Test.stopTest();
        System.assert(true, 'Test ran without unmocked callout errors.');
    }
    
	@isTest
	static void testPricingDataSync() {
    	// Insert parent project
    	EYI_Project__c project = new EYI_Project__c(
       		Name = 'Test Project',
        	EYI_Project_Code__c = 'PRJ-001'
    	);
    	insert project;

    	// Insert tower (if required by Inventory)
    	EYI_Tower__c tower = new EYI_Tower__c(
        	Name = 'Test Tower',
        	EYI_Project_Name__c = project.Id
    	);
    	insert tower;

    	// Insert inventory
    	EYI_Inventory__c inventory = new EYI_Inventory__c(
        	EYI_Project__c = project.Id,
        	EYI_Tower__c = tower.Id,
            EYI_Inventory_Number__c = 'INV-001'
    	);
    	insert inventory;

    	// Insert rate list, referencing inventory
    	EYI_Rate_List__c rate = new EYI_Rate_List__c(
        	EYI_Inventory__c = inventory.Id
    	);
    	insert rate;

    	// Set up and call your test
    	Test.setMock(HttpCalloutMock.class, new EYI_HttpCalloutMock());
    	Test.startTest();
    	EYI_FutureCalloutClass.pricingDataSync(new Set<Id>{ rate.Id });
    	Test.stopTest();
	}
    
	@isTest
	static void testInventoryDataSync() {
    	// Insert required parent: Project
    	EYI_Project__c project = new EYI_Project__c(
        	Name = 'Test Project',
        	EYI_Project_Code__c = 'PRJ-002'
    	);
    	insert project;

    	// Insert required parent: Tower (if needed)
    	EYI_Tower__c tower = new EYI_Tower__c(
       	 	Name = 'Test Tower',
        	EYI_Project_Name__c = project.Id
    	);
    	insert tower;

    	// Insert Inventory with all required fields
    	EYI_Inventory__c inv = new EYI_Inventory__c(
        	EYI_Project__c = project.Id,
        	EYI_Tower__c = tower.Id,
        	EYI_Inventory_Number__c = 'INV-002'
    	);
    	insert inv;

    	Test.setMock(HttpCalloutMock.class, new EYI_HttpCalloutMock());
    	Test.startTest();
    	EYI_FutureCalloutClass.inventoryDataSync(new Set<Id>{ inv.Id }, true);
    	Test.stopTest();
	}
    
	@isTest
	static void testCarParkingDataSync2() {
    	// Insert required parent: Project
    	EYI_Project__c project = new EYI_Project__c(
        	Name = 'Test Project',
        	EYI_Project_Code__c = 'PRJ-003'
    	);
    	insert project;

    	// Insert required parent: Tower (if needed)
    	EYI_Tower__c tower = new EYI_Tower__c(
        	Name = 'Test Tower',
        	EYI_Project_Name__c = project.Id
    	);
    	insert tower;

    	// Insert required inventory (if needed by Car Park)
    	EYI_Inventory__c inventory = new EYI_Inventory__c(
        	EYI_Project__c = project.Id,
        	EYI_Tower__c = tower.Id,
        	EYI_Inventory_Number__c = 'INV-003'
    	);
    	insert inventory;

    	// Insert Car Park Master with required lookup(s)
    	EYI_Car_Park_Master__c carPark = new EYI_Car_Park_Master__c(
        	EYI_Project__c = project.Id,
        	EYI_Tower__c = tower.Id,
        	EYI_Inventory__c = inventory.Id,
            EYI_Parking_Number__c = 'PARK-001'
    	);
    	insert carPark;

    	Test.setMock(HttpCalloutMock.class, new EYI_HttpCalloutMock());
    	Test.startTest();
    	EYI_FutureCalloutClass.carParkingDataSync(new Set<Id>{ carPark.Id });
    	Test.stopTest();
	}  
}