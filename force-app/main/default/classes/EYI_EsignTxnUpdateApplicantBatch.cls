global class EYI_EsignTxnUpdateApplicantBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    public List<EYI_Applicants__c> start(Database.BatchableContext BC) {
        return [SELECT Id, E_Sign_Transaction_Id__c, E_Sign_Done__c, Opportunity__c FROM EYI_Applicants__c 
                where E_Sign_Transaction_Id__c != null AND E_Sign_Done__c = false ORDER BY createddate DESC LIMIT 1];
    }

    public void execute(Database.BatchableContext BC, List<EYI_Applicants__c> scope) {
        for (EYI_Applicants__c rec : scope) {
            asyncCallUpdateESignDetails(rec.Id, String.valueof(rec.E_Sign_Transaction_Id__c), rec.Opportunity__c);      
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('finish');
        //Post processing logic
    }
    

    public static void asyncCallUpdateESignDetails(Id applicantId, String txnid, Id oppId){
        try {
            String authKey = EYI_PAN_AadharVerificationLwcController.authorizeKeyCallout();
            httpRequest req = new HttpRequest();
            String endpoint = 'callout:syntizen_EKYC' + '/FetchTransactionStatus';
            req.setEndpoint(endpoint);
            req.setHeader('authKey',authKey);
            req.setMethod('POST');
            RequestEsignStatus reqbody= new RequestEsignStatus();
            reqbody.txnid =String.valueof(txnid);
            reqbody.rrn = String.valueof(applicantId);
            String jsonBody = JSON.serialize(reqbody);
            req.setBody(jsonBody);
            http http = new http();
            HttpResponse res = http.send(req);
            ResponseEsignStatus response = (ResponseEsignStatus)JSON.deserialize(res.getBody(), ResponseEsignStatus.class);
            System.debug(JSON.serializePretty(response));
            if (res.getStatusCode() == 200) {
                Blob fileBlob = EncodingUtil.base64Decode(response.signedfile);
                //contentVersion cv = [select id,ContentDocumentId, FirstPublishLocationId from contentversion where FirstPublishLocationId =:oppId AND  title like '%Application Form%' LIMIT 1];
                ContentDocumentLink cdl = [select Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title from ContentDocumentLink where LinkedEntityId =:OppId and contentDocument.Title LIKE '%Application Form%' LIMIT 1];
                Id contentDocumentID = cdl.ContentDocumentId;
                contentVersion cv = [select id,ContentDocumentId from contentversion where contentDocumentId=:contentDocumentID LIMIT 1];
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'Application Form.pdf';
                contentVersion.PathOnClient = 'Application Form.pdf';
                contentVersion.VersionData = fileBlob;
                contentVersion.ContentDocumentId = cv.ContentDocumentId;
                //contentVersion.FirstPublishLocationId = Id.valueof(response.rrn);
                insert contentVersion;

                EYI_Applicants__c rec = new EYI_Applicants__c();
                rec.Id = applicantId;
                rec.E_Sign_Done__c = true;
                update rec;
            }else{
                EYI_Applicants__c rec = new EYI_Applicants__c();
                rec.Id = applicantId;
                rec.Esign_Response__c = String.valueof(response);
                rec.EYI_Signed_File__c = response.signedfile;
                update rec;
            }
        
        }
        catch(Exception e){
            System.debug('Error during callout: ' + e.getMessage());
            EYI_Applicants__c rec = new EYI_Applicants__c();
            rec.Id = applicantId;
            rec.Esign_Response__c = 'Exception Occured: ' + e.getMessage();
            update rec;
        }
    }

    public class RequestEsignStatus{
        public string txnid;
        public string rrn;
        public RequestEsignStatus(){
            this.txnid = txnid;
            this.rrn = rrn;
        }
    }

    public class ResponseEsignStatus{
        public string respcode;
        public string respdesc;
        public string rrn;
        public string txnid;
        public string signedfile;
        public string filepassword;
        public string status;
        public ResponseEsignStatus(){
            this.respcode =respcode;
            this.respdesc= respdesc;
            this.rrn = rrn;
            this.txnid = txnid;
            this.signedfile = signedfile;
            this.filepassword = filepassword;
            this.status = status;
            }
    }
}