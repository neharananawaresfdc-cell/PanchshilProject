/**
 * @description       : 
 * @author            : Digambar Ganage 
 * @group             : EY Notification Framework
 * @last modified on  : 11-21-2024
 * @last modified by  : Digambar Ganage 
**/
public with sharing class EYI_CustomMetadataUtility {
    /**
     * @use : This method is used to get the sms templates
     * used in Class : EYI_SMSService
     */
    public static Map<String, EYI_SMS_Text_Templates__mdt> getSMSTemplateMetadata() {
        Map<String, EYI_SMS_Text_Templates__mdt> smsTemplateMap = new Map<String, EYI_SMS_Text_Templates__mdt>();
        for (EYI_SMS_Text_Templates__mdt record : [ SELECT Id, DeveloperName, Channel_Type__c, Message_Body__c, IsActive__c
                                                    FROM EYI_SMS_Text_Templates__mdt 
                                                    WHERE IsActive__c = true]){
            smsTemplateMap.put(record.DeveloperName, record);
        }
       return smsTemplateMap;
    }

     /**
     * @use : This method is used to get the sms templates for Brochure component
     *
     */
    @AuraEnabled(cacheable=true)
    public static List<EYI_SMS_Text_Templates__mdt> getMessageTemplates() {
        // Query both SMS and WhatsApp templates from the custom metadata
        return [SELECT Channel_Type__c, Message_Body__c, Id ,label
                FROM EYI_SMS_Text_Templates__mdt];
    }

    /**
     * @use : This method is used to get the EYI_Lead_Enquiry_Escalation_Settings__mdt
     *
     */     
    public static Map<String, EYI_Lead_Enquiry_Escalation_Settings__mdt> getEscalationTimeMatrix(String callType) {
        Map<String, EYI_Lead_Enquiry_Escalation_Settings__mdt> callTypeToMDTMap = new Map<String, EYI_Lead_Enquiry_Escalation_Settings__mdt>();
        // Query the metadata records for the specified fields, ordered by Call_Type__c
        List<EYI_Lead_Enquiry_Escalation_Settings__mdt> records = [SELECT Id, Call_Type__c, Is_Active__c, 
                                                                   L1_Escalation_Time__c, L2_Escalation_Time__c, 
                                                                   L3_Escalation_Time__c 
                                                                   FROM EYI_Lead_Enquiry_Escalation_Settings__mdt 
                                                                   WHERE Is_Active__c = true
                                                                   AND Call_Type__c = :callType
                                                                   ];
        for (EYI_Lead_Enquiry_Escalation_Settings__mdt record : records) {
            callTypeToMDTMap.put(record.Call_Type__c, record);
        }
        return callTypeToMDTMap;
    }
}