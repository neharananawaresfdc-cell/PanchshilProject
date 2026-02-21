@isTest
private class EYI_CreateDemandTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create test user
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Create separate accounts for each test
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account 1'));
        accounts.add(new Account(Name = 'Test Account 2'));
        accounts.add(new Account(Name = 'Test Account 3'));
        insert accounts;
    }

    @isTest
    static void testHandleAfterUpdate() {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            AccountId = acc.Id,
            EYI_Ownership_Status__c = 'Accepted',
            EYI_Relationship_Manager__c = testUser.Id
        );
        insert opp;

        Quote quote = new Quote(
            Name = 'Test Quote 1',
            OpportunityId = opp.Id,
            Status = 'Approved'
        );
        insert quote;

        opp.SyncedQuoteId = quote.Id;
        update opp;

        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Opportunity_Name__c = opp.Id,
            EYI_Actual_Booking_Date__c = Date.today()
        );
        insert booking;

        Payment_Plan__c plan = new Payment_Plan__c(
            Name = 'Plan 1',
            EYI_Quote__c = quote.Id
        );
        insert plan;

        EYI_Payment_Schedule__c schedule = new EYI_Payment_Schedule__c(
            Payment_Plan__c = plan.Id,
            EYI_Actual_Date__c = Date.today(),
            EYI_Billing_Date__c = Date.today().addDays(5),
            EYI_Milestone_Type__c = 'CLP',
            EYI_Milestone__c = true,
            EYI_SAP_Milestone_Code__c = 'MST001',
            EYI_SAP_Plant_Code__c = 'PLANT01',
            EYI_SAP_Sales_Org__c = 'ORG01',
            EYI_Usage__c = 'EYIN',
            EYI_Usage_Description__c = '3BHK',
            EYI_Milestone_Number__c = 1,
            EYI_Amount_to_be_paid__c = 100000,
            EYI_Invoice_Percentage__c = 100
        );
        insert schedule;

        Test.startTest();
        
        EYI_Booking__c oldBooking = booking.clone();
        oldBooking.EYI_SAP_Sales_Order_Number__c = null;
        booking.EYI_SAP_Sales_Order_Number__c = 'SAP123';
        update booking;

        Test.stopTest();

        List<EYI_Demand__c> demands = [
            SELECT Id, EYI_Booking__c, EYI_Opportunity__c, EYI_Amount_to_be_paid__c, EYI_Demand_Status__c
            FROM EYI_Demand__c
            WHERE EYI_Booking__c = :booking.Id
        ];

        System.assertEquals(1, demands.size(), 'One demand should be created');
        System.assertEquals('Open', demands[0].EYI_Demand_Status__c, 'Demand status should be Open');
    }

    @isTest
    static void testHandleAfterUpdateNoSAPChange() {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            AccountId = acc.Id,
            EYI_Ownership_Status__c = 'Accepted',
            EYI_Relationship_Manager__c = testUser.Id
        );
        insert opp;

        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Opportunity_Name__c = opp.Id,
            EYI_SAP_Sales_Order_Number__c = 'SAP456'
        );
        insert booking;

        Test.startTest();
        
        EYI_Booking__c oldBooking = booking.clone();
        oldBooking.EYI_SAP_Sales_Order_Number__c = 'SAP456';
        booking.EYI_SAP_Sales_Order_Number__c = 'SAP456';
        update booking;

        Test.stopTest();

        List<EYI_Demand__c> demands = [
            SELECT Id FROM EYI_Demand__c WHERE EYI_Booking__c = :booking.Id
        ];

        System.assertEquals(0, demands.size(), 'No demand should be created when SAP number doesn\'t change');
    }

    @isTest
    static void testHandleAfterUpdateTimeBoundMilestone() {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 3' LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 3',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            AccountId = acc.Id,
            EYI_Relationship_Manager__c = testUser.Id
        );
        insert opp;

        Quote quote = new Quote(
            Name = 'Test Quote 3',
            OpportunityId = opp.Id,
            Status = 'Approved'
        );
        insert quote;

        opp.SyncedQuoteId = quote.Id;
        opp.EYI_Ownership_Status__c = 'Accepted';
        update opp;

        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Opportunity_Name__c = opp.Id,
            EYI_Actual_Booking_Date__c = Date.today()
        );
        insert booking;

        Payment_Plan__c plan = new Payment_Plan__c(
            Name = 'Plan 3',
            EYI_Quote__c = quote.Id
        );
        insert plan;

        EYI_Payment_Schedule__c schedule = new EYI_Payment_Schedule__c(
            Payment_Plan__c = plan.Id,
            EYI_Actual_Date__c = Date.today(),
            EYI_Billing_Date__c = Date.today().addDays(10),
            EYI_Milestone_Type__c = 'Time Bound',
            EYI_Amount_to_be_paid__c = 50000,
            EYI_Invoice_Percentage__c = 50,
            EYI_Milestone_Number__c = 3,
            EYI_SAP_Plant_Code__c = 'PLANT03',
            EYI_SAP_Sales_Org__c = 'ORG03',
            EYI_Usage__c = 'EYIN',
            EYI_Usage_Description__c = '1BHK',
            EYI_Milestone__c = true,
            EYI_SAP_Milestone_Code__c = 'MST999'
        );
        insert schedule;

        // Debug: Check existing demands before test
        List<EYI_Demand__c> existingDemands = [SELECT Id FROM EYI_Demand__c];
        System.debug('Existing demands before test: ' + existingDemands.size());

        Test.startTest();
        
        EYI_Booking__c oldBooking = booking.clone();
        oldBooking.EYI_SAP_Sales_Order_Number__c = null;
        booking.EYI_SAP_Sales_Order_Number__c = 'SAP789';
        update booking;

        Test.stopTest();

        List<EYI_Demand__c> demands = [
            SELECT Id, EYI_Demand_Type__c, EYI_Actual_Date__c, EYI_Billing_Date__c, EYI_Payment_Schedule__c
            FROM EYI_Demand__c
            WHERE EYI_Booking__c = :booking.Id
        ];

        System.debug('Demands created for this booking: ' + demands.size());
        for(EYI_Demand__c demand : demands) {
            System.debug('Demand: ' + demand.Id + ', Type: ' + demand.EYI_Demand_Type__c + ', Schedule: ' + demand.EYI_Payment_Schedule__c);
        }

        System.assertEquals(1, demands.size(), 'One demand should be created for Time Bound test');
        if(demands.size() > 0) {
            System.assertEquals('Time Bound', demands[0].EYI_Demand_Type__c, 'Demand type should be Time Bound');
            System.assertEquals(Date.today().addDays(10), demands[0].EYI_Actual_Date__c, 'Actual date should be billing date for Time Bound');
        }
    }
    @isTest
    static void testHandleAfterUpdateTimeBoundMilestone1() {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 3' LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 3',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            AccountId = acc.Id,
            EYI_Relationship_Manager__c = testUser.Id
        );
        insert opp;

        Quote quote = new Quote(
            Name = 'Test Quote 3',
            OpportunityId = opp.Id,
            Status = 'Approved'
        );
        insert quote;

        opp.SyncedQuoteId = quote.Id;
        opp.EYI_Ownership_Status__c = 'Accepted';
        update opp;

        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Opportunity_Name__c = opp.Id,
            EYI_Actual_Booking_Date__c = Date.today()
        );
        insert booking;
        
        EYI_Global_Charges__c globalCharges = new EYI_Global_Charges__c(
            Name = 'GC1',
            EYI_SAP_Material_Name__c = 'Material X',
            EYI_SAP_Sequence_Number__c = 1,
            EYI_Demand_Applicable__c = true
        );
        insert globalCharges;

        Project_Charges__c projectCharges = new Project_Charges__c(
            Name = 'Charge 1',
            EYI_Charge_Type__c = 'Other Charges',
            EYI_Global_Charges__c = globalCharges.Id
        );
        insert projectCharges;
        EYI_Applied_Project_Charge__c charge = new EYI_Applied_Project_Charge__c(
            Name = 'Test Applied Charge',
            EYI_Quote__c = quote.Id,
            EYI_Project_Charges__c = projectCharges.Id
        );
        insert charge;

        Payment_Plan__c plan = new Payment_Plan__c(
            Name = 'Plan 3',
            EYI_Quote__c = quote.Id
        );
        insert plan;

        EYI_Payment_Schedule__c schedule = new EYI_Payment_Schedule__c(
            Payment_Plan__c = plan.Id,
            EYI_Actual_Date__c = Date.today(),
            EYI_Billing_Date__c = Date.today().addDays(10),
            EYI_Milestone_Type__c = 'Time Bound',
            EYI_Amount_to_be_paid__c = 50000,
            EYI_Invoice_Percentage__c = 50,
            EYI_Milestone_Number__c = 3,
            EYI_SAP_Plant_Code__c = 'PLANT03',
            EYI_SAP_Sales_Org__c = 'ORG03',
            EYI_Usage__c = 'EYIN',
            EYI_Usage_Description__c = '1BHK',
            EYI_Milestone__c = true,
            EYI_SAP_Milestone_Code__c = 'MST999'
        );
        insert schedule;

        // Debug: Check existing demands before test
        List<EYI_Demand__c> existingDemands = [SELECT Id FROM EYI_Demand__c];
        System.debug('Existing demands before test: ' + existingDemands.size());

        Test.startTest();
        
        EYI_Booking__c oldBooking = booking.clone();
        oldBooking.EYI_SAP_Sales_Order_Number__c = null;
        booking.EYI_SAP_Sales_Order_Number__c = 'SAP789';
        update booking;

        Test.stopTest();

      
    }
}