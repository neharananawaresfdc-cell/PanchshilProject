/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EYI_SAP_CaseCancellationPayController {
    

    // Wrapper class for unified data fetch
    public class CancellationPageData {
        @AuraEnabled public Case cancellationDetail;
        @AuraEnabled public Opportunity opportunity;
        @AuraEnabled public Quote quote;
        @AuraEnabled public EYI_Booking__c booking;
        
    }

    /*@AuraEnabled
    public static void uploadFile(String base64Data, String caseId) {
        base64Data = base64Data.replace('data:image/png;base64,', '');
        Blob fileBody = EncodingUtil.base64Decode(base64Data);
    
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Case Print';
        contentVersion.PathOnClient = 'case_print.png';
        contentVersion.VersionData = fileBody;
        insert contentVersion;
    
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        link.LinkedEntityId = caseId;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;
    }*/

    @AuraEnabled
    public static Id fetchOppId(Id recordId){
        RecordType recType = [Select id,DeveloperName,SobjectType from RecordType Where SobjectType = 'Case' and DeveloperName ='Cancellation'];
        List<Case> cancelDetails = [SELECT EYI_Opportunity__c FROM Case WHERE Id = :recordId and RecordTypeId =:recType.Id LIMIT 1];
        return !cancelDetails.isEmpty() ? cancelDetails[0].EYI_Opportunity__c : null;
    }
    
    @AuraEnabled
    public static Boolean getPaymentReceiptDetails(Id recordId){
        Boolean paymentReceipt = false;
        List<EYI_Payment_Receipt__c> paymentReceiptList = [SELECT Id,EYI_Payment_Status__c FROM EYI_Payment_Receipt__c where (EYI_Payment_Status__c = null OR EYI_Payment_Status__c ='REJECT') AND EYI_Opportunity__c =: recordId];
        if(paymentReceiptList.Size() > 0){
           paymentReceipt = true; 
        }
        return paymentReceipt;
    }

    @AuraEnabled
    public static Case fetchCancellationDetails(Id recordId){
        try{
            System.debug('fetchCancellationDetails recordId : '+recordId);
            
        // Declare the query string
        String query = 'SELECT EYI_Opportunity__c,EYI_Sub_Type__c,EYI_IsCancellationFetched__c, EYI_Cancellation_Type__c,IsCancellationSubmitted__c, EYI_Cancellation_Subtype__c,EYI_TDS_Amount__c, ' +
            'EYI_Cancellation_Reason__c, EYI_Cancellation_Status__c, EYI_Cancellation_Commencement__c,EYI_Adjustment_Remarks__c,EYI_Forfeiture_Remarks__c, ' +
            'EYI_Cancellation_Remarks__c, EYI_Date_of_Cancellation_initiated__c, EYI_Retention_Enablers__c,EYI_Interest_Charged_Remarks__c, ' +
            'EYI_Retention_Remarks__c, EYI_Retained_by_User__c, EYI_Retention_Date__c, EYI_Registration_Status__c,EYI_Brokerage_Charged_Remarks__c, ' +
            'EYI_Bank_Name__c, Bank_Name__c, EYI_Instrument_Details__c, EYI_Account_No__c, EYI_Cheque__c, ' +
            'EYI_Total_Received_Amount__c, EYI_TotalAmountCharged__c, EYI_Amount_to_Cust_of_Other_Adjustment__c, ' +
            'EYI_Total_Refund_Given__c, EYI_Demanded_Amount_Principal__c, EYI_Reversal_Demanded_Amount_Principal__c, ' +
            'EYI_Demanded_Amount_Tax__c, EYI_Reversal_Demanded_Amount_Tax__c, EYI_Demand_Amount_Charged_to_Customer__c, ' +
            'EYI_Reversal_to_Customer__c, EYI_Debit_Note_Principal__c, EYI_Credit_Note_Principal__c, ' +
            'EYI_Debit_Note_Tax__c, EYI_Credit_Note_Tax__c, EYI_Reversal_Debit_Note_Principal__c, ' +
            'EYI_Reversal_Credit_Note_Principal__c, EYI_Reversal_Debit_Note_Tax__c, EYI_Reversal_Credit_Note_Tax__c, ' +
            'EYI_Debit_Note_Charged_to_Customer__c, EYI_Credit_Note_Charged_to_Customer__c, EYI_Total_Interest_Accured__c, ' +
            'EYI_Interest_Waiver__c, EYI_Total_Interest_Charged__c, EYI_Brokerage_Amount__c, EYI_Brokerage_Waiver__c,EYI_Payment_Done__c, ' +
            'EYI_Total_Brokerage_Charged__c, EYI_Other_Adjustments_Included__c, EYI_Other_Adjustments__c, EYI_IFSC_Code__c, ' +
            'EYI_Amount_be_Forfeited__c,EYI_Beneficiary_Name__c,EYI_Remark_For_Finance__c, EYI_Forfeit_Amount__c,EYI_Branch_Name__c,EYI_Cancellation_Request_Date__c,EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,EYI_Opportunity__r.EYI_SAP_Customer_Number__c FROM Case ';

        // Build the WHERE clause based on recordId prefix
        String cancellationRecIdStratWith =System.label.Cancellation_RecordId;
        if (recordId != null && String.valueOf(recordId).startsWith(cancellationRecIdStratWith)) {
            query += 'WHERE Id = :recordId';
        } else if (String.valueOf(recordId).startsWith('006')) {
            //query += 'WHERE EYI_Opportunity__c = :recordId';
            query += 'WHERE EYI_Opportunity__c = :recordId AND RecordType.Name = \'Cancellation\'';
        } else {
            throw new AuraHandledException('Invalid record Id prefix.');
        }

        List<Case> cancelDetail = Database.query(query);
        if (cancelDetail.isEmpty()) {
            return null;  // Or you can throw a custom error/message
        }

        return cancelDetail[0];
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
            SELECT Id,Name,StageName,EYI_Mode_of_Funding__c, EYI_SAP_Customer_Number__c, EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,EYI_Walk_in_Source__c,
            EYI_Sourcing_Manager__r.Name, EYI_Relationship_Manager__r.Name, EYI_Primary_Closing_Manager__r.Name,EYI_REC__r.EYI_REC_Vendor_Code__c
            FROM Opportunity WHERE Id = :recordId
        ];
        System.debug('oppDetails : '+oppDetails);
        return !oppDetails.isEmpty() ? oppDetails[0] : null ;
    }
    @AuraEnabled
    public static EYI_Brokerage__c fetchBrokerDetails(Id recordId){
        List<EYI_Brokerage__c> brokerageList = [SELECT Id,EYI_SAP_PO_Number__c from EYI_Brokerage__c where EYI_REC_Account__r.Branding_Opportunity__c =: recordId];
        System.debug('brokerageList : '+brokerageList);
        return !brokerageList.isEmpty() ? brokerageList[0] : null ;
    }

    @AuraEnabled
    public static String getApiData(String filterString){
        try {
            System.debug('filterString :: '+filterString);
            HTTPResponse res = EY_SAP_Gateway.getSAPCancellationPaymentDetails(filterString);
            String apiResponse = res.getBody();
            System.debug('statusCode : '+res.getStatusCode());
            System.debug('apiResponse@@ : '+apiResponse);
            return apiResponse;   
        } catch (Exception e) {
            System.debug('e.getMessage() : '+e.getMessage());
            /*if (e.getMessage().contains('StatusCode=404')) {
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
            }*/
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Quote fetchQuoteDetails(Id opportunityId) {
        List<Quote> quoteList =[
            SELECT Id,EYI_Agreement_Value__c, TotalPrice, Stamp_Duty__c,EYI_Quoatation_Grand_Total__c
            FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = true LIMIT 1];
        return !quoteList.isEmpty() ? quoteList[0] : null;
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
    @AuraEnabled
    public static EYI_REC__c fetchRecDetails(Id opportunityId) {
        Opportunity opp = [
            SELECT EYI_REC__r.Name,EYI_REC__r.EYI_REC_Vendor_Code__c, EYI_REC__r.EYI_RERA_Number__c,EYI_REC__r.EYI_RERA_Certificate_No__c, EYI_REC__r.EYI_REC_Code__c 
            FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];
        return opp.EYI_REC__r;
    }

    @AuraEnabled(cacheable=true)
    public static EYI_Brokerage__c fetchBrokerageDetails(Id opportunityId) {
       List<EYI_Brokerage__c> brokerageList = [
            SELECT EYI_Brokerage_Amount__c
            FROM EYI_Brokerage__c
            WHERE EYI_Opportunity__c = :opportunityId
            LIMIT 1];
        return !brokerageList.isEmpty() ? brokerageList[0] : null;
        
    }
    @AuraEnabled
    public static Case checkCancellationFetchedDetails(Id recordId){
        return [Select Id,EYI_IsCancellationFetched__c from Case Where Id =: recordId];
    }

    @AuraEnabled
    public static String saveCancellationDetails(Map<String, Object> data) {
        System.debug('Entering saveCancellationDetails method');
        System.debug('Data received: ' + data);

        try {
            String recordId = (String) data.get('Id');
            System.debug('Record ID: ' + recordId);
            Set<String> dateFields = new Set<String>{'EYI_Retention_Date__c','EYI_Cancellation_Request_Date__c', 'EYI_Date_of_Cancellation_initiated__c'};
            Set<String> decimalFields = new Set<String>{'EYI_Total_Received_Amount__c','EYI_Reversal_to_Customer__c','EYI_TotalAmountCharged__c',
                'EYI_Amount_to_Cust_of_Other_Adjustment__c','EYI_Total_Refund_Given__c','EYI_Payment_Done__c',
                'EYI_Reversal_To_Customer__c','EYI_Demanded_Amount_Principal__c',
                'EYI_Reversal_Demanded_Amount_Principal__c','EYI_Demanded_Amount_Tax__c',
                'EYI_Reversal_Demanded_Amount_Tax__c','EYI_Demand_Amount_Charged_to_Customer__c',
                'EYI_Debit_Note_Principal__c','EYI_Credit_Note_Principal__c','EYI_Debit_Note_Tax__c',
                'EYI_Credit_Note_Tax__c','EYI_Reversal_Debit_Note_Principal__c',
                'EYI_Reversal_Credit_Note_Principal__c','EYI_Reversal_Debit_Note_Tax__c',
                'EYI_Reversal_Credit_Note_Tax__c','EYI_Debit_Note_Charged_to_Customer__c',
                'EYI_Credit_Note_Charged_to_Customer__c','EYI_Total_Interest_Accured__c',
                'EYI_Interest_Waiver__c','EYI_Total_Interest_Charged__c','EYI_Brokerage_Amount__c',
                'EYI_Brokerage_Waiver__c','EYI_Total_Brokerage_Charged__c','EYI_Other_Adjustments__c',
                'EYI_Forfeit_Amount__c','EYI_TDS_Amount__c',
                'EYI_Down_Payment_Amount_Principal__c','EYI_Down_Payment_Amount_Tax__c','EYI_Reversal_Down_Payment_Amt_Principal__c',
                'EYI_Reversal_Down_Payment_Amt_Tax__c','EYI_Down_Payment_Amt_Charged_To_Customer__c'};

            Case cancellation = new Case();
            // for (String fieldName : data.keySet()) {
            //     cancellation.put(fieldName, data.get(fieldName));
            // }
            for (String fieldName : data.keySet()) {
                
                /*if(fieldName == 'EYI_Demand_Amount_Charged_to_Customer__c' || fieldName=='EYI_Reversal_Demanded_Amount_Tax__c'
                   || fieldName == 'EYI_Demanded_Amount_Tax__c' || fieldName=='EYI_Reversal_Demanded_Amount_Principal__c'
                  || fieldName=='EYI_Demanded_Amount_Principal__c' || fieldName=='EYI_Total_Refund_Given__c' 
                  || fieldName == 'EYI_Amount_to_Cust_of_Other_Adjustment__c' || fieldName =='EYI_TotalAmountCharged__c'
                  || fieldName == 'EYI_Total_Received_Amount__c'){
                    continue;
                }*/
                 Object fieldValue1 = data.get(fieldName);
                    System.debug('fieldName : '+fieldName);
                    System.debug('fieldValue : '+fieldValue1);
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
                    System.debug('fieldName : '+fieldName);
                    System.debug('fieldValue : '+fieldValue);
                    if (fieldValue != null) {
                        if (fieldValue instanceof Decimal) {
                            cancellation.put(fieldName, (Decimal) fieldValue);
                        }else if (fieldValue instanceof String) {
                            String raw = (String) fieldValue;
                            String cleaned = raw.replaceAll('[^0-9.-]', '');
                            cancellation.put(fieldName, Decimal.valueOf(cleaned));
                        } else if (fieldValue instanceof Boolean) {
                            cancellation.put(fieldName, (Boolean) fieldValue);
                        }else {
                            System.debug('Skipping unsupported type for Decimal field ' + fieldName);
                        }
                    }
                }
                // Handle other types (e.g., String, Integer, etc.)
                else {
                    cancellation.put(fieldName, data.get(fieldName));
                }
                if(fieldName == 'EYI_Reversal_To_Customer__c' && data.get(fieldName) != null){
                     cancellation.put('EYI_IsCancellationFetched__c',true);
                }
            }
            RecordType recType = [Select id,DeveloperName,SobjectType from RecordType Where SobjectType = 'Case' and DeveloperName ='Cancellation'];
			System.debug('cancellation :: '+cancellation);
            cancellation.put('RecordTypeId',recType.Id );
            cancellation.put('EYI_Stages__c','Cancellation Retention in Progress');
            
            upsert cancellation;
            //return [Select Id from Case where Id=:cancellation.Id].Id;
            System.debug('Record updated successfully.');
            return cancellation.Id;

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
}