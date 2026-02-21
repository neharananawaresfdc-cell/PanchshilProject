global class EYI_SAP_AgeingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Map<String, String> dynamicDueDays;
    
    global EYI_SAP_AgeingBatch(Map<String, String> dueDays) {
        this.dynamicDueDays = dueDays;
        System.debug('Batch constructor initialized with dynamic due days: ' + dynamicDueDays);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT EYI_SAP_Customer_Number__c, EYI_Project_Enquired__r.EYI_SAP_Company_Code__c
            FROM Opportunity
            WHERE (StageName = 'Sold' OR StageName = 'Registration Completed')
            AND EYI_SAP_Customer_Number__c != null AND EYI_SAP_Customer_Number__c != '0' 
            AND EYI_Project_Enquired__r.EYI_SAP_Company_Code__c != null
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        if (scope.isEmpty()) return;
        
        // Find min customer number and company code
        String minCust = String.valueOf(scope[0].EYI_SAP_Customer_Number__c);
        String maxCust = minCust;
        String minComp = scope[0].EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
        String maxComp = minComp;
        
        for (Opportunity opp : scope) {
            String cust = String.valueOf(opp.EYI_SAP_Customer_Number__c);
            String comp = opp.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
            
            //if (cust < minCust) minCust = cust;
            //if (comp < minComp) minComp = comp;
            if (cust < minCust) minCust = cust;
            if (cust > maxCust) maxCust = cust;
            if (comp < minComp) minComp = comp;
            if (comp > maxComp) maxComp = comp;
        }
        
        List<Map<String, String>> customerNoItems = new List<Map<String, String>>{
            new Map<String, String> {
                'SIGN' => 'I',
                    'OPTION' => 'EQ',
                    'LOW' => minCust,
                    'HIGH' => maxCust
                    }
        };
            
            List<Map<String, String>> companyCodeItems = new List<Map<String, String>>{
                new Map<String, String> {
                    'SIGN' => 'I',
                        'OPTION' => 'EQ',
                        'LOW' => minComp,
                        'HIGH' => maxComp 
                        }
            };
                
            Date d = Date.today();
            String formattedDate = (d.day() < 10 ? '0' : '') + String.valueOf(d.day()) + '.' +
            (d.month() < 10 ? '0' : '') + String.valueOf(d.month()) + '.' +
            String.valueOf(d.year());
        
        Map<String, Object> ageingReport = new Map<String, Object>();
        ageingReport.put('KeyDate', formattedDate);
        ageingReport.put('CustomerNo', new Map<String, Object>{ 'item' => customerNoItems });
        ageingReport.put('CompanyCode', new Map<String, Object>{ 'item' => companyCodeItems });
        
        ageingReport.put('DueDays1', dynamicDueDays.containsKey('DueDays1') ? dynamicDueDays.get('DueDays1') : '30');
        ageingReport.put('DueDays2', dynamicDueDays.containsKey('DueDays2') ? dynamicDueDays.get('DueDays2') : '60');
        ageingReport.put('DueDays3', dynamicDueDays.containsKey('DueDays3') ? dynamicDueDays.get('DueDays3') : '90');
        ageingReport.put('DueDays4', dynamicDueDays.containsKey('DueDays4') ? dynamicDueDays.get('DueDays4') : '120');
        ageingReport.put('DueDays5', dynamicDueDays.containsKey('DueDays5') ? dynamicDueDays.get('DueDays5') : '150');
        ageingReport.put('DueDays6', dynamicDueDays.containsKey('DueDays6') ? dynamicDueDays.get('DueDays6') : '180');
        ageingReport.put('DueDays7', dynamicDueDays.containsKey('DueDays7') ? dynamicDueDays.get('DueDays7') : '365');
        ageingReport.put('DueDays8', dynamicDueDays.containsKey('DueDays8') ? dynamicDueDays.get('DueDays8') : '720');
        
        Map<String, Object> payload = new Map<String, Object> {'AgeingReport' => ageingReport};
            
        String jsonBody = JSON.serialize(payload);
       
        Http http = new Http();
        String apiResponse;
        try {
            HttpResponse res = EY_SAP_Gateway.getSAPAgeingReport(jsonBody);
            apiResponse = res.getBody();
            
            if (res.getStatusCode() == 200) {
                processApiResponse(apiResponse);
                /*logCalloutErrorUsingLogger(
                    'CustAgingReportSalesForce',
                    jsonBody,
                    res.getStatusCode(),
                    null,
                    res.getBody()
                );*/
            } else {
                System.debug('Callout failed: ' + res.getBody());
                /*logCalloutErrorUsingLogger(
                    'CustAgingReportSalesForce',
                    jsonBody,
                    res.getStatusCode(),
                    null,
                    res.getBody()
                );*/
            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
            System.debug('Error Stack Trace: ' + e.getStackTraceString());
            /*logCalloutErrorUsingLogger(
                'CustAgingReportSalesForce',
                jsonBody,
                500,
                null,
                e.getMessage()
            );*/
            if (e.getMessage().contains('StatusCode=400')) {
               // String fallbackJson = getFallbackResponse();
               // System.debug('Fallback JSON: ' + fallbackJson);
              //  processApiResponse(fallbackJson);
            } else if (e.getMessage().contains('StatusCode=500') || e.getMessage().contains('StatusCode=503')) {
                System.debug('API error detected. Retry or further investigation may be needed.');
            } else if (e.getMessage().contains('StatusCode=404')) {
                System.debug('Resource not found (404). Check API endpoint or data.');
            } else if (e.getMessage().contains('StatusCode=401')) {
                System.debug('Unauthorized (401). Check API authentication credentials.');
            } else {
                System.debug('Unhandled error: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional: send notification or log finish status
    }
    
    public static String padLeft(String original, Integer length, String padChar) {
        Integer padLength = length - original.length();
        return (padLength > 0) ? String.valueOf(padChar).repeat(padLength) + original : original;
    }
    
    public static void processApiResponse(String responseBody) {
        Map<String, Object> responseMap1 = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> responseMap2 = (Map<String, Object>) responseMap1.get('n0:ZSD_CUSTOMER_AGEING_SFResponse');
        Map<String, Object> exOutput = (Map<String, Object>) responseMap2.get('EX_OUTPUT');
        
        if (exOutput == null || exOutput.get('item') == null) return;
      
        Set<String> custNumsAgePadded = new Set<String>();
        Map<String, List<Object>> mapAgeSAPCustWithItems = new Map<String, List<Object>>();
        
        List<Object> items = (List<Object>) exOutput.get('item');
        Set<String> custNumsPadded = new Set<String>();
        
        for (Object obj : items) 
        {
            
            Map<String, Object> row = (Map<String, Object>) obj;
            String custNo = (String) row.get('KUNNR');
            String delayDaysStr = (String) row.get('DELAY_DAYS');
            Decimal delayDays;
            
            try {
                delayDays = Decimal.valueOf(delayDaysStr);
            } catch (Exception ex) {
                continue;
            }
            
            if (!String.isBlank(custNo) && delayDays != null) {
                String paddedCustNo = padLeft(custNo, 10, '0');
                system.debug('paddedCustNo==>'+paddedCustNo);
                
                if(mapAgeSAPCustWithItems.containsKey(paddedCustNo)){
                    List<Object> objRec =  mapAgeSAPCustWithItems.get(paddedCustNo);
                    objRec.add(obj);
                    mapAgeSAPCustWithItems.put(paddedCustNo, objRec);
                } else {
                    mapAgeSAPCustWithItems.put(paddedCustNo, new List<Object>{obj});
                }
                
                custNumsPadded.add(paddedCustNo);
            }
        }

        List<Opportunity> oppsToUpdate = [
            SELECT Id, EYI_SAP_Customer_Number__c, EYI_Collection_Ageing__c
            FROM Opportunity
            WHERE EYI_SAP_Customer_Number__c IN :custNumsPadded
        ];
        System.debug('oppsToUpdate :: '+oppsToUpdate);
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Map<String,String> mapSAPNumberToOppId = new Map<String,String>();
        Set<Id> oppsId = new Set<Id>();
        
        for (Opportunity opp : oppsToUpdate) {
            oppsId.add(opp.Id);
            String custNum = padLeft(String.valueOf(opp.EYI_SAP_Customer_Number__c), 10, '0');
            mapSAPNumberToOppId.put(custNum,opp.Id);
        }
        
        String ageingRecordTypeId = Schema.SObjectType.EYI_SAP_Report__c.getRecordTypeInfosByDeveloperName().get('EYI_SAP_Ageing_Report').getRecordTypeId();
        
        List<EYI_SAP_Report__c> deleteSAPReport = new List<EYI_SAP_Report__c>();
        deleteSAPReport = [SELECT id from EYI_SAP_Report__c where Opportunity__c IN:oppsId AND RecordTypeId =: ageingRecordTypeId];
        if (!deleteSAPReport.isEmpty()) {
            delete deleteSAPReport;
        }
        
        List<EYI_SAP_Report__c> insertToSAPReport = new List<EYI_SAP_Report__c>();
        
        for (Opportunity opp : oppsToUpdate) {
            for(Object obj :mapAgeSAPCustWithItems.get(opp.EYI_SAP_Customer_Number__c)){
                Map<String, Object> row = (Map<String, Object>) obj;
                Decimal delayDays = Decimal.valueOf(String.valueOf(row.get('DELAY_DAYS')));
                EYI_SAP_Report__c report = new EYI_SAP_Report__c();
                report.Opportunity__c = mapSAPNumberToOppId.get(opp.EYI_SAP_Customer_Number__c);
                report.EYI_Ageing_SAP_Customer_Number__c = opp.EYI_SAP_Customer_Number__c;
                report.EYI_Ageing_Delay_Days__c =delayDays;
                report.RecordTypeId = ageingRecordTypeId;
                report.EYI_Sales_Org__c = String.valueOf(row.get('VKORG'));
                
                String vtwegStr = String.valueOf(row.get('VTWEG'));
                report.EYI_Distribution_Channel__c = (vtwegStr == null || vtwegStr.trim() == '') ? 0 : Integer.valueOf(row.get('VTWEG'));
                
                report.EYI_Company_Code__c = Integer.valueOf(row.get('BUKRS'));
                report.EYI_Company_Name__c = String.valueOf(row.get('BUKRS_DESC'));
                report.EYI_Customer_Name__c = String.valueOf(row.get('NAME1'));
                
                String dueDateStr = String.valueOf(row.get('DUE_DATE'));
                report.EYI_Due_Date__c = parseCustomDateFormat(dueDateStr);
                
                report.EYI_Document_Type__c = String.valueOf(row.get('DOCUMENT_TYPE'));
                
                String documentDateStr = String.valueOf(row.get('DOCUMENT_DATE'));
                report.EYI_Document_Date__c = parseCustomDateFormat(documentDateStr);
                
                String postingDateStr = String.valueOf(row.get('POSTING_DATE'));
                report.EYI_Posting_Date__c = parseCustomDateFormat(postingDateStr);
                
                report.EYI_Currency__c = String.valueOf(row.get('CURRENCY'));
                report.EYI_Agreement_Value__c = Decimal.valueOf(String.valueOf(row.get('AGREEMENT_VAL')));
                report.EYI_Carpet_Area__c = Decimal.valueOf(String.valueOf(row.get('CARPET_AREA')));
                report.EYI_Saleable_Area__c = Decimal.valueOf(String.valueOf(row.get('SALEABLE_AREA')));
                report.EYI_Segment__c = String.valueOf(row.get('SEGMENT'));
                report.EYI_City__c	= String.valueOf(row.get('ORT01'));
                report.EYI_Region__c = String.valueOf(row.get('REGION'));
                report.EYI_Region_Description__c = String.valueOf(row.get('REGION_DESC'));
                
                //Below fields added by Akshay
                report.EYI_SAP_Customer_Number__c = String.valueOf(row.get('KUNNR'));
                report.EYI_Sales_Order_Type__c = String.valueOf(row.get('AUART'));
                report.EYI_Sales_Order_Type_Description__c = String.valueOf(row.get('AUART_DESC'));
                report.EYI_Customer_Type__c = String.valueOf(row.get('KTOKD'));
                report.EYI_Customer_Type_Description__c = String.valueOf(row.get('KTOKD_DESC'));
                report.EYI_Billing_Document_Number__c = String.valueOf(row.get('BILL_DOC'));
                report.EYI_Line_Item_Number__c = String.valueOf(row.get('LINE_NO'));
                report.EYI_Sales_Order_Number__c = String.valueOf(row.get('VBELN'));
                report.EYI_Material_Number__c = String.valueOf(row.get('MATNR'));
                report.EYI_Profit_Center_Name__c = String.valueOf(row.get('PRCTR'));
                report.EYI_Profit_Center_Description__c = String.valueOf(row.get('PRCTR_DESC'));
                report.EYI_BRACKET1__c = Decimal.valueOf(String.valueOf(row.get('BRACKET1')));
                report.EYI_BRACKET2__c = Decimal.valueOf(String.valueOf(row.get('BRACKET2')));
                report.EYI_BRACKET3__c = Decimal.valueOf(String.valueOf(row.get('BRACKET3')));
                report.EYI_BRACKET4__c = Decimal.valueOf(String.valueOf(row.get('BRACKET4')));
                report.EYI_BRACKET5__c = Decimal.valueOf(String.valueOf(row.get('BRACKET5')));
                report.EYI_BRACKET6__c = Decimal.valueOf(String.valueOf(row.get('BRACKET6')));
                report.EYI_BRACKET7__c = Decimal.valueOf(String.valueOf(row.get('BRACKET7')));
                report.EYI_BRACKET8__c = Decimal.valueOf(String.valueOf(row.get('BRACKET8')));
                report.EYI_BRACKET9__c = Decimal.valueOf(String.valueOf(row.get('BRACKET9')));
                report.EYI_Payment_Terms__c = String.valueOf(row.get('ZTERM'));
                report.EYI_Tax_Code__c = String.valueOf(row.get('MWSKZ'));
                report.EYI_Ref_Doc_No__c = String.valueOf(row.get('XBLNR'));
                report.EYI_Not_Due__c = Decimal.valueOf(String.valueOf(row.get('NOT_DUE')));
                report.EYI_Received_Amount__c = Decimal.valueOf(String.valueOf(row.get('AMOUNT')));
                insertToSAPReport.add(report);                
            }            
        }
        System.debug('insertToSAPReport.size():: '+insertToSAPReport.size());
        System.debug('insertToSAPReport:: '+insertToSAPReport);
        if (!insertToSAPReport.isEmpty()) {
            insert insertToSAPReport;
        }
        
        System.debug('oppToUpdate::; '+oppToUpdate);
        if (!oppToUpdate.isEmpty()) {
            update oppToUpdate;
        }
    }
    
    
    public static Date parseCustomDateFormat(String inputDateStr) {
    if (inputDateStr == null || inputDateStr.trim() == ''|| inputDateStr == '0000-00-00') {
        return null;
    }

    List<String> parts = inputDateStr.split('\\.');
    if (parts.size() != 3) {
        return null; // or throw exception depending on use case
    }

    try {
        Integer day = Integer.valueOf(parts[0]);
        Integer month = Integer.valueOf(parts[1]);
        Integer year = Integer.valueOf(parts[2]);
        return Date.newInstance(year, month, day);
    } catch (Exception e) {
        return null;
    }
}
    /*private static void logCalloutErrorUsingLogger(String endpoint, String requestBody, Integer statusCode, String recordId, String errorMessage) {
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
    }*/
    
}