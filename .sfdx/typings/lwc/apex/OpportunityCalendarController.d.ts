declare module "@salesforce/apex/OpportunityCalendarController.getAvailableTimeSlots" {
  export default function getAvailableTimeSlots(param: {selectedDate: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityCalendarController.updateEventWithOpportunity" {
  export default function updateEventWithOpportunity(param: {eventId: any, opportunityId: any, isRecheduled: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityCalendarController.checkIfOpportunityLinked" {
  export default function checkIfOpportunityLinked(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityCalendarController.unlinkOpportunityFromEvent" {
  export default function unlinkOpportunityFromEvent(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpportunityCalendarController.createEvent" {
  export default function createEvent(param: {startDatetime: any, endDatetime: any, recordId: any}): Promise<any>;
}
