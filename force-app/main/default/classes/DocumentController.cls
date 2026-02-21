public class DocumentController {
    
    @AuraEnabled
    public static void saveDocument(String fileContent, String fileName, Id recordId) {
        System.debug('recordId : '+recordId);
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = EncodingUtil.base64Decode(fileContent);
        insert contentVersion;
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        contentDocumentLink.LinkedEntityId = recordId;
        contentDocumentLink.ShareType = 'V'; // Viewer permission
        insert contentDocumentLink;
        
		// Check if the file contains "Old NOC" and then send system notification
        if (fileName.containsIgnoreCase('Old NOC')) {
            sendNotificationToManager(recordId, fileName);
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> getDocumentTrackerRecords(Id recordId) {
        
        List<DocumentWrapper> documentWrappers = new List<DocumentWrapper>();
        
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
        if (!contentDocumentLinks.isEmpty()) {
            for (ContentDocumentLink link : contentDocumentLinks) {
                ContentDocument contentDocument = [
                    SELECT Id, Title,FileExtension,CreatedDate
                    FROM ContentDocument 
                    WHERE Id = :link.ContentDocumentId
                ];
                
                documentWrappers.add(new DocumentWrapper(contentDocument.Title,contentDocument.Id,contentDocument.FileExtension,contentDocument.CreatedDate));
            }
        }
        return documentWrappers;
    }
    
    public class DocumentWrapper {
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String ContentDocumentId { get; set; }
        @AuraEnabled public String FileExtension { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        
        public DocumentWrapper(String Name, String ContentDocumentId, String FileExtension, DateTime createdDate) {
            this.Name = Name;
            this.ContentDocumentId = ContentDocumentId;
            this.FileExtension = FileExtension;
            this.createdDate = createdDate;
        }
    }
    @AuraEnabled
    public static void deleteDocument(Id contentDocumentId){
         
        List<ContentDocument> contentDocuments = new List<ContentDocument> ();
        
             contentDocuments = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id = :contentDocumentId
            ];

         if (!contentDocuments.isEmpty()) {
            delete contentDocuments;
        }
        
    }

    private static void sendNotificationToManager(Id recordId, String fileName) {
        SObject record = Database.query('SELECT OwnerId FROM ' + recordId.getSObjectType() + ' WHERE Id = :recordId LIMIT 1');
        Id ownerId = (Id) record.get('OwnerId');
        
        User ownerUser = [SELECT Id, ManagerId FROM User WHERE Id = :ownerId LIMIT 1];
        Id managerId = ownerUser.ManagerId;
    
        Id secondLevelManagerId = null;
        
        if (managerId != null) {
            User managerUser = [SELECT Id, ManagerId FROM User WHERE Id = :managerId LIMIT 1];
            secondLevelManagerId = managerUser.ManagerId;
        }
    
        CustomNotificationType cnType = [
            SELECT Id FROM CustomNotificationType 
            WHERE DeveloperName = 'Old_NOC_Document_Upload_Alert' LIMIT 1
        ];
    
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setBody('A Old NOC document "' + fileName + '" has been uploaded to Loan record.');
        customNotificationObj.setTitle('Loan Record - Old NOC Document Uploaded');
        customNotificationObj.setNotificationTypeId(cnType.Id);
        customNotificationObj.setSenderId(UserInfo.getUserId());
        customNotificationObj.setTargetId(recordId);
        
        Set<String> recipientIds = new Set<String>{ownerId};
        
        if (managerId != null) {
            recipientIds.add(managerId);
        }
        if (secondLevelManagerId != null) {
            recipientIds.add(secondLevelManagerId);
        }
    
        if (!recipientIds.isEmpty()) {
            customNotificationObj.send(recipientIds);
            System.debug('Notification sent to: ' + recipientIds);
        } else {
            System.debug('No recipients found for notification.');
        }
    }
    
}