@isTest
public class EYI_GetCaseRecords_Test {

    @TestSetup
    public static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'test123',
            Email = 'test@panchshil.com.test',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test' + Math.random() + '@panchshil.com.test'
        );
        insert testUser;

        Account acc = new Account(Name='Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(30),
            AccountId=acc.Id,
            EYI_SAP_Customer_Number__c = 'SAP123456'
        );
        insert opp;

        Contact contact = new Contact(
            FirstName = 'Doc',
            LastName = 'Linked',
            Email = 'linked@example.com',
            AccountId = acc.Id
        );
        insert contact;

        Id recTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName='Post_Sales' LIMIT 1].Id;
        Case c = new Case(
            Subject='Case Subject',
            Status='New',
            Origin='Phone',
            RecordTypeId=recTypeId,
            EYI_Opportunity__c=opp.Id,
            SuppliedName='Test Name',
            SuppliedEmail='test@panchshil.com.test',
            ContactId=contact.Id
        );
        insert c;

        ContentVersion cv = new ContentVersion(
            Title='Test Doc',
            PathOnClient='TestDoc.pdf',
            VersionData=Blob.valueOf('Test content'),
            IsMajorVersion=true
        );
        insert cv;

        ContentVersion fetched = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id LIMIT 1];
        insert new ContentDocumentLink(
            ContentDocumentId=fetched.ContentDocumentId,
            LinkedEntityId=c.Id,
            ShareType='V',
            Visibility='AllUsers'
        );

        insert new EYI_Comments__c(
            EYI_Synced_Case__c=c.Id,
            EYI_Mobile_App_Comments__c='Test comment for mobile app'
        );
    }

    @isTest static void testFindByCaseIdAndNumber() {
        Case c = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        GetCaseWrapper.CaseRequest reqObj = new GetCaseWrapper.CaseRequest();
        reqObj.CaseId = c.Id;
        reqObj.CaseNumber = c.CaseNumber;

        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>{reqObj}));

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assert(response.status);
        System.assertEquals('Records retrieved successfully', response.message);
        System.assertEquals(1, response.cases.size());
        System.assertEquals(1, response.cases[0].documentLinks.size());
    }

    @isTest static void testFindBySAPCustomerNumber() {
        Opportunity opp = [SELECT EYI_SAP_Customer_Number__c FROM Opportunity LIMIT 1];
        GetCaseWrapper.CaseRequest reqObj = new GetCaseWrapper.CaseRequest();
        reqObj.sap_customer_codes = opp.EYI_SAP_Customer_Number__c;

        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>{reqObj}));

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assert(response.status);
        System.assertEquals(1, response.cases.size());
    }

    @isTest static void testFindWithComments() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        GetCaseWrapper.CaseRequest reqObj = new GetCaseWrapper.CaseRequest();
        reqObj.CaseId = c.Id;

        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>{reqObj}));

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assertEquals(1, response.cases[0].comments.size());
        System.assertEquals('Test comment for mobile app', response.cases[0].comments[0].mobileAppComment);
    }

    @isTest static void testFindWithInvalidCaseId() {
        GetCaseWrapper.CaseRequest reqObj = new GetCaseWrapper.CaseRequest();
        reqObj.CaseId = '500XXXXX';

        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>{reqObj}));

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assertEquals(false, response.status);
        System.assert(response.message.contains('Invalid id'));
    }

    @isTest static void testFindWithEmptyRequest() {
        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>()));
        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assertEquals(false, response.status);
    }

    @isTest static void testFindWithMalformedJSON() {
        simulateRestContext('Invalid JSON String');
        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assertEquals(false, response.status);
        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest static void testFindWithNullFields() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        GetCaseWrapper.CaseRequest reqObj = new GetCaseWrapper.CaseRequest();
        reqObj.CaseId = c.Id;
        reqObj.CaseNumber = '';
        reqObj.sap_customer_codes = null;

        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>{reqObj}));

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assertEquals(1, response.cases.size());
    }

    @isTest static void testFindWithInvalidSAPCode() {
        GetCaseWrapper.CaseRequest reqObj = new GetCaseWrapper.CaseRequest();
        reqObj.sap_customer_codes = 'INVALID_CODE';

        simulateRestContext(JSON.serialize(new List<GetCaseWrapper.CaseRequest>{reqObj}));

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        System.assertEquals(false, response.status);
        System.assertEquals(0, response.cases.size());
    }

    @isTest static void testGetCaseDocumentPublicUrls_Valid() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Map<Id, List<GetCaseWrapper.DocumentDetail>> result =
            EYI_GetCaseRecords.getCaseDocumentPublicUrls(new Set<Id>{c.Id});

        System.assertEquals(1, result.get(c.Id).size());
    }

    @isTest static void testGetCaseDocumentPublicUrls_Empty() {
        Map<Id, List<GetCaseWrapper.DocumentDetail>> result =
            EYI_GetCaseRecords.getCaseDocumentPublicUrls(new Set<Id>());
        System.assertEquals(0, result.size());
    }

    @isTest static void testGetCaseDocumentPublicUrls_NoLinkedDocs() {
        Contact contact = new Contact(
            FirstName = 'NoDoc',
            LastName = 'Tester',
            Email = 'nodoc@example.com'
        );
        insert contact;

        Case noDocCase = new Case(
            Subject = 'No Doc Linked',
            Status = 'New',
            SuppliedName = 'Fallback Name',
            SuppliedEmail = 'nodoc@example.com',
            ContactId = contact.Id
        );
        insert noDocCase;

        Map<Id, List<GetCaseWrapper.DocumentDetail>> result =
            EYI_GetCaseRecords.getCaseDocumentPublicUrls(new Set<Id>{noDocCase.Id});

        System.assertEquals(0, result.size(), 'Expected no document links for this case');
    }

    private static void simulateRestContext(String body) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/getCase/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
    }
}