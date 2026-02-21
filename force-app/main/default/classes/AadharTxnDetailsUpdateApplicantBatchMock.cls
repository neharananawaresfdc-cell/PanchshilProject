@isTest
global class AadharTxnDetailsUpdateApplicantBatchMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"mockKey":"mockValue"}');
        res.setStatusCode(200);
        return res;
    }
}