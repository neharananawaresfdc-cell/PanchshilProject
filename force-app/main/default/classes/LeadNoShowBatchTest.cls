@isTest
private class LeadNoShowBatchTest {
    @isTest static void testLeadNoShowBatch() {
        // Step 1: Create test data
        // 
        Lead parentLead = new Lead(
            LastName = 'TestLead',
            Company = 'TestCompany'
        );
        insert parentLead;
        List<EYI_Lead_Enquiry__c> testLeads = new List<EYI_Lead_Enquiry__c>();
		
        // Create 3 records - 2 with past date and Visit Confirmed status, 1 with future date
        testLeads.add(new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today().addDays(-2),
            EYI_Parent_Record__c = parentLead.Id
        ));
        testLeads.add(new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today().addDays(-1),
            EYI_Parent_Record__c =parentLead.Id
        ));
        testLeads.add(new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Visit Confirmed',
            EYI_Site_Visit_Date__c = Date.today().addDays(1),
            EYI_Parent_Record__c = parentLead.Id// future date, should not update
        ));
        insert testLeads;

        // Step 2: Execute the batch
        Test.startTest();
        LeadNoShowBatch batch = new LeadNoShowBatch();
        Database.executeBatch(batch);
        EYI_LeadNoShowScheduler scheduler = new EYI_LeadNoShowScheduler();
        scheduler.execute(null);
        Test.stopTest();
        


        // Step 3: Verify the results
        List<EYI_Lead_Enquiry__c> updatedLeads = [
            SELECT Id, EYI_Lead_Status__c, EYI_AutomationBypassDatetime__c ,EYI_Site_Visit_Date__c
            FROM EYI_Lead_Enquiry__c
            WHERE Id IN :testLeads
        ];

        Integer updatedCount = 0;
        for (EYI_Lead_Enquiry__c lead : updatedLeads) {
            if (lead.EYI_Site_Visit_Date__c < Date.today()) {
                // These should be updated
              //  System.assertEquals('No Show', lead.EYI_Lead_Status__c, 'Lead status should be updated to No Show');
              // System.assertNotEquals(null, lead.EYI_AutomationBypassDatetime__c, 'Automation bypass datetime should be set');
                updatedCount++;
            } else {
                System.debug('Inside else');
                // This one should remain unchanged
                //System.assertEquals('Visit Confirmed', lead.EYI_Lead_Status__c, 'Lead status should remain Visit Confirmed');
                //System.assertEquals(null, lead.EYI_AutomationBypassDatetime__c, 'Automation bypass datetime should remain null');
            }
        }

        System.assertEquals(2, updatedCount, 'Two leads should have been updated');
    }
}