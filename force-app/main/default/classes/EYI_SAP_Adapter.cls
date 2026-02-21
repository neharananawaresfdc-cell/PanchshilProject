/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-27-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EYI_SAP_Adapter {
    
    public static String createReceiptBody(EYI_Payment_Receipt__c paymentReceipt, List<Map<String, Object>> updatedRecords, Map<String, Object> formData) {
        EYI_PaymentReceiptWrapper data = new EYI_PaymentReceiptWrapper();
        System.debug('updatedRecords map-->' + updatedRecords);
        System.debug('formData map-->' + formData);
        System.debug('customer number-->' + formData.get('customerNumber'));
        System.debug('companyCode-->' + formData.get('companyCode'));
        system.debug('paymentReceipt --> '+ paymentReceipt);
        List<EYI_Booking__c> booking = new List<EYI_Booking__c>();
        Id projectId ;
        Id towerId;
        opportunity opp = new Opportunity();
        
        //String gstClassification = paymentReceipt?.EYI_Opportunity__r.EYI_Inventory__r.EYI_GST_Tax_Classification__c ;
        Date instrumentDate;
        if(String.valueOf(formData.get('TransactionType')) != 'TDS'){
            if (paymentReceipt != null && paymentReceipt.EYI_Instrument_Date__c != null) {
            instrumentDate = paymentReceipt.EYI_Instrument_Date__c;
            } else if (formData != null && formData.containsKey('InstrumentDate') && formData.get('InstrumentDate') != null) {
                instrumentDate = Date.valueOf(String.valueOf(formData.get('InstrumentDate')));
            }
        }else{
            if (paymentReceipt != null && paymentReceipt.EYI_Channel_Date__c != null) {
            instrumentDate = paymentReceipt.EYI_Channel_Date__c;
            } else if (formData != null && formData.containsKey('ChannelDate') && formData.get('ChannelDate') != null) {
                instrumentDate = Date.valueOf(String.valueOf(formData.get('ChannelDate')));
            }
        }

        String formattedDate = '';
        if (instrumentDate != null) {
            formattedDate = String.join(new List<String>{
                (instrumentDate.day() < 10 ? '0' : '') + instrumentDate.day(),
                    (instrumentDate.month() < 10 ? '0' : '') + instrumentDate.month(),
                    String.valueOf(instrumentDate.year())
                    }, '.');
        }
        
        data.paymentAdvice = new EYI_PaymentReceiptWrapper.PaymentAdvice();
        
        // Transaction Type
        String transactionType;
        if (paymentReceipt != null && paymentReceipt.EYI_Transaction_Type__c != null) {
            transactionType = paymentReceipt.EYI_Transaction_Type__c;
        } else if (formData != null && formData.containsKey('TransactionType')) {
            transactionType = String.valueOf(formData.get('TransactionType'));
        }
        data.paymentAdvice.TransactionType = getSF_FieldMapping('EYI_Transaction_Type__c', transactionType);
        
        // Company Code
        String companyCode = (paymentReceipt != null && paymentReceipt.EYI_Opportunity__r?.EYI_Project_Enquired__r?.EYI_SAP_Company_Code__c != null)
            ? paymentReceipt.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c
            : (formData != null && formData.containsKey('companyCode') ? String.valueOf(formData.get('companyCode')) : '');
                
                // SAP Customer Number
                String sapCustomerNum = (paymentReceipt != null && paymentReceipt.EYI_Opportunity__r?.EYI_SAP_Customer_Number__c != null)
                ? paymentReceipt.EYI_Opportunity__r.EYI_SAP_Customer_Number__c
                : (updatedRecords != null && !updatedRecords.isEmpty() && updatedRecords.get(0).containsKey('customerNumber') 
                   ? String.valueOf(updatedRecords.get(0).get('customerNumber')) 
                   : '');
                       
        // If Company Code or SAP Customer Number is still empty, fetch from Opportunity using OpportunityId in formData
        
        if (formData.containsKey('OpportunityId') && formData.get('OpportunityId') != null) {
            String opportunityId = String.valueOf(formData.get('OpportunityId'));
            
            opp = [SELECT EYI_Project_Enquired__r.EYI_SAP_Company_Code__c, EYI_Inventory__r.EYI_Project__c, EYI_Inventory__r.EYI_Tower__c, EYI_Inventory__c, EYI_Inventory__r.EYI_Inventory_Number__c, EYI_SAP_Customer_Number__c,EYI_Inventory__r.Name,
                   EYI_Inventory__r.EYI_SAP_Profit_Center__c,EYI_Inventory__r.EYI_OC_Received_Date__c, EYI_Inventory__r.EYI_GST_Tax_Classification__c,EYI_SalesOrder_Number__c
                   FROM Opportunity 
                   WHERE Id = :opportunityId 
                   LIMIT 1];

            projectId = opp.EYI_Inventory__r.EYI_Project__c;
            towerId = opp.EYI_Inventory__r.EYI_Tower__c;

            //Added by Rishikesh to update the tax code logic 
            booking = [Select Id, EYI_Booking_Date__c, EYI_Actual_Booking_Date__c, EYI_SAP_Sales_Order_Number__c From EYI_Booking__c Where EYI_Opportunity_Name__c =:opportunityId LIMIT 1];
            system.debug('opp ==> '+opp);
            if (opp != null) {
                if (String.isEmpty(companyCode) && opp.EYI_Project_Enquired__r != null) {
                    companyCode = opp.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
                }
                if (String.isEmpty(sapCustomerNum)) {
                    sapCustomerNum = opp.EYI_SAP_Customer_Number__c;
                }
            }
        }

        //data.paymentAdvice.Reference = opp.EYI_SalesOrder_Number__c;
        data.PaymentAdvice.CompanyCode = companyCode;
        data.PaymentAdvice.SapCustomerNumber = sapCustomerNum;
        data.PaymentAdvice.PaymentDate = formattedDate;
        data.PaymentAdvice.CurrencyKey = 'INR';
        data.PaymentAdvice.REMARKS = paymentReceipt?.EYI_Remarks__c != null ? paymentReceipt?.EYI_Remarks__c:'';
        if (paymentReceipt != null && paymentReceipt.EYI_Instrument_Date__c != null) {            
            data.PaymentAdvice.PaymentDocumentNumber = paymentReceipt.EYI_Mode_of_Payment__c;
        }
        System.debug('opp.EYI_Inventory__r.EYI_Inventory_Number__c : '+opp.EYI_Inventory__r.EYI_Inventory_Number__c);
        //data.paymentAdvice.MaterialCode = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_Inventory_Number__c : paymentReceipt?.EYI_Opportunity__r.EYI_Inventory__r?.EYI_Inventory_Number__c != null ? paymentReceipt.EYI_Opportunity__r.EYI_Inventory__r?.EYI_Inventory_Number__c : '';
        //data.paymentAdvice.MaterialCode = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_Inventory_Number__c : '';
        
        // Payment Amount
        Decimal paymentAmount = (paymentReceipt != null && paymentReceipt.EYI_Amount__c != null)
            ? paymentReceipt.EYI_Amount__c
            : (formData != null && formData.containsKey('PaymentAmount') ? Decimal.valueOf(String.valueOf(formData.get('PaymentAmount'))) : null);
                data.PaymentAdvice.PaymentAmount = paymentAmount != null ? String.valueOf(paymentAmount) : '';
        
        // Bank Name
        String bankName = (paymentReceipt != null && paymentReceipt.EYI_Bank_Name__c != null)
            ? paymentReceipt.EYI_Bank_Name__c
            : (formData != null && formData.containsKey('BankName') ? String.valueOf(formData.get('BankName')) : '');
                data.PaymentAdvice.CustomerBankName = bankName;
        data.paymentAdvice.CustomHeaderField1 = (formData != null && formData.containsKey('ReceivedFrom') ? String.valueOf(formData.get('ReceivedFrom')) : '');
        
        // Instrument Number
        String instrumentNumber = (paymentReceipt != null && paymentReceipt.EYI_Instrument_Number__c != null)
            ? String.valueOf(paymentReceipt.EYI_Instrument_Number__c)
            : (formData != null && formData.containsKey('InstrumentNumber') ? String.valueOf(formData.get('InstrumentNumber')) : '');
               System.debug('Form Data Instrument Num : '+String.valueOf(formData.get('InstrumentNumber')));
        		//System.debug('Instr Num : '+paymentReceipt.EYI_Instrument_Number__c);
                System.debug('instrumentNumber : '+instrumentNumber);
                if(instrumentNumber != ''){
                    data.PaymentAdvice.BankReferenceNumber = instrumentNumber.toUpperCase();
                }
                

        String channelNumber = (paymentReceipt != null && paymentReceipt.EYI_Channel_Number__c != null)
            ? String.valueOf(paymentReceipt.EYI_Channel_Number__c)
            : (formData != null && formData.containsKey('ChannelNumber') ? String.valueOf(formData.get('ChannelNumber')) : '');
               System.debug('Form Data Instrument Num : '+String.valueOf(formData.get('InstrumentNumber')));
        		//System.debug('Instr Num : '+paymentReceipt.EYI_Instrument_Number__c);
                System.debug('channelNumber : '+channelNumber);
                if(channelNumber != ''){
                    data.PaymentAdvice.BankReferenceNumber = channelNumber.toUpperCase();
                }
        
        // DD Number
        //if(paymentReceipt!= null){
            //if(paymentReceipt.EYI_Check_number__c != null){
               String dd_ChequeNumber = (paymentReceipt != null && paymentReceipt.EYI_Channel_Number__c != null)
            ? String.valueOf(paymentReceipt.EYI_Channel_Number__c)
            : (formData != null && formData.containsKey('ChequeDdNumber') ? String.valueOf(formData.get('ChequeDdNumber')) : '');
                if(dd_ChequeNumber != ''){
                   data.PaymentAdvice.BankReferenceNumber = dd_ChequeNumber;   
                }
                
           // }  
       // } 
        data.paymentAdvice.REMARKS = String.valueOf(formData.get('Remarks'));
        data.PaymentAdvice.PaymentDocumentNumber = String.valueOf(formData.get('paymentMode'));
        data.PaymentAdvice.PaymentAdviceHoldIndicator = 'Y';
        data.paymentAdvice.LineItems = new List<EYI_PaymentReceiptWrapper.LineItem>();

        if(String.valueOf(formData.get('TransactionType')) != 'Demand'){
            System.debug('Inside Token and Advance');
            EYI_PaymentReceiptWrapper.LineItem li = new EYI_PaymentReceiptWrapper.LineItem();
            system.debug('opp.EYI_SalesOrder_Number__c'+ opp.EYI_SalesOrder_Number__c);

            if (formData.containsKey('OpportunityId') && !booking.isEmpty() && booking[0].EYI_SAP_Sales_Order_Number__c != null){
                li.Reference = String.valueOf(booking[0].EYI_SAP_Sales_Order_Number__c);
            }       

            //li.Reference = opp.EYI_SalesOrder_Number__c;
            if(String.valueOf(formData.get('TransactionType')) == 'Advance'){
                li.Reference3 = 'ADV';
            }else if(String.valueOf(formData.get('TransactionType')) == 'Token'){
                li.Reference3 = 'TOK';
            }else if(String.valueOf(formData.get('TransactionType')) == 'TDS'){
                li.Reference3 = 'TDS';
                li.TaxCode = '';
            }
            //li.MaterialCode = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_Inventory_Number__c : paymentReceipt?.EYI_Opportunity__r.EYI_Inventory__r?.EYI_Inventory_Number__c != null ? paymentReceipt.EYI_Opportunity__r.EYI_Inventory__r?.EYI_Inventory_Number__c : '';
            if(li.Reference2 == null){
                li.Reference2 = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_Inventory_Number__c : paymentReceipt?.EYI_Opportunity__r.EYI_Inventory__r?.EYI_Inventory_Number__c != null ? paymentReceipt.EYI_Opportunity__r.EYI_Inventory__r?.EYI_Inventory_Number__c : '';  
            }
            //li.Reference = SO Number;
            li.PartialPaymentAmount = String.valueOf(formData.get('PaymentAmount'));
            li.DocumentInvoiceDate = formattedDate;
            li.ProfitCenter = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_SAP_Profit_Center__c : '';
            
            List<Project_Charges__c> projectCharge = [Select Id, EYI_GST_Percentage__c, EYI_GST_Applicable_on_this_charge__c, EYI_Active__c 
                                                From Project_Charges__c Where EYI_Project__c = : projectId 
                                                AND EYI_Active__c = true AND EYI_GST_Applicable_on_this_charge__c = true 
                                                AND EYI_GST_Percentage__c != '' AND  Name = 'TAX' LIMIT 1];
            List<Project_Charges__c> towerCharge = [Select Id, EYI_GST_Percentage__c, EYI_GST_Applicable_on_this_charge__c, EYI_Active__c 
                                                    From Project_Charges__c Where EYI_Tower__c = : towerId 
                                                    AND EYI_Active__c = true AND EYI_GST_Applicable_on_this_charge__c = true 
                                                    AND EYI_GST_Percentage__c != '' AND  Name = 'TAX' LIMIT 1];
               
            if (String.valueOf(formData.get('TransactionType')) != 'TDS' && formData.containsKey('OpportunityId') &&  opp.EYI_Inventory__r != null &&  opp.EYI_Inventory__r.EYI_OC_Received_Date__c != null) {
                if (opp.EYI_Inventory__r.EYI_OC_Received_Date__c != null) {
                    li.TaxCode = 'A1';
                } else {
                    // Set TaxCode based on towerCharge or projectCharge
                    if (towerCharge.size() >0 || projectCharge.size()>0) {
                        String gstPercentage = towerCharge.size() >0 ? towerCharge[0].EYI_GST_Percentage__c : projectCharge[0].EYI_GST_Percentage__c;
                        li.TaxCode = (gstPercentage == 'GST-5') ? 'F1' :(gstPercentage == 'GST-12') ? 'F2' :(gstPercentage == 'GST-18') ? 'F3' :  'A0'; // or some default value if needed
                    }else{
                        li.TaxCode = 'A0';
                    }
                }
            } else {
                // Handle the case where OpportunityId is not present or booking is empty
                if (towerCharge.size() >0 || projectCharge.size()>0) {
                    String gstPercentage = towerCharge.size() >0 ? towerCharge[0].EYI_GST_Percentage__c : projectCharge[0].EYI_GST_Percentage__c;
                    li.TaxCode = (gstPercentage == 'GST-5') ? 'F1' : (gstPercentage == 'GST-12') ? 'F2' : (gstPercentage == 'GST-18') ? 'F3' : 'A0'; // or some default value if needed
                }else{
                    li.TaxCode = 'A0';
                }
            }

            data.paymentAdvice.LineItems.add(li);
            System.debug('li : '+li);
        }
        
        if (updatedRecords != null && !updatedRecords.isEmpty()) {
            for (Map<String, Object> record : updatedRecords) {
                if (record.containsKey('inputValue') && record.get('inputValue') != null && String.valueOf(record.get('inputValue')).trim() != '' 
                    && record.containsKey('fiDocumentNo') && String.valueOf(formData.get('TransactionType')) == 'Demand') {
                        EYI_PaymentReceiptWrapper.LineItem li = new EYI_PaymentReceiptWrapper.LineItem();
                        system.debug('inside line item'+ record);
                        if(li.Reference3 == null){
                          li.Reference3 = String.valueOf(record.get('paymentBifurcation'));  
                        }
                        //li.Reference = opp.EYI_SalesOrder_Number__c;
                        //li.CustomerReference = formData.containsKey('customerNumber') ? String.valueOf(formData.get('customerNumber')) : '';
                        li.CustomerReference = record.containsKey('REF_DOC_NO') ? String.valueOf(record.get('REF_DOC_NO')) : '';
                        li.DocumentInvoiceDate = formattedDate;
                        li.PartialPaymentAmount = String.valueOf(record.get('inputValue'));

                        if (formData.containsKey('OpportunityId') && !booking.isEmpty() &&booking[0].EYI_Actual_Booking_Date__c != null && opp.EYI_Inventory__r != null && opp.EYI_Inventory__r.EYI_OC_Received_Date__c != null) {
                            if (booking[0].EYI_Actual_Booking_Date__c > opp.EYI_Inventory__r.EYI_OC_Received_Date__c) {
                                li.TaxCode = 'A1';
                            } else {
                                li.TaxCode = 'A0';
                            }
                        }else{
                            li.TaxCode = 'A0';
                        }

                        //String outstanding = String.valueOf((Decimal)record.get('outstanding') - (Decimal)record.get('inputValue'));
                        li.DocumentYear = record.containsKey('fiscalYear') ? String.valueOf(record.get('fiscalYear')) : '';
                        li.BillingDocumentNumber = record.containsKey('billingDoc') ? String.valueOf(record.get('billingDoc')) : '';
                        //li.ProfitCenter = record.containsKey('profitCenter') ? String.valueOf(record.get('profitCenter')) : '';
                        if (record.containsKey('profitCenter') && record.get('profitCenter') != null) {
                            li.ProfitCenter = String.valueOf(record.get('profitCenter'));
                        } else {
                            li.ProfitCenter = ''; // or a default value if required
                        }

                        if(li.Reference2 == null){
                            li.Reference2 = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_Inventory_Number__c : '';  
                        }
                        if (formData.containsKey('OpportunityId') && !booking.isEmpty() && booking[0].EYI_SAP_Sales_Order_Number__c != null){
                            li.Reference = String.valueOf(booking[0].EYI_SAP_Sales_Order_Number__c);
                        }
                        if(String.valueOf(record.get('paymentBifurcation')) != 'ADV'){
                            Decimal outstandingVal = Decimal.valueOf((String)record.get('outstanding'));
                            Decimal inputVal = Decimal.valueOf((String)record.get('inputValue'));
                            String outstanding = String.valueOf(outstandingVal - inputVal);
                            //li.CustomItemField1 = String.valueOf(record.get('outstanding')) != String.valueOf(record.get('amountLocalCurrency')) ? String.valueOf(record.get('outstanding')) : outstanding; 
                            li.CustomItemField1 = outstanding; 
                            li.CustomItemField2 = '';
                            li.CustomItemField3 = '';
                            if(li.Reference1 == null){
                                li.Reference1 = String.valueOf(record.get('milestoneNo'));  
                            }
                            
                            li.profitCenter = formData.containsKey('OpportunityId') ? opp.EYI_Inventory__r.EYI_SAP_Profit_Center__c : '';
                            // Check if fiDocumentNo contains 'Floating'
                            String fiDocumentNo = String.valueOf(record.get('fiDocumentNo'));
                            li.AccountDocumentNumber = (fiDocumentNo != null && fiDocumentNo.contains('Floating')) ? null : fiDocumentNo;
                            li.CustRefLineItem = String.valueOf(record.get('lineItemNo'));
                        }
                        data.paymentAdvice.LineItems.add(li);
                    }
            }
        }
        
        String jsonBody = JSON.serialize(data);
        System.debug('jsonBody : '+jsonBody);
        Integer chunkSize = 200;
        for (Integer i = 0; i < jsonBody.length(); i += chunkSize) {
            System.debug(jsonBody.substring(i, Math.min(i + chunkSize, jsonBody.length())));
        }
        
        return jsonBody;
    } 
    
    public static String getSF_FieldMapping(String fieldName, String sfValue) {
        String sapValue = '';
        try {
            SAP_SF_Field_Data_Map__mdt fieldMap = [
                SELECT Id, SAP_Value__c 
                FROM SAP_SF_Field_Data_Map__mdt 
                WHERE SF_Field_Name__c = :fieldName AND SF_Value__c = :sfValue 
                LIMIT 1
            ];
            sapValue = fieldMap.SAP_Value__c;
        } catch (Exception e) {
            System.debug('Exception :::' + e);
        }
        return sapValue;
    }
    
    public class GetSapDocument {
        public String DocumentNo { get; set; }
        public String CompanyCode { get; set; }
        public String AccountingDocNo { get; set; }
        public String FiscalYear { get; set; }
        public String DocumentType { get; set; }
    }
    
    public static String createSOA_PDFBody(String requestJsonString) {
        RequestWrapper parsedData = (RequestWrapper) JSON.deserialize(requestJsonString, RequestWrapper.class);
        return JSON.serialize(parsedData);
    }
    
    public static String createLineItemsBody(Id opportunityId) {
        Opportunity opp = [
            SELECT EYI_Project_Enquired__r.EYI_SAP_Company_Code__c, EYI_SAP_Customer_Number__c
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];
        
        Date today = Date.today();
        String keyDate = 
            (today.day() < 10 ? '0' + today.day() : String.valueOf(today.day())) + '.' +
            (today.month() < 10 ? '0' + today.month() : String.valueOf(today.month())) + '.' +
            today.year();
        
        Map<String, Object> customerOpenLineItem = new Map<String, Object>();
        customerOpenLineItem.put('KeyDate', keyDate);
        
        Map<String, Object> companyCodeEntry = new Map<String, Object>{
            'SIGN' => 'I',
                'OPTION' => 'EQ',
                'LOW' => opp.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                'HIGH' => ''
                };
                    
                    customerOpenLineItem.put('CompanyCode', new Map<String, Object>{
                        'item' => new List<Object>{companyCodeEntry}
                    });
        
        Map<String, Object> customerNoEntry = new Map<String, Object>{
            'SIGN' => 'I',
                'OPTION' => 'EQ',
                'LOW' => opp.EYI_SAP_Customer_Number__c,
                'HIGH' => ''
                };
                    
                    customerOpenLineItem.put('CustomerNo', new Map<String, Object>{
                        'item' => new List<Object>{customerNoEntry}
                    });
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('CustomerOpenLineItem', customerOpenLineItem);
        
        String jsonBody = JSON.serialize(requestBody);
        System.debug('Generated Request Body: ' + jsonBody);
        
        return jsonBody;
    }
    
    public static String createDemandBody(Map<Id,Date> demandDateMap, List<EYI_Demand__c> demandList, String action){
        EYI_DemandRaiseRequestWrapper data = new EYI_DemandRaiseRequestWrapper();
        EYI_DemandRaiseRequestWrapper requestWrapper = new EYI_DemandRaiseRequestWrapper();
        requestWrapper.DemandRaiseAPI = new List<EYI_DemandRaiseRequestWrapper.DemandRaiseAPI>();
        
        List<SAP_SF_Field_Map__c> mapData = [select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c from SAP_SF_Field_Map__c ];
        Map<String, String> sfmapSAP = new Map<String, String>();
        Integer counter = 10;
        
        if(!mapData.isEmpty()){
            for(SAP_SF_Field_Map__c mp :mapData){
                sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                //system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
            } 
        }
        
        for(EYI_Demand__c demand :demandList){
            // Create the inner wrapper and map the data
            EYI_DemandRaiseRequestWrapper.DemandRaiseAPI record = new EYI_DemandRaiseRequestWrapper.DemandRaiseAPI();
            record.TypeOfAction = action; 
            record.CustomerNo = demand.EYI_Opportunity__r?.EYI_SAP_Customer_Number__c != null? demand.EYI_Opportunity__r.EYI_SAP_Customer_Number__c : '';
            record.SalesOrderNo = demand.EYI_Booking__r?.EYI_SAP_Sales_Order_Number__c!=null?demand.EYI_Booking__r.EYI_SAP_Sales_Order_Number__c:'';
            record.SalesOrg = demand.EYI_Project__r.EYI_SAP_Salesorg__c; // Example value
            if(demand.EYI_IsOtherChargeDemand__c == 'Yes'){
                record.UnitCode = demand.EYI_Usage_Description__c != null ?  demand.EYI_Usage_Description__c : ''; 
            }else{
                record.UnitCode = demand.EYI_Opportunity__r?.EYI_Inventory__r.EYI_Inventory_Number__c!=null?demand.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c:'';
            }
            //record.UnitCode = demand.EYI_Opportunity__r?.EYI_Inventory__r.EYI_Inventory_Number__c!=null?demand.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c:'';
            record.SalesOrderLineItemNo = counter; // Example value
            //counter += 10;
            
            if(demand.EYI_Actual_Date__c!= null){
                //customer.BIRTHDT = String.valueof) ;
                List<String> dday;
                if(action == 'BLOCK' && demandDateMap != null && demandDateMap.size()>0){
                    Date billingDate = demandDateMap.get(demand.id);
                    dday = String.valueOf(billingDate).split('-');
                }else{
                    dday = String.valueOf(demand.EYI_Actual_Date__c).split('-');
                }
                //List<String> dday = String.valueOf(demand.EYI_Actual_Date__c).split('-');
                system.debug('dday  ===='+dday);
                string deathhdt;
                if(!dday.isEmpty()){
                    deathhdt = dday[2] + '.' +dday[1] +'.' +dday[0];
                }
                record.BillingDate=deathhdt;
            }
            //record.BillingDate = (demand.EYI_Actual_Date__c != null )?String.valueOf(demand.EYI_Actual_Date__c):String.valueOf(demand.EYI_Billing_Date__c);
            record.TotalDemandAmount = (demand.EYI_Amount_to_be_paid__c != null )?String.valueOf(demand.EYI_Amount_to_be_paid__c):'';
            record.TaxValue = ''; // Example value
            record.PrincipalValue = ''; // Example value
            record.OtherCharges = ''; // Example value
            record.DateType = ''; // Example value
            record.Usage = demand.EYI_Usage__c != null ?String.valueOf(demand.EYI_Usage__c):'';
            record.UsageDescription = demand.EYI_Usage_Description__c != null ?String.valueOf(demand.EYI_Usage_Description__c):'';
            record.CurrencyKey = 'INR'; // Example value
            record.MilestoneNumber = demand.EYI_SAP_Milestone_Code__c != null ?String.valueOf(demand.EYI_SAP_Milestone_Code__c):'';
            record.AdditionalParameter1 = ''; // Example value
            record.AdditionalParameter2 = ''; // Example value
            record.AdditionalParameter3 = ''; // Example value
            
            // billing doc no only passed for cancellation.
            if(action == 'SENT'){
                record.SapBillingDocNo = demand.EYI_SAP_Demand_Number__c!= null ?String.valueOf(demand.EYI_SAP_Demand_Number__c):''; // Example value 
            }else{
                record.SapBillingDocNo = '';
            }
            
            if(demand.EYI_Opportunity__r.EYI_Distribution_Channel__c  != null){
                if(sfmapSAP.containsKey('EYI_Distribution_Channel__c'+'~'+demand.EYI_Opportunity__r.EYI_Distribution_Channel__c  )) 
                    record.DistributionChannel =sfmapSAP.get('EYI_Distribution_Channel__c'+'~'+demand.EYI_Opportunity__r.EYI_Distribution_Channel__c  );// '1';//test
            }
            
            // Add record to the list
            requestWrapper.DemandRaiseAPI.add(record);
        }
        // Convert to JSON request body
        String requestBody = JSON.serialize(requestWrapper);
        System.debug('Request Body: ' + requestBody);
        
        return requestBody;
        
    }
    public class RequestWrapper {
        public GetSapDocument GetSapDocument { get; set; }
    }
}