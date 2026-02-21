declare module "@salesforce/apex/EYI_TowerUtility.getOpportunities" {
  export default function getOpportunities(param: {towerId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_TowerUtility.getEmailTemplates" {
  export default function getEmailTemplates(): Promise<any>;
}
declare module "@salesforce/apex/EYI_TowerUtility.getTowerDocuments" {
  export default function getTowerDocuments(param: {towerIds: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_TowerUtility.sendEmails" {
  export default function sendEmails(param: {opportunityIds: any, documentIds: any, subject: any, body: any}): Promise<any>;
}
