@isTest
private class RecordFileDownloaderControllerTest {

    @isTest
    static void testGetFileIdsWithMatchingDocument() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create a ContentVersion with matching title
        ContentVersion cv = new ContentVersion(
            Title = 'PANCARD_TestDoc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        // Get the ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Link the document to the Account
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = acc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        Test.startTest();
        List<Id> result = RecordFileDownloaderController.getfileIds(new List<String>{acc.Id});
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one ContentVersion Id');
    }

    @isTest
    static void testGetFileIdsWithNoMatchingTitle() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;

        // Create a ContentVersion with non-matching title
        ContentVersion cv = new ContentVersion(
            Title = 'AADHAAR_TestDoc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        // Get the ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Link the document to the Account
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = acc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        Test.startTest();
        List<Id> result = RecordFileDownloaderController.getfileIds(new List<String>{acc.Id});
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list due to title mismatch');
    }

    @isTest
    static void testGetFileIdsWithNoContentDocumentLink() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account 3');
        insert acc;

        Test.startTest();
        List<Id> result = RecordFileDownloaderController.getfileIds(new List<String>{acc.Id});
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list due to no ContentDocumentLink');
    }

    @isTest
    static void testGetFileIdsWithEmptyAndNullInput() {
        Test.startTest();
        List<Id> result1 = RecordFileDownloaderController.getfileIds(new List<String>());
        List<Id> result2 = RecordFileDownloaderController.getfileIds(null);
        Test.stopTest();

        System.assertEquals(0, result1.size(), 'Should return empty list for empty input');
        System.assertEquals(0, result2.size(), 'Should return empty list for null input');
    }
}