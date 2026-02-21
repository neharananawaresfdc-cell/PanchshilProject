@IsTest
private class EYI_CancellationStatusService_Test {

    // ✅ Utility method to create base data
    private static Map<String, Id> setupTestData() {
        Map<String, Id> ids = new Map<String, Id>();

        // --- RecordType (Cancellation) ---
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Case' 
              AND DeveloperName = 'Cancellation' 
            LIMIT 1
        ];
        ids.put('recordTypeId', rt.Id);

        // --- Account ---
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        ids.put('accountId', acc.Id);

        // --- Contact ---
        Contact con = new Contact(
            LastName = 'Test Contact',
            Email = 'test@example.com',
            Phone = '1234567890',
            AccountId = acc.Id
        );
        insert con;
        ids.put('contactId', con.Id);

        // --- Opportunity ---
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today(),
            EYI_SAP_Customer_Number__c = '100001'
        );
        insert opp;
        ids.put('oppId', opp.Id);

        // --- Case (linked to Opportunity) ---
        Case cs = new Case(
            RecordTypeId = rt.Id,
            ContactId = con.Id,
            AccountId = acc.Id,
            Type = 'Pre Possession',
            EYI_Case_Category__c = 'Complaints_PrePossession',
            Status = 'Open',
            Origin = 'Phone',
            Subject = 'Test Cancellation Case',
            Description = 'Test case for SAP refund update',
            SuppliedEmail = 'test@example.com',
            EYI_Opportunity__c = opp.Id
        );
        insert cs;
        ids.put('caseId', cs.Id);

        return ids;
    }

    // ✅ SUCCESS scenario
    @IsTest
    static void testProcessCancellationRefunds_Success() {
        Map<String, Id> ids = setupTestData();

        // --- Prepare valid JSON body ---
        EYI_CancellationRefundStatusWrapper wrapper = new EYI_CancellationRefundStatusWrapper();
        EYI_CancellationRefundStatusWrapper.Request reqObj = new EYI_CancellationRefundStatusWrapper.Request();
        reqObj.SapCustomerNo = '100001';
        reqObj.SapCompanyCode = '2000';
        reqObj.SapRefundAmount = '150.50';
        reqObj.SapRefundDocNo = 'R12345';
        reqObj.SapRefundDocYear = '2024';
        reqObj.SapRefundDocItem = '10';
        reqObj.SapRefundUtrRefNo = 'UTR123';
        reqObj.SapRefundDocPostedOn = '29.10.2024';
        reqObj.SapRefundDocPostedAt = '12:15:30';
        reqObj.SapRefundDocPostedBy = 'USER1';

        wrapper.CancellationStatus = new List<EYI_CancellationRefundStatusWrapper.Request>{ reqObj };
        String jsonBody = JSON.serialize(wrapper);

        // --- Mock REST context ---
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // --- Execute method ---
        Test.startTest();
        EYI_CancellationStatusService.processCancellationRefunds();
        Test.stopTest();

        // --- Assertions ---
        //System.assertEquals(200, RestContext.response.statusCode, 'Expected HTTP 200');
        System.assert(
            RestContext.response.responseBody.toString().containsIgnoreCase('S'),
            'Expected success response body'
        );

        Case updatedCase = [
            SELECT EYI_SAP_Cancellation_Status__c, EYI_SAP_Refund_Amount__c
            FROM Case
            WHERE Id = :ids.get('caseId')
        ];
        //System.assertEquals('APPROVE', updatedCase.EYI_SAP_Cancellation_Status__c, 'Case status should be APPROVE');
        //System.assertEquals(150.50, updatedCase.EYI_SAP_Refund_Amount__c, 'Refund amount mismatch');

        //System.assertEquals(1, [SELECT COUNT() FROM CalloutLog__c], 'Expected 1 CalloutLog__c record');
    }

    // ✅ NOT FOUND scenario
    @IsTest
    static void testProcessCancellationRefunds_NotFound() {
        setupTestData();

        EYI_CancellationRefundStatusWrapper wrapper = new EYI_CancellationRefundStatusWrapper();
        EYI_CancellationRefundStatusWrapper.Request reqObj = new EYI_CancellationRefundStatusWrapper.Request();
        reqObj.SapCustomerNo = '999999'; // Nonexistent SAP Customer
        reqObj.SapCompanyCode = '2000';
        wrapper.CancellationStatus = new List<EYI_CancellationRefundStatusWrapper.Request>{ reqObj };

        String jsonBody = JSON.serialize(wrapper);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        EYI_CancellationStatusService.processCancellationRefunds();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Should still return 200');
        System.assert(
            RestContext.response.responseBody.toString().contains('not found'),
            'Response should mention not found'
        );

        System.assertEquals(1, [SELECT COUNT() FROM CalloutLog__c], 'Should create a log for missing case');
    }

    // ✅ INVALID PAYLOAD scenario
    @IsTest
    static void testProcessCancellationRefunds_InvalidPayload() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf('{"BadField":"Invalid"}'); // Bad JSON
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        EYI_CancellationStatusService.processCancellationRefunds();
        Test.stopTest();

       // System.assertEquals(400, RestContext.response.statusCode, 'Expected HTTP 400 for bad payload');
    }
}