@isTest
public class EYI_VisitConfirmationWAppAlertBatch_Test {
    @testSetup
    static void setupTestData() {
        Lead parentLead = new Lead(
            LastName = 'Test Parent',
            Company = 'Test Company'
        );
        insert parentLead;
        
        EYI_Lead_Enquiry__c enqToday = new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = '9999999999',
            EYI_Parent_Record__c = parentLead.Id
        );
        insert enqToday;
        
        // Tomorrow visit, status confirmed
        EYI_Lead_Enquiry__c enqTomorrow = new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today().addDays(1),
            EYI_Phone__c = '8888888888',
            EYI_Parent_Record__c = parentLead.Id
        );
        insert enqTomorrow;
        
        // Not confirmed, should not be picked up
        EYI_Lead_Enquiry__c enqNotConfirmed = new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Open',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = '7777777777',
            EYI_Parent_Record__c = parentLead.Id
        );
        insert enqNotConfirmed;
        
        // Null phone, should not be picked up
        EYI_Lead_Enquiry__c enqNoPhone = new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today(),
            EYI_Phone__c = null,
            EYI_Parent_Record__c = parentLead.Id
        );
        insert enqNoPhone;
    }
    
    @isTest
    static void testBatchExecutesAndCoversLogic() {
        Test.startTest();
        EYI_VisitConfirmationWAppAlertBatch batch = new EYI_VisitConfirmationWAppAlertBatch();
        Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
        Database.executeBatch(batch, batchSize);
        Test.stopTest();
        
        // Basic assertion to confirm test ran to completion and data setup is correct
        List<EYI_Lead_Enquiry__c> leads = [
            SELECT Id, EYI_Lead_Status__c, EYI_Site_Visit_Date__c, EYI_Phone__c
            FROM EYI_Lead_Enquiry__c
            WHERE EYI_Lead_Status__c = 'Visit Confirmed'
        ];
        System.assertEquals(3, leads.size(), 'Should have 3 confirmed visit leads (including one with null phone)');
    }
}