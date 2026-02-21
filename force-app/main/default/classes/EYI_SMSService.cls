/**
 * @description       : 
 * @author            : Abhishek Verma, Akshay Salunke
 * @group             : EY Notification Framework
 * @last modified on  : 11-04-2024
 * @last modified by  : Digambar Ganage
**/
public with sharing class EYI_SMSService {

    @AuraEnabled
    public static void sendSMSBrochure(String phonenumber,String message,String recId) {
        System.debug('phonenumber===>'+phonenumber);
        System.debug('message===>'+message);
        System.debug('recId===>'+recId);
        try{
            tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_SMSSenderNumber;
            tdc_tsw.GlobalSMSSender.messageType = 'SMS';
            tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndMessageText(phonenumber,message,recId);
        }catch(Exception e){
        }    
    }
    
    @InvocableMethod(label='Send SMS' description='Send SMS Via API')
    public static void sendSMS(List<String> recepientBodyList){//recipient,String templateId,String recordId){
        if(recepientBodyList.size()>0){
            try {
                    String recepientBody = recepientBodyList[0];
                    RecipientWrapper rec = (RecipientWrapper)JSON.deserialize(recepientBody, RecipientWrapper.class);
                    tdc_tsw.GlobalSMSSender.messageType = 'SMS';
                    tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_SMSSenderNumber;

                    if ( isString(rec.recipient.substring(rec.recipient.length() - 2))) {   
                        System.debug('in if SMS recepientBody==>'+ recepientBody);
                        tdc_tsw.GlobalSMSSender.SendSmsWithPhoneAPiAndTemplateId(
                            rec.recipient, rec.templateId,rec.recordId);
                    }else{
                        System.debug('in else SMS recepientBody==>'+ recepientBody);
                        tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndTemplateId(
                            rec.recipient, rec.templateId,rec.recordId);
                    }
                } catch(Exception e) {
            }
        }
    }
    public static void SendTextSMSMessagToNumber(String phonenumber, String message, String recId) {
        try {
            if (!Test.isRunningTest()) {
                System.debug('Calling send SMS phonenumber '+phonenumber+' message '+message+' recId '+recId);
                sendSMSInternal(phonenumber, message, recId);
            } else {
                System.debug('Skipping SMS callout in test context');
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    // 👇 Testable logic here
    @TestVisible
    private static void sendSMSInternal(String phonenumber, String message, String recId) {
        if (!phonenumber.startsWith('+91')) {
            phonenumber = '+91' + phonenumber;
        }

        tdc_tsw.GlobalSMSSender.messageType = 'SMS';
        tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_SMSSenderNumber_US;
        tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndMessageText(phonenumber, message, recId);
        System.debug('SendTextSMSMessagToNumber Called===>' + tdc_tsw.GlobalSMSSender.messageType);
    }
    
    public static Boolean isString(Object param) {
        return param instanceof String;
    }

    public class RecipientWrapper {
        public String recipient { get; set; }
        public String templateId { get; set; }
        public String recordId { get; set; }
    }
}