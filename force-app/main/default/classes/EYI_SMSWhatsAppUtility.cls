public with sharing class EYI_SMSWhatsAppUtility {
        /**
     * @use : This method is used to get the sms templates
     * used in Class : EYI_SMSService,EYI_WhatsappService
     */
    @AuraEnabled(cacheable=true)
    public static List<tdc_tsw__Message_Template__c> getMessageTemplates() {
        return[SELECT Id,name,tdc_tsw__Channel__c, tdc_tsw__ObjectName__c,tdc_tsw__SMSBodyNew__c 
                FROM tdc_tsw__Message_Template__c ];
    }

    @AuraEnabled(cacheable=true)
    public static List<tdc_tsw__Message_Template__c> getMessageTemplatesPresales() {
        return[SELECT Id,name,tdc_tsw__Channel__c, tdc_tsw__Folder__r.Name, tdc_tsw__ObjectName__c,tdc_tsw__SMSBodyNew__c 
                FROM tdc_tsw__Message_Template__c Where tdc_tsw__Folder__r.Name = 'Presales WhatsApp Templates Latest'];
    }
}