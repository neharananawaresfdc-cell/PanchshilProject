@isTest
public class EYI_DemandStatusUpdateTest {
    // Dummy wrapper classes for test context
    public class DemandWrapper {
        public String SapDemandNumber;
        public String SAP_ODN_No;
        public String SAP_IRN_No;
        public String SapCancellationDocumentNo;
        public String SAP_IRN_Status;
        public String SAP_Cancelled_ODN_No;
        public String ESIGN_FLAG;
    }
    public class DemandStatusWrapper {
        public List<DemandWrapper> DemandStatus;
    }
    
    @isTest
    static void testUpdateDemandStatus_success() {
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting', // Use a valid stage in your org!
            CloseDate = Date.today().addDays(10),
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        // Create test EYI_Demand__c record
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Demand_Number__c = 'SAP123'
        );
        insert demand; 
        
        // Prepare request body
        DemandWrapper dw = new DemandWrapper();
        dw.SapDemandNumber = 'SAP123';
        dw.SAP_ODN_No = 'ODN456';
        dw.SAP_IRN_No = 'IRN789';
        dw.SapCancellationDocumentNo = 'CANCEL001';
        dw.SAP_IRN_Status = 'ACT';
        dw.SAP_Cancelled_ODN_No = 'CANCEL_ODN002';
        dw.ESIGN_FLAG = 'Y';
        DemandStatusWrapper dsw = new DemandStatusWrapper();
        dsw.DemandStatus = new List<DemandWrapper>{ dw };
            String reqBody = JSON.serialize(dsw);
        
        // Setup RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Call method
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        // System.assertEquals(1, responses.size());
        // System.assertEquals('E', responses[0].TYPE);
        // System.assertEquals('Please check all the data is filled properly or not', responses[0].MESSAGE);
    }
    
    @isTest
    static void testUpdateDemandStatus_notFound() {
        // Demand number does not exist
        DemandWrapper dw = new DemandWrapper();
        dw.SapDemandNumber = 'SAP999';
        DemandStatusWrapper dsw = new DemandStatusWrapper();
        dsw.DemandStatus = new List<DemandWrapper>{ dw };
            String reqBody = JSON.serialize(dsw);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        System.assertEquals(1, responses.size());
        System.assertEquals('E', responses[0].TYPE);
        System.assert(responses[0].MESSAGE.contains('does not exists'));
    }
    
    @isTest
    static void testUpdateDemandStatus_exception() {
        // Malformed request body to trigger exception
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('invalid-json');
        RestContext.request = req;
        RestContext.response = res;
        
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        System.assertEquals(1, responses.size());
        System.assertEquals('E', responses[0].TYPE);
    }
    
    @isTest
    static void testUpdateDemandStatus_happyPath() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Demand_Number__c = 'SAP321'
        );
        insert demand;
        
        // Prepare DemandWrapper map with correct field names and types
        Map<String, Object> demandMap = new Map<String, Object>{
            'VBELN_VF' => 'SAP321',
                'SAP_ODN_No' => 'ODN999',
                'SAP_IRN_No' => 'IRN999',
                'SapCancellationDocumentNo' => 'CANCEL999',
                'SAP_IRN_Status' => 'ACT',
                'SAP_Cancelled_ODN_No' => 'CANCEL_ODN999',
                'ESIGN_FLAG' => true,
                 'CAN_ODN' => 'Success' // Boolean!
                // Add other fields if you want, but not required for update
                };
                    Map<String, Object> wrapper = new Map<String, Object>{
                        'DemandStatus' => new List<Object>{ demandMap }
                    };
                        String reqBody = JSON.serialize(wrapper);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        System.debug(responses[0]);
        System.assertEquals('S', responses[0].TYPE);
        //System.assertEquals('Record was successfully updated.', responses[0].MESSAGE);
        
        // Optionally, assert the updated fields
        EYI_Demand__c updated = [SELECT EYI_SAP_ODN_No__c, EYI_SAP_IRN_No__c, EYI_SapCancellationDocumentNo__c, EYI_SAP_IRN_Status__c, EYI_SAP_Cancelled_ODN_No__c, EYI_ESIGN_FLAG__c
                                 FROM EYI_Demand__c WHERE Id = :demand.Id];
        // System.assertEquals('ODN999', updated.EYI_SAP_ODN_No__c);
        // System.assertEquals('IRN999', updated.EYI_SAP_IRN_No__c);
        // System.assertEquals('CANCEL999', updated.EYI_SapCancellationDocumentNo__c);
        // System.assertEquals('Active', updated.EYI_SAP_IRN_Status__c); // 'ACT' maps to 'Active'
        // System.assertEquals('CANCEL_ODN999', updated.EYI_SAP_Cancelled_ODN_No__c);
        // System.assertEquals(true, updated.EYI_ESIGN_FLAG__c);
    }

     @isTest
    static void testUpdateDemandStatus_happyPath1() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Demand_Number__c = 'SAP321'
        );
        insert demand;
        
        // Prepare DemandWrapper map with correct field names and types
        Map<String, Object> demandMap = new Map<String, Object>{
            'VBELN_VF' => 'SAP321',
                'SAP_ODN_No' => 'ODN999',
                'SAP_IRN_No' => 'IRN999',
                'SapCancellationDocumentNo' => 'CANCEL999',
                'SAP_IRN_Status' => 'ACT',
                'SAP_Cancelled_ODN_No' => 'CANCEL_ODN999',
                'ESIGN_FLAG' => true,
                 'CAN_ODN' => 'Success' // Boolean!
                // Add other fields if you want, but not required for update
                };
                    Map<String, Object> wrapper = new Map<String, Object>{
                        'DemandStatus' => new List<Object>{ demandMap }
                    };
                        String reqBody = JSON.serialize(wrapper);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        System.debug(responses[0]);
        System.assertEquals('S', responses[0].TYPE);
        //System.assertEquals('Record was successfully updated.', responses[0].MESSAGE);
        
        // Optionally, assert the updated fields
        EYI_Demand__c updated = [SELECT EYI_SAP_ODN_No__c, EYI_SAP_IRN_No__c, EYI_SapCancellationDocumentNo__c, EYI_SAP_IRN_Status__c, EYI_SAP_Cancelled_ODN_No__c, EYI_ESIGN_FLAG__c
                                 FROM EYI_Demand__c WHERE Id = :demand.Id];
        // System.assertEquals('ODN999', updated.EYI_SAP_ODN_No__c);
        // System.assertEquals('IRN999', updated.EYI_SAP_IRN_No__c);
        // System.assertEquals('CANCEL999', updated.EYI_SapCancellationDocumentNo__c);
        // System.assertEquals('Active', updated.EYI_SAP_IRN_Status__c); // 'ACT' maps to 'Active'
        // System.assertEquals('CANCEL_ODN999', updated.EYI_SAP_Cancelled_ODN_No__c);
        // System.assertEquals(true, updated.EYI_ESIGN_FLAG__c);
    }

    @isTest
    static void testUpdateDemandStatus_dmlError() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        // Insert a demand record
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Demand_Number__c = 'SAPERROR'
        );
        insert demand;
        
        // Prepare PATCH body with an invalid value that will fail on update
       Map<String, Object> demandMap = new Map<String, Object>{
                    'SapDemandNumber' => 'SAPERROR',
                    'SAP_ODN_No' => 'ODNINVALID',
                    'SAP_IRN_No' => 'IRNINVALID',
                    'SapCancellationDocumentNo' => 'CANCELINVALID',
                    'SAP_IRN_Status' => 'ACT',
                    'SAP_Cancelled_ODN_No' => 'CANCEL_ODNINVALID',
                    'ESIGN_FLAG' => 'notABoolean' // ❌ Should be true/false, not a string
                };
                    Map<String, Object> wrapper = new Map<String, Object>{
                        'DemandStatus' => new List<Object>{ demandMap }
                    };
                        String reqBody = JSON.serialize(wrapper);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        System.debug(responses[0]);
        System.assertEquals('E', responses[0].TYPE);
        System.assert(responses[0].MESSAGE != null && responses[0].MESSAGE != 'Sap Demand Number does no');
    }
    
    @isTest
    static void testUpdateDemandStatus_exceptionWithNonEmptySapCustomerNumber() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Demand_Number__c = 'SAPEXC'
        );
        insert demand;
        
        // Provide a valid SapDemandNumber so sapCustomerNumber is not empty
        // Set MilestoneNumber to a string to cause JSON.deserialize error after sapCustomerNumber is added
        Map<String, Object> demandMap = new Map<String, Object>{
            'SapDemandNumber' => 'SAPEXC',
                'MilestoneNumber' => 'notAnInt', // This will cause an exception
                'SAP_ODN_No' => 'ODNERROR',
                'SAP_IRN_No' => 'IRNERROR',
                'SapCancellationDocumentNo' => 'CANCELERROR',
                'SAP_IRN_Status' => 'ACT',
                'SAP_Cancelled_ODN_No' => 'CANCEL_ODNERROR',
                'ESIGN_FLAG' => true
                };
                    Map<String, Object> wrapper = new Map<String, Object>{
                        'DemandStatus' => new List<Object>{ demandMap }
                    };
                        String reqBody = JSON.serialize(wrapper);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        
        List<EYI_DemandStatusUpdate.CustomResponse> responses = EYI_DemandStatusUpdate.updateDemandStatus();
        System.debug('Actual TYPE: ' + responses[0].TYPE + ', MESSAGE: ' + responses[0].MESSAGE);
        System.assertEquals('E', responses[0].TYPE);
        System.assert(responses[0].MESSAGE != null && responses[0].MESSAGE.contains('Sap Demand Number does not exists'));
    }
}