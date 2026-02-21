public with sharing class EYI_WelcomCallUtilityClass {
    //Method return opportunity Details
    @AuraEnabled
    public static Opportunity getOppRec(String recordId){
        try {
            List<Opportunity> getOppRec = [Select Id,Name,EYI_Agreement_Value__c, EYI_First_Name__c, EYI_Last_Name__c,EYI_Project_Enquired__r.Name,EYI_Inventory__r.Name,Owner.Name, EYI_Primary_Applicant__r.EYI_Designation__c, EYI_Primary_Applicant__r.EYI_Date_of_Birth__c,EYI_Primary_Applicant__r.EYI_Anniversary_Date__c,EYI_Primary_Applicant__r.Nationality__c,EYI_Primary_Applicant__r.EYI_Company_Name__c, EYI_Primary_Applicant__r.Name, EYI_Primary_Applicant__r.EYI_Aadhar_Number__c, EYI_Primary_Applicant__r.EYI_Pancard_Number__c, EYI_Primary_Applicant__r.Verified_AADHAR_Card_Address__c,EYI_Primary_Applicant__r.Verified_AADHAR_Card_Name__c,EYI_Relationship_Manager__r.Name, EYI_Relationship_Manager__r.Email,EYI_Relationship_Manager__r.MobilePhone  from Opportunity where Id=: recordId];
            return getOppRec[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static EYI_Applicants__c getSecondApp(String recordId){
        try {
            List<EYI_Applicants__c> getSecondApp = [Select Id,Name,Verified_AADHAR_Card_Name__c from EYI_Applicants__c where Opportunity__c =: recordId AND EYI_Applicant_No__c = 2];
            return getSecondApp[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}