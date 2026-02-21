public class MockBookingFormSuccess implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        // Send back a fake JSON response your code expects
        res.setBody('{"esignRequest":"' + EncodingUtil.base64Encode(Blob.valueOf('test-pdf')) + '","txnid":"123456","posturl":"https://signurl.com"}');
        return res;
    }
}