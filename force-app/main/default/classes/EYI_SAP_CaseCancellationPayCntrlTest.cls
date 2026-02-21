@isTest
public class EYI_SAP_CaseCancellationPayCntrlTest {

    private static Opportunity createTestOpportunity() {
        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=Date.today(),
            EYI_SAP_Customer_Number__c='123456',
            EYI_Last_Name__c='test Con',
            EYI_Ownership_Status__c='Accepted'
        );
        insert opp;
        return opp;
    }

    private static Case createTestCase(Id oppId) {
        return new Case(
            RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cancellation').getRecordTypeId(),
            Status='New',
            EYI_Opportunity__c=oppId,
           // LastName='Test LastName',
            Subject='Test Case Subject'
        );
    }

    private static EYI_REC__c createTestRec() {
        Account acc = new Account(Name='Test Account');
        insert acc;

        EYI_REC__c rec = new EYI_REC__c(
            Name='Test REC',
           // EYI_REC_Account__c = acc.Id,
            EYI_RERA_Number__c = 'RERA123',
            EYI_Mobile__c = '9988776655'
           // EYI_REC_Code__c = 'REC001'
        );
        insert rec;
        return rec;
    }

    private static EYI_Applicants__c createTestApplicant(Id oppId) {
        Contact contact = new Contact(LastName='Test Last Name');
        insert contact;

        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Opportunity__c = oppId,
            Name = 'Test Applicant'
           // Primary_Applicant__c = contact.Id
        );
        insert applicant;
        return applicant;
    }

    @isTest
    static void testFetchOppId() {
        Opportunity opp = createTestOpportunity();
        Case testCase = createTestCase(opp.Id);
        insert testCase;

        Test.startTest();
        Id returnedId = EYI_SAP_CaseCancellationPayController.fetchOppId(testCase.Id);
        Test.stopTest();

        System.assertEquals(opp.Id, returnedId);
    }

    @isTest
    static void testGetPaymentReceiptDetails() {
        Opportunity opp = createTestOpportunity();

        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(EYI_Opportunity__c=opp.Id);
        insert receipt;

        Test.startTest();
        Boolean result = EYI_SAP_CaseCancellationPayController.getPaymentReceiptDetails(opp.Id);
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void testFetchCancellationDetails() {
        Opportunity opp = createTestOpportunity();
        Case testCase = createTestCase(opp.Id);
        insert testCase;

        Test.startTest();
        Case result = EYI_SAP_CaseCancellationPayController.fetchCancellationDetails(testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testFetchCancellationPageData() {
        Opportunity opp = createTestOpportunity();
        Case testCase = createTestCase(opp.Id);
        insert testCase;

        Quote quote = new Quote(Name='Test Quote', OpportunityId=opp.Id);
        insert quote;

        EYI_Booking__c booking = new EYI_Booking__c(EYI_Opportunity_Name__c = opp.Id, EYI_Source_of_Booking__c = 'Online');
        insert booking;

        Test.startTest();
        //EYI_SAP_CaseCancellationPayController.fetchCancellationPageData data = EYI_SAP_CaseCancellationPayController.fetchCancellationPageData(opp.Id);
        Test.stopTest();

       // System.assertNotEquals(null, data);
       // System.assertNotEquals(null, data.booking);
    }

    @isTest
    static void testSaveCancellationDetails() {
        Opportunity opp = createTestOpportunity();
        Case testCase = createTestCase(opp.Id);
        insert testCase;

        Map<String, Object> updateData = new Map<String, Object>{
            'Id' => testCase.Id,
            'EYI_Cancellation_Remarks__c' => 'Updated remarks',
            'EYI_Total_Refund_Given__c' => '₹12,000.00'
        };

        Test.startTest();
        EYI_SAP_CaseCancellationPayController.saveCancellationDetails(updateData);
        Test.stopTest();

        Case updated = [SELECT EYI_Cancellation_Remarks__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Updated remarks', updated.EYI_Cancellation_Remarks__c);
    }

    @isTest
    static void testGetUserOptions() {
        Test.startTest();
        List<Map<String, String>> options = EYI_SAP_CaseCancellationPayController.getUserOptions();
        Test.stopTest();

        System.assert(options.size() > 0);
    }

    @isTest
    static void testFetchQuoteDetails() {
        Opportunity opp = createTestOpportunity();
        Quote quote = new Quote(Name='Test Quote', OpportunityId=opp.Id);
        insert quote;

        Test.startTest();
        Quote result = EYI_SAP_CaseCancellationPayController.fetchQuoteDetails(opp.Id);
        Test.stopTest();

        //System.assertNotEquals(null, result);
    }

    @isTest
    static void testFetchApplicantDetails() {
        Opportunity opp = createTestOpportunity();
        EYI_Applicants__c applicant = createTestApplicant(opp.Id);

        Test.startTest();
        EYI_Applicants__c result = EYI_SAP_CaseCancellationPayController.fetchApplicantDetails(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testFetchRecDetails() {
        EYI_REC__c rec = createTestRec();

        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=Date.today(),
            EYI_REC__c = rec.Id
        );
        insert opp;

        Test.startTest();
        EYI_REC__c result = EYI_SAP_CaseCancellationPayController.fetchRecDetails(opp.Id);
        Test.stopTest();

        System.assertEquals(rec.Id, result.Id);
    }

    @isTest
    static void testFetchBrokerageDetails() {
        Opportunity opp = createTestOpportunity();
		EYI_REC__c recAcc = new EYI_REC__c(Name='test',EYI_Mobile__c='8866997755');
        insert recAcc;
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(EYI_Opportunity__c = opp.Id, 
                                                          EYI_Brokerage_Amount__c = 1000,EYI_REC_Account__c =recAcc.Id);
        insert brokerage;

        Test.startTest();
        EYI_Brokerage__c result = EYI_SAP_CaseCancellationPayController.fetchBrokerageDetails(opp.Id);
        Test.stopTest();

        System.assertEquals(brokerage.Id, result.Id);
    }
}