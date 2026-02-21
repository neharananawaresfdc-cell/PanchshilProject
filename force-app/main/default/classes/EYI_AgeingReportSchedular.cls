global class EYI_AgeingReportSchedular implements Schedulable{
    global void execute(SchedulableContext sc) {
        // LOW/HIGH Queries
        List<Opportunity> sortedCustomerNumber = [
            Select EYI_SAP_Customer_Number__c
            FROM Opportunity
            WHERE EYI_SAP_Customer_Number__c != NULL
            ORDER BY EYI_SAP_Customer_Number__c ASC
        ];
        
        List<Opportunity> sortedComapnyCode = [
            Select EYI_Project_Enquired__r.EYI_SAP_Company_Code__c
            FROM Opportunity
            WHERE EYI_Project_Enquired__r.EYI_SAP_Company_Code__c != NULL
            ORDER BY EYI_Project_Enquired__r.EYI_SAP_Company_Code__c ASC
        ];
        
        if (sortedCustomerNumber.isEmpty()) return;
        
        String minCustomer = sortedCustomerNumber[0].EYI_SAP_Customer_Number__c;
        String maxCustomer = sortedCustomerNumber[sortedCustomerNumber.size() - 1].EYI_SAP_Customer_Number__c;
        
        if (sortedCustomerNumber.isEmpty()) return;
        
        String minCompCode = sortedComapnyCode[0].EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
        String maxCompCode = sortedComapnyCode[sortedComapnyCode.size() - 1].EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
        
    }
}