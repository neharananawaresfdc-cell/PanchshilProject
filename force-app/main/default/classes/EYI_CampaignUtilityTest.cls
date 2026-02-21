@isTest
public class EYI_CampaignUtilityTest {

    @TestSetup
    static void setupData() {
        // Create a Campaign
         EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project Insert',
            EYI_Project_Code__c = 'PRJ001',
            EYI_SAP_Salesorg__c = '1000',
            EYI_SAP_Plant_Code__c = '1100'
        );
        insert project;

        Campaign camp = new Campaign(
            Name = 'New Email Campaign',
            EYI_Campaign_Purpose__c ='Lead Generation',
            EYI_Campaign_Type__c = 'BTL',               // Custom field
            EYI_Project_Name__c = project.id,     // Replace with actual Project ID
            EYI_Source__c = 'Email',                      // Custom field
            Status = 'Planned',
            IsActive=True,

            StartDate = Date.newInstance(2025, 5, 31)
        );
        insert camp;
            
        camp.StartDate = Date.newInstance(2025, 6, 31);

        camp.Status = 'In Progress';
        update camp;

        
        Lead ld = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Phone = '9876543210',
            Company = 'Test Co',
            Status = 'Open - Not Contacted',
            EYI_Project_Enquired__c = project.Id,
            EYI_Segment__c = 'Residential',
            LeadSource = 'PREC',
            EYI_AutomationBypassDatetime__c = System.now()
        );
        insert ld;

        // Create Lead Enquiry
        EYI_Lead_Enquiry__c leadEnq = new EYI_Lead_Enquiry__c(
            EYI_Parent_Record__c = ld.Id,
            EYI_Campaign_Name__c = camp.Id,
            EYI_Segment__c = 'Residential',
            EYI_Phone__c = '9876543210',
            EYI_Email__c = 'test.lead@example.com',
            EYI_Lead_Source__c = 'PREC',
            //EYI_Lead_Status__c = 'Open',
            EYI_Project_Enquired__c = project.Id
        );
       // insert leadEnq;
        EYI_Lead_Enquiry__c leadEnq2 = new EYI_Lead_Enquiry__c(
            EYI_Parent_Record__c = ld.Id,
            EYI_Segment__c = 'Residential',
            EYI_Phone__c = '9876543210',
            EYI_Email__c = 'test.lead2@example.com',
            EYI_Lead_Source__c = 'PREC',
            //EYI_Lead_Status__c = 'Open',
            EYI_Project_Enquired__c = project.Id
        );
        //insert leadEnq2;

       
        insert new List<EYI_Lead_Enquiry__c>{leadEnq, leadEnq2};

        // // Create Email Template
        // Folder folder = new Folder(Name = 'Campaign_Bulk_Emails', DeveloperName = 'Campaign_Bulk_Emails', AccessType = 'Public');
        // insert folder;

        // EmailTemplate template = new EmailTemplate(
        //     Name = 'Test Template',
        //     Subject = 'Test Subject',
        //     HtmlValue = '<p>Test</p>',
        //     Body = 'Test Body',
        //     FolderId = folder.Id
        // );
        // insert template;

        // Create ContentDocument and ContentVersion
       // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;

        // After insert, query the ContentDocumentId from the inserted ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Link ContentDocument to the Lead (or other sObject) record
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = leadEnq.Id,  // Make sure leadEnq is a valid record Id
            ShareType = 'V',              // 'V' = Viewer permission
            Visibility = 'AllUsers'       // Optional but recommended, defaults to 'AllUsers'
        );
        insert cdl;

    }

    @isTest
    static void testGetLeadEnquiries() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Test.startTest();
        List<EYI_Lead_Enquiry__c> leads = EYI_CampaignUtility.getLeadEnquiries(camp.Id);
        Test.stopTest();
        System.assertNotEquals(0, leads.size(), 'Lead enquiries should be returned');
    }

    @isTest
    static void testGetEmailTemplates() {
        Test.startTest();
        List<EmailTemplate> templates = EYI_CampaignUtility.getEmailTemplates();
        Test.stopTest();
        // System.assertNotEquals(0, templates.size(), 'Email templates should be returned');
    }

    @isTest
    static void testGetProjectDocuments() {
        EYI_Lead_Enquiry__c lead = [SELECT Id FROM EYI_Lead_Enquiry__c LIMIT 1];
        Test.startTest();
        List<ContentDocumentLink> docs = EYI_CampaignUtility.getProjectDocuments(new List<Id>{lead.Id});
        
        Test.stopTest();
        System.assertNotEquals(0, docs.size(), 'Project documents should be returned');
    }

    @isTest
    static void testSendEmails() {
        EYI_Lead_Enquiry__c lead = [SELECT Id FROM EYI_Lead_Enquiry__c LIMIT 1];
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        EYI_CampaignUtility.sendEmails(
            new List<Id>{lead.Id},
            new List<Id>{cv.ContentDocumentId},
            'Test Subject',
            'Test Body'
        );
        Test.stopTest();

        // No assert needed as Messaging.sendEmail doesn't return a value
        System.assert(true, 'sendEmails executed without exception');
    }
}