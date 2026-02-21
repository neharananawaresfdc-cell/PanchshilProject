@isTest
global class EYI_ProjectSyncToMobileApp_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndPoint().contains('VerifyPanDetails')){
            res.setStatusCode(200);
            res.setBody('{ "respcode": "S-400", "respdesc": "Invalid Request",  "rrn": ""}');
        }
        else if(req.getEndPoint().contains('.json')){
            //Wrong response sent: Need to check the response.
            res.setBody('{"id": "1234567890"}');
            res.setStatusCode(200);
        }
        else {
            //For getAccessToken http request:
            res.setBody('{"access_token":"cgwRuly-shWB9Dl0LJafIqLTnVEda1Yna77b73dk6C8","token_type":"Bearer","refresh_token":"7WnbLhUYbdtzM2noaatpxqujS2_wtKr63of7fMHPjgQ","created_at":1743493257}');
        }
        res.setHeader('Content-Type','application/json');
    	return res;
    }
}