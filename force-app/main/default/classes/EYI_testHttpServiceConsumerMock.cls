@isTest
global class EYI_testHttpServiceConsumerMock implements HttpCalloutMock {
    private String responseBody;
    private Integer statusCode;
    private String status;

    // Constructor for just a body (defaults to 200 OK)
    public EYI_testHttpServiceConsumerMock(String body) {
        this.responseBody = body;
        this.statusCode = 200;
        this.status = 'OK';
    }
    
    // Constructor for body, status code, and status message
    public EYI_testHttpServiceConsumerMock(String body, Integer code, String status) {
        this.responseBody = body;
        this.statusCode = code;
        this.status = status;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setStatus(status);
        response.setBody(responseBody);
        return response;
    }
}