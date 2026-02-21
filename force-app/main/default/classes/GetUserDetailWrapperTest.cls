@isTest
public class GetUserDetailWrapperTest {
    @isTest
    static void testRequestWrapperFields() {
        GetUserDetailWrapper.RequestWrapper req = new GetUserDetailWrapper.RequestWrapper();
        req.email = 'test@example.com';
        req.MobileNumber = '1234567890';
        req.flat_details = 'Flat 101';
        req.booking_details = 'Booking123';
        req.other_applicants = 'Applicant2';
        req.transactional_financials = 'Financials';
        req.transactional_milestones = 'Milestones';
        req.transactional_receipts = 'Receipts';
        System.assertEquals('test@example.com', req.email);
        System.assertEquals('1234567890', req.MobileNumber);
        System.assertEquals('Flat 101', req.flat_details);
        System.assertEquals('Booking123', req.booking_details);
        System.assertEquals('Applicant2', req.other_applicants);
        System.assertEquals('Financials', req.transactional_financials);
        System.assertEquals('Milestones', req.transactional_milestones);
        System.assertEquals('Receipts', req.transactional_receipts);
    }

    @isTest
    static void testCaseResponseConstructor() {
        List<String> docLinks = new List<String>{'link1', 'link2'};
        GetUserDetailWrapper.CaseResponse caseResp = new GetUserDetailWrapper.CaseResponse(
            '5001', 'CASE-001', 'Test Subject', 'Open', 'SubCat', 'Cat', 'Test Desc', 'TypeA', 'High'
        );
        caseResp.documentLink = docLinks;
        System.assertEquals('5001', caseResp.CaseId);
        System.assertEquals('CASE-001', caseResp.CaseNumber);
        System.assertEquals('Test Subject', caseResp.Subject);
        System.assertEquals('Open', caseResp.Status);
        System.assertEquals('Cat', caseResp.Category);
        System.assertEquals('SubCat', caseResp.SubCategory);
        System.assertEquals('Test Desc', caseResp.Description);
        System.assertEquals('TypeA', caseResp.Type);
        System.assertEquals('High', caseResp.Priority);
        System.assertEquals(2, caseResp.documentLink.size());
        System.assertEquals('link1', caseResp.documentLink[0]);
    }

    @isTest
    static void testCaseResponseWrapperConstructor() {
        GetUserDetailWrapper.CaseResponse caseResp = new GetUserDetailWrapper.CaseResponse(
            '5002', 'CASE-002', 'Subject2', 'Closed', 'SubCat2', 'Cat2', 'Desc2', 'TypeB', 'Low'
        );
        List<GetUserDetailWrapper.CaseResponse> cases = new List<GetUserDetailWrapper.CaseResponse>{caseResp};
        GetUserDetailWrapper.CaseResponseWrapper respWrapper = new GetUserDetailWrapper.CaseResponseWrapper(true, 'Success', cases);
        System.assertEquals(true, respWrapper.status);
        System.assertEquals('Success', respWrapper.message);
        System.assertEquals(1, respWrapper.cases.size());
        System.assertEquals('5002', respWrapper.cases[0].CaseId);
    }
}