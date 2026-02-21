@IsTest
public class EventControllerTest {

    @IsTest
    public static void testSaveEvents_ValidData() {
        // Prepare valid test data
        List<Map<String, Object>> eventList = new List<Map<String, Object>>();

        // Create mock event 1
        Map<String, Object> event1 = new Map<String, Object>();
        Map<String, Object> startDateTime1 = new Map<String, Object>();
        startDateTime1.put('year', 2023);
        startDateTime1.put('month', 12);
        startDateTime1.put('day', 10);
        startDateTime1.put('hour', 10);
        startDateTime1.put('minute', 0);
        startDateTime1.put('second', 0);
        
        Map<String, Object> endDateTime1 = new Map<String, Object>();
        endDateTime1.put('year', 2023);
        endDateTime1.put('month', 12);
        endDateTime1.put('day', 10);
        endDateTime1.put('hour', 12);
        endDateTime1.put('minute', 0);
        endDateTime1.put('second', 0);
        
        event1.put('startDateTime', startDateTime1);
        event1.put('endDateTime', endDateTime1);
        eventList.add(event1);

        // Create mock event 2
        Map<String, Object> event2 = new Map<String, Object>();
        Map<String, Object> startDateTime2 = new Map<String, Object>();
        startDateTime2.put('year', 2023);
        startDateTime2.put('month', 12);
        startDateTime2.put('day', 11);
        startDateTime2.put('hour', 14);
        startDateTime2.put('minute', 0);
        startDateTime2.put('second', 0);
        
        Map<String, Object> endDateTime2 = new Map<String, Object>();
        endDateTime2.put('year', 2023);
        endDateTime2.put('month', 12);
        endDateTime2.put('day', 11);
        endDateTime2.put('hour', 16);
        endDateTime2.put('minute', 0);
        endDateTime2.put('second', 0);
        
        event2.put('startDateTime', startDateTime2);
        event2.put('endDateTime', endDateTime2);
        eventList.add(event2);

        // Call the method to test
        Test.startTest();
        EventController.saveEvents(eventList, 'Registration');
        Test.stopTest();

        // Verify that events were inserted
        List<Event> insertedEvents = [SELECT Subject, StartDateTime, EndDateTime, Registration_Status__c, IsRegistrationScheduled__c
                                      FROM Event
                                      WHERE Subject = 'Registration Slot'];

        System.assertEquals(2, insertedEvents.size(), 'Two events should have been inserted.');
        System.assertEquals('Scheduled', insertedEvents[0].Registration_Status__c, 'The first event should have status Scheduled.');
        System.assert(insertedEvents[0].IsRegistrationScheduled__c, 'The first event should have IsRegistrationScheduled__c set to true.');
        System.assertEquals('Scheduled', insertedEvents[1].Registration_Status__c, 'The second event should have status Scheduled.');
        System.assert(insertedEvents[1].IsRegistrationScheduled__c, 'The second event should have IsRegistrationScheduled__c set to true.');
    }

    @IsTest
    public static void testSaveEvents_InvalidData() {
        // Prepare invalid test data (missing date-time components)
        List<Map<String, Object>> eventList = new List<Map<String, Object>>();

        // Event with missing start date-time
        Map<String, Object> eventInvalid = new Map<String, Object>();
        eventInvalid.put('startDateTime', null); // Invalid start date
        Map<String, Object> endDateTime = new Map<String, Object>();
        endDateTime.put('year', 2023);
        endDateTime.put('month', 12);
        endDateTime.put('day', 10);
        endDateTime.put('hour', 12);
        endDateTime.put('minute', 0);
        endDateTime.put('second', 0);
        eventInvalid.put('endDateTime', endDateTime);
        eventList.add(eventInvalid);

        // Call the method to test
        Test.startTest();
        EventController.saveEvents(eventList, 'Registration');
        Test.stopTest();

        // Verify that no events were inserted
        List<Event> insertedEvents = [SELECT Id FROM Event WHERE Subject = 'Registration Slot'];
        System.assertEquals(0, insertedEvents.size(), 'No events should have been inserted for invalid data.');
    }

}