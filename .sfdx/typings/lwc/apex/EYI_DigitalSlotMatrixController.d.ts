declare module "@salesforce/apex/EYI_DigitalSlotMatrixController.getOpportunity" {
  export default function getOpportunity(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DigitalSlotMatrixController.getDateRangeFromSettings" {
  export default function getDateRangeFromSettings(): Promise<any>;
}
declare module "@salesforce/apex/EYI_DigitalSlotMatrixController.checkIfOpportunityLinked" {
  export default function checkIfOpportunityLinked(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DigitalSlotMatrixController.getBookingStatus" {
  export default function getBookingStatus(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DigitalSlotMatrixController.getAvailableTimeSlots" {
  export default function getAvailableTimeSlots(param: {selectedDate: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DigitalSlotMatrixController.updateEventWithOpportunity" {
  export default function updateEventWithOpportunity(param: {eventTime: any, opportunityId: any, selectedDate: any, resscheduleremark: any}): Promise<any>;
}
