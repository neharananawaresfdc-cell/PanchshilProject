/**
* @Name: EYI_GenerateBillingPDFController
* @Description: This class calls SAP to fetch statement PDFs 
* @Author: Mrinal Tripathi
* @Creation Date: 1-Mar-2025
* @Creation Date: 1-Mar-2025
* @Version: 1
* @Usage: This class should not be instantiated directly. It is called by the EYI_generateSAPOrderPDF LWC.
* @Example: 
* @See: EYI_GenerateBillingPDFController
* @Related: EYI_generateSAPOrderPDF
* @Notes: 
**/
public with sharing  class EYI_GenerateBillingPDFController {
    @AuraEnabled
    public static String getGeneratingFile(String requestJsonString){
        String returnString;
        Blob blobpdf;
        List<Attachment> attachList = new List<Attachment>();
        if(requestJsonString != null){
            try{
                String apiResponse;
                HTTPResponse res = new HTTPResponse();
                // call from integration framework
                // variable naming fix
                res = EY_SAP_Gateway.sendSOA_PDF(requestJsonString);
                //post processing
                apiResponse = res.getBody();
                System.debug('apiResponse'+apiResponse);
                Map<String, Object> resMap1 = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                if (resMap1 != null && resMap1.containsKey('n0:ZSD_EXPORT_FORMS_TO_SFResponse')) {
                    Map<String, Object> resMap = (Map<String, Object>) resMap1.get('n0:ZSD_EXPORT_FORMS_TO_SFResponse');
                    
                    if (resMap != null && resMap.containsKey('EX_PDF')) {
                        String exPdf = String.valueOf(resMap.get('EX_PDF'));
                        
                        if (!String.isBlank(exPdf)) {
                            returnString = EncodingUtil.Base64Encode(EncodingUtil.base64Decode(exPdf));
                            System.debug('Decoded & Encoded PDF: ' + returnString);
                        } else {
                            System.debug('EX_PDF is blank or null.');
                        }
                    } else {
                        System.debug('EX_PDF key not found in response.');
                    }
                } else {
                    System.debug('n0:ZSD_EXPORT_FORMS_TO_SFDCResponse key not found in response.');
                }
            }
            // Exception handling required
            catch(Exception ex){
                /*ERP_Integration_Log__c log = new ERP_Integration_Log__c();
log.API_name__c = System.Label.PDF_Generation_Request;
log.Status__c = System.Label.API_Failed;
log.Error_Reason__c = 'Exception Occurred : '+ex.getMessage() +'Exception occured on Line :'+ex.getLineNumber();
Database.insert(log) ;
*/
            }
        }
        
        return returnString;   
    }
/* *************************************************************************************************
*  This getBooking method is the base method of the class where logic method to send Booking List
related to every Opportunity for the Login Account.
*************************************************************************************************
*/ 
    @AuraEnabled(Cacheable=true)
    public static List<EYI_Booking__c> getBooking(String Accountid)
    { 
        List<EYI_Booking__c> bookingList = new List<EYI_Booking__c>();
        if(!String.isBlank(Accountid)){
            bookingList = [Select Id,Name,EYI_Booking_Form_Status__c,EYI_Project_Name__r.Name,EYI_Opportunity_Name__c,EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c,EYI_Opportunity_Name__r.EYI_SalesOrder_Number__c,EYI_Opportunity_Name__r.AccountId From EYI_Booking__c WHERE EYI_Opportunity_Name__r.AccountId = :Accountid OR Id =:Accountid]; 
            System.debug('bookingList--->'+bookingList);   
        }
        return bookinglist;
    }
    
    public class RequestWrapper
    {
        public String DocumentNo {get; set;} 
        public String CompanyCode {get; set;} 
        public String AccountingDocNo {get; set;} 
        public String FiscalYear {get; set;} 
        public String DocumentType {get; set;} 
        
    }
    
    
    /*{
public String BILLDOC {get; set;} 
public String BUKRS {get; set;} 
public String GJAHR {get; set;} 
public String BELNR {get; set;} 
public String TYPE {get; set;} 

}*/
}