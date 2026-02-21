/**
* @description       : 
* @author            : Abhishek Verma
* @group             : 
* @last modified on  : 03-26-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EY_SAP_Gateway {
    public class SAPCalloutException extends Exception {}
    
    // 1 mid level AbstractClass for the entire SAP API
    abstract class AbstractSAPConsumer extends EYI_AbstractHttpServiceConsumer {
        public AbstractSAPConsumer(String method, String endpoint) {
           // super(method, 'callout:SAP_Integration_Base' + endpoint);
            super(method, endpoint);
        }
        
        protected override HttpResponse send() {
            try {
                // try to send request with current access token (OAuth2)
                return super.send();
            }
            
            catch(EYI_AbstractHttpServiceConsumer.HttpException e) {
                //re-auth if token expired
                throw new SAPCalloutException(e.getResponse() + ': ' + e.getMessage());
            }
        }
    }
    
    /* PET */
    
    // 1 low level Abstract Class for each Resource in the API (Store, User below)
    abstract public class AbstractCreateBrokerVendor extends AbstractSAPConsumer {
        public AbstractCreateBrokerVendor(String method, String endpoint) {
            super(method, '/CreateBrokerVendorSalesForce/' + endpoint);
        }
    }
    
    
    public class PostConsumerCall extends AbstractSAPConsumer {
        public PostConsumerCall(String petId) {
            super('POST', '');
        }
        public HttpResponse call(String pet) {
            request.setBody(pet);
            return send();
        }
    }
    
    public static void createSAPConsumer(String Data) {
        String petBody = EY_SAPAdapter.createConsumerBody(data);
        PostConsumerCall caller = new PostConsumerCall('');
        HttpResponse hr = caller.call(petBody);
    }
    public class PostReceiptCall extends AbstractSAPConsumer {
        public PostReceiptCall() {
            super('POST', 'callout:SAP_CreatePaymentReceipt'); //CreatePaymentReceiptSalesForce
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
    public class PostSOA_PDF_Call extends AbstractSAPConsumer {
        public PostSOA_PDF_Call() {
            super('POST', 'callout:ExportFormBase64Encoding'); //ExportFormBase64Encoding
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
     public class PostSAP_CancellationCall extends AbstractSAPConsumer {
        public PostSAP_CancellationCall() {
            super('POST', 'callout:SAP_FetchCancellationPaymntDetails'); //FetchCancellationPaymntDetailsSalesForce
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
    public class PostSAP_CancellationCallSF extends AbstractSAPConsumer {
        public PostSAP_CancellationCallSF() {
            super('POST', 'callout:SAP_CancellationRequestPosting'); //CancellationRequestPostingSalesForce
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
    public class PostSAP_ReportCall extends AbstractSAPConsumer {
        public PostSAP_ReportCall() {
            super('POST', 'callout:SAP_Outstanding_Report'); //OutstandingBalReportSalesForce
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
    
    public class PostSAP_AgeingReportCall extends AbstractSAPConsumer {
        public PostSAP_AgeingReportCall() {
            super('POST', 'callout:SAP_Ageing_Report'); //CustAgingReportSalesForce
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
    public class PostCustOpenLineItemsCall extends AbstractSAPConsumer {
        public PostCustOpenLineItemsCall() {
            super('POST', 'callout:SAP_CustOpenLineItemSalesForce'); //CustOpenLineItemSalesForce
        }
        
        public HttpResponse call(String receipt) {
            request.setBody(receipt);
            return send();
        }
    }
    // we need put the Endpoint for Demand 
    public class PostDemandCall extends AbstractSAPConsumer {
        public PostDemandCall() {
            super('POST', 'callout:SAP_DemandRaiseSalesForce'); //DemandRaiseSalesForce
        }
        
        public HttpResponse call(String demand) {
            request.setBody(demand);
            return send();
        }
    }

    public class PostInvoiceCreation extends AbstractSAPConsumer {
        public PostInvoiceCreation() {
            super('POST', 'callout:SAP_RECInvoiceCreate'); //RECInvoiveCreateChngeSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            return send();
        }
    }
    public class customerLedgerAction extends AbstractSAPConsumer {
        public customerLedgerAction() {
            super('POST', 'callout:EYI_Cust_Ledger_Details'); //RECInvoiveCreateChngeSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            return send();
        }
    }
    public class InvSyncCall extends AbstractSAPConsumer {
        public InvSyncCall(String method) {
            super(method, 'callout:SAP_CreateUnitMasterSalesForce'); //CreateUnitMasterSalesForce CreateUnitMasterSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            request.setTimeout(120000);
            return send();
        }
    }
    public static HttpResponse getSAPCancellationPaymentDetails(string filters) {
        //String reportBody = EYI_SAP_Adapter.createReportBody(filters);
        PostSAP_CancellationCall caller = new PostSAP_CancellationCall();
        System.debug('filters : '+filters);
        HttpResponse hr = caller.call(filters);
        System.debug('hr : '+hr);
        //	HttpResponse hr = new HttpResponse();
        return hr;
        
    }
    public static HttpResponse postCancellationDetails(string filters) {
        //String reportBody = EYI_SAP_Adapter.createReportBody(filters);
        PostSAP_CancellationCallSF caller = new PostSAP_CancellationCallSF();
        HttpResponse hr = caller.call(filters);
        //	HttpResponse hr = new HttpResponse();
        return hr;
        
    }
    public class PostPricSyncCall extends AbstractSAPConsumer {
        public PostPricSyncCall() {
            super('POST', 'callout:SAP_CreateUnitMaster'); //CreateUnitMasterSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            request.setTimeout(120000);
            return send();
        }
    }
    
    public class PostCustSyncCall extends AbstractSAPConsumer {
        public PostCustSyncCall() {
            super('POST', 'callout:Customer_Sync'); //CreateUnitMasterSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            request.setTimeout(120000);
            return send();
        }
    }
    public class CarParkSyncCall extends AbstractSAPConsumer {
        public CarParkSyncCall(String method) {
            super(method, 'callout:CreateUnitMasterSalesForce'); //CreateUnitMasterSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            request.setTimeout(120000);
            return send();
        }
    }
    public class brokerSyncCall extends AbstractSAPConsumer {
        public brokerSyncCall(String method) {
            super(method, 'callout:SAP_Integration'); //CreateUnitMasterSalesForce
        }
        
        public HttpResponse call(String reqBody) {
            request.setBody(reqBody);
            request.setTimeout(120000);
            return send();
        }
    }
    
    public static HttpResponse getSAPOutsatndingReport(string filters) {
        //String reportBody = EYI_SAP_Adapter.createReportBody(filters);
        PostSAP_ReportCall caller = new PostSAP_ReportCall();
        HttpResponse hr = caller.call(filters);
        //	HttpResponse hr = new HttpResponse();
        return hr;
        
    }
    public static HttpResponse getSAPAgeingReport(string filters){
        PostSAP_AgeingReportCall caller = new PostSAP_AgeingReportCall();
        HttpResponse hr = caller.call(filters);
        //	HttpResponse hr = new HttpResponse();
        return hr;
        
        
    }
    public static HttpResponse sendPayementReceipt(EYI_Payment_Receipt__c paymentReceipt, List<Map<String, Object>> updatedRecords, Map<String, Object> formData) {
        String paymentReceiptBody = EYI_SAP_Adapter.createReceiptBody(paymentReceipt,updatedRecords, formData);
        PostReceiptCall caller = new PostReceiptCall();
        HttpResponse hr = caller.call(paymentReceiptBody);
        return hr;
    }
    
    @future(callout=true)
    public static void sendPayementReceiptFuture(String paymentReceiptBody) {
        PostReceiptCall caller = new PostReceiptCall();
        caller.call(paymentReceiptBody);
    }

    public static HttpResponse sendPaymentLineItems(Id opptyId) {
        String paymentReceiptBody = EYI_SAP_Adapter.createLineItemsBody(opptyId);
        PostCustOpenLineItemsCall caller = new PostCustOpenLineItemsCall();
        HttpResponse hr = caller.call(paymentReceiptBody);
        return hr;
        
    }
    public static HttpResponse sendSOA_PDF(String jsonRequest) {
        String pdfBody = EYI_SAP_Adapter.createSOA_PDFBody(jsonRequest);
        PostSOA_PDF_Call caller = new PostSOA_PDF_Call();
        HttpResponse hr = caller.call(pdfBody);
        return hr;
        
    }
    public static HttpResponse blockDemandCall(Map<Id,Date> demandDateMap, List<EYI_Demand__c> demandlist, String action){
        String demandReqBody = EYI_SAP_Adapter.createDemandBody(demandDateMap, demandlist, action);
        PostDemandCall caller = new PostDemandCall();
        HttpResponse hr = caller.call(demandReqBody);
        EYI_AbstractHttpServiceConsumer.Logger log = new EYI_AbstractHttpServiceConsumer.Logger();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('/blackDemand');
        req.setBody(demandReqBody);
        req.setMethod('POST');
        log.addEntry(req, hr, DateTime.now());
        System.enqueueJob(log);
        return hr;
        
    }
    public static HttpResponse invoiceCreation(String reqBody){
        PostInvoiceCreation caller = new PostInvoiceCreation();
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
    public static HttpResponse customerLedger(String reqBody){
        customerLedgerAction caller = new customerLedgerAction();
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
    public static HttpResponse inventorySync(String reqBody, String method){
        InvSyncCall caller = new InvSyncCall(method);
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
     public static HttpResponse pricingSync(String reqBody){
        PostPricSyncCall caller = new PostPricSyncCall();
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
    public static HttpResponse custSync(String reqBody){
        PostCustSyncCall caller = new PostCustSyncCall();
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
     public static HttpResponse carParkSync(String reqBody, String method){
        CarParkSyncCall caller = new CarParkSyncCall(method);
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
    public static HttpResponse brokerSync(String reqBody, String method){
        brokerSyncCall caller = new brokerSyncCall(method);
        HttpResponse hr = caller.call(reqBody);
        return hr;
        
    }
}