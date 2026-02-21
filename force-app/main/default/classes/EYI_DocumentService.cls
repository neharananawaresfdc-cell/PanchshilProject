public class EYI_DocumentService {

    public class DocumentPayload {
        public String document_name;
        public String document_type;
        public String document_link;
        public String created_date;

        public DocumentPayload(EYI_DMS__c doc) {
            this.document_name = doc.Name;
            this.document_type = doc.EYI_Document_Name__c;
            this.document_link = doc.EYI_Document_Link__c;
            this.created_date = String.valueOf(doc.CreatedDate.date());
        }
    }

    @future(callout=true)
    public static void sendDocumentToExternalSystem(Id recordId) {
        EYI_DMS__c doc = [SELECT EYI_Document_Name__c,Name,EYI_Document_Link__c, CreatedDate
                          FROM EYI_DMS__c
                          WHERE Id = :recordId
                          LIMIT 1];

        DocumentPayload payload = new DocumentPayload(doc);
        String jsonBody = JSON.serialize(payload);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:External_Doc_Service/api/documents'); //replace actual
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response status: ' + res.getStatus());
            System.debug('Response body: ' + res.getBody());
        } catch (Exception ex) {
            System.debug('Callout failed: ' + ex.getMessage());
        }
    }
}