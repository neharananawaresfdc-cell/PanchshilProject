@isTest
private class EYI_PricingCalloutTest {
    
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"TYPE":"S","ID":"123","NUMBER":1,"n0:ZSD_CREATE_PRICE_FROM_SFResponse":{"E_RETURN":{"item":{"TYPE":"A","MESSAGE":"Success"}}}}');
            return res;
        }
    }
    
    class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"TYPE":"S","ID":"123","NUMBER":1,"n0:ZSD_CREATE_PRICE_FROM_SFResponse":{"ABC":{"item":{"TYPE":"S","MESSAGE":"Success"}}}}');
            return res;
        }
    }
    
    class MockHttpResponseGenerator2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
			res.setBody('{"TYPE":"S","ID":"123","NUMBER":1,"n0:ZSD_CREATE_PRICE_FROM_SFResponse":{"E_RETURN":{"item":[{"TYPE":"E","MESSAGE":"Error 1"},{"TYPE":"W","MESSAGE":"Warning 1"},{"TYPE":"S","MESSAGE":"Success 1"}]}}}');
            return res;
        }
    }
    
    class MockHttpResponseGenerator3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"TYPE":"S","ID":"123","NUMBER":1,"n0:ZSD_CREATE_PRICE_FROM_SFResponse":{"E_RETURN":{"item":[{"TYPE":"E","MESSAGE":"Some error message"}]}}}');
            return res;
        }
    }
    
    public static String testData(){
        EYI_Project__c proj = new EYI_Project__c(Name='Test Balewadi', EYI_SAP_Salesorg__c='1000', EYI_SAP_Plant_Code__c='P001', EYI_Project_Code__c = '123', EYI_Stamp_Duty__c= 133);
        insert proj;

        EYI_Tower__c tower = new EYI_Tower__c(Name='Test Tower', EYI_SAP_Plant_ID__c='PL01');
        insert tower;

        EYI_Inventory__c inv = new EYI_Inventory__c(Name='Inventory', EYI_Inventory_Number__c='MAT001', EYI_SAP_Material_Code__c='M123');
        insert inv;

        EYI_Global_Charges__c gcharge = new EYI_Global_Charges__c(
            Name = 'Test',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'TEst'
        );
        insert gcharge;
        
        Project_Charges__c projectCharge = new Project_Charges__c(
        	Name = 'Test1234',
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Global_Charges__c = gcharge.id,
            EYI_Project__c = proj.id,
            EYI_Tower__c = tower.id,
            EYI_Active__c = true,
            EYI_Charge_Type__c = 'Pricing Charges'
        );
		insert projectCharge;
        
        EYI_Rate_List__c rate = new EYI_Rate_List__c(
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Inventory__c = inv.Id,
            EYI_Condition_Type__c = 'Brokerage',
            EYI_Distruibution_Channel__c = 'Residential Sales',
            EYI_Calculation_Type__c = 'Fixed Amount',
            EYI_Pricing_Amount__c = 500,
            EYI_is_Sync_SAP__c = false,
            EYI_Global_Charges__c = gcharge.Id
        );
        insert rate;
        
        
        // Insert field mapping
        insert new SAP_SF_Field_Map__c(Name='Test123',SF_Field_Name__c='EYI_Condition_Type__c', SF_Value__c='Brokerage', SAP_Value__c='COND1');
        insert new SAP_SF_Field_Map__c(Name='Test1234',SF_Field_Name__c='EYI_Distruibution_Channel__c', SF_Value__c='Residential Sales', SAP_Value__c='CHN1');
        insert new SAP_SF_Field_Map__c(Name='Test1235',SF_Field_Name__c='EYI_Calculation_Type__c', SF_Value__c='Fixed Amount', SAP_Value__c='FA');
		
        return tower.id;
    }

    @isTest
    static void testPricingDataSyncWithTower() {
        String towerId = testData();
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(towerId);
        Test.stopTest();

        System.assertEquals('S', msg.type);
        System.assert(msg.message.contains('Pricing Synced'));
    }
    
    @isTest
    static void testPricingDataSyncWithTower1() {
        String towerId = testData();
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());        
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(towerId);
        Test.stopTest();

        System.assertEquals('S', msg.type);
        System.assert(msg.message.contains('Pricing Synced'));
    }
    
    @isTest
    static void testPricingDataSyncWithTower2() {
        String towerId = testData();
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());        
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(towerId);
        Test.stopTest();

        System.assertEquals('S', msg.type);
        System.assert(msg.message.contains('Pricing Synced'));
    }
    
    @isTest
    static void testPricingDataSyncWithTower3() {
        String towerId = testData();
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());        
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(towerId);
        Test.stopTest();

        System.assertEquals('S', msg.type);
        System.assert(msg.message.contains('Pricing Synced'));
    }
    
    @isTest
    static void testPricingDataSyncWithTower4() {
        String towerId = testData();
		EYI_Project__c project = [SELECT Id, Name FROM EYI_Project__c WHERE Name =: 'Test Balewadi' AND EYI_SAP_Salesorg__c =:'1000' LIMIT 1];
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());        
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(project.id);
        Test.stopTest();

        System.assertEquals('S', msg.type);
        System.assert(msg.message.contains('Pricing Synced'));
    }
    
    @isTest
    static void testPricingDataSyncWithTower5() {
        String towerId = testData();
		EYI_Inventory__c inventory = [SELECT Id, Name FROM EYI_Inventory__c WHERE Name =: 'Inventory' AND EYI_Inventory_Number__c =:'MAT001' LIMIT 1];
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());        
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(inventory.id);
        Test.stopTest();
    }
    
    @isTest
    static void processPricingRecordsTest(){
        String towerId = testData();
        EYI_Rate_List__c rate = [SELECT Id FROM EYI_Rate_List__c WHERE EYI_Tower__c = :towerId LIMIT 1];
        List<EYI_Rate_List__c> rt = new List<EYI_Rate_List__c>	();
        rt.add(rate);
        Test.startTest();
        EYI_PricingCallout.processPricingRecords(rt, true);
        Test.stopTest();
    }
    

    @isTest
    static void testPricingDataSyncWithNullId() {
        Test.startTest();
        EYI_PricingCallout.lwcMessage msg = EYI_PricingCallout.pricingDataSync(null);
        Test.stopTest();

        System.assertEquals('E', msg.type);
        System.assertEquals('Record Id Missing', msg.message);
    }
    
    @isTest
    public static void getSyncValueTest(){
        String towerID = testData();
		EYI_Project__c project = [SELECT Id, Name FROM EYI_Project__c WHERE Name =: 'Test Balewadi' AND EYI_SAP_Salesorg__c =:'1000' LIMIT 1];
        Test.startTest();
        EYI_PricingCallout.getSyncValue(project.Id, 'Pricing');
        Test.stopTest();
    }
    
    @isTest
    public static void getSyncValueTest1(){
        String towerID = testData();
		EYI_Project__c project = [SELECT Id, Name FROM EYI_Project__c WHERE Name =: 'Test Balewadi' AND EYI_SAP_Salesorg__c =:'1000' LIMIT 1];
		EYI_Inventory__c inventory = [SELECT Id, Name FROM EYI_Inventory__c WHERE Name =: 'Inventory' AND EYI_Inventory_Number__c =:'MAT001' LIMIT 1];
        inventory.EYI_Is_Syc__c = false;
        inventory.EYI_Project__c = project.Id;
        update inventory;
        Test.startTest();
        EYI_PricingCallout.getSyncValue(project.Id, 'Inventory');
        Test.stopTest();
    }
    
    @isTest
    public static void getSyncValueTest2(){
        String towerID = testData();
    EYI_Project__c project = [SELECT Id, Name FROM EYI_Project__c WHERE Name =: 'Test Balewadi' AND EYI_SAP_Salesorg__c =:'1000' LIMIT 1];
    EYI_Tower__c tower = [SELECT Id FROM EYI_Tower__c WHERE Name = 'Test Tower' LIMIT 1];
    
    EYI_Car_Park_Master__c cpm = new EYI_Car_Park_Master__c(
        EYI_Is_Syc__c = false,
        EYI_Parking_Number__c = 'C130C09014',
        EYI_Project__c = project.id,
        EYI_Tower__c = tower.id
    );
    
    Test.startTest();
    try {
        insert cpm;
    } catch (DmlException e) {
        // Handle potential trigger errors gracefully in test context
        System.debug('Car park insert failed: ' + e.getMessage());
    }
    EYI_PricingCallout.getSyncValue(project.Id, '');
    Test.stopTest();
}
}