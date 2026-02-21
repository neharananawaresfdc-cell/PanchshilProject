@isTest
public class EY_SAP_GatewayTest {
    // Mock HTTP response for callouts
    public class SAPHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"result":"success"}');
            return res;
        }
    }

    @testSetup
    static void setup() {
        System.debug('setup ');
        // If any setup data is needed, add here
    }

    @isTest
    static void testGetSAPCancellationPaymentDetails() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.getSAPCancellationPaymentDetails('{"test":"value"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testPostCancellationDetails() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.postCancellationDetails('{"test":"value"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testGetSAPOutsatndingReport() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.getSAPOutsatndingReport('{"test":"value"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testGetSAPAgeingReport() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.getSAPAgeingReport('{"test":"value"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testSendPayementReceipt() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        EYI_Payment_Receipt__c rec = new EYI_Payment_Receipt__c();
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        Map<String, Object> formData = new Map<String, Object>();
        HttpResponse resp = EY_SAP_Gateway.sendPayementReceipt(rec, updatedRecords, formData);
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testSendPayementReceiptFuture() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        Test.startTest();
        EY_SAP_Gateway.sendPayementReceiptFuture('{"test":"future"}');
        Test.stopTest();
        // No assert needed for @future, just coverage
    }

    @isTest
    static void testSendPaymentLineItems() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());  
        Test.startTest();
        HttpResponse resp = EY_SAP_Gateway.sendPaymentLineItems(opp.Id);
        Test.stopTest(); 
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testSendSOA_PDF() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.sendSOA_PDF('{"pdf":"body"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testBlockDemandCall() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        Map<Id, Date> demandDateMap = new Map<Id, Date>();
        List<EYI_Demand__c> demandList = new List<EYI_Demand__c>();
        HttpResponse resp = EY_SAP_Gateway.blockDemandCall(demandDateMap, demandList, 'block');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testInvoiceCreation() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.invoiceCreation('{"invoice":"body"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testInventorySync() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.inventorySync('{"inv":"body"}', 'POST');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testPricingSync() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.pricingSync('{"price":"body"}');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testCarParkSync() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        HttpResponse resp = EY_SAP_Gateway.carParkSync('{"carpark":"body"}', 'POST');
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void testCreateSAPConsumer() {
        Test.setMock(HttpCalloutMock.class, new SAPHttpMock());
        // This will call PostConsumerCall and its callout
        EY_SAP_Gateway.createSAPConsumer('{"consumer":"data"}');
        // No assert needed, just coverage
    }
}