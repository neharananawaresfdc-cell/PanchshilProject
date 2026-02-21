public with sharing class EYI_OpportunityUtility {
    @AuraEnabled
    public static opportunity getOpportunityInfo(String oppId) {
        return [SELECT Id,  EYI_Project_Enquired__c ,EYI_Email__c,EYI_Project_Tower_Enquired__c
                FROM Opportunity 
                WHERE Id = :oppId 
                LIMIT 1];
    }

    @AuraEnabled
    public static List<EYI_LeadEnquiryUtility.FileInfo> getFilesByOpportunityId(String oppId, String oppProjectId,String towerId) {
        List<EYI_LeadEnquiryUtility.FileInfo> files = new List<EYI_LeadEnquiryUtility.FileInfo>();
        // List of ContentDocumentIds
        List<Id> documentIds = new List<Id>();
        if(oppId!=null && oppId!=''){
            documentIds.add(oppId);
        }
        if(oppProjectId!=null && oppProjectId!=''){
            documentIds.add(oppProjectId);
        }
        if(towerId!=null && towerId!=''){
            documentIds.add(towerId);
        }
      
        // Query ContentDocumentLink to find related files to the Lead based on ProjectId
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :documentIds
        ];        
        for (ContentDocumentLink link : docLinks) {
            // Retrieve the file details
            files.add(new EYI_LeadEnquiryUtility.FileInfo(link.ContentDocumentId, link.ContentDocument.Title));
        }
        return files;
    }

    @AuraEnabled
    public static List<EmailTemplate> getOpportunityEmailTemplates(String templateName) {
        //List<String> folderNames = new List<String>{System.Label.EYI_Brochure_Email_Templates};
        return [SELECT id,Name,Folder.Name FROM EmailTemplate WHERE Folder.Name = :templateName];
    }
    // @AuraEnabled
    // public static List<EmailTemplate> getOpportunityEmailTemplates(String templateName) {
    //     List<String> folderNames = new List<String>{System.Label.EYI_Brochure_Email_Templates};
    //     return [SELECT id,Name,Folder.Name FROM EmailTemplate WHERE Folder.Name IN :folderNames];

    // }
    
    @AuraEnabled
    public static void updateOppNCFSentDate(String oppId) {
        try{
           
            Opportunity opp = new Opportunity(Id=oppId);
            opp.EYI_Welcome_Letter_NCF_Sent_Date__c = System.now().date();
            opp.EYI_AutomationBypassDatetime__c = System.now();
            System.debug('Error EYI_Welcome_Letter_NCF_Sent_Date__c:'+ opp);
            update opp;
            System.debug('Error EYI_Welcome_Letter_NCF_Sent_Date__c:'+ opp);

        }catch(Exception e){
            System.debug('Error updating sent date: ' + e.getMessage());
        }
    }
}