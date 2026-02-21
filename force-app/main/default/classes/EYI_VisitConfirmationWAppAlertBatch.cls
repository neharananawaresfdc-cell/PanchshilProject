global with sharing class EYI_VisitConfirmationWAppAlertBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.Stateful {
        global Database.QueryLocator start(Database.BatchableContext BC) {
            // Query to get the eyi_leadenqury records
            String query = 'SELECT Id, EYI_Lead_Status__c, EYI_Site_Visit_Date__c, EYI_Phone__c FROM EYI_Lead_Enquiry__c WHERE EYI_Site_Visit_Date__c!= NULL AND EYI_Lead_Status__c = \'Visit Confirmed\'';
            return Database.getQueryLocator(query);
        }
    
        global void execute(Database.BatchableContext BC, List<EYI_Lead_Enquiry__c> scope) {
            // Process each batch of records
            for (EYI_Lead_Enquiry__c enq : scope) {
                Date siteVisitDate = enq.EYI_Site_Visit_Date__c.date();
                if (enq.EYI_Phone__c != null) {
                    if (siteVisitDate != null && siteVisitDate == System.today()) {
                        try {
                            tdc_tsw.GlobalSMSSender.messageType = 'WhatsApp';  
                            tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_WhatsAppSenderNumber;
                            tdc_tsw.GlobalSMSSender.isSyncCall = true;
                            tdc_tsw.GlobalSMSSender.SendSmsWithPhoneAPiAndTemplateId(
                                'EYI_Phone__c',
                                System.Label.EYI_VC_TodayWPTemplate,
                                enq.Id
                            );
                            System.debug('===>'+enq.Id +'===>'+System.Label.EYI_VC_TodayWPTemplate);
                        } catch (Exception e) {
                            System.debug('Exception : '+e);
                        }
                    } else if (siteVisitDate != null && siteVisitDate == Date.today().addDays(1)) {  // Compare Date with Date
                        try {
                            tdc_tsw.GlobalSMSSender.messageType = 'WhatsApp'; 
                            tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_WhatsAppSenderNumber;
                            tdc_tsw.GlobalSMSSender.isSyncCall = true;
                            tdc_tsw.GlobalSMSSender.SendSmsWithPhoneAPiAndTemplateId(
                                'EYI_Phone__c',
                                System.Label.EYI_VC_TomorrowWPTemplate,
                                enq.Id
                            );
                        } catch (Exception e) {
                            System.debug('Exception : '+e);
                        }
                    }
                }
            }
        }
    
        global void finish(Database.BatchableContext BC) {
            System.debug('finish : ');
        }
    }