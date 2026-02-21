public with sharing class EYI_BrochureCommunicationWrapper {
    public Id leadId { get; set; }
    public String projectName { get; set; }
    public Id projectId { get; set; }
    public String senderEmail { get; set; }
    public String ccEmails { get; set; }
    public String senderPhone { get; set; }
    public List<String> selectedFileIds { get; set; }
    public String messagebody{get;set;}
    public String emailSubject{get;set;}

    public EYI_BrochureCommunicationWrapper(){
        System.debug('EYI_BrochureCommunicationWrapper');
    }
}