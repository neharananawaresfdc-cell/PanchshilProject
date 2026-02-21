@RestResource(urlMapping='/documentLinkToRecords')
global with sharing class EYI_DMS_RecordCreation {

    @HttpPost
    global static String createDmsRecords() {
        RestResponse res = RestContext.response;
        // these hold the DMS records to insert / update
        List<EYI_DMS__c> toInsert = new List<EYI_DMS__c>();
        List<EYI_DMS__c> toUpdate = new List<EYI_DMS__c>();
        
        // parallel lists to keep your wrapper in lock‐step with the DMS sObject
        List<DocumentLinkWrapper> insertWrappers = new List<DocumentLinkWrapper>();
        List<DocumentLinkWrapper> updateWrappers = new List<DocumentLinkWrapper>();
        
        try {
            String body = RestContext.request.requestBody.toString();
            if (String.isBlank(body)) {
                throw new CustomException('Request body cannot be empty');
            }
            RequestWrapper reqWrap = (RequestWrapper) JSON.deserialize(body, RequestWrapper.class);
            if (reqWrap.DocumentLinks == null || reqWrap.DocumentLinks.isEmpty()) {
                throw new CustomException('DocumentLinks cannot be empty');
            }

            // build your DMS records and also remember which wrapper goes with each
            for (DocumentLinkWrapper w : reqWrap.DocumentLinks) {
                EYI_DMS__c d = new EYI_DMS__c();
                d.EYI_Lockated_Document_Id__c = w.LockatedDocumentId;
                d.EYI_Document_Link__c        = w.url;
                d.EYI_Document_Name__c        = w.DocumentName;
                d.EYI_SFDC_Object_Name__c     = w.ObjectName;
                d.EYI_Project__c              = (w.ObjectName == 'EYI_Project__c') ? w.ProjectId : null;
                d.EYI_Tower__c                = (w.ObjectName == 'EYI_Tower__c')   ? w.TowerId   : null;

                if (String.isNotBlank(w.SFDC_DocumentId)) {
                    d.Id = w.SFDC_DocumentId;
                    toUpdate.add(d);
                    updateWrappers.add(w);
                } else {
                    toInsert.add(d);
                    insertWrappers.add(w);
                }
            }

            // do the DML
            if (!toInsert.isEmpty()) insert toInsert;
            if (!toUpdate.isEmpty()) update toUpdate;

            // now build your response in the exact same order
            List<Map<String,String>> resp = new List<Map<String,String>>();
            
            // first the inserted ones:
            for (Integer i = 0; i < toInsert.size(); i++) {
                EYI_DMS__c d = toInsert[i];
                DocumentLinkWrapper w = insertWrappers[i];
                resp.add(new Map<String,String>{
                    'Message'            => 'DMS record processed successfully',
                    'Type'               => 'S',
                    'LockatedDocumentId' => w.LockatedDocumentId,
                    'SFDC_DocumentId'    => d.Id
                });
            }
            // then the updated ones:
            for (Integer i = 0; i < toUpdate.size(); i++) {
                EYI_DMS__c d = toUpdate[i];
                DocumentLinkWrapper w = updateWrappers[i];
                resp.add(new Map<String,String>{
                    'Message'            => 'DMS record processed successfully',
                    'Type'               => 'S',
                    'LockatedDocumentId' => w.LockatedDocumentId,
                    'SFDC_DocumentId'    => d.Id
                });
            }

            if (res != null) res.statusCode = 201;
            return JSON.serialize(resp);

        } catch (Exception e) {
            if (res != null) res.statusCode = 500;
            return JSON.serialize(new List<Map<String,String>>{
                new Map<String,String>{
                    'Message'            => 'Error: ' + e.getMessage(),
                    'Type'               => 'E',
                    'LockatedDocumentId' => '',
                    'SFDC_DocumentId'    => ''
                }
            });
        }
    }

    public class RequestWrapper {
        public List<DocumentLinkWrapper> DocumentLinks;
    }

    public class DocumentLinkWrapper {
        public String SFDC_DocumentId;
        public String LockatedDocumentId;
        public String url;
        public String DocumentName;
        public String ObjectName;
        public String ProjectId;
        public String TowerId;
    }

    public class CustomException extends Exception {}
}