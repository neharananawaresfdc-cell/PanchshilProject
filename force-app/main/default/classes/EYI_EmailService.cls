/**
 * @author            : Abhishek Verma
 * @group             : EY Notification Framework
 * @last modified on  : 11-06-2024
 * @last modified by  : Digambar Ganage
**/
public with sharing class EYI_EmailService {

    public static EmailTemplate getEmailTemplateByDeveloperName(String developerName) {
        // Query to fetch the email template based on DeveloperName
        EmailTemplate emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body,TemplateType 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = :developerName 
                                       LIMIT 1];
        // Return the email template if found
        return emailTemplate;
    }

    @AuraEnabled
    public static void sendEmail(String emailRequestJson) {
    System.debug('Email Request Wrapper: ' + emailRequestJson);
    try {
        EYI_BrochureCommunicationWrapper emailRequest = (EYI_BrochureCommunicationWrapper) JSON.deserialize(emailRequestJson, EYI_BrochureCommunicationWrapper.class);
        System.debug('Deserialized EmailRequestWrapper: ' + emailRequest);        
        Id leadId = emailRequest.leadId;
        String projectName = emailRequest.projectName;
        Id projectId = emailRequest.projectId;
        String senderEmail = emailRequest.senderEmail;
        String senderPhone = emailRequest.senderPhone;
        List<String> selectedFileIds = emailRequest.selectedFileIds;
        String messageBody = emailRequest.messageBody;
        String emailSubject = emailRequest.emailSubject;
        System.debug('selectedFileIds: ' + selectedFileIds);
            // Query the files based on the selectedFileIds
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            // Query the ContentVersion based on the selected FileIds
            List<ContentVersion> contentVersions = [
                    SELECT Id, Title, VersionData, FileExtension,ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :selectedFileIds
                ];
            System.debug('ContentVersion: ===>' + contentVersions.size());
            // Loop through the content versions and create file attachments
            for (ContentVersion cv : contentVersions) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.Title + '.' + cv.FileExtension); // Set the file name with extension
                attachment.setBody(cv.VersionData); // Set the file content (binary data)
                attachments.add(attachment);
            }
            // Send email with attachments
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {senderEmail});
            mail.setSubject(emailSubject);
            mail.setPlainTextBody(messageBody);
            mail.setFileAttachments(attachments); // Attach the files
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Email sent successfully with ' + attachments.size() + ' attachments.');
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error occurred while sending email: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendEmailAddActivity(String emailRequestJson) {
    System.debug('Email Request Wrapper: ' + emailRequestJson);
    try {
        EYI_BrochureCommunicationWrapper emailRequest = (EYI_BrochureCommunicationWrapper) JSON.deserialize(emailRequestJson, EYI_BrochureCommunicationWrapper.class);
        System.debug('Deserialized EmailRequestWrapper: ' + emailRequest);        
        Id leadId = emailRequest.leadId;
        String projectName = emailRequest.projectName;
        Id projectId = emailRequest.projectId;
        String senderEmail = emailRequest.senderEmail;
        String senderPhone = emailRequest.senderPhone;
        List<String> selectedFileIds = emailRequest.selectedFileIds;
        String messageBody = emailRequest.messageBody;
        String emailSubject = emailRequest.emailSubject;
        System.debug('selectedFileIds: ' + selectedFileIds);
            // Query the files based on the selectedFileIds
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            // Query the ContentVersion based on the selected FileIds
            List<ContentVersion> contentVersions = [
                    SELECT Id, Title, VersionData, FileExtension,ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :selectedFileIds
                ];
            System.debug('ContentVersion: ===>' + contentVersions.size());
        OrgWideEmailAddress owea = [
    SELECT Id, Address, DisplayName
    FROM OrgWideEmailAddress
    WHERE Address = 'sales@panchshil.com'
    LIMIT 1
];
            // Loop through the content versions and create file attachments
            for (ContentVersion cv : contentVersions) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.Title + '.' + cv.FileExtension); // Set the file name with extension
                attachment.setBody(cv.VersionData); // Set the file content (binary data)
                attachments.add(attachment);
            }
            // Send email with attachments
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {senderEmail});
            mail.setSubject(emailSubject);
            mail.setPlainTextBody(messageBody);
            mail.setFileAttachments(attachments);
            mail.setWhatId(leadId); // Attach the files
            // Send the email
            mail.setOrgWideEmailAddressId(owea.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Email sent successfully with ' + attachments.size() + ' attachments.');
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error occurred while sending email: ' + e.getMessage());
        }
    }

    public static Map<Id, List<ContentVersion>> getAllContentDocumentsByRecordId(List<Id> recordIds) {
        Map<Id, List<ContentVersion>> projectAttachmentsMap = new Map<Id, List<ContentVersion>>();

        if (recordIds == null || recordIds.isEmpty()) {
            return projectAttachmentsMap;
        }

        // Allowed titles from label
        List<String> allowedTitles = System.Label.EYI_Default_Brochures_Label.split(',');

        // Query ContentDocumentLink for all recordIds
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :recordIds
        ];

        if (contentDocumentLinks.isEmpty()) {
            return projectAttachmentsMap;
        }

        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        // Query ContentVersion by ContentDocumentId
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, VersionData, FileExtension, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            AND IsLatest = true
        ];

        for (ContentVersion cv : contentVersions) {
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                if (cdl.ContentDocumentId == cv.ContentDocumentId) {
                    if (!projectAttachmentsMap.containsKey(cdl.LinkedEntityId)) {
                        projectAttachmentsMap.put(cdl.LinkedEntityId, new List<ContentVersion>());
                    }
                    projectAttachmentsMap.get(cdl.LinkedEntityId).add(cv);
                }
            }
        }
        return projectAttachmentsMap;
    }

}