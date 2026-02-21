/*
 * Test Class Name : EYI_PAN_AadharVerificationLwcCtrl_Test 
 */

public without sharing class EYI_PAN_AadharVerificationLwcController {

    @AuraEnabled(cacheable=true)
    public static EYI_Applicants__c getApplicantData(String applicantId){
        
        return [SELECT Id,EYI_Aadhar_Number__c, EYI_Pancard_Number__c, Is_PAN_EKYC_Completed__c, Is_Aadhar_EKYC_Completed__c, DigiLocker_Transaction_Id__c FROM EYI_Applicants__c WHERE Id=:applicantId];
    }

    @AuraEnabled
    public static string verifyPANdetails(String recAccId, String panCardNumber, String name , String dob){
        try{  
            
            if(recAccId != null){
               string idType = 'PAN';

               //Check recordId object added by Nilesh
               Boolean isPANValidated = false;
               Schema.SObjectType sObjectType = Id.valueOf(recAccId).getSObjectType();
               String objectApiName = sObjectType.getDescribe().getName();
               if(objectApiName == 'EYI_Applicants__c'){
                isPANValidated = checkPanAadharEKYCStatus(recAccId);
               }else{
                isPANValidated = checkPANandAadharEKYCCompleted(recAccId,idType);
               }

                if(isPANValidated == true){
                    return 'PAN Card already validated in our System, Thanks!';
                }else{
                    String authKey = authorizeKeyCallout();
                    if(authKey!= null && authKey != ''){
                        //if(recAccId!=null && panCardNumber!=null && name!=null && dob !=null){
                        if(panCardNumber!=null && name!=null && dob !=null){
                            String formattedDate = dob;
                            if(dob.contains('-')){
                                List<String> dobstring = dob.split('-');
                                if(dobstring.size()==3)
                                    formattedDate =dobstring[2] +'/' +dobstring[1]+'/' + dobstring[0];
                                
                                
                            }
                        //recAccId = 'a1PC4000005WlFRMA0';
                           return panverificationCallout(recAccId,authKey,panCardNumber,name ,formattedDate);    
                        }else{
                            return 'Please enter required details';
                        }
                        
                    }
                } 
                
            }
            return '';
        }
        catch(Exception e){
            return e.getMessage();        }
    }
    
    @AuraEnabled
    public static String verifyDigilockerdetails(String recAccId, String aadharCardNumber, String name ,String gender, String dob, String currentUrl){
        try{
            
            digilockerDetails dd = new digilockerDetails();
            if(recAccId!=null || recAccId == null){
                String authKey = authorizeKeyCallout();
                if(authKey!= null && authKey != ''){
                    if(aadharCardNumber!=null && name!=null && dob !=null && gender!=null){
                            String formattedDate = dob;
                            if(dob.contains('-')){
                                List<String> dobstring = dob.split('-');
                                if(dobstring.size()==3)
                                    formattedDate =dobstring[2] +'/' +dobstring[1]+'/' + dobstring[0];
                                
                                
                            }
                            //recAccId = 'a1PC4000005WlFRMA0';
                            return JSON.serialize(aadharDigilockerCallout(recAccId,authKey,aadharCardNumber,name ,gender,formattedDate,currentUrl));    
                        }else{
                            digilockerDetails dd2 = new digilockerDetails();
                            dd2.isSuccess = false;
                            dd2.redirectURL = null;
                            dd2.desRes ='Please enter required details, Please Try agin!';
                            return JSON.serialize(dd2);
                            
                        }
                        
                }
            }else{
                 digilockerDetails dd3 = new digilockerDetails();
                dd3.isSuccess = false;
                dd3.redirectURL = null;
                dd3.desRes ='Record Not found , Please Try agin!';
                return JSON.serialize(dd3);
            }
            return null;
        }
        catch(Exception e){
            system.debug('error-->'+e.getMessage());
            digilockerDetails dd3 = new digilockerDetails();
            dd3.isSuccess = false;
            dd3.redirectURL = null;
            dd3.desRes =e.getMessage();
            return JSON.serialize(dd3);
            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static EYI_REC__c buttonPANandAadhar(String recAccId){
        Map<String,Boolean> statusEKYC = new Map<String,Boolean>();
        if(recAccId!=null){
            List<EYI_REC__c> recAcc = [select id,EYI_PAN_No__c,EYI_Aadhar__c,Name,Owner.name,Sourcing_Manager_Name__c, is_PAN_E_KYC_Completed__c,DigiLocker_Transaction_Id__c,is_Aadhar_E_KYC_Completed__c,EYI_First_Name__c,EYI_Last_Name__c,EYI_REC_Code__c,EYI_Mobile__c,EYI_Email__c from EYI_REC__c where id=:recAccId limit 1 ];
            if(!recAcc.isEmpty()){
                statusEKYC.put('PAN',recAcc[0].is_PAN_E_KYC_Completed__c);
                statusEKYC.put('AADHAR',recAcc[0].is_Aadhar_E_KYC_Completed__c);
                //return statusEKYC;
                return recAcc[0];
            }
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static EYI_Applicants__c buttonPANandAadharforApplicant(String appAccId){
        Map<String,Boolean> statusEKYC = new Map<String,Boolean>();
        if(appAccId!=null){
            List<EYI_Applicants__c> appAcc = [select id,EYI_Pancard_Number__c,EYI_Date_of_Birth__c,EYI_Gender__c,EYI_Aadhar_Number__c,Name,Owner.name, Is_PAN_EKYC_Completed__c,DigiLocker_Transaction_Id__c,Is_Aadhar_EKYC_Completed__c,EYI_First_Name__c,EYI_Last_Name__c,EYI_Company_Name__c,EYI_Mobile_Number__c,EYI_Email__c from EYI_Applicants__c where id=:appAccId limit 1 ];
            if(!appAcc.isEmpty()){
                statusEKYC.put('PAN',appAcc[0].Is_PAN_EKYC_Completed__c);
                statusEKYC.put('AADHAR',appAcc[0].Is_Aadhar_EKYC_Completed__c);
                //return statusEKYC;
                return appAcc[0];
            }
        }
        return null;
    }
        
    public static boolean checkPANandAadharEKYCCompleted(String recAccId,String idType){
        List<EYI_REC__c> recAcc = [select id, is_PAN_E_KYC_Completed__c,is_Aadhar_E_KYC_Completed__c from EYI_REC__c where id=:recAccId limit 1 ];
        if(!recAcc.isEmpty() && idType!=null && idType =='PAN' ) return recAcc[0].is_PAN_E_KYC_Completed__c;
        else if(!recAcc.isEmpty() && idType!=null && idType =='AADHAR') return recAcc[0].is_Aadhar_E_KYC_Completed__c;
        
        return false;
        
    }
    
    //applicant ekyac verification added by Nilesh
    public static boolean checkPanAadharEKYCStatus(String applicantRecId){
        return [SELECT Id, isKYCDone__c FROM EYI_Applicants__c WHERE Id=:applicantRecId LIMIT 1]?.isKYCDone__c;
    }

    public static string authorizeKeyCallout(){
        try{
            List<APIConfiguration__mdt> apiConfig = [select id,DeveloperName,UserName__c,Password__c from APIConfiguration__mdt where DeveloperName='syntizen_Authorization_Key' limit 1];
            if(!apiConfig.isEmpty() && apiConfig[0].UserName__c !=null && apiConfig[0].Password__c !=null){
                httpRequest req = new HttpRequest();
                String endpoint = 'callout:syntizen_EKYC' + '/userauthentication';
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                requestAuthorizeKey reqbody= new requestAuthorizeKey();
                reqbody.username =apiConfig[0].UserName__c;
                String password = apiConfig[0].Password__c;
                Blob binaryData = Blob.valueOf(password);
                String base64StringPassword = EncodingUtil.base64Encode(binaryData);
                reqbody.password = base64StringPassword;
                String jsonBody = JSON.serialize(reqbody);
                req.setBody(jsonBody);
                http http = new http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 200) {
                  ResponseAuthorizeKey response = (ResponseAuthorizeKey)JSON.deserialize(res.getBody(), ResponseAuthorizeKey.class);
                    return response.authkey;
                    } else {
                        // Error handling if the API call fails
                        System.debug('Error response: ' + res.getBody());
                        return null;
                    }
            }
            return null;
        }
        catch(exception e){
            return null;
        }
        
    }
    
    public static String panverificationCallout(String recAccId,String authKey, String panCardNumber, String name , String dob){
        try{
            httpRequest req = new HttpRequest();
                String endpoint = 'callout:syntizen_EKYC' + '/panverification';
                req.setEndpoint(endpoint);
                req.setHeader('authKey',authKey);
                req.setMethod('POST');
                RequestPANVeriifcation reqbody= new RequestPANVeriifcation();
                Blob binaryData = Blob.valueOf(panCardNumber);
                String base64StringPANCardNumber = EncodingUtil.base64Encode(binaryData);
                reqbody.pannumber =base64StringPANCardNumber;
                reqbody.rrn = recAccId + String.valueOf(Math.round(Math.random()*100));
                reqbody.nameoncard = name;
                reqbody.dob = dob;
                String jsonBody = JSON.serialize(reqbody);
                req.setBody(jsonBody);
                http http = new http();
                HttpResponse res = http.send(req);
                ResponsePANVeriifcation response = (ResponsePANVeriifcation)JSON.deserialize(res.getBody(), ResponsePANVeriifcation.class);
                if (res.getStatusCode() == 200) {
                   // ResponsePANVeriifcation response = (ResponsePANVeriifcation)JSON.deserialize(res.getBody(), ResponsePANVeriifcation.class);
                    
                    
                    Schema.SObjectType sObjectType = Id.valueOf(recAccId).getSObjectType();
                    String objectApiName = sObjectType.getDescribe().getName();
                    if(objectApiName == 'EYI_Applicants__c'){
                        EYI_Applicants__c applicantUpdate = new EYI_Applicants__c();
                        applicantUpdate.Id = recAccId;
                        if(response.ispanvalid != null && response.ispanvalid == 'VALID'){
                            applicantUpdate.Is_PAN_EKYC_Completed__c = true;
                            applicantUpdate.Verified_PAN_Number__c = (response.pannumber!=null) ? response.pannumber : null;
                            applicantUpdate.Verified_PAN_Name__c = (response.panname!=null && response.panname == 'Y') ? name : null;
                            applicantUpdate.Verified_PAN_Aadhar_Link_Details__c = (response.panseedingstatus!=null) ? response.panseedingstatus : null;
                            String formattedDateString;
                            if(dob.length()== 10)  formattedDateString = dob.substring(6, 10) + '-' + dob.substring(3, 5) + '-' + dob.substring(0, 2);
                            applicantUpdate.Verified_DOB__c = (response.dob!=null && response.dob == 'Y') ? Date.valueOf(formattedDateString) : null;
                            applicantUpdate.Verification_PAN_process_description__c = (response.respdesc!=null) ? response.respdesc : null;
                        }else{
                            applicantUpdate.Verification_PAN_process_description__c = (response.respdesc!=null) ? response.respdesc : null;
                        }
                        update applicantUpdate;
                    }else{
                        EYI_REC__c recUpd = new EYI_REC__c();
                        recUpd.Id = recAccId;
                        if(response.ispanvalid != null && response.ispanvalid == 'VALID'){
                            recUpd.is_PAN_E_KYC_Completed__c = true;
                            recUpd.Verified_PAN_Number__c = (response.pannumber!=null) ? response.pannumber : null;
                            recUpd.Verified_PAN_Name__c = (response.panname!=null && response.panname == 'Y') ? name : null;
                            recUpd.Verified_PAN_Aadhar_Link_Details__c = (response.panseedingstatus!=null) ? response.panseedingstatus : null;
                            String formattedDateString;
                            if(dob.length()== 10)  formattedDateString = dob.substring(6, 10) + '-' + dob.substring(3, 5) + '-' + dob.substring(0, 2);
                            recUpd.Verified_DOB__c = (response.dob!=null && response.dob == 'Y') ? Date.valueOf(formattedDateString) : null;
                            recUpd.Verification_PAN_process_description__c = (response.respdesc!=null) ? response.respdesc : null;
                        }else{
                            recUpd.Verification_PAN_process_description__c = (response.respdesc!=null) ? response.respdesc : null;
                        }
                        update recUpd;
                    }


                    /*
                  if(response.respcode =='200'){ //uncomment when issue from system solve
                      String dataError;
                       if(response.panname!=null && response.panname !='Y')  dataError = 'PAN Name mismatched with our system';
                       if(response.dob!=null && response.dob!='Y' ) dataError = dataError + ',' + 'Date of Birth is mismatched with our system';
                      if(dataError!=null) return dataError;
                    String accesstokenSFDC = SalesforceApiIntegration.getOAuthToken();
                    HttpRequest reqSFDC = new HttpRequest();
                    RequestPANandAADHARUpdate reqPANUpd = new RequestPANandAADHARUpdate();
                    reqPANUpd.recAccId = recAccId;
                    reqPANUpd.docUpdateType = 'PAN';
                    reqPANUpd.ispanvalid=response.ispanvalid;
                    reqPANUpd.pannumber=response.pannumber;
                    reqPANUpd.panname=(response.panname!=null && response.panname == 'Y') ? name : null;
                    reqPANUpd.panseedingstatus=response.panseedingstatus;
                    reqPANUpd.dob=(response.dob!=null && response.dob == 'Y') ? dob : null;
                    reqPANUpd.respdesc=response.respdesc;
                    String endPointSFDC = URL.getOrgDomainUrl() + '/services/apexrest/updatePAN_AadharRECAccRecord';
                    reqSFDC.setEndpoint(endPointSFDC);
                    reqSFDC.setMethod('POST');
                    
                    // Set the Authorization header with the access token
                    reqSFDC.setHeader('Authorization', 'Bearer ' + accesstokenSFDC);
                    reqSFDC.setHeader('Content-Type', 'application/json');
                    reqSFDC.setBody(JSON.serialize(reqPANUpd));
                    
                    Http httpSFDC = new Http();
                    HttpResponse resSFDC = http.send(reqSFDC);
                    
                        if (resSFDC.getStatusCode() == 200 && resSFDC.getBody() != 'Success') {
                              response.respdesc = resSFDC.getBody(); 
                         }
                  }else{
                      return response.respdesc;
                  }*/
                }else{
                    
                     calloutLOGCapture('PAN Veirification E-KYC',res.getStatusCode(),recAccId,jsonBody,JSON.serialize(response));
                }
             
            return response.respdesc;
           }
            catch(Exception e){
                system.debug('Error-->'+e.getMessage());
                return e.getMessage();
            }
        
    }
    
    public static digilockerDetails aadharDigilockerCallout(String recAccId,String authKey, String aadharCardNumber, String name ,String gender, String dob,String currentUrl){
        try{
            digilockerDetails dd = new digilockerDetails();
            httpRequest req = new HttpRequest();
                String endpoint = 'callout:syntizen_EKYC' + '/createdigilockerrequest';
                req.setEndpoint(endpoint);
                req.setHeader('authKey',authKey);
                req.setMethod('POST');
                RequestAADHARDigiLocker reqbody= new RequestAADHARDigiLocker();
                reqbody.doctype = 'AADHAAR';
                if(currentUrl!=null ) reqbody.redirecturl =currentUrl;
                else reqbody.redirecturl ='https://www.google.com';
                reqbody.rrn = recAccId + String.valueOf(Math.random());
                String jsonBody = JSON.serialize(reqbody);
                req.setBody(jsonBody);
                http http = new http();
                HttpResponse res = http.send(req);
                ResponseAADHARDigiLocker response = (ResponseAADHARDigiLocker)JSON.deserialize(res.getBody(), ResponseAADHARDigiLocker.class);
                if (res.getStatusCode() == 200) {
                   // ResponsePANVeriifcation response = (ResponsePANVeriifcation)JSON.deserialize(res.getBody(), ResponsePANVeriifcation.class);
                    
                    if(response.respcode =='200' ){ 
                        
                    
                    Schema.SObjectType sObjectType = Id.valueOf(recAccId).getSObjectType();
                    String objectApiName = sObjectType.getDescribe().getName();
                    if(objectApiName == 'EYI_Applicants__c'){
                        EYI_Applicants__c applicantUpdate = new EYI_Applicants__c();
                        applicantUpdate.Id = recAccId;
                        if(response.url != null && response.respcode =='200'){
                            applicantUpdate.DigiLocker_Transaction_Id__c = (response.txnid!=null) ? Integer.valueof(response.txnid) : null;
                            applicantUpdate.DigiLocker_URL__c = (response.url!=null) ? response.url : null;
                            applicantUpdate.DigiLocker_Process_Description_Response__c = (response.respdesc!=null) ? response.respdesc : null;
                            dd.isSuccess = true;
                            dd.redirectURL = (response.url!=null) ? response.url : null;
                            dd.desRes = (response.respdesc!=null) ? response.respdesc : null;
                        }else{
                            applicantUpdate.DigiLocker_Process_Description_Response__c = (response.respdesc!=null) ? response.respdesc : null;
                            dd.isSuccess = false;
                            dd.redirectURL = null;
                            dd.desRes = (response.respdesc!=null) ? response.respdesc : null;
                        }
                        update applicantUpdate;
                    }else{
                        EYI_REC__c recUpd = new EYI_REC__c();
                        recUpd.Id = recAccId;
                        if(response.url != null && response.respcode =='200'){
                            recUpd.DigiLocker_Transaction_Id__c = (response.txnid!=null) ? Integer.valueof(response.txnid) : null;
                            recUpd.DigiLocker_URL__c = (response.url!=null) ? response.url : null;
                            recUpd.DigiLocker_Process_Description_Response__c = (response.respdesc!=null) ? response.respdesc : null;
                            dd.isSuccess = true;
                            dd.redirectURL = (response.url!=null) ? response.url : null;
                            dd.desRes = (response.respdesc!=null) ? response.respdesc : null;
                        }else{
                            recUpd.DigiLocker_Process_Description_Response__c = (response.respdesc!=null) ? response.respdesc : null;
                            dd.isSuccess = false;
                            dd.redirectURL = null;
                            dd.desRes = (response.respdesc!=null) ? response.respdesc : null;
                        }
                        update recUpd;
                    }
                    }

                    /*
                    String accesstokenSFDC = SalesforceApiIntegration.getOAuthToken();
                    HttpRequest reqSFDC = new HttpRequest();
                    RequestPANandAADHARUpdate reqAADHARUpd = new RequestPANandAADHARUpdate();
                    reqAADHARUpd.recAccId = recAccId;
                    reqAADHARUpd.docUpdateType = 'AADHAR';
                    reqAADHARUpd.txnid=response.txnid;
                    reqAADHARUpd.url=response.url;
                    reqAADHARUpd.respdesc=response.respdesc;
                    
                    String endPointSFDC = URL.getOrgDomainUrl() + '/services/apexrest/updatePAN_AadharRECAccRecord';
                    reqSFDC.setEndpoint(endPointSFDC);
                    reqSFDC.setMethod('POST');
                    
                    // Set the Authorization header with the access token
                    reqSFDC.setHeader('Authorization', 'Bearer ' + accesstokenSFDC);
                    reqSFDC.setHeader('Content-Type', 'application/json');
                    reqSFDC.setBody(JSON.serialize(reqAADHARUpd));
                    
                    Http httpSFDC = new Http();
                    HttpResponse resSFDC = http.send(reqSFDC);
                        String responseBody = resSFDC.getBody();
                    system.debug(responseBody+'<--responseBody');
                        if (resSFDC.getStatusCode() == 200 && !resSFDC.getBody().Contains('Success')) {
                                dd.isSuccess = false;
                                dd.redirectURL = null;
                                dd.desRes = (response.respdesc!=null) ? response.respdesc : null;
                                
                        }else if(resSFDC.getStatusCode() == 200 && resSFDC.getBody().Contains('Success')){
                            dd.isSuccess = true;
                            dd.redirectURL = (response.url!=null) ? response.url : null;
                            dd.desRes = (response.respdesc!=null) ? response.respdesc : null;
                            
                        }
                      }else{
                          return response.respdesc;
                      }
                        
                  }*/
                }else{
                    
                     calloutLOGCapture('AADHAR DigiLocker',res.getStatusCode(),recAccId,jsonBody,JSON.serialize(response));
                }
            
            return dd;
            
        }
        catch(Exception e){
            system.debug('Error-->'+e.getMessage());
            digilockerDetails dd = new digilockerDetails();
            dd.isSuccess = false;
            dd.redirectURL = null;
            dd.desRes = e.getMessage();
            return dd;
        }
    }

    public static void calloutLOGCapture(String name , Decimal statuscode , string recordId , String req, string resp){
        CalloutLog__c cl = new CalloutLog__c();
                     //cl.Name = name;
                     cl.HttpStatusCode__c = statuscode;
                     cl.Record_Id__c = recordId;
                     cl.RequestBody__c = req;
                     cl.ResponseBody__c = resp;
                     insert cl;
    }
    
   @AuraEnabled
    public static Id uploadDocument(String base64Data, Id recordId, String filename) {
        Id contentDocumentId;
        try {
            // This example assumes fileData is base64 encoded. You can modify this as needed.
            // File upload logic to Salesforce using the ContentVersion object
            //String base64Data = EncodingUtil.base64Decode(fileData);
            Blob fileBlob = EncodingUtil.base64Decode(base64Data);
            string fname ;
            if(filename!=null && filename.contains('.'))  fname = filename.split('\\.')[0];
            else fname ='Document Uploaded';
                
            
            ContentVersion contentVersion = new ContentVersion(
                Title = fname, 
                PathOnClient = 'document.pdf', 
                VersionData = fileBlob, 
                FirstPublishLocationId = recordId,
                ContentLocation = 'S',
                Origin = 'H',
                IsMajorVersion = true
            );
            insert contentVersion;

            Id contentVersionId = contentVersion.Id;
            contentVersion contentVersionRec = [select id, ContentDocumentId from contentversion where id=:contentVersionId LIMIT 1];
            contentDocumentId = contentVersionRec.ContentDocumentId;
            
            System.debug('contentVersionContentDocumentId:' + ContentDocumentId + ':' + contentVersion.Id);
        } catch (Exception e) {
            throw new AuraHandledException('Error during file upload: ' + e.getMessage());
        }
        return contentDocumentId;
    }     

    public class requestAuthorizeKey{
        public string username ;
        public string password;
            
            public requestAuthorizeKey() {
            this.username = username;
            this.password = password;
        }
    }
    
        public class ResponseAuthorizeKey{
            public string respcode;
            public string respdesc;
            public string authkey;
            public string authkeyexpriry;
            public string accbal;
            public string accvalidtill;
            public string role;
            public string username;
            
            public ResponseAuthorizeKey(string respcode,string respdesc,string authkey,string authkeyexpriry,string accbal,string accvalidtill,string role,string username){
                this.respcode = respcode;
                this.respdesc = respdesc;
                this.authkey = authkey;
                this.authkeyexpriry = authkeyexpriry;
                this.accbal = accbal;
                this.accvalidtill = accvalidtill;
                this.role =role;
                this.username = username;
            }
        }
        
        public class RequestPANVeriifcation{
            public string pannumber;
            public string rrn;
            public string nameoncard;
            public string father_name;
            public String dob;
               public RequestPANVeriifcation(){
                    this.pannumber =pannumber;
                    this.rrn =rrn;
                    this.nameoncard =nameoncard;
                    this.father_name =father_name;
                    this.dob = dob;
            }
        }
        
        public class ResponsePANVeriifcation{
            public string respcode;
            public string respdesc;
            public string rrn;
            public string ispanvalid;
            public string pannumber;
            public string panname;
            public string fathername;
            public string dob;
            public string panseedingstatus;
               public ResponsePANVeriifcation(){
                    this.respcode =respcode ;
                    this.respdesc=respdesc ;
                    this.rrn=rrn;
                    this.ispanvalid=ispanvalid;
                    this.pannumber=pannumber;
                    this.panname=panname;
                    this.fathername=fathername;
                    this.dob=dob;
                    this.panseedingstatus=panseedingstatus;
                    }
        }
        
        public class RequestAADHARDigiLocker{
            public string doctype;
            public string redirecturl;
            public string rrn;
               public RequestAADHARDigiLocker(){
                    this.doctype =doctype;
                    this.redirecturl =redirecturl;
                    this.rrn =rrn;
    
            }
        }
        
        public class ResponseAADHARDigiLocker{
            public string respcode;
            public string respdesc;
            public string rrn;
            public string url;
            public string txnid;
               public ResponseAADHARDigiLocker(){
                    this.respcode =respcode ;
                    this.respdesc=respdesc ;
                    this.rrn=rrn;
                    this.url=url;
                    this.txnid=txnid;
                    
                    }
        }
        
    public class digilockerDetails{
        public Boolean isSuccess;
        Public string redirectURL;
        Public string desRes;
        public digilockerDetails(){
            this.isSuccess = isSuccess;
            this.redirectURL = redirectURL;
            this.desRes = desRes;
            
        }
    }
    
    public class RequestPANandAADHARUpdate{
        public string recAccId;
        public string docUpdateType;
        public string ispanvalid;
        public string pannumber;
        public string panname;
        public string panseedingstatus;
        public string dob;
        public string respdesc;
        public string txnid;
        public string url;
        
           public RequestPANandAADHARUpdate(){
               this.recAccId = recAccId;
               this.DocUpdateType = docUpdateType;
               this.ispanvalid=ispanvalid;
               this.pannumber=pannumber;
               this.panname=panname;
               this.panseedingstatus=panseedingstatus;
               this.dob=dob;
               this.respdesc=respdesc ;
               this.txnid =txnid;
               this.url = url;
              }
    }
    
}