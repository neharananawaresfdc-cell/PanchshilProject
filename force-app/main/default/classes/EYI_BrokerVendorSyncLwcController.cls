public class EYI_BrokerVendorSyncLwcController {
    
    @future(callout=true)
    public static void syncToSAP(Id recAccId) {
        EYI_BrokerVendorSyncLwcController.brokerVendorSync(recAccId, '');
    }
    
    public static void updatedBankDetails(List<EYI_Bank_Details__c> oldBank, List<EYI_Bank_Details__c> newBank) {
        Set<Id> recAccountIds = new Set<Id>();
        
        // Collect all unique EYI_REC_Account__c IDs from newBank
        for (EYI_Bank_Details__c bank : newBank) {
            if (bank.EYI_REC_Account__c != null) {
                recAccountIds.add(bank.EYI_REC_Account__c);
            }
        }
        
        // Query the related EYI_REC_Account__c records
        Map<Id, EYI_REC__c> recAccountsMap = new Map<Id, EYI_REC__c>(
            [SELECT Id, EYI_REC_Vendor_Code__c FROM EYI_REC__c WHERE Id IN :recAccountIds]
        );
        
        // Check conditions using the queried records
        Id recId;
        for (EYI_Bank_Details__c bank : newBank) {
            if (bank.EYI_REC_Account__c != null && recAccountsMap.containsKey(bank.EYI_REC_Account__c)) {
                EYI_REC__c relatedAccount = recAccountsMap.get(bank.EYI_REC_Account__c);
                if (relatedAccount.EYI_REC_Vendor_Code__c != null) {
                    recId = bank.EYI_REC_Account__c;
                }
            }
        }
        
        // Call the sync method if recId is found
        if (recId != null) {
            EYI_BrokerVendorSyncLwcController.syncToSAP(recId);
        }
    }


    public static Boolean hasSignificantChanges(EYI_REC__c oldRec, EYI_REC__c newRec) {
        List<String> fieldsToCheck = new List<String>{
            'EYI_Salutation__c', 'EYI_First_Name__c', 'EYI_Middle_Name__c', 'EYI_Last_Name__c','EYI_Gender__c', 'EYI_Marital_Status__c', 'EYI_Nationality__c', 'EYI_Occupation__c',
            'EYI_Organization__c', 'EYI_Designation__c', 'EYI_Birth_Date__c', 'EYI_Anniversary_Date__c','EYI_Company_Code__c', 'EYI_Reconciliation_Account__c', 'EYI_Payment_Terms__c',
            'EYI_Minority_Indicator__c', 'EYI_MSME__c', 'EYI_GSTIN__c', 'EYI_Aadhar__c','EYI_Udyog_Adhar__c', 'EYI_Company_Regisration__c', 'EYI_ESIC_Number__c','EYI_RERA_Number__c', 
            'EYI_City__c', 'EYI_Country__c', 'EYI_Region__c','EYI_Mobile__c', 'EYI_Alternate_Mobile__c', 'EYI_Type_Of_RERA_Registration__c','EYI_REC_Firm_Name__c', 
            'EYI_Pincode_Office__c','EYI_REC_Owner_Mobile_Number__c', 'EYI_Email__c', 'EYI_Alternate_Email__c','EYI_REC_Correspondence_Mobile_Number__c', 'EYI_PAN_No__c', 
            'EYI_REC_Correspondence_Email_ID__c','EYI_Tax_Classification__c', 'EYI_REC_Vendor_Code__c', 'EYI_Address1__c','EYI_Address2__c', 'EYI_Address3__c', 'EYI_E_Invoicing_Applicable__c',
            'EYI_Is_MSME__c', 'EYI_MSME_Number__c', 'EYI_Country_Code_for_Secondary_Mobile__c','EYI_Country_Code_REC_Primary_Mobile__c', 'EYI_Country_Code_for_REC_Owner_Mobile__c',
            'EYI_REC_Owner_Telephone_Number__c', 'EYI_Primary_Telephone_Number__c','EYI_Secondary_Telephone_Number__c', 'EYI_REC_Correspondence_Last_Name__c',
            'EYI_Correspondence_City__c', 'EYI_Correspondence_Country__c','EYI_Correspondence_Region__c', 'EYI_Correspondence_Address_1__c','EYI_Correspondence_Address_2__c', 
            'EYI_Correspondence_Address_3__c','EYI_Correspondence_Pincode_Office__c', 'EYI_REC_Correspondence_Contact_Name__c','EYI_CP_Contact_1_Mobile_Number__c', 'EYI_First_Name_of_Contact_Person__c',
            'EYI_Last_Name_of_Contact_Person__c', 'EYI_CP_E_Mail_Address__c','EYI_Title__c', 'EYI_Correspondence_Title__c', 'EYI_State__c','EYI_Correspondence_State__c'
        };
    
        for (String field : fieldsToCheck) {
            if (oldRec.get(field) != newRec.get(field) && newRec.EYI_REC_Vendor_Code__c != null) {
                return true;
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static lwcMessage brokerVendorSync(String recAccId, String TestRun){
        lwcMessage lm = new lwcMessage();
        Boolean isPATCHOperation = false;
        Map<String, String> sfmapSAP = new Map<String, String>();
        
        if(recAccId!=null){ 
            List<EYI_REC__c> rec = [select id,EYI_Salutation__c,EYI_First_Name__c,EYI_Middle_Name__c,EYI_Last_Name__c,EYI_Gender__c,EYI_Marital_Status__c,
                                    EYI_Nationality__c,EYI_Occupation__c,EYI_Organization__c,EYI_Designation__c,EYI_Birth_Date__c,EYI_Anniversary_Date__c,
                                    EYI_Company_Code__c,EYI_Reconciliation_Account__c ,EYI_Payment_Terms__c,EYI_Minority_Indicator__c ,EYI_MSME__c,EYI_Title__c,
                                    EYI_GSTIN__c , EYI_Aadhar__c, EYI_Udyog_Adhar__c ,EYI_Company_Regisration__c ,EYI_ESIC_Number__c ,EYI_RERA_Number__c,EYI_CP_E_Mail_Address__c,
                                    EYI_City__r.Name , EYI_Country__c, EYI_Region__c ,EYI_Mobile__c,EYI_Alternate_Mobile__c,EYI_Correspondence_Address_3__c,EYI_Correspondence_Title__c,
                                    EYI_Type_Of_RERA_Registration__c,EYI_REC_Firm_Name__c,EYI_PAN_No__c,EYI_Pincode_Office__c,EYI_Correspondence_Pincode_Office__c,EYI_MSME_Number__c,
                                    EYI_REC_Owner_Mobile_Number__c,EYI_Email__c,EYI_Alternate_Email__c,EYI_REC_Correspondence_Mobile_Number__c,EYI_REC_Correspondence_Email_ID__c,
                                    EYI_Tax_Classification__c,EYI_REC_Vendor_Code__c,EYI_Address1__c,EYI_Address2__c,EYI_Address3__c,EYI_E_Invoicing_Applicable__c,EYI_Is_MSME__c,
                                    EYI_Country_Code_for_Secondary_Mobile__c,EYI_Country_Code_REC_Primary_Mobile__c ,EYI_Country_Code_for_REC_Owner_Mobile__c,EYI_Correspondence_Country__c,
                                    EYI_REC_Owner_Telephone_Number__c,EYI_Primary_Telephone_Number__c,EYI_Secondary_Telephone_Number__c,EYI_Correspondence_Region__c,EYI_Correspondence_State__c,
                                    EYI_REC_Correspondence_Last_Name__c,EYI_Correspondence_City__r.Name,EYI_Correspondence_Address_1__c,EYI_Correspondence_Address_2__c,EYI_State__c,
                                    EYI_REC_Correspondence_Contact_Name__c,EYI_CP_Contact_1_Mobile_Number__c,EYI_First_Name_of_Contact_Person__c,EYI_Last_Name_of_Contact_Person__c
                                    from EYI_REC__c where id=:recAccId limit 1];
            if(!rec.isEmpty()){
                try{
                List<SAP_SF_Field_Map__c> mapData = [select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c from SAP_SF_Field_Map__c ];
                if(!mapData.isEmpty()){
                    for(SAP_SF_Field_Map__c mp :mapData){
                        sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                        system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
                    } 
                }
                if(rec[0].EYI_Type_Of_RERA_Registration__c == null){
                lm.type = 'ERROR';
                lm.message  ='Type Of RERA Registration is mandatory can not be blank.';
                 return lm;
                 }  

                EYI_RECVendorCreationWrapper recVendor = new EYI_RECVendorCreationWrapper();
                
                EYI_RECVendorCreationWrapper.cls_ImVendor clvend = new EYI_RECVendorCreationWrapper.cls_ImVendor(); 
                clvend.TestRun = TestRun;
                if(sfmapSAP.containsKey('EYI_Type_Of_RERA_Registration__c'+'~'+rec[0].EYI_Type_Of_RERA_Registration__c)) 
                    clvend.type =sfmapSAP.get('EYI_Type_Of_RERA_Registration__c'+'~'+rec[0].EYI_Type_Of_RERA_Registration__c);// '1';//test
                if(rec[0].EYI_REC_Vendor_Code__c !=null){
                    clvend.Lifnr = rec[0].EYI_REC_Vendor_Code__c;
                    isPATCHOperation = true;
                }
                if(sfmapSAP.containsKey('EYI_Salutation__c'+'~'+rec[0].EYI_Salutation__c)) 
                    clvend.TitleMedi = sfmapSAP.get('EYI_Salutation__c'+'~'+rec[0].EYI_Salutation__c); // '0002';//rec[0].EYI_Salutation__c;
                if(rec[0].EYI_Middle_Name__c!=null) clvend.NameFirst= rec[0].EYI_First_Name__c+ rec[0].EYI_Middle_Name__c;
                else clvend.NameFirst= rec[0].EYI_First_Name__c;
                
                clvend.NameLast = (rec[0].EYI_Last_Name__c != null) ? rec[0].EYI_Last_Name__c : '';
                if(sfmapSAP.containsKey('EYI_Gender__c'+'~'+rec[0].EYI_Gender__c)) 
                    clvend.Sexid=sfmapSAP.get('EYI_Gender__c'+'~'+rec[0].EYI_Gender__c);//'2';//rec[0].EYI_Gender__c;sfmapSAP
                if(sfmapSAP.containsKey('EYI_Marital_Status__c'+'~'+rec[0].EYI_Marital_Status__c)) 
                    clvend.Marst=sfmapSAP.get('EYI_Marital_Status__c'+'~'+rec[0].EYI_Marital_Status__c);//'1';//rec[0].EYI_Marital_Status__c;
                if(rec[0].EYI_Middle_Name__c!=null) clvend.Sort1=rec[0].EYI_First_Name__c+ rec[0].EYI_Middle_Name__c;
                else clvend.Sort1=rec[0].EYI_First_Name__c;
                clvend.Sort2 = 'Broker';
                
                if(sfmapSAP.containsKey('EYI_Country__c'+'~'+rec[0].EYI_Country__c)) 
                    clvend.Natio=sfmapSAP.get('EYI_Country__c'+'~'+rec[0].EYI_Country__c);//'IN';//rec[0].EYI_Nationality__c;
                if(sfmapSAP.containsKey('EYI_Occupation__c'+'~'+rec[0].EYI_Occupation__c)) 
                    clvend.Jobgr=sfmapSAP.get('EYI_Occupation__c'+'~'+rec[0].EYI_Occupation__c);//'Z001';//rec[0].EYI_Occupation__c;
                clvend.Organization=(rec[0].EYI_REC_Firm_Name__c != null) ? rec[0].EYI_REC_Firm_Name__c : '';
                clvend.Designation=(rec[0].EYI_Designation__c!=null) ? rec[0].EYI_Designation__c:'';
                if(rec[0].EYI_Birth_Date__c!=null){
                    List<String> bday = String.valueOf(rec[0].EYI_Birth_Date__c).split('-');
                string birthdt;
                if(!bday.isEmpty()){
                    birthdt = bday[2] + '-' +bday[1] +'-' +bday[0];
                }
                clvend.Birthdt=birthdt;
                 }
                //clvend.Birthdt=String.valueOf(rec[0].EYI_Birth_Date__c);
                if(rec[0].EYI_Anniversary_Date__c!=null){
                List<String> dday = String.valueOf(rec[0].EYI_Anniversary_Date__c).split('-');
                string deathhdt;
                if(!dday.isEmpty()){
                    deathhdt = dday[2] + '-' +dday[1] +'-' +dday[0];
                }
                clvend.Deathdt=deathhdt;
                }
                List<EYI_Project_REC_Mapping__c> epRecMap = [select id ,EYI_Project__r.EYI_SAP_Company_Code__c	
                                                             from EYI_Project_REC_Mapping__c 
                                                             where EYI_REC_Account__c=:recAccId and EYI_Project__r.EYI_SAP_Company_Code__c!=null order by createddate asc limit 1];
                //clvend.Bukrs=(rec[0].EYI_Company_Code__c!=null ) ? rec[0].EYI_Company_Code__c : '';
                if(!epRecMap.isEmpty())
                    clvend.Bukrs=(epRecMap[0].EYI_Project__r.EYI_SAP_Company_Code__c!=null ) ? epRecMap[0].EYI_Project__r.EYI_SAP_Company_Code__c : '';
                //clvend.Akont=(rec[0].EYI_Reconciliation_Account__c!=null) ? rec[0].EYI_Reconciliation_Account__c : '';
                clvend.Zuawa = '';
                if(sfmapSAP.containsKey('EYI_Payment_Terms__c'+'~'+rec[0].EYI_Payment_Terms__c)) 
                    clvend.Zterm=sfmapSAP.get('EYI_Payment_Terms__c'+'~'+rec[0].EYI_Payment_Terms__c);
                //clvend.Zterm=rec[0].EYI_Payment_Terms__c;
                if(sfmapSAP.containsKey('EYI_Minority_Indicator__c'+'~'+rec[0].EYI_Minority_Indicator__c)) 
                     clvend.Mindk=sfmapSAP.get('EYI_Minority_Indicator__c'+'~'+rec[0].EYI_Minority_Indicator__c);//rec[0].EYI_Minority_Indicator__c;//NEED TO UPDATE KDS
                //clvendek.Cerdt=String.valueOf(rec[0].EYI_MSME__c);
                clvend.Gstin=(rec[0].EYI_GSTIN__c!=null) ? rec[0].EYI_GSTIN__c : '';
                clvend.J1ipanno = (rec[0].EYI_PAN_No__c!=null) ? rec[0].EYI_PAN_No__c : '' ;
                if(sfmapSAP.containsKey('EYI_Tax_Classification__c'+'~'+rec[0].EYI_Tax_Classification__c)) 
                    clvend.VenClass=sfmapSAP.get('EYI_Tax_Classification__c'+'~'+rec[0].EYI_Tax_Classification__c);
                if(rec[0].EYI_E_Invoicing_Applicable__c!=null && rec[0].EYI_E_Invoicing_Applicable__c== true) 
                    clvend.EInvoicing = 'X';
                if(rec[0].EYI_Is_MSME__c!=null && rec[0].EYI_Is_MSME__c== true) 
                    clvend.MsmeInd = 'X';
                if(rec[0].EYI_MSME_Number__c!=null) 
                    clvend.MsmeNo = rec[0].EYI_MSME_Number__c;
                
                
                
                
                List<ContentDocumentLink> cd =  [ SELECT ContentDocumentId,  ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
                                                 FROM ContentDocumentLink WHERE LinkedEntityId = :recAccId and ContentDocument.Title ='REC_Merged_PDF.pdf' order by ContentDocument.createddate desc limit 1];
                if(!cd.isEmpty()){
                    string ContentDocumentId = cd[0].ContentDocumentId;
                    List<ContentVersion> cv = [select Id, Title, VersionData, FileExtension , ContentDocumentId from ContentVersion where ContentDocumentId=:ContentDocumentId limit 1];
                    
                    if(!cv.isEmpty()) clvend.Pdf =  EncodingUtil.base64Encode(cv[0].VersionData);
                }
                
                List<EYI_RECVendorCreationWrapper.cls_Vendorid> venList = new List<EYI_RECVendorCreationWrapper.cls_Vendorid>();
                if(rec[0].EYI_Aadhar__c!=null){
                    EYI_RECVendorCreationWrapper.cls_Vendorid  ven1 =new EYI_RECVendorCreationWrapper.cls_Vendorid();
                    ven1.Idnumber = rec[0].EYI_Aadhar__c;
                    ven1.Idtype = 'ZINAAD';
                    venList.add(ven1);
                }
                if(rec[0].EYI_RERA_Number__c!=null)
                {
                    EYI_RECVendorCreationWrapper.cls_Vendorid  ven2 =new EYI_RECVendorCreationWrapper.cls_Vendorid();
                    ven2.Idnumber = rec[0].EYI_RERA_Number__c;
                    ven2.Idtype = 'ZINRER';
                    venList.add(ven2);
                }
                if(rec[0].EYI_MSME_Number__c!=null){
                    EYI_RECVendorCreationWrapper.cls_Vendorid  ven3 =new EYI_RECVendorCreationWrapper.cls_Vendorid();
                    ven3.Idnumber = rec[0].EYI_MSME_Number__c;
                    ven3.Idtype = 'ZINUAR';
                    venList.add(ven3);
                    
                }
                
                
                List<EYI_RECVendorCreationWrapper.cls_Addr> addrList = new List<EYI_RECVendorCreationWrapper.cls_Addr>();
                EYI_RECVendorCreationWrapper.cls_Addr addr = new EYI_RECVendorCreationWrapper.cls_Addr();
                addr.City1 = (rec[0].EYI_City__r.Name!=null) ? rec[0].EYI_City__r.Name : '';
                if(sfmapSAP.containsKey('EYI_Country__c'+'~'+rec[0].EYI_Country__c)) 
                    addr.Country =sfmapSAP.get('EYI_Country__c'+'~'+rec[0].EYI_Country__c);//'IN';// rec[0].EYI_Country__c;
                if(sfmapSAP.containsKey('EYI_Region__c'+'~'+rec[0].EYI_State__c)) 
                    addr.Region =sfmapSAP.get('EYI_Region__c'+'~'+rec[0].EYI_State__c);//='11';// rec[0].EYI_Region__c;
                addr.PostCode1 = (rec[0].EYI_Pincode_Office__c!=null) ?rec[0].EYI_Pincode_Office__c: '' ;
                //addr.Region = rec[0].EYI_Region__c;
                addr.Street = (rec[0].EYI_Address1__c!=null) ? rec[0].EYI_Address1__c : '';    
                addr.StrSuppl3 = (rec[0].EYI_Address2__c!=null) ? rec[0].EYI_Address2__c :'';    
                addr.Location = (rec[0].EYI_Address2__c!=null) ?rec[0].EYI_Address2__c : '' ;
                addr.AddrType = 'XXDFLT';//for broker default
                addrList.add(addr);
                
                EYI_RECVendorCreationWrapper.cls_Addr addrCP = new EYI_RECVendorCreationWrapper.cls_Addr();
                addrCP.City1 = (rec[0].EYI_Correspondence_City__r.Name!=null) ?rec[0].EYI_Correspondence_City__r.Name: '' ;
                if(sfmapSAP.containsKey('EYI_Country__c'+'~'+rec[0].EYI_Correspondence_Country__c	)) 
                    addrCP.Country =sfmapSAP.get('EYI_Country__c'+'~'+rec[0].EYI_Correspondence_Country__c);//'IN';// rec[0].EYI_Country__c;
                if(sfmapSAP.containsKey('EYI_Region__c'+'~'+rec[0].EYI_Correspondence_State__c)) 
                    addrCP.Region =sfmapSAP.get('EYI_Region__c'+'~'+rec[0].EYI_Correspondence_State__c);//='11';// rec[0].EYI_Region__c;
                addrCP.PostCode1 = (rec[0].EYI_Correspondence_Pincode_Office__c!=null) ? rec[0].EYI_Correspondence_Pincode_Office__c : '';
                //addrCP.Region = rec[0].EYI_Correspondence_Region__c;
                addrCP.Street = (rec[0].EYI_Correspondence_Address_1__c!=null) ?rec[0].EYI_Correspondence_Address_1__c : '';    
                addrCP.StrSuppl3 = (rec[0].EYI_Correspondence_Address_2__c!=null) ?rec[0].EYI_Correspondence_Address_2__c:'' ;    
                addrCP.Location = (rec[0].EYI_Correspondence_Address_3__c!=null) ?rec[0].EYI_Correspondence_Address_3__c:'' ;
                addrCP.AddrType = 'ZBPCOM';//for broker default
                addrList.add(addrCP);
        
                
                
                List<EYI_RECVendorCreationWrapper.cls_Comm> commList = new List<EYI_RECVendorCreationWrapper.cls_Comm>();
                if(rec[0].EYI_REC_Owner_Mobile_Number__c!=null){
                    EYI_RECVendorCreationWrapper.cls_Comm comm1 = new EYI_RECVendorCreationWrapper.cls_Comm();
                    comm1.TelNumber = (rec[0].EYI_REC_Owner_Telephone_Number__c!=null) ?rec[0].EYI_REC_Owner_Telephone_Number__c:'';
                    comm1.MobNumber = (rec[0].EYI_REC_Owner_Mobile_Number__c!=null) ?rec[0].EYI_REC_Owner_Mobile_Number__c : '';  
                    if(rec[0].EYI_Country_Code_for_REC_Owner_Mobile__c!=null && sfmapSAP.containsKey('EYI_Country__c'+'~'+rec[0].EYI_Country_Code_for_REC_Owner_Mobile__c)){
                       comm1.Country = sfmapSAP.get('EYI_Country__c'+'~'+rec[0].EYI_Country_Code_for_REC_Owner_Mobile__c);//'IN';// rec[0].EYI_Country__c;
                    }
                     
                    commList.add(comm1);
                }
                
                if(rec[0].EYI_Mobile__c!= null){
                    EYI_RECVendorCreationWrapper.cls_Comm comm2 = new EYI_RECVendorCreationWrapper.cls_Comm();
                    comm2.TelNumber = (rec[0].EYI_Primary_Telephone_Number__c!=null) ? rec[0].EYI_Primary_Telephone_Number__c : '';
                    comm2.MobNumber = (rec[0].EYI_Mobile__c!=null) ?rec[0].EYI_Mobile__c : '';  
                    comm2.SmtpAddr = (rec[0].EYI_Email__c!=null) ?rec[0].EYI_Email__c:'' ;
                    if(rec[0].EYI_Country_Code_REC_Primary_Mobile__c!=null && sfmapSAP.containsKey('EYI_Country__c'+'~'+rec[0].EYI_Country_Code_REC_Primary_Mobile__c)){
                       comm2.Country = sfmapSAP.get('EYI_Country__c'+'~'+rec[0].EYI_Country_Code_REC_Primary_Mobile__c);//'IN';// rec[0].EYI_Country__c;
                    }
                    commList.add(comm2);
                }
                
                if(rec[0].EYI_Alternate_Mobile__c!= null){
                    EYI_RECVendorCreationWrapper.cls_Comm comm3 = new EYI_RECVendorCreationWrapper.cls_Comm();
                    comm3.TelNumber = (rec[0].EYI_Secondary_Telephone_Number__c!=null) ?rec[0].EYI_Secondary_Telephone_Number__c : '';
                    comm3.MobNumber = (rec[0].EYI_Alternate_Mobile__c!=null) ?rec[0].EYI_Alternate_Mobile__c : '';  
                    comm3.SmtpAddr = (rec[0].EYI_Alternate_Email__c!=null) ? rec[0].EYI_Alternate_Email__c : '';
                    if(rec[0].EYI_Country_Code_for_Secondary_Mobile__c!=null && sfmapSAP.containsKey('EYI_Country__c'+'~'+rec[0].EYI_Country_Code_for_Secondary_Mobile__c)){
                       comm3.Country = sfmapSAP.get('EYI_Country__c'+'~'+rec[0].EYI_Country_Code_for_Secondary_Mobile__c);//'IN';// rec[0].EYI_Country__c;
                    }
                    commList.add(comm3);
                }
                /*if(rec[0].EYI_REC_Correspondence_Mobile_Number__c!= null){
                    EYI_RECVendorCreationWrapper.cls_Comm comm4 = new EYI_RECVendorCreationWrapper.cls_Comm();
                    comm4.MobNumber = rec[0].EYI_REC_Correspondence_Mobile_Number__c;  
                    comm4.SmtpAddr = rec[0].EYI_REC_Correspondence_Email_ID__c;
                    commList.add(comm4);
                }*/
                
                List<EYI_RECVendorCreationWrapper.ContactPerson> cpList = new List<EYI_RECVendorCreationWrapper.ContactPerson>();
                if(rec[0].EYI_REC_Correspondence_Mobile_Number__c!= null){
                  EYI_RECVendorCreationWrapper.ContactPerson cp1 = new EYI_RECVendorCreationWrapper.ContactPerson();
                  cp1.Firstname =(rec[0].EYI_REC_Correspondence_Contact_Name__c!=null) ?rec[0].EYI_REC_Correspondence_Contact_Name__c:'' ;
                  cp1.Lastname = (rec[0].EYI_REC_Correspondence_Last_Name__c!=null) ?rec[0].EYI_REC_Correspondence_Last_Name__c:''	 ;
                  cp1.Tel1Numbr = (rec[0].EYI_REC_Correspondence_Mobile_Number__c!=null) ?rec[0].EYI_REC_Correspondence_Mobile_Number__c: '' ;
                  cp1.Email = (rec[0].EYI_REC_Correspondence_Email_ID__c!=null) ?rec[0].EYI_REC_Correspondence_Email_ID__c:'';
                    if(sfmapSAP.containsKey('EYI_Salutation__c'+'~'+rec[0].EYI_Correspondence_Title__c)) 
                    cp1.TitleKey = sfmapSAP.get('EYI_Salutation__c'+'~'+rec[0].EYI_Correspondence_Title__c); // '0002';//rec[0].EYI_Salutation__c;
                     
                    cpList.add(cp1);
                }
                if(rec[0].EYI_CP_Contact_1_Mobile_Number__c!= null){
                  EYI_RECVendorCreationWrapper.ContactPerson cp2 = new EYI_RECVendorCreationWrapper.ContactPerson();
                  cp2.Firstname =(rec[0].EYI_First_Name_of_Contact_Person__c!=null) ?rec[0].EYI_First_Name_of_Contact_Person__c:'' ;
                  cp2.Lastname = (rec[0].EYI_Last_Name_of_Contact_Person__c!=null) ? rec[0].EYI_Last_Name_of_Contact_Person__c: '';
                  cp2.Tel1Numbr = (rec[0].EYI_CP_Contact_1_Mobile_Number__c!=null) ?rec[0].EYI_CP_Contact_1_Mobile_Number__c:''	;
                  cp2.Email = (rec[0].EYI_CP_E_Mail_Address__c!=null) ?rec[0].EYI_CP_E_Mail_Address__c:'' ;
                    if(sfmapSAP.containsKey('EYI_Salutation__c'+'~'+rec[0].EYI_Title__c)) 
                    cp2.TitleKey = sfmapSAP.get('EYI_Salutation__c'+'~'+rec[0].EYI_Title__c); // '0002';//rec[0].EYI_Salutation__c;
                    
                    cpList.add(cp2);
                }
                
                List<EYI_Bank_Details__c> bankDetails= [select id,EYI_Bank_Country__c,EYI_IFSC_Code__c,EYI_Deactivated__c,EYI_Bank_Account_Number__c,EYI_Account_Holder_Name__c,
                                                        EYI_International_Payment_Code__c, EYI_Name_of_Bank_Account__c from EYI_Bank_Details__c where EYI_REC_Account__c=:recAccId];
                List<EYI_RECVendorCreationWrapper.Bankdetail> bdList = new List<EYI_RECVendorCreationWrapper.Bankdetail>();
                if(!bankDetails.isEmpty()){
                   bdList = bankDetailsWrapper(bankDetails,sfmapSAP);
                    }
                clvend.Addr = addrList;
                clvend.Comm = commList;
                clvend.Vendorid = venList;
                clvend.ContactPerson = cpList;
                clvend.Bankdetail= bdList;
                recVendor.ImVendor = clvend;
                
               /* HttpRequest req = new HttpRequest();
                String jsonBody =JSON.serialize(recVendor);
                system.debug('jsonBody'+jsonBody);
                req.setBody(jsonBody);
                system.debug('isPATCHOperation-->'+isPATCHOperation);
                if(isPATCHOperation == true) req.setMethod('PATCH'); 
                else req.setMethod('POST'); 
                
                
                req.setEndpoint('callout:SAP_Integration');
                // Create an HTTP object to send the request
                Http http = new Http();
                HttpResponse res;
                
                //try {
                    // Send the HTTP request and get the response
                    res = http.send(req);*/
            String jsonBody =JSON.serialize(recVendor);
            String callType;
            if(isPATCHOperation == true) callType = 'PATCH'; 
            else callType = 'POST';
            HTTPResponse res = new HTTPResponse();
            res = EY_SAP_Gateway.brokerSync(jsonBody, callType);
                    // Check the response status code
                    if (res.getStatusCode() == 200) {
                        // Success: Return the response body
                        // return res.getBody();
                        system.debug('res.getBody()-->'+res.getBody());
                        // Deserialize the JSON into an untyped map
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        
                        // Extract the "n0:ZsdCreateVendorFromSfResponse" field from the map
                        Map<String, Object> vendorResponse = (Map<String, Object>) responseMap.get('n0:ZsdCreateVendorFromSfResponse');
                        
                        // Extract the "EReturn" field
                        Map<String, Object> eReturn = (Map<String, Object>) vendorResponse.get('EReturn');
                        String EBrokerVal = (string) vendorResponse.get('EBroker');
                        system.debug('EBroker-->'+EBrokerVal);
                        // Extract the "item" field from EReturn
                        // Map<String, List<Object>> item = (Map<String, List<Object>>) eReturn.get('item');
                        Object item =  eReturn.get('item');
                        system.debug('item-->'+item);
                        
                        // Now you can access individual fields within the "item" map
                        String type = '';
                        String messagDisp = '';
                        if (item instanceof List<Object>) {
                            List<Object> itemList = (List<Object>) item;
                            
                            for (Object obj : itemList) {
                                Map<String, Object> objitem = (Map<String, Object>) obj;
                                type = type + (String) objitem.get('Type');
                                messagDisp =messagDisp+ (String) objitem.get('Message');
                            }
                        }else if(item instanceof Map<String, Object>){
                            Map<String, Object> objitem = (Map<String, Object>) item;
                            type =  (String) objitem.get('Type');
                            messagDisp =(String) objitem.get('Message');
                        }
                        if(EBrokerVal!=null && type!=null && type== 'S' && isPATCHOperation ==false){
                            EYI_REC__c recUpd = new EYI_REC__c();
                            recUpd.Id =recAccId;
                            recUpd.EYI_REC_Vendor_Code__c = EBrokerVal;
                            recUpd.EYI_Registration_Status__c = 'Registered';
                            update recUpd;
                            system.debug('Updating Vendor code');
                            
                        }
                        lm.type =  type;
                        lm.message = messagDisp;
                        return lm;
                        
                    } else {
                        // Handle errors
                        // res.getStatusCode(),recAccId,jsonBody,JSON.serialize(response));
                        CalloutLog__c cl = new CalloutLog__c();
                        //cl.Name = 'SF SAP Broker Vendor Sync';
                        cl.HttpStatusCode__c = res.getStatusCode();
                        cl.Record_Id__c = recAccId;
                        //cl.RequestBody__c = jsonBody;
                        cl.ResponseBody__c = res.getBody();
                        insert cl;
                        
                        lm.type =  'E';
                        lm.message = res.getStatus();
                        return lm;
                        
                    }
                } catch (Exception e) {
                    // Handle exceptions
                    lwcMessage lm2 = new lwcMessage();
                    lm2.type =  'E';
                    lm2.message = e.getMessage();
                    return lm2;
                    
                }
            }
        }
        lm.type =  'E';
        lm.message = 'Record Id Missing';
        return lm;
        
    }
 
    public static List<EYI_RECVendorCreationWrapper.Bankdetail> bankDetailsWrapper(List<EYI_Bank_Details__c> bankDetails,Map<String, String> sfmapSAP){
      List<EYI_RECVendorCreationWrapper.Bankdetail> bdList = new List<EYI_RECVendorCreationWrapper.Bankdetail>();       
        Integer i = 1;
        for(EYI_Bank_Details__c bd : bankDetails){
            EYI_RECVendorCreationWrapper.Bankdetail bddetail = new EYI_RECVendorCreationWrapper.Bankdetail(); 
            string bankingcode;
            if(String.valueOf(i).length() == 1) bankingcode = '000' + String.valueOf(i);
            if(String.valueOf(i).length() == 2) bankingcode = '00' + String.valueOf(i);
            if(String.valueOf(i).length() == 3) bankingcode = '0' + String.valueOf(i);
            if(String.valueOf(i).length() == 4) bankingcode =  String.valueOf(i);
            
            bddetail.Bkvid =bankingcode;
            if(bd.EYI_Bank_Country__c!=null && sfmapSAP.containsKey('EYI_Country__c'+'~'+bd.EYI_Bank_Country__c)){
                       bddetail.BankCtry = sfmapSAP.get('EYI_Country__c'+'~'+bd.EYI_Bank_Country__c);//'IN';// rec[0].EYI_Country__c;
                    }
            
            bddetail.BankKey =(bd.EYI_IFSC_Code__c!=null) ?bd.EYI_IFSC_Code__c:'';
            bddetail.BankAcct =(bd.EYI_Bank_Account_Number__c!=null) ?bd.EYI_Bank_Account_Number__c:'';
            bddetail.Accountholder =(bd.EYI_Account_Holder_Name__c!=null) ?bd.EYI_Account_Holder_Name__c:'';
            bddetail.BankRef =(bd.EYI_International_Payment_Code__c!=null) ? bd.EYI_International_Payment_Code__c:'';
            bddetail.Bankaccountname =(bd.EYI_Name_of_Bank_Account__c!=null) ? bd.EYI_Name_of_Bank_Account__c : '';
            
            // Usage
            if (bd.EYI_Deactivated__c) {
                String formattedDate = formatDateYYYYMMDD(System.today());
                //bddetail.BANKDETAILVALIDFROM = formattedDate;
                //bddetail.BANKDETAILVALIDTO = formattedDate;
                bddetail.BankRef = 'D';
            }

            bdList.add(bddetail);
            i++;
                            
        }
        return bdList;
    }
    // Helper method to format Date as YYYYMMDD
    public static String formatDateYYYYMMDD(Date dateVal) {
        return String.valueOf(dateVal.year()) +
            (dateVal.month() < 10 ? '0' : '') + String.valueOf(dateVal.month()) +
            (dateVal.day() < 10 ? '0' : '') + String.valueOf(dateVal.day());
    }
    
    public class lwcMessage{
        
        @AuraEnabled  public string type;
        @AuraEnabled  public string message;
    }   
    
    public class sapResponse {
        public ZsdCreateVendorFromSfResponse n0_ZsdCreateVendorFromSfResponse;
    }
    
    public class ZsdCreateVendorFromSfResponse {
        public String EBroker;
        public EReturnWrapper EReturn;
    }
    
    public class EReturnWrapper {
        public List<ItemWrapper> item;
    }
    
    public class ItemWrapper {
        public String Type;
        public String Id;
        public String Numberval;
        public String Message;
        public String LogNo;
        public String LogMsgNo;
        public String MessageV1;
        public String MessageV2;
        public String MessageV3;
        public String MessageV4;
        public String Parameter;
        public String Row;
        public String Fieldval;
        public String Systemval;
    }
 
    @AuraEnabled
    public static checkData checkProjectMap(Id recordId){
        String message;
        checkData cd = new checkData();
        if(recordId!=null){
            List<EYI_Bank_Details__c> bankDetails= [select id,EYI_Bank_Country__c,EYI_IFSC_Code__c,EYI_Bank_Account_Number__c,EYI_Account_Holder_Name__c,
                                                        EYI_International_Payment_Code__c, EYI_Name_of_Bank_Account__c from EYI_Bank_Details__c where EYI_REC_Account__c=:recordId];
            if(bankDetails.isEmpty()){
              cd.bankMapMsg  ='Bank details are not available for this REC';
            } 
                
            
            List<EYI_Project_REC_Mapping__c> projectMap =[select id ,EYI_Project__r.EYI_SAP_Company_Code__c	from EYI_Project_REC_Mapping__c 
                                                             where EYI_REC_Account__c=:recordId order by createddate asc limit 1];
            if(projectMap.isEmpty()) {
                cd.type = 'ERROR';
                cd.projectMapMsg='Project is not mapped to REC';
                
            }
            else if(projectMap[0].EYI_Project__r.EYI_SAP_Company_Code__c ==null){
                cd.type = 'ERROR';
                cd.projectMapMsg='Company Code is blank for the Project Mapped to REC.';
             
            } 
             
        }
        return cd;
    }
    
    public class checkData{
        @AuraEnabled public String type;
        @AuraEnabled public String projectMapMsg;
        @AuraEnabled public String bankMapMsg;
    }
    
	
}