declare module "@salesforce/apex/EYI_LeadConvertionClass.updateLeadOnCIF" {
  export default function updateLeadOnCIF(param: {cifId: any, recId: any, leadEnquiryId: any, opptId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadConvertionClass.updatesOnLeadEnquiry" {
  export default function updatesOnLeadEnquiry(param: {oppId: any, leadEnquiryId: any, recId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_LeadConvertionClass.convertLeadEnquiryToOpp" {
  export default function convertLeadEnquiryToOpp(param: {CIFId: any}): Promise<any>;
}
