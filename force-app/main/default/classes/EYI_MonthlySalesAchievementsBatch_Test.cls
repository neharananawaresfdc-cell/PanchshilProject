@isTest
public class EYI_MonthlySalesAchievementsBatch_Test {

    // Utility to create test user
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }

    @isTest
    static void testMonthlySalesAchievementsBatch() {
        // Create a test user
        User u = createTestUser();
        System.runAs(u) {

            // Test dates
            Date today = Date.today();
            Integer fiscalStartMonth = 4; // April
            Date monthStart = Date.newInstance(today.year(), today.month(), 1);
            Date monthEnd = monthStart.addMonths(1).addDays(-1);

            // Create a Target Management record
            EYI_Target_Management__c target = new EYI_Target_Management__c(
               // Name = 'Test Target',
                OwnerId = u.Id,
                EYI_Target_Start_Date__c = monthStart,
                EYI_Target_End_Date__c = monthEnd,
                EYI_Target_KPI__c = 'Number of EOIs',
                EYI_Target_Module__c = 'Sales',
                EYI_Target_Month_Date__c = monthStart
            );
            insert target;

            // Create Opportunity
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                OwnerId = u.Id,
                EYI_Booked_Date__c = Date.today(),
                EYI_Walk_in_Source__c = 'Referral',
                EYI_Walk_in_Sub_source__c = 'Employee',
                EYI_Sourcing_Manager__c = u.Id
            );
            insert opp;

            // Create EOI (Expression of Interest)
            EYI_Expression_Of_Interest__c eoi = new EYI_Expression_Of_Interest__c(
             //   Name = 'Test EOI',
                OwnerId = u.Id,
                EYI_Opportunity__c = opp.Id
            );
            insert eoi;

            // Create Task for Follow-up
            Task t = new Task(
                OwnerId = u.Id,
                Status = 'Completed',
                Subject = 'Follow Up Call',
                WhatId = opp.Id,
                ActivityDate = Date.today(),
                EYI_Next_Action_Status__c = 'Follow Up',
                EYI_Next_Action_Date_Time__c = system.now()
            );
            insert t;

            // Create ProcessDefinition and ProcessInstance mock data (if required for your org)
            // Skipped since batch doesn’t rely on inserts here for logic coverage

            // Run the batch
            Test.startTest();
            EYI_MonthlySalesAchievementsBatch batch = new EYI_MonthlySalesAchievementsBatch();
            Database.executeBatch(batch, 1);
            Test.stopTest();

            // Verify that achievements were updated
            EYI_Target_Management__c updatedTarget = [
                SELECT Id, EYI_Achivements__c
                FROM EYI_Target_Management__c
                WHERE Id = :target.Id
                LIMIT 1
            ];

            System.assertNotEquals(null, updatedTarget.EYI_Achivements__c,
                'EYI_Achivements__c should have been updated by the batch');
            System.debug('✅ Achievement updated: ' + updatedTarget.EYI_Achivements__c);
        }
    }
}