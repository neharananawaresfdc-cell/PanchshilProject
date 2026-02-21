@isTest
public class EYI_EsignTxnUpdateAppBatchSchTest {
    @isTest
    static void testScheduleBatch() {
        // Add required LastName field
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Name = 'Test Applicant',
            EYI_Last_Name__c = 'TestLast'
        );
        insert applicant;

        // Schedule the batch job
        String cronExp = '0 0 12 * * ?';
        Test.startTest();
        String jobId = System.schedule('Test EsignTxnUpdateApplicantBatchSchedule', cronExp, new EYI_EsignTxnUpdateApplicantBatchSchedule());
        Test.stopTest();
    }
}