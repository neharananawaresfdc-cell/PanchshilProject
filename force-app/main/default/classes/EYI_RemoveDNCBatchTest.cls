@isTest
private class EYI_RemoveDNCBatchTest {

@IsTest
    static void testStartMethod() {
        // Create a test EYI_Lead_Enquiry__c record with DNC__c = True and EYI_DNC__c = True
        Lead newLead = new Lead(
            LastName = 'TestLastName',
            Company = 'TestCompany',
            LeadSource = 'Web',
            Email = 'test@test.com'
        );
        insert newLead;

        EYI_Lead_Enquiry__c testLead = new EYI_Lead_Enquiry__c(
            EYI_Lead_Status__c = 'Open',
            EYI_Site_Visit_Date__c = Date.today().addDays(-1),
            DNC__c = True,
            EYI_DNC__c = True,
            EYI_No_of_Not_Connected_Follow_Ups__c = 0,
            EYI_Parent_Record__c = newLead.Id
        );
        insert testLead;
        List<SObject> sobjlist = new List<SObject>();
        sobjlist.add(testLead);

        Test.startTest();
        EYI_RemoveDNCBatch batch = new EYI_RemoveDNCBatch();
        Database.BatchableContext bc = null;
        Database.QueryLocator queryLocator = batch.start(bc);
        batch.execute(bc,sobjlist);
        EYI_RemoveDNCBatchScheduler scheBatch = new EYI_RemoveDNCBatchScheduler();
        scheBatch.execute(null);
        Test.stopTest();

        // Assert that the query locator is not null
    }
}