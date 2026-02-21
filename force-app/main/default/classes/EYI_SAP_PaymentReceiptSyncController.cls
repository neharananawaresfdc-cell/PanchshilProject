/**
* @Name: EYI_SAP_PaymentReceiptSyncController
* @Description: This class calls SAP sync api to sync booking records with SAP.
* @Author: Mrinal Tripathi
* @Creation Date: 24-Feb-2025
* @Creation Date:24-Feb-2025
* @Version: 1
* @Usage: This class should not be instantiated directly. It is called by the EYI_PaymentReceiptSAPSync LWC.
* @Example: 
* @See: EYI_SAP_PaymentReceiptSyncController
* @Related: EYI_PaymentReceiptSAPSync
* @Notes: 
**/
public class EYI_SAP_PaymentReceiptSyncController {

    @AuraEnabled
    public static lwcMessage PaymentsSync(Id recordId) {
        lwcMessage lm = new lwcMessage();
        //cust number from oppty, remove division, oppty auto number field, salesforce group from oppty regional manager, cancellation reason remove, pdf logic ()
        try{
        EYI_Payment_Receipt__c PaymentData = [Select Id,EYI_Transaction_Type__c,EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                                      		 EYI_Opportunity__r.EYI_SAP_Customer_Number__c,EYI_Amount__c,
                                             EYI_Bank_Name__c,//EYI_Instrument_Number__c,
                                             EYI_Instrument_Date__c,
                                              EYI_Opportunity__r.EYI_Inventory__r.Name, EYI_SAP_Error__c,EYI_Is_Syc__c
 from EYI_Payment_Receipt__c where Id = :recordId];
        System.debug('PaymentData :: '+PaymentData);
        System.debug('String.ValueOf(PaymentData.EYI_Instrument_Date__c) '+String.ValueOf(PaymentData.EYI_Instrument_Date__c));
        System.debug('String.valueOf(PaymentData.EYI_Amount__c '+String.valueOf(PaymentData.EYI_Amount__c));
        System.debug('PaymentData.EYI_Bank_Name__c '+PaymentData.EYI_Bank_Name__c);
        System.debug('PaymentData.EYI_Transaction_Type__c '+PaymentData.EYI_Transaction_Type__c);
        System.debug('CompanyCode: ' + PaymentData.EYI_Opportunity__r?.EYI_Project_Enquired__r?.EYI_SAP_Company_Code__c);
		System.debug('CustomerNumber: ' + PaymentData.EYI_Opportunity__r?.EYI_SAP_Customer_Number__c);
		System.debug('MaterialCode: ' + PaymentData.EYI_Opportunity__r?.EYI_Inventory__r?.Name);
        EYI_PaymentReceiptWrapper data = new EYI_PaymentReceiptWrapper();
        data.PaymentAdvice.TransactionType = PaymentData.EYI_Transaction_Type__c;
        data.PaymentAdvice.PaymentDate = String.ValueOf(PaymentData.EYI_Instrument_Date__c);
        data.PaymentAdvice.PaymentAmount = String.valueOf(PaymentData.EYI_Amount__c);
        data.PaymentAdvice.CustomerBankName = PaymentData.EYI_Bank_Name__c;
        data.PaymentAdvice.CompanyCode = PaymentData.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
        data.PaymentAdvice.SapCustomerNumber = PaymentData.EYI_Opportunity__r?.EYI_SAP_Customer_Number__c;
        data.PaymentAdvice.MaterialCode = PaymentData.EYI_Opportunity__r?.EYI_Inventory__r?.Name;
        String jsonBody =JSON.serialize(data);
        system.debug('Genrate jsonBody'+jsonBody);
        HttpRequest req = new HttpRequest();
        req.setBody(jsonBody);
        //system.debug('isPATCHOperation-->'+isPATCHOperation);
        //if(isPATCHOperation == true) req.setMethod('PATCH'); 
        req.setMethod('POST'); 
        req.setEndpoint('callout:SAP_Integration_Base/CreatePaymentReceiptSalesForce');
        Http http = new Http();
        HttpResponse res;
        
        
        // Send the HTTP request and get the response
        res = http.send(req);
            
        System.debug('res::'+res.getStatusCode());
        System.debug('res body::'+res.getBody());
        // Check the response status code
        if (res.getStatusCode() == 200) {
            system.debug('Success jsonBody-->: '+res.getBody());
            // Deserialize the JSON into an untyped map
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Extract the "n0:ZSD_CREATE_UNITS_FROM_SFResponse" field from the map
            Map<String, Object> BookingResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_SO_FROM_SFResponse');
            // Extract the message from CarparkingResponse map.
            Map<String, Object> exReturn = (Map<String, Object>) BookingResponse.get('EX_RETURN');
            system.debug('exReturn  '+exReturn);
            
            // Now you can access individual fields within the "item" map
            String type = '';
            String messagDisp = '';
            type =  (String) exReturn.get('TYPE');
            messagDisp =(String) exReturn.get('MESSAGE');
            
            if(messagDisp!=null && type!=null ){
                PaymentData.EYI_SAP_Error__c = messagDisp;
                system.debug('Updating Inventory code');
                
            } 
            String cleanedType = type.replaceAll('-', '');
            
            // Check if the cleaned string contains only 'S'
            if (cleanedType != '' && cleanedType.replaceAll('S', '') == '') {
                PaymentData.EYI_Is_Syc__c = true;  
            }
            update PaymentData;
            lm.type = type;
            lm.message = messagDisp;
        }
        }catch(Exception e){
            System.debug('Error Message : '+e.getMessage());
            System.debug('Exception occurred: ' + e.getMessage());
        lm.type = 'E';
        lm.message = 'Error: ' + e.getMessage();
        }
       
        return lm;
    }
    public class lwcMessage {
        @AuraEnabled public String type;
        @AuraEnabled public String message;        
    }
}