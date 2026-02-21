@RestResource(urlMapping='/createCase/*')
global with sharing class CaseCaseVerloop {

    @HttpPost
    global static ResponseWrapper createCase() {
        ResponseWrapper res = new ResponseWrapper();
        try {
            // Parse the incoming JSON
            RestRequest req = RestContext.request;
            String reqBody = req.requestBody.toString();
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(reqBody);

            // Create Case record
            Case newCase = new Case();
            newCase.SuppliedName   = (String) data.get('SuppliedName');
            newCase.Origin         = (String) data.get('Origin');
            newCase.Status         = (String) data.get('Status');
            newCase.SuppliedPhone  = (String) data.get('SuppliedPhone');
            newCase.Subject        = (String) data.get('Subject');
            newCase.Description    = (String) data.get('Description');
            newCase.SuppliedEmail  = (String) data.get('SuppliedEmail');

            insert newCase;
			List<Case> CaseList = [Select Id,CaseNumber  from Case Where Id =:newCase.Id];
            // Success response
            res.caseNumber = CaseList[0].CaseNumber;
            res.message = 'Success';
        } catch (Exception e) {
            // Error response
            res.caseNumber = '';
            res.message = 'Error: ' + e.getMessage();
        }
        return res;
    }

    global class ResponseWrapper {
        public String caseNumber;
        public String message;
    }
}