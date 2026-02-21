declare module "@salesforce/apex/EYI_CampaignUtility.getLeadEnquiries" {
  export default function getLeadEnquiries(param: {campaignId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CampaignUtility.getEmailTemplates" {
  export default function getEmailTemplates(): Promise<any>;
}
declare module "@salesforce/apex/EYI_CampaignUtility.getProjectDocuments" {
  export default function getProjectDocuments(param: {projectIds: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CampaignUtility.sendEmails" {
  export default function sendEmails(param: {leadEnqIds: any, documentIds: any, subject: any, body: any}): Promise<any>;
}
