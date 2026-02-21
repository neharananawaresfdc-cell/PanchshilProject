public with sharing class EYI_LeadConvertionClass {
    public EYI_LeadConvertionClass() {

    }
    @AuraEnabled
    public static void updateLeadOnCIF(String cifId, String recId, String leadEnquiryId,String opptId) {
        EYI_Customer_Information_Form__c cifRecord = new EYI_Customer_Information_Form__c();
        System.debug(
            'cifId==> ' +
            cifId +
            ' recId==> ' +
            recId +
            ' leadEnquiryId==> ' +
            leadEnquiryId
            + 
            ' opptId==> ' +
            opptId  );

        try {
            cifRecord.Id = cifId;
            cifRecord.EYI_REC_Account__c = recId;
            cifRecord.EYI_Lead_Enquiry__c = leadEnquiryId;
            cifRecord.EYI_Opportunity__c = opptId;
            System.debug('before cif update ===>'+cifRecord);
            update cifRecord;
            // if(recId != null && recId!= ''){
            //     updateRECOnLeadEnquiry(recId,leadEnquiryId);
            // }
            System.debug('after cif update ===>'+cifRecord);
        } catch (Exception e) {
            System.debug('Error updating Lead on Opportunity: ' + e.getMessage());
            System.debug(' cif update failed ===>'+cifRecord);

            throw new AuraHandledException('exceptionText' + e.getMessage() + ' : ' + e.getLineNumber() + ' :');
        }
    }

    
    // @AuraEnabled
    // public static void updateRECOnLeadEnquiry(String recId,String leadEnquiryId){
    //     EYI_Lead_Enquiry__c leadEnq = new EYI_Lead_Enquiry__c();
    //     try {
    //         leadEnq.Id = leadEnquiryId;
    //         leadEnq.EYI_REC_Account__c = recId;
    //         leadenq.EYI_AutomationBypassDatetime__c = System.now();
    //         leadenq.EYI_Lead_Status__c = 'Visit Done';
    //         update leadEnq;
    //     } catch (Exception e) {
    //         System.debug('Error updating Lead on Opportunity: ' + e.getMessage());
    //     }
    // }
    @AuraEnabled
    public static void updatesOnLeadEnquiry(String oppId,String leadEnquiryId,String recId){
        System.debug('leadEnquiryId==>'+leadEnquiryId);
        System.debug('oppId==>'+oppId);
        System.debug('recId==>'+recId);

        EYI_Lead_Enquiry__c leadEnq = new EYI_Lead_Enquiry__c();
        try {
            leadEnq.Id = leadEnquiryId;
            leadEnq.EYI_Opportunity__c = oppId;
            leadEnq.EYI_REC_Account__c = recId;
            leadenq.EYI_Lead_Status__c = 'Visit Done';
            leadenq.EYI_AutomationBypassDatetime__c = System.now();
            update leadEnq;
        } catch (Exception e) {
            Opportunity opp = new Opportunity();
            opp.Id=oppId;
            opp.Error_Message_LWC__c=e.getMessage() + 'LeadEnqId- '+ leadEnquiryId;
            update opp;
            System.debug('Error updating Lead on Opportunity: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String convertLeadEnquiryToOpp(String CIFId){
        system.debug('check convertleadEnquiry');
        List<EYI_Lead_Conversion_Metadata__mdt> customMetadataRecords = getAllCustomMetadata('Lead_Conversion', 'EYI_Lead_Conversion_Metadata__mdt');
        List<String> valuesList = new List<String>();
        Map<String,String> valuesMap = new Map<String,String>();
        List<String> allFieldCIF = new List<String>();
        List<String> phoneNumber = new List<String>();
        List<String> emailIds = new List<String>();
        for (EYI_Lead_Conversion_Metadata__mdt record : customMetadataRecords) {
            String commaSeparatedValue = record.EYI_LeadEnquiryVsOppField__c; // Replace with your actual field name
            valuesList = commaSeparatedValue.split(',');
        }    
        for (String value : valuesList) {
            List<String> keyValue = value.split(':');
            if (keyValue.size() == 2) {
                allFieldCIF.add(keyValue[0].trim());
                valuesMap.put(keyValue[0].trim(), keyValue[1].trim());
            }
        }
        system.debug('valuesMap'+valuesMap);
        List<EYI_Customer_Information_Form__c> cifRecord =getCIFData(CIFId,allFieldCIF);
        for (EYI_Customer_Information_Form__c cif : cifRecord) {
            if(cif.EYI_Mobile_number__c != null && cif.EYI_Mobile_number__c != ''){
                phoneNumber.add(cif.EYI_Mobile_number__c);
            }
            if(cif.EYI_Email_Id__c != null && cif.EYI_Email_Id__c != ''){
                emailIds.add(cif.EYI_Email_Id__c);
            }
            
           
        }
        List<EYI_Project__c> getOppTAT = [Select Id, EYI_Opportunity_TAT__c from EYI_Project__c where Id =: cifRecord[0].EYI_Project_Enquired__c];
        List<Account> getAccounts = [Select Id,Phone,EYI_Email__c from Account where Phone IN:phoneNumber OR EYI_Email__c IN:emailIds];
        List<Opportunity> oppRecordsInsert = new List<Opportunity>();
        Account newAccount = new Account();
        if(getAccounts.isEmpty()){
            
            newAccount.Phone = cifRecord[0].EYI_Mobile_number__c;
            newAccount.EYI_Email__c = cifRecord[0].EYI_Email_Id__c;
            newAccount.Name = cifRecord[0].EYI_First_Name__c + ' ' + cifRecord[0].EYI_Last_name__c;
            insert newAccount;
            
        }else{
            newAccount = getAccounts[0];
        }
        Integer closeDate = Integer.valueOf(Label.EYI_Opportunity_Close_Date);
        String currentProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        for (EYI_Customer_Information_Form__c cif : cifRecord) {
            Opportunity opp = new Opportunity();
            for (String cifField : valuesMap.keySet()) {
                String oppField = valuesMap.get(cifField);
                opp.put(oppField, cif.get(cifField));
                opp.StageName = 'Walk-in';
                //opp.OwnerId = cif.EYI_Closing_Manager__c;
                
                if (currentProfileName == 'Leasing') {
                    opp.OwnerId = UserInfo.getUserId();
                } else {
                	opp.OwnerId = cif.EYI_Closing_Manager__c;
                }

                opp.EYI_AutomationBypassDatetime__c =  System.now();
                opp.EYI_Converted_Lead_Enquiry__c = cif.EYI_Lead_Enquiry__c;
                opp.AccountId = newAccount.Id;
                opp.EYI_CIF_Record__c = cif.Id;
                opp.EYI_Alternate_Email__c = cif.EYI_Email_Id__c;
                opp.Name = cif.EYI_First_Name__c + ' ' + cif.EYI_Last_name__c;
                opp.EYI_First_Name__c = cif.EYI_First_Name__c;
                opp.EYI_Last_Name__c = cif.EYI_Last_name__c;
                opp.EYI_Property__c = cif.EYI_Property__c;
                opp.CloseDate = System.today().addDays((Integer)getOppTAT[0].EYI_Opportunity_TAT__c);
                
            }   
            System.debug('69 EYI_Converted_Lead_Enquiry__c===> '+ cif);
            System.debug('69 EYI_Converted_Lead_Enquiry__c===> '+ opp);

            // Set Opportunity fields based on CIF and other logic
            // opp.Name = cif.Name; // Example field mapping
            // opp.CloseDate = Date.today().addMonths(1); // Example field
            // opp.StageName = 'Prospecting'; // Example field
            oppRecordsInsert.add(opp);
            
        }
        if(!oppRecordsInsert.isEmpty()){
            insert oppRecordsInsert;
        }
        //List<EYI_Lead_Enquiry__c> updateLeadEnquiryOPPId = new List<EYI_Lead_Enquiry__c>();
        // for (EYI_Customer_Information_Form__c cif : cifRecord) {
        //     System.debug('81 EYI_Customer_Information_Form__c===> '+ cif);

        //     cif.EYI_Opportunity__c = oppRecordsInsert[0].Id;
        //     // EYI_Lead_Enquiry__c leadEnqIdMap = new EYI_Lead_Enquiry__c();
        //     // leadEnqIdMap.Id = cif.EYI_Lead_Enquiry__c;
        //     // leadEnqIdMap.EYI_Opportunity__c = oppRecordsInsert[0].Id;
        //     // leadEnqIdMap.EYI_Lead_Status__c = 'Visit Done';
        //     // updateLeadEnquiryOPPId.add(leadEnqIdMap);
        // } 
        // update cifRecord;
        //update updateLeadEnquiryOPPId;
        System.debug('oppRecordsInsert'+oppRecordsInsert[0].Id);
        System.debug('customMetadataRecords'+customMetadataRecords);
        return oppRecordsInsert[0].Id;
    }
    public static List<EYI_Customer_Information_Form__c> getCIFData(String cifIDs,List<String> fieldsToretrive){
        List<EYI_Customer_Information_Form__c> cifRecords= new List<EYI_Customer_Information_Form__c>();
        String query = 'SELECT Id, EYI_Lead_Enquiry__c , EYI_Email_Id__c,EYI_First_Name__c, EYI_Property__c,EYI_Last_name__c, ';
        query += String.join(fieldsToretrive, ', ');
        query += ' FROM EYI_Customer_Information_Form__c WHERE Id = ' + '\''+cifIDs+'\'';        
        system.debug('query'+query);
        try {
            // Perform the query and cast the results to a list of Lead
            cifRecords = (List<SObject>)Database.query(query);
            
        } catch (QueryException e) {System.debug('Error executing query: ' + e.getMessage());
        }
        return cifRecords;
    }
    public static List<SObject> getAllCustomMetadata(String recordApiName, string objectName) {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        String query = 'SELECT ';
        for (String fieldName : fieldMap.keySet()) {
            query += fieldName + ', ';
        }
        
        query = query.removeEnd(', ') + ' FROM ' + objectName + ' WHERE DeveloperName = :recordApiName';
        return Database.query(query);
    }
    // public static void convertLeadEnquiryToOpp(Map<String,String> LeadAndCIFIDs){
       
    //     //List<EYI_Lead_Enquiry__c> leadEnquiries = [SELECT Id,  FROM Lead_Enquiry__c WHERE Id IN :LeadEnquiryId];
    //    // List<CIF__c> cifs = [SELECT Id, CIF_Field1__c, CIF_Field2__c FROM CIF__c WHERE Id IN :CIFId];
    //     // List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
    //     List<EYI_Lead_Conversion_Metadata__mdt> customMetadataRecords = getAllCustomMetadata('Lead_Conversion', 'EYI_Lead_Conversion_Metadata__mdt');
    //     List<String> valuesList = new List<String>();
    //     Map<String,String> valuesMap = new Map<String,String>();
    //     List<String> allFieldCIF = new List<String>();
    //     List<String> phoneNumber = new List<String>();
    //     List<String> emailIds = new List<String>();
    //     List<EYI_Customer_Information_Form__c> cifRecord =getCIFData(LeadAndCIFIDs.values(),allFieldCIF);
    //     for (EYI_Customer_Information_Form__c cif : cifRecord) {
    //         phoneNumber.add(cif.EYI_Mobile_number__c);
    //         emailIds.add(cif.EYI_Email_Id__c);
    //     }
    //     List<Account> getAccounts = [Select Id from Account where Phone IN:phoneNumber OR EYI_Email__c IN:emailIds];
    //     List<Opportunity> oppRecordsInsert = new List<Opportunity>();
    //     for (EYI_Customer_Information_Form__c cif : cifRecord) {
    //         Opportunity opp = new Opportunity();
    //         for (String cifField : valuesMap.keySet()) {
    //             String oppField = valuesMap.get(cifField);
    //             opp.put(oppField, cif.get(cifField));
    //         }   
    //         // Set Opportunity fields based on CIF and other logic
    //         // opp.Name = cif.Name; // Example field mapping
    //         // opp.CloseDate = Date.today().addMonths(1); // Example field
    //         // opp.StageName = 'Prospecting'; // Example field
    //         oppRecordsInsert.add(opp);
    //     }
    //     if(!oppRecordsInsert.isEmpty()){
    //         insert oppRecordsInsert;
    //     }
    //     System.debug('oppRecordsInsert'+oppRecordsInsert);
    //     System.debug('customMetadataRecords'+customMetadataRecords);
    //     for (EYI_Lead_Conversion_Metadata__mdt record : customMetadataRecords) {
    //         String commaSeparatedValue = record.EYI_LeadEnquiryVsOppField__c; // Replace with your actual field name
    //         valuesList = commaSeparatedValue.split(',');
    //     }    
    //     for (String value : valuesList) {
    //         List<String> keyValue = value.split(':');
    //         if (keyValue.size() == 2) {
    //             allFieldCIF.add(keyValue[0].trim());
    //             valuesMap.put(keyValue[0].trim(), keyValue[1].trim());
    //         }
    //     }
    //     system.debug('valuesMap'+valuesMap);
        
    // }
    // public static List<EYI_Customer_Information_Form__c> getCIFData(List<ID> cifIDs,List<String> fieldsToretrive){
    //     List<EYI_Customer_Information_Form__c> cifRecords= new List<EYI_Customer_Information_Form__c>();
    //     String query = 'SELECT Id, EYI_Lead_Enquiry__c,';
    //     query += String.join(fieldsToretrive, ', ');
    //     query += ' FROM EYI_Customer_Information_Form__c WHERE Id IN ('+ String.join(cifIDs, ', ') + ')';
    //     // List<String> quotedIds = new List<String>();
    //     // for (String id : newParentID) {
    //     //     quotedIds.add('\'' + id + '\'');
    //     // }
    //    // query += ' And EYI_Lead_Generation_Medium__c != '+ typeOfInsert;
    //    // query += ' AND Id NOT IN (' + String.join(newParentID, ', ') + ')';
    //     // if(queryCondition != null && queryCondition!= ''){
    //     //     query = query + ' AND ( ' + queryCondition + ' )';
    //     // }
    //    // query += ' ORDER BY CreatedDate ASC';
    //     //adding order by bcoz wanted to retrive record first which is already exist so that new record will get delete if it is duplicate
    //     //
        
    //     system.debug('query'+query);
    //     //List<EYI_Customer_Information_Form__c> cifRecords = new List<EYI_Customer_Information_Form__c>();
    //     try {
    //         // Perform the query and cast the results to a list of Lead
    //         cifRecords = (List<SObject>)Database.query(query);
            
    //     } catch (QueryException e) {System.debug('Error executing query: ' + e.getMessage());
    //     }
    //     return cifRecords;
    // }
    
}