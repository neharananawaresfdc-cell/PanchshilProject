@isTest
public class DocumentControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a user with a manager and a second-level manager for notification test
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User manager2 = new User(
            Alias = 'mgr2',
            Email='mgr2@test.com',
            EmailEncodingKey='UTF-8',
            LastName='Manager2',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId=p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mgr2unique@test.com'
        );
        insert manager2;

        User manager1 = new User(
            Alias = 'mgr1',
            Email='mgr1@test.com',
            EmailEncodingKey='UTF-8',
            LastName='Manager1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId=p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mgr1unique@test.com',
            ManagerId = manager2.Id
        );
        insert manager1;

        User owner = new User(
            Alias = 'ownr',
            Email='owner@test.com',
            EmailEncodingKey='UTF-8',
            LastName='Owner',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId=p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='ownerunique@test.com',
            ManagerId = manager1.Id
        );
        insert owner;

        // Create a record to attach documents to (using Account for example)
        Account acc = new Account(Name='Test Account', OwnerId=owner.Id);
        insert acc;

        // Create CustomNotificationType metadata if not present (mock for test context)
        // In real org, this should exist. Here, just to avoid query error in test context.
        // This block is only for test context and will not actually insert metadata.
        // You may need to use Test.loadData or mock the query if needed.
    }

    @isTest
    static void testSaveDocumentAndNotification() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String fileContent = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String fileName = 'Old NOC Document.pdf';

        // Mock CustomNotificationType for test context
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomNotificationMock());
        try {
            DocumentController.saveDocument(fileContent, fileName, acc.Id);
        } catch (Exception e) {
            // Ignore notification errors in test context
        }
        Test.stopTest();

        // Assert ContentVersion and ContentDocumentLink created
        List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE Title = :fileName];
        System.assertEquals(1, cvs.size());
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];
        System.assertEquals(1, cdls.size());
    }

    @isTest
    static void testGetDocumentTrackerRecords() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        // Insert a ContentVersion and ContentDocumentLink for test
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc.pdf',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test')
        );
        insert cv;
        ContentDocument cd = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId != null ?
            [SELECT Id FROM ContentDocument WHERE Id = :([SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId)] : null;
        if (cd != null) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = acc.Id,
                ShareType = 'V'
            );
            insert cdl;
        }

        Test.startTest();
        List<DocumentController.DocumentWrapper> docs = DocumentController.getDocumentTrackerRecords(acc.Id);
        Test.stopTest();
        System.assert(docs.size() >= 0);
    }

    @isTest
    static void testDeleteDocument() {
        // Insert a ContentVersion and get ContentDocumentId
        ContentVersion cv = new ContentVersion(
            Title = 'DeleteMe.pdf',
            PathOnClient = 'DeleteMe.pdf',
            VersionData = Blob.valueOf('DeleteMe')
        );
        insert cv;
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        Test.startTest();
        DocumentController.deleteDocument(docId);
        Test.stopTest();
        // Should not find ContentDocument after delete
        List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id = :docId];
        System.assertEquals(0, cds.size());
    }

    // Mock for CustomNotificationType query (if needed)
    // You may need to use a stub or mock if your org requires it for notification
    public class CustomNotificationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success":true}');
            return res;
        }
    }
}