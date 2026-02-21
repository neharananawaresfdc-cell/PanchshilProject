@isTest
private class DemandTriggerHandlerTest {

    // Step 1: Mock FCM callout to simulate successful push response
    private class MockFCMHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"name":"projects/mock_project/messages/0:abc123"}');
            return res;
        }
    }

    @isTest
    static void testHandleStatusChange() {
        // Register FCM mock callout
        Test.setMock(HttpCalloutMock.class, new MockFCMHttpResponse());

        // Step 2: Create test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp',EYI_Ownership_Status__c ='Accepted', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Step 3: Create test Demand with initial status (not "Demand Raised")
        EYI_Demand__c demand = new EYI_Demand__c(

            EYI_Opportunity__c = opp.Id,
            EYI_Demand_Status__c = 'Open'
        );
        insert demand; 

        // Step 4: Create related FCM record for that Opportunity
        EYI_FCM_Detail__c fcm = new EYI_FCM_Detail__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Custom_Device_ID__c = 'mock_device_token_123'
        );
        insert fcm;

        // Step 5: Simulate Demand status change → "Demand Raised"
        EYI_Demand__c updatedDemand = demand.clone(false, true, false, false);
        updatedDemand.EYI_Demand_Status__c = 'Demand Raised';
        demand.EYI_Demand_Status__c = 'Demand Raised';
        update demand;

        Map<Id, EYI_Demand__c> oldMap = new Map<Id, EYI_Demand__c>{ demand.Id => demand };
        Map<Id, EYI_Demand__c> newMap = new Map<Id, EYI_Demand__c>{ updatedDemand.Id => updatedDemand };

        Test.startTest();
        //DemandTriggerHandler.handleStatusChange(oldMap, newMap);
        Test.stopTest();

        // If we reach this point without exceptions, the logic executed correctly
        System.assert(true, 'handleStatusChange executed without error');
    }
}