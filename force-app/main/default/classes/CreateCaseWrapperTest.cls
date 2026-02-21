@IsTest
public class CreateCaseWrapperTest {

    @IsTest
    static void testCreateCaseWrapper() {
        // Create instance of the main wrapper
        CreateCaseWrapper wrapper = new CreateCaseWrapper();

        // Create and populate CaseWrapper
        CreateCaseWrapper.CaseWrapper caseWrapper = new CreateCaseWrapper.CaseWrapper();
        caseWrapper.sapCustomerCode = 'CUST001';
        caseWrapper.category = 'Hardware';
        caseWrapper.subCategory = 'Laptop';
        caseWrapper.subject = 'Issue with laptop screen';
        caseWrapper.description = 'Screen flickering randomly.';
        caseWrapper.case_number = 'CASE1234';
        caseWrapper.caseType = 'Technical';
        caseWrapper.email = 'user@example.com';

        // Create and set CaseAttachment
       
        List<CreateCaseWrapper.CaseAttachment> caseAttachmentList = new List<CreateCaseWrapper.CaseAttachment>();
        CreateCaseWrapper.CaseAttachment caseAttachment = new CreateCaseWrapper.CaseAttachment();
        caseAttachment.fileName = 'screenshot.png';
        caseAttachment.type = 'image/png';
        caseAttachment.base64Data = 'dGVzdA==';  // sample base64 string
        caseAttachmentList.add(caseAttachment);
        caseWrapper.caseAttachments = caseAttachmentList;

        // Create comments list
        List<CreateCaseWrapper.CaseComment> comments = new List<CreateCaseWrapper.CaseComment>();

        // Create a comment
        CreateCaseWrapper.CaseComment comment = new CreateCaseWrapper.CaseComment();
        comment.commentedBy = 'Support Agent';
        comment.createdDate = '2025-07-12T10:00:00Z';
        comment.comment = 'Looking into this issue.';

        // Add comment attachment
        CreateCaseWrapper.CommentAttachment commentAttachment = new CreateCaseWrapper.CommentAttachment();
        commentAttachment.fileName = 'errorlog.txt';
        commentAttachment.type = 'text/plain';
        commentAttachment.base64Data = 'ZXJyb3IgbG9nIGNvbnRlbnQ='; // sample base64
        comment.commentAttachment = commentAttachment;

        comments.add(comment);
        caseWrapper.Comments = comments;

        // Assign CaseWrapper to main wrapper class
        wrapper.CaseDetails = caseWrapper;

        // Assertions to verify the data
        System.assertEquals('CUST001', wrapper.CaseDetails.sapCustomerCode);
        System.assertEquals('Hardware', wrapper.CaseDetails.category);
        System.assertEquals('Laptop', wrapper.CaseDetails.subCategory);
        System.assertEquals('Issue with laptop screen', wrapper.CaseDetails.subject);
        System.assertEquals('Screen flickering randomly.', wrapper.CaseDetails.description);
        System.assertEquals('CASE1234', wrapper.CaseDetails.case_number);
        System.assertEquals('Technical', wrapper.CaseDetails.caseType);
        System.assertEquals('user@example.com', wrapper.CaseDetails.email);

        

        System.assertEquals(1, wrapper.CaseDetails.Comments.size());
        System.assertEquals('Support Agent', wrapper.CaseDetails.Comments[0].commentedBy);
        System.assertEquals('2025-07-12T10:00:00Z', wrapper.CaseDetails.Comments[0].createdDate);
        System.assertEquals('Looking into this issue.', wrapper.CaseDetails.Comments[0].comment);

        System.assertEquals('errorlog.txt', wrapper.CaseDetails.Comments[0].commentAttachment.fileName);
        System.assertEquals('text/plain', wrapper.CaseDetails.Comments[0].commentAttachment.type);
        System.assertEquals('ZXJyb3IgbG9nIGNvbnRlbnQ=', wrapper.CaseDetails.Comments[0].commentAttachment.base64Data);
    }
}