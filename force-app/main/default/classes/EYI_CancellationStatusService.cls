@RestResource(urlMapping='/CancellationStatusAPI')
global class EYI_CancellationStatusService {

    @HttpPost
    global static void processCancellationRefunds() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        DateTime requestTime = DateTime.now();
        String requestBody = req.requestBody != null ? req.requestBody.toString() : '';
        Integer httpStatusCode;
        String responseBody;

        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        List<Case> casesToUpdate = new List<Case>();
        List<EYI_CancellationRefundStatusWrapper.Response> responseList = new List<EYI_CancellationRefundStatusWrapper.Response>();

        try {
            EYI_CancellationRefundStatusWrapper wrapper = 
                (EYI_CancellationRefundStatusWrapper)JSON.deserialize(requestBody, EYI_CancellationRefundStatusWrapper.class);

            System.debug('Deserialized wrapper --> ' + JSON.serialize(wrapper));

            if (wrapper == null || wrapper.CancellationStatus == null || wrapper.CancellationStatus.isEmpty()) {
                handleError(400, 'Invalid or empty request payload.', res, calloutLogs, requestTime, requestBody);
                return;
            }

            // Extract SAP Customer Numbers
            Set<String> sapCustomerNos = new Set<String>();
            for (EYI_CancellationRefundStatusWrapper.Request entry : wrapper.CancellationStatus) {
                if (String.isNotBlank(entry.SapCustomerNo)) {
                    sapCustomerNos.add(entry.SapCustomerNo.trim());
                }
            }

            System.debug('sapCustomerNos --> ' + sapCustomerNos);

            // Query Opportunities
            Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
            for (Opportunity opp : [
                SELECT Id, EYI_SAP_Customer_Number__c 
                FROM Opportunity 
                WHERE EYI_SAP_Customer_Number__c IN :sapCustomerNos
            ]) {
                oppMap.put(opp.EYI_SAP_Customer_Number__c.trim(), opp);
            }

            System.debug('oppMap keys --> ' + oppMap.keySet());

            // Query Cancellation Record Types
            Set<Id> cancellationRecordTypeIds = new Set<Id>();
            for (RecordType rt : [
                SELECT Id FROM RecordType 
                WHERE Name = 'Cancellation' AND SObjectType = 'Case'
            ]) {
                cancellationRecordTypeIds.add(rt.Id);
            }

            // Query Cases related to Opportunities
            Map<Id, Case> caseMap = new Map<Id, Case>();
            for (Case c : [
                SELECT Id, EYI_Opportunity__c 
                FROM Case 
                WHERE EYI_Opportunity__c IN :oppMap.values() 
                AND RecordTypeId IN :cancellationRecordTypeIds
            ]) {
                caseMap.put(c.EYI_Opportunity__c, c);
            }

            System.debug('caseMap keys --> ' + caseMap.keySet());

            for (EYI_CancellationRefundStatusWrapper.Request entry : wrapper.CancellationStatus) {
                try {
                    String cleanedCustomerNo = String.isNotBlank(entry.SapCustomerNo) ? entry.SapCustomerNo.trim() : null;
                    Opportunity opp = cleanedCustomerNo != null ? oppMap.get(cleanedCustomerNo) : null;

                    if (opp != null && caseMap.containsKey(opp.Id)) {
                        Case c = caseMap.get(opp.Id);

                        c.EYI_SAP_Cancellation_Status__c = String.isNotBlank(entry.SapRefundDocNo) ? 'APPROVE' : 'REJECT';
                        c.EYI_SAP_Refund_Amount__c = Decimal.valueOf(entry.SapRefundAmount);
                        c.EYI_SAP_Refund_Doc_Posted_By__c = entry.SapRefundDocPostedBy;
                        c.EYI_SAP_Refund_Doc_Posted_Date__c = parsePostedDateTime(entry.SapRefundDocPostedOn, entry.SapRefundDocPostedAt);
                        c.EYI_SAP_Refund_Document_Item__c = entry.SapRefundDocItem;
                        c.EYI_SAP_Refund_Document_No__c = entry.SapRefundDocNo;
                        c.EYI_SAP_Refund_Document_Year__c = entry.SapRefundDocYear;
                        c.EYI_SAP_Refund_Reversal_Doc_Item__c = entry.SapRefundRevDocItem;
                        c.EYI_SAP_Refund_Reversal_Doc_No__c = entry.SapRefundRevDocNo;
                        c.EYI_SAP_Refund_Reversal_Doc_Year__c = entry.SapRefundRevDocYear;
                        c.EYI_SAP_Refund_UTR_Ref_No__c = entry.SapRefundUtrRefNo;

                        casesToUpdate.add(c);

                        EYI_CancellationRefundStatusWrapper.Response resp =
                            createResponse('S', 'Cancellation refund processing completed.', entry);
                        responseList.add(resp);
                        calloutLogs.add(createCalloutLog('Cancellation Refund', 'INFO', entry.SapCustomerNo,
                            JSON.serialize(entry), JSON.serialize(resp), requestTime, DateTime.now(), 200));
                    } else {
                        EYI_CancellationRefundStatusWrapper.Response resp =
                            createResponse('E', 'Opportunity or Cancellation Case not found.', entry);
                        responseList.add(resp);
                        calloutLogs.add(createCalloutLog('Cancellation Refund', 'ERROR', entry.SapCustomerNo,
                            JSON.serialize(entry), JSON.serialize(resp), requestTime, DateTime.now(), 404));
                    }
                } catch (Exception innerEx) {
                    EYI_CancellationRefundStatusWrapper.Response resp =
                        createResponse('E', 'Processing error: ' + innerEx.getMessage(), entry);
                    responseList.add(resp);
                    calloutLogs.add(createCalloutLog('Cancellation Refund', 'ERROR', entry.SapCustomerNo,
                        JSON.serialize(entry), JSON.serialize(resp), requestTime, DateTime.now(), 500));
                }
            }

            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }

            httpStatusCode = 200;
            responseBody = JSON.serialize(responseList);
            res.statusCode = httpStatusCode;
            res.responseBody = Blob.valueOf(responseBody);

        } catch (Exception ex) {
            handleError(500, 'Fatal error: ' + ex.getMessage(), res, calloutLogs, requestTime, requestBody);
        }

        if (!calloutLogs.isEmpty()) {
            insert calloutLogs;
        }
    }

    // Helper: Parse combined date and time
    private static DateTime parsePostedDateTime(String postedOn, String postedAt) {
        if (String.isNotBlank(postedOn) && String.isNotBlank(postedAt)) {
            try {
                List<String> dateParts = postedOn.trim().split('\\.');
                List<String> timeParts = postedAt.trim().split(':');

                Date rdate = Date.newInstance(
                    Integer.valueOf(dateParts[2]), // year
                    Integer.valueOf(dateParts[1]), // month
                    Integer.valueOf(dateParts[0])  // day
                );

                Time rtime = Time.newInstance(
                    Integer.valueOf(timeParts[0]), // hour
                    Integer.valueOf(timeParts[1]), // minute
                    Integer.valueOf(timeParts[2]), // second
                    0                              // millisecond
                );

                return DateTime.newInstance(rdate, rtime);
            } catch (Exception e) {
                System.debug('❌ Failed to parse date/time: ' + e.getMessage());
            }
        }
        return null;
    }

    // Helper: Create response
    private static EYI_CancellationRefundStatusWrapper.Response createResponse(String type, String message, EYI_CancellationRefundStatusWrapper.Request entry) {
        EYI_CancellationRefundStatusWrapper.Response resp = new EYI_CancellationRefundStatusWrapper.Response();
        resp.Type = type;
        resp.Message = message;
        resp.SapCustomerNo = entry.SapCustomerNo;
        resp.SapComapnyCode = entry.SapCompanyCode;
        resp.SapDocNo = entry.SapRefundDocNo;
        return resp;
    }

    // Helper: Create log
    private static CalloutLog__c createCalloutLog(String endpoint, String type, String recordId, String requestBody,
                                                  String responseBody, DateTime requestTime, DateTime responseTime,
                                                  Integer statusCode) {
        return new CalloutLog__c(
            Endpoint__c = endpoint,
            Type__c = type,
            Record_Id__c = recordId,
            RequestBody__c = requestBody,
            ResponseBody__c = responseBody,
            RequestTime__c = requestTime,
            ResponseTime__c = responseTime,
            HttpStatusCode__c = statusCode
        );
    }

    // Helper: Handle error exit
    private static void handleError(Integer status, String message, RestResponse res, List<CalloutLog__c> logs,
                                    DateTime requestTime, String requestBody) {
        res.statusCode = status;
        res.responseBody = Blob.valueOf(message);
        logs.add(createCalloutLog('Cancellation Refund', 'ERROR', null, requestBody, message, requestTime, DateTime.now(), status));
    }
}