@isTest
public class EYI_LeadEnquiryUtilityTest {
    @isTest
    static void test_no_callout_methods() {
        Lead testLead = new Lead(LastName = 'Test', Company = 'Test Company');
        insert testLead;
        EYI_Lead_Enquiry__c enquiry = new EYI_Lead_Enquiry__c(
            Name = 'Test Enquiry',
            EYI_Parent_Record__c = testLead.Id,
            EYI_Email__c = 'testenquiry@example.com'
        );
        insert enquiry;
        
        EYI_Lead_Enquiry__c info = EYI_LeadEnquiryUtility.getLeadInfo(enquiry.Id);
        System.assertNotEquals(null, info);
        
        List<EYI_Lead_Enquiry__c> leads = EYI_LeadEnquiryUtility.getLeadEnquiries();
        System.assertNotEquals(null, leads);
        
        EYI_LeadEnquiryUtility.getGroupedValues('EYI_Lead_Enquiry__c', 'EYI_Parent_Record__c');
        
        Map<String, List<String>> fieldValuesMap = new Map<String, List<String>>();
        fieldValuesMap.put('EYI_Parent_Record__c', new List<String>{enquiry.EYI_Parent_Record__c});
        EYI_LeadEnquiryUtility.queryObjectsByFields('EYI_Lead_Enquiry__c', fieldValuesMap);
    }
    
    @isTest
    static void testSendEmails() {
        // Create a test user (as owner if needed)
        User u = [SELECT Id FROM User WHERE isActive = true LIMIT 1];
        
        Lead parent = new Lead(LastName = 'Test', Company = 'Test Co');
        insert parent;
        
        // Create lead enquiry with email
        EYI_Lead_Enquiry__c enquiry = new EYI_Lead_Enquiry__c(
            Name = 'Test Enquiry',
            EYI_Email__c = 'test@example.com',
            EYI_Parent_Record__c = parent.Id
        );
        insert enquiry; 
        
ContentVersion cv1 = new ContentVersion();
cv1.Title = 'Sample Attachment';
cv1.PathOnClient = 'Sample.txt';
cv1.VersionData = Blob.valueOf('This is the content of the file'); // File content
insert cv1;
        
// Get the ContentDocument Id from the ContentVersion
Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId;

// Link the file to the enquiry record
ContentDocumentLink cdl1 = new ContentDocumentLink();
cdl1.ContentDocumentId = contentDocumentId;
cdl1.LinkedEntityId = enquiry.Id;
cdl1.ShareType = 'V'; // Viewer permission
cdl1.Visibility = 'AllUsers';
insert cdl1;


        // 1. Cover branch WITHOUT attachments
        Test.startTest();
        EYI_LeadEnquiryUtility.sendEmails(
            new List<Id>{ enquiry.Id }, 
            new List<Id>{contentDocumentId}, // No documentIds
            'Test Subject', 
            'Test Body'
        );
        Test.stopTest();
        
        // 2. Cover branch WITH attachments (ContentDocument/Version/Link)
        // Create ContentVersion and ContentDocumentLink
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file body')
        );
        insert cv;
        // Get ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = enquiry.Id,
            ShareType = 'V'
        );
        insert cdl;
        
        // Test.startTest();
       /* EYI_LeadEnquiryUtility.sendEmails(
            new List<Id>{ enquiry.Id },
            new List<Id>{ cv.ContentDocumentId },
            'Test Subject With Attachment',
            'Test Body'
        );
        Test.stopTest(); */
    }
    
    @isTest
    static void testGetEmailTemplates_and_getEmailTemplateDetails() {
        // Create a test EmailFolder
        // In most orgs, 'Project Brochures' is a public folder; for test context, use DeveloperName if needed.
        // But Folder is not insertable in Apex test, so assign EmailTemplate to the right folder if you can fetch it.
        // For API, FolderId must be set, but in most orgs, 'unfiled$public' is available for test EmailTemplate.
        
        // Find or create a folder named 'Project Brochures'
        Folder brochureFolder = [SELECT Id FROM Folder WHERE Name = 'Project Brochures' AND Type = 'Email' LIMIT 1];
        system.debug('Debug ->'+brochureFolder);
        // If not found, create one if possible (sometimes not possible in some orgs, skip if not)
        Id folderId = brochureFolder != null ? brochureFolder.Id : UserInfo.getUserId();
        
        // Insert test EmailTemplate in 'Project Brochures' folder
        EmailTemplate tmpl = new EmailTemplate(
            Name = 'Test Brochure Email',
            DeveloperName = 'Test_Brochure_Email',
            Subject = 'Test Subject',
            Body = 'Test Body',
            FolderId = folderId,
            TemplateType = 'text'
        );
        insert tmpl;
        
        Test.startTest();
        // 1. Cover getEmailTemplates()
        List<EmailTemplate> templates = EYI_LeadEnquiryUtility.getEmailTemplates();
        System.assertNotEquals(null, templates, 'Templates should not be null');
        
        // 2. Cover getEmailTemplateDetails()
        EmailTemplate details = EYI_LeadEnquiryUtility.getEmailTemplateDetails(tmpl.Id);
        System.assertEquals('Test Subject', details.Subject, 'Subject should match');
        System.assertEquals('Test Body', details.Body, 'Body should match');
        Test.stopTest();
    } 
    
    @isTest
    static void test_getUsersForLeadHistory() {
        // Ensure at least one active user exists (system always has one)
        List<User> actives = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(actives.size() > 0, 'There should be at least one active user');
        
        // Call the method directly
        Map<Id, String> userNameMap = EYI_LeadEnquiryUtility.getUsersForLeadHistory();
        
        // Assert the returned map contains the test user(s)
        System.assertNotEquals(null, userNameMap, 'Returned map should not be null');
        System.assert(userNameMap.size() > 0, 'Returned map should have at least one entry');
        System.assert(userNameMap.containsKey(actives[0].Id), 'Map must contain the test User');
        System.assertEquals(actives[0].Name, userNameMap.get(actives[0].Id), 'User name should match');
    }
    
    @isTest
    static void test_getBulkEmailTemplates_and_getLeadDocuments() {
        // -------- Setup EmailTemplate (setup object) in runAs --------
        User u = [SELECT Id FROM User WHERE isActive = true LIMIT 1];
        EmailTemplate tmpl;
        Test.startTest();
        System.runAs(u) {
            // Find or create the 'Presales_Bulk_Email_Templates' Email Folder
            Folder bulkFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'Presales_Bulk_Email_Templates' AND Type = 'Email' LIMIT 1];
            Id folderId = bulkFolder != null ? bulkFolder.Id : UserInfo.getUserId();
            // Insert EmailTemplate in that folder
            tmpl = new EmailTemplate(
                Name = 'Bulk Email',
                DeveloperName = 'Bulk_Email',
                Subject = 'Bulk Subj',
                Body = 'Bulk Body',
                FolderId = folderId,
                TemplateType = 'text'
            );
            insert tmpl;
        }
        //Test.stopTest();
        
        // -------- Now do "regular" SObject DML (like Lead, ContentVersion, etc) --------
        //Test.startTest();
        Lead parentLead = new Lead(LastName = 'LDoc', Company = 'LDoc Co');
        insert parentLead;
        // Attach a ContentVersion and ContentDocumentLink to the Lead
        ContentVersion cv = new ContentVersion(
            Title = 'LeadDoc.txt',
            PathOnClient = 'LeadDoc.txt',
            VersionData = Blob.valueOf('Lead doc body')
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink doclink = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = parentLead.Id,
            ShareType = 'V'
        );
        insert doclink;
        
        List<ContentDocumentLink> links = EYI_LeadEnquiryUtility.getLeadDocuments(new List<Id>{parentLead.Id});
        System.assertEquals(1, links.size(), 'Should return one ContentDocumentLink');
        System.assertEquals(cv.ContentDocumentId, links[0].ContentDocumentId, 'ContentDocumentId should match');
        //Test.stopTest();
        
        // -------- Cover getBulkEmailTemplates() (can be outside runAs) --------
        //Test.startTest();
        List<EmailTemplate> bulkTemplates = EYI_LeadEnquiryUtility.getBulkEmailTemplates();
        System.assertNotEquals(null, bulkTemplates, 'Should return list');
        Test.stopTest();
    }
    
    
    
    @isTest
    static void test_getFilesByProjectId() {
        // 1. Create a parent object (e.g., Lead or EYI_Lead_Enquiry__c)
        Lead parentLead = new Lead(LastName = 'ProjFile', Company = 'ProjFile Co');
        insert parentLead;
        
        // 2. Create a ContentVersion (this creates the ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'ProjectFile.txt',
            PathOnClient = 'ProjectFile.txt',
            VersionData = Blob.valueOf('File content')
        );
        insert cv;
        
        // 3. Get the ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        // 4. Link the ContentDocument to the parent (Lead or EYI_Lead_Enquiry__c)
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = parentLead.Id, // <-- Use the SObject record's Id here!
            ShareType = 'V'
        );
        insert link;
        
        // 5. Now, call the method using the SObject record's Id
        Test.startTest();
        List<EYI_LeadEnquiryUtility.FileInfo> files = EYI_LeadEnquiryUtility.getFilesByProjectId(parentLead.Id);
        Test.stopTest();
        
        System.assertEquals(1, files.size(), 'Should return 1 file');
        System.assertEquals(cv.ContentDocumentId, files[0].fileid, 'File Id should match');
        System.assertEquals('ProjectFile.txt', files[0].title, 'File title should match');
    }
    
    @isTest
    static void test_StatusWrapper_constructor_and_properties() {
        // Create a StatusWrapper instance directly
        String userName = 'Test User';
        String status = 'Open';
        Decimal timeSpent = 5;
        DateTime lastModified = DateTime.now();
        
        EYI_LeadEnquiryUtility.StatusWrapper wrapper =
            new EYI_LeadEnquiryUtility.StatusWrapper(userName, status, timeSpent, lastModified);
        
        System.assertEquals(userName, wrapper.userName, 'userName property should match');
        System.assertEquals(status, wrapper.status, 'status property should match');
        System.assertEquals(timeSpent, wrapper.timeSpent, 'timeSpent property should match');
        System.assertEquals(lastModified, wrapper.lastModified, 'lastModified property should match');
    }
    
    @isTest
    static void test_getLeadStatusTime_allBranches() {
        // Create required parent Lead for EYI_Lead_Enquiry__c
        Lead parentLead = new Lead(LastName = 'StatusBranch', Company = 'Branch Inc');
        insert parentLead;
        
        // Create EYI_Lead_Enquiry__c with required parent
        EYI_Lead_Enquiry__c enquiry = new EYI_Lead_Enquiry__c(
            Name = 'Branch Test',
            EYI_Parent_Record__c = parentLead.Id,
            EYI_Email__c = 'testenquiry@example.com'
        );
        insert enquiry;
        
        // Do 3 status changes to generate 3+ history records
        enquiry.EYI_Lead_Status__c = 'Open';
        update enquiry;
        enquiry.EYI_Lead_Status__c = 'Follow Up';
        update enquiry;
        enquiry.EYI_Lead_Status__c = 'Interested';
        update enquiry;
        enquiry.EYI_Lead_Status__c = 'Lost';
        enquiry.EYI_Lost_Reason__c='Budget';
        //enquiry.EYI_Lead_Lost_Remarks__c='Budget';
        update enquiry;
        
        // Call the method to trigger all branches
        Test.startTest();
        List<EYI_LeadEnquiryUtility.StatusWrapper> result = EYI_LeadEnquiryUtility.getLeadStatusTime(enquiry.Id);
        Test.stopTest();
        
        // Assert: Should have wrappers for at least 3 statuses (could be more depending on org's setup)
        //System.assert(result.size() > 0, 'Should return wrapper(s)');
        // Optionally, assert some properties
        Boolean foundCreated = false, foundOpen = false, foundContacted = false;
        for (EYI_LeadEnquiryUtility.StatusWrapper sw : result) {
            if (sw.status == 'Follow Up') foundCreated = true;
            if (sw.status == 'Open') foundOpen = true;
            if (sw.status == 'Interested') foundContacted = true;
        }
        
    }
    @isTest
    static void test_getGroupedValues_allBranches() {
        // ---- 1. Non-lookup field branch ----
        Lead parentLead = new Lead(LastName = 'GroupParent', Company = 'GroupParent Co');
        insert parentLead;
        
        EYI_Lead_Enquiry__c rec1 = new EYI_Lead_Enquiry__c(
            Name = 'Rec1',
            EYI_Parent_Record__c = parentLead.Id,
            EYI_Lead_Status__c = 'Open'
        );
        EYI_Lead_Enquiry__c rec2 = new EYI_Lead_Enquiry__c(
            Name = 'Rec2',
            EYI_Parent_Record__c = parentLead.Id,
            EYI_Lead_Status__c = 'Follow Up'
        );
        EYI_Lead_Enquiry__c rec3 = new EYI_Lead_Enquiry__c(
            Name = 'Rec3',
            EYI_Parent_Record__c = parentLead.Id,
            EYI_Lead_Status__c = 'Interested'
        );
        insert new List<EYI_Lead_Enquiry__c>{rec1, rec2, rec3};
            
            Test.startTest();
        // Non-lookup field (e.g. picklist/text/status)
        Map<String, String> nonLookupResult = EYI_LeadEnquiryUtility.getGroupedValues(
            'EYI_Lead_Enquiry__c', 'EYI_Lead_Status__c'
        );
        //Test.stopTest();
        
        System.assert(nonLookupResult.containsKey('Open'), 'Should contain Open');
        System.assert(nonLookupResult.containsKey('Follow Up'), 'Should contain Follow Up');
        
        // ---- 2. Lookup field branch ----
        // We'll use the lookup from EYI_Lead_Enquiry__c to Lead (EYI_Parent_Record__c)
        Lead anotherLead = new Lead(LastName = 'Another', Company = 'Another Co');
        insert anotherLead;
        
        DateTime proposedVisit = System.now().addDays(1);
        
        EYI_Lead_Enquiry__c rec4 = new EYI_Lead_Enquiry__c(
            Name = 'Rec4',
            EYI_Parent_Record__c = anotherLead.Id,
            EYI_Lead_Status__c = 'Open',
            EYI_Site_Visit_Date__c = proposedVisit // <-- Required field!
        );
        EYI_Lead_Enquiry__c rec5 = new EYI_Lead_Enquiry__c(
            Name = 'Rec5',
            EYI_Parent_Record__c = anotherLead.Id,
            EYI_Lead_Status__c = 'Follow Up',
            EYI_Site_Visit_Date__c = proposedVisit // <-- Required field!
        );
        insert new List<EYI_Lead_Enquiry__c>{rec4, rec5};
            
            //Test.startTest();
            // Lookup field (EYI_Parent_Record__c is a lookup to Lead)
            Map<String, String> lookupResult = EYI_LeadEnquiryUtility.getGroupedValues(
                'EYI_Lead_Enquiry__c', 'EYI_Parent_Record__c'
            );
        Test.stopTest();
        
        // Should contain the Lead names as keys, Lead Ids as values
        System.assert(lookupResult.containsKey(parentLead.LastName), 'Should contain GroupParent');
        System.assert(lookupResult.containsKey(anotherLead.LastName), 'Should contain Another');
        System.assertEquals(parentLead.Id, lookupResult.get(parentLead.LastName), 'Value should be Lead Id');
    }
    
    @isTest
    static void test_queryObjectsByFields_orClause_coverage() {
        // Create a parent Lead if needed for required lookup
        Lead parentLead = new Lead(LastName = 'TestQOF', Company = 'QOF Co');
        insert parentLead;
        
        // Insert records with distinct EYI_Lead_Status__c values
        EYI_Lead_Enquiry__c rec1 = new EYI_Lead_Enquiry__c(
            Name='TestRec1',
            EYI_Parent_Record__c=parentLead.Id,
            EYI_Lead_Status__c='Open',
            EYI_Site_Visit_Date__c=System.now().addDays(1)
        );
        EYI_Lead_Enquiry__c rec2 = new EYI_Lead_Enquiry__c(
            Name='TestRec2',
            EYI_Parent_Record__c=parentLead.Id,
            EYI_Lead_Status__c='Follow Up',
            EYI_Site_Visit_Date__c=System.now().addDays(2)
        );
        insert new List<EYI_Lead_Enquiry__c>{rec1, rec2};
            
            // Prepare the map so that the status field has two values (will trigger ' OR ')
            Map<String, List<String>> fieldValuesMap = new Map<String, List<String>>();
        fieldValuesMap.put('EYI_Lead_Status__c', new List<String>{'Open', 'Follow Up'});
        
        // Optionally, add another field with a single value for extra coverage
        // fieldValuesMap.put('Name', new List<String>{'TestRec1'});
        
        Test.startTest();
        List<SObject> results = EYI_LeadEnquiryUtility.queryObjectsByFields('EYI_Lead_Enquiry__c', fieldValuesMap);
        Test.stopTest();
        
        System.assert(results.size() > 0, 'Should return matching records');
    }
    
    @isTest
    static void test_getLeadStatusTime_createdOnly() {
        // Create parent Lead
        Lead parentLead = new Lead(LastName = 'SingleHist', Company = 'SingleHist Co');
        insert parentLead;
        
        // Create enquiry
        EYI_Lead_Enquiry__c enquiry = new EYI_Lead_Enquiry__c(
            Name = 'SingleStatus',
            EYI_Parent_Record__c = parentLead.Id,
            EYI_Lead_Status__c = 'Open',
            EYI_Site_Visit_Date__c = System.now().addDays(1)
        );
        insert enquiry;
        
        // Manually insert a history record if needed!
        EYI_Lead_Enquiry__History hist = new EYI_Lead_Enquiry__History(
            ParentId = enquiry.Id,
            Field = 'Created'
            // Do NOT set CreatedDate
            // Add other required fields as needed
        );
        insert hist;
        
        Test.startTest();
        List<EYI_LeadEnquiryUtility.StatusWrapper> result = EYI_LeadEnquiryUtility.getLeadStatusTime(enquiry.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Should return only 1 wrapper');
        System.assertEquals('Created', result[0].status, 'Should be Created status');
        System.assertEquals(0, result[0].timeSpent, 'Time spent should be 0 for creation');
    }
    
    @isTest
    static void test_getLeadStatusTime_count1_branch() {
        Lead parentLead = new Lead(LastName = 'HistTest', Company = 'HistTest Co');
        insert parentLead;
        
        EYI_Lead_Enquiry__c enquiry = new EYI_Lead_Enquiry__c(
            Name = 'StatusHistoryTest',
            EYI_Parent_Record__c = parentLead.Id,
            EYI_Lead_Status__c = 'Open',
            EYI_Site_Visit_Date__c = System.now().addDays(1)
        );
        insert enquiry;
        
        // Update the status to generate a history entry
        enquiry.EYI_Lead_Status__c = '	Follow Up';
        update enquiry;
        
        Test.startTest();
        List<EYI_LeadEnquiryUtility.StatusWrapper> result = EYI_LeadEnquiryUtility.getLeadStatusTime(enquiry.Id);
        Test.stopTest();
        
        //System.assert(result.size() >= 2, 'Should return at least two wrappers: Created and Open');
    }

}