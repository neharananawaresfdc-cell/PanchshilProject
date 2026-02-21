/*
 * Test class : EYI_PAN_AadharVerificationUpdate_Test
 */ 

@RestResource(urlMapping='/updatePAN_AadharRECAccRecord')
global class EYI_PAN_AadharVerificationUpdate {
    
    @HttpPost
    global static String updatePAN_AadharRECrecord(){
        System.debug('jsonData --> ');
        RestRequest req = Restcontext.request;
        system.debug('req'+req.requestBody.toString());
       Map<String, Object> reqMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString()); 
        system.debug('s1'+reqMap.containsKey('recAccId'));
        system.debug('s1'+reqMap.containsKey('panname'));
        String recAccId = reqMap.containsKey('recAccId') ? (String)reqMap.get('recAccId') : null;
        String ispanvalid = reqMap.containsKey('ispanvalid') ? (String)reqMap.get('ispanvalid') : null;
        String pannumber = reqMap.containsKey('pannumber') ? (String)reqMap.get('pannumber') : null;
        String panname = reqMap.containsKey('panname') ? (String)reqMap.get('panname') : null;
        String panseedingstatus = reqMap.containsKey('panseedingstatus') ? (String)reqMap.get('panseedingstatus') : null;
        String dob = reqMap.containsKey('dob') ? (String)reqMap.get('dob') : null;
        String respdesc = reqMap.containsKey('respdesc') ? (String)reqMap.get('respdesc') : null;
        String docUpdateType = reqMap.containsKey('docUpdateType') ? (String)reqMap.get('docUpdateType') : null;
        String txnid = reqMap.containsKey('txnid') ? (String)reqMap.get('txnid') : null;
        string url = reqMap.containsKey('url') ? (String)reqMap.get('url') : null;
            
           Boolean updateRECAcc = false;
           if(recAccId !=null) updateRECAcc = true;
            EYI_REC__c recUpd = new EYI_REC__c();
            recUpd.Id = recAccId;
        if(docUpdateType!=null && docUpdateType =='PAN'){
            
            if (ispanvalid != null && ispanvalid == 'VALID') {
                recUpd.is_PAN_E_KYC_Completed__c = true;
                recUpd.Verified_PAN_Number__c = (pannumber != null) ? pannumber : null;
                recUpd.Verified_PAN_Name__c = (panname != null) ? panname : null;
                recUpd.Verified_PAN_Aadhar_Link_Details__c = (panseedingstatus != null) ? panseedingstatus : null;
                
                if (dob != null && dob.length() == 10) {
                    String formattedDateString = dob.substring(6, 10) + '-' + dob.substring(3, 5) + '-' + dob.substring(0, 2);
                    recUpd.Verified_DOB__c = Date.valueOf(formattedDateString);
                }
                
                recUpd.Verification_PAN_process_description__c = (respdesc != null) ? respdesc : null;
            } else if (ispanvalid != null && pannumber != null) {
                recUpd.Verification_PAN_process_description__c = (respdesc != null) ? respdesc : null;
            }
            
            // Update record in Salesforce
            try{
                if(updateRECAcc == true) { update recUpd; return 'Success'; }
                else return 'No Data Found';
                
                
            }catch (Exception e) {
                System.debug('Error --> ' + e.getMessage());
                return e.getMessage();
            }
        }else if(docUpdateType!=null && docUpdateType =='AADHAR'){
            if(url != null ){
                recUpd.DigiLocker_Transaction_Id__c = (txnid!=null) ? Integer.valueof(txnid) : null;
                recUpd.DigiLocker_URL__c = (url!=null) ? url : null;
                recUpd.DigiLocker_Process_Description_Response__c = (respdesc!=null) ? respdesc : null;
                
            }else{
                recUpd.DigiLocker_Process_Description_Response__c = (respdesc!=null) ? respdesc : null;
                
            }
            try{
                if(updateRECAcc == true) { update recUpd; return 'Success'; }
                else return 'No Data Found';
                
                
            }catch (Exception e) {
                System.debug('Error --> ' + e.getMessage());
                return e.getMessage();
            }
            
        }
        return 'No action define';
    }
}