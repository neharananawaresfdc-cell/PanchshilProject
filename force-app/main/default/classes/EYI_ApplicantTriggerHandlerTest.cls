@isTest
public class EYI_ApplicantTriggerHandlerTest {
    @isTest
    static void testUpdateOpportunityMobiles() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(10),
            EYI_Ownership_Status__c='Accepted',
            AccountId = acc.Id
        );
        insert opp;
        // Create Applicants: 1 Primary, 2 Co-Applicants (using correct picklist values)
        EYI_Applicants__c primary = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Primary Applicant',
            EYI_Mobile_Number__c = '1234567890',
            EYI_Last_Name__c = 'Primary'
        );
        EYI_Applicants__c coapp1 = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Co-applicant',
            EYI_Mobile_Number__c = '1234567892',
            EYI_Last_Name__c = 'Coapp1'
        );
        EYI_Applicants__c coapp2 = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Co-applicant',
            EYI_Mobile_Number__c = '1234567893',
            EYI_Last_Name__c = 'Coapp2'
        );
        insert new List<EYI_Applicants__c>{primary, coapp1, coapp2};

        // Query applicants for the handler
        List<EYI_Applicants__c> apps = [
            SELECT Id, Opportunity__c, EYI_Applicant_Type__c, EYI_Mobile_Number__c 
            FROM EYI_Applicants__c 
            WHERE Opportunity__c = :opp.Id
            ORDER BY CreatedDate
        ];

        Test.startTest();
        EYI_ApplicantTriggerHandler.updateOpportunityMobiles(apps);
        Test.stopTest();

        // Assert Opportunity fields updated
        Opportunity updatedOpp = [
            SELECT EYI_Mobile_Number__c, EYI_Applicant2_Mobile__c, EYI_Applicant3_Mobile__c 
            FROM Opportunity 
            WHERE Id = :opp.Id
        ];
        System.assertEquals('1234567892', updatedOpp.EYI_Applicant2_Mobile__c, 'Co-Applicant 1 mobile should be set');
        System.assertEquals('1234567893', updatedOpp.EYI_Applicant3_Mobile__c, 'Co-Applicant 2 mobile should be set');
    }

    @isTest
    static void testUpdateOpportunityMobiles_NoApplicants() {
        // Should not throw error if no applicants
        EYI_ApplicantTriggerHandler.updateOpportunityMobiles(new List<EYI_Applicants__c>());
    }

    @isTest
    static void testUpdateOpportunityMobiles_NullOpportunity() {
        // Should not throw error if Opportunity__c is null
        EYI_Applicants__c app = new EYI_Applicants__c(
            EYI_Applicant_Type__c = 'Primary Applicant',
            EYI_Mobile_Number__c = '1234567890',
            EYI_Last_Name__c = 'Test'
        );
        EYI_ApplicantTriggerHandler.updateOpportunityMobiles(new List<EYI_Applicants__c>{app});
    }
    @isTest
    static void testUpdateOpportunityMobilesApp() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(10),
            EYI_Ownership_Status__c='Accepted',
            AccountId = acc.Id
        );
        insert opp;
         EYI_FCM_Detail__c fcm = new EYI_FCM_Detail__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Custom_Device_ID__c = 'mock_device_token_123'
        );
        insert fcm;
        // Create Applicants: 1 Primary, 2 Co-Applicants (using correct picklist values)
        EYI_Applicants__c primary = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Primary Applicant',
            EYI_Mobile_Number__c = '1234567890',
            EYI_Last_Name__c = 'Primary'
        );
        EYI_Applicants__c coapp1 = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Co-applicant',
            EYI_Mobile_Number__c = '1234567892',
            EYI_Last_Name__c = 'Coapp1'
        );
        EYI_Applicants__c coapp2 = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Applicant_Type__c = 'Co-applicant',
            EYI_Mobile_Number__c = '1234567893',
            EYI_Last_Name__c = 'Coapp2'
        );
        insert new List<EYI_Applicants__c>{primary, coapp1, coapp2};
          // primary.isKYCDone__c = true;
       // update primary;
        Test.setMock(HttpCalloutMock.class, new EYI_FCMCalloutMock());
        Test.startTest();

    // Trigger the handler method which leads to callout
    primary.isKYCDone__c = true;
    update primary;

    Test.stopTest();
        }
}