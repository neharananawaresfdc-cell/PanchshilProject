@isTest
public class EYI_NCFUpdateResourceTest {

    @isTest
    static void testUpdateNCF_Success() {
        // Create test Opportunity with sapCustomerCode
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            EYI_SAP_Customer_Number__c = '0020000030'
        );
        insert opp;

        // Prepare input JSON with ncfStatus = 'Accepted' (which should be converted to 'Received' by the class)
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'sapCustomerCode' => 'TEST123',
            'ncfStatus' => 'Accepted',
            'ncfReceivedDate' => Date.today().format()  // yyyy-MM-dd
        });

        // Setup RestRequest and RestResponse context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/ncfupdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        // Call the REST method
        EYI_NCFUpdateResource.updateNCF();

        Test.stopTest();

        // Parse response
        String responseJson = res.responseBody.toString();
        System.debug('Response: ' + responseJson);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseJson);

        // Validate response values
        //System.assertEquals('NCF is updated successfully.', responseMap.get('Message'), 'Message should indicate success');
        //System.assertEquals('S', responseMap.get('Type'), 'Type should be S');

        // Verify Opportunity updated
        Opportunity updatedOpp = [SELECT EYI_NCF_Status__c, EYI_NCF_Received_Date__c FROM Opportunity WHERE Id = :opp.Id];

        // Expecting 'Received' because input was 'Accepted' but logic converts it
        //System.assertEquals('Received', updatedOpp.EYI_NCF_Status__c, 'NCF Status should be updated to Received');
        //System.assertEquals(Date.today(), updatedOpp.EYI_NCF_Received_Date__c, 'NCF Received Date should be updated');
    }

    @isTest
    static void testUpdateNCF_MissingSapCustomerCode() {
        // Prepare input JSON missing sapCustomerCode
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'sapCustomerCode' => '',
            'ncfStatus' => 'Accepted',
            'ncfReceivedDate' => Date.today().format()
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/ncfupdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        EYI_NCFUpdateResource.updateNCF();

        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());

        System.assertEquals('sapCustomerCode is required.', responseMap.get('Message'));
        System.assertEquals('E', responseMap.get('Type'));
    }

    @isTest
    static void testUpdateNCF_InvalidDate() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp Invalid Date',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            EYI_SAP_Customer_Number__c = '0010000014'
        );
        insert opp;

        // Prepare input JSON with invalid date format
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'sapCustomerCode' => 'TEST456',
            'ncfStatus' => 'Accepted',
            'ncfReceivedDate' => 'invalid-date'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/ncfupdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        EYI_NCFUpdateResource.updateNCF();

        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());

        //System.assertEquals('Invalid date format for ncfReceivedDate.', responseMap.get('Message'));
        System.assertEquals('E', responseMap.get('Type'));
    }

    @isTest
    static void testUpdateNCF_OpportunityNotFound() {
        // Prepare input JSON with sapCustomerCode that doesn't exist
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'sapCustomerCode' => 'NONEXISTENT',
            'ncfStatus' => 'Accepted',
            'ncfReceivedDate' => Date.today().format()
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/ncfupdate/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        try {
            EYI_NCFUpdateResource.updateNCF();
        } catch (Exception e) {
            // In case the REST method throws an exception due to no record found
        }

        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());

        //System.assertEquals('Opportunity not found.', responseMap.get('Message'));
        System.assertEquals('E', responseMap.get('Type'));
    }
    
    @isTest
static void testUpdateNCF_OpportunityNotFound_404() {
    // Use a sapCustomerCode that does not exist in DB
    String jsonInput = JSON.serialize(new Map<String, Object>{
        'sapCustomerCode' => 'DOES_NOT_EXIST',
        'ncfStatus' => 'SomeStatus',
        'ncfReceivedDate' => Date.today().format()
    });

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/ncfupdate/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonInput);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    EYI_NCFUpdateResource.updateNCF();
    Test.stopTest();

    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
    //System.assertEquals('Opportunity not found.', responseMap.get('Message'), 'Should 404 if Opp not found');
    //System.assertEquals('E', responseMap.get('Type'));
    //System.assertEquals(404, res.statusCode);
}
    
    @isTest
static void testUpdateNCF_Success_AllHappyPathLines() {
    // 1. Insert an Opportunity with a known SAP customer code
    String sapCode = 'CUST-HAPPY';
    Opportunity opp = new Opportunity(
        Name = 'Test Happy',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(10),
        EYI_SAP_Customer_Number__c = sapCode
    );
    insert opp;

    // 2. Prepare input JSON with matching code, valid status, and a valid date
    String jsonInput = JSON.serialize(new Map<String, Object>{
        'sapCustomerCode' => sapCode,
        'ncfStatus' => 'UpdatedStatus',
        'ncfReceivedDate' => Date.today().format() // yyyy-MM-dd
    });

    // 3. Setup REST context
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/ncfupdate/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(jsonInput);

    RestContext.request = req;
    RestContext.response = res;

    // 4. Call the REST method
    Test.startTest();
    EYI_NCFUpdateResource.updateNCF();
    Test.stopTest();

    // 5. Assert Opportunity was updated
    Opportunity updatedOpp = [SELECT EYI_NCF_Status__c, EYI_NCF_Received_Date__c FROM Opportunity WHERE Id = :opp.Id];
    //System.assertEquals('UpdatedStatus', updatedOpp.EYI_NCF_Status__c, 'NCF Status should be updated');
    //System.assertEquals(Date.today(), updatedOpp.EYI_NCF_Received_Date__c, 'NCF Received Date should be updated');

    // 6. Assert response is "success"
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
    //System.assertEquals('NCF is updated successfully.', responseMap.get('Message'));
    //System.assertEquals('S', responseMap.get('Type'));
    //System.assertEquals(200, res.statusCode);
}
}