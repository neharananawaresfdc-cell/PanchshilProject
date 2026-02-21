@isTest
public class EYI_CustomMetadataUtility_test {
    @isTest
    static void testCustomMetadataUtilityMethod() {
        // Load test data for EYI_SMS_Text_Templates__mdt
        List<EYI_SMS_Text_Templates__mdt> smsTemplates = 
            (List<EYI_SMS_Text_Templates__mdt>) Test.loadData(EYI_SMS_Text_Templates__mdt.sObjectType, 'EYI_SMS_Text_Templates_TestData');

        // Load test data for EYI_Lead_Enquiry_Escalation_Settings__mdt
        List<EYI_Lead_Enquiry_Escalation_Settings__mdt> escalationSettings = 
            (List<EYI_Lead_Enquiry_Escalation_Settings__mdt>) Test.loadData(EYI_Lead_Enquiry_Escalation_Settings__mdt.sObjectType, 'EYI_Escalation_Settings_TestData');

        Test.startTest();
        EYI_CustomMetadataUtility.getEscalationTimeMatrix('Inbound');
        EYI_CustomMetadataUtility.getSMSTemplateMetadata();
        EYI_CustomMetadataUtility.getMessageTemplates();
        Test.stopTest();

        // Assertions
        System.assert(!smsTemplates.isEmpty(), 'SMS Templates should be loaded');
        System.assert(!escalationSettings.isEmpty(), 'Escalation Settings should be loaded');
    }
}