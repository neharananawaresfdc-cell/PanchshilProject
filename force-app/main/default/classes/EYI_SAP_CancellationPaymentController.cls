public class EYI_SAP_CancellationPaymentController {

    // Wrapper class for unified data fetch
    public class CancellationPageData {
        @AuraEnabled public EYI_Cancellation_Detail__c cancellationDetail;
        @AuraEnabled public Opportunity opportunity;
        @AuraEnabled public Quote quote;
        @AuraEnabled public EYI_Booking__c booking;
        
    }


    /*@AuraEnabled
    public static Id fetchOppId(Id recordId){
        List<EYI_Cancellation_Detail__c> cancelDetails = [SELECT EYI_Opportunity__c FROM EYI_Cancellation_Detail__c WHERE Id = :recordId LIMIT 1];
        return !cancelDetails.isEmpty() ? cancelDetails[0].EYI_Opportunity__c : null;
    }*/
    
    @AuraEnabled
    public static Boolean getPaymentReceiptDetails(Id recordId){
        Boolean paymentReceipt = false;
        String prefix = String.valueOf(recordId).substring(0, 3);
        Id OppId;
    	System.debug('prefix '+prefix+' standard Prefix : '+Case.SObjectType.getDescribe().getKeyPrefix());
        if (prefix == Case.SObjectType.getDescribe().getKeyPrefix()) {
            Case cs = [Select Id,EYI_Opportunity__c from Case where Id=:recordId];
            if(cs != null){
               OppId = cs.EYI_Opportunity__c; 
            }
        }else if (prefix == Opportunity.SObjectType.getDescribe().getKeyPrefix()) {
            OppId = recordId;
        }
        System.debug('OppId : '+OppId);
        if(OppId != null){
          List<EYI_Payment_Receipt__c> paymentReceiptList = [SELECT Id,EYI_Payment_Status__c FROM EYI_Payment_Receipt__c where  EYI_Payment_Status__c !='APPROVE' AND EYI_Opportunity__c =: OppId];
            if(paymentReceiptList.Size() > 0){
               paymentReceipt = true; 
            }  
        }
        
        return paymentReceipt;
    }

   /* @AuraEnabled
    public static EYI_Cancellation_Detail__c fetchCancellationDetails(Id recordId){
        try{
            System.debug('fetchCancellationDetails recordId : '+recordId);

        // Declare the query string
        String query = 'SELECT EYI_Opportunity__c, EYI_Cancellation_Type__c, EYI_Cancellation_Subtype__c, ' +
            'EYI_Cancellation_Reason__c, EYI_Cancellation_Status__c, EYI_Cancellation_Commencement__c, ' +
            'EYI_Cancellation_Remarks__c, EYI_Date_of_Cancellation_initiated__c, EYI_Retention_Enablers__c, ' +
            'EYI_Retention_Remarks__c, EYI_Retained_by_User__c, EYI_Retention_Date__c, EYI_Registration_Status__c, ' +
            'EYI_Bank_Name__c, Bank_Name__c, EYI_Instrument_Details__c, EYI_Account_No__c, EYI_Cheque__c, ' +
            'EYI_Total_Received_Amount__c, EYI_TotalAmountCharged__c, EYI_Amount_to_Cust_of_Other_Adjustment__c, ' +
            'EYI_Total_Refund_Given__c, EYI_Demanded_Amount_Principal__c, EYI_Reversal_Demanded_Amount_Principal__c, ' +
            'EYI_Demanded_Amount_Tax__c, EYI_Reversal_Demanded_Amount_Tax__c, EYI_Demand_Amount_Charged_to_Customer__c, ' +
            'EYI_Reversal_to_Customer__c, EYI_Debit_Note_Principal__c, EYI_Credit_Note_Principal__c, ' +
            'EYI_Debit_Note_Tax__c, EYI_Credit_Note_Tax__c, EYI_Reversal_Debit_Note_Principal__c, ' +
            'EYI_Reversal_Credit_Note_Principal__c, EYI_Reversal_Debit_Note_Tax__c, EYI_Reversal_Credit_Note_Tax__c, ' +
            'EYI_Debit_Note_Charged_to_Customer__c, EYI_Credit_Note_Charged_to_Customer__c, EYI_Total_Interest_Accured__c, ' +
            'EYI_Interest_Waiver__c, EYI_Total_Interest_Charged__c, EYI_Brokerage_Amount__c, EYI_Brokerage_Waiver__c, ' +
            'EYI_Total_Brokerage_Charged__c, EYI_Other_Adjustments_Included__c, EYI_Other_Adjustments__c, EYI_IFSC_Code__c, ' +
            'EYI_Amount_be_Forfeited__c, EYI_Forfeit_Amount__c FROM EYI_Cancellation_Detail__c ';

        // Build the WHERE clause based on recordId prefix
        String cancellationRecIdStratWith =System.label.Cancellation_RecordId;
        if (recordId != null && String.valueOf(recordId).startsWith(cancellationRecIdStratWith)) {
            query += 'WHERE Id = :recordId';
        } else if (String.valueOf(recordId).startsWith('006')) {
            query += 'WHERE EYI_Opportunity__c = :recordId';
        } else {
            throw new AuraHandledException('Invalid record Id prefix.');
        }

        // Execute the query using Database.query with binding
        EYI_Cancellation_Detail__c cancelDetail = Database.query(query);

        System.debug('cancelDetail: ' + cancelDetail);

        return cancelDetail;
        }catch(Exception e){
        	System.debug('Error occurred: ' + e.getMessage());
            throw new AuraHandledException('Error fetching cancellation details: ' + e.getMessage());
        }  
    }

     @AuraEnabled(cacheable=true)
        public static List<Map<String, String>> getUserOptions() {
            List<Map<String, String>> options = new List<Map<String, String>>();
            for (User u : [SELECT Id, Name FROM User WHERE IsActive = true ORDER BY Name]) {
                options.add(new Map<String, String>{
                    'label' => u.Name,
                    'value' => u.Id
                });
            }
            return options;
        }


    @AuraEnabled
    public static Opportunity fetchOppDetails(Id recordId){
        List<Opportunity> oppDetails = [
            SELECT Id, EYI_SAP_Customer_Number__c, EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
            EYI_Sourcing_Manager__r.Name, EYI_Relationship_Manager__r.Name, EYI_Primary_Closing_Manager__r.Name
            FROM Opportunity WHERE Id = :recordId
        ];
        return !oppDetails.isEmpty() ? oppDetails[0] : null ;
    }

    @AuraEnabled
    public static String getApiData(String filterString){
        try {
            System.debug('filter in function -->'+ filterString);
            HTTPResponse res = EY_SAP_Gateway.getSAPCancellationPaymentDetails(filterString);
            String apiResponse = res.getBody();
            System.debug('statusCode : '+res.getStatusCode());
            System.debug('apiResponse : '+apiResponse);
            return apiResponse;   
        } catch (Exception e) {
            System.debug('e.getMessage() : '+e.getMessage());
            if (e.getMessage().contains('StatusCode=404')) {
                String fallbackJson = JSON.serialize(new Map<String, Object>{
                    'EX_MESSAGE'    => '',
                    'COMP_CODE'     => '',
                    'CUSTOMER'      => '',
                    'DEMAND_P'      => 1500000,
                    'DEMAND_P_R'    => 1500000,
                    'PAID_P'        => 1200,
                    'REFUND_T'      => 1200,
                    'DEMAND_T'      => 180000,
                    'DEMAND_T_R'    => 120000,
                    'PAID_T'        => 0,
                    'BROKERAGE'     => 300000,
                    'INTEREST_C'    => 118000,
                    'DEBIT_P'       => 1000,
                    'CREDIT_P'      => 0,
                    'DEBIT_T'       => 0,
                    'CREDIT_T'      => 0,
                    'DEBIT_P_R'     => 1000,
                    'CREDIT_P_R'    => 0,
                    'DEBIT_T_R'     => 0,
                    'CREDIT_T_R'    => 0,
                    'CUST1'         => '',
                    'CUST2'         => '',
                    'CUST3'         => '',
                    'CUST4'         => ''
                });
                return fallbackJson;
            }
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Quote fetchQuoteDetails(Id opportunityId) {
        String query = 'SELECT EYI_Agreement_Value__c, TotalPrice, Stamp_Duty__c FROM Quote WHERE OpportunityId = :opportunityId';
        if (!Test.isRunningTest()) {
            query += ' AND IsSyncing = true';
        }
        query += ' LIMIT 1';
        List<Quote> quotes = Database.query(query);
        return quotes.isEmpty() ? null : quotes[0];
    }

    @AuraEnabled(cacheable=true)
    public static EYI_Booking__c fetchBookingDetails(Id bookingId) {
        return [
            SELECT EYI_SAP_Sales_Order_Number__c, EYI_Source_of_Booking__c 
            FROM EYI_Booking__c WHERE EYI_Opportunity_Name__c = :bookingId LIMIT 1
        ];
    }
      @AuraEnabled(cacheable=true)
public static EYI_Applicants__c fetchApplicantDetails(Id opportunityId) {
    
   List<EYI_Applicants__c> applicants =[
       SELECT Name, Primary_Applicant__r.EYI_Applicant_Type__c
		FROM EYI_Applicants__c
		WHERE Opportunity__c =:opportunityId
  		AND EYI_Applicant_Type__c = 'Primary Applicant'
        LIMIT 1
    ];
    System.debug('applicants '+applicants);
    return applicants.isEmpty() ? null : applicants[0];
}
     @AuraEnabled(cacheable=true)
public static EYI_REC__c fetchRecDetails(Id opportunityId) {
    Opportunity opp = [
        SELECT EYI_REC__r.Name, EYI_REC__r.EYI_RERA_Number__c, EYI_REC__r.EYI_REC_Code__c 
        FROM Opportunity WHERE Id = :opportunityId LIMIT 1
    ];
    return opp.EYI_REC__r;
}

@AuraEnabled(cacheable=true)
public static EYI_Brokerage__c fetchBrokerageDetails(Id opportunityId) {
    return [
        SELECT EYI_Brokerage_Amount__c
        FROM EYI_Brokerage__c
        WHERE EYI_Opportunity__c = :opportunityId
        LIMIT 1
    ];
}

    // @AuraEnabled(cacheable=true)
    // public static Opportunity fetchOpportunityDetails(Id opportunityId) {
    //     return [SELECT EYI_Sourcing_Manager__r.Name, EYI_Relationship_Manager__r.Name, EYI_Primary_Closing_Manager__r.Name
    //         FROM Opportunity WHERE Id = :opportunityId LIMIT 1
    //     ];
    // }

    @AuraEnabled(cacheable=true)

    public static CancellationPageData fetchCancellationPageData(Id opportunityId) {
        CancellationPageData data = new CancellationPageData();
        System.debug(LoggingLevel.INFO, 'Opprtunityid for cancellation details: ' + opportunityId);
        data.cancellationDetail = [SELECT EYI_Cancellation_Type__c, EYI_Cancellation_Subtype__c, EYI_Cancellation_Reason__c,
            EYI_Cancellation_Status__c, EYI_Cancellation_Commencement__c, EYI_Registration_Status__c, 
            EYI_Cancellation_Remarks__c, EYI_Date_of_Cancellation_initiated__c, EYI_Retention_Enablers__c,
            EYI_Retention_Remarks__c, EYI_Retained_by_User__c, EYI_Retention_Date__c, EYI_Bank_Name__c
            // EYI_Approval_Retention_Hierarchy__c, EYI_Approval_Cancellation_Hierarchy__c,
            // EYI_Instrument_Details__c, EYI_Applicant__c, EYI_Account_Number__c, EYI_Check_Number__c
            FROM EYI_Cancellation_Detail__c WHERE EYI_Opportunity__c = :opportunityId LIMIT 1
        ];

        // data.opportunity = [SELECT EYI_Sourcing_Manager__r.Name, EYI_Relationship_Manager__r.Name, EYI_Primary_Closing_Manager__r.Name
        //     FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
         System.debug(LoggingLevel.INFO, 'Opprtunityid for quote details: ' + opportunityId);
        List<Quote> quoteList = [
            SELECT EYI_Agreement_Value__c, TotalPrice, Stamp_Duty__c 
            FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = true LIMIT 1
        ];

        if (!quoteList.isEmpty()) {
            data.quote = quoteList[0];
        } else {
            data.quote = null;
        }
        // data.quote = [
        //     SELECT EYI_Agreement_Value__c, TotalPrice, Stamp_Duty__c 
        //     FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = true LIMIT 1
        // ];
        System.debug(LoggingLevel.INFO, 'Opprtunityid for booking details: ' + opportunityId);
        data.booking = [SELECT EYI_SAP_Sales_Order_Number__c, EYI_Source_of_Booking__c 
            FROM EYI_Booking__c WHERE EYI_Opportunity_Name__c = :opportunityId LIMIT 1];


        return data;
    }

    @AuraEnabled
    public static void saveCancellationDetails(Map<String, Object> data) {
        System.debug('Entering saveCancellationDetails method');
        System.debug('Data received: ' + data);

        try {
            String recordId = (String) data.get('Id');
            System.debug('Record ID: ' + recordId);
            Set<String> dateFields = new Set<String>{'EYI_Retention_Date__c', 'EYI_Date_of_Cancellation_initiated__c'};
            Set<String> decimalFields = new Set<String>{'EYI_Total_Received_Amount__c', 'EYI_TotalAmountCharged__c','EYI_Amount_to_Cust_of_Other_Adjustment__c','EYI_Total_Refund_Given__c','EYI_Reversal_To_Customer__c','EYI_Demanded_Amount_Principal__c','EYI_Reversal_Demanded_Amount_Principal__c','EYI_Demanded_Amount_Tax__c','EYI_Reversal_Demanded_Amount_Tax__c','EYI_Demand_Amount_Charged_to_Customer__c','EYI_Debit_Note_Principal__c','EYI_Credit_Note_Principal__c','EYI_Debit_Note_Tax__c','EYI_Credit_Note_Tax__c','EYI_Reversal_Debit_Note_Principal__c','EYI_Reversal_Credit_Note_Principal__c','EYI_Reversal_Debit_Note_Tax__c','EYI_Reversal_Credit_Note_Tax__c','EYI_Debit_Note_Charged_to_Customer__c','EYI_Credit_Note_Charged_to_Customer__c','EYI_Total_Interest_Accured__c','EYI_Interest_Waiver__c','EYI_Total_Interest_Charged__c','EYI_Brokerage_Amount__c','EYI_Brokerage_Waiver__c','EYI_Total_Brokerage_Charged__c','EYI_Other_Adjustments__c','EYI_Forfeit_Amount__c'};

            EYI_Cancellation_Detail__c cancellation = new EYI_Cancellation_Detail__c();
            // for (String fieldName : data.keySet()) {
            //     cancellation.put(fieldName, data.get(fieldName));
            // }
            for (String fieldName : data.keySet()) {

                // Handling Date fields (conversion to Date)
                if (dateFields.contains(fieldName)) {
                    if (data.get(fieldName) != null) {
                        try {
                            cancellation.put(fieldName, Date.valueOf((String) data.get(fieldName))); // Convert string to Date
                        } catch (Exception e) {
                            System.debug('Error converting Date field ' + fieldName + ': ' + e.getMessage());
                        }
                    }
                }
                // Handling Decimal fields (conversion to Decimal)
                else if (decimalFields.contains(fieldName)) {
                    Object fieldValue = data.get(fieldName);
                    if (fieldValue != null) {
                        if (fieldValue instanceof Decimal) {
                            cancellation.put(fieldName, (Decimal) fieldValue);
                        } else if (fieldValue instanceof String) {
                            String raw = (String) fieldValue;
                            String cleaned = raw.replaceAll('[^0-9.-]', '');
                            cancellation.put(fieldName, Decimal.valueOf(cleaned));
                        } else {
                            System.debug('Skipping unsupported type for Decimal field ' + fieldName);
                        }
                    }


                }
                // Handle other types (e.g., String, Integer, etc.)
                else {
                    cancellation.put(fieldName, data.get(fieldName));
                }
            }

            upsert cancellation;
            System.debug('Record updated successfully.');

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }*/
    
    @AuraEnabled
    public static ResponseWrapper checkCaseStatus(Id recordId) {
        // Default error response
        ResponseWrapper response = new ResponseWrapper('e', 'Unknown error');
    
        try {
            String prefix = String.valueOf(recordId).substring(0, 3);
    		System.debug('prefix '+prefix+' standard Prefix : '+Case.SObjectType.getDescribe().getKeyPrefix());
            if (prefix == Case.SObjectType.getDescribe().getKeyPrefix()) {
                System.debug('Inside case if ');
                // === CASE ID ===
                List<Case> caseList = [
                    SELECT Id, RecordType.Name, EYI_Case_Approval_Status__c
                    FROM Case
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                System.debug('caseList : '+caseList);
                if (caseList.isEmpty()) {
                    response.message = 'Cancellation case not found.';
                } else {
                    Case caseRecord = caseList[0];
    				System.debug('caseRecord.RecordType.Name : '+caseRecord.RecordType.Name);
                    System.debug('caseRecord.EYI_Case_Approval_Status__c : '+caseRecord.EYI_Case_Approval_Status__c);
                    
                    if (caseRecord.RecordType.Name != 'Cancellation') {
                        response.message = 'Cancellation case not found.';
                    } else if (caseRecord.EYI_Case_Approval_Status__c != 'Approved by Functional Head') {
                        System.debug('Please approve the case first');
                        response.message = 'Please approve the case first.';
                    } else {
                        System.debug('Case is okay to procced');
                        response = new ResponseWrapper('s', 'Case is approved');
                    }
                }
    
            } else if (prefix == Opportunity.SObjectType.getDescribe().getKeyPrefix()) {
                // === OPPORTUNITY ID ===
                List<Case> cases = [
                    SELECT Id, EYI_Case_Approval_Status__c
                    FROM Case
                    WHERE EYI_Opportunity__c = :recordId
                    AND RecordType.Name = 'Cancellation'
                    LIMIT 1
                ];
    
                if (cases.isEmpty()) {
                    response.message = 'Cancellation case not found.';
                } else if (cases[0].EYI_Case_Approval_Status__c != 'Approved by Functional Head') {
                    response.message = 'Please approve the case first.';
                } else {
                    response = new ResponseWrapper('s', 'Case is approved');
                }
            } else {
                response.message = 'Invalid record Id';
            }
    	
        } catch (Exception ex) {
            System.debug('Error in checkCaseStatus: ' + ex.getMessage());
            response = new ResponseWrapper('e', 'An unexpected error occurred: ' + ex.getMessage());
        }
    return response;
        
    }

    
    public class ResponseWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public String message;
    
        public ResponseWrapper(String type, String message) {
            this.type = type;
            this.message = message;
        }
    }

}