@isTest
public class EYI_DigitalSlotMatrixControllerTest {

    @testSetup
    static void setupData() {
        // Create users first
        createUsers();
    }
    
    static void createUsers() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole LIMIT 1];
        String unique = String.valueOf(DateTime.now().getTime());
        
        User relMgr = new User(
            Username = 'relmgr' + unique + '@test.com',
            Alias = 'relm' + unique.left(4),
            Email = 'relmgr' + unique + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'RelMgr',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            UserRoleId = role.Id
        );
        insert relMgr;

        User u = new User(
            Username = 'testuser' + unique + '@test.com',
            Alias = 'test' + unique.left(4),
            Email = 'testuser' + unique + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            UserRoleId = role.Id
        );
        insert u;

        System.runAs(u) {
            Account acc = new Account(Name = 'Test Account');
            insert acc;

            Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Email = 'contact' + unique + '@test.com');
            insert con;

            // Create Opportunity with all required fields
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                OwnerId = UserInfo.getUserId(),
                AccountId = acc.Id,
                EYI_Digital_Slot_Booking_Send_Time__c = System.now(),
                EYI_Ownership_Status__c = 'Accepted',
                EYI_IsUnitTransferred__c = false,
                EYI_Digital_Slot_Status__C = 'Digital Slot Scheduled',
                EYI_Digital_Slot_Schedule_Time__c = System.now().addDays(1),
                EYI_Digital_Slot_Re_Schedule_Time__c = System.now().addDays(2),
                EYI_Relationship_Manager__c = relMgr.Id,
                EYI_Digital_Slot_Re_Schedule_Count__c = 0
            );
            insert opp;

            // Create Event not linked yet
            Event ev = new Event(
                WhatId = null,
                StartDateTime = System.now().addHours(1),
                EndDateTime = System.now().addHours(2),
                Subject = 'Digital Matrix Slot',
                EYI_IsDigitalSlotScheduled__c = true,
                OwnerId = relMgr.Id,
                IsRegistrationScheduled__c = true,
                Registration_Status__c = 'Scheduled',
                ActivityDate = Date.today()
            );
            insert ev;
        }
    }

    static void createCustomSetting() {
        // Create custom setting (only when needed)
        XAndYMatrix__c setting = new XAndYMatrix__c();
        setting.X__c = 1;
        setting.Y__c = 30;
        setting.EYI_Time_Interval__c = 1;
        insert setting;
    }

    @isTest
    static void testGetOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        Opportunity result = EYI_DigitalSlotMatrixController.getOpportunity(opp.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetDateRangeFromSettings() {
        createCustomSetting();
        
        Test.startTest();
        Map<String, Integer> result = EYI_DigitalSlotMatrixController.getDateRangeFromSettings();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assert(result.containsKey('x'));
        System.assert(result.containsKey('y'));
    }

    @isTest
    static void testCheckIfOpportunityLinked() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Event e = [SELECT Id FROM Event LIMIT 1];
        e.WhatId = opp.Id;
        update e;

        Test.startTest();
        Map<String, Object> result = EYI_DigitalSlotMatrixController.checkIfOpportunityLinked(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey('opportunityName'));
    }

    // @isTest
    // static void testCheckIfOpportunityLinked_null() {
    //     Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    //     // Ensure no events are linked to this opportunity
    //     List<Event> linkedEvents = [SELECT Id, WhatId FROM Event WHERE WhatId = :opp.Id];
    //     for(Event e : linkedEvents) {
    //         e.WhatId = null;
    //     }
    //     if(!linkedEvents.isEmpty()) {
    //         update linkedEvents;
    //     }

    //     Test.startTest();
    //     Map<String, Object> result = EYI_DigitalSlotMatrixController.checkIfOpportunityLinked(opp.Id);
    //     Test.stopTest();
    //     System.assertEquals(null, result);
    // }

    @isTest
    static void testGetBookingStatus() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        Opportunity result = EYI_DigitalSlotMatrixController.getBookingStatus(opp.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetAvailableTimeSlots_today() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Date selectedDate = Date.today();
        Test.startTest();
        Map<String, Integer> slots = EYI_DigitalSlotMatrixController.getAvailableTimeSlots(selectedDate, opp.Id);
        Test.stopTest();
        System.assert(slots != null);
    }

    @isTest
    static void testGetAvailableTimeSlots_future() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Date selectedDate = Date.today().addDays(2);
        Test.startTest();
        Map<String, Integer> slots = EYI_DigitalSlotMatrixController.getAvailableTimeSlots(selectedDate, opp.Id);
        Test.stopTest();
        System.assert(slots != null);
    }

    @isTest
    static void testFormatTime() {
        createCustomSetting();
        
        Test.startTest();
        Map<String, Integer> slots = EYI_DigitalSlotMatrixController.getAvailableTimeSlots(Date.today().addDays(1), [SELECT Id FROM Opportunity LIMIT 1].Id);
        Test.stopTest();
        System.assert(slots != null);
        // This indirectly tests the formatTime method
    }

    @isTest
    static void testUpdateEventWithOpportunity_NewBooking() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        String timeRange = '01:00 PM - 02:00 PM';
        Date selectedDate = Date.today();
        String resscheduleremark = 'Initial booking';

        Test.startTest();
        String result = EYI_DigitalSlotMatrixController.updateEventWithOpportunity(timeRange, opp.Id, selectedDate, resscheduleremark);
        Test.stopTest();

        System.assert(result.contains('Scheduled') || result.contains('Re-Scheduled') || result.contains('expired'));
    }

    @isTest
    static void testUpdateEventWithOpportunity_Reschedule() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Simulate linking the opportunity to an existing event
        Event e = [SELECT Id, StartDateTime FROM Event LIMIT 1];
        e.WhatId = opp.Id;
        e.StartDateTime = System.now().addDays(2);
        update e;

        String timeRange = '01:00 PM - 02:00 PM';
        Date selectedDate = Date.today();
        String resscheduleremark = 'Rescheduling event';

        Test.startTest();
        String result = EYI_DigitalSlotMatrixController.updateEventWithOpportunity(timeRange, opp.Id, selectedDate, resscheduleremark);
        Test.stopTest();

        System.assert(result != null);
    }

    @isTest
    static void testUpdateEventWithOpportunity_Expired() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        // Set booking send time to 3 days ago to force expiry
        opp.EYI_Digital_Slot_Booking_Send_Time__c = System.now().addDays(-3);
        update opp;

        String timeRange = '01:00 PM - 02:00 PM';
        Date selectedDate = Date.today();
        String resscheduleremark = 'Expired link';

        Test.startTest();
        String result = EYI_DigitalSlotMatrixController.updateEventWithOpportunity(timeRange, opp.Id, selectedDate, resscheduleremark);
        Test.stopTest();

        System.assert(result.contains('expired'));
    }

    @isTest
    static void testUpdateEventWithOpportunity_RescheduleExpired() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Link opportunity to event and set start time to yesterday (expired)
        Event e = [SELECT Id, StartDateTime FROM Event LIMIT 1];
        e.WhatId = opp.Id;
        e.StartDateTime = System.now().addDays(-2);
        update e;

        String timeRange = '01:00 PM - 02:00 PM';
        Date selectedDate = Date.today();
        String resscheduleremark = 'Reschedule expired';

        Test.startTest();
        String result = EYI_DigitalSlotMatrixController.updateEventWithOpportunity(timeRange, opp.Id, selectedDate, resscheduleremark);
        Test.stopTest();

        System.assert(result.contains('expired'));
    }

    @isTest
    static void testUpdateEventWithOpportunity_CreateNewEvent() {
        createCustomSetting();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Delete existing events to force new event creation
        delete [SELECT Id FROM Event];

        String timeRange = '01:00 PM - 02:00 PM';
        Date selectedDate = Date.today();
        String resscheduleremark = 'Create new event';

        Test.startTest();
        String result = EYI_DigitalSlotMatrixController.updateEventWithOpportunity(timeRange, opp.Id, selectedDate, resscheduleremark);
        Test.stopTest();

        System.assert(result.contains('Scheduled') || result.contains('expired'));
    }

    @isTest
    static void testFormatTo24Hour() {
        // This will cover the 'AM' && 12 branch
        String result = EYI_DigitalSlotMatrixController.formatTo24Hour('12:00 AM');
        System.assertEquals('00:00', result);

        // Cover 'PM' && hour != 12
        result = EYI_DigitalSlotMatrixController.formatTo24Hour('01:30 PM');
        System.assertEquals('13:30', result);

        // Cover 'AM' && hour != 12
        result = EYI_DigitalSlotMatrixController.formatTo24Hour('09:15 AM');
        System.assertEquals('09:15', result);

        // Cover 'PM' && hour == 12
        result = EYI_DigitalSlotMatrixController.formatTo24Hour('12:45 PM');
        System.assertEquals('12:45', result);
    }

    // @isTest
    // static void testParseTimeErrorBranch() {
    //     Boolean caught = false;
    //     try {
    //         EYI_DigitalSlotMatrixController.updateEventWithOpportunity('badtime', [SELECT Id FROM Opportunity LIMIT 1].Id, Date.today(), 'bad');
    //     } catch (AuraHandledException e) {
    //         caught = true;
    //     }
    //     System.assert(caught, 'Should catch AuraHandledException for bad time format');
    // }

    // @isTest
    // static void testParseTimeInvalidFormat() {
    //     Boolean caught = false;
    //     try {
    //         EYI_DigitalSlotMatrixController.updateEventWithOpportunity('10:30', [SELECT Id FROM Opportunity LIMIT 1].Id, Date.today(), 'invalid');
    //     } catch (AuraHandledException e) {
    //         caught = true;
    //     }
    //     System.assert(caught, 'Should catch AuraHandledException for invalid time format');
    // }

    @isTest
    static void testGenerateOTP() {
        String otp = EYI_DigitalSlotMatrixController.generateOTP();
        System.assertEquals(4, otp.length());
        System.assert(otp.isNumeric());
    }

    @isTest
    static void testGetDateRangeFromSettings_DefaultValues() {
        // Don't create custom setting to test default values
        Test.startTest();
        Map<String, Integer> result = EYI_DigitalSlotMatrixController.getDateRangeFromSettings();
        Test.stopTest();
        
        System.assertEquals(0, result.get('x'));
        System.assertEquals(30, result.get('y'));
    }

    @isTest
    static void testGetAvailableTimeSlots_WithAdminUser() {
        createCustomSetting();
        
        // Create admin user
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        String unique = String.valueOf(DateTime.now().getTime());
        User adminUser = new User(
            Username = 'admin' + unique + '@test.com',
            Alias = 'adm' + unique.left(4),
            Email = 'admin' + unique + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert adminUser;

        // Create event with admin as owner
        Event adminEvent = new Event(
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            Subject = 'Admin Event',
            EYI_IsDigitalSlotScheduled__c = true,
            OwnerId = adminUser.Id,
            ActivityDate = Date.today().addDays(1)
        );
        insert adminEvent;

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Map<String, Integer> slots = EYI_DigitalSlotMatrixController.getAvailableTimeSlots(Date.today().addDays(1), opp.Id);
        Test.stopTest();
        
        System.assert(slots != null);
    }
}