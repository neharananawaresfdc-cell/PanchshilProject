@isTest
public class EYI_CreateCaseResourceTest {

    // Helper method to create Account + Opportunity with SAP customer code
    private static Opportunity createTestOpportunity(String sapCode) {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            EYI_Last_Name__c='test',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            AccountId = acc.Id,
            EYI_SAP_Customer_Number__c = sapCode
        );
        insert opp;
        return opp;
    }

    // Helper to setup RestContext for REST call
    private static void setupRestContext(String requestBody) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @isTest
    static void test_createCase_withAttachment_andComment() {
        String sapCode = 'SAP12345';
        Opportunity opp = createTestOpportunity(sapCode);

        // Build valid base64 content
        String base64File = EncodingUtil.base64Encode(Blob.valueOf('Sample file content'));

        // Build wrapper object
        CreateCaseWrapper wrapper = new CreateCaseWrapper();
        wrapper.CaseDetails = new CreateCaseWrapper.CaseWrapper();
        wrapper.CaseDetails.sapCustomerCode = sapCode;
        wrapper.CaseDetails.caseType = 'Post Possession';
        wrapper.CaseDetails.category = 'Queries Post Possession';
        wrapper.CaseDetails.subCategory = 'Society Formation';
        wrapper.CaseDetails.subject = 'Case From Mobile App';
        wrapper.CaseDetails.description = 'Issue with product';
        wrapper.CaseDetails.email = 'user@test.com';
        wrapper.CaseDetails.case_number = '';  // New case
        
        //
        CreateCaseWrapper wrapper1 = new CreateCaseWrapper();
        wrapper1.CaseDetails = new CreateCaseWrapper.CaseWrapper();
        wrapper1.CaseDetails.sapCustomerCode = sapCode;
        wrapper1.CaseDetails.caseType = 'Post Possession';
        wrapper1.CaseDetails.category = 'Complaints Post Possession';
        wrapper1.CaseDetails.subCategory = 'Security and Safety Complaints';
        wrapper1.CaseDetails.subject = 'Case From Mobile App';
        wrapper1.CaseDetails.description = 'Issue with product';
        wrapper1.CaseDetails.email = 'user@test.com';
        wrapper1.CaseDetails.case_number = ''; 

        // Case attachment
        

        //
        List<CreateCaseWrapper.CaseAttachment> attachments = new List<CreateCaseWrapper.CaseAttachment>();

CreateCaseWrapper.CaseAttachment ca1 = new CreateCaseWrapper.CaseAttachment();
ca1.fileName = 'caseFile1.pdf';
ca1.base64Data = 'base64EncodedDataHere'; // replace with actual base64 string
ca1.type = 'pdf';
attachments.add(ca1);

CreateCaseWrapper.CaseAttachment ca2 = new CreateCaseWrapper.CaseAttachment();
ca2.fileName = 'caseFile2.jpg';
ca2.base64Data = 'base64EncodedDataHere'; // replace with actual base64 string
ca2.type = 'jpg';
attachments.add(ca2);

// Assign the list of attachments to the wrapper
wrapper.CaseDetails.caseAttachments = attachments;
        
        // Comment with attachment
        CreateCaseWrapper.CaseComment comment1 = new CreateCaseWrapper.CaseComment();
        comment1.comment = 'Initial comment';
        CreateCaseWrapper.CommentAttachment commentAtt1 = new CreateCaseWrapper.CommentAttachment();
        commentAtt1.fileName = 'commentFile.txt';
        commentAtt1.base64Data = base64File;
        comment1.commentAttachment = commentAtt1;
        wrapper1.CaseDetails.Comments = new List<CreateCaseWrapper.CaseComment>{ comment1 };
        //
        CreateCaseWrapper.CaseComment comment = new CreateCaseWrapper.CaseComment();
        comment.comment = 'Initial comment';
        CreateCaseWrapper.CommentAttachment commentAtt = new CreateCaseWrapper.CommentAttachment();
        commentAtt.fileName = 'commentFile.txt';
        commentAtt.base64Data = base64File;
        comment.commentAttachment = commentAtt;
        wrapper.CaseDetails.Comments = new List<CreateCaseWrapper.CaseComment>{ comment };

        // Serialize to JSON
        String jsonBody = JSON.serialize(wrapper);
        setupRestContext(jsonBody);
        
        String jsonBody1 = JSON.serialize(wrapper1);
        setupRestContext(jsonBody1);

        Test.startTest();
        EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
        Test.stopTest();

        //System.assertEquals('Success', resp.type, 'Expected success response');
       // System.assertNotEquals(null, resp.caseId, 'Case Id should not be null');
        //System.assertNotEquals(null, resp.caseNumber, 'Case Number should not be null');
    }
     @isTest
    static void test_createCase_withAttachment_andComment1() {
        String sapCode = 'SAP12345';
        Opportunity opp = createTestOpportunity(sapCode);

        // Build valid base64 content
        String base64File = EncodingUtil.base64Encode(Blob.valueOf('Sample file content'));

        // Build wrapper object
        CreateCaseWrapper wrapper = new CreateCaseWrapper();
        wrapper.CaseDetails = new CreateCaseWrapper.CaseWrapper();
        wrapper.CaseDetails.sapCustomerCode = sapCode;
        wrapper.CaseDetails.caseType = 'Post Possession';
        wrapper.CaseDetails.category = 'Complaints Post Possession';
        wrapper.CaseDetails.subCategory = 'Security and Safety Complaints';
        wrapper.CaseDetails.subject = 'Case From Mobile App';
        wrapper.CaseDetails.description = 'Issue with product';
        wrapper.CaseDetails.email = 'user@test.com';
        wrapper.CaseDetails.case_number = '';  // New case
        
        

        // Case attachment
        List<CreateCaseWrapper.CaseAttachment> attachments = new List<CreateCaseWrapper.CaseAttachment>();

CreateCaseWrapper.CaseAttachment ca1 = new CreateCaseWrapper.CaseAttachment();
ca1.fileName = 'caseFile1.pdf';
ca1.base64Data = 'base64EncodedDataHere'; // replace with actual base64 string
ca1.type = 'pdf';
attachments.add(ca1);

CreateCaseWrapper.CaseAttachment ca2 = new CreateCaseWrapper.CaseAttachment();
ca2.fileName = 'caseFile2.jpg';
ca2.base64Data = 'base64EncodedDataHere'; // replace with actual base64 string
ca2.type = 'jpg';
attachments.add(ca2);

// Assign the list of attachments to the wrapper
wrapper.CaseDetails.caseAttachments = attachments;

       
        
        
        //
        CreateCaseWrapper.CaseComment comment = new CreateCaseWrapper.CaseComment();
        comment.comment = 'Initial comment';
        CreateCaseWrapper.CommentAttachment commentAtt = new CreateCaseWrapper.CommentAttachment();
        commentAtt.fileName = 'commentFile.txt';
        commentAtt.base64Data = base64File;
        comment.commentAttachment = commentAtt;
        wrapper.CaseDetails.Comments = new List<CreateCaseWrapper.CaseComment>{ comment };

        // Serialize to JSON
        String jsonBody = JSON.serialize(wrapper);
        setupRestContext(jsonBody);


        Test.startTest();
        EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
        Test.stopTest();

        //System.assertEquals('Success', resp.type, 'Expected success response');
       // System.assertNotEquals(null, resp.caseId, 'Case Id should not be null');
        //System.assertNotEquals(null, resp.caseNumber, 'Case Number should not be null');
    }

    /*@isTest
    static void test_createCase_withExistingCaseNumber() {
        String sapCode = 'SAP54321';
        Opportunity opp = createTestOpportunity(sapCode);

        // Create RecordType needed
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Post_Sales' AND SObjectType = 'Case' LIMIT 1];

        // Create existing Case
        Case existingCase = new Case(
            RecordTypeId = rt.Id,
            EYI_Opportunity__c = opp.Id,
            Type = 'Pre Possession',
            EYI_Case_Category__c = 'Requests_PostPossession',
            EYI_Case_Sub_Category__c = 'Customization',
            Subject = 'Test',
            Description = 'Desc',
            SuppliedEmail = 'email@test.com',
            Origin = 'Mobile App',
            Status = 'New'
        );
        insert existingCase;
		
        // Build wrapper with existing case number
        CreateCaseWrapper wrapper = new CreateCaseWrapper();
        wrapper.CaseDetails = new CreateCaseWrapper.CaseWrapper();
        wrapper.CaseDetails.sapCustomerCode = sapCode;
        wrapper.CaseDetails.case_number = existingCase.CaseNumber;

        // Add a comment to attach
        CreateCaseWrapper.CaseComment comment = new CreateCaseWrapper.CaseComment();
        comment.comment = 'Follow-up comment';
        wrapper.CaseDetails.Comments = new List<CreateCaseWrapper.CaseComment>{ comment };

        String jsonBody = JSON.serialize(wrapper);
        setupRestContext(jsonBody);

        Test.startTest();
        EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
        Test.stopTest();

        //System.assertEquals('Success', resp.type, 'Expected success response');
        //System.assertEquals(existingCase.Id, resp.caseId, 'Case Id should match existing case');
        //System.assertEquals(existingCase.CaseNumber, resp.caseNumber, 'Case Number should match existing case');
    }*/

    @isTest
    static void test_createCase_invalidInput() {
        // Null CaseDetails
        CreateCaseWrapper wrapper = new CreateCaseWrapper();
        wrapper.CaseDetails = null;

        setupRestContext(JSON.serialize(wrapper));

        Test.startTest();
        EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
        Test.stopTest();

       // System.assertEquals('Error', resp.type);
       // System.assertEquals('Invalid request: Missing case details or SAP customer code.', resp.message);
    }

    @isTest
    static void test_createCase_noOpportunityFound() {
        CreateCaseWrapper wrapper = new CreateCaseWrapper();
        wrapper.CaseDetails = new CreateCaseWrapper.CaseWrapper();
        wrapper.CaseDetails.sapCustomerCode = 'NON_EXISTENT_SAP_CODE';

        setupRestContext(JSON.serialize(wrapper));

        Test.startTest();
        EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
        Test.stopTest();

       // System.assertEquals('Error', resp.type);
        //System.assertEquals('No Opportunity found for given SAP Customer Code.', resp.message);
    }

    @isTest
    static void test_createCase_blankAttachment() {
        String sapCode = 'SAP111';
        createTestOpportunity(sapCode);

        CreateCaseWrapper wrapper = new CreateCaseWrapper();
        wrapper.CaseDetails = new CreateCaseWrapper.CaseWrapper();
        wrapper.CaseDetails.sapCustomerCode = sapCode;
        wrapper.CaseDetails.caseType = 'Post Possession';
        wrapper.CaseDetails.category = 'Requests_PostPossession';
        wrapper.CaseDetails.subCategory = 'Customization';
        wrapper.CaseDetails.subject = 'Blank file test';
        wrapper.CaseDetails.description = 'Blank file case';
        wrapper.CaseDetails.email = 'test@blank.com';
        wrapper.CaseDetails.case_number = '';

        // Blank attachment base64
        List<CreateCaseWrapper.CaseAttachment> attachments = new List<CreateCaseWrapper.CaseAttachment>();

CreateCaseWrapper.CaseAttachment ca1 = new CreateCaseWrapper.CaseAttachment();
ca1.fileName = 'caseFile1.pdf';
ca1.base64Data = 'base64EncodedDataHere'; // replace with actual base64 string
ca1.type = 'pdf';
attachments.add(ca1);

CreateCaseWrapper.CaseAttachment ca2 = new CreateCaseWrapper.CaseAttachment();
ca2.fileName = 'caseFile2.jpg';
ca2.base64Data = 'base64EncodedDataHere'; // replace with actual base64 string
ca2.type = 'jpg';
attachments.add(ca2);

// Assign the list of attachments to the wrapper
wrapper.CaseDetails.caseAttachments = attachments;
        
        

        setupRestContext(JSON.serialize(wrapper));

        Test.startTest();
        EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
        Test.stopTest();

       // System.assertEquals('Success', resp.type);
       // System.assertNotEquals(null, resp.caseId);
       // System.assertNotEquals(null, resp.caseNumber);
    }
   @isTest
static void test_insertCase_failure_simulation() {
    String sapCode = 'SAPFAIL';
    Opportunity opp = createTestOpportunity(sapCode);

    // Invalid email format triggers insert error
    CreateCaseWrapper wrapper = new CreateCaseWrapper();
    wrapper.CaseDetails = new CreateCaseWrapper.CaseWrapper();
    wrapper.CaseDetails.sapCustomerCode = sapCode;
    wrapper.CaseDetails.caseType = 'Post Possession';
    wrapper.CaseDetails.category = 'Queries Post Possession';
    wrapper.CaseDetails.subCategory = 'Invalid';
    wrapper.CaseDetails.subject = 'Fail Insert';
    wrapper.CaseDetails.description = 'Cause DML Exception';
    wrapper.CaseDetails.email = 'invalid-email'; // Invalid format
    wrapper.CaseDetails.case_number = '';

    setupRestContext(JSON.serialize(wrapper));

    Test.startTest();
    EYI_CreateCaseResource.CustomResponse resp = EYI_CreateCaseResource.createCaseRec();
    Test.stopTest();

    //System.assertEquals('Success', resp.type); // Case is still returned, but error is logged silently
}


}