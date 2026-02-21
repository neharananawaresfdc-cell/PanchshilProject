@isTest
public class EYI_VisitConfirmationSMSAlertBatch_Test {
    @testSetup
    static void setupTestData() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert u;
        
        Lead parent = new Lead(LastName = 'Test', Company = 'Test Co');
        insert parent;
        
        List<EYI_Lead_Enquiry__c> leads = new List<EYI_Lead_Enquiry__c>();
        for (Integer i = 0; i < 125; i++) {
            leads.add(new EYI_Lead_Enquiry__c(
                EYI_Lead_Status__c = 'Visit Confirmed',
                EYI_Site_Visit_Date__c = Date.today(),
                EYI_Phone__c = '99999999' + String.valueOf(i),
                OwnerId = u.Id,
                EYI_Parent_Record__c = parent.Id
            ));
            leads.add(new EYI_Lead_Enquiry__c(
                EYI_Lead_Status__c = 'Visit Confirmed',
                EYI_Site_Visit_Date__c = Date.today().addDays(1),
                EYI_Phone__c = '88888888' + String.valueOf(i),
                OwnerId = u.Id,
                EYI_Parent_Record__c = parent.Id
            ));
        }
        leads.add(new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Open',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = '7777777777',
            OwnerId = u.Id,
            EYI_Parent_Record__c = parent.Id
        ));
        insert leads;
    }

    // @isTest
    // static void testBatchExecution() {
    //     Test.startTest();
    //     EYI_VisitConfirmationSMSAlertBatch batch = new EYI_VisitConfirmationSMSAlertBatch();
    //     Database.executeBatch(batch,10);
    //     Test.stopTest();

    //     Integer countToday = [SELECT count() FROM EYI_Lead_Enquiry__c WHERE EYI_Site_Visit_Date__c = :Date.today() AND EYI_Lead_Status__c = 'Visit Confirmed'];
    //     Integer countTomorrow = [SELECT count() FROM EYI_Lead_Enquiry__c WHERE EYI_Site_Visit_Date__c = :Date.today().addDays(1) AND EYI_Lead_Status__c = 'Visit Confirmed'];
    //     System.assertEquals(125, countToday, 'Should have 125 records for today');
    //     System.assertEquals(125, countTomorrow, 'Should have 125 records for tomorrow');
    // }

    // @isTest
    // static void testBatchWithNoRecords() {
    //     // Remove all records
    //     delete [SELECT Id FROM EYI_Lead_Enquiry__c];
    //     Test.startTest();
    //     EYI_VisitConfirmationSMSAlertBatch batch = new EYI_VisitConfirmationSMSAlertBatch();
    //     Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
    //     Database.executeBatch(batch, batchSize);
    //     Test.stopTest();
    //     // No exception should be thrown, and nothing to assert
    //     System.assertEquals(0, [SELECT count() FROM EYI_Lead_Enquiry__c]);
    // }

    // @isTest
    // static void testBatchWithNonMatchingStatus() {
    //     Lead parent = new Lead(LastName = 'Test', Company = 'Test Co');
    //     insert parent;
    //     // Only 'Open' status records
    //     EYI_Lead_Enquiry__c openLead = new EYI_Lead_Enquiry__c(
    //         EYI_Lead_Status__c = 'Open',
    //         EYI_Site_Visit_Date__c = Date.today(),
    //         EYI_Phone__c = '1234567890',
    //         EYI_Parent_Record__c = parent.Id
    //     );
    //     insert openLead;
    //     Test.startTest();
    //     EYI_VisitConfirmationSMSAlertBatch batch = new EYI_VisitConfirmationSMSAlertBatch();
    //     Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
    //     Database.executeBatch(batch, batchSize);
    //     Test.stopTest();
    //     // Should not process as status is not 'Visit Confirmed'
    //     EYI_Lead_Enquiry__c result = [
    //         SELECT EYI_Lead_Status__c, EYI_Site_Visit_Date__c 
    //         FROM EYI_Lead_Enquiry__c 
    //         WHERE Id = :openLead.Id
    //     ];
    //     System.assertEquals('Open', result.EYI_Lead_Status__c);
    // }

    // @isTest
    // static void testBatchMultipleExecutions() {
    //     EYI_VisitConfirmationSMSAlertBatch batch = new EYI_VisitConfirmationSMSAlertBatch();
    //     Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
    //     Database.executeBatch(batch, batchSize);
    //     try {
    //         // Try to execute batch again in same context, should throw error
    //         Database.executeBatch(batch, 50);
    //         //System.assert(false, 'Should not allow more than one batch execution in the same context');
    //     } catch (Exception e) {
    //         System.assert(e.getMessage().contains('already executing') || e.getMessage().contains('can only call'), 'Should throw error for multiple batch executions');
    //     }
    // }

    @isTest
    static void testDirectExecute() {
        EYI_VisitConfirmationSMSAlertBatch batch = new EYI_VisitConfirmationSMSAlertBatch();
        List<EYI_Lead_Enquiry__c> leads = [SELECT Id, EYI_Site_Visit_Date__c,EYI_Phone__c FROM EYI_Lead_Enquiry__c WHERE EYI_Lead_Status__c = 'Visit Confirmed' LIMIT 10];
        Test.startTest();
        batch.execute(null, leads);
        Test.stopTest();
    }
}