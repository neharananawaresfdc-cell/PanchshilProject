global class EYI_SAP_OutstandingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT EYI_SAP_Customer_Number__c, EYI_Project_Enquired__r.EYI_SAP_Company_Code__c
            FROM Opportunity
            WHERE (StageName = 'Sold' OR StageName = 'Registration Completed') AND
            EYI_SAP_Customer_Number__c != null AND EYI_SAP_Customer_Number__c != '0' 
            AND EYI_Project_Enquired__r.EYI_SAP_Company_Code__c != null order by  EYI_SAP_Customer_Number__c desc 
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        if (scope.isEmpty()) return;
        System.debug('scope===> ' + scope);
        // Find min/max customer number and company code
        String minCust = String.valueOf(scope[0].EYI_SAP_Customer_Number__c);
        String maxCust = minCust;
        String minComp = scope[0].EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
        String maxComp = minComp;
        
        for (Opportunity opp : scope) {
            String cust = String.valueOf(opp.EYI_SAP_Customer_Number__c);
            String comp = opp.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
            
            if (cust < minCust) minCust = cust;
            if (cust > maxCust) maxCust = cust;
            if (comp < minComp) minComp = comp;
            if (comp > maxComp) maxComp = comp;
        }
        
        System.debug('minCust : '+minCust);
        System.debug('maxCust : '+maxCust);
        System.debug('minComp : '+minComp);
        System.debug('maxComp : '+maxComp);
        
        // Build CustomerNo items
        List<Map<String, String>> customerNoItems = new List<Map<String, String>>();
        customerNoItems.add(new Map<String, String>{
            'HIGH' => maxCust,
                'LOW' => minCust,
                'OPTION' => 'EQ',
                'SIGN' => 'I'
                });
        
        // Build CompanyCode items
        List<Map<String, String>> companyCodeItems = new List<Map<String, String>>();
        companyCodeItems.add(new Map<String, String>{
            'HIGH' => maxComp,
                'LOW' => minComp,
                'OPTION' => 'EQ',
                'SIGN' => 'I'
                });
        
        // Hardcoded SalesOrg items as per your static JSON example
        /*List<Map<String, String>> salesOrgItems = new List<Map<String, String>>{
            new Map<String, String>{'HIGH' => '', 'LOW' => 'R150', 'OPTION' => 'EQ', 'SIGN' => 'I'},
                new Map<String, String>{'HIGH' => '', 'LOW' => 'R190', 'OPTION' => 'EQ', 'SIGN' => 'I'},
                    new Map<String, String>{'HIGH' => '', 'LOW' => 'R210', 'OPTION' => 'EQ', 'SIGN' => 'I'}
        };
            
            // Hardcoded CompanyCode repeated items (8 times) as per your static JSON example
            List<Map<String, String>> companyCodeRepeatedItems = new List<Map<String, String>>();
        for (Integer i = 0; i < 8; i++) {
            companyCodeRepeatedItems.add(new Map<String, String>{
                'HIGH' => '',
                    'LOW' => '1320',
                    'OPTION' => 'EQ',
                    'SIGN' => 'I'
                    });
        }*/
        
        // Build final payload with dynamic and static parts mixed
        Map<String, Object> innerObj = new Map<String, Object>();
        Date d = Date.today();
        String dayStr = (d.day() < 10 ? '0' : '') + String.valueOf(d.day());
        String monthStr = (d.month() < 10 ? '0' : '') + String.valueOf(d.month());
        String yearStr = String.valueOf(d.year());
        
        String formattedDate = dayStr + '-' + monthStr + '-' + yearStr;
        innerObj.put('KeyDate', formattedDate);
        
        
        innerObj.put('CustomerNo', new Map<String, Object>{ 'item' => customerNoItems });
        //innerObj.put('SalesOrg', new Map<String, Object>{ 'item' => salesOrgItems });
        innerObj.put('CompanyCode', new Map<String, Object>{ 'item' => companyCodeItems });
        
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('ZSD_OUTSTANDING_BALANCE_SF', innerObj);
        System.debug('payload : '+payload);
        // Serialize JSON
        //System.debug('payload : '+payload);
        String jsonBody = JSON.serialize(payload);
        //System.debug('jsonBody: ' + jsonBody);
        
        // Call external system
        String apiResponse;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        try {           
            HTTPResponse res = new HTTPResponse();
            system.debug('jsonBody '+jsonBody);
            res = EY_SAP_Gateway.getSAPOutsatndingReport(jsonBody);
            apiResponse = res.getBody();
            System.debug('apiResponse'+apiResponse);
            if (res.getStatusCode() == 200) {
                processApiResponse(res.getBody());
              
            } else {
                 
                System.debug('Callout failed: ' + res.getBody());
                
            }
        } catch (Exception e) {
            
            System.debug('Callout error: ' + e.getMessage());
            if (e.getMessage().contains('StatusCode=500')) {
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
    
    private static String padLeft(String original, Integer length, String padChar) {
        Integer padLength = length - original.length();
        return (padLength > 0) ? String.valueOf(padChar).repeat(padLength) + original : original;
    }
    
    public static void processApiResponse(String responseBody) {
        Map<String, Object> responseMap1 = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Decimal> custToOutstanding = new Map<String, Decimal>();
        //Anu added
        Set<String> custNumsPadded = new Set<String>();
        Map<String, List<Object>> mapSAPCustWithItems = new Map<String, List<Object>>();
        
        for(String key : responseMap1.keySet()){
            Map<String, Object> responseMap2 = (Map<String, Object>) responseMap1.get(key);
            Map<String, Object> exOutput = (Map<String, Object>) responseMap2.get('EX_OUTPUT');
            if (exOutput == null) {
                return;
            }
            
            List<Object> items = (List<Object>) exOutput.get('item');
            if (items == null || items.isEmpty()) return;
            
            for (Object obj : items) {
                Map<String, Object> row = (Map<String, Object>) obj;
                String custNo = (String) row.get('KUNNR');
                Decimal outAmt = Decimal.valueOf(String.valueOf(row.get('OUTSTAND_AMT')));
                if (!String.isBlank(custNo) && outAmt != null) {
                    String paddedCustNo = padLeft(custNo, 10, '0');
                    //Added by Anu
                    if(mapSAPCustWithItems.containsKey(paddedCustNo)){
                        List<Object> objRec =  mapSAPCustWithItems.get(paddedCustNo);
                        objRec.add(obj);
                        mapSAPCustWithItems.put(paddedCustNo, objRec);
                    } else {
                        mapSAPCustWithItems.put(paddedCustNo, new List<Object>{obj});
                    }
                    if(custToOutstanding.containsKey(paddedCustNo)){
                        custToOutstanding.put(paddedCustNo, custToOutstanding.get(paddedCustNo) + outAmt);
                    } else {
                        custToOutstanding.put(paddedCustNo, outAmt);
                    }
                    custNumsPadded.add(paddedCustNo);
                }
            }
        }
        
        //Added by Anu
        
        Set<Id> oppsId = new Set<Id>();
        List<Opportunity> oppsToUpdate = [
            SELECT Id, EYI_SAP_Customer_Number__c, EYI_Outstanding_Amount__c
            FROM Opportunity
            WHERE EYI_SAP_Customer_Number__c IN :custNumsPadded
        ];
        
        system.debug('oppsToUpdate '+ oppsToUpdate);
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Map<String,String> mapSAPNumberToOppId = new Map<String,String>();
        for (Opportunity opp : oppsToUpdate) {
            oppsId.add(opp.Id);
            String custNum = padLeft(String.valueOf(opp.EYI_SAP_Customer_Number__c), 10, '0');
            mapSAPNumberToOppId.put(custNum,opp.Id);
            
            /*String custNum = padLeft(String.valueOf(opp.EYI_SAP_Customer_Number__c), 10, '0');
            mapSAPNumberToOppId.put(custNum,opp.Id);
            if (custToOutstanding.containsKey(custNum)) {
            opp.EYI_Outstanding_Amount__c = custToOutstanding.get(custNum);
            oppToUpdate.add(opp);
            }*/
        }
        //Added by Anu
        List<EYI_SAP_Report__c> deleteSAPReport = new List<EYI_SAP_Report__c>();
        String outAmtRecordTypeId = Schema.SObjectType.EYI_SAP_Report__c.getRecordTypeInfosByDeveloperName().get('EYI_SAP_Outstanding_Report').getRecordTypeId();
        
        deleteSAPReport = [SELECT id from EYI_SAP_Report__c where Opportunity__c IN:oppsId AND RecordTypeId=:outAmtRecordTypeId];
        if (!deleteSAPReport.isEmpty()) {
            delete deleteSAPReport;
        }
        
        List<EYI_SAP_Report__c> insertToSAPReport = new List<EYI_SAP_Report__c>();
        
        for (Opportunity opp : oppsToUpdate) {
            for(Object obj :mapSAPCustWithItems.get(opp.EYI_SAP_Customer_Number__c)){
                Map<String, Object> row = (Map<String, Object>) obj;
                System.debug('row data ==>'+row);
                System.debug('row data2 ==>'+Decimal.valueOf(String.valueOf(row.get('VBELN'))));
                //Decimal outAmt = Decimal.valueOf(String.valueOf(row.get('OUTSTAND_AMT')));
                //Integer salesDoc = (Integer.valueOf(row.get('VBELN')));
                EYI_SAP_Report__c report = new EYI_SAP_Report__c();
                report.Opportunity__c = mapSAPNumberToOppId.get(opp.EYI_SAP_Customer_Number__c);
                report.EYI_SAP_Customer_Number__c = opp.EYI_SAP_Customer_Number__c;
                report.EYI_SAP_Outstanding_Amount__c =Decimal.valueOf(String.valueOf(row.get('OUTSTAND_AMT')));
                report.RecordTypeId = outAmtRecordTypeId;
                System.debug('row data ==>'+Decimal.valueOf(String.valueOf(row.get('VBELN'))));
                report.EYI_Sales_Document_Number__c = Decimal.valueOf(String.valueOf(row.get('VBELN')));
                report.EYI_SO_Line_Item__c = Integer.valueOf(row.get('POSNR'));
                report.EYI_Customer_Name__c = String.valueOf(row.get('CUST_NAME'));
                report.EYI_Material__c = String.valueOf(row.get('MATNR'));
                report.EYI_Material_Description__c = String.valueOf(row.get('ARKTX'));
                report.EYI_Recon_Account__c = Integer.valueOf(row.get('AKONT'));
                report.EYI_Recon_Account_Description__c =String.valueOf(row.get('TXT50'));
                report.EYI_Total_Consideration__c = Decimal.valueOf(String.valueOf(row.get('NETWR')));
                report.EYI_Actual_Basic_Bill_Amount__c = Decimal.valueOf(String.valueOf(row.get('BILL_AMT_EX_TX')));
                report.EYI_Debit_Amount__c = Decimal.valueOf(String.valueOf(row.get('V_DEBIT')));
                report.EYI_Tax_Amount__c = Decimal.valueOf(String.valueOf(row.get('TOT_TAX')));
                report.EYI_Billed_Amt_Debit_Note_Amt__c = Decimal.valueOf(String.valueOf(row.get('BILLD_AMT')));
                report.EYI_Received_Amount__c = Decimal.valueOf(String.valueOf(row.get('RECVD_AMT')));
                report.EYI_Outstanding_Amount__c = Decimal.valueOf(String.valueOf(row.get('OUTSTAND_AMT')));
                report.EYI_Profit_Center_Name__c = String.valueOf(row.get('PRCTR'));
                report.EYI_Reason_For_Rejection__c = String.valueOf(row.get('TEXT'));
                report.EYI_Plant__c = String.valueOf(row.get('WERKS'));
                report.EYI_Flat__c = String.valueOf(row.get('FLAT_NAME'));
                report.EYI_Sales_Org__c = String.valueOf(row.get('VKORG'));
                report.EYI_Sales_Org_Description__c = String.valueOf(row.get('VTEXT'));
                report.EYI_Company_Name__c = String.valueOf(row.get('BUKRS'));
                report.EYI_Distribution_Channel__c = Integer.valueOf(row.get('VTWEG'));
                report.EYI_Area__c = Decimal.valueOf(String.valueOf(row.get('KWMENG')));
                report.EYI_Booking_Date__c	= Date.valueOf(String.valueOf(row.get('ERDAT')));
                report.EYI_Rejection__c = String.valueOf(row.get('ABGRU'));
                report.EYI_Profit_Center_Name__c = String.valueOf(row.get('VPRCTR_LTEXT'));
                report.EYI_Building_Name__c  = String.valueOf(row.get('BUILD_NAME'));
                report.EYI_Credit_Amount__c = Decimal.valueOf(String.valueOf(row.get('V_CREDIT')));
                report.EYI_After_Deduction_Basic_Bill__c = Decimal.valueOf(String.valueOf(row.get('V_BBILL')));
				
                String aedDateStr = String.valueOf(row.get('ZZAGRMT_DT'));
                report.EYI_Agreement_Execution_Date__c = parseCustomDateFormat(aedDateStr);
                
                String ahdDateStr = String.valueOf(row.get('ZZAGRMT_HND_DT'));
                report.EYI_Agreement_Handover_Date__c = parseCustomDateFormat(ahdDateStr);
                
                String ardDateStr = String.valueOf(row.get('ZZAGRMT_RECV_DT'));
                report.EYI_Agreement_Received_Date__c = parseCustomDateFormat(ardDateStr);
                
                
                report.EYI_Agreement_Registration_Number__c = String.valueOf(row.get('ZZAGRMT_REG_NO'));
                report.EYI_Sales_Deed_Number__c = String.valueOf(row.get('ZZSALES_DEED_NO'));
                
                String aregdDateStr = String.valueOf(row.get('ZZSALES_DEED_DT'));
                report.EYI_Registration_Date__c = parseCustomDateFormat(aregdDateStr);
				
				String acandDateStr = String.valueOf(row.get('ZZCANL_DT'));
                report.EYI_Cancellation_Date__c = parseCustomDateFormat(acandDateStr);
				
               
                report.EYI_Cancellation_Initiated_By__c = String.valueOf(row.get('ZZCANL_INIT_BY'));
                report.EYI_Sales_Type__c = String.valueOf(row.get('ZZ_SALES'));
                report.EYI_Property_Tax_Number__c = String.valueOf(row.get('ZZ_PROPERTY_TAX_NUMBER'));
				
				String afrankdDateStr = String.valueOf(row.get('ZZ_FRANKING_DATE'));
                report.EYI_Franking_Date__c = parseCustomDateFormat(afrankdDateStr);
				
               
                report.EYI_Stamp_Duty_Amount__c = Decimal.valueOf(String.valueOf(row.get('ZZ_STAMP_DUTY')));
                report.EYI_Stamp_Duty_Amount_FI__c = Decimal.valueOf(String.valueOf(row.get('ZZ_SD_FI')));
                report.EYI_Payment_Project__c = String.valueOf(row.get('ZZ_PAY_PROJECT'));
                report.EYI_CRM_Mapped__c = String.valueOf(row.get('LIFNR'));
                report.EYI_Name_of_CRM_Mapped__c = String.valueOf(row.get('LIFNR_NAME'));
                insertToSAPReport.add(report);                
            }            
        }	
        
        if (!insertToSAPReport.isEmpty()) {
            insert insertToSAPReport;
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