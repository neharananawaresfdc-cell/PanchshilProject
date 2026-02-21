declare module "@salesforce/apex/EYI_OpportunityUtility.getOpportunityInfo" {
  export default function getOpportunityInfo(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_OpportunityUtility.getFilesByOpportunityId" {
  export default function getFilesByOpportunityId(param: {oppId: any, oppProjectId: any, towerId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_OpportunityUtility.getOpportunityEmailTemplates" {
  export default function getOpportunityEmailTemplates(param: {templateName: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_OpportunityUtility.updateOppNCFSentDate" {
  export default function updateOppNCFSentDate(param: {oppId: any}): Promise<any>;
}
