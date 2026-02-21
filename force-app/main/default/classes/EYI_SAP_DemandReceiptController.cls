/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EYI_SAP_DemandReceiptController {

    private static Id paymentReceiptId;
    public EYI_SAP_DemandReceiptController() {

    }
    @AuraEnabled(cacheable=true)
    public static String getBookingSalesOrder(Id opportunityId) {
        List<EYI_Booking__c> booking = [
            SELECT EYI_SAP_Sales_Order_Number__c 
            FROM EYI_Booking__c 
            WHERE EYI_Opportunity_Name__c = :opportunityId 
            LIMIT 1
        ];

        return !booking.isEmpty()  ? booking[0].EYI_SAP_Sales_Order_Number__c : null;
    }
    @AuraEnabled
    public static EYI_Payment_Receipt__c getPDCDetails(Id recordId){
      return [SELECT Id, EYI_Opportunity__c, EYI_Instrument_Date__c ,EYI_Cheque_Realization_Date__c, EYI_Amount__c, EYI_Bank_Name__c, EYI_Mode_of_Payment__c,
            EYI_Transaction_Type__c ,EYI_Category_of_Funding__c, EYI_Remarks__c, EYI_Check_Number__c From EYI_Payment_Receipt__c where Id=:recordId];
    }

    @AuraEnabled(cacheable=true)
    public static List<EYI_Applicants__c> getApplicants(Id opportunityId) {
        return [
            SELECT Id, Name, EYI_Applicant_Type__c 
            FROM EYI_Applicants__c 
            WHERE Opportunity__c = :opportunityId
        ];
    }

    @AuraEnabled
    public static List<Map<String, Object>> getApiData(Id recordId) {
        List<Map<String, Object>> finalRecords = new List<Map<String, Object>>();
        EYI_SAP_DemandReceiptController.paymentReceiptId = recordId;
    
       
    
        // Step 1: Get SAP Data
        List<Map<String, Object>> sapRecords = getSAP_Data(recordId);
        System.debug('response in fetch-->' +sapRecords);
        // Step 2: Map SAP Records by fiDocumentNo
        Map<String, Map<String, Object>> sapMap = new Map<String, Map<String, Object>>();
        for (Map<String, Object> sapRecord : sapRecords) {
            String fiDocNo = (String)sapRecord.get('fiDocumentNo');
            if (fiDocNo != null) {
                //String fiDocNum = (String)sapRecord.get('fiDocumentNo');
            String fiscalYear =(String)sapRecord.get('fiscalYear');
            String lineItemNo = (String)sapRecord.get('lineItemNo');
            String compositeKey = fiDocNo+ '-' +String.valueOf(fiscalYear)+'-' +lineItemNo;
                sapMap.put(compositeKey, sapRecord);
            }
        }

        // Step 3: Query all Salesforce Data (No filters)
        List<EYI_Payment_Line_Item__c> dbLineItems = [
            SELECT EYI_Total_Amount__c, EYI_Status__c, EYI_SAP_External_Id__c, 
                   EYI_Principal_Tax_Amount__c, EYI_Adjustment_Amount__c,
                   EYI_Outstanding_Amount__c, EYI_Payment_Receipt__r.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                   EYI_Payment_Receipt__r.EYI_Opportunity__r.EYI_SAP_Customer_Number__c, EYI_Fiscal_Year__c,
                   EYI_Number_of_Line_Items__c, 
                   EYI_Billing_Document__c, EYI_Milestone_No__c, EYI_Unit_Code_SAP__c,EYI_SAP_Ref_Doc_No__c,
                   EYI_Adjustment_Type__c, EYI_FL_Document_Number__c,EYI_Special_G_L_Indicator__c,EYI_Doc_Type__c,EYI_Customer_Reference__c,EYI_UniqueKey__c,EYI_INV_REF__c,EYI_Item_Text__c
            FROM EYI_Payment_Line_Item__c 
            WHERE EYI_Payment_Receipt__r.EYI_Opportunity__c = :recordId AND EYI_Payment_Receipt__r.EYI_Payment_Status__c != 'REJECT' AND EYI_Payment_Receipt__r.EYI_Payment_Status__c != 'APPROVE'
            
        ];
        
        
        System.debug('sapMap-->' +sapMap.size());
    
        // Step 4: Filter Salesforce Data and Override SAP Map
        for (Map<String, Object> sapRecord : sapRecords) {
            String fiDocNum = (String)sapRecord.get('fiDocumentNo');
            String fiscalYear =(String)sapRecord.get('fiscalYear');
            String lineItemNo = (String)sapRecord.get('lineItemNo');
            String compositeKey = fiDocNum + '-' + String.valueOf(fiscalYear) + '-' + lineItemNo;
            
            // Added by Rishikesh to add Posting Date column in line items
            String rawDate = (String)sapRecord.get('PSTNG_DATE');   

        for (EYI_Payment_Line_Item__c sfRecord : dbLineItems) {
            String fiDocNo = sfRecord.EYI_FL_Document_Number__c;
            System.debug('SAP compositeKey : '+compositeKey);
            System.debug('sfRecord.EYI_UniqueKey__c : '+sfRecord.EYI_UniqueKey__c);
            // Determine if this record passes filter
            Boolean passesFilter = false;
            if (sfRecord.EYI_Status__c == 'Rejected') {
                passesFilter = true;
            } else if (sfRecord.EYI_Status__c == null && 
                       (sfRecord.EYI_Outstanding_Amount__c == null || sfRecord.EYI_Outstanding_Amount__c != 0)) {
                passesFilter = true;
            }
    
            if (passesFilter && fiDocNo != null && sfRecord.EYI_UniqueKey__c != null && compositeKey == sfRecord.EYI_UniqueKey__c) {
                // Build Salesforce record map
                Map<String, Object> sfMap = new Map<String, Object>{
                    'id' => sfRecord.Id,
                    'fiDocumentNo' => fiDocNo,
                    'amountLocalCurrency' => String.valueOf(sfRecord.EYI_Principal_Tax_Amount__c),
                    'status' => sfRecord.EYI_Status__c,
                    'outstanding' => String.valueOf(sfRecord.EYI_Outstanding_Amount__c),
                    'paymentBifurcation' => sfRecord.EYI_Adjustment_Type__c,
                    'unitCodeSAP' => sfRecord.EYI_Unit_Code_SAP__c,
                    'milestoneNo' => sfRecord.EYI_Milestone_No__c,
                    'billingDoc' => sfRecord.EYI_Billing_Document__c,
                    'fiscalYear' => sfRecord.EYI_Fiscal_Year__c,
                    'companyCode' => sfRecord.EYI_Payment_Receipt__r.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                    'customerNumber' => sfRecord.EYI_Payment_Receipt__r.EYI_Opportunity__r.EYI_SAP_Customer_Number__c,
                    'lineItemNo' => sfRecord.EYI_Number_of_Line_Items__c,
                    'SP_GL_IND' =>  sfRecord.EYI_Special_G_L_Indicator__c,
                    'DOC_TYPE' => sfRecord.EYI_Doc_Type__c,
                    'PSTNG_DATE' => rawDate,
                    'CustRefLineItem' => sfRecord.EYI_Customer_Reference__c,
                    'DB_CR_IND' => sapRecord.containsKey('DB_CR_IND') && String.isNotBlank((String)sapRecord.get('DB_CR_IND')) ? String.valueOf((String)sapRecord.get('DB_CR_IND')) : null,
                    'INV_REF' => sfRecord.EYI_INV_REF__c,
                    'ITEM_TEXT' => sfRecord.EYI_Item_Text__c,
                    'REF_DOC_NO' => sapRecord.containsKey('REF_DOC_NO') && String.isNotBlank((String)sapRecord.get('REF_DOC_NO')) ? String.valueOf((String)sapRecord.get('REF_DOC_NO')) : null

                };
                 system.debug('sfMap===>' +sfMap);
                    
                
                // Override SAP with Salesforce
                sapMap.put(compositeKey, sfMap);
            } 
           else if (!passesFilter && compositeKey == sfRecord.EYI_UniqueKey__c && fiDocNo != null) {
            System.debug('Removing compositeKey '+compositeKey);
                // Remove corresponding SAP data if Salesforce record failed the filter
                sapMap.remove(compositeKey);
            }
          
        }
    }
        
    
        // Step 5: Final Union List
        finalRecords.addAll(sapMap.values());
        system.debug('finalRecords--->89' +finalRecords.size());
    
        return finalRecords;
    }
    

    private static List<Map<String, Object>> getSAP_Data(String recordId){
        HttpResponse response = EY_SAP_Gateway.sendPaymentLineItems(recordId);
        String jsonResponse = response.getBody();
        List<Map<String, Object>> records = new List<Map<String, Object>>();
    
        // Parse the JSON string into a generic map
        Map<String, Object> fullResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        System.debug('fullResponse:::'+fullResponse);
        if (fullResponse == null) return records;
        // Convert the full response map back to JSON string for clean printing
        String fullResponseString = JSON.serializePretty(fullResponse);
        System.debug('Full Response:\n' + fullResponseString);
        // Navigate to the 'item' list
        System.debug('Value ::: '+fullResponse.get('n0:ZSD_OPEN_LINE_ITEMS_CUST_SFResponse'));

        Object respObj = fullResponse.get('n0:ZSD_OPEN_LINE_ITEMS_CUST_SFResponse');
        //Object respObj = fullResponse.get('n0:ZSD_OPEN_LINE_ITEMS_CUST_SFResponse');
        Map<String, Object> responseMap = new Map<String, Object>() ;
        Map<String, Object> exOutput = new Map<String, Object>() ;
        List<Object> items = new List<Object>();

        if (respObj instanceof Map<String, Object>) {
            responseMap = (Map<String, Object>) respObj;
            System.debug('responseMap ::: ' + responseMap);

            Object exOutputObj = responseMap.get('EX_OUTPUT');
            if (exOutputObj instanceof Map<String, Object>) {
                exOutput = (Map<String, Object>) exOutputObj;
                System.debug('Items :: '+exOutput.get('item'));
                //items = (List<Object>) exOutput.get('item');
                //items =  exOutput.get('item');
                Object itemsObj = exOutput.get('item');

                if (itemsObj instanceof List<Object>) {
                    items = (List<Object>) itemsObj;
                } else if (itemsObj instanceof Map<String, Object>) {
                    items = new List<Object>{ itemsObj };
                } else {
                    System.debug('Unexpected type for items: ' + itemsObj);
                    return records;
                }
                if (items == null) return records;
                System.debug('exOutput ::: ' + exOutput);
            } else {
                System.debug('EX_OUTPUT is not a map: ' + exOutputObj);
                return records;
            }

        } else {
            System.debug('ZSD_OPEN_LINE_ITEMS_CUST_SFResponse is not a map. Actual value: ' + respObj);
            return records;
        }
        /*
        Map<String, Object> responseMap = (Map<String, Object>) fullResponse.get('n0:ZSD_OPEN_LINE_ITEMS_CUST_SFResponse');
        if (responseMap == null) return records;
        
        Map<String, Object> exOutput = (Map<String, Object>) responseMap.get('EX_OUTPUT');
        system.debug('exOutput:::'+exOutput);
        if (exOutput == null) return records;
        */


        Integer idCounter = 1;
        
        // Loop through each item and map to your desired structure
        for (Object obj : items) {
            Map<String, Object> itemMap = (Map<String, Object>) obj;
            System.debug('currentObj Item number:::'+itemMap.get('ITEM_NUM'));

            Map<String, Object> record = new Map<String, Object>{
                'id' => idCounter,
                'companyCode' => itemMap.get('COMP_CODE'),
                'customerNumber' => itemMap.get('CUSTOMER'),
                'fiDocumentNo' => itemMap.get('DOC_NO'),
                'fiscalYear' => itemMap.get('FISC_YEAR'),
                'lineItemNo' => itemMap.get('ITEM_NUM'),
                'billingDoc' => itemMap.get('BILL_DOC'),
                'milestoneNo' => itemMap.get('REF_KEY_1'), // Assuming REF_KEY_2 as milestoneNo
                'unitCodeSAP' => itemMap.get('REF_KEY_2'), // Not available in response, leave blank or logic to derive
                'paymentBifurcation' => itemMap.get('REF_KEY_3'), // Assuming REF_KEY_1 as bifurcation
                'amountLocalCurrency' => itemMap.get('LC_AMOUNT'),
                'outstanding' => itemMap.get('LC_AMOUNT'),
                'currency' => itemMap.get('CURRENCY'),
                'DOC_TYPE' => itemMap.get('DOC_TYPE'),
                'SP_GL_IND' => itemMap.get('SP_GL_IND'),
                'DOC_DATE' => itemMap.get('DOC_DATE'),
                'PSTNG_DATE' => itemMap.get('PSTNG_DATE'),
                'DB_CR_IND' => itemMap.get('DB_CR_IND'),
                'ALLOC_NMBR' => itemMap.get('ALLOC_NMBR'),
                'REF_DOC_NO' => itemMap.get('REF_DOC_NO'),
                'CustRefLineItem' => itemMap.get('ITEM_NUM'),
                'INV_REF' => itemMap.get('INV_REF'),
                'ITEM_TEXT' => itemMap.get('ITEM_TEXT'),
                'REF_DOC_NO' => itemMap.get('REF_DOC_NO')
            };
            
            records.add(record);
            system.debug('Records from SAP--->'+records);
            idCounter++;
        }

        return records;
       
    }

    /*@AuraEnabled(cacheable=true)
    public static String checkDuplicateNumber(String fieldType, String value) {
        if (String.isBlank(fieldType) || String.isBlank(value)) {
            return 'EMPTY';
        }

        List<EYI_Payment_Receipt__c> existing = new List<EYI_Payment_Receipt__c>();
        System.debug('fieldType : '+fieldType);
        System.debug('value : '+value);
        if (fieldType == 'InstrumentNumber') {
            existing = [
                SELECT Id FROM EYI_Payment_Receipt__c
                WHERE EYI_Instrument_Number__c = :value
                AND EYI_Payment_Status__c != 'REJECT'
                LIMIT 1
            ];
        } else if (fieldType == 'ChequeDdNumber') { //  EYI_Instrument_Number__c, EYI_Check_number__c, EYI_Payment_Status__c,
            existing = [
                SELECT Id FROM EYI_Payment_Receipt__c
                WHERE EYI_Check_number__c = :value
                AND EYI_Payment_Status__c != 'REJECT'
                LIMIT 1
            ];
        }
        return existing.isEmpty() ? 'UNIQUE' : 'DUPLICATE';
    }*/
    @AuraEnabled
    public static String checkDuplicateNumber(String fieldType, String value, String bankName) {
        System.debug('fieldType : '+fieldType);
        System.debug('value : '+value);
        System.debug('bankName : '+bankName);
        // Validate primary parameters
        if (String.isBlank(fieldType) || String.isBlank(value)) {
            return 'EMPTY';
        }
 
        List<EYI_Payment_Receipt__c> existing = new List<EYI_Payment_Receipt__c>();
 
        // Check by Instrument Number only
        if (fieldType == 'InstrumentNumber') {
            System.debug('inside InstrumentNumber');
            existing = [
                SELECT Id
                FROM EYI_Payment_Receipt__c
                WHERE EYI_Instrument_Number__c = :value
                AND EYI_Payment_Status__c != 'REJECT'
                LIMIT 1
            ];
        }
        // Check by Cheque/DD Number and Bank Name
        else if (fieldType == 'ChequeDdNumber') {
            System.debug('inside ChequeDdNumber');
            if (String.isBlank(bankName)) {
                return 'EMPTY_BANK';
            }
 
            existing = [
                SELECT Id
                FROM EYI_Payment_Receipt__c
                WHERE EYI_Check_number__c = :value
                AND EYI_Bank_Name__c = :bankName
                AND EYI_Payment_Status__c != 'REJECT'
                LIMIT 1
            ];
        }
        System.debug('existing : '+existing);
        return existing.isEmpty() ? 'UNIQUE' : 'DUPLICATE';
    }
    
    @AuraEnabled
    public static void createLineItems(List<Map<String, Object>> updatedRecords, Id paymentReceiptId,Id opptyId, Decimal paymentAmountFromUser, Decimal advanceAmount) {
        if (updatedRecords == null || updatedRecords.isEmpty()) {
            return;
        }

        List<EYI_Payment_Line_Item__c> upsertList = new List<EYI_Payment_Line_Item__c>();
        Decimal totalAdjustedAmount = 0;

        // Query existing line items
        Map<String, EYI_Payment_Line_Item__c> existingLineItemMap = new Map<String, EYI_Payment_Line_Item__c>();
        for (EYI_Payment_Line_Item__c lineItem : [
            SELECT Id, EYI_Adjustment_Amount__c, EYI_FL_Document_Number__c,EYI_Outstanding_Amount__c,EYI_Previously_Adjustment_Amount__c,EYI_SAP_External_Id__c
            FROM EYI_Payment_Line_Item__c
            WHERE EYI_Payment_Receipt__r.EYI_Opportunity__c = :opptyId order by CreatedDate Desc
        ]) {
            if (lineItem.EYI_FL_Document_Number__c != null) {
                existingLineItemMap.put(lineItem.EYI_SAP_External_Id__c, lineItem);
            }
        }

        for (Map<String, Object> record : updatedRecords) {
            if (record.containsKey('inputValue') && record.get('inputValue') != null && record.get('inputValue') != '' && record.containsKey('fiDocumentNo')) {
                String fiDocNo = String.valueOf(record.get('fiDocumentNo'));
                String fiscalYear =String.valueOf(record.get('fiscalYear')) ;
                String lineItemNo = (String)record.get('lineItemNo');
                String compositeKey = fiDocNo+ '-' +String.valueOf(fiscalYear)+'-' +lineItemNo;

                String paymentBifurcation = String.valueOf(record.get('paymentBifurcation'));
                if( paymentBifurcation=='ADV'){
                    system.debug('inside OTH and ADV');
                    break;
                }

                Decimal adjustmentAmountFromScreen = Decimal.valueOf(String.valueOf(record.get('inputValue')));
                
                totalAdjustedAmount += adjustmentAmountFromScreen;
                Decimal principalAmt = Decimal.valueOf(String.valueOf(record.get('amountLocalCurrency')));
                Decimal outstandingAmount = record.containsKey('outstandingAmount') ? Decimal.valueOf(String.valueOf(record.get('outstandingAmount'))) : 0;
                System.debug('outstandingAmount : '+outstandingAmount);
                System.debug('principalAmt : '+principalAmt);
                Decimal totalAdjustmentAmount = adjustmentAmountFromScreen;
                Decimal existingTotalAmount = 0;
                EYI_Payment_Line_Item__c existingItem = existingLineItemMap.get(compositeKey);
                if (existingItem != null && existingItem.EYI_Adjustment_Amount__c != null) {
                    System.debug('existingItem : '+existingItem);
                    if(existingItem.EYI_Previously_Adjustment_Amount__c != null){
                        totalAdjustmentAmount += existingItem.EYI_Previously_Adjustment_Amount__c;
                        existingTotalAmount = existingItem.EYI_Previously_Adjustment_Amount__c + existingItem.EYI_Adjustment_Amount__c;
                        }else{
                            totalAdjustmentAmount += existingItem.EYI_Adjustment_Amount__c;
                            existingTotalAmount += existingItem.EYI_Adjustment_Amount__c;
                        }
                    }
                System.debug('existingItem:::'+existingItem);
                System.debug('totalAdjustmentAmount after addition:::'+totalAdjustmentAmount);
                System.debug('adjustmentAmountFromScreen :::'+adjustmentAmountFromScreen);
                EYI_Payment_Line_Item__c primaryLineItem = new EYI_Payment_Line_Item__c();
                primaryLineItem.EYI_Adjustment_Amount__c = adjustmentAmountFromScreen;
                primaryLineItem.EYI_Previously_Adjustment_Amount__c = existingTotalAmount;
                primaryLineItem.EYI_Payment_Receipt__c = paymentReceiptId;
                primaryLineItem.EYI_SAP_External_Id__c = compositeKey;
                primaryLineItem.EYI_FL_Document_Number__c = fiDocNo;

                // Logic for adjustment amount limit
                if (existingItem != null && existingItem.EYI_Outstanding_Amount__c != null && existingItem.EYI_Outstanding_Amount__c < totalAdjustmentAmount) {
                    Decimal adjustmentAmt = 0;
                    if(existingItem.EYI_Previously_Adjustment_Amount__c != null){
                         adjustmentAmt = existingItem.EYI_Previously_Adjustment_Amount__c != null ? existingItem.EYI_Previously_Adjustment_Amount__c : 0;
                    }else{
                         adjustmentAmt = existingItem.EYI_Adjustment_Amount__c != null ? existingItem.EYI_Adjustment_Amount__c : 0;
                    }
                    
                    Decimal outstandingAmt = existingItem.EYI_Outstanding_Amount__c != null ? existingItem.EYI_Outstanding_Amount__c : 0;
                   // primaryLineItem.EYI_Adjustment_Amount__c = adjustmentAmt + outstandingAmt;
                    System.debug('less than condition'+ primaryLineItem.EYI_Adjustment_Amount__c);
                }
                else if (existingItem != null && existingItem.EYI_Outstanding_Amount__c != null && existingItem.EYI_Outstanding_Amount__c == totalAdjustmentAmount) {
                    
                   // primaryLineItem.EYI_Adjustment_Amount__c = adjustmentAmountFromScreen + existingItem.EYI_Adjustment_Amount__c;
                    System.debug('equal condition'+ primaryLineItem.EYI_Adjustment_Amount__c);
                }
                else{
                    //primaryLineItem.EYI_Adjustment_Amount__c = totalAdjustmentAmount;
                    System.debug('else condition'+ primaryLineItem.EYI_Adjustment_Amount__c);
                }
                
                //added by Rishikesh to format the posting date
                String rawDate = (String)record.get('PSTNG_DATE');
                // Map additional fields
                primaryLineItem.EYI_Adjustment_Type__c = String.valueOf(record.get('paymentBifurcation'));
                primaryLineItem.EYI_Unit_Code_SAP__c = String.valueOf(record.get('unitCodeSAP'));
                primaryLineItem.EYI_Milestone_No__c = String.valueOf(record.get('milestoneNo'));
                primaryLineItem.EYI_Billing_Document__c = String.valueOf(record.get('billingDoc'));
                primaryLineItem.EYI_Doc_Type__c = String.valueOf(record.get('DOC_TYPE'));
                primaryLineItem.EYI_Special_G_L_Indicator__c = String.valueOf(record.get('SP_GL_IND'));
                primaryLineItem.EYI_Customer_Reference__c = String.valueOf(record.get('ITEM_NUM'));
                primaryLineItem.EYI_INV_REF__c = String.valueOf(record.get('INV_REF'));
                primaryLineItem.EYI_Item_Text__c = String.valueOf(record.get('ITEM_TEXT'));
                primaryLineItem.EYI_SH_Indicators__c = String.valueOf(record.get('DB_CR_IND'));
                primaryLineItem.EYI_SAP_Ref_Doc_No__c = String.valueOf(record.get('REF_DOC_NO'));
                primaryLineItem.EYI_Posting_Date__c =  Date.valueOf(rawDate);

                if (record.containsKey('amountLocalCurrency')) { 
                    primaryLineItem.EYI_Principal_Tax_Amount__c = principalAmt;
                }
                if (record.containsKey('fiscalYear')) {
                    primaryLineItem.EYI_Fiscal_Year__c = Decimal.valueOf(String.valueOf(record.get('fiscalYear')));
                }
                if (record.containsKey('lineItemNo')) {
                    primaryLineItem.EYI_Number_of_Line_Items__c = String.valueOf(String.valueOf(record.get('lineItemNo')));
                }

                upsertList.add(primaryLineItem);


                // Optional: Existing logic for splits remains unchanged
            }
        }

        // After processing all rows, check for floating amount
        Decimal floatingAmount = advanceAmount;
        if (floatingAmount > 0) {
            
            /*EYI_Payment_Line_Item__c floatingLineItem = new EYI_Payment_Line_Item__c();
            floatingLineItem.EYI_Payment_Receipt__c = paymentReceiptId;
            floatingLineItem.EYI_SAP_External_Id__c = 'Floating_' + paymentReceiptId;
            //floatingLineItem.EYI_Adjustment_Amount__c = floatingAmount;
            floatingLineItem.EYI_Principal_Tax_Amount__c = floatingAmount;
            floatingLineItem.EYI_FL_Document_Number__c = paymentReceiptId + '_Floating';
            floatingLineItem.EYI_Adjustment_Type__c = 'OTH';
            upsertList.add(floatingLineItem);*/
             // Add floating item to updatedRecords as a map
        }
        

        if (!upsertList.isEmpty()) {
            upsert upsertList EYI_SAP_External_Id__c;
        }
    }

    @AuraEnabled
    public static String createLineItemsWithReceipt(List<Map<String, Object>> updatedRecords, Id opptyId, Map<String, Object> formData, Id fileId) {
        formData.put('OpportunityId', opptyId);
        System.debug('formData ==> '+formData);
        System.debug('updatedRecords ==>'+updatedRecords);
		List<EYI_Payment_Line_Item__c> lstlineItem = new  List<EYI_Payment_Line_Item__c>();
        String returnMessage;

        String transactionType = formData.containsKey('TransactionType') ? String.valueOf(formData.get('TransactionType')) : null;
        Boolean isNonBankable = formData.containsKey('NonBankablePayment') ? Boolean.valueOf(formData.get('NonBankablePayment')) : false;
        Boolean showPaymentReceipt = formData.containsKey('PaymentAlreadyDone') && Boolean.valueOf(formData.get('PaymentAlreadyDone'));
        System.debug('showPaymentReceipt===>' +showPaymentReceipt);
        EYI_SAP_PaymentReceiptSyncLwcController.lwcMessage lm;
    
        // Extract and clean payment amount
        String rawAmount = String.valueOf(formData.get('PaymentAmount'));
        String paymentId = formData.containsKey('ReceiptSelect') ? String.valueOf(formData.get('ReceiptSelect')) : null; 
        String cleanedAmount = rawAmount != null ? rawAmount.replace(',', '') : '0';
        Decimal paymentAmount = Decimal.valueOf(cleanedAmount);
        Decimal advanceAmount = formData.containsKey('advanceAmount') ? Decimal.valueOf(String.valueOf(formData.get('advanceAmount'))) : null;

        // --- Create Payment Receipt ---
        system.debug('PaymentId 1 ==> '+ paymentId);
        
    
        Boolean floatingAddedForDemand = false;
        // Update Inventory to Block
       // EYI_Inventory__c invRec = [SELECT Id,EYI_Inventory_Status__c,EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_Minimum_Token_Amount__c,EYI_Opportunity__c,EYI_Opportunity__r.StageName from EYI_Inventory__c  where EYI_Opportunity__c =:  opptyId];
		Opportunity oppRec = [Select Id,StageName,EYI_Project_Enquired__r.EYI_Minimum_Token_Amount__c from Opportunity Where Id =:opptyId];
        List<EYI_Payment_Receipt__c> existingPaymentReceipt = [Select Id,EYI_Amount__c from EYI_Payment_Receipt__c Where EYI_Opportunity__c =:opptyId];

        Decimal totalAmountReceived = 0;

        if(!existingPaymentReceipt.isEmpty() ){
            for(EYI_Payment_Receipt__c prObj : existingPaymentReceipt){
                totalAmountReceived += prObj.EYI_Amount__c;
            }
        }
        List<Opportunity> updateInvList = new List<Opportunity>();
        totalAmountReceived  += paymentAmount;
        if(oppRec.EYI_Project_Enquired__r.EYI_Minimum_Token_Amount__c <= totalAmountReceived){
            if(oppRec.StageName == 'Walk-in'){
                Opportunity invObj = new Opportunity();
                invObj.Id = opptyId;
                invObj.StageName = 'Block';
                invObj.EYI_Token_Amount__c = totalAmountReceived;
                invObj.EYI_AutomationBypassDatetime__c = System.now();
                updateInvList.add(invObj);
            }
        }
        
        // --- Handle Advance or Demand Floating Logic ---
        if (transactionType != null && (transactionType.equalsIgnoreCase('Advance') || transactionType.equalsIgnoreCase('Demand') || transactionType.equalsIgnoreCase('TDS'))) {
    
            if (transactionType.equalsIgnoreCase('Advance')) {
                updatedRecords.clear();
    
                Map<String, Object> floatingRecord = new Map<String, Object>();
                floatingRecord.put('fiDocumentNo', 'Floating');
                floatingRecord.put('inputValue', String.valueOf(paymentAmount));
                floatingRecord.put('amountLocalCurrency', String.valueOf(paymentAmount));
                floatingRecord.put('EYI_Tax_Code__c', null);
                floatingRecord.put('profitCenter', null);
                floatingRecord.put('inventoryName', null);

                floatingRecord.put('customerNumber', formData.get('customerNumber'));
                floatingRecord.put('paymentBifurcation', 'ADV');
                
                
                updatedRecords.add(floatingRecord);
                System.debug('updatedRecords '+updatedRecords);
                
            }
    
            if (transactionType.equalsIgnoreCase('Demand')) {
                Decimal totalInputValue = 0;
                for (Map<String, Object> record : updatedRecords) {
                    if (record.containsKey('inputValue') && record.get('inputValue') != null && String.valueOf(record.get('inputValue')) != '') {
                        Decimal inputVal = Decimal.valueOf(String.valueOf(record.get('inputValue')));
                        totalInputValue += inputVal;
                    }
                }
                List<Id> lstLineId = new List<Id>();
                /*if(paymentId!='' &&paymentId!=null){
                    Decimal totalValue =0;
                   for (Map<String, Object> record : updatedRecords) {
                         if (record.containsKey('paymentBifurcation') && record.get('paymentBifurcation') != null && String.valueOf(record.get('paymentBifurcation')) == 'OTH') {
                             Decimal paymentValue = Decimal.valueOf(String.valueOf(record.get('amountLocalCurrency')));
                             totalValue = totalValue+paymentValue;
                             System.debug('==totalValue=='+totalValue);
                             System.debug('==totalInputValue=='+totalInputValue);

                             if(totalValue<=totalInputValue){
                                 lstLineId.add((Id)(record.get('id')));
                             }
                             
                             System.debug('==paymentValue=='+paymentValue);
                             System.debug('==advanceAmount=='+advanceAmount);
                             if(paymentValue>=advanceAmount){
                                 lstLineId.add((Id)(record.get('id')));
                             }
                         }
                   }
                }
                if(!showPaymentReceipt ){
                   for (Map<String, Object> record : updatedRecords) {
                            System.debug('line item id : '+record.get('id'));
                         if (record.containsKey('paymentBifurcation') && record.get('paymentBifurcation') != null && String.valueOf(record.get('paymentBifurcation')) == 'OTH') {   
                            String lineItemId = String.valueOf(record.get('id'));
                            // ✅ Add only if ID is 15 or 18 characters
                            if (lineItemId.length() == 15 || lineItemId.length() == 18) {
                                lstLineId.add((Id)lineItemId);
                            }                          
                               //  lstLineId.add((Id)(record.get('id')));                           
                         }
                   }
                }*/
                
                
                if(!lstLineId.isEmpty()){
                    lstlineItem = [Select Id from EYI_Payment_Line_Item__c where Id IN:lstLineId];
                }
                
                System.debug('==lstlineItem=='+lstlineItem);
                if(lstlineItem != null && !lstlineItem.isEmpty())
                {
                   // delete lstlineItem;
                }
    
                Decimal floatingAmount = paymentAmount - totalInputValue;
    
                if (floatingAmount > 0) {
                    System.debug('Inside floatingAmount');
                    Map<String, Object> floatingRecord = new Map<String, Object>();
                    floatingRecord.put('fiDocumentNo', 'Floating');
                    floatingRecord.put('inputValue', String.valueOf(floatingAmount));
                    floatingRecord.put('amountLocalCurrency', String.valueOf(floatingAmount));
                    floatingRecord.put('EYI_Tax_Code__c', null);
                    floatingRecord.put('profitCenter', null);
                    floatingRecord.put('inventoryName', null);
                    floatingRecord.put('customerNumber', formData.get('customerNumber'));
                    floatingRecord.put('paymentBifurcation', 'ADV');
    				//code added by Akshay
                    updatedRecords.add(floatingRecord);
                    
                    floatingAddedForDemand = true;
                }
            }
        }
    
        // --- SAP Sync if not NonBankable ---
        if (!isNonBankable) {
            system.debug('updatedRecordsSSS ==> '+ updatedRecords);
            system.debug('formData ==> '+ formData);

            lm = EYI_SAP_PaymentReceiptSyncLwcController.paymentSyncFromUI(updatedRecords, formData);
            System.debug('lm:::' + lm);
            returnMessage = lm.EX_AVSID + ' || ' + lm.message;
        }
    
        // --- Remove floating record for Demand after Sync ---
        if (transactionType != null && transactionType.equalsIgnoreCase('Demand') && floatingAddedForDemand) {
            Integer indexToRemove = -1;
            for (Integer i = 0; i < updatedRecords.size(); i++) {
                Map<String, Object> rec = updatedRecords[i];
                if (rec.containsKey('fiDocumentNo') && String.valueOf(rec.get('fiDocumentNo')) == 'Floating') {
                    indexToRemove = i;
                    break;
                }
            }
            if (indexToRemove != -1) {
                updatedRecords.remove(indexToRemove);
            }
        }
        
        if(paymentId == null || paymentId == ''/* && transactionType != null && transactionType.equalsIgnoreCase('Demand')*/){
            paymentId = createPaymentReceipt(formData, opptyId);
            system.debug('PaymentId 2 ==> '+ paymentId);
        }
    
        // --- Attach File if Available ---
        if (fileId != null) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = fileId;
            cdl.LinkedEntityId = paymentId ;
            insert cdl;
        }
    
        // --- Update Receipt with SAP Info ---
        if (!isNonBankable && lm != null && lm.type == 'S') {
            if(paymentId != ''){
                EYI_Payment_Receipt__c paymentData = [SELECT Id FROM EYI_Payment_Receipt__c WHERE Id = :paymentId LIMIT 1];
                paymentData.EYI_SAP_Payment_Advice_Number__c = lm.EX_AVSID;
                paymentData.EYI_Is_Syc__c = true;
                paymentData.EYI_SAP_Error__c = null;
                //paymentData.EYI_Account_Document_Number__c = lm.BELNR;
                paymentData.EYI_Doc_Year__c = lm.GJAHR;
                paymentData.EYI_SAP_Company_Code__c = lm.BUKRS;
                update paymentData; 
            }   
        }

        //Anu changes
        if(lstlineItem != null && !lstlineItem.isEmpty())
        {
            delete lstlineItem;
        }
        if(!updateInvList.isEmpty()){
            update updateInvList;
        }
    
        // --- Create Standard Line Items ---
        if (transactionType != null &&  transactionType.equalsIgnoreCase('Demand')){
            System.debug('updatedRecords  :: '+updatedRecords);
            createLineItems(updatedRecords, paymentId, opptyId, paymentAmount,advanceAmount);
        }
        if (lm != null) {
            if (lm.type == 'E') {
                System.debug('lm.message : '+lm.message);
                throw new AuraHandledException(lm.message); // error still works
            } else {
                return returnMessage; //Success message
            }
        }
        if(paymentId != null && isNonBankable){
            return 'Payment receipt has been created successfully.';
        }
        return 'Payment receipt has been created successfully.';
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityInfo(Id recordId){
         Opportunity opp = [Select id, Name, EYI_Inventory__r.EYI_Inventory_Number__c from Opportunity where Id = :recordId limit 1];
         return opp;
    }
        
    @AuraEnabled
    public static List<EYI_Payment_Receipt__c> getPaymentReceiptList(Id opptyId) {

        system.debug('opptyId: ' + opptyId);
        // Query payment receipts that match the opportunity and have related PLIs with ADV or OTH adjustment types
        List<EYI_Payment_Receipt__c> receiptsWithAdvPLI = [
            SELECT Id, Name, EYI_Amount__c, EYI_Mode_of_Payment__c,EYI_Instrument_Number__c, EYI_Channel_Date__c, EYI_Channel_Number__c, EYI_Instrument_Date__c ,EYI_Bank_Name__c,
                    EYI_Transaction_Type__c,EYI_Non_Bankable_Payment__c,EYI_Remarks__c
            FROM EYI_Payment_Receipt__c
            WHERE EYI_Opportunity__c = :opptyId AND EYI_Transaction_Type__c = 'Demand'
            AND Id IN (
                SELECT EYI_Payment_Receipt__c
                FROM EYI_Payment_Line_Item__c
                WHERE EYI_Adjustment_Type__c IN ('ADV', 'OTH')
            )
        ];

        System.debug('receiptsWithAdvPLI: ' + receiptsWithAdvPLI);

        // If none found, throw an error to show in LWC
        if (receiptsWithAdvPLI.isEmpty()) {
            throw new AuraHandledException('No payment receipts available.');
        }
        return receiptsWithAdvPLI;
    }

    private static Id createPaymentReceipt(Map<String, Object> formData, Id opptyId) {
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c();
    
        // Set Opportunity Lookup
        receipt.EYI_Opportunity__c = opptyId;
        System.debug('Transaction type in payment receipt creation====>'+formData.get('TransactionType'));
        System.debug('bank name in payment receipt creation====>'+formData.get('BankName'));
        // Populate fields from formData map
        if (formData.containsKey('InstrumentNumber') && formData.get('TransactionType') != 'TDS' ) {
            receipt.EYI_Instrument_Number__c = String.valueOf(formData.get('InstrumentNumber'));
        }
        if (formData.containsKey('InstrumentDate') && formData.get('TransactionType') != 'TDS' ) {
            receipt.EYI_INstrument_Date__c = Date.valueOf((String)formData.get('InstrumentDate'));
        }
        if (formData.containsKey('RealizationDate')) {
            String realizationDateStr = (String)formData.get('RealizationDate');
            if (String.isNotBlank(realizationDateStr)) {
                receipt.EYI_Cheque_Realization_Date__c = Date.valueOf(realizationDateStr);
            }
           // receipt.EYI_Cheque_Realization_Date__c = Date.valueOf((String)formData.get('RealizationDate'));
        }
        if (formData.containsKey('PaymentAmount')) {
            String rawAmount = String.valueOf(formData.get('PaymentAmount'));
            String cleanedAmount = rawAmount.replace(',', ''); // Remove all commas
            Decimal paymentAmount = Decimal.valueOf(cleanedAmount);
            receipt.EYI_Amount__c = paymentAmount;
        }
        if (formData.containsKey('TransactionType')) {
            receipt.EYI_Transaction_Type__c = (String)formData.get('TransactionType');
        }
        if (formData.containsKey('CategoryofFunnding')) {
            receipt.EYI_Category_of_Funding__c = (String)formData.get('CategoryofFunnding');
        }
        if (formData.containsKey('ReceivedFrom')) {
            receipt.EYI_Received_From__c = (String)formData.get('ReceivedFrom');
        }
        if (formData.containsKey('BankName')) {
            receipt.EYI_Bank_Name__c = (String)formData.get('BankName');
        }
        // if (formData.containsKey('otherBankName')) {
        //     receipt.EYI_Other_Bank_Name__c	 = (String)formData.get('otherBankName');
        // }
        if (formData.containsKey('ChequeDdNumber')) {
            receipt.EYI_Check_Number__c = (String)formData.get('ChequeDdNumber');
        }
        if (formData.containsKey('paymentMode')) {
            receipt.EYI_Mode_of_Payment__c = (String)formData.get('paymentMode');
        }
        if (formData.containsKey('NonBankablePayment')) {
            receipt.EYI_Non_Bankable_Payment__c = Boolean.valueOf(formData.get('NonBankablePayment'));
        }
        if (formData.containsKey('Remarks')) {
            receipt.EYI_Remarks__c = String.valueOf(formData.get('Remarks'));
        }
        if (formData.containsKey('ChannelNumber')) {
            receipt.EYI_Channel_Number__c = (String)formData.get('ChannelNumber');
        }

         if (formData.containsKey('ChannelDate')) {
            String channelDateStr = (String)formData.get('ChannelDate');
            if (String.isNotBlank(channelDateStr)) {
                receipt.EYI_Channel_Date__c = Date.valueOf(channelDateStr);
            }

           // receipt.EYI_Cheque_Realization_Date__c = Date.valueOf((String)formData.get('RealizationDate'));

        }
        receipt.EYI_Opportunity__c = opptyId;
        receipt.EYI_Payment_Status__c = 'SUBMITTED';
        // Add other field mappings as needed based on your formData keys
    
        // Insert Receipt
        insert receipt;   
        // Return the created receipt Id
        return receipt.Id;
    }
	@AuraEnabled(cacheable=true)
public static Map<String, List<String>> getPicklistValues(String objectApiName, List<String> fieldApiNames) {
    Map<String, List<String>> picklistMap = new Map<String, List<String>>();

    // Validate object name
    Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
    if (sObjectType == null) {
        throw new AuraHandledException('Invalid object API name: ' + objectApiName);
    }

    // Describe only requested fields (avoid eager loading all fields)
    for (String fieldName : fieldApiNames) {
        Schema.SObjectField fieldToken = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldName);
        
        if (fieldToken == null) {
            throw new AuraHandledException('Field ' + fieldName + ' not found on object ' + objectApiName);
        }

        Schema.DescribeFieldResult fieldResult = fieldToken.getDescribe();
        if (fieldResult.getType() == Schema.DisplayType.Picklist) {
            List<String> picklistOptions = new List<String>();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                picklistOptions.add(entry.getLabel());
            }
            picklistMap.put(fieldName, picklistOptions);
        } else {
            throw new AuraHandledException(fieldName + ' is not a picklist field.');
        }
    }

    return picklistMap;
}
    

    
}