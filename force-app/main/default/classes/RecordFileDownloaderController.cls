/**
* @description       : 
* @author            : Abhishek Verma
* @group             : 
* @last modified on  : 03-18-2025
* @last modified by  : Abhishek Verma
**/
public without sharing class RecordFileDownloaderController {
    @AuraEnabled
    public static List<Id> getfileIds(List<String> recordIds) {
        if (recordIds == null || recordIds.isEmpty()) {
            return new List<Id>();
        }

        Set<Id> contentDocumentIds = new Set<Id>();
        List<Id> contentVersionIds = new List<Id>();

        List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds AND ContentDocument.Title LIKE '%PANCARD_%' ];

        for (ContentDocumentLink cdl : docLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        if (!contentDocumentIds.isEmpty()) {
            List<ContentVersion> versions = [ SELECT Id FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN :contentDocumentIds ];

            for (ContentVersion cdv : versions) {
                contentVersionIds.add(cdv.Id);
            }
        }
        return contentVersionIds;
    }
}