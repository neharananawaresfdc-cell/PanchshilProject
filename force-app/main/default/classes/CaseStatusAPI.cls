@RestResource(urlMapping='/caseStatus/*')
global with sharing class CaseStatusAPI {
    
    @HttpGet
    global static CaseWrapper getCaseStatus() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String caseNumber = req.params.get('caseNumber');
        System.debug(' Incoming CaseNumber from API: ' + caseNumber);
        
        if (String.isBlank(caseNumber)) {
            res.statusCode = 400; // Bad Request
            CaseWrapper errorRes = new CaseWrapper();
            errorRes.message = 'caseNumber parameter is required';
            return errorRes;
        }
        
        // Query using list
        List<Case> cases = [
            SELECT Id, CaseNumber, Status, Subject 
            FROM Case 
            WHERE CaseNumber = :caseNumber
            LIMIT 1
        ];
        
        if (cases.isEmpty()) {
            System.debug('️ No Case found for CaseNumber: ' + caseNumber);
            res.statusCode = 404; // Not Found
            CaseWrapper notFoundRes = new CaseWrapper();
            notFoundRes.message = 'No Case found for CaseNumber ' + caseNumber;
            return notFoundRes;
        }
        
        Case c = cases[0];
        System.debug('Case found: Id=' + c.Id + ', Status=' + c.Status);
        
        CaseWrapper cw = new CaseWrapper();
        cw.caseId = c.Id;
        cw.caseNumber = c.CaseNumber;
        cw.status = c.Status;
        cw.subject = c.Subject;
        cw.message = 'Success';
        
        return cw;
    }
    
    global class CaseWrapper {
        public String caseId;
        public String caseNumber;
        public String status;
        public String subject;
        public String message;
    }
}