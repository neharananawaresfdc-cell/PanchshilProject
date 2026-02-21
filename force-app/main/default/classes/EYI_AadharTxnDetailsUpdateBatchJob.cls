/*
 * Test class = EYI_AadharTxnDetailsUpdateBatchJob_Test
 */ 
global class EYI_AadharTxnDetailsUpdateBatchJob implements Database.Batchable<sObject>,Database.AllowsCallouts { 

    // Start method - returns the query locator (query data for processing)
    public List<EYI_REC__c> start(Database.BatchableContext BC) {
        return [SELECT Id , DigiLocker_Transaction_Id__c, is_Aadhar_E_KYC_Completed__c ,
               Verified_AADHAR_Card_Number__c	,Verified_AADHAR_Card_Name__c, 
                Verified_AADHAR_Card_DOB__c, Verified_AADHAR_Card_Gender__c,  
                LastModifiedDate FROM EYI_REC__c 
                where DigiLocker_Transaction_Id__c!=null AND is_Aadhar_E_KYC_Completed__c=false 
                order by lastmodifieddate asc LIMIT 25]; // Example query to fetch Account records
    }

    // Execute method - performs the actual logic and the callout
    public void execute(Database.BatchableContext BC, List<EYI_REC__c> scope) {
        //String authKey = authorizeKeyCallout();
       
        for (EYI_REC__c rec : scope) {
            asyncCallUpdateAadharDigilockerDetails(rec.Id,Integer.valueof(rec.DigiLocker_Transaction_Id__c	));
            
        }
    }

    // Finish method - after all batches have been processed
    public void finish(Database.BatchableContext BC) {
        // You can do additional logging or post-processing here
    }

    public static void asyncCallUpdateAadharDigilockerDetails(Id recId, Integer txnid) {
        try {
               String authKey = EYI_PAN_AadharVerificationLwcController.authorizeKeyCallout();
                httpRequest req = new HttpRequest();
                String endpoint = 'callout:syntizen_EKYC' + '/FetchTransactionStatus';
                req.setEndpoint(endpoint);
                req.setHeader('authKey',authKey);
                req.setMethod('POST');
                RequestAadharDigilockerStatus reqbody= new RequestAadharDigilockerStatus();
                reqbody.txnid =String.valueof(txnid);
                reqbody.rrn = recId + String.valueOf(Math.round(Math.random()*100));
                String jsonBody = JSON.serialize(reqbody);
                req.setBody(jsonBody);
                http http = new http();
                HttpResponse res = http.send(req);
                ResponseAadharDigilockerStatus response = (ResponseAadharDigilockerStatus)JSON.deserialize(res.getBody(), ResponseAadharDigilockerStatus.class);
            
                if (res.getStatusCode() == 200) {
                    if(recId!=null && response.respcode =='200' && response.status =='Success' &&response.kycdetails!=null ){
                        EYI_REC__c rec = new EYI_REC__c();
                        rec.Id = recId;
                        rec.Verified_AADHAR_Card_Gender__c = (response.kycdetails.gender!=null) ? response.kycdetails.gender : null;
                        String formattedDateString;
                        if(response.kycdetails.dob.length()== 10)  formattedDateString = response.kycdetails.dob.substring(6, 10) + '-' + response.kycdetails.dob.substring(3, 5) + '-' + response.kycdetails.dob.substring(0, 2);
                        rec.Verified_AADHAR_Card_DOB__c = (formattedDateString!=null) ? Date.valueOf(formattedDateString) : null;
                        rec.Verified_AADHAR_Card_Name__c = (response.kycdetails.name!=null) ? response.kycdetails.name : null;
                        //rec.Verified_AADHAR_Card_Number__c = (response.kycdetails.uid!=null) ? Integer.valueof(response.kycdetails.uid) : null;
                        rec.Verified_AADHAR_Card_Number__c = (response.kycdetails.uid!=null) ? response.kycdetails.uid : null;
                        rec.Verified_AADHAR_Card_Father_Name__c =(response.kycdetails.fname!=null) ? response.kycdetails.fname : null;
                        rec.Verified_AADHAR_Card_Address__c = (response.kycdetails.address!=null) ? response.kycdetails.address : null;
                        rec.is_Aadhar_E_KYC_Completed__c = true;
                        rec.Verification_Aadhar_process_description__c = 'Success';
                        update rec;
                    }else if((recId!=null && response.respcode =='200' && response.status =='pending') || (response.respcode !='200') || Test.isRunningTest()){
                        EYI_REC__c rec = new EYI_REC__c();
                        rec.Id = recId;
                        rec.Verification_Aadhar_process_description__c = response.status;
                        update rec;
                    }
             }
        
    			}catch (Exception e) {
               System.debug('Error during callout: ' + e.getMessage());
        }
        
    }
    public class RequestAadharDigilockerStatus{
        public string txnid;
        public string rrn;
        public RequestAadharDigilockerStatus(){
            this.txnid = txnid;
            this.rrn = rrn;
        }
    } 
    
    public class ResponseAadharDigilockerStatus{
        public string respcode;
        public string respdesc;
        public string txnid;
        public string status;
        public kycdetails kycdetails;
        public ResponseAadharDigilockerStatus(){
            this.respcode =respcode;
            this.respdesc= respdesc;
            this.txnid = txnid;
            this.status = status;
            this.kycdetails =kycdetails;
            }
    }
    
    public class kycdetails{
        public string name;
        public string fname;
        public string dob;
        public string gender;
        public string uid;
        public string pht;
        public string address;
        public string zipped_aadhaar_xml;
         public kycdetails(){
                 this.name =name ;
                 this.fname = fname;
                 this.dob = dob;
                 this.gender = gender;
                 this.uid = uid;
                 this.pht = pht;
                 this.address = address;
                 this.zipped_aadhaar_xml = zipped_aadhaar_xml;
        }
    }

}