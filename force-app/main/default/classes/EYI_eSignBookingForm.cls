public without sharing class EYI_eSignBookingForm {
    
    private static final String SYNTIZEN_API_URL = 'https://uatapp.syntizen.com/sws/';
    
    public EYI_eSignBookingForm() {}

   @TestVisible private static String esignCoordinates(Id applicantId, Id oppId,Integer totalPages){

        map<Integer, String> coordinatesData = new map<Integer, String>();
        AggregateResult[] results = [SELECT COUNT(Id) totalApp FROM EYI_Applicants__c WHERE Opportunity__c = :oppId];
        List<String> coordinatesList = new List<String>();
        Integer countApp = (Integer)results[0].get('totalApp');

        for (Integer i = 0; i <= 5; i++) {
            coordinatesList.add('');
        }
        for (Integer page = 2; page <= totalPages; page++) {
            if(countApp < 4){
                coordinatesList[0] += page + '-440,100,40,90;';
                coordinatesList[1] += page + '-220,100,40,90;';
                coordinatesList[2] += page + '-90,100,40,90;';    
            }else{
                coordinatesList[0] += page + '-440,170,40,90;';
                coordinatesList[1] += page + '-220,170,40,90;';
                coordinatesList[2] += page + '-90,170,40,90;';
                coordinatesList[3] += page + '-440,100,40,90;';
                coordinatesList[4] += page + '-220,100,40,90;';
                coordinatesList[5] += page + '-90,100,40,90;';
            }
            
        }
        for (Integer i = 0; i <= 5; i++) {
            coordinatesData.put(i, coordinatesList[i]);
        }
        system.debug('coordinates'+coordinatesData);
        // coordinatesData.put(0,  '2-475,200,45,100;3-475,200,45,100;4-475,200,45,100;5-475,200,45,100;6-475,200,45,100;');
        // coordinatesData.put(1,  '5-225,200,45,100;');
        // coordinatesData.put(2,  '2-50,200,45,100;3-50,200,45,100;4-50,200,45,100;5-50,200,45,100;6-50,200,45,100;');
        // coordinatesData.put(3,  '2-475,100,45,100;');
        // coordinatesData.put(4,  '4-225,100,45,100;');
        // coordinatesData.put(5,  '4-50,100,45,100;');

        List<EYI_Applicants__c> appRecList = [SELECT Id, EYI_Applicant_Type__c FROM EYI_Applicants__c WHERE Opportunity__c=:oppId ORDER By CreatedDate ASC];
        Integer index = 1;
        for(EYI_Applicants__c appRec : appRecList){
            if(appRec.Id == applicantId ){
                if(appRec.EYI_Applicant_Type__c == 'Primary Applicant'){
                    return coordinatesData.get(0);
                }
                break;
            }
            index = index + 1;
        }

        return coordinatesData.get(index-1);
    }

    @AuraEnabled
    public static string getContentDistributionURL(string recordId2){
        Id recordId = Id.valueOf(recordId2);
        String oppID;
        if('EYI_Applicants__c' == recordId.getSObjectType().getDescribe().getName()){
            oppID = [SELECT Opportunity__c FROM EYI_Applicants__c WHERE Id =:recordId LIMIT 1 ].Opportunity__c;
        }else{
            oppID = recordId;
        }

        set<Id> conDocIdSet = new Set<Id>();
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppID AND ContentDocument.Title LIKE '%Application Form%']){
            conDocIdSet.add(cdl.ContentDocumentId);
        }
        List<ContentDistribution> cdRecords = new List<ContentDistribution>();
        if(!conDocIdSet.isEmpty()){
            cdRecords = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE Name LIKE '%Application Form%' AND ContentDocumentId IN :conDocIdSet ORDER BY CreatedDate DESC LIMIT 1];
        }

        if(!cdRecords.isEmpty()){
            return cdRecords[0].DistributionPublicUrl;
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static string getDocBase64(string recordId){
        try {
            Id recordIdOppApp = Id.valueOf(recordId);
        String oppID;
        
        if('EYI_Applicants__c' == recordIdOppApp.getSObjectType().getDescribe().getName()){
            oppID = [SELECT Opportunity__c FROM EYI_Applicants__c WHERE Id =:recordIdOppApp LIMIT 1 ].Opportunity__c;
        }else{
            oppID = recordId;
           
        }
        system.debug('oppID'+oppID);
        List<String> contentDocId = fetchContentDocumentIds(oppID);
        system.debug('contentDocId'+contentDocId);
        if (contentDocId.isEmpty()) {
            return null;
        }     
        String base64EncodedFile = getBase64EncodedFile(contentDocId);
        return base64EncodedFile;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static map<string, string> getBookingForm(String recordId2, Integer totalPageCount) {
        map<string, string> result = new map<string, string>();
        try {
            Id recordId = Id.valueof(recordId2);
            String nameAsPerAadhar;
            String coordinate;
            List<EYI_Applicants__c> getAppDetails = [SELECT Id, EYI_Email__c,EYI_Applicant_Type__c, EYI_Booking__c,Opportunity__c, Verified_AADHAR_Card_Name__c FROM EYI_Applicants__c WHERE Id=:recordId LIMIT 1];
            nameAsPerAadhar = getAppDetails[0].Verified_AADHAR_Card_Name__c;
            coordinate= esignCoordinates(recordId, getAppDetails[0].Opportunity__c,totalPageCount);
    
            List<String> contentDocId = fetchContentDocumentIds(getAppDetails[0].Opportunity__c);
            if (contentDocId.isEmpty()) {
                return null;
            }     
            String base64EncodedFile = getBase64EncodedFile(contentDocId);
            String authKey = EYI_PAN_AadharVerificationLwcController.authorizeKeyCallout();
            
            HttpRequest req = createHttpRequest('InitiateRequest', authKey, base64EncodedFile, recordId, nameAsPerAadhar, coordinate);
           system.debug('req'+req);
             HttpResponse res = sendHttpRequest(req);
            if (res.getStatusCode() == 200) {
                ResponseInitiateRequest response = (ResponseInitiateRequest)JSON.deserialize(res.getBody(), ResponseInitiateRequest.class);
                System.debug('Nilesh1:' + response.posturl);
                System.debug('Nilesh2:' + response.esignRequest);
                Blob decodedBlob = EncodingUtil.base64Decode(response.esignRequest);
                String decodedString = decodedBlob.toString();

                EYI_Applicants__c app = new EYI_Applicants__c();
                app.Id = Id.valueof(recordId);
                app.E_Sign_Transaction_Id__c = Integer.valueof(response.txnid);
                UPDATE app;

                result.put('posturl', response.posturl);
                result.put('esignRequest', decodedString);
            } else {
                string error = 'Error initiating request: ' + res.getStatusCode();
                result.put('error', error);
            }
        } catch (Exception e) {
            map<string, string> result2 = new map<string, string>();
            System.debug('Error: ' + e.getMessage());
            string error = 'Error initiating request: ' + e.getMessage();
            result2.put('error', error);
            return result2;
        }
        return result;
    }
    
    public static List<String> fetchContentDocumentIds(String recordId) {
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
        
        List<String> contentDocId = new List<String>();
        for (ContentDocumentLink link : docLinks) {
            contentDocId.add(link.ContentDocumentId);
        }
        
        return contentDocId;
    }

    @TestVisible private static String getBase64EncodedFile(List<String> contentDocId) {
        system.debug('contentDocId2'+contentDocId);
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocId AND Title like '%Application Form%' ORDER BY CreatedDate DESC LIMIT 1
        ];
        system.debug('contentVersions2'+contentVersions);
        if (contentVersions.isEmpty()) {
            throw new CustomException('No Booking Form found');
        }
        
        Blob fileBlob = contentVersions[0].VersionData;
        //Blob fileBlob = Blob.valueOf('/services/data/v48.0/sobjects/ContentVersion/068C4000004Cm3QIAS/VersionData');
        return EncodingUtil.base64Encode(fileBlob);
    }

    @TestVisible 
    private static HttpRequest createHttpRequest(String endpointKey, String authKey, String base64EncodedFile, String recordId, string nameAsPerAadhar, string coordinate) {
        List<APIConfiguration__mdt> apiConfig = [select id,DeveloperName,ApiEndPoint__c,UserName__c,Password__c from APIConfiguration__mdt where DeveloperName='syntizen_Authorization_Key' limit 1];
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiConfig[0].ApiEndPoint__c + endpointKey);
        req.setHeader('authKey', authKey);
        req.setHeader('apikey', '');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        
        //return Integer.valueOf(pageCountNode.getText());
        RequestInitiateRequest reqBody = new RequestInitiateRequest();
        reqBody.rrn = recordId;
        reqBody.coordinates_location = 'C';
        reqBody.coordinates = coordinate;
        reqBody.file = base64EncodedFile;
        reqBody.doctype = 'PDF';
        reqBody.signername = nameAsPerAadhar;
        reqBody.signerlocation = 'India';
        reqBody.signreason = 'Document Esign';
        reqBody.authmode = '1';
        reqBody.webhookurl = '';

        String requestBody = JSON.serialize(reqBody);
        req.setBody(requestBody);

        return req;
    }

    @TestVisible
	private static HttpResponse sendHttpRequest(HttpRequest req) {
        Http http = new Http();
        return http.send(req);
    }

    public class RequestInitiateRequest {
        public String rrn;
        public String coordinates_location;
        public String coordinates;
        public String file;
        public String doctype;
        public String signername;
        public String signerlocation;
        public String signreason;
        public String authmode;
        public String webhookurl;
    }

    public class ResponseInitiateRequest {
        public String respcode;
        public String respdesc;
        public String rrn;
        public String txnid;
        public String esignrequest;
        public String posturl;
        public String status;
    }

    public class CustomException extends Exception {}
}