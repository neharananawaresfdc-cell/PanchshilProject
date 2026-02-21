/**
 * Created by Abhishek on 1/25/19.
 */

public with sharing class EYI_AbstractHttpServiceConsumerMock implements HttpCalloutMock {
	public HttpResponse respond(HttpRequest request) {
		HttpResponse response = new HttpResponse();

		if (request.getEndpoint().contains('endpoint/success')) {
			response.setBody('success response');
			response.setStatusCode(200);
		}

		else if (request.getEndpoint().contains('endpoint/error')) {
			response.setBody('error response');
			response.setStatusCode(400);
		}

		return response;
	}
}