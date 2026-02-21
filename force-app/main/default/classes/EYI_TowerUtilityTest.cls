@isTest
private class EYI_TowerUtilityTest {
    
    private static final String FOLDER_DEV_NAME = 'Possession_Email_Templates';
    
    @testSetup
    static void setupData() {
        // Create non-setup objects first to avoid mixed DML
        // Create custom object for Tower
        EYI_Tower__c tower = new EYI_Tower__c(Name = 'Test Tower');
        insert tower;

        // Create Opportunities
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'John',
            EYI_Last_Name__c = 'Doe',
            EYI_Email_Id__c = 'john.doe@example.com',
            EYI_Mobile_number__c = '9876543210',
            EYI_Project_Type__c = 'Residential',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
			EYI_Customer_Address_Type__c = 'Pune',
			EYI_State__c = 'Maharashtra'
        );
        insert cif;
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(
                Name = 'Opp 1',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                EYI_Project_Tower_Enquired__c = tower.Id,
                EYI_Alternate_Email__c = 'test1@example.com',
                EYI_Possession_Status__c = 'OC Received',
                OwnerId = UserInfo.getUserId(),
                EYI_CIF_Record__c = cif.Id
            ),
            new Opportunity(
                Name = 'Opp 2',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(20),
                EYI_Project_Tower_Enquired__c = tower.Id,
                EYI_Alternate_Email__c = 'test2@example.com',
                EYI_Possession_Status__c = 'NDC Completed',
                OwnerId = UserInfo.getUserId(),
                EYI_CIF_Record__c = cif.Id
            )
        };
        insert opps;

        // Create ContentDocument and ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert cv;

        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = tower.Id,
            ShareType = 'V'
        );
        insert cdl;

        // Now create setup object (EmailTemplate) in a separate transaction
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Query for an existing folder
            Folder folder;
            try {
                folder = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName = :FOLDER_DEV_NAME AND Type = 'Email' LIMIT 1];
            } catch (Exception e) {
                // Fallback to Unfiled Public Email Templates if folder not found
                folder = [SELECT Id FROM Folder WHERE Name = 'Unfiled Public Email Templates' LIMIT 1];
            }

            // Create EmailTemplate
            EmailTemplate et = new EmailTemplate(
                Name = 'Test Possession Template',
                DeveloperName = 'Test_Possession_Template',
                Subject = 'Test Subject',
                HtmlValue = '<p>Test HTML</p>',
                Body = 'Test Body',
                FolderId = folder.Id,
                TemplateType = 'custom'
            );
            insert et;
        }
    }

    @isTest
    static void testGetOpportunities() {
        EYI_Tower__c tower = [SELECT Id FROM EYI_Tower__c];
        
        Test.startTest();
        List<Opportunity> opps = EYI_TowerUtility.getOpportunities(tower.Id);
        Test.stopTest();
        System.assertEquals('Opp 1', opps[0].Name, 'Opportunity name should match');
        System.assertEquals(tower.Id, opps[0].EYI_Project_Tower_Enquired__c, 'Tower Id should match');
    }

    @isTest
    static void testGetOpportunitiesInvalidId() {
        Test.startTest();
        List<Opportunity> opps = EYI_TowerUtility.getOpportunities(null);
        Test.stopTest();
        
        System.assertEquals(0, opps.size(), 'Should return no opportunities for null tower Id');
    }

    @isTest
    static void testGetEmailTemplates() {
        Test.startTest();
        List<EmailTemplate> templates = EYI_TowerUtility.getEmailTemplates();
        Test.stopTest();
        
        // if ([SELECT COUNT() FROM Folder WHERE DeveloperName = :FOLDER_DEV_NAME AND Type = 'Email'] > 0) {
        //     // System.assertEquals(2, templates.size(), 'Should return two email template');
        //     System.assertEquals(FOLDER_DEV_NAME, templates[0].Folder.DeveloperName, 'Folder developer name should match');
        //     System.assertEquals('OC Received', templates[0].Name, 'Template name should match');
        // } else {
        //     System.assertEquals(0, templates.size(), 'Should return no templates if folder does not exist');
        // }
    }

    @isTest
    static void testGetTowerDocuments() {
        EYI_Tower__c tower = [SELECT Id FROM EYI_Tower__c WHERE Name = 'Test Tower' LIMIT 1];
        
        Test.startTest();
        List<ContentDocumentLink> docs = EYI_TowerUtility.getTowerDocuments(new List<Id>{tower.Id});
        Test.stopTest();
        
        System.assertEquals(1, docs.size(), 'Should return one document link');
        System.assertEquals('TestDoc', docs[0].ContentDocument.Title, 'Document title should match');
    }

    @isTest
    static void testGetTowerDocumentsEmptyList() {
        Test.startTest();
        List<ContentDocumentLink> docs = EYI_TowerUtility.getTowerDocuments(new List<Id>());
        Test.stopTest();
        
        System.assertEquals(0, docs.size(), 'Should return no documents for empty tower Id list');
    }

    @isTest
    static void testSendEmailsWithAttachments() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE EYI_Email__c != null AND EYI_Possession_Status__c != 'Possession Completed'];
        if (!opps.isEmpty()) {
            ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
            
            Test.startTest();
            EYI_TowerUtility.sendEmails(
                new List<Id>{opps[0].Id},
                new List<Id>{cd.Id},
                'Test Subject',
                'Test Body'
            );
            Test.stopTest();
            
            // System.assertEquals(1, Limits.getEmailInvocations(), 'One email should be sent');
        }
    }

    @isTest
    static void testSendEmailsWithoutAttachments() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE EYI_Email__c != null AND EYI_Possession_Status__c != 'Possession Completed'];
        if (!opps.isEmpty()) {
            Test.startTest();
            EYI_TowerUtility.sendEmails(
                new List<Id>{opps[0].Id},
                new List<Id>(),
                'Test Subject',
                'Test Body'
            );
            Test.stopTest();
            
            // System.assertEquals(1, Limits.getEmailInvocations(), 'One email should be sent');
        }
    }

    @isTest
    static void testSendEmailsNoValidOpportunities() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE EYI_Possession_Status__c = 'NDC Completed'];
        if (!opps.isEmpty()) {
            Test.startTest();
            EYI_TowerUtility.sendEmails(
                new List<Id>{opps[0].Id},
                new List<Id>(),
                'Test Subject',
                'Test Body'
            );
            Test.stopTest();
            
            System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent for NDC Completed');
        }
    }

    @isTest
    static void testSendEmailsInvalidOpportunity() {
        Test.startTest();
        Account acc = new Account();
        acc.name= 'Test Account';
        insert acc;
        EYI_TowerUtility.sendEmails(
            new List<Id>{acc.Id},
            new List<Id>(),
            'Test Subject',
            'Test Body'
        );
        Test.stopTest();
        
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent for invalid opportunity Id');
    }
}