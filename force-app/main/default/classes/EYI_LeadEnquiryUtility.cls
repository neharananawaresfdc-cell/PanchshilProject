public with sharing class EYI_LeadEnquiryUtility {
    @AuraEnabled(cacheable=true)
    public static EYI_Lead_Enquiry__c getLeadInfo(String leadEnqId) {
        return [SELECT Id, EYI_Parent_Record__c, EYI_Parent_Record__r.Email,EYI_Mobile__c, EYI_DND__c,EYI_Email__c,EYI_Phone__c,EYI_Alternate_Mobile_No__c
                    , EYI_Parent_Record__r.Phone, EYI_Project_Enquired__c, EYI_Client_Communication_Preference__c,Name,Owner.Name,Owner.Phone 
                FROM EYI_Lead_Enquiry__c 
                WHERE Id = :leadEnqId 
                LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static List<FileInfo> getFilesByProjectId(Id projectId) {
       // Create a list of FileInfo objects to return
        List<FileInfo> files = new List<FileInfo>();
        // List of ContentDocumentIds
        List<Id> documentIds = new List<Id>();
        documentIds.add(projectId);
      
        // Query ContentDocumentLink to find related files to the Lead based on ProjectId
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :documentIds
        ];        
        for (ContentDocumentLink link : docLinks) {
            // Retrieve the file details
            files.add(new FileInfo(link.ContentDocumentId, link.ContentDocument.Title));
        }
        return files;
    }

    
   
    
    // Wrapper class to return file information (file Id and Title)
    public class FileInfo {
        @AuraEnabled public String fileid;
        @AuraEnabled public String title;

        public FileInfo(String fileid, String title) {
            this.fileid = fileid;
            this.title = title;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplates() {
        return [SELECT id,Name,Folder.Name FROM EmailTemplate WHERE Folder.Name='Project Brochures'];
    }

    @AuraEnabled
    public static EmailTemplate getEmailTemplateDetails(Id templateId) {
        return [SELECT Subject, Body FROM EmailTemplate WHERE Id = :templateId LIMIT 1];
    }

    public class StatusWrapper {
        @AuraEnabled
        public String userName { get; set; } // User's name (String)
        @AuraEnabled
        public String status { get; set; }   // User's status (String)
        @AuraEnabled
        public Decimal timeSpent { get; set; } // Time spent (Number)
        @AuraEnabled
        public DateTime lastModified { get; set; } // Date last modified (DateTime)
        // Constructor to initialize the wrapper fields
        public StatusWrapper(String userName, String status, Decimal timeSpent, DateTime lastModified) {
            this.userName = userName;
            this.status = status;
            this.timeSpent = timeSpent;
            this.lastModified = lastModified;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<StatusWrapper> getLeadStatusTime(String leadId) {
        // Variables to track the previous lead status change
        Datetime previousChangeTime = null;
        String previousStatus = null;
        Id previousUserId = null;
        String userName='';
        Map<Id, String> userNameMap = new Map<Id, String>();
        Map<String, StatusWrapper> resultMap = new Map<String, StatusWrapper>();
        Integer timeSpent;
        List<EYI_Lead_Enquiry__History> leadHistories = [
            SELECT ParentId, CreatedById, Field, OldValue, NewValue, CreatedDate
            FROM EYI_Lead_Enquiry__History
            WHERE ParentId = :leadId 
            AND (Field = 'EYI_Lead_Status__c' OR Field = 'Created')
            ORDER BY CreatedDate
        ];
        userNameMap = getUsersForLeadHistory();
        for (Integer count = 0;  count < leadHistories.size(); count++) {
            if(count==0){
                userName = userNameMap.get(leadHistories[count].CreatedById);
                StatusWrapper sw = new StatusWrapper(userName,'Created',0,leadHistories[count].CreatedDate);
                resultMap.put('Created',sw);
                system.debug('resultMap 1===> '+sw);
            }else if(count==1){
                previousStatus = (String)leadHistories[count].OldValue;
                previousChangeTime = leadHistories[count].CreatedDate;
                userName = userNameMap.get(leadHistories[count].CreatedById);
                previousUserId = leadHistories[count].CreatedById;
                timeSpent = EYI_BusinessHoursUtility.getDateDiffInDays(leadHistories[count-1].CreatedDate, leadHistories[count].CreatedDate);
                StatusWrapper sw = new StatusWrapper(userName,previousStatus,timeSpent,previousChangeTime);
                system.debug('resultMap 2===> '+sw);
                resultMap.put(previousStatus,sw);
            }else{
                previousStatus = (String)leadHistories[count].OldValue;
                previousChangeTime = leadHistories[count].CreatedDate;
                previousUserId = leadHistories[count].CreatedById;
                timeSpent = EYI_BusinessHoursUtility.getDateDiffInDays(leadHistories[count-1].CreatedDate, leadHistories[count].CreatedDate);
                userName = userNameMap.get(leadHistories[count].CreatedById);
                if (resultMap.containsKey(previousStatus)) {
                    // If it exists, get the existing StatusWrapper
                    StatusWrapper existingSW = resultMap.get(previousStatus);
                    // Add the timeSpent to the existing time in StatusWrapper
                    existingSW.timeSpent = timeSpent+ existingSW.timeSpent;
                    // Update the last modified user ID in the existing StatusWrapper
                    existingSW.userName = userName;
                    // Set the new changeTime as the current changeTime
                    existingSW.lastModified = previousChangeTime;
                    // Put the updated StatusWrapper back into the map
                    resultMap.put(previousStatus, existingSW);
                    system.debug('resultMap 183===> '+existingSW);
                } else {
                    // If it doesn't exist, just put the new StatusWrapper into the map
                    StatusWrapper sw = new StatusWrapper(userName,previousStatus,timeSpent,previousChangeTime);
                    resultMap.put(previousStatus, sw);
                    system.debug('resultMap  188===> '+sw);
                }
                system.debug('timeSpent'+timeSpent);
            }
        }
        System.debug('resultList keyset ====> '+resultMap.keySet());
        System.debug('resultList Values ====> '+resultMap.values());
        return resultMap.Values();
    }

    // Method to get user names based on user IDs
    public static Map<Id, String> getUsersForLeadHistory() {
        // Create a map for userId to userName
        Map<Id, String> userNameMap = new Map<Id, String>();
        // Populate the map with User ID and Name
        for (User u : [SELECT Id, Name FROM User WHERE isactive = true]) {
            userNameMap.put(u.Id, u.Name);
        }
        // Return the map of User ID to User Name
        return userNameMap;
    }   
    //********************************************************List Email Changes 13/6/25***************************************************** */
    @AuraEnabled(cacheable=true)
    public static List<EYI_Lead_Enquiry__c> getLeadEnquiries() {
        return [SELECT Id, Name, EYI_Email__c FROM EYI_Lead_Enquiry__c WHERE EYI_Email__c!='' limit 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getBulkEmailTemplates() {
        return [SELECT Id, Name, Subject, HtmlValue, Body,Folder.DeveloperName FROM EmailTemplate WHERE  Folder.DeveloperName = 'Presales_Bulk_Email_Templates'];
    }
    @AuraEnabled
    public static List<ContentDocumentLink> getLeadDocuments(List<Id> leadIds) {
        return [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :leadIds
        ];
    }

    @AuraEnabled
    public static void sendEmails(List<Id> leadEnquiryIds, List<Id> documentIds, String subject, String body) {
        // Query valid opportunities with emails
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        System.debug('leadEnquiryIds == >'+leadEnquiryIds);
        System.debug('documentIds == >'+documentIds);
        System.debug('subject == >'+subject);
        System.debug('body == >'+body);
        List<EYI_Lead_Enquiry__c> enquries = [
            SELECT EYI_Email__c
            FROM EYI_Lead_Enquiry__c
            WHERE Id IN :leadEnquiryIds AND EYI_Email__c != null
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
        for (EYI_Lead_Enquiry__c enq : enquries) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{enq.EYI_Email__c});
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            if(documentIds.size()>0){
                mail.setFileAttachments(attachments);
            }
            mail.setSaveAsActivity(true); // Optional: log the email to activity history
            emailsToSend.add(mail);
            System.debug('Email to send ===>' + emailsToSend);
        }

        // Send all emails in bulk
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    @AuraEnabled
    public static Map<String, String> getGroupedValues(String objectName, String fieldName) {
    Map<String, String> optionMap = new Map<String, String>();

    // Get the field describe information
    Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
    Schema.DescribeFieldResult fieldDescribe = describeResult.fields.getMap().get(fieldName).getDescribe();

    // Check if the field is a lookup field
    if (fieldDescribe.getReferenceTo().size() > 0) {
        // Get the referenced object name
        String referencedObject = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
        // Query the referenced object for Id and Name
        String lookupQuery = 'SELECT Id, Name FROM ' + referencedObject;
        List<SObject> lookupResults = Database.query(lookupQuery);

        // Create a map of Id and Name for the referenced object
        Map<Id, String> lookupMap = new Map<Id, String>();
        for (SObject lookupResult : lookupResults) {
            lookupMap.put(lookupResult.Id, (String) lookupResult.get('Name'));
        }

        // Query the main object and group by the lookup field
        String query = 'SELECT ' + fieldName + ', COUNT(Id) cnt FROM ' + objectName + ' GROUP BY ' + fieldName;
        List<AggregateResult> results = Database.query(query);

        // Create the option map using the lookup map
        for (AggregateResult result : results) {
            Id fieldValue = (Id) result.get(fieldName);
            String fieldLabel = lookupMap.get(fieldValue);
            optionMap.put(fieldLabel,fieldValue);
        }
    } else {
        // Query the main object and group by the field
        String query = 'SELECT ' + fieldName + ', COUNT(Id) cnt FROM ' + objectName + ' GROUP BY ' + fieldName;
        List<AggregateResult> results = Database.query(query);

        // Create the option map
        for (AggregateResult result : results) {
            String fieldValue = String.valueOf(result.get(fieldName));
            optionMap.put(fieldValue, fieldValue);
        }
    }

    return optionMap;
    }

    @AuraEnabled
    public static List<SObject> queryObjectsByFields(String objectApiName, Map<String, List<String>> fieldValuesMap) {
    // Initialize the dynamic SOQL query
    String soqlQuery = 'SELECT Id,Name,EYI_Email__c';

    // Add all fields from the map to the SELECT clause
    for (String fieldName : fieldValuesMap.keySet()) {
        soqlQuery += ', ' + fieldName;
    }

    soqlQuery += ' FROM ' + objectApiName;

    // Initialize the WHERE clause
    String whereClause = '';
    for (String fieldName : fieldValuesMap.keySet()) {
        List<String> values = fieldValuesMap.get(fieldName);
        if (values != null && !values.isEmpty()) {
            // Add conditions for each value in the list
            for (String value : values) {
                if (String.isNotBlank(whereClause)) {
                    whereClause += ' OR ';
                }
                whereClause += fieldName + ' = \'' + String.escapeSingleQuotes(value) + '\'';
            }
        }
    }

    // Add the WHERE clause to the query if it's not empty
    if (String.isNotBlank(whereClause)) {
        soqlQuery += ' WHERE (' + whereClause + ')';
    }

    // Add the LIMIT clause
    soqlQuery += ' LIMIT 50000';

    // Execute the query and return the results
    return Database.query(soqlQuery);
}

}