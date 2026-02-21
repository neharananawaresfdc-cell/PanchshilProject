trigger EYI_BookingTrigger on EYI_Booking__c (after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_BookingTrigger').EYI_Active__c){
    if (Trigger.isAfter && Trigger.isUpdate) {
        EYI_CreateDemandTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    }

}