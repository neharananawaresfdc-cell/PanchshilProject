/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EYI_SAP_PaymentReceiptSyncLwcController {
    @AuraEnabled
    public static lwcMessage PaymentsSync(Id recordId) {
        lwcMessage lm = new lwcMessage();
        Map<String, String> messageAndType = new Map<String, String>();
        EYI_Payment_Receipt__c receiptData =  [Select Id,EYI_Transaction_Type__c,EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                                               EYI_Opportunity__r.EYI_SAP_Customer_Number__c,EYI_Amount__c,
                                               EYI_Bank_Name__c,EYI_Instrument_Number__c,
                                               EYI_Instrument_Date__c,
                                               EYI_Opportunity__r.EYI_Inventory__r.Name, EYI_Currency_Key__c,EYI_SAP_Error__c,EYI_Is_Syc__c,EYI_SAP_Customer_Reference_Number__c,EYI_Principal_Amount__c,EYI_Tax_Amount__c,EYI_Tax_Code__c,
                                               EYI_Opportunity__r.EYI_Inventory__r.EYI_SAP_Profit_Center__c,EYI_SAP_Payment_Advice_Number__c,(Select Id,EYI_Total_Amount__c, EYI_Status__c, EYI_SAP_External_Id__c, 
                                               EYI_Principal_Tax_Amount__c, EYI_Adjustment_Amount__c,
                                               EYI_Outstanding_Amount__c, EYI_Payment_Receipt__r.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                                               EYI_Payment_Receipt__r.EYI_SAP_Customer_Number__c, EYI_Fiscal_Year__c,
                                               EYI_Number_of_Line_Items__c, 
                                               EYI_Billing_Document__c, EYI_Milestone_No__c, EYI_Unit_Code_SAP__c,
                                               EYI_Adjustment_Type__c, EYI_FL_Document_Number__c
                                        FROM Payment_Line_Items__r)
                                               from EYI_Payment_Receipt__c where Id = :recordId];
        //try {
        HttpResponse hr = EY_SAP_Gateway.sendPayementReceipt(receiptData,null, null);
        processPaymentResponse(hr,receiptData);
        return lm;
    }
    
    public static lwcMessage paymentResponseProcessing(HttpResponse response, EYI_Payment_Receipt__c paymentData) {
        lwcMessage lm = new lwcMessage();
        
        // check if response is valid
        if(response.getStatusCode() == 200) {
            try{
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                // Extract the "n0:ZSD_CREATE_UNITS_FROM_SFResponse" field from the map
                Map<String, Object> paymentReceiptResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_PAYMT_RCPT_FROM_SFResponse');
                // Extract the message from CarparkingResponse map.
                String avsId = (String)paymentReceiptResponse.get('EX_AVSID');
                String BELNR = (String)paymentReceiptResponse.get('EX_BELNR');
                String GJAHR = (String)paymentReceiptResponse.get('EX_GJAHR');
                String BUKRS = (String)paymentReceiptResponse.get('EX_BUKRS');  
                if(avsId != null && avsId != ''){
                    lm.type = 'S';
                    lm.message = 'Payment receipt is successfully synced';
                    if(paymentData !=null){
                        paymentData.EYI_SAP_Payment_Advice_Number__c = avsId;
                        paymentData.EYI_Is_Syc__c = true;
                        paymentData.EYI_SAP_Error__c = null;
                        //paymentData.EYI_Account_Document_Number__c = BELNR;
                        paymentData.EYI_Doc_Year__c = GJAHR;
                        paymentData.EYI_SAP_Company_Code__c = BUKRS;
                        paymentData.EYI_Payment_Status__c = 'Submitted';
                        update paymentData;
                    }
                    lm.EX_AVSID = avsId;
                    if(BELNR != null && BELNR != ''){
                        //lm.BELNR = BELNR;
                    }
                    if(GJAHR != null && GJAHR != ''){
                        lm.GJAHR = GJAHR;
                    }
                    if(BUKRS != null && BUKRS != ''){
                        lm.BUKRS = BUKRS;
                    }
                        
                    
                    return lm;
                }  
                
                Map<String, Object> exReturn = (Map<String, Object>) paymentReceiptResponse.get('EX_RETURN');
                if(exReturn == null){
                    
                }
                system.debug('exReturn  '+exReturn);
                Object item =  exReturn.get('item');
                
                // Now you can access individual fields within the "item" map
                string successtype='';
                String type = '';
                String messagDisp = '';
                if (item instanceof List<Object>) {
                    List<Object> itemList = (List<Object>) item;
                    
                    for (Object obj : itemList) { 
                        
                        Map<String, Object> objitem = (Map<String, Object>) obj;
                        //type = type +'-'+ (String) objitem.get('TYPE');
                        successtype = successtype +'-'+ (String) objitem.get('TYPE');
                        string types =(String) objitem.get('TYPE');
                        //system.debug('Updating type '+type);
                        // if (!type.contains('S')) {
                        if(types!='S'){
                            type =(String) objitem.get('TYPE');
                            system.debug('Updating type  inside S loop '+types);
                            messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                        }
                    }
                    system.debug('messagDisp  240==== '+messagDisp);
                }else if(item instanceof Map<String, Object>){
                    SYSTEM.DEBUG('item   '+item);
                    Map<String, Object> objitem = (Map<String, Object>) item;
                    SYSTEM.DEBUG('objitem   '+objitem);
                    type =  (String) objitem.get('TYPE');
                    successtype = (String) objitem.get('TYPE');
                    if(type!='S'){
                        type =(String) objitem.get('TYPE');
                        system.debug('Updating type  inside S loop '+type);
                        messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                    }
                    // messagDisp =(String) objitem.get('MESSAGE');
                }
                system.debug('messageDisp inside loop '+messagDisp);
                if(messagDisp!=null && type!=null ){
                    if(paymentData != null){
                        paymentData.EYI_SAP_Error__c = messagDisp;
                        update paymentData;
                        system.debug('Updating payment receipt for error');
                    }
                    
                    
                }
                String cleanedType = successtype.replaceAll('-', '');
                
                // Check if the cleaned string contains only 'S'
                if (cleanedType != '' && cleanedType.replaceAll('S', '') == '') {
                    if(paymentData != null){
                        paymentData.EYI_Is_Syc__c = true;  
                    }
                    Type ='S';
                    messagDisp = 'Payment Receipt Synced to SAP Successfully.';
                    if(paymentData != null){
                        update paymentData;
                    }
                }
                
                SYSTEM.DEBUG('type  ==>>  '+type);
                SYSTEM.DEBUG('messagDisp   '+messagDisp);
                lm.type =  type;
                lm.message = messagDisp;
                SYSTEM.DEBUG('lm   '+lm);
                return lm;
            }
            catch(Exception e){
                lm.type =  'E';
                lm.message = e.getMessage();
                return lm;
            }
        }
        
        return lm;
    }

    public static void processPaymentResponse(HttpResponse response, EYI_Payment_Receipt__c paymentData) {
        if (response.getStatusCode() == 200) {
            try {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> paymentReceiptResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_PAYMT_RCPT_FROM_SFResponse');

                String avsId = (String)paymentReceiptResponse.get('EX_AVSID');
                String BELNR = (String)paymentReceiptResponse.get('EX_BELNR');
                String GJAHR = (String)paymentReceiptResponse.get('EX_GJAHR');
                String BUKRS = (String)paymentReceiptResponse.get('EX_BUKRS');

                if (avsId != null && avsId != '') {
                    if (paymentData != null) {
                        paymentData.EYI_SAP_Payment_Advice_Number__c = avsId;
                        paymentData.EYI_Is_Syc__c = true;
                        paymentData.EYI_SAP_Error__c = null;
                        //paymentData.EYI_Account_Document_Number__c = BELNR;
                        paymentData.EYI_Doc_Year__c = GJAHR;
                        paymentData.EYI_Payment_Status__c = 'Submitted';
                        paymentData.EYI_SAP_Company_Code__c = BUKRS;
                        update paymentData; // ✅ Update Salesforce record inside Queueable execution
                    }
                } else {
                    if (paymentData != null) {
                        paymentData.EYI_SAP_Error__c = 'SAP Sync Failed';
                        update paymentData;
                    }
                }
            } catch (Exception e) {
                if (paymentData != null) {
                    paymentData.EYI_SAP_Error__c = e.getMessage(); // Capture error in the object itself
                    update paymentData;
                }
            }
        }
    }

    
    public class lwcMessage {
        @AuraEnabled public String type;
        @AuraEnabled public String message;  
        public string EX_AVSID;
        public string BELNR;
        public string GJAHR;
        public String BUKRS;
    }
   
    public static lwcMessage paymentSyncFromUI(List<Map<String, Object>> updatedRecords, Map<String, Object> formData){
        lwcMessage lm = new lwcMessage();
        //try {
        HttpResponse hr = EY_SAP_Gateway.sendPayementReceipt(null, updatedRecords, formData);
        lm = paymentResponseProcessing(hr,null);
        return lm;
    }
   /* public static void paymentSyncFromUI(List<Map<String, Object>> updatedRecords, Map<String, Object> formData) {
        System.enqueueJob(new PaymentReceiptQueueable(updatedRecords, formData));
    }*/

    
}