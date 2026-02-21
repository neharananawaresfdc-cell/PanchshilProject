@isTest
public class EYI_NotificationServiceTest {
    @testSetup
    static void setupData() {
        // Insert a user for record owner
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            LastName = 'TestUser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        Lead l = new Lead(LastName='Test', Company='Test');
		insert l;
        
        // Insert a sample EYI_Lead_Enquiry__c record (adjust required fields as needed)
        EYI_Lead_Enquiry__c enquiry = new EYI_Lead_Enquiry__c(
            Name = 'Test Enquiry',
            EYI_Parent_Record__c = l.Id,
            OwnerId = u.Id,
            EYI_Project_Enquired__c = null, // Add valid project Id if needed
            EYI_Client_Communication_Preference__c = 'Email'
        );
        insert enquiry;

        // Insert minimal custom metadata record if possible
        // You may need to use Metadata API for this in a real org/test (not always possible in Apex)
    }

    /* @isTest
	static void test_getNotifications_afterUpdate() {
    	// Create and insert a parent Lead, since EYI_Parent_Record__c is required
    	Lead parent = new Lead(LastName='Test', Company='Test');
    	insert parent;

    	// Insert the original record
   	 	EYI_Lead_Enquiry__c orig = new EYI_Lead_Enquiry__c(
        	Name = 'Test Enquiry',
        	EYI_Parent_Record__c = parent.Id,
        	OwnerId = UserInfo.getUserId(),
        	EYI_Client_Communication_Preference__c = 'Email'
    	);
    	insert orig;

    	// Query the original record to simulate "old" values
        EYI_Lead_Enquiry__c oldRecord = [SELECT Id,EYI_Opportunity__c, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Created_and_LastModified_Time_Difference__c, EYI_Age_group__c, EYI_Call_Status__c, EYI_Ethnicity__c, EYI_Industry__c, EYI_IsNew__c, EYI_Lead_Generation_Medium__c, EYI_Lead_Lost_Other_Reason__c, EYI_Lead_Source__c, EYI_Lead_Status__c, EYI_Lost_Reason__c, EYI_Nature_of_Lead__c, EYI_Occupation__c, EYI_Qualification_Status__c, EYI_Rating__c, EYI_Salutation__c, EYI_Segment__c, Profile_Status__c, Sticky_Agent__c, DNC__c, EYI_Address__Street__s, EYI_Address__City__s, EYI_Address__PostalCode__s, EYI_Address__StateCode__s, EYI_Address__CountryCode__s, EYI_Address__Latitude__s, EYI_Address__Longitude__s, EYI_Address__GeocodeAccuracy__s, EYI_Address__c, EYI_Agent__c, EYI_Alternate_Email__c, EYI_Alternate_Mobile_No__c, EYI_Area_Requirement_sq_ft__c, EYI_AutomationBypassDatetime__c, EYI_Call_Log_Details__c, EYI_Campaign_Name__c, EYI_Client_Communication_Preference__c, EYI_Closing_Manager__c, EYI_Company__c, EYI_Converted__c, EYI_DNC__c, EYI_DND__c, EYI_Designation__c, EYI_Email__c, EYI_Follow_Up__c, EYI_Inbound_L1_Escalation_Time__c, EYI_Inbound_L2_Escalation_Time__c, EYI_Inbound_L3_Escalation_Time__c, EYI_Is_Activity_Performed_Within_Time__c, EYI_Is_Lead_Source_Change__c, EYI_Lead_Enquiry_Number__c, EYI_Lead_Entry_Remarks__c, EYI_Lead_Lost_Remarks__c, EYI_Lead_Remarks__c, EYI_Lead_Sub_Source_Type__c, EYI_Linkedin_Profile__c, EYI_Mobile__c, EYI_No_of_Follow_Ups__c, EYI_No_of_Not_Connected_Follow_Ups__c, EYI_Number_of_Incoming_calls__c, EYI_Number_of_Outgoing_calls__c, EYI_Outbound_L1_Escalation_Time__c, EYI_Outbound_L2_Escalation_Time__c, EYI_Outbound_L3_Escalation_Time__c, EYI_Parent_Record__c, EYI_Phone__c, EYI_Profile_Negative_Reason__c, EYI_Profile_Verified__c, EYI_Remarks__c, EYI_Secondary_Owner__c, EYI_Site_Visit_Date__c, EYI_Sourcing_S_M__c, Mask_Data_test__c, Missed_Call__c, Missed__c, Number_of_Retries__c, Working_Hours__c, EYI_Budget__c, EYI_IsAutomationBypassed__c, EYI_LeadType__c, EYI_Masked_Alternate_Email__c, EYI_Masked_Alternate_Mobile_No__c, EYI_Masked_Email__c, EYI_Masked_Mobile__c, EYI_Masked_Phone__c, EYI_Property__c, EYI_Purpose_of_Purchase__c, EYI_Unit_Configuration__c, EYI_Vertical__c, Phone__c, EYI_Is_Lead_Enquiry_is_New__c, EYI_Project_Enquired__c, EYI_REC_Account__c, EYI_Asset_Class__c, EYI_Lead_Sub_Source__c, EYI_Sub_Asset_Class__c FROM EYI_Lead_Enquiry__c   WHERE Id = :orig.Id];

    	// Update the record
    	oldRecord.Name = 'Test Enquiry Updated';
    	update oldRecord;

    	// Query the updated record to simulate "new" values (after update)
    	EYI_Lead_Enquiry__c newRecord = [SELECT Id, Name, OwnerId,IsDeleted, EYI_Lead_Enquiry_Number__c, EYI_Client_Communication_Preference__c, EYI_Parent_Record__c FROM EYI_Lead_Enquiry__c WHERE Id = :orig.Id];

    	// Prepare the maps for the trigger context
    	Map<Id, SObject> newRecords = new Map<Id, SObject>{ newRecord.Id => newRecord };
    	Map<Id, SObject> oldRecords = new Map<Id, SObject>{ oldRecord.Id => oldRecord };

    	Test.startTest();
    	List<EYI_Notification> notifications = EYI_NotificationService.getNotifications(newRecords, oldRecords, TriggerOperation.AFTER_UPDATE);
    	Test.stopTest();

    	System.assertNotEquals(null, notifications, 'Notifications list should not be null');
	} */

    @isTest
    static void test_getNotifications_afterInsert() {
        EYI_Lead_Enquiry__c inserted = [SELECT Id,EYI_Opportunity__c, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Created_and_LastModified_Time_Difference__c, EYI_Age_group__c, EYI_Call_Status__c, EYI_Ethnicity__c, EYI_Industry__c, EYI_IsNew__c, EYI_Lead_Generation_Medium__c, EYI_Lead_Lost_Other_Reason__c, EYI_Lead_Source__c, EYI_Lead_Status__c, EYI_Lost_Reason__c, EYI_Nature_of_Lead__c, EYI_Occupation__c, EYI_Qualification_Status__c, EYI_Rating__c, EYI_Salutation__c, EYI_Segment__c, Profile_Status__c, Sticky_Agent__c, DNC__c, EYI_Address__Street__s, EYI_Address__City__s, EYI_Address__PostalCode__s, EYI_Address__StateCode__s, EYI_Address__CountryCode__s, EYI_Address__Latitude__s, EYI_Address__Longitude__s, EYI_Address__GeocodeAccuracy__s, EYI_Address__c, EYI_Agent__c, EYI_Alternate_Email__c, EYI_Alternate_Mobile_No__c, EYI_Area_Requirement_sq_ft__c, EYI_AutomationBypassDatetime__c, EYI_Call_Log_Details__c, EYI_Campaign_Name__c, EYI_Client_Communication_Preference__c, EYI_Closing_Manager__c, EYI_Company__c, EYI_Converted__c, EYI_DNC__c, EYI_DND__c, EYI_Designation__c, EYI_Email__c, EYI_Follow_Up__c, EYI_Inbound_L1_Escalation_Time__c, EYI_Inbound_L2_Escalation_Time__c, EYI_Inbound_L3_Escalation_Time__c, EYI_Is_Activity_Performed_Within_Time__c, EYI_Is_Lead_Source_Change__c, EYI_Lead_Enquiry_Number__c, EYI_Lead_Entry_Remarks__c, EYI_Lead_Lost_Remarks__c, EYI_Lead_Remarks__c, EYI_Lead_Sub_Source_Type__c, EYI_Linkedin_Profile__c, EYI_Mobile__c, EYI_No_of_Follow_Ups__c, EYI_No_of_Not_Connected_Follow_Ups__c, EYI_Number_of_Incoming_calls__c, EYI_Number_of_Outgoing_calls__c, EYI_Outbound_L1_Escalation_Time__c, EYI_Outbound_L2_Escalation_Time__c, EYI_Outbound_L3_Escalation_Time__c, EYI_Parent_Record__c, EYI_Phone__c, EYI_Profile_Negative_Reason__c, EYI_Profile_Verified__c, EYI_Remarks__c, EYI_Secondary_Owner__c, EYI_Site_Visit_Date__c, EYI_Sourcing_S_M__c, Mask_Data_test__c, Missed_Call__c, Missed__c, Number_of_Retries__c, Working_Hours__c, EYI_Budget__c, EYI_IsAutomationBypassed__c, EYI_LeadType__c, EYI_Masked_Alternate_Email__c, EYI_Masked_Alternate_Mobile_No__c, EYI_Masked_Email__c, EYI_Masked_Mobile__c, EYI_Masked_Phone__c, EYI_Property__c, EYI_Purpose_of_Purchase__c, EYI_Unit_Configuration__c, EYI_Vertical__c, Phone__c, EYI_Is_Lead_Enquiry_is_New__c, EYI_Project_Enquired__c, EYI_REC_Account__c, EYI_Asset_Class__c, EYI_Lead_Sub_Source__c, EYI_Sub_Asset_Class__c FROM EYI_Lead_Enquiry__c LIMIT 1]; 
        Map<Id, SObject> newRecords = new Map<Id, SObject>{ inserted.Id => inserted };
        // Call method under test (simulate AFTER_INSERT)
        Test.startTest();
        List<EYI_Notification> notifications = EYI_NotificationService.getNotifications(newRecords, null, TriggerOperation.AFTER_INSERT);
        Test.stopTest();

        System.assertNotEquals(null, notifications);
    }

    @isTest
    static void test_CreateNotifications() {
        // You must insert or query a EYI_Notification_Template__mdt record for this test to work.
        // If not possible, you can simulate with a mock object if your org allows.
        EYI_Notification_Template__mdt metaData = new EYI_Notification_Template__mdt(
            MasterLabel = 'TestTemplate',
            sObject__c = 'EYI_Lead_Enquiry__c',
            Channel_Type__c = 'Email',
            Recipient_Field__c = 'OwnerId',
            Email_Template__c = 'SampleTemplate',
            Notification_Trigger_Fields__c = 'Name',
            Notification_Message__c = 'Test Message',
            Operation_Type__c = 'AFTER_UPDATE',
            Active__c = true,
            Notification_Trigger_Logic__c = 'Test'
        );
        // This insert will fail unless you have a custom metadata deploy solution.
        // insert metaData;  // Not allowed in standard Apex, only via Metadata API or special test utilities.

        EYI_Lead_Enquiry__c rec = [ SELECT Id, OwnerId, Name, EYI_Client_Communication_Preference__c,EYI_Project_Enquired__c FROM EYI_Lead_Enquiry__c LIMIT 1];
        Map<String,Object> changedFields = new Map<String,Object>{ 'Name' => 'Changed' };

        // Call method under test (simulate with fake metaData)
        Test.startTest();
        EYI_Notification notification = EYI_NotificationService.CreateNotifications(metaData, rec, changedFields);
        Test.stopTest();

        System.assertNotEquals(null, notification);
    }

    @isTest
    static void test_getMergeFields() {
        EYI_Lead_Enquiry__c rec = [SELECT Id, Name, OwnerId FROM EYI_Lead_Enquiry__c LIMIT 1];
        Map<Id, SObject> newRecords = new Map<Id, SObject>{ rec.Id => rec };

        Test.startTest();
        Map<Id, List<EYI_MergeFieldsWrapper>> mergeFields = EYI_NotificationService.getMergeFields('EYI_Lead_Enquiry__c', newRecords);
        Test.stopTest();

        System.assertNotEquals(null, mergeFields);
    }

    @isTest
    static void test_sendNotifications() {
        EYI_Notification notif = new EYI_Notification();
        notif.channelType = 'Email';
        notif.recipient = 'user@example.com';
        notif.message = 'Test message';
        notif.attachmentLink = 'https://example.com/file';
        notif.recordOwnerId = UserInfo.getUserId();
        notif.emailTemplateName = 'SampleTemplate';
        notif.notificationName = 'Test Notification';

        Test.startTest();
        EYI_NotificationService.sendNotifications(new List<EYI_Notification>{notif});
        Test.stopTest();
    }
}