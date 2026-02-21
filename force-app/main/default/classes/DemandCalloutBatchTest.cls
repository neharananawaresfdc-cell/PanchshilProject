@isTest
private class DemandCalloutBatchTest {

    // Mock for success (status 200)
    class SAPCalloutMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "n0:ZSD_DEMAND_FROM_SFResponse": { "EX_OUTPUT": { "item": { "MSGTYPE": "S", "KUNNR": "12345", "VBELN": "SO123", "MLBEZ": "USE01", "VBELN_VF": "INV456", "CUSTOM1": "X", "MESSAGE": "Success" } } } }');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock that throws exception to trigger logException
    class SAPCalloutMockFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a failed callout by throwing a system exception
            throw new CalloutException('Simulated SAP callout failure');
        }
    }


    // Method to insert common test data
    private static EYI_Demand__c createTestDemand() {
        EYI_Project__c project = new EYI_Project__c(Name = 'Project A', EYI_Project_Code__c = 'P-1001', EYI_SAP_Salesorg__c = 'ORG1');
        insert project;

        EYI_Inventory__c inventory = new EYI_Inventory__c(Name = 'Inventory A', EYI_Inventory_Number__c = 'INV001');
        insert inventory;

        EYI_Booking__c booking = new EYI_Booking__c(EYI_SAP_Sales_Order_Number__c = 'SO123');
        insert booking;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Qualification',
            EYI_Ownership_Status__c = 'Accepted',
            CloseDate = Date.today().addDays(30),
            EYI_SAP_Customer_Number__c = '12345'
        );
        insert opp;

        return new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Booking__c = booking.Id,
            EYI_Project__c = project.Id,
            EYI_Usage__c = 'USE01',
            EYI_Amount_to_be_paid__c = 5000,
            EYI_Billing_Date__c = Date.today()
        );
    }

    // ✅ Test for successful callout
    @isTest
    static void testSuccessfulCalloutLogsError() {
        Test.setMock(HttpCalloutMock.class, new SAPCalloutMockSuccess());

        EYI_Demand__c demand = createTestDemand();
        insert demand;

        Map<Id, Date> demandMap = new Map<Id, Date>{ demand.Id => Date.today() };

        Test.startTest();
        DemandCalloutBatch batch = new DemandCalloutBatch(demandMap, 'RAISE', 1);
        Database.executeBatch(batch, 1);
        Test.stopTest();

        List<CalloutLog__c> logs = [SELECT Id, Type__c FROM CalloutLog__c];
        System.assert(!logs.isEmpty(), 'Expected logs to be inserted');
        System.assertEquals('ERROR', logs[0].Type__c, 'Expected ERROR log from success case logging');
    }

    // ✅ Test for exception callout → covers logException()
    @isTest
    static void testExceptionCalloutLogsException() {
        Test.setMock(HttpCalloutMock.class, new SAPCalloutMockFailure());

        EYI_Demand__c demand = createTestDemand();
        insert demand;

        Map<Id, Date> demandMap = new Map<Id, Date>{ demand.Id => Date.today() };

        Test.startTest();
        DemandCalloutBatch batch = new DemandCalloutBatch(demandMap, 'RAISE', 1);
        Database.executeBatch(batch, 1);
        Test.stopTest();

        List<CalloutLog__c> logs = [SELECT Id, Type__c, ResponseBody__c FROM CalloutLog__c];
        System.assert(!logs.isEmpty(), 'Expected exception log to be inserted');
        System.assertEquals('EXCEPTION', logs[0].Type__c, 'Expected EXCEPTION log from thrown callout');
       // System.assert(logs[0].ResponseBody__c.contains('Simulated SAP failure'));
    }
}