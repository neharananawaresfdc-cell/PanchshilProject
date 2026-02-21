declare module "@salesforce/apex/EYI_CifFormCreation.getUserProjects" {
  export default function getUserProjects(param: {user: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getLeads" {
  export default function getLeads(param: {cont: any, proj: any, cc: any, emailid: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getCIFs" {
  export default function getCIFs(param: {cont: any, proj: any, cc: any, emailid: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getLeadData" {
  export default function getLeadData(param: {cont: any, proj: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getLeadphone" {
  export default function getLeadphone(param: {cont: any, cc: any, emailid: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getLead" {
  export default function getLead(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getOpportunity" {
  export default function getOpportunity(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getCampaigns" {
  export default function getCampaigns(param: {Source: any, Subsource: any, developer: any, project: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.createOpportunityTeams" {
  export default function createOpportunityTeams(param: {OppId: any, userId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getProject" {
  export default function getProject(param: {projName: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getProjectById" {
  export default function getProjectById(param: {projId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.createLead" {
  export default function createLead(param: {cif: any, projectName: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.createrec" {
  export default function createrec(param: {cifRec: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.sendOTPEmailForCif" {
  export default function sendOTPEmailForCif(param: {email: any, phNo: any, countryCode: any, cifId: any, projectName: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.createCIF" {
  export default function createCIF(param: {cifRec: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getProjects" {
  export default function getProjects(): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getSubProjects" {
  export default function getSubProjects(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getTowers" {
  export default function getTowers(param: {projectId: any, subProjId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getRecTypes" {
  export default function getRecTypes(param: {proj: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.searchElements" {
  export default function searchElements(param: {objectName: any, fields: any, searchTerm: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.updateSMOnOpp" {
  export default function updateSMOnOpp(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_CifFormCreation.getCountryPhonePatterns" {
  export default function getCountryPhonePatterns(): Promise<any>;
}
