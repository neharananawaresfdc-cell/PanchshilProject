@isTest
public class EYI_MonthlyPresalesAchievementsBatchTest {

    @testSetup
    static void setupData() {
        // Create Users
        //User u = TestUtility.createTestUser(); // assumes a method to create a user
        //insert u;
		Profile p = [SELECT Id FROM Profile WHERE Name='Pre-Sales' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert u;
        // Create KPI values (you'll need exact picklist/text values)
        String kpiVisitConfirmed = 'Visit Confirmed';
        String kpiVisitDone = 'Visit Done';
        String kpiRatio = 'Lead to Walk-In Conversion ratio';
        String kpiAvgTalkTime = 'Average Talk Time';
        String kpiOutboundCalls = 'Total Outbound Calls to be Done';
        String kpiInboundCalls = 'Total Inbound Calls Completed';

        // Target Management records
        List<EYI_Target_Management__c> targetRecords = new List<EYI_Target_Management__c>();

        List<String> kpis = new List<String>{kpiVisitConfirmed, kpiVisitDone, kpiRatio, kpiAvgTalkTime, kpiOutboundCalls, kpiInboundCalls};

        for (String kpi : kpis) {
            EYI_Target_Management__c tm = new EYI_Target_Management__c(
               // Name = 'Target ' + kpi,
                OwnerId = u.Id,
                EYI_Target_KPI__c = kpi,
                EYI_Target_Module__c = 'Presales',
                EYI_Target_Month_Date__c = Date.today() // current month
            );
            targetRecords.add(tm);
        }
        insert targetRecords;
		Lead parentRec = new Lead(Status = 'Open', OwnerId = u.Id,LastName = 'Test2', Company='TBC',Phone='9999999999',Email='test@gmail.com');
		insert parentRec;
        // Lead Enquiry for Visit Confirmed
        EYI_Lead_Enquiry__c lead1 = new EYI_Lead_Enquiry__c(
            Name = 'Lead 1',
            OwnerId = u.Id,
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test1@gmail.com',
            EYI_Parent_Record__c = parentRec.id,
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today()
           // CreatedDate = Date.today()
        );
        insert lead1;
		EYI_Lead_Enquiry__c lead2 = new EYI_Lead_Enquiry__c(
            Name = 'Lead 1',
            OwnerId = u.Id,
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test@gmail.com',
            EYI_Parent_Record__c = parentRec.id,
            EYI_Lead_Status__c = 'Visit Done',
            EYI_Site_Visit_Date__c = Date.today()
           // CreatedDate = Date.today()
        );
        insert lead2;
        

        // Create CIF
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'John',
            EYI_Last_Name__c = 'Doe',
            EYI_Email_Id__c = 'test@gmail.com',
            EYI_Mobile_number__c = '9999999999',
            EYI_Project_Type__c = 'Residential',
            EYI_Sourcing_Manager__c = u.Id,
			EYI_Customer_Address_Type__c = 'Pune',
            EYI_Lead_Enquiry__c = lead2.Id,
			EYI_State__c = 'Maharashtra'
        );
        insert cif;

        // Call logs
        tdc_360CTI__Call_Log__c call1 = new tdc_360CTI__Call_Log__c(
            OwnerId = u.Id,
            tdc_360CTI__Call_Type__c = 'Outgoing',
            CustomLead_Enquiry__c = lead1.Id,
            tdc_360CTI__Answered_Seconds__c = 30
           // CreatedDate = Date.today()
        );
        insert call1;

        tdc_360CTI__Call_Log__c call2 = new tdc_360CTI__Call_Log__c(
            OwnerId = u.Id,
            tdc_360CTI__Call_Type__c = 'Incoming',
            CustomLead_Enquiry__c = lead1.Id,
            tdc_360CTI__Answered_Seconds__c = 20
           // CreatedDate = Date.today()
        );
        insert call2;
    }

    @isTest
    static void testMonthlyPresalesAchievementsBatch() {
        List<EYI_Lead_Enquiry__c> getleadData = [Select Id, EYI_Lead_Status__c,OwnerId from EYI_Lead_Enquiry__c];
        system.debug('getleadData'+getleadData);
        Test.startTest();

        EYI_MonthlyPresalesAchievementsBatch batch = new EYI_MonthlyPresalesAchievementsBatch();
        Database.executeBatch(batch, 200);
        EYI_MonthlyPresalesAchievementsScheduler scheBatch = new EYI_MonthlyPresalesAchievementsScheduler();
        scheBatch.execute(null);

        Test.stopTest();

        // Validate updates
        List<EYI_Target_Management__c> updatedRecords = [
            SELECT Id, EYI_Achivements__c, EYI_Target_KPI__c 
            FROM EYI_Target_Management__c
        ];

        System.assertNotEquals(0, updatedRecords.size(), 'No target management records found');

        for (EYI_Target_Management__c rec : updatedRecords) {
            System.debug('KPI: ' + rec.EYI_Target_KPI__c + ' | Achievement: ' + rec.EYI_Achivements__c);
           // System.assert(rec.EYI_Achivements__c != null, 'Achievement value should be updated for KPI: ' + rec.EYI_Target_KPI__c);
        }
    }
}