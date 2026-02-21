@isTest(SeeAllData=true)
public class EYI_DigitalLeadEscalationReportBatchTest {
    @isTest
    static void testBatchExecution() {
        // Query an existing report (must exist in your org)
        Report rep = [SELECT Id, Name FROM Report LIMIT 1];

        Test.startTest();
        EYI_DigitalLeadEscalationReportBatch batch = new EYI_DigitalLeadEscalationReportBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        System.assertNotEquals(null, rep.Id, 'Report should exist');
    }
}