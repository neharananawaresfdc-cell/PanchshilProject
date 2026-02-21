@isTest
private class GetCaseWrapper_Test {

    @isTest
    static void testCaseRequestInitialization() {
        Account acc = new Account();
        acc.Name ='Test Account';
        insert acc;
        GetCaseWrapper.CaseRequest request = new GetCaseWrapper.CaseRequest();
        request.CaseId = acc.Id;
        request.CaseNumber = '00001001';
        request.OpportunityId = acc.Id;
        request.sap_customer_codes = 'SAP001';

        System.assertEquals('SAP001', request.sap_customer_codes);
    }

    @isTest
    static void testCaseResponseWrapperInitialization() {
        List<GetCaseWrapper.CaseResponse> caseResponses = new List<GetCaseWrapper.CaseResponse>();

        GetCaseWrapper.CaseResponseWrapper responseWrapper =
            new GetCaseWrapper.CaseResponseWrapper(true, 'Success', caseResponses);

        System.assertEquals(true, responseWrapper.status);
        System.assertEquals('Success', responseWrapper.message);
        System.assertEquals(0, responseWrapper.cases.size());
    }

    @isTest
    static void testCaseResponseInitialization() {
        DateTime createdDate = DateTime.now();
		Account acc = new Account();
        acc.Name ='Test Account';
        insert acc;
        GetCaseWrapper.CaseResponse caseResponse = new GetCaseWrapper.CaseResponse(
            acc.Id,
            '00001001',
            'Test Subject',
            'New',
            'Login',
            'Technical',
            'Login issue',
            'Problem',
            'High',
            createdDate
        );

        System.assertEquals('Test Subject', caseResponse.Subject);
        System.assertEquals('New', caseResponse.Status);
        System.assertNotEquals(null, caseResponse.documentLinks);
        System.assertNotEquals(null, caseResponse.comments);
    }

    @isTest
    static void testDocumentDetailInitialization() {
        GetCaseWrapper.DocumentDetail doc = new GetCaseWrapper.DocumentDetail(
            'https://test.com/doc1.pdf',
            'PDF',
            'test'
        );

        System.assertEquals('PDF', doc.typeOfDoc,'test');
    }

    @isTest
    static void testCommentDetailInitialization() {
        Id creatorId = UserInfo.getUserId();
        DateTime createdDate = DateTime.now();

        GetCaseWrapper.CommentDetail comment = new GetCaseWrapper.CommentDetail(
            creatorId,
            createdDate,
            'Customer reported issue via mobile app.',
            'John Doe'
        );

        System.assertEquals('John Doe', comment.CommentedBy);
        System.assertEquals('Customer reported issue via mobile app.', comment.mobileAppComment);
    }
}