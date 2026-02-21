public without sharing class EYI_TowerUtility {
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id towerId) {
        return [SELECT Id, Name, EYI_Email__c,StageName, EYI_Project_Tower_Enquired__c
                FROM Opportunity
                WHERE EYI_Project_Tower_Enquired__c = :towerId
                AND StageName NOT IN ('Cancelled', 'Sales Lost', 'Closed Lost')
                AND (EYI_Email__c != null OR EYI_Alternate_Email__c != null)
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplates() {
        return [SELECT Id, Name, Subject, HtmlValue, Body,Folder.DeveloperName FROM EmailTemplate WHERE  Folder.DeveloperName = 'Possession_Email_Templates'];
    }
   
    @AuraEnabled
    public static List<ContentDocumentLink> getTowerDocuments(List<Id> towerIds) {
        if (towerIds == null || towerIds.isEmpty()) {
            return new List<ContentDocumentLink>();
        }
       return [SELECT 
                ContentDocumentId, 
                ContentDocument.Title, 
                ContentDocument.FileType, 
                ContentDocument.ContentSize
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :towerIds
        ];

    }
    @AuraEnabled
    public static void sendEmails(List<Id> opportunityIds, List<Id> documentIds, String subject, String body) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        List<Opportunity> opps = [
            SELECT EYI_Email__c
            FROM Opportunity
            WHERE EYI_Possession_Status__c != 'Possession Completed'
            AND Id IN :opportunityIds AND EYI_Email__c != null
        ];

        if(documentIds.size()>0){
            // Prepare file attachments
            for (Id docId : documentIds) {
                ContentVersion cv = [
                                    SELECT Title, VersionData, FileExtension
                                    FROM ContentVersion
                                    WHERE ContentDocumentId = :docId
                                    ORDER BY VersionNumber DESC
                                    LIMIT 1
                ];
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title + '.' + cv.FileExtension);
                efa.setBody(cv.VersionData);
                String ext = cv.FileExtension.toLowerCase();
                System.debug('ext=====> '+ext);

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
                //efa.setContentType('application/octet-stream'); // Set generic content type
                System.debug('efa=====> '+efa);
                attachments.add(efa);
            }
        }

        // Prepare emails
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : opps) {
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
        System.debug('emailsToSend=====> '+emailsToSend);
        // Send all emails in bulk
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

}