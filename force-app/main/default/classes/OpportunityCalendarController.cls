public without sharing class OpportunityCalendarController {
    // Wrapper class with @AuraEnabled for Lightning components
    public class EventResult {
    @AuraEnabled public List<Map<String, String>> availableEvents { get; set; }
    @AuraEnabled public List<Map<String, String>> bookedEvents { get; set; }

    public EventResult() {
        availableEvents = new List<Map<String, String>>();
        bookedEvents = new List<Map<String, String>>();
    }
    }

    @AuraEnabled
    public static EventResult getAvailableTimeSlots(Date selectedDate) {
        EventResult result = new EventResult();

        // Get today's date
        Date today = Date.today();
        List<Event> eventList = new List<Event>();

        // Check if selectedDate is equal to today's date
        if (selectedDate == today) {
            // If selectedDate is today, filter by StartDateTime > System.now()
             eventList = [SELECT Id, WhatId, IsRegistrationScheduled__c, Registration_Status__c, 
                                  StartDateTime, EndDateTime
                                  FROM Event 
                                  WHERE ActivityDate = :selectedDate 
                                  AND IsRegistrationScheduled__c = true 
                                  AND (Registration_Status__c = 'Scheduled' OR Registration_Status__c = 'Re-Scheduled') 
                                  AND StartDateTime > :System.now()
                         AND OwnerId = :UserInfo.getUserId()];  // Only events that start after the current time
                                  
            
        } else {
            // If selectedDate is in the future, show all events
             eventList = [SELECT Id, WhatId, IsRegistrationScheduled__c, Registration_Status__c, 
                                  StartDateTime, EndDateTime
                                  FROM Event 
                                  WHERE ActivityDate = :selectedDate 
                                  AND IsRegistrationScheduled__c = true 
                                  AND (Registration_Status__c = 'Scheduled' OR Registration_Status__c = 'Re-Scheduled') AND OwnerId = :UserInfo.getUserId()];
        }
        for (Event evt : eventList) {
                Map<String, String> eventMap = new Map<String, String>();
                eventMap.put('Id', evt.Id);
                eventMap.put('WhatId', String.valueOf(evt.WhatId));
                eventMap.put('StartDateTime', evt.StartDateTime.format('h:mm a'));  // Format Start DateTime
                eventMap.put('EndDateTime', evt.EndDateTime.format('h:mm a'));      // Format End DateTime
                eventMap.put('IsRegistrationScheduled', String.valueOf(evt.IsRegistrationScheduled__c));
                eventMap.put('RegistrationStatus', String.valueOf(evt.Registration_Status__c));

                if (evt.WhatId == null) {
                    result.availableEvents.add(eventMap);
                } else if (evt.WhatId != null && String.valueOf(evt.WhatId).startsWith('006')) {
                    result.bookedEvents.add(eventMap);
                }
            }

        return result;
    }


    
     @AuraEnabled
    public static void updateEventWithOpportunity(String eventId, String opportunityId, boolean isRecheduled) {
        // Retrieve the event by Id
        Event evt = [SELECT Id,Subject,WhatId,StartDateTime,EndDateTime,OwnerId FROM Event WHERE Id = :eventId LIMIT 1];
        Opportunity oppRec = [Select Id,EYI_Registration_Status__c,Registration_Date__c,EYI_Registration_Scheduled_Date__c from Opportunity Where Id =:opportunityId];
        List<Event> eventList = new List<event>();
        // Link the Opportunity to the Event by updating WhatId
      	System.debug('evt.WhatId : '+evt.WhatId);
        if(evt.WhatId == null){
            System.debug('evt.WhatId == null ');
            evt.WhatId = opportunityId;
            if(isRecheduled == true){
                 System.debug('isRecheduled+::: '+isRecheduled);
            	evt.Registration_Status__c = 'Re-Scheduled';
                oppRec.EYI_Registration_Status__c = 'Registration Rescheduled';
            }else{
                oppRec.EYI_Registration_Status__c = 'Registration Scheduled';
            }
            oppRec.EYI_Registration_Scheduled_Date__c = evt.StartDateTime;
            eventList.add(evt);
        }else{
            System.debug('evt.WhatId != null ');
           Event eventRec = new Event();
           eventRec.Subject = evt.Subject;
           eventRec.WhatId = opportunityId;
           eventRec.OwnerId = evt.OwnerId;
           eventRec.IsRegistrationScheduled__c = true;
           eventRec.StartDateTime = evt.StartDateTime;
           eventRec.EndDateTime = evt.EndDateTime;
		   if(isRecheduled == true){
            	eventRec.Registration_Status__c = 'Re-Scheduled';
                oppRec.EYI_Registration_Status__c = 'Registration Rescheduled'; 
           }else{
           		eventRec.Registration_Status__c = 'Scheduled';
                oppRec.EYI_Registration_Status__c = 'Registration Scheduled'; 
           } 
            oppRec.EYI_Registration_Scheduled_Date__c = eventRec.StartDateTime;

            eventList.add(eventRec);
        }
        System.debug('eventList :: '+eventList);
        
        upsert eventList;
        update oppRec;
    }
    @AuraEnabled
public static Map<String, Object> checkIfOpportunityLinked(Id opportunityId) {
    System.debug('opportunityId ::: '+opportunityId);
    Map<String, Object> result = new Map<String, Object>();

    // Query for the linked event where the Opportunity is attached
    Event event = [SELECT Id, StartDateTime, EndDateTime, whatId, IsRegistrationScheduled__c, Registration_Status__c 
                   FROM Event 
                   WHERE whatId = :opportunityId AND IsRegistrationScheduled__c = true AND (Registration_Status__c = 'Scheduled' OR Registration_Status__c = 'Re-Scheduled') LIMIT 1];

    // Check the conditions
    if (event != null && event.IsRegistrationScheduled__c == true && (event.Registration_Status__c == 'Scheduled' || event.Registration_Status__c == 'Re-Scheduled')) {
        result.put('opportunityName', [SELECT Name FROM Opportunity WHERE Id = :opportunityId LIMIT 1].Name);

        // Format the event date and time to 12-hour format with AM/PM
        String eventDate = event.StartDateTime.format('dd-MM-yyyy');
        String eventStartTime = event.StartDateTime.format('h:mm a'); // Format as 3:00 PM
        String eventEndTime = event.EndDateTime.format('h:mm a'); // Format as 4:00 PM

        result.put('eventDate', eventDate);
        result.put('eventStartTime', eventStartTime);
        result.put('eventEndTime', eventEndTime);
        result.put('registrationStatus', event.Registration_Status__c);
        return result;
    }else{
        return null;
    }
}



    @AuraEnabled
    public static void unlinkOpportunityFromEvent(Id opportunityId) {
        // Query the event linked to the Opportunity
        List<Event> eventsToUnlink = [SELECT Id, whatId,Registration_Status__c FROM Event WHERE whatId = :opportunityId AND IsRegistrationScheduled__c = true AND (Registration_Status__c = 'Scheduled' OR Registration_Status__c = 'Re-Scheduled') LIMIT 1];
		System.debug('eventsToUnlink : '+eventsToUnlink);
        System.debug('eventsToUnlink : '+eventsToUnlink.size());
        if(eventsToUnlink.size() > 0){
            Event eventToUpdate = eventsToUnlink[0];
        	eventToUpdate.whatId = null;
            eventToUpdate.Registration_Status__c = 'Scheduled';
            update eventToUpdate;
        }
    }
    
    @AuraEnabled
    public static String createEvent(String startDatetime, String endDatetime, Id recordId) {
        try {
            // Parse the passed datetime strings into DateTime objects
            startDatetime = startDatetime.replace('T', ' ').substring(0, startDatetime.indexOf('.'));
            endDatetime = endDatetime.replace('T', ' ').substring(0, endDatetime.indexOf('.'));
            
            // Now parse the cleaned strings into DateTime objects
            DateTime actualStartDateTime = DateTime.valueOf(startDatetime);
            DateTime actualEndDateTime = DateTime.valueOf(endDatetime);

            // Log for debugging (Optional)
            system.debug('actualStartDateTime: ' + actualStartDateTime);
            system.debug('actualEndDateTime: ' + actualEndDateTime);
            /*Map<String, Object> startDateTimeComponents = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(startDatetime));
            Map<String, Object> endDateTimeComponents = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(endDatetime));
            system.debug('startDateTimeComponents '+startDateTimeComponents);
            system.debug('endDateTimeComponents '+endDateTimeComponents);
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

              */  
            // Check if start date is before end date
            
            Opportunity oppRec = [Select Id,EYI_Registration_Status__c,Registration_Date__c,EYI_Registration_Scheduled_Date__c from Opportunity Where Id =:recordId];
            // Create a new Event record
            Event eventRecord = new Event();
            eventRecord.Subject = 'Registration Slot';// You can modify this dynamically as needed
            eventRecord.StartDateTime = actualStartDateTime;
            eventRecord.EndDateTime = actualEndDateTime;
            eventRecord.OwnerId = UserInfo.getUserId();
            eventRecord.WhatId = recordId;
            eventRecord.IsRegistrationScheduled__c = true;
            oppRec.EYI_Registration_Scheduled_Date__c = eventRecord.StartDateTime;
            if(oppRec.EYI_Registration_Status__c == null || oppRec.EYI_Registration_Status__c == 'Registration Pending' ){
                eventRecord.Registration_Status__c = 'Scheduled';
                oppRec.EYI_Registration_Status__c = 'Registration Scheduled';
            }
            else if(oppRec.EYI_Registration_Status__c == 'Registration Scheduled' || oppRec.EYI_Registration_Status__c == 'Registration Rescheduled'){
                eventRecord.Registration_Status__c = 'Re-Scheduled';
                oppRec.EYI_Registration_Status__c = 'Registration Rescheduled';
            }
            
            
            // Insert the event record into Salesforce
            insert eventRecord;
            update oppRec;

            // Return the ID of the created event record
            return eventRecord.Id; 

        } catch (Exception e) {
            throw new AuraHandledException('Error in creating event: ' + e.getMessage());
        }
    }
    
}