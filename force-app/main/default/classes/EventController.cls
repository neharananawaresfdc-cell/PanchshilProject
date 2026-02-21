public class EventController {
@AuraEnabled
public static void saveEvents(List<Map<String, Object>> eventList, String selectedSlotType) {
    System.debug('Received events: ' + eventList);

    List<Event> eventRecords = new List<Event>();
    
    for (Map<String, Object> eventRec : eventList) {
        System.debug('Event start: ' + eventRec.get('startDateTime'));
        System.debug('Event end: ' + eventRec.get('endDateTime'));

        Event eventRecord = new Event();
        
        eventRecord.OwnerId = UserInfo.getUserId();
        
        if(selectedSlotType == 'Registration'){
            eventRecord.Registration_Status__c = 'Scheduled';
            eventRecord.Subject = 'Registration Slot';
            eventRecord.IsRegistrationScheduled__c = true;
        }
        if(selectedSlotType == 'DigitMatrix'){
            eventRecord.Subject = 'Digital Matrix Slot';
            eventRecord.EYI_IsDigitalSlotScheduled__c = true;
        }
        
        Map<String, Object> startDateTimeComponents = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eventRec.get('startDateTime')));
        Map<String, Object> endDateTimeComponents = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eventRec.get('endDateTime')));

        if (startDateTimeComponents != null && endDateTimeComponents != null) {
            try {
                Integer startYear = (Integer) startDateTimeComponents.get('year');
                Integer startMonth = (Integer) startDateTimeComponents.get('month');
                Integer startDay = (Integer) startDateTimeComponents.get('day');
                Integer startHour = (Integer) startDateTimeComponents.get('hour');
                Integer startMinute = (Integer) startDateTimeComponents.get('minute');
                Integer startSecond = (Integer) startDateTimeComponents.get('second');
                
                Integer endYear = (Integer) endDateTimeComponents.get('year');
                Integer endMonth = (Integer) endDateTimeComponents.get('month');
                Integer endDay = (Integer) endDateTimeComponents.get('day');
                Integer endHour = (Integer) endDateTimeComponents.get('hour');
                Integer endMinute = (Integer) endDateTimeComponents.get('minute');
                Integer endSecond = (Integer) endDateTimeComponents.get('second');

                eventRecord.StartDateTime = DateTime.newInstance(startYear, startMonth, startDay, startHour, startMinute, startSecond);
                eventRecord.EndDateTime = DateTime.newInstance(endYear, endMonth, endDay, endHour, endMinute, endSecond);

                eventRecords.add(eventRecord);
            } catch (Exception e) {
                System.debug('Error creating DateTime: ' + e.getMessage());
            }
        } else {
            System.debug('Invalid start or end date-time components');
        }
    } 
    if (!eventRecords.isEmpty()) {
        insert eventRecords;
    }
}


}