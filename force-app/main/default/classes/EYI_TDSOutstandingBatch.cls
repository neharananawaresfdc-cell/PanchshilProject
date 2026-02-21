global class EYI_TDSOutstandingBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, EYI_SAP_Customer_Number__c, EYI_TDS_Outstanding__c,
                   EYI_Project_Enquired__r.EYI_SAP_Company_Code__c
            FROM Opportunity
            WHERE EYI_SAP_Customer_Number__c != null
              AND EYI_Project_Enquired__r.EYI_SAP_Company_Code__c != null
              AND EYI_Sales_Order_Number__c != null
              
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        Opportunity opp = scope[0];
        String customerNumber = opp.EYI_SAP_Customer_Number__c;
        String companyCode = opp.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;

        try {
            String response = fetchCustomerLedger(customerNumber, companyCode);

            if (String.isNotBlank(response)) {
                Map<String, Object> fullResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
                Map<String, Object> outerMap = (Map<String, Object>) fullResponse.get('n0:ZSD_CUSTOMER_LEDGER_SFResponse');
                Map<String, Object> exOutput = (Map<String, Object>) outerMap.get('EX_OUTPUT');
                List<Object> items = (List<Object>) exOutput.get('item');

                for (Object itemObj : items) {
                    Map<String, Object> item = (Map<String, Object>) itemObj;
                    if (item.get('PAYMENTMILESTONE') == 'TDS') {
                        Decimal totalOutstanding = Decimal.valueOf((String)item.get('TOTALOUTSTANDING'));
                        opp.EYI_TDS_Outstanding__c = totalOutstanding;
                        update opp;
                        break;
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error processing Opportunity Id: ' + opp.Id + ' - ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optional: Add logging or email notification
    }

    public String fetchCustomerLedger(String customerNumber, String companyCode) {
        Map<String, String> payload = new Map<String, String>{
            'customerNumber' => customerNumber,
            'companyCode' => companyCode
        };

        String reqBody = JSON.serialize(payload);
		HTTPResponse res = EY_SAP_Gateway.customerLedger(reqBody);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            System.debug('Callout failed with status: ' + res.getStatusCode());
            return null;
        }
    }
}