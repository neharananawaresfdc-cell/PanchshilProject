/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EYI_SAP_ReportController {
    public EYI_SAP_ReportController() {
	System.debug('EYI_SAP_ReportController ');
    }
    @AuraEnabled
    public static String getApiData(String filterString){
        //callout logic pending
        String apiResponse;

        try {
            /*
            EYI_Booking__c bookingData = [SELECT Id, EYI_SAP_Sales_Order_Number__c, EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c,
                                      EYI_Project_Name__r.EYI_SAP_Salesorg__c, EYI_Project_Name__r.EYI_SAP_Plant_Code__c, EYI_Project_Name__r.EYI_Distribution_Channel__c, 
                                      EYI_Divisions__c, EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Office__c, EYI_Opportunity_Name__r.EYI_Opportunity_Number__c, EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Group__c, 
                                      EYI_Actual_Booking_Date__c, EYI_Cancellation_Reason__c, EYI_Opportunity_Name__r.Name, EYI_Agreement_Execution_Date__c, EYI_Agreement_Handover_Date__c, 
                                      EYI_Agreement_Received_Date__c, EYI_Aggrement_Reg_No__c, EYI_Sales_Deed_No__c, EYI_Registration_Date__c, EYI_Possession_Intimation_Date__c, EYI_Agreement_Possession_Date__c, 
                                      EYI_Actual_Possession_Date__c, EYI_Maintenance_wef_Date__c, Transfer_Swapping_Date__c, EYI_Transfer_Swapping_Remarks__c, EYI_Mortgage_Status__c, EYI_Loaning_Institute__c, 
                                      EYI_Loan_Amount__c, EYI_Loan_File_Number__c, EYI_Agreement_Loan_Percentage__c, EYI_Sanction_Date__c, EYI_NOC_Issue_Date__c, EYI_Cancellation_Date__c, 
                                      EYI_Cancellation_initiated_By__c, EYI_Deed_of_Cancellation_Reg_Date__c, EYI_Name_1__c, EYI_Tab_D_Rate_of_Intrest__c, EYI_Self_Banking_for_VA01__c, EYI_Opportunity_Name__r.SyncedQuote.Payment_Plan__c,
                                      EYI_Banking_Remarks_for_VA01__c,EYI_Source_of_Booking__c,EYI_REC_Account__r.EYI_REC_Vendor_Code__c ,EYI_SAP_request__c,EYI_Opportunity_Name__r.EYI_Segment__c       FROM EYI_Booking__c WHERE Id = :recordId];
                                      */

            // Define dynamic columns (get scenario from filters)
            System.debug('filter in function -->'+ filterString);
            Map<String, Object> rawData = (Map<String, Object>) JSON.deserializeUntyped(filterString);
            Map<String, List<String>> filters = new Map<String, List<String>>();

            // Convert Object values to List<String>
            for (String key : rawData.keySet()) {
                List<Object> objectList = (List<Object>) rawData.get(key);
                List<String> stringList = new List<String>();

                for (Object obj : objectList) {
                    stringList.add(String.valueOf(obj));
                }

                filters.put(key, stringList);
                System.debug('Converted req to json --->'+filters);
            }

            
            String reqBodyString = convertMapToJson(filters);
            System.debug('Converted req to json --->'+reqBodyString);
            List<Map<String, String>> columns = getColumnWrapper();

            // Sample data (Mock JSON Response)
            List<Map<String, Object>> records = new List<Map<String, Object>>();
            records.add(new Map<String, Object>{
                'SalesDocument' => '3020000159',
                'SOLineItem' => 10,
                'CustomerNo' => '20000245',
                'CustomerName' => 'Yugantara Vishwakaram',
                'TotalConsideration' => 27006000,
                'BookingDate' => '2023-07-28'
            });

             // Response wrapper logic here
             HTTPResponse res = new HTTPResponse();
             res = EY_SAP_Gateway.getSAPOutsatndingReport(reqBodyString);
             apiResponse = res.getBody();
             System.debug('apiResponse'+apiResponse);
             return apiResponse;

                         // Return both columns and data
            // return new Map<String, Object>{
            //     'columns' => columns,
            //     'data' => records
            // };
         


              

            //String jsonString = '{"EX_MESSAGE":{"Message":""},"EX_OUTPUT":{"item":[{"SalesDocument":"","SOLineItem":"","CustomerNo":"","CustomerName":"","Material":"","MaterialDescription":"","ReconAccount":"","ReconAccountDescription":"","TotalConsideration":"","ActualBasicBillAmount":"","DebitAmount":"","TaxAmount":"","BilledAndDebitNoteAmt":"","ReceivedAmt":"","OutstandingAmt":"","ProfitCenter":"","ReasonForRejection":"","Plant":"","Flat":"","SalesOrg":"","SalesOrgDesc":"","CompanyName":"","DistributionChannel":"","Area":"","BookingDate":"","Rejection":"","ProfitCenterName":"","BuildingName":"","CreditAmount":"","AfterDeductionBasicBill":"","AgreementExecutionDate":"","AgreementHandoverDate":"","AgreementReceivedDate":"","AgreementRegNo":"","SalesDeedNo":"","RegistrationDate":"","CancellationDate":"","CancellationInitiatedBy":"","SalesType":"","PropertyTaxNumber":"","FrankingDate":"","StampDutyAmountSD":"","StampDutyAmountFI":"","PaymentProject":"","CRMMapped":"","NameOfCRMMapped":""}]}}';
            //return EYI_SAP_ReportResponseWrapper.parse(jsonString);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
       
    }
    private static List<Map<String, String>> getColumnWrapper(){
        List<Map<String, String>> columns = new List<Map<String, String>>();
            
        columns.add(new Map<String, String>{'label' => 'Sales Document', 'fieldName' => 'SalesDocument', 'type' => 'text'});
        columns.add(new Map<String, String>{'label' => 'Line Item', 'fieldName' => 'SOLineItem', 'type' => 'number'});
        columns.add(new Map<String, String>{'label' => 'Customer No', 'fieldName' => 'CustomerNo', 'type' => 'text'});
        columns.add(new Map<String, String>{'label' => 'Customer Name', 'fieldName' => 'CustomerName', 'type' => 'text'});
        columns.add(new Map<String, String>{'label' => 'Total Consideration', 'fieldName' => 'TotalConsideration', 'type' => 'currency'});
        columns.add(new Map<String, String>{'label' => 'Booking Date', 'fieldName' => 'BookingDate', 'type' => 'date'});
        return columns;
    }
    private static String convertMapToJson(Map<String, List<String>> inputMap) {
        Map<String, Object> outputJson = new Map<String, Object>();
        Map<String, Object> jsonRoot = new Map<String, Object>();
    
        for (String key : inputMap.keySet()) {
            List<String> values = inputMap.get(key);
            if (key == 'KeyDate' && values != null && !values.isEmpty()) {
                // Handle KeyDate as a single value instead of list
                jsonRoot.put(key, values[0]);
            } else {
                List<Map<String, String>> itemList = new List<Map<String, String>>();
    
                for (String value : values) {
                Map<String, String> item = new Map<String, String>();
                item.put('SIGN', 'I');
                item.put('OPTION', 'EQ');
                item.put('LOW', value);
                item.put('HIGH', '');
                itemList.add(item);
            }
    
            Map<String, Object> itemWrapper = new Map<String, Object>();
            itemWrapper.put('item', itemList);
            jsonRoot.put(key, itemWrapper);
        }
        }
    
        outputJson.put('ZSD_OUTSTANDING_BALANCE_SF', jsonRoot);
        return JSON.serializePretty(outputJson);
    }
    @AuraEnabled(cacheable=true)
    public static List<EYI_Project__c> getAllProjects(){
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        try {
            projectList = [SELECT Id, Name,EYI_SAP_Company_Code__c,EYI_SAPMaterial_Code__c,EYI_SAP_Salesorg__c, EYI_Project_Type__c FROM EYI_Project__c WITH SECURITY_ENFORCED ORDER BY Name ASC];
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return projectList;
    }

    @AuraEnabled
    public static String getAgeingReport(String filterString){
        String apiResponse;
        try {    Map<String, Object> rawData = (Map<String, Object>) JSON.deserializeUntyped(filterString);
            Map<String, List<String>> filters = new Map<String, List<String>>();
        
            // Convert Object values to List<String>
            for (String key : rawData.keySet()) {
                Object rawValue = rawData.get(key);
        
                //  Handle single value fields (like KeyDate)
                if (rawValue instanceof String) {
                    filters.put(key, new List<String>{String.valueOf(rawValue)});
                }
                //  Handle list fields (like CompanyCode, CustomerNo, etc.)
                else if (rawValue instanceof List<Object>) {
                    List<Object> objectList = (List<Object>) rawValue;
                    List<String> stringList = new List<String>();
        
                    for (Object obj : objectList) {
                        stringList.add(String.valueOf(obj));
                    }
        
                    filters.put(key, stringList);
                }
            }
        
            System.debug('Converted req to JSON --->' + filters);
        
            //  Generate the response body using a separate method
            String reqBodyString = convertMapToJsonAgeing(filters);
            System.debug('Final Response JSON --->' + reqBodyString);
             
             
             HTTPResponse res = new HTTPResponse();
             res = EY_SAP_Gateway.getSAPAgeingReport(reqBodyString);
             apiResponse = res.getBody();
             System.debug('apiResponse'+apiResponse);
             return apiResponse;
        
    //string reqBody = JSON.serializePretty(reqBodyString);

    // Convert to JSON string
    //return reqBodyString;
        
        // // Convert to JSON String
        // String requestBody = JSON.serializePretty(finalRequest);
        // List<Map<String, String>> columns = getColumnWrapper();

        //     // Sample data (Mock JSON Response)
        //     List<Map<String, Object>> records = new List<Map<String, Object>>();
        //     records.add(new Map<String, Object>{
        //         'SalesDocument' => '3020000159',
        //         'SOLineItem' => 10,
        //         'CustomerNo' => '20000245',
        //         'CustomerName' => 'Yugantara Vishwakaram',
        //         'TotalConsideration' => 27006000,
        //         'BookingDate' => '2023-07-28'
        //     });
        // System.debug('Generated Request Body: ' + requestBody);
        // return new Map<String, Object>{
        //         'columns' => columns,
        //         'data' => records
        //     };
        //return requestBody;
    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String convertMapToJsonAgeing(Map<String, List<String>> inputMap) {
        Map<String, Object> jsonRoot = new Map<String, Object>();
    
        for (String key : inputMap.keySet()) {
            List<String> values = inputMap.get(key);
    
            //  Handle KeyDate as a single string value
            if (key == 'KeyDate' && values != null && !values.isEmpty()) {
                jsonRoot.put(key, values[0]);
            } 
            //  Handle DueDays directly as string values
            else if (key.startsWith('DueDays')) {
                if (values != null && !values.isEmpty()) {
                    jsonRoot.put(key, values[0]);  // Only one value for each DueDays key
                }
            } 
            //  Handle other fields as a list of objects
            else {
                List<Map<String, String>> itemList = new List<Map<String, String>>();
    
                for (String value : values) {
                    Map<String, String> item = new Map<String, String>();
                    item.put('SIGN', 'I');
                    item.put('OPTION', 'EQ');
                    item.put('LOW', value);
                    item.put('HIGH', '');
                    itemList.add(item);
                }
    
                Map<String, Object> itemWrapper = new Map<String, Object>();
                itemWrapper.put('item', itemList);
                jsonRoot.put(key, itemWrapper);
            }
        }
    
        //  Wrap in final structure
        Map<String, Object> responseBody = new Map<String, Object>();
        responseBody.put('AgeingReport', jsonRoot);
    
        return JSON.serialize(responseBody);
    }
    
    @AuraEnabled
    public static string getTDSReport(String filterString){
        try {
            Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(filterString);

    Map<String, Object> responseBody = new Map<String, Object>();
    Map<String, Object> tdsReportAPI = new Map<String, Object>();

    // Iterate over all keys dynamically
    for (String key : inputMap.keySet()) {
        List<Object> values = (List<Object>) inputMap.get(key);
        if (values != null && !values.isEmpty()) { // Only add non-empty lists
            tdsReportAPI.put(key, createFilterItemMap(values));
        }
    }

    responseBody.put('TdsReportAPI', tdsReportAPI);
    
    return JSON.serializePretty(responseBody);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, Object> createFilterItemMap(List<Object> values) {
        Map<String, Object> filterMap = new Map<String, Object>();
        List<Map<String, String>> items = new List<Map<String, String>>();
    
        for (Object value : values) {
            Map<String, String> filterItem = new Map<String, String>{
                'SIGN' => 'I',
                'OPTION' => 'EQ',
                'LOW' => String.valueOf(value),
                'HIGH' => ''
            };
            items.add(filterItem);
        }
    
        filterMap.put('item', items);
        return filterMap;
    }
  
    
}