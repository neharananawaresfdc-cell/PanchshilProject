@isTest
private class EYI_EmailServiceTest {

    @testSetup
    static void setupTemplates() {
        EmailTemplate textTemplate = new EmailTemplate(
            Name = 'Test Text',
            DeveloperName = 'Test_Text',
            FolderId = UserInfo.getUserId(),
            TemplateType = 'text',
            Subject = 'Hello {{Name}}',
            Body = 'Dear {{Name}}, Welcome!',
            IsActive = true
        );
        insert textTemplate;
		
        /*tterhead lh = new Letterhead(
    		Name = 'TestLH',
    		DeveloperName = 'TestLH'
		);
		insert lh;*/
        
        // HTML template
        EmailTemplate template = new EmailTemplate(
    		Name = 'Test Email',
    		DeveloperName = 'Test_Template',
    		FolderId = UserInfo.getUserId(),
    		TemplateType = 'text',
    		Subject = 'Hello {{Name}}',
    		Body = 'Dear {{Name}}, Welcome!',
    		IsActive = true
		);
		insert template;
    }

    // @isTest
    // static void testSend_TextAndHtml() {
    //     User u = [SELECT Id FROM User WHERE Profile.Name='System Administrator' LIMIT 1];

    //     // Covers text template, with merge fields, recipient set
    //     EYI_Notification note1 = new EYI_Notification();
    //     note1.recipient = 'john@example.com';
    //     note1.emailTemplateName = 'Test_Text';
    //     note1.recordOwnerId = u.Id;
    //     note1.projectId = null;
    //     note1.attachmentLink = 'No';
    //     EYI_MergeFieldsWrapper field = (EYI_MergeFieldsWrapper)JSON.deserialize('{"replaceField":"{{Name}}","fieldValue":"John Doe"}', EYI_MergeFieldsWrapper.class);
    //     note1.mergeFieldsList = new List<EYI_MergeFieldsWrapper>{field};

    //     // Covers html template, no merge fields, recipient blank
    //     EYI_Notification note2 = new EYI_Notification();
    //     note2.recipient = '';
    //     note2.emailTemplateName = 'Test_HTML';
    //     note2.recordOwnerId = u.Id;
    //     note2.projectId = null;
    //     note2.attachmentLink = 'No';
    //     note2.mergeFieldsList = new List<EYI_MergeFieldsWrapper>();

    //     // Actually call the method!
    //     Test.startTest();
    //     EYI_EmailService.send(new List<EYI_Notification>{note1, note2});
    //     Test.stopTest();
    // }

    // @isTest
    // static void testSend_WithAttachments() {
    //     User u = [SELECT Id FROM User WHERE Profile.Name='System Administrator' LIMIT 1];

    //     // Create dummy ContentVersion and ContentDocumentLink
    //     ContentVersion cv = new ContentVersion(
    //         Title = 'TestFile',
    //         PathOnClient = 'TestFile.pdf',
    //         VersionData = Blob.valueOf('Sample file content')
    //     );
    //     insert cv;
    //     Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

    //     // Create a dummy record to link attachment to (e.g., a Project__c or Account)
    //     Account acc = new Account(Name = 'Attachment Test');
    //     insert acc;

    //     ContentDocumentLink cdl = new ContentDocumentLink(
    //         ContentDocumentId = contentDocumentId,
    //         LinkedEntityId = acc.Id,
    //         ShareType = 'V'
    //     );
    //     insert cdl;

    //     // Notification referencing the account (projectId)
    //     EYI_Notification note = new EYI_Notification();
    //     note.recipient = 'jane@example.com';
    //     note.emailTemplateName = 'Test_Text';
    //     note.recordOwnerId = u.Id;
    //     note.projectId = acc.Id;
    //     note.attachmentLink = 'Yes';
    //     EYI_MergeFieldsWrapper field = (EYI_MergeFieldsWrapper)JSON.deserialize('{"replaceField":"{{Name}}","fieldValue":"John Doe"}', EYI_MergeFieldsWrapper.class);
    //     note.mergeFieldsList = new List<EYI_MergeFieldsWrapper>{field};
    //     Test.startTest();
    //     EYI_EmailService.send(new List<EYI_Notification>{note});
    //     Test.stopTest();
    // }

   // @isTest
    // static void testGetAllContentDocumentsByRecordId() {
        // Empty input, should cover early return
       // Map<Id, List<ContentVersion>> result = EYI_EmailService.getAllContentDocumentsByRecordId(new List<Id>());
        // Query ContentDocumentLinks to fetch ContentDocuments related to each Record Id
   		/*ist<ContentDocumentLink> contentDocumentLinks = [
        	SELECT ContentDocumentId, LinkedEntityId 
        	FROM ContentDocumentLink 
        	WHERE LinkedEntityId IN :recordIds
    	];*/
       // System.assertNotEquals(null, result);

        // Valid input (see previous test for full coverage)
   // }*/

    @isTest
    static void testGetEmailTemplateByDeveloperName() {
        // Should return the template
        EmailTemplate et = EYI_EmailService.getEmailTemplateByDeveloperName('Test_Text');
        System.assertNotEquals(null, et);

        // Negative test: non-existent name (should throw exception)
        try {
            EYI_EmailService.getEmailTemplateByDeveloperName('NonExistent');
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('List has no rows'), 'Expected query exception');
        }
    }

    @isTest
    static void testSendEmailAuraMethod() {
        // Create ContentVersion and link as in previous
        ContentVersion cv = new ContentVersion(
            Title = 'AuraTest',
            PathOnClient = 'AuraTest.pdf',
            VersionData = Blob.valueOf('Aura file')
        );
        insert cv;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        EYI_BrochureCommunicationWrapper wrapper = new EYI_BrochureCommunicationWrapper();
        wrapper.leadId = null;
        wrapper.projectName = 'Aura Project';
        wrapper.projectId = null;
        wrapper.senderEmail = 'aura@example.com';
        wrapper.senderPhone = '9999999999';
        wrapper.selectedFileIds = new List<String>{String.valueOf(contentDocumentId)};
        wrapper.ccEmails = '';
        wrapper.messageBody = 'Aura message';
        wrapper.emailSubject = 'Aura subject';

        String jsonInput = JSON.serialize(wrapper);

        Test.startTest();
        EYI_EmailService.sendEmail(jsonInput);
        EYI_EmailService.sendEmailAddActivity(jsonInput);
        EYI_EmailService.getAllContentDocumentsByRecordId(new List<Id>());
        Test.stopTest();
    }
   @isTest
    static void testSendEmailAuraMethod2() {
         EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = '234',
            EYI_Project_Property_Type__c = 'Residential'
        );
        insert proj;
        Lead ld = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Phone = '9876543210',
            Company = 'Test Co',
            Status = 'Open - Not Contacted',
            EYI_Project_Enquired__c =proj.Id,
            EYI_Segment__c = 'Residential',
            LeadSource = 'PREC',
            EYI_AutomationBypassDatetime__c = System.now()
        );
        insert ld;

        // Create Lead Enquiry
        EYI_Lead_Enquiry__c leadEnq = new EYI_Lead_Enquiry__c(
            EYI_Parent_Record__c = ld.Id,
            EYI_Segment__c = 'Residential',
            EYI_Phone__c = '9876543210',
            EYI_Email__c = 'test.lead@example.com',
            EYI_Lead_Source__c = 'PREC',
            //EYI_Lead_Status__c = 'Open',
            EYI_Project_Enquired__c = proj.Id
        );
        insert leadEnq;
        // Create ContentVersion and link as in previous
        ContentVersion cv = new ContentVersion(
            Title = 'AuraTest',
            PathOnClient = 'AuraTest.pdf',
            VersionData = Blob.valueOf('Aura file')
        );
        insert cv;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = leadEnq.Id;
        cdl.ShareType = 'V';   // 'V' = Viewer permission; 'C' = Collaborator permission
        cdl.Visibility = 'AllUsers'; // visibility setting

        insert cdl;
        EYI_BrochureCommunicationWrapper wrapper = new EYI_BrochureCommunicationWrapper();
        wrapper.leadId = leadEnq.Id;
        wrapper.projectName = 'Aura Project';
        wrapper.projectId = null;
        wrapper.senderEmail = 'aura@example.com';
        wrapper.senderPhone = '9999999999';
        wrapper.selectedFileIds = new List<String>{String.valueOf(contentDocumentId)};
        wrapper.ccEmails = '';
        wrapper.messageBody = 'Aura message';
        wrapper.emailSubject = 'Aura subject';

        String jsonInput = JSON.serialize(wrapper);

        Test.startTest();
        List<Id> leadEnqIds = new List<Id>{ leadEnq.Id };
        try {
              EYI_EmailService.getAllContentDocumentsByRecordId(leadEnqIds);
        } catch (Exception e) {
            
        }
          
        Test.stopTest();
    }   
    
}