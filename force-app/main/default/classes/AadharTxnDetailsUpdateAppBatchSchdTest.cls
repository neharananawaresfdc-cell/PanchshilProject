@isTest
public class AadharTxnDetailsUpdateAppBatchSchdTest {

    @testSetup
    static void setupData() {
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Name='Nilesh Ghodke',
            EYI_Last_Name__c='Ghodke',
            EYI_Pancard_Number__c='DLWPG4197L',
            EYI_Applicant_Type__c='Primary Applicant',
            DigiLocker_Transaction_Id__c = 324232,
            Is_Aadhar_EKYC_Completed__c = false
        );
        insert applicant;
    }

    @isTest
    static void testScheduleJob() {
        Test.startTest();
        AadharTxnDetailsUpdateAppBatchSchedule sch = new AadharTxnDetailsUpdateAppBatchSchedule();
        sch.execute(null);
        Test.stopTest();
    }
}