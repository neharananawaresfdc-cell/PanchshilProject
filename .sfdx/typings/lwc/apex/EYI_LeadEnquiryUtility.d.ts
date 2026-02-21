declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getLeadInfo" {
  export default function getLeadInfo(param: {leadEnqId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getFilesByProjectId" {
  export default function getFilesByProjectId(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getEmailTemplates" {
  export default function getEmailTemplates(): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getEmailTemplateDetails" {
  export default function getEmailTemplateDetails(param: {templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getLeadStatusTime" {
  export default function getLeadStatusTime(param: {leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getLeadEnquiries" {
  export default function getLeadEnquiries(): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getBulkEmailTemplates" {
  export default function getBulkEmailTemplates(): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getLeadDocuments" {
  export default function getLeadDocuments(param: {leadIds: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.sendEmails" {
  export default function sendEmails(param: {leadEnquiryIds: any, documentIds: any, subject: any, body: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.getGroupedValues" {
  export default function getGroupedValues(param: {objectName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadEnquiryUtility.queryObjectsByFields" {
  export default function queryObjectsByFields(param: {objectApiName: any, fieldValuesMap: any}): Promise<any>;
}
