public with sharing class EYI_CampaignUtility {  
    @AuraEnabled(cacheable=true)
    public static List<EYI_Lead_Enquiry__c> getLeadEnquiries(Id campaignId) {
        return [SELECT Id, Name, EYI_Email__c,EYI_Campaign_Name__c FROM EYI_Lead_Enquiry__c WHERE EYI_Campaign_Name__c = :campaignId AND EYI_Campaign_Name__c!= null];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplates() {
        return [SELECT Id, Name, Subject, HtmlValue, Body,Folder.DeveloperName FROM EmailTemplate WHERE  Folder.DeveloperName = 'Campaign_Bulk_Emails'];
    }
   
    @AuraEnabled
    public static List<ContentDocumentLink> getProjectDocuments(List<Id> projectIds) {
        if (projectIds == null || projectIds.isEmpty()) {
            return new List<ContentDocumentLink>();
        }
        return [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :projectIds
        ];
    }
    @AuraEnabled
    public static void sendEmails(List<Id> leadEnqIds, List<Id> documentIds, String subject, String body) {
        // Query valid opportunities with emails
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        List<EYI_Lead_Enquiry__c> leadEnqs = [
            SELECT EYI_Email__c
            FROM EYI_Lead_Enquiry__c
            WHERE Id IN :leadEnqIds AND EYI_Email__c != null
        ];

        if(documentIds.size()>0){
            // Prepare file attachments
            for (Id docId : documentIds) {
                ContentVersion cv = [
                    SELECT Title, VersionData, FileExtension
                    FROM ContentVersion
                    WHERE ContentDocumentId = :docId AND IsLatest = true
                    LIMIT 1
                ];
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title);
                efa.setBody(cv.VersionData);
                String ext = cv.FileExtension.toLowerCase();
                Map<String, String> mimeMap = new Map<String, String>{
                    'pdf' => 'application/pdf',
                    'doc' => 'application/msword',
                    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                    'xls' => 'application/vnd.ms-excel',
                    'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                    'png' => 'image/png',
                    'jpg' => 'image/jpeg',
                    'jpeg' => 'image/jpeg'
                };
                efa.setContentType(mimeMap.containsKey(ext) ? mimeMap.get(ext) : 'application/octet-stream');
                attachments.add(efa);
            }
        }

        // Prepare emails
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (EYI_Lead_Enquiry__c opp : leadEnqs) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{opp.EYI_Email__c});
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            if(documentIds.size()>0){
                mail.setFileAttachments(attachments);
            }
            mail.setSaveAsActivity(true); // Optional: log the email to activity history
            emailsToSend.add(mail);
        }

        // Send all emails in bulk
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

}