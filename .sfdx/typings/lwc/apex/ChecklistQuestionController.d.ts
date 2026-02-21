declare module "@salesforce/apex/ChecklistQuestionController.getOppRecord" {
  export default function getOppRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId" {
  export default function getChecklistItemsByRecordId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getOpportunityDetails" {
  export default function getOpportunityDetails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getBookingDetails" {
  export default function getBookingDetails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getQuestions" {
  export default function getQuestions(): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.submitChecklistCancellationItems" {
  export default function submitChecklistCancellationItems(param: {recordId: any, isSubmit: any, checkListLabel: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.submitChecklistInvoiceItems" {
  export default function submitChecklistInvoiceItems(param: {recordId: any, isSubmit: any, checkListLabel: any, invoiceStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.submitChecklistAdminItems" {
  export default function submitChecklistAdminItems(param: {recordId: any, isSubmit: any, checkListLabel: any, adminChecklistStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.saveInvoiceStatus" {
  export default function saveInvoiceStatus(param: {recordId: any, invoiceStatus: any, checklistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.saveInvoiceSubmissionStatus" {
  export default function saveInvoiceSubmissionStatus(param: {recordId: any, isSubmitted: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.saveChecklistItemsCancellation" {
  export default function saveChecklistItemsCancellation(param: {checklistItems: any, recordId: any, isSubmit: any, checklistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.submitChecklistItems" {
  export default function submitChecklistItems(param: {recordId: any, isSubmit: any, checkListLabel: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.saveChecklistItems" {
  export default function saveChecklistItems(param: {checklistItems: any, recordId: any, bookingFormStatus: any, bookingFormRejection: any, isSubmit: any, checklistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.updateOppRecord" {
  export default function updateOppRecord(param: {recordId: any, checklistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.saveRemark" {
  export default function saveRemark(param: {recordId: any, remark: any, checklistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.saveBookingStatus" {
  export default function saveBookingStatus(param: {recordId: any, bookingFormStatus: any, checklistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.findBookingForm" {
  export default function findBookingForm(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getCHIFDetails" {
  export default function getCHIFDetails(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.createCHIFDetails" {
  export default function createCHIFDetails(param: {oppId: any, towerId: any, projectId: any, onBehalf: any, type: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getRECDetails" {
  export default function getRECDetails(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getBrokerageDetails" {
  export default function getBrokerageDetails(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getChecklistItems" {
  export default function getChecklistItems(param: {opportunityId: any, checklistType: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.getBankDetailsByREC" {
  export default function getBankDetailsByREC(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.updatePreCancellationSubmissionStatus" {
  export default function updatePreCancellationSubmissionStatus(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChecklistQuestionController.updateOpportunityPostCancellationFields" {
  export default function updateOpportunityPostCancellationFields(param: {opportunityId: any, userId: any}): Promise<any>;
}
