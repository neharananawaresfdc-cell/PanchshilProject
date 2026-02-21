/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : EY Notification Framework
 * @last modified on  : 11-04-2024
 * @last modified by  : Digambar Ganage
**/
public with sharing class EYI_WhatsAppService {

    @AuraEnabled
    public static void sendWhatsAppBrochure(String phonenumber,String message,String recId){
        try{
            tdc_tsw.GlobalSMSSender.messageType = 'WhatsApp';
            tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_WhatsAppSenderNumber;
            tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndMessageText(phonenumber,message,recId);
        }catch(Exception e){
        }    
    }


    @InvocableMethod(label='Send WhatsApp Message')
    public static void sendWhatsApp(List<String> recepientBodyList) {
        if(recepientBodyList.size() > 0){
            try {
                String recepientBody = recepientBodyList[0];
                RecipientWrapper rec = (RecipientWrapper)JSON.deserialize(recepientBody, RecipientWrapper.class);
                tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_WhatsAppSenderNumber;
                tdc_tsw.GlobalSMSSender.messageType = 'WhatsApp'; 
                // If documentId is provided, use the method that supports it
                if (String.isNotBlank(rec.documentId)) {
                    List<String> prmList= new List<String>();
                    String prm1 = rec.recordId+',' + rec.recipient + ',' + rec.templateId + ',' + System.Label.EYI_WhatsAppSenderNumber + ','
                                + rec.documentId +',' + tdc_tsw.GlobalSMSSender.messageType;
                    prmList.add(prm1);
                    tdc_tsw.GlobalSMSSender.sendSMSFromProcessBuilder(prmList);
                                        
                } else {
                    if (isString(rec.recipient.substring(rec.recipient.length() - 2))) {
                        tdc_tsw.GlobalSMSSender.SendSmsWithPhoneAPiAndTemplateId(
                            rec.recipient, rec.templateId, rec.recordId);
                    } else {
                        tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndTemplateId(
                            rec.recipient, rec.templateId, rec.recordId);
                    }
                }
            } catch(Exception e) {
                System.debug('Error sending WhatsApp message: ' + e.getMessage());
            }
        }
    }

    
    public static Boolean isString(Object param) {
        return param instanceof String;
    }
    public static void SendTextWhatsAppMessagToNumber(String phonenumber,String message,String recId) {
        try {
            System.debug('Calling Whatsapp from SendTextWhatsAppMessagToNumber phonenumber '+phonenumber+' message '+message+' recId '+recId);
            tdc_tsw.GlobalSMSSender.messageType = 'WhatsApp';
            System.debug('System.Label.EYI_WhatsAppSenderNumber : '+System.Label.EYI_WhatsAppSenderNumber);
            tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_WhatsAppSenderNumber;
            tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndMessageText(phonenumber,message,recId); 
            
        } catch(Exception e) {
            System.debug('e : '+e);
            System.debug('e : '+e.getMessage());
        } 
    }

    public class RecipientWrapper {
        public String recipient { get; set; }
        public String templateId { get; set; }
        public String recordId { get; set; }
        public String documentId { get; set; }
    }

    
}