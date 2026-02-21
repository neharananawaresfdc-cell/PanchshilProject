@RestResource(urlMapping='/UpdateVendorInvoiceStatus/*')
global class EYI_VendorInvoiceStatus {

    global class CustomResponse {
        public String id;
        public String sapPoNumber;
        public String sapBillDeskNumber;
        public Boolean success;
        public String message;

        public CustomResponse(String id, String sapPoNumber, String sapBillDeskNumber, Boolean success, String message) {
            this.id = id;
            this.sapPoNumber = sapPoNumber;
            this.sapBillDeskNumber = sapBillDeskNumber;
            this.success = success;
            this.message = message;
        }
    }

    @HttpPost
    global static List<CustomResponse> createPaymentReceipts() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        List<CustomResponse> responses = new List<CustomResponse>();
        Set<String> sapPONumbers = new Set<String>();

        try {
            EYI_InvoiceStatusWrapper invoiceReceiptRequest = (EYI_InvoiceStatusWrapper)JSON.deserialize(requestBody, EYI_InvoiceStatusWrapper.class);
            List<EYI_InvoiceStatusWrapper.InvoiceWrapper> invoiceList = invoiceReceiptRequest.InvStatus;
            System.debug('invoiceReceiptRequest: '+invoiceReceiptRequest);
            Map<String, EYI_InvoiceStatusWrapper.InvoiceWrapper> brokerageIdToWrapperMap = new Map<String, EYI_InvoiceStatusWrapper.InvoiceWrapper>();

            for (EYI_InvoiceStatusWrapper.InvoiceWrapper invoice : invoiceList) {
                if (String.isNotBlank(invoice.SapPONumber)) {
                    sapPONumbers.add(invoice.SapPONumber);
                }
            }

            Map<String, Id> existingBrokerageMap = getBrokerage(sapPONumbers);
            List<EYI_Brokerage__c> updateBrokerageList = new List<EYI_Brokerage__c>();

            for (EYI_InvoiceStatusWrapper.InvoiceWrapper invoice : invoiceList) {
                Id brokerageId = existingBrokerageMap.get(invoice.SapPONumber);

                if (brokerageId != null) {
                    EYI_Brokerage__c record = new EYI_Brokerage__c(Id = brokerageId);
                    record.EYI_SAP_Bill_Desk_Number__c = invoice.SapBillDeskNumber;
                    //record.EYI_REC_Vendor_Code__c = invoice.RecVendorNo;
                    record.EYI_SAP_PO_Number__c = invoice.SapPONumber;
                    record.EYI_Invoice_Status__c = invoice.InvoiceStatus;
                    record.EYI_SAP_Company_Code__c = invoice.SapCompanyCode;
                    if(invoice.SapUTRNo != null){
                       record.EYI_SAP_UTR_Number__c = invoice.SapUTRNo;
                       //record.Stages__c = 'Payout Completed';
                    }
                   
                    record.EYI_SAP_Paid_Amount__c = invoice.paidAmount;
                    
                    record.EYI_SAP_Material_Number__c = invoice.SapMaterialNumber;

                    if (invoice.InvoiceStatus == 'HOLD' || invoice.InvoiceStatus == 'REJECT') {
                        record.EYI_Reason_for_Rejection_Hold__c = invoice.ReasonForRejectionHold != null ? invoice.ReasonForRejectionHold : null;//invoice.ReasonForRejectionHold;
                        record.EYI_Rejection_Hold_Remarks__c = invoice.RejectionHoldRemarks != null ? invoice.RejectionHoldRemarks : null;//invoice.RejectionHoldRemarks;
                    }

                    if (invoice.InvoiceStatus == 'APPROVED') {
                        if (String.isNotBlank(invoice.SapDocumentNumber)) {
                            record.EYI_SAP_Document_Number__c = invoice.SapDocumentNumber;
                        }else{
                           record.EYI_SAP_Document_Number__c = null; 
                        }
                        if (String.isNotBlank(invoice.SapDocumentYear) && invoice.SapDocumentYear != '0') {
                            record.EYI_SAP_Document_Year__c = String.valueOf(invoice.SapDocumentYear);
                        }else{
                            record.EYI_SAP_Document_Year__c = null;
                        }
                        if (String.isNotBlank(invoice.SapDocumentItem) && invoice.SapDocumentItem != '0') {
                            record.EYI_SAP_Document_Item__c = Decimal.valueOf(invoice.SapDocumentItem);
                        }else{
                            record.EYI_SAP_Document_Item__c = null;
                        }
                    }

                    if (String.isNotBlank(invoice.ApprovedHoldOn) && String.isNotBlank(invoice.ApprovedHoldAt)) {
                        String timePart = invoice.ApprovedHoldAt;
                        if (!timePart.contains(':')) {
                            timePart += ':00';
                        } else if (timePart.split(':').size() == 2) {
                            timePart += ':00';
                        }
                        List<String> timeParts = timePart.split(':');
                        if (timeParts[0].length() == 1) {
                            timePart = '0' + timePart;
                        }
                        String dateTimeStr = invoice.ApprovedHoldOn + ' ' + timePart;
                        record.EYI_Approved_Hold_On__c = DateTime.valueOf(dateTimeStr);
                    }
                    System.debug('invoice.paymentDate : '+invoice.paymentDate);
                    String paymentDateStr = invoice.paymentDate;
                    if(String.isNotBlank(paymentDateStr)){
                        System.debug('inside if ');
                        //record.EYI_Payment_Date__c = Date.valueOf(invoice.paymentDate);
                        String formattedDate = paymentDateStr.substring(0,4) + '-' + paymentDateStr.substring(4,6) + '-' + paymentDateStr.substring(6,8);

                        try {
                            record.EYI_Payment_Date__c = Date.valueOf(formattedDate);
                            System.debug('Parsed date: ' + record.EYI_Payment_Date__c);
                        } catch (Exception e) {
                            System.debug('Date parsing failed: ' + e.getMessage());
                        }
                    }else{
                       record.EYI_Payment_Date__c  = null;
                    }
                    updateBrokerageList.add(record);
                    brokerageIdToWrapperMap.put(String.valueOf(record.Id), invoice);
                } else {
                    logCalloutErrorUsingLogger('/UpdateVendorInvoiceStatus', requestBody, 404, invoice.SapPONumber, 'PO Number does not exist');
                    responses.add(new CustomResponse(null, invoice.SapPONumber, invoice.SapBillDeskNumber, false, 'PO Number does not exist'));
                }
            }

            if (!updateBrokerageList.isEmpty()) {
                Database.SaveResult[] saveResults = Database.update(updateBrokerageList, false);

                for (Integer i = 0; i < saveResults.size(); i++) {
                    Database.SaveResult result = saveResults[i];
                    EYI_Brokerage__c record = updateBrokerageList[i];
                    EYI_InvoiceStatusWrapper.InvoiceWrapper wrapper = brokerageIdToWrapperMap.get(String.valueOf(record.Id));

                    if (result.isSuccess()) {
                        responses.add(new CustomResponse(record.Id, wrapper.SapPONumber, wrapper.SapBillDeskNumber, true, 'Invoice updated successfully'));
                    } else {
                        String errMsg = '';
                        for (Database.Error err : result.getErrors()) {
                            errMsg += err.getMessage() + ' ';
                        }
                        logCalloutErrorUsingLogger('/UpdateVendorInvoiceStatus', requestBody, 500, wrapper.SapPONumber, errMsg.trim());
                        responses.add(new CustomResponse(record.Id, wrapper.SapPONumber, wrapper.SapBillDeskNumber, false, 'Update failed: ' + errMsg.trim()));
                    }
                }
            }

        } catch (Exception ex) {
            logCalloutErrorUsingLogger('/UpdateVendorInvoiceStatus', requestBody, 500, null, ex.getMessage());
            responses.add(new CustomResponse(null, null, null, false, 'General error: ' + ex.getMessage()));
        }

        return responses;
    }

    public static Map<String, Id> getBrokerage(Set<String> sapPONumbers) {
        Map<String, Id> mapOfBrokerage = new Map<String, Id>();
        if (!sapPONumbers.isEmpty()) {
            for (EYI_Brokerage__c brokerage : [
                SELECT Id, EYI_SAP_PO_Number__c 
                FROM EYI_Brokerage__c 
                WHERE EYI_SAP_PO_Number__c IN :sapPONumbers
            ]) {
                mapOfBrokerage.put(brokerage.EYI_SAP_PO_Number__c, brokerage.Id);
            }
        }
        return mapOfBrokerage;
    }

    private static void logCalloutErrorUsingLogger(String endpoint, String requestBody, Integer statusCode, String recordId, String errorMessage) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(requestBody);
        req.setMethod('POST');

        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(errorMessage);

        EYI_AbstractHttpServiceConsumer.Logger log = new EYI_AbstractHttpServiceConsumer.Logger();
        log.addEntry(req, res, DateTime.now());
        System.enqueueJob(log);
    }   
}