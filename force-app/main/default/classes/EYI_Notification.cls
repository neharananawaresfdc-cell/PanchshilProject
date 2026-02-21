/**
 * @description       : Wrapper Class for Notification Data
 * @author            : Abhishek Verma
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Digambar Ganage
**/

public with sharing class EYI_Notification {
    @InvocableVariable public String channelType;
    @InvocableVariable public String recipient;
    @InvocableVariable public String message;
    @InvocableVariable public String attachmentLink;
    @InvocableVariable public String recordId;
    @InvocableVariable public String projectId;
    @InvocableVariable public String recordOwnerId;
    @InvocableVariable public String emailTemplateName;
    public Map<String, Object> changedFields; // New field for changed fields
    @InvocableVariable public String notificationName;	
    public List<EYI_MergeFieldsWrapper> mergeFieldsList;

    // Other relevant fields
}