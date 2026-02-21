public class EYI_CreateInvoiceResource {
    
    @AuraEnabled
    public static lwcMessage validateInvoiceSync(String recInvoiceId){
        System.debug('recInvoiceId : '+recInvoiceId);
        lwcMessage lm = new lwcMessage();
        Boolean allFieldsPresent = true;
        String reqFieldError = System.Label.EYI_Cust_Sync_Req_field_Error;
        Boolean isPATCHOperation = false;
        Map<String, String> sfmapSAP = new Map<String, String>();
        
        
        EYI_Brokerage__c brokerageDetails= [SELECT Id, EYI_Opportunity__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c,EYI_Opportunity__r.EYI_Sales_Order_Number__c,EYI_REC_Account__c, EYI_REC_Account__r.EYI_REC_Vendor_Code__c,
                                            EYI_REC_Account__r.EYI_Payment_Terms__c,EYI_SAP_Material_Number__c,Invoice_Number__c,EYI_Invoice_Date__c,EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,EYI_Invoice_Amount__c,EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c
                                            FROM EYI_Brokerage__c 
                                            Where Id =:recInvoiceId];
        System.debug('brokerageDetails : '+brokerageDetails);
        System.debug('brokerageDetails.EYI_REC_Account__c : '+brokerageDetails.EYI_REC_Account__c);
        Id recId = (String)brokerageDetails.EYI_REC_Account__c;
        List<EYI_Bank_Details__c> recBankAccs = [ SELECT Id FROM EYI_Bank_Details__c Where EYI_REC_Account__c =:recId] ;
        List<ContentDocumentLink> cdList = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recInvoiceId
            AND ContentDocument.Title = 'REC_Merged_PDF.pdf'
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ];

        if (cdList.isEmpty()) {
            allFieldsPresent = false;
            lm.type = 'e';
            reqFieldError += 'REC_Merged_PDF.pdf not attached, ';
        }

        if(brokerageDetails != null){
            try{
                
                
                reqFieldError+=' Brokerage : ';
                
                
                if (cdList.isEmpty()) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'Please click on the download button to generate merge pdf, ';
                }

                if (String.isBlank(brokerageDetails.EYI_Opportunity__r.EYI_Sales_Order_Number__c)) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_Opportunity__r.EYI_Sales_Order_Number__c, ';
                }
                
                
                if (brokerageDetails.EYI_Invoice_Date__c == null) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_Invoice_Date__c, ';
                }
                
                if (String.isBlank(brokerageDetails.EYI_REC_Account__r.EYI_REC_Vendor_Code__c)) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_REC_Account__r.EYI_REC_Vendor_Code__c, ';
                }
                
                if(String.isBlank(brokerageDetails.EYI_Opportunity__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c)){
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_Opportunity__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c, ';
                }
                
                if (String.isBlank(brokerageDetails.EYI_REC_Account__r.EYI_Payment_Terms__c)) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_REC_Account__r.EYI_Payment_Terms__c, ';
                }
                
                if (String.isBlank(brokerageDetails.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c)) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c, ';
                }
                if (brokerageDetails.EYI_Invoice_Amount__c == null) { 
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_Invoice_Amount__c, ';
                }
                if (String.isBlank(brokerageDetails.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c)) {
                    allFieldsPresent = false;
                    lm.type = 'e';
                    reqFieldError += 'EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c, ';
                }
                
                if (allFieldsPresent && recBankAccs.isEmpty()) {
                    lm.type = 'e';
                    reqFieldError += 'No Bank Details are available on REC';
                }

                if (lm.type == 'e') {
                    reqFieldError = reqFieldError.trim();
                    if (reqFieldError.endsWith(',')) {
                        reqFieldError = reqFieldError.substring(0, reqFieldError.length() - 1);
                    }
                    lm.message = reqFieldError;
                    return lm;
                } else{
                    lm.type ='s';
                    lm.message = ''; 
                    return lm;
                }
            }Catch(Exception e){
                lm.type =  'e';
                lm.message = e.getMessage()+'---' +e.getLineNumber();
                system.debug('Error:: ' +e.getMessage());
                return lm;
            }
        }else{
            lm.type =  'e';
            lm.message = 'Record Id Missing';
            return lm;
        }
    }
    
    public class lwcMessage{
        @AuraEnabled  public string type;
        @AuraEnabled  public string message;
    }
    
    @AuraEnabled
    public static lwcMessage buildRequestBodyFromAccount(String recordId) {
        system.debug('recordId'+recordId);
        String reqBody;
        String apiResponse;
        lwcMessage lm = new lwcMessage();
        
        List<EYI_Brokerage__c> brokRec = [
            SELECT Id,
            EYI_SAP_PO_Number__c,
            EYI_REC_Account__r.EYI_REC_Vendor_Code__c,
            EYI_Opportunity__r.EYI_Sales_Order_Number__c,
            EYI_REC_Account__r.EYI_Payment_Terms__c,
            EYI_Invoice_Amount__c,
            EYI_Invoice_Date__c,
            EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
            Invoice_Number__c,
            EYI_Opportunity__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c,
            EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c
            FROM EYI_Brokerage__c  
            WHERE Id =:recordId
        ];
        
        InvoiceRequestWrapper wrapper = new InvoiceRequestWrapper();
        wrapper.InvoiceInput = new List<InvoiceRequestWrapper.InvoiceInput>();
        
        List<SAP_SF_Field_Map__c> mapData = [
            select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c 
            from SAP_SF_Field_Map__c
        ];
        
        Map<String, String> sfmapSAP = new Map<String, String>();
        if(!mapData.isEmpty()){
            for(SAP_SF_Field_Map__c mp :mapData){
                sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
            }
        }
        List<ContentDocumentLink> cd =  [ SELECT ContentDocumentId,  ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
                                         FROM ContentDocumentLink WHERE LinkedEntityId = :recordId and ContentDocument.Title ='REC_Merged_PDF.pdf' order by ContentDocument.createddate desc limit 1];   
        System.debug('cd : '+cd);
        for (EYI_Brokerage__c brok : brokRec) {
            InvoiceRequestWrapper.InvoiceInput req = new InvoiceRequestWrapper.InvoiceInput();
            
            req.PoNumber = String.isNotBlank(brok.EYI_SAP_PO_Number__c) ? brok.EYI_SAP_PO_Number__c : '';
            req.RecVendorCode = String.isNotBlank(brok.EYI_REC_Account__r.EYI_REC_Vendor_Code__c) ? brok.EYI_REC_Account__r.EYI_REC_Vendor_Code__c : '';
            req.SalesOrderNumber = String.isNotBlank(brok.EYI_Opportunity__r.EYI_Sales_Order_Number__c) ? brok.EYI_Opportunity__r.EYI_Sales_Order_Number__c : '';
            
            if(sfmapSAP.containsKey('EYI_Payment_Terms__c'+'~'+brok.EYI_REC_Account__r.EYI_Payment_Terms__c))
                req.PaymentTerms = sfmapSAP.get('EYI_Payment_Terms__c'+'~'+brok.EYI_REC_Account__r.EYI_Payment_Terms__c);
            
            req.CurrencyKey = 'INR';
            req.InvoiceAmount = String.isNotBlank(String.ValueOf(brok.EYI_Invoice_Amount__c)) ? String.ValueOf(brok.EYI_Invoice_Amount__c) : '';
            req.CompanyCode = String.isNotBlank(brok.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c) ? brok.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c : '';
            req.YourReference = String.isNotBlank(brok.Invoice_Number__c) ? brok.Invoice_Number__c : '';
            req.Plant = String.isNotBlank(brok.EYI_Opportunity__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c) ? brok.EYI_Opportunity__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c : '';
            
            if(brok.EYI_Invoice_Date__c!= null){
                List<String> dday = String.valueOf(brok.EYI_Invoice_Date__c).split('-');
                string deathhdt;
                if(!dday.isEmpty()){
                    deathhdt = dday[2] + '.' +dday[1] +'.' +dday[0];
                }
                req.PoDocDate = deathhdt != null ? deathhdt : '';
            }
            
            req.MaterialNumber = String.isNotBlank(brok.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c) ? brok.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c : '';
            req.PurchasingOrganization = '';
            req.PurchasingGroup = '';
            req.PurchasingDocumentType = '';
            req.OurReference = '';
            req.IncotermsLocation1 = '';
            req.IncotermsLocation2 = '';
            if(!cd.isEmpty()){
                System.debug('Inside Attachment');
                string ContentDocumentId = cd[0].ContentDocumentId;
                List<ContentVersion> cv = [select Id, Title, VersionData, FileExtension , ContentDocumentId from ContentVersion where ContentDocumentId=:ContentDocumentId limit 1];
                System.debug('cv : '+cv);
                if(!cv.isEmpty()) req.Attachment =  EncodingUtil.base64Encode(cv[0].VersionData);
            }
            System.debug('req.Attachment : '+req.Attachment);
            //req.Attachment = '';
            req.CustomField2 = '';
            req.CustomField3 = '';
            req.InvoiceRemarks = '';
            wrapper.InvoiceInput.add(req);
        }
        
        System.debug('reqBody2-->' +wrapper );    
        reqBody = JSON.serializePretty(wrapper);
        System.debug('reqBody-->' + JSON.serialize(reqBody ));        
        
        try{
            HTTPResponse res = EY_SAP_Gateway.invoiceCreation(reqBody);
            apiResponse = res.getBody();
            
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(apiResponse);
            Map<String, Object> rootMap = (Map<String, Object>) responseMap.get('n0:ZSD_REC_INVOICE_FROM_SFResponse');
            String exOutputJson = JSON.serialize(rootMap.get('EX_OUTPUT'));   
            EX_OUTPUT exOutput = (EX_OUTPUT) JSON.deserialize(exOutputJson, EX_OUTPUT.class);
            Item item = exOutput.item;

            if (item.TYPE == 'S') {
                EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
                    Id = recordId,
                    EYI_SAP_PO_Number__c = item.EBELN,
                    EYI_Invoice_Status__c = 'SUBMITTED',
                    EYI_SAP_Bill_Desk_Number__c = item.TRACK_ID
                );
                update brokerage;
                lm.type ='S';
                lm.message = 'Purchase Order '+ item.EBELN + ' Created Successfully.';
                
            } else if (item.TYPE == 'E') {
                lm.type ='e';
                lm.message = item.MESSAGE;  
            }
            return lm; 
        }catch(Exception e){
            if (e.getMessage().contains('StatusCode=500')) {
                lm.type ='e';
                lm.message = e.getMessage();
            }
            return lm;
        }
    }
    
    public class SAPResponseWrapper {
        public EX_OUTPUT EX_OUTPUT;
    }
    public class EX_OUTPUT {
        public Item item;
    }
    public class Item {
        public String EBELN;
        public String TRACK_ID;
        public String MESSAGE;
        public String TYPE;
    }
}