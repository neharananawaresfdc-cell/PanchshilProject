public with sharing class EYI_RecordDataController {
    // This method returns the PaymentReceipt, Booking, and Demand Data
    @AuraEnabled(cacheable=true)
    public static SObject getRecordData(String recordId, String objectApiName) {
        if (String.isEmpty(recordId) || String.isEmpty(objectApiName)) {
            throw new AuraHandledException('Invalid recordId or objectApiName');
        }

        // Use hardcoded queries for each supported object to avoid SOQL injection
        if (objectApiName == 'EYI_Payment_Receipt__c') {
            return [
                SELECT EYI_SAP_Document_Number__c,
                       EYI_SAP_Company_Code__c,
                       EYI_Fiscal_Year__c
                FROM EYI_Payment_Receipt__c
                WHERE Id = :recordId
            ];
        } else if (objectApiName == 'EYI_Booking__c') {
            return [
                SELECT EYI_SAP_Customer_Number__c,
                       EYI_Project_Name__r.EYI_SAP_Company_Code__c,
                       EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c,
                       EYI_SAP_Sales_Order_Number__c,
                       EYI_Opp_Customer_Number__c
                FROM EYI_Booking__c
                WHERE Id = :recordId
            ];
        } else if (objectApiName == 'EYI_Demand__c') {
            return [
                SELECT EYI_SAP_Demand_Number__c
                FROM EYI_Demand__c
                WHERE Id = :recordId
            ];
        } else {
            throw new AuraHandledException('Unsupported object type: ' + objectApiName);
        }
    }
}