@isTest
private class EYI_DMS_RecordCreationTest {

    @isTest
    static void testCreateDmsRecords_InsertSuccess() {
        // Create a project with required fields
        EYI_Project__c proj = new EYI_Project__c(
            Name                = 'Insert Project',
            EYI_Project_Code__c = 'PRJ001'
        );
        insert proj;

        // Build the request payload
        EYI_DMS_RecordCreation.DocumentLinkWrapper doc = new EYI_DMS_RecordCreation.DocumentLinkWrapper();
        doc.SFDC_DocumentId    = null;
        doc.LockatedDocumentId = 'LOCK1';
        doc.url                = 'https://test.com/insert.pdf';
        doc.DocumentName       = 'Brochure';             // valid picklist value
        doc.ObjectName         = 'EYI_Project__c';
        doc.ProjectId          = proj.Id;
        doc.TowerId            = null;

        EYI_DMS_RecordCreation.RequestWrapper wrapper = new EYI_DMS_RecordCreation.RequestWrapper();
        wrapper.DocumentLinks = new List<EYI_DMS_RecordCreation.DocumentLinkWrapper>{ doc };

        // Set REST context
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        // Execute
        Test.startTest();
        String jsonResponse = EYI_DMS_RecordCreation.createDmsRecords();
        Test.stopTest();

        // Deserialize response
        List<Object> respList = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        System.assertEquals(1, respList.size());

        Map<String, Object> respMap = (Map<String, Object>) respList[0];
        System.assertEquals('S', respMap.get('Type'));
        System.assertEquals('DMS record processed successfully', respMap.get('Message'));
        System.assertEquals('LOCK1', respMap.get('LockatedDocumentId'));
        String newId = (String) respMap.get('SFDC_DocumentId');
        System.assertNotEquals(null, newId);

        // Verify record fields in DB
        EYI_DMS__c inserted = [
            SELECT EYI_Lockated_Document_Id__c, EYI_Document_Link__c, EYI_Document_Name__c
            FROM EYI_DMS__c
            WHERE Id = :newId
        ];
        System.assertEquals('LOCK1', inserted.EYI_Lockated_Document_Id__c);
        System.assertEquals('https://test.com/insert.pdf', inserted.EYI_Document_Link__c);
        System.assertEquals('Brochure', inserted.EYI_Document_Name__c);
    }

    @isTest
    static void testCreateDmsRecords_UpdateSuccess() {
        // Create a project and an existing DMS record
        EYI_Project__c proj = new EYI_Project__c(
            Name                = 'Update Project',
            EYI_Project_Code__c = 'PRJ002'
        );
        insert proj;

        EYI_DMS__c existing = new EYI_DMS__c(
            EYI_Lockated_Document_Id__c = 'OLDLOCK',
            EYI_Document_Link__c        = 'https://old.com/old.pdf',
            EYI_Document_Name__c        = 'Brochure',
            EYI_SFDC_Object_Name__c     = 'EYI_Project__c',
            EYI_Project__c              = proj.Id
        );
        insert existing;

        // Build wrapper to update this record
        EYI_DMS_RecordCreation.DocumentLinkWrapper doc = new EYI_DMS_RecordCreation.DocumentLinkWrapper();
        doc.SFDC_DocumentId    = existing.Id;
        doc.LockatedDocumentId = 'LOCK_UPDATE';
        doc.url                = 'https://new.com/updated.pdf';
        doc.DocumentName       = 'Brochure';
        doc.ObjectName         = 'EYI_Project__c';
        doc.ProjectId          = proj.Id;
        doc.TowerId            = null;

        EYI_DMS_RecordCreation.RequestWrapper wrapper = new EYI_DMS_RecordCreation.RequestWrapper();
        wrapper.DocumentLinks = new List<EYI_DMS_RecordCreation.DocumentLinkWrapper>{ doc };

        RestContext.request  = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(wrapper));

        // Execute
        Test.startTest();
        String jsonResponse = EYI_DMS_RecordCreation.createDmsRecords();
        Test.stopTest();

        // Verify updated record
        EYI_DMS__c updated = [
            SELECT EYI_Lockated_Document_Id__c, EYI_Document_Link__c
            FROM EYI_DMS__c
            WHERE Id = :existing.Id
        ];
        System.assertEquals('LOCK_UPDATE', updated.EYI_Lockated_Document_Id__c);
        System.assertEquals('https://new.com/updated.pdf', updated.EYI_Document_Link__c);

        // Assert response contains correct LockatedDocumentId
        List<Object> respList = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        Map<String, Object> respMap = (Map<String, Object>) respList[0];
        System.assertEquals('LOCK_UPDATE', respMap.get('LockatedDocumentId'));
        System.assertEquals(existing.Id, respMap.get('SFDC_DocumentId'));
        System.assertEquals('S', respMap.get('Type'));
    }

    @isTest
    static void testCreateDmsRecords_EmptyBodyError() {
        RestContext.request  = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf('');

        Test.startTest();
        String jsonResponse = EYI_DMS_RecordCreation.createDmsRecords();
        Test.stopTest();

        List<Object> respList = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        Map<String, Object> respMap = (Map<String, Object>) respList[0];

        System.assertEquals('E', respMap.get('Type'));
        System.assert(((String)respMap.get('Message')).contains('Request body cannot be empty'));
        System.assertEquals('', respMap.get('LockatedDocumentId'));
        System.assertEquals('', respMap.get('SFDC_DocumentId'));
    }

    @isTest
    static void testCreateDmsRecords_EmptyDocumentLinksError() {
        EYI_DMS_RecordCreation.RequestWrapper wrapper = new EYI_DMS_RecordCreation.RequestWrapper();
        wrapper.DocumentLinks = new List<EYI_DMS_RecordCreation.DocumentLinkWrapper>();

        RestContext.request  = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(wrapper));

        Test.startTest();
        String jsonResponse = EYI_DMS_RecordCreation.createDmsRecords();
        Test.stopTest();

        List<Object> respList = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        Map<String, Object> respMap = (Map<String, Object>) respList[0];

        System.assertEquals('E', respMap.get('Type'));
        System.assert(((String)respMap.get('Message')).contains('DocumentLinks cannot be empty'));
        System.assertEquals('', respMap.get('LockatedDocumentId'));
        System.assertEquals('', respMap.get('SFDC_DocumentId'));
    }

    @isTest
    static void testCreateDmsRecords_DmlExceptionError() {
        // Force a DML exception by using invalid lookup
        EYI_DMS_RecordCreation.DocumentLinkWrapper doc = new EYI_DMS_RecordCreation.DocumentLinkWrapper();
        doc.SFDC_DocumentId    = null;
        doc.LockatedDocumentId = 'LOCK_FAIL';
        doc.url                = 'https://test.com/fail.pdf';
        doc.DocumentName       = 'Brochure';             // valid picklist
        doc.ObjectName         = 'EYI_Project__c';
        doc.ProjectId          = 'InvalidId';
        doc.TowerId            = null;

        EYI_DMS_RecordCreation.RequestWrapper wrapper = new EYI_DMS_RecordCreation.RequestWrapper();
        wrapper.DocumentLinks = new List<EYI_DMS_RecordCreation.DocumentLinkWrapper>{ doc };

        RestContext.request  = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(wrapper));

        Test.startTest();
        String jsonResponse = EYI_DMS_RecordCreation.createDmsRecords();
        Test.stopTest();

        List<Object> respList = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        Map<String, Object> respMap = (Map<String, Object>) respList[0];

        System.assertEquals('E', respMap.get('Type'));
        System.assertEquals('', respMap.get('LockatedDocumentId'), 'Error path clears LockatedDocumentId');
        System.assertEquals('', respMap.get('SFDC_DocumentId'));
        System.assert(((String)respMap.get('Message')).startsWith('Error:'), 'Expect error message prefix');
    }
}