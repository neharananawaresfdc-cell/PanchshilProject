/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EYI_CustomerMasterSyncLwcController {

    public static Boolean hasSignificantChanges(Opportunity oldOpp, Opportunity newOpp) {
        return
            oldOpp.EYI_Email__c       != newOpp.EYI_Email__c ||
            oldOpp.EYI_Mobile_Number__c != newOpp.EYI_Mobile_Number__c ||
            oldOpp.EYI_Occupation__c  != newOpp.EYI_Occupation__c ||
            oldOpp.EYI_Payment_Terms__c != newOpp.EYI_Payment_Terms__c ||
            oldOpp.EYI_City__c        != newOpp.EYI_City__c ||
            oldOpp.EYI_Address_1__c   != newOpp.EYI_Address_1__c ||
            oldOpp.EYI_Address_2__c   != newOpp.EYI_Address_2__c ||
            oldOpp.EYI_Address_3__c   != newOpp.EYI_Address_3__c ||
            oldOpp.EYI_Locality__c    != newOpp.EYI_Locality__c ||
            oldOpp.EYI_Pincode__c     != newOpp.EYI_Pincode__c;
    }

    @future(callout=true)
    public static void syncToSAP(Id opportunityId) {
        EYI_CustomerMasterSyncLwcController.customerMasterSync(opportunityId, '');
    }

    @AuraEnabled
    public static lwcMessage customerMasterSync(String recordId, String TestRun){
        lwcMessage lm = new lwcMessage();
        Boolean isPATCHOperation = false;
        Map<String, String> sfmapSAP = new Map<String, String>();
        
        if(recordId!= null){
            Opportunity RecOpportunity = [Select id ,EYI_Inventory__c, EYI_CIF_Record__r.EYI_Country__c, EYI_Salutation__c ,EYI_First_Name__c,EYI_Last_Name__c,EYI_Address3__c,EYI_Nationality__c,EYI_Project_Enquired__c,
                                          EYI_Address2__c,EYI_Address1__c,EYI_City__c,EYI_Country_Classification__c,EYI_Country_Key__c,EYI_Customer_Currency__c,EYI_Project_Enquired__r.EYI_SAP_Salesorg__c,EYI_BP_Type__c,
                                          Account.EYI_Marital_Status__c,Account.EYI_Nationality__c,Account.EYI_Occupation__c,Account.EYI_Date_Of_Birth__c,EYI_SAP_Customer_Number__c,EYI_Segment__c,EYI_Distribution_Channel__c,
                                          EYI_Date_Of_Birth__c,EYI_District__c,EYI_GSTIN_Number__c,EYI_Id_Number__c,EYI_Id_Type__c,EYI_Industry__c,EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                                          EYI_Occupation__c,EYI_Pan_Number__c,EYI_Partner_Function__c,EYI_Payment_Terms__c,EYI_Postal_Code__c,EYI_Primary_Applicant__r.EYI_Pancard_Number__c,
                                          EYI_Project_Tower_Enquired__r.EYI_SAP_Delivery_Plant_Code__c, EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c, EYI_Marital_Status__c,EYI_GST_Applicable__c,GST_Applicable__c,EYI_Alternate_Mobile_No__c,EYI_Primary_Applicant__r.EYI_Applicant_Type__c,
                                          EYI_Primary_Closing_Manager__r.EYI_Sales_Office__c,EYI_TCS_Applicable__c,EYI_Email__c,EYI_Mobile_Number__c,EYI_Is_Syc__c,EYI_Inventory__r.EYI_Inventory_Number__c,
                                          EYI_CIF_Record__r.EYI_Salutation__c ,EYI_CIF_Record__r.EYI_First_Name__c,EYI_CIF_Record__r.EYI_Last_Name__c,EYI_Is_NRI__c,EYI_Address_1__c,EYI_Pincode__c,
                                          EYI_SAP_State_Code__c,EYI_Country_Code__c, EYI_Locality__c, EYI_Primary_Closing_Manager__r.EYI_Sales_District__c   , EYI_Primary_Closing_Manager__r.EYI_Sales_Group__c,                 
                                          EYI_Address_2__c,EYI_Address_3__c,
                                          
                                          (Select id ,EYI_Salutation__c, Name, EYI_DOB__c, EYI_Email__c,EYI_Last_Name__c, EYI_First_Name__c, EYI_Relation__c, EYI_Mobile_Number__c, EYI_Applicant_Type__c ,EYI_Title__c,EYI_Pancard_Number__c,EYI_Type_Of_Applicant__c
                                           from Applicants__r Where EYI_Applicant_Type__c = 'Co-applicant'),
                                          
                                         (Select Id,EYI_Account_Holder_Name__c,EYI_Bank_Country__c,EYI_IFSC_Code__c,EYI_Bank_Account_Number__c, EYI_Bank_Name__c,IsDeleted,Is_New__c from Bank_Details__r  WHERE (IsDeleted = TRUE OR IsDeleted = FALSE))
                                          
                                          from Opportunity where id =:recordId limit 1];
            List<EYI_Bank_Details__c> bankDetailsList = [
    SELECT Id,
           EYI_Account_Holder_Name__c,
           EYI_Bank_Country__c,
           EYI_IFSC_Code__c,
           EYI_Bank_Account_Number__c,
           EYI_Bank_Name__c,
           IsDeleted,
           Is_New__c
    FROM EYI_Bank_Details__c
    WHERE Opportunity__c = :recordId
    ALL ROWS
];
   System.debug('bankDetailsList Query : '+bankDetailsList);   
            System.debug('bankDetailsList Query size: '+bankDetailsList.size()); 
            if(RecOpportunity!= null){
                try{
                    //Mrinal change starts -> Required fields missing
                    String reqFieldError = System.Label.EYI_Cust_Sync_Req_field_Error;
    				reqFieldError+=' Opportunity : ';
                    if (String.isBlank(RecOpportunity.EYI_Segment__c)) {
                        lm.type = 'e';
                        reqFieldError += ' Segment, ';
                    }
    
                    if (String.isBlank(RecOpportunity.EYI_BP_Type__c)) {
                        lm.type = 'e';
                        reqFieldError += ' Client Type, ';
                    }
    
                    if (String.isBlank(RecOpportunity.EYI_Payment_Terms__c)) {
                        lm.type = 'e';
                        reqFieldError += ' Terms Of Payment, ';
                    }
    
                    if (String.isBlank(RecOpportunity.EYI_Mobile_Number__c)) {
                        lm.type = 'e';
                        reqFieldError += ' Mobile Number, ';
                    }
                    if (String.isBlank(RecOpportunity.EYI_City__c)) {
                        lm.type = 'e';
                        reqFieldError += ' City, ';
                    }
                    if (String.isBlank(RecOpportunity.EYI_Pincode__c)) {
                        lm.type = 'e';
                        reqFieldError += ' Pincode, ';
                    }
                    if (String.isBlank(RecOpportunity.EYI_SAP_State_Code__c)) {
                        lm.type = 'e';
                        reqFieldError += ' State, ';
                    }
                    if (String.isBlank(RecOpportunity.EYI_Country_Code__c)) {
                        lm.type = 'e';
                        reqFieldError += ' Country code, ';
                    }
    
                    // Checking EYI_Inventory__r lookup fields
                    if (RecOpportunity.EYI_Inventory__c == null) {
                        lm.type = 'e';
                        reqFieldError += ' Inventory, ';
                    }
                    if (RecOpportunity.EYI_Inventory__c != null) {
                        if (String.isBlank(RecOpportunity.EYI_Inventory__r.EYI_Inventory_Number__c)) {
                            lm.type = 'e';
                            reqFieldError += ' Inventory --> Inventory Number, ';
                        }
                    }
                    // Checking EYI_Project_Enquired__r lookup fields
                    if (RecOpportunity.EYI_Project_Enquired__r != null) {
                        if (String.isBlank(RecOpportunity.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c)) {
                            lm.type = 'e';
                            reqFieldError += ' Project --> SAP Company Code, ';
                        }
                        if (String.isBlank(RecOpportunity.EYI_Project_Enquired__r.EYI_SAP_Salesorg__c)) {
                            lm.type = 'e';
                            reqFieldError += ' Project --> SAP Sales-org, ';
                        }
                    }
    
                    // Checking EYI_Project_Tower_Enquired__r lookup fields
                    if (RecOpportunity.EYI_Project_Tower_Enquired__r != null) {
                        if (String.isBlank(RecOpportunity.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c)) {
                            lm.type = 'e';
                            reqFieldError += ' Tower --> SAP Plant Code, ';
                        }
                    }
                    if (RecOpportunity.EYI_CIF_Record__c == null) {
                        lm.type = 'e';
                        reqFieldError += ' CIF Record, ';
                    }
                    // Checking CIF fields from EYI_CIF_Record__r lookup
                    if (RecOpportunity.EYI_CIF_Record__r != null) {
                        if (String.isBlank(RecOpportunity.EYI_CIF_Record__r.EYI_Salutation__c)) {
                            lm.type = 'e';
                            reqFieldError += ' CIF Record --> Salutation, ';
                        }
                        if (String.isBlank(RecOpportunity.EYI_CIF_Record__r.EYI_First_Name__c)) {
                            lm.type = 'e';
                            reqFieldError += ' CIF Record --> First Name, ';
                        }
                        if (String.isBlank(RecOpportunity.EYI_CIF_Record__r.EYI_Last_Name__c)) {
                            lm.type = 'e';
                            reqFieldError += ' CIF Record --> Last Name, ';
                        }

                        if (String.isBlank(RecOpportunity.EYI_Country_Code__c)) {
                            lm.type = 'e';
                            reqFieldError += ' Country code, ';
                        }
                    }

                    // Remove the trailing comma and space before setting the error message
                    if (lm.type == 'e') {
                        reqFieldError = reqFieldError.trim();
                        if (reqFieldError.endsWith(',')) {
                            reqFieldError = reqFieldError.substring(0, reqFieldError.length() - 1);
                        }
                        lm.message = reqFieldError; 
                        return lm;
                    }
    
    
                    //Mrinal change ends -> Required fields missing
                    List<SAP_SF_Field_Map__c> mapData = [select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c from SAP_SF_Field_Map__c ];
                    if(!mapData.isEmpty()){
                        for(SAP_SF_Field_Map__c mp :mapData){
                            sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                            //system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
                        } 
                    }
                    EYI_REC_CustomerMasterCreationWrapper recCustomerMaster = new EYI_REC_CustomerMasterCreationWrapper();
                    EYI_REC_CustomerMasterCreationWrapper.cls_ImCustomer customer = new EYI_REC_CustomerMasterCreationWrapper.cls_ImCustomer();
                    
                    EYI_REC_CustomerMasterCreationWrapper.cls_Partner Partner = new EYI_REC_CustomerMasterCreationWrapper.cls_Partner();
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_Partner> PartnerList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_Partner>();
                    
                    EYI_REC_CustomerMasterCreationWrapper.cls_CustID CustID = new EYI_REC_CustomerMasterCreationWrapper.cls_CustID();
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_CustID> CustIDList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_CustID>();
                    
                    EYI_REC_CustomerMasterCreationWrapper.cls_TaxID TaxID = new EYI_REC_CustomerMasterCreationWrapper.cls_TaxID();
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_TaxID> TaxIDList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_TaxID>();
                    
                    EYI_REC_CustomerMasterCreationWrapper.cls_Addr Addr = new EYI_REC_CustomerMasterCreationWrapper.cls_Addr();
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_Addr> AddrList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_Addr>();
                    
                    EYI_REC_CustomerMasterCreationWrapper.cls_Comm Comm = new EYI_REC_CustomerMasterCreationWrapper.cls_Comm();
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_Comm> CommList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_Comm>();
                    
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_CO_Applicant> CO_ApplicantList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_CO_Applicant>();
                    
                    List<EYI_REC_CustomerMasterCreationWrapper.cls_Bank> BankList = new List<EYI_REC_CustomerMasterCreationWrapper.cls_Bank>();

                    if(RecOpportunity.EYI_SAP_Customer_Number__c != null){
                        customer.KUNNR = RecOpportunity.EYI_SAP_Customer_Number__c;
                    }
                    customer.TEST_RUN=TestRun; 
                    // these are required field

                    
                    
                    // not req. 
                    //customer.SORT2 ='SORT2';
                    customer.SEXID ='';
                    customer.INCO1 ='';
                    customer.SPART ='00';
                    //customer.TAXKD ='0';
                    //customer.TYPE ='1';
                    //customer.TAXKD ='0';
                    // customer.TYPE ='1';
                    // create formula  field
                   // customer.VTWEG ='10';
                   /*
                    if(RecOpportunity.EYI_SAP_Customer_Number__c!= null){
                        customer.CUSTOMERNO = RecOpportunity.EYI_SAP_Customer_Number__c;// '1';//test
                    }*/

                    if(RecOpportunity.EYI_Inventory__r.EYI_Inventory_Number__c!= null){
                        customer.SORT2 = RecOpportunity.EYI_Inventory__r.EYI_Inventory_Number__c;// '1';//test
                    }                
                    
                    if(RecOpportunity.EYI_CIF_Record__r.EYI_Salutation__c!= null){
                        if(sfmapSAP.containsKey('EYI_Salutation__c'+'~'+RecOpportunity.EYI_CIF_Record__r.EYI_Salutation__c)) 
                            customer.TITLE_MEDI =sfmapSAP.get('EYI_Salutation__c'+'~'+RecOpportunity.EYI_CIF_Record__r.EYI_Salutation__c);// '1';//test
                    }
                    // we are passing inventory data 
                    if(RecOpportunity.EYI_Inventory__c!= null){
                        //customer.SORT2 = String.valueof(RecOpportunity.EYI_Inventory__c) ;
                    }
                    if(RecOpportunity.EYI_BP_Type__c!= null){
                        customer.TYPE = String.valueof(RecOpportunity.EYI_BP_Type__c) ;
                    }
                    if(RecOpportunity.EYI_Segment__c!= null){
                        if(sfmapSAP.containsKey('EYI_Distribution_Channel__c'+'~'+RecOpportunity.EYI_Segment__c)) 
                            customer.VTWEG =sfmapSAP.get('EYI_Distribution_Channel__c'+'~'+RecOpportunity.EYI_Segment__c);// '1';//test
                        if(RecOpportunity.EYI_Segment__c == 'Residential Sales'){
                    		customer.BU_GROUP ='ZREC';
                        }else{
                            customer.BU_GROUP ='ZCOS';
                        }
                    }
                    if(RecOpportunity.EYI_CIF_Record__r.EYI_First_Name__c!= null){
                        customer.NAME_FIRST = String.valueof(RecOpportunity.EYI_CIF_Record__r.EYI_First_Name__c) ;
                    }
                    if(RecOpportunity.EYI_CIF_Record__r.EYI_Last_Name__c!= null){
                        customer.NAME_LAST = String.valueof(RecOpportunity.EYI_CIF_Record__r.EYI_Last_Name__c) ;
                    }
                    if(RecOpportunity.EYI_First_Name__c!= null){
                        String fn = String.valueOf(RecOpportunity.EYI_First_Name__c).trim();
                        fn = fn.split(' ').size() >= 2 ? fn.split(' ')[0] + ' ' + fn.split(' ')[1] : fn;
                        customer.SORT1 = fn.substring(0, Math.min(fn.length(), 20));
                        //customer.SORT1 = String.valueof(RecOpportunity.EYI_First_Name__c) ;
                    }
                    if(RecOpportunity.EYI_Segment__c!= null){
                        if(sfmapSAP.containsKey('EYI_Segment__c'+'~'+RecOpportunity.EYI_Segment__c)) 
                            customer.BU_GROUP =sfmapSAP.get('EYI_Segment__c'+'~'+RecOpportunity.EYI_Segment__c);// '1';//test
                    }
                    if(RecOpportunity.Account.EYI_Marital_Status__c!= null){
                        if(sfmapSAP.containsKey('EYI_Marital_Status__c'+'~'+RecOpportunity.Account.EYI_Marital_Status__c)) 
                            customer.MARST =sfmapSAP.get('EYI_Marital_Status__c'+'~'+RecOpportunity.Account.EYI_Marital_Status__c);// '1';//test
                    }
                    if(RecOpportunity.Account.EYI_Nationality__c!= null){
                        if(sfmapSAP.containsKey('EYI_Nationality__c'+'~'+RecOpportunity.Account.EYI_Nationality__c)) 
                            customer.NATIO =sfmapSAP.get('EYI_Nationality__c'+'~'+RecOpportunity.Account.EYI_Nationality__c);// '1';//test
                    }
                    if(RecOpportunity.Account.EYI_Occupation__c!= null){
                        if(sfmapSAP.containsKey('EYI_Occupation__c'+'~'+RecOpportunity.Account.EYI_Occupation__c)) 
                            customer.JOBGR =sfmapSAP.get('EYI_Occupation__c'+'~'+RecOpportunity.Account.EYI_Occupation__c);// '1';//test
                    }
                    if(RecOpportunity.Account.EYI_Date_Of_Birth__c!= null){
                        //customer.BIRTHDT = String.valueof) ;
                        List<String> dday = String.valueOf(RecOpportunity.Account.EYI_Date_Of_Birth__c).split('-');
                        system.debug('dday  ===='+dday);
                        string deathhdt;
                        if(!dday.isEmpty()){
                            deathhdt = dday[2] + '.' +dday[1] +'.' +dday[0];
                        }
                        customer.BIRTHDT=deathhdt;
                    }
                    if(RecOpportunity.id!= null){
                        customer.BPEXT = String.valueof(RecOpportunity.id) ;
                    }
                    if(RecOpportunity.EYI_Country_Classification__c!= null){
                        if(sfmapSAP.containsKey('EYI_Country_Classification__c'+'~'+RecOpportunity.EYI_Country_Classification__c)) 
                            customer.KUKLA =sfmapSAP.get('EYI_Country_Classification__c'+'~'+RecOpportunity.EYI_Country_Classification__c);
                    }
                    if(RecOpportunity.EYI_Industry__c!= null){
                        if(sfmapSAP.containsKey('EYI_Industry__c'+'~'+RecOpportunity.EYI_Industry__c)) 
                            customer.BRAN1 =sfmapSAP.get('EYI_Industry__c'+'~'+RecOpportunity.EYI_Industry__c);
                    }
                    
                    /* if(RecOpportunity.EYI_Project_Enquired__c!= null){
    customer.BUKRS = String.valueof(RecOpportunity.EYI_Project_Enquired__c) ;
    }*/
                    // we are piuting this fields
                    
                    if(RecOpportunity.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c!= null){
                        customer.BUKRS = String.valueof(RecOpportunity.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c) ;
                    }
                    if(RecOpportunity.EYI_Payment_Terms__c!= null){
                        if(sfmapSAP.containsKey('EYI_Payment_Terms__c'+'~'+RecOpportunity.EYI_Payment_Terms__c)) 
                            customer.ZTERM =sfmapSAP.get('EYI_Payment_Terms__c'+'~'+RecOpportunity.EYI_Payment_Terms__c);// '1';//test
                    }
                    if(RecOpportunity.EYI_Project_Enquired__r.EYI_SAP_Salesorg__c!= null){
                        customer.VKORG = String.valueof(RecOpportunity.EYI_Project_Enquired__r.EYI_SAP_Salesorg__c) ;
                    }
                    if(RecOpportunity.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c!= null){
                        customer.WERKS = String.valueof(RecOpportunity.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c) ;
                    }
                    // not found kds RecordType.Nam
                    /* if(RecOpportunity.EYI_Salutation__c!= null){
    if(sfmapSAP.containsKey('EYI_Salutation__c'+'~'+RecOpportunity.EYI_Salutation__c)) 
    customer.VTWEG =sfmapSAP.get('EYI_Salutation__c'+'~'+RecOpportunity.EYI_Salutation__c);// '1';//test
    }*/
                    // not found kds Project --> Project City
                    if(RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_District__c != null){
                        if(sfmapSAP.containsKey('EYI_Project_City__c'+'~'+RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_District__c)) {
                            customer.BZIRK =sfmapSAP.get('EYI_Project_City__c'+'~'+RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_District__c) ; //sfmapSAP.get('EYI_Salutation__c'+'~'+RecOpportunity.EYI_Salutation__c);// '1';//test 
                        }
                    }
                    if(RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_Office__c!= null){
                        if(sfmapSAP.containsKey('EYI_Sales_Office__c'+'~'+RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_Office__c)) 
                            customer.VKBUR =sfmapSAP.get('EYI_Sales_Office__c'+'~'+RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_Office__c);// '1';//test
                    }
                    if(RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_Group__c!= null){
                        if(sfmapSAP.containsKey('EYI_Sales_Group__c'+'~'+RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_Group__c)) 
                            customer.VKGRP =sfmapSAP.get('EYI_Sales_Group__c'+'~'+RecOpportunity.EYI_Primary_Closing_Manager__r.EYI_Sales_Group__c);// '1';//test
                    }
                    if(RecOpportunity.EYI_Customer_Currency__c!= null){
                        if(sfmapSAP.containsKey('EYI_Customer_Currency__c'+'~'+RecOpportunity.EYI_Customer_Currency__c)) 
                            customer.WAERS =sfmapSAP.get('EYI_Customer_Currency__c'+'~'+RecOpportunity.EYI_Customer_Currency__c);// '1';//test
                    }
                    if(RecOpportunity.EYI_Primary_Applicant__r.EYI_Pancard_Number__c!= null){
                        customer.J_1IPANNO = String.valueof(RecOpportunity.EYI_Primary_Applicant__r.EYI_Pancard_Number__c) ;
                    }
                    if(RecOpportunity.EYI_TCS_Applicable__c == TRUE ){
                        customer.TCS_FLAG = 0 ;
                    }else{
                        customer.TCS_FLAG = 1 ;

                    }
                    if(RecOpportunity.EYI_GST_Applicable__c == 'Yes' ){
                        customer.GST_FLAG = 0 ;
                    }else{
                        customer.GST_FLAG = 1 ;
                    }
                    if(RecOpportunity.EYI_GSTIN_Number__c!= null ){
                        customer.GSTIN =  String.valueof(RecOpportunity.EYI_GSTIN_Number__c) ;
                    }
                    List<ContentDocumentLink> cd =  [ SELECT ContentDocumentId,  ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
                                                     FROM ContentDocumentLink WHERE LinkedEntityId = :RecOpportunity.id and ContentDocument.Title ='pdf' order by ContentDocument.createddate desc limit 1];
                    if(!cd.isEmpty()){
                        string ContentDocumentId = cd[0].ContentDocumentId;
                        List<ContentVersion> cv = [select Id, Title, VersionData, FileExtension , ContentDocumentId from ContentVersion where ContentDocumentId=:ContentDocumentId limit 1];
                        
                        if(!cv.isEmpty())
                            customer.PDF =  EncodingUtil.base64Encode(cv[0].VersionData);
                    }
                    
                    // partner function 
                    
                    if(RecOpportunity.EYI_Partner_Function__c!= null){
                        if(sfmapSAP.containsKey('EYI_Partner_Function__c'+'~'+RecOpportunity.EYI_Partner_Function__c)) 
                            Partner.PARVW =sfmapSAP.get('EYI_Partner_Function__c'+'~'+RecOpportunity.EYI_Partner_Function__c);// '1';//test
                    }
                    // kds not found
                    if(RecOpportunity.EYI_Partner_Function__c!= null){
                        if(sfmapSAP.containsKey('EYI_Business_Partner__c'+'~'+RecOpportunity.EYI_Partner_Function__c)) {}
                        //  Partner.KTONR =sfmapSAP.get('EYI_Business_Partner__c'+'~'+RecOpportunity.EYI_Partner_Function__c);// '1';//test
                    }
                    PartnerList.add(Partner);
                    
                    // CustID function 
                    if(RecOpportunity.EYI_Primary_Applicant__r.EYI_Applicant_Type__c!= null){
                        if(sfmapSAP.containsKey('EYI_Id_Type__c'+'~'+RecOpportunity.EYI_Primary_Applicant__r.EYI_Applicant_Type__c)) 
                            CustID.IDTYPE =sfmapSAP.get('EYI_Id_Type__c'+'~'+RecOpportunity.EYI_Primary_Applicant__r.EYI_Applicant_Type__c);// '1';//test
                    }
                    if(RecOpportunity.EYI_Id_Number__c!= null){
                        CustID.IDNUMBER = String.valueof(RecOpportunity.EYI_Id_Number__c) ;
                    }
                    CustIDList.add(CustID);
                    
                    //TaxID function
                    if(RecOpportunity.EYI_GSTIN_Number__c!= null){
                        TaxID.TAXNUM = String.valueof(RecOpportunity.EYI_GSTIN_Number__c) ;
                    }
                    if(RecOpportunity.EYI_GSTIN_Number__c!= null){
                        TaxID.TAXTYPE = '';//String.valueof(RecOpportunity.EYI_GSTIN_Number__c) ;
                    }
                    TaxIDlist.add(TaxID);
                    Integer SEQNO=0;
                    //Addr 
                    if(RecOpportunity.EYI_Address_1__c!= null){
                        Addr.STREET = String.valueof(RecOpportunity.EYI_Address_1__c) ;
                    }
                    if(RecOpportunity.EYI_Address_2__c!= null){
                        Addr.STR_SUPPL3 = String.valueof(RecOpportunity.EYI_Address_2__c) ;
                    }
                    if(RecOpportunity.EYI_Address_3__c!= null){
                        Addr.LOCATION = String.valueof(RecOpportunity.EYI_Address_3__c) ;
                    }
                    if(RecOpportunity.EYI_Locality__c!= null){
                        Addr.CITY2 = String.valueof(RecOpportunity.EYI_Locality__c) ;
                    }
                    if(RecOpportunity.EYI_Pincode__c!= null){
                        Addr.POST_CODE1 = String.valueof(RecOpportunity.EYI_Pincode__c) ;
                    }
                    if(RecOpportunity.EYI_City__c!= null){
                        Addr.CITY1 = String.valueof(RecOpportunity.EYI_City__c) ;
                    }
                    /*
                    if(!RecOpportunity.EYI_Is_NRI__c){
                        Addr.COUNTRY ='India';
                    }else{ */
                    if(RecOpportunity.EYI_Country_Code__c!= null){
                        String countryCode = RecOpportunity.EYI_CIF_Record__r.EYI_Country__c.trim(); 
                        Integer startIndex = RecOpportunity.EYI_CIF_Record__r.EYI_Country__c.indexOf('(');
                        system.debug('startIndex '+ startIndex);                    
                        //String countryName = startIndex > 0 ? countryCode.substring(0, startIndex).trim() : null;
                        String countryName = RecOpportunity.EYI_CIF_Record__r.EYI_Country__c;
    
                        system.debug('Country Name '+ countryName);
                        String recordName = 'EYI_Country__c_' +countryName;
                        SAP_SF_Field_Map__c countryRecord = [
                        SELECT Id, Name, SAP_Value__c  // Add required fields here
                        FROM SAP_SF_Field_Map__c
                        WHERE Name = :recordName
                        LIMIT 1
                    ];
                        //Addr.COUNTRY = String.valueof(RecOpportunity.EYI_Country_Key__c) ;
                        //Addr.COUNTRY = String.valueof(sfmapSAP.get('EYI_Country__c'+'~'+countryName));
                        Addr.COUNTRY = countryRecord.SAP_Value__c; 
                    }
                
                    
                    // not found  state 
                    if(RecOpportunity.EYI_SAP_State_Code__c!= null){
                        Addr.REGION = RecOpportunity.EYI_SAP_State_Code__c;
                    }
                    SEQNO++;
                    // these are required field
                    Addr.ADDR_TYPE= 'XXDFLT';
                    Addr.SEQNO= String.valueof(SEQNO);
                    AddrList.add(Addr);
                    
                    //CO_APPLICANT
                    /*
                    if(RecOpportunity.Applicants__r.size()>0){
                        Integer i = 1;
                        for(EYI_Applicants__c AppObj : RecOpportunity.Applicants__r){
                            if(AppObj.EYI_Title__c!= null){ 
                                if(sfmapSAP.containsKey('EYI_Salutation__c'+'~'+AppObj.EYI_Salutation__c)) 
                                    CO_APPLICANT.TITLE =sfmapSAP.get('EYI_Salutation__c'+'~'+AppObj.EYI_Salutation__c);// '1';//test
                            }
                            if(AppObj.EYI_Last_Name__c!= null){
                                CO_APPLICANT.NAME_LAST= String.valueof(AppObj.EYI_Last_Name__c) ;
                            }
                            if(AppObj.EYI_First_Name__c!= null){
                                CO_APPLICANT.NAME_FIRST= String.valueof(AppObj.EYI_First_Name__c) ;
                            }                            
                            
                            if(AppObj.EYI_Email__c!= null){
                                CO_APPLICANT.SMTP_ADDRESS= String.valueof(AppObj.EYI_Email__c) ;
                            }
                            if(AppObj.EYI_Mobile_Number__c!= null){
                                CO_APPLICANT.TEL_NUMBER= String.valueof(AppObj.EYI_Mobile_Number__c) ;
                            }
                             if(AppObj.EYI_Pancard_Number__c!= null){
                                CO_APPLICANT.PANNO= String.valueof(AppObj.EYI_Pancard_Number__c) ;
                            }
                            if(AppObj.EYI_Applicant_Type__c!= null && AppObj.EYI_Applicant_Type__c =='Co-Applicant' ){
                                CO_APPLICANT.ABTNR = 'Z00' + String.valueOf(i++);
                                
                                if(AppObj.EYI_Relation__c!= null && sfmapSAP.containsKey('EYI_Relation__c'+'~'+AppObj.EYI_Relation__c)){
                                    CO_APPLICANT.PAFKT= sfmapSAP.get('EYI_Relation__c'+'~'+AppObj.EYI_Relation__c);
                                }
                            }
                            CO_ApplicantList.add(CO_APPLICANT);
                        }
                    }*/
                    if (RecOpportunity.Applicants__r.size() > 0) {
                        Integer i = 1;
                        for (EYI_Applicants__c AppObj : RecOpportunity.Applicants__r) {
                            if (AppObj.EYI_Applicant_Type__c != null && AppObj.EYI_Applicant_Type__c == 'Co-Applicant') {
                                EYI_REC_CustomerMasterCreationWrapper.cls_CO_Applicant CO_APPLICANT = new EYI_REC_CustomerMasterCreationWrapper.cls_CO_Applicant();

                                CO_APPLICANT.ABTNR = 'Z00' + String.valueOf(i++);
                                if(AppObj.EYI_DOB__c != null){
                                    List<String> dday = String.valueOf(AppObj.EYI_DOB__c).split('-');
                                    string deathhdt;
                                    if(!dday.isEmpty()){
                                        deathhdt = dday[2] + '.' +dday[1] +'.' +dday[0];
                                    }
                                    CO_APPLICANT.BIRTHDT = deathhdt;
                                }

                                if (AppObj.EYI_Salutation__c != null && sfmapSAP.containsKey('EYI_Salutation__c' + '~' + AppObj.EYI_Salutation__c)) {
                                    system.debug('inside Salutation ');
                                    CO_APPLICANT.TITLE = sfmapSAP.get('EYI_Salutation__c' + '~' + AppObj.EYI_Salutation__c);
                                }
                                if (AppObj.Name != null) {
                                    List<String> parts = AppObj.Name.trim().split(' ');
                                    Integer len = parts.size();

                                    CO_APPLICANT.NAME_FIRST = (len == 1) ? parts[0] :
                                                            (len == 2) ? parts[0] :
                                                            parts[0] + ' ' + parts[1];

                                    if (len == 1) {
                                        CO_APPLICANT.NAME_LAST = '';
                                    } else if (len == 2) {
                                        CO_APPLICANT.NAME_LAST = parts[1];
                                    } else {
                                        List<String> tail = new List<String>();
                                        for (Integer j = 2; j < len; j++) {
                                            tail.add(parts[j]);
                                        }
                                        CO_APPLICANT.NAME_LAST = String.join(tail, ' ');
                                    }
                                }
                                /*
                                if (AppObj.EYI_Last_Name__c != null) {
                                    CO_APPLICANT.NAME_LAST = String.valueOf(AppObj.EYI_Last_Name__c);
                                }
                                if (AppObj.EYI_First_Name__c != null) {
                                    CO_APPLICANT.NAME_FIRST = String.valueOf(AppObj.EYI_First_Name__c);
                                }*/
                                if (AppObj.EYI_Email__c != null) {
                                    CO_APPLICANT.SMTP_ADDRESS = String.valueOf(AppObj.EYI_Email__c);
                                }
                                if (AppObj.EYI_Mobile_Number__c != null) {
                                    CO_APPLICANT.TEL_NUMBER = String.valueOf(AppObj.EYI_Mobile_Number__c);
                                }
                                if (AppObj.EYI_Pancard_Number__c != null) {
                                    CO_APPLICANT.PANNO = String.valueOf(AppObj.EYI_Pancard_Number__c);
                                }
                                if (AppObj.EYI_Relation__c != null && sfmapSAP.containsKey('EYI_Relation__c' + '~' + AppObj.EYI_Relation__c)) {
                                    CO_APPLICANT.PAFKT = sfmapSAP.get('EYI_Relation__c' + '~' + AppObj.EYI_Relation__c);
                                }
                                CO_ApplicantList.add(CO_APPLICANT);
                            }
                        }
                    }
                    
                    //Added by Akshay for Bank details Sync
                    if (bankDetailsList.size() > 0) {
                        System.debug('bankDetailsList.Size() : '+bankDetailsList.Size());
                        Integer i = 1;
                        for (EYI_Bank_Details__c bankObj : bankDetailsList) {
                        EYI_REC_CustomerMasterCreationWrapper.cls_Bank Bank = new EYI_REC_CustomerMasterCreationWrapper.cls_Bank();

                            System.debug('bankObj : '+bankObj);
                            string bankingcode;
                            if(String.valueOf(i).length() == 1) bankingcode = '000' + String.valueOf(i);
                            if(String.valueOf(i).length() == 2) bankingcode = '00' + String.valueOf(i);
                            if(String.valueOf(i).length() == 3) bankingcode = '0' + String.valueOf(i);
                            if(String.valueOf(i).length() == 4) bankingcode =  String.valueOf(i);
                            
                            Bank.Bkvid =bankingcode;
                            /*if (bankObj.EYI_Bank_Name__c != null) {
                                    Bank.BKVID = String.valueOf(bankObj.EYI_Bank_Name__c);
                            }*/
                            if(bankObj.EYI_Bank_Country__c!=null && sfmapSAP.containsKey('EYI_Country__c'+'~'+bankObj.EYI_Bank_Country__c)){
                               Bank.BANK_CTRY = sfmapSAP.get('EYI_Country__c'+'~'+bankObj.EYI_Bank_Country__c);//'IN';// rec[0].EYI_Country__c;
                            }
                            /*if (bankObj.EYI_Bank_Country__c != null) {
                                    Bank.BANK_CTRY = String.valueOf(bankObj.EYI_Bank_Country__c);
                            }*/
                            if (bankObj.EYI_IFSC_Code__c != null) {
                                    Bank.BANK_KEY = String.valueOf(bankObj.EYI_IFSC_Code__c);
                            }
                            if (bankObj.EYI_Bank_Account_Number__c != null) {
                                    Bank.BANK_ACCT = String.valueOf(bankObj.EYI_Bank_Account_Number__c);
                            }
                            if (bankObj.EYI_Account_Holder_Name__c != null) {
                                    Bank.ACCOUNTHOLDER = String.valueOf(bankObj.EYI_Account_Holder_Name__c);
                            }
                            if (bankObj.isDeleted) {
                                    Bank.BANK_REF = 'D';
                            }else{
                                if(bankObj.Is_New__c){
                                   Bank.BANK_REF = 'I'; 
                                }else{
                                    Bank.BANK_REF = 'U';
                                }
                            }
                            if (bankObj.EYI_Bank_Name__c != null) {
                                    Bank.BANKACCOUNTNAME = String.valueOf(bankObj.EYI_Bank_Name__c);
                            }
                           
                            BankList.add(Bank);
                            i++;
                        }
                    }

                    //cls_Comm
                    if(RecOpportunity.EYI_Mobile_Number__c!= null){
                        Comm.TEL_NUMBER= String.valueof(RecOpportunity.EYI_Mobile_Number__c) ;
                    }
                    if(RecOpportunity.EYI_Email__c!= null){
                        Comm.SMTP_ADDR = String.valueof(RecOpportunity.EYI_Email__c) ;
                    }
                    if(RecOpportunity.EYI_Alternate_Mobile_No__c!= null){
                        Comm.MOB_NUMBER = String.valueof(RecOpportunity.EYI_Alternate_Mobile_No__c) ;
                    }
                    // default values to be added
                    Comm.COUNTRY=   String.valueof(RecOpportunity.EYI_Country_Key__c) ; //'IN';
                    Comm.MOB_NUMBER=  String.valueof(RecOpportunity.EYI_Mobile_Number__c) ;//'456789876543';
                    CommList.add(Comm);
                    
                    
                    customer.PARTNER =PARTNERlist;
                    customer.CustID =CustIDlist;
                    customer.TaxID =TaxIDlist;
                    customer.Addr =Addrlist;
                    customer.Comm =Commlist;
                    customer.CO_APPLICANT =CO_Applicantlist;
                    customer.Bank =Banklist;
                    
                    recCustomerMaster.IM_CUSTOMER =customer;
                    
                    /*HttpRequest req = new HttpRequest();
                    
                    system.debug('Genrate jsonBody:: '+jsonBody);
                    req.setBody(jsonBody);
                    system.debug('isPATCHOperation-->'+isPATCHOperation);
                    if(isPATCHOperation == true) req.setMethod('PATCH'); 
                    else req.setMethod('POST');*/ 
                    String jsonBody =JSON.serialize(recCustomerMaster);
                    HTTPResponse res = new HTTPResponse();
            		res = EY_SAP_Gateway.custSync(jsonBody);
                   // req.setEndpoint('callout:Customer_Sync');
                    
                    // Create an HTTP object to send the request
                   /* Http http = new Http();
                    HttpResponse res;
                    // Send the HTTP request and get the response
                    res = http.send(req);*/
                    system.debug('res.getBody()-->'+res.getBody());
                    
                    // Check the response status code
                    if (res.getStatusCode() == 200) {
                        
                        /*EYI_AbstractHttpServiceConsumer.Logger log = new EYI_AbstractHttpServiceConsumer.Logger();
                        log.addEntry(req, res, DateTime.now());
                        System.enqueueJob(log);*/
                        // Success: Return the response body
                        system.debug('Response jsonbody-->'+res.getBody());
                        // Deserialize the JSON into an untyped map
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        // Extract the "n0:ZsdCreateVendorFromSfResponse" field from the map
                        Map<String, Object> CustomerResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_CUSTOMER_FROM_SFResponse');
                        // Extract the "EX_RETURN" field
                        //List<Object> EXRETURNLst= (List<Object>)CustomerResponse.get('EX_RETURN');
                        Map<String, Object> EX_RETURN = (Map<String, Object>) CustomerResponse.get('EX_RETURN');
                        String EXCUTSOMERVal = (string) CustomerResponse.get('EX_CUTSOMER');
                        system.debug('EXCUTSOMERVal-->'+EXCUTSOMERVal);
                        system.debug('EX_RETURN-->'+EX_RETURN);
                        Object item =  EX_RETURN.get('item');
                        system.debug('item-->'+item);
                        
                        // Now you can access individual fields within the "item" map
                        String type = '';
                        String messagDisp = '';
                        if (item instanceof List<Object>) {
                            List<Object> itemList = (List<Object>) item;
                            
                            for (Object obj : itemList) {
                                Map<String, Object> objitem = (Map<String, Object>) obj;
                                type = type +'\n--'+ (String) objitem.get('TYPE');
                                messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                            }
                        }else if(item instanceof Map<String, Object>){
                            SYSTEM.DEBUG('item   '+item);
                            Map<String, Object> objitem = (Map<String, Object>) item;
                            SYSTEM.DEBUG('objitem   '+objitem);
                            type =  (String) objitem.get('TYPE');
                            messagDisp =(String) objitem.get('MESSAGE');
                        }
                        if(messagDisp!=null && type!=null  && isPATCHOperation ==true){
                            RecOpportunity.EYI_SAP_Error__c = messagDisp;
                            update RecOpportunity;
                            system.debug('Updating RecOpportunity code');
                        }
                        String cleanedType = type.replaceAll('-', '');
                        // Check if the cleaned string contains only 'S'
                        if (cleanedType != '' && cleanedType.replaceAll('S', '') == '') {
                            system.debug('RecOpportunity    == '+RecOpportunity);
                            list<Opportunity> updatelist= new  list<Opportunity>();
                            IF(!RecOpportunity.EYI_Is_Syc__c){
                                RecOpportunity.EYI_Is_Syc__c= TRUE;
                                RecOpportunity.EYI_SAP_Error__c = messagDisp;
                                IF(EXCUTSOMERVal!= null && EXCUTSOMERVal!=''){
                                RecOpportunity.EYI_SAP_Customer_Number__c= EXCUTSOMERVal;
                                }
                                UPDATE RecOpportunity;
                            }ELSE{
                                 IF(EXCUTSOMERVal!= null && EXCUTSOMERVal!=''){
                                RecOpportunity.EYI_SAP_Customer_Number__c= EXCUTSOMERVal;
                                RecOpportunity.EYI_SAP_Error__c = messagDisp;
                                }
                                UPDATE RecOpportunity;
    
                            }
                        }
                        SYSTEM.DEBUG('type   '+type);
                        SYSTEM.DEBUG('messagDisp   '+messagDisp);
                        lm.type =  type;
                        lm.message = messagDisp;
                        SYSTEM.DEBUG('lm   '+lm);
                        return lm;
                        
                    }
                    else{
                        
                        /*EYI_AbstractHttpServiceConsumer.Logger log = new EYI_AbstractHttpServiceConsumer.Logger();
                        log.addEntry(req, res, DateTime.now());
                        System.enqueueJob(log);*/
                        lm.type =  'E';
                        lm.message = res.getBody();
                        RecOpportunity.EYI_SAP_Error__c = res.getBody();
                        update RecOpportunity;
                        system.debug('Error:: ' +res.getBody());
                        return lm;
                    }
                    
                } catch (Exception e) {
                    // Handle exceptions
                    lm.type =  'E';
                    lm.message = e.getMessage()+'---' +e.getLineNumber();
                    RecOpportunity.EYI_SAP_Error__c = e.getMessage();
                    update RecOpportunity;
                    system.debug('Error:: ' +e.getMessage());
                    return lm;
                }
            }
        }else{
            lm.type =  'E';
            lm.message = 'Record Id Missing';
            return lm;
        }
        return lm;
    }
    
    public class lwcMessage{
        
        @AuraEnabled  public string type;
        @AuraEnabled  public string message;
    }  
}