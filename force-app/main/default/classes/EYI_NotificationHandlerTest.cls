@isTest
public with sharing class EYI_NotificationHandlerTest {
    @TestSetup
    static void makeData(){
        EYI_Notification_Settings__c testSetting = new EYI_Notification_Settings__c(
            EYI_Is_Notifications_Enabled__c = true
        );
        insert testSetting;
    }
    @IsTest
    static void EYI_NotificationHandlerTest(){
        EYI_Assignment_Group_Member__c member = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.Presales_Assignment_Group_Label,true);
        Test.startTest();
            List<Lead> leadList = EYI_TestDataFactory.createLeads('Test',4,'983434334','Direct Client','',true);
            EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c();
            enq.EYI_Parent_Record__c = leadList[0].Id;
            enq.EYI_Lead_Status__c = 'Open';
            enq.EYI_Client_Communication_Preference__c = 'All';
            enq.EYI_Lead_Source__c = 'Web';
            enq.EYI_Phone__c = '+918877664455';

            insert enq;
        Test.stopTest();
    }
    @IsTest
    static void EYI_NotificationHandlerTest1(){
        EYI_Assignment_Group_Member__c member = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.Presales_Assignment_Group_Label,true);
        EYI_Assignment_Group_Member__c member2 = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.EYI_ClosingManagerGroupName,true);

        Test.startTest();
            List<Lead> leadList = EYI_TestDataFactory.createLeads('Test',4,'983434334','Direct Client','',true);
            EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c();
            enq.EYI_Parent_Record__c = leadList[0].Id;
        	enq.EYI_Nature_of_Lead__c = 'Outright';
        	enq.EYI_Purpose_of_Purchase__c = 'End Use';
        	enq.EYI_Segment__c = 'Residential';
        	enq.EYI_LeadType__c	 = 'Villa';
        	enq.EYI_Property__c = '46 Banyan Tree';
        	enq.Name = 'Testing123';
        	enq.EYI_Company__c = 'Testing123';
        	enq.EYI_Email__c = 'testing321@gmail.com';
        	enq.EYI_Rating__c = 'Hot';
            enq.EYI_Lead_Status__c = 'Open';
            enq.EYI_Client_Communication_Preference__c = 'All';
            enq.EYI_Lead_Source__c = 'Web';
            enq.EYI_Phone__c = '+918877664455';
            enq.EYI_Site_Visit_Date__c = system.now();

            insert enq;
			System.debug('Lead Status 1 = '+enq.EYI_Lead_Status__c);
            enq.EYI_Lead_Status__c='Visit Confirmed';
            update enq;
            System.debug('Lead Status 2 = '+enq.EYI_Lead_Status__c);
        	EYI_LeadEnquiryUtility.getLeadInfo(enq.id);
        	enq.EYI_Lead_Status__c='No Show';
            update enq;
            System.debug('Lead Status 3 = '+enq.EYI_Lead_Status__c);
        
        	List<EYI_Lead_Enquiry__History> leadHistories = [
            SELECT ParentId, CreatedById, Field, OldValue, NewValue, CreatedDate
            FROM EYI_Lead_Enquiry__History
            WHERE ParentId = :enq.id 
            AND (Field = 'EYI_Lead_Status__c' OR Field = 'Created')
            ORDER BY CreatedDate
        ];
        
        System.debug('Lead histories.size = >'+leadHistories.size());
            EYI_LeadEnquiryUtility.getLeadStatusTime(enq.Id);
        Test.stopTest();
    }
    @IsTest
    static void EYI_NotificationHandlerTest2(){
        EYI_Assignment_Group_Member__c member = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.Presales_Assignment_Group_Label,true);
        EYI_Assignment_Group_Member__c member2 = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.EYI_ClosingManagerGroupName,true);
        List<EYI_Project__c> projectList = EYI_TestDataFactory.createProjects('One North', 1, true,'Commercial');        

        Test.startTest();
            List<Lead> leadList = EYI_TestDataFactory.createLeads('Test',4,'983434334','Direct Client','',true);
            EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c();
            enq.EYI_Parent_Record__c = leadList[0].Id;
            enq.EYI_Lead_Status__c = 'Open';
            enq.EYI_Client_Communication_Preference__c = 'All';
            enq.EYI_Lead_Source__c = 'Web';
            enq.EYI_Phone__c = '+918877664455';
            insert enq;
            enq.EYI_Lead_Source__c = 'Other';
            enq.EYI_Lead_Status__c='No Show';
            update enq;

            //EYI_SMSService.sendSMSBrochure(enq.EYI_Phone__c,'{!Name} hi',enq.id);
        Test.stopTest();
    }
    @IsTest
    static void EYI_NotificationHandlerTest3(){
        EYI_Assignment_Group_Member__c member = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.Presales_Assignment_Group_Label,true);
        EYI_Assignment_Group_Member__c member2 = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.EYI_ClosingManagerGroupName,true);
        List<EYI_Project__c> projectList = EYI_TestDataFactory.createProjects('One North', 1, true,'Commercial');        
        
        Test.startTest();
            List<Lead> leadList = EYI_TestDataFactory.createLeads('Test',4,'983434334','Direct Client','',true);
            EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c();
            enq.EYI_Parent_Record__c = leadList[0].Id;
            enq.EYI_Lead_Status__c = 'Open';
            enq.EYI_Client_Communication_Preference__c = 'All';
            enq.EYI_Lead_Source__c = 'Web';
            enq.EYI_Email__c = 'Web@gmail.com';
            enq.EYI_Phone__c = '+918877664455';
            enq.EYI_Site_Visit_Date__c = system.now();

            insert enq;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Test File';
            contentVersion.PathOnClient = 'TestFile.txt';
            contentVersion.VersionData = Blob.valueOf('Sample content');
            insert contentVersion;


        // Query the ContentDocumentId
        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        List<String> myList = new List<String>();
        myList.add(insertedContentVersion.ContentDocumentId);
     
        EYI_BrochureCommunicationWrapper wrapper = new EYI_BrochureCommunicationWrapper();
            wrapper.leadId = enq.id;
            wrapper.projectId = projectList[0].id;
            wrapper.projectName = projectList[0].name;
            wrapper.senderEmail = enq.EYI_Email__c;
            wrapper.senderPhone = enq.EYI_Phone__c;
            wrapper.selectedFileIds = myList;
            wrapper.messagebody = 'enq.EYI_Phone__c';
            wrapper.emailSubject = 'enq.EYI_Phone__c';

            String jsonString = JSON.serialize(wrapper);
            EYI_EmailService.sendEmail(jsonString);
            EYI_MergeFieldsWrapper testWrapper = new EYI_MergeFieldsWrapper(enq.id,'EYI_Phone__c','EYI_Phone__c','EYI_Phone__c' );
            EYI_LeadEnquiryUtility.getFilesByProjectId(projectList[0].Id);
            EYI_LeadEnquiryUtility.StatusWrapper stwrapper = new EYI_LeadEnquiryUtility.StatusWrapper('test','test',10,System.now());

        Test.stopTest();
    }

    @IsTest
    static void EYI_NotificationHandlerTest4(){
        EYI_Assignment_Group_Member__c member = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.Presales_Assignment_Group_Label,true);
        EYI_Assignment_Group_Member__c member2 = EYI_TestDataFactory.createAssignmentGroupMember(System.Label.EYI_ClosingManagerGroupName,true);
        List<EYI_Project__c> projectList = EYI_TestDataFactory.createProjects('One North', 1, true,'Commercial');        
        
        Test.startTest();
            List<Lead> leadList = EYI_TestDataFactory.createLeads('Test',4,'983434334','Direct Client','',true);
            EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c();
            enq.EYI_Parent_Record__c = leadList[0].Id;
            enq.EYI_Lead_Status__c = 'Open';
            enq.EYI_Client_Communication_Preference__c = 'All';
            enq.EYI_Lead_Source__c = 'Web';
            enq.EYI_Email__c = 'Web@gmail.com';
            enq.EYI_Phone__c = '+918877664455';
            enq.EYI_Site_Visit_Date__c = system.now();

            insert enq;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Test File';
            contentVersion.PathOnClient = 'TestFile.txt';
            contentVersion.VersionData = Blob.valueOf('Sample content');
            insert contentVersion;

        // Query the ContentDocumentId
        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        List<String> myList = new List<String>();
        myList.add(insertedContentVersion.ContentDocumentId);
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedContentVersion.ContentDocumentId; // Example ContentDocumentId
        cdl.LinkedEntityId = projectList[0].Id; // Example LinkedEntityId (e.g., Account ID)
        cdl.ShareType = 'V'; // Viewer
        cdl.Visibility = 'AllUsers';
        insert cdl;

        EYI_BrochureCommunicationWrapper wrapper = new EYI_BrochureCommunicationWrapper();
            wrapper.leadId = enq.id;
            wrapper.projectId = projectList[0].id;
            wrapper.projectName = projectList[0].name;
            wrapper.senderEmail = enq.EYI_Email__c;
            wrapper.senderPhone = enq.EYI_Phone__c;
            wrapper.selectedFileIds = myList;
            wrapper.messagebody = 'enq.EYI_Phone__c';
            wrapper.emailSubject = 'enq.EYI_Phone__c';

            String jsonString = JSON.serialize(wrapper);
            EYI_EmailService.sendEmail(jsonString);
            EYI_MergeFieldsWrapper testWrapper = new EYI_MergeFieldsWrapper(enq.id,'EYI_Phone__c','EYI_Phone__c','EYI_Phone__c' );
            EYI_LeadEnquiryUtility.getFilesByProjectId(projectList[0].Id);
            EYI_LeadEnquiryUtility.StatusWrapper stwrapper = new EYI_LeadEnquiryUtility.StatusWrapper('test','test',10,System.now());
        Test.stopTest();
    }
    
    @isTest
    public static void getEmailTemplatesTest(){
        Test.startTest();
        EYI_LeadEnquiryUtility.getEmailTemplates();
        Test.stopTest();
    }
    
    @isTest
    public static void getEmailTemplateDetailsTest(){
        
    }
}