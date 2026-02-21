@isTest
private class EYI_DuplicateDetectorHandlerTest {

    @isTest
    static void testIsDuplicate() {
        EYI_Notification_Settings__c notificationSetting = new EYI_Notification_Settings__c(
            EYI_Is_Notifications_Enabled__c = true
        );
        insert notificationSetting;
        EYI_DuplicateDetectorSettings__c duplicateDetectorSetting = new EYI_DuplicateDetectorSettings__c(
            EYI_Is_DuplicateDetector_Enabled__c = true
        );
        insert duplicateDetectorSetting;
        EY_Lead_Duplicate_Detector_rules__mdt customMetadata = [SELECT DeveloperName, EYI_Master_Object_API_Name__c, EYI_Fields_to_detect_Duplicate__c 
                                                   FROM EY_Lead_Duplicate_Detector_rules__mdt 
                                                   WHERE DeveloperName = 'Lead_Duplicate' LIMIT 1];
        
        List<Lead> leadsToInsert = EYI_TestDataFactory.createLeads('Test345','Golden Bell',4,'983434334','Direct Client','',true);
       // List<Lead> leadsToInsertWebtoLead = EYI_TestDataFactory.createLeads('Test7865',4,'9090909094','Web','Google',true);
        
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        for (Lead l : leadsToInsert) {
            leadsMap.put(l.Id, l);
        }

        Lead newLead = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'johndoe@example.com', Phone = '123-456-7890');
        
        List<SObject> newSObjectList = new List<SObject>{newLead};
        
        Test.startTest();
        List<Lead> leadsToInsertDuplicate = EYI_TestDataFactory.createLeads('Johndata','Panchshil Towers',1,'983434334','Direct Client','',true);
        for (Lead l : leadsToInsertDuplicate) {
            leadsMap.put(l.Id, l);
       }
        String mockResponse = '{"Success":"True","SuccessCode":"200"}';
     //   EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
       // Test.setMock(HttpCalloutMock.class, mock);
        DuplicateDetectorClass.isDuplicate('Lead_Duplicate', 'EY_Lead_Duplicate_Detector_rules__mdt', leadsMap, null);
        Test.stopTest();

        //System.assertNotEquals(result, null, 'Expected result to be non-null');
        
        // Assert that errors have been added for the duplicate lead
        //System.assertEquals(newLead.errors.size(), 1, 'Expected one error for duplicate');
        //System.assertEquals(newLead.errors[0].message, 'Duplicate found: Email johndoe@example.com', 'Error message should match the expected duplicate message');
    }
}