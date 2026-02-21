@isTest
global class EYI_FCMCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}'); // or whatever your real response looks like
        res.setStatusCode(200);
        return res;
    }
}