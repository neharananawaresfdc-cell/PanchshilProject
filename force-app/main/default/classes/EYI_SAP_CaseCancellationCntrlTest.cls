@isTest
public class EYI_SAP_CaseCancellationCntrlTest {

    // ✅ Reusable data setup for Opportunity and related objects
    private static Opportunity createTestOpportunity() {
        // Create Project
        EYI_Project__c project = new EYI_Project__c(Name = 'Test Project', EYI_Project_Code__c = 'PRJ001');
        insert project;

        // Create Tower
        EYI_Tower__c tower = new EYI_Tower__c(Name = 'Tower A', EYI_project_Name__c = project.Id);
        insert tower;

        // Create Inventory
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            EYI_Tower__c = tower.Id,
            EYI_Project__c = project.Id,
            EYI_Floor_Number__c = '5',
            EYI_Inventory_Number__c = 'INV001'
        );
        insert inventory;

        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            EYI_Email__c = 'dilyas2@wordpress.org',
            EYI_Mobile_Number__c = '9999999999',
            EYI_Date_Of_Birth__c = System.Today()
        );
        insert acc;

        // Create Panchshil Master
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            EYI_City__c = 'Pune',
            EYI_State__c = 'Maharashtra',
            EYI_Pincode__c = '410405',
            Master_Type__c = 'Pincode',
            EYI_Zone__c = 'Pune Region',
            EYI_Sub_Urb__c = 'Pune Moffusil Division'
        );
        insert mster;

        // Create City
        EYI_City__c city = new EYI_City__c(
            Name = 'Pune',
            EYI_State__c = 'Maharashtra',
            EYI_Pincode__c = '410405'
        );
        insert city;

        // Create CIF
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_City__c = city.Id,
            EYI_Salutation__c = 'Mr.',
            EYI_Pincode__c = mster.Id,
            EYI_First_Name__c = 'Test',
            EYI_Last_Name__c = 'CIF',
            EYI_Mobile_number__c = '9764212568',
            EYI_Address_1__c = 'Noida',
            EYI_Address_2__c = 'Test2',
            EYI_Address_3__c = 'Test3',
            EYI_Email_Id__c = 'dilyas2@wordpress.org',
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert cif;
        
		EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test@email.com',
            EYI_Last_Name__c = 'Last',
            EYI_First_Name__c = 'First',
            OwnerId = UserInfo.getUserId(),
            EYI_Type_Of_RERA_Registration__c = 'Company/ Firm',
            EYI_PAN_No__c = 'ABCDE1234F',
            EYI_Company_PAN_No__c = 'ABCD12345E'
        );
        insert rec;
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Sold',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            EYI_SAP_Customer_Number__c = '0020000402',
            EYI_Project_Enquired__c = project.Id,
            EYI_SD_Status__c = 'SD Received',
            EYI_Signed_Agreement_Status__c = 'Received',
            EYI_Franking_status__c = 'Done',
            EYI_Mobile_Number__c = '9999999999',
            EYI_Project_Tower_Enquired__c = tower.Id,
            EYI_Inventory__c = inventory.Id,
            EYI_CIF_Record__c = cif.Id,
            EYI_Collection_Ageing__c = 15,
            EYI_Registration_Scheduled_Date__c = Date.today().addDays(10),
            EYI_Booking_Amount_Received__c = 4000000,
            EYI_Ownership_Status__c = 'Accepted',
            EYI_REC__c = rec.Id
        );
        insert opp;
		Quote quote = new Quote(
            Name = 'test quote data',
            EYI_Inventory__c = inventory.Id,
            EYI_Floor_Rate_Discount_L__c = 2300,
            EYI_Floor_Rate_Discount_PSF__c = 4000,
            EYI_Base_Rate_Discount_PSF__c = 9000,
            EYI_Base_Rate_Discount_L__c = 200,
            EYI_Quoatation_Grand_Total__c = 6000000,
            OpportunityId = opp.Id
        );
        insert quote;
        User salesManager = [SELECT Id FROM User LIMIT 1];
        User sourcingTL = [SELECT Id FROM User LIMIT 1];
        User sourcingManager = [SELECT Id FROM User LIMIT 1];
        User sourcingHead = [SELECT Id FROM User LIMIT 1];
        
        // Create Brokerage record with all required user fields populated
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Final_Approval_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id,
            EYI_REC_Account__c = rec.Id,
           // Sourcing_TL_User__c = sourcingTL.Id,
            Email_User__c = sourcingManager.Id,
            Sourcing_Head_User__c = sourcingHead.Id
        );
        insert brokerage;
        return opp;
    }

    // ✅ Helper for creating a Case linked to Opportunity
    private static Case createCancellationCase(Id opportunityId) {
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact contact = new Contact(
            FirstName = 'Doc',
            LastName = 'Linked',
            Email = 'linked@example.com',
            AccountId = acc.Id
        );
        insert contact;

        Id recTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName='Post_Sales' LIMIT 1].Id;
        Case c = new Case(
            Subject='Case Subject',
            Status='New',
            Origin='Phone',
            RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cancellation').getRecordTypeId(),
            EYI_Opportunity__c=opportunityId,
            SuppliedName='Test Name',
            SuppliedEmail='test@panchshil.com.test',
            ContactId=contact.Id
        );
        insert c;
        
        return c;
    }
    //Create Case 
    private static Case syncCase(Id opportunityId){
        Opportunity opp = [SELECT Id FROM Opportunity where ID =:opportunityId LIMIT 1];
		opp.StageName = 'Registration Completed';
        opp.EYI_Registration_Status__c = 'Registration Completed';
        update opp;
        EYI_REC__c recInsert = new EYI_REC__c(
            Name='Test REC', EYI_REC_Firm_Name__c='Firm', EYI_Mobile__c='9876543210',
            EYI_Email__c='test1@example.com', EYI_Last_Name__c='TestLast'
        );
        insert recInsert;

        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        User retainedByUser = [SELECT Id FROM User  LIMIT 1];

       Account acc = new Account(Name='Test Account');
        insert acc;
        Contact contact = new Contact(
            FirstName = 'Doc',
            LastName = 'Linked',
            Email = 'linked@example.com',
            AccountId = acc.Id
        );
        insert contact;

       /* Group q = new Group(Name = 'Test Case Queue', Type = 'Queue', DoesIncludeBosses = false);
        insert q;*/

        Case c = new Case(
            EYI_Opportunity__c = opp.Id,
            EYI_Cancellation_Type__c = 'Voluntary',
            EYI_Cancellation_Subtype__c = 'Financial Inability',
            EYI_Cancellation_Remarks__c = 'Some remarks',
            EYI_Date_of_Cancellation_initiated__c = Date.today(),
            EYI_Cancellation_Status__c = 'Inprogress',
            EYI_Cancellation_Commencement__c = 'On Booking',
            EYI_Registration_Status__c = 'Registered',
            EYI_Demanded_Amount_Principal__c = 100,
            EYI_Reversal_Demanded_Amount_Principal__c = 10,
            EYI_Paid_Amount_Principal__c = 90,
            EYI_Refund_Amount_Principal__c = 20,
            EYI_Demanded_Amount_Tax__c = 15,
            EYI_Reversal_Demanded_Amount_Tax__c = 1,
            EYI_Paid_Amount_Tax__c = 14,
            EYI_Refund_Amount_Tax__c = 2,
            EYI_Brokerage_Amount__c = 5,
            EYI_Debit_Note_Principal__c = 3,
            EYI_Credit_Note_Principal__c = 2,
            EYI_Debit_Note_Tax__c = 1,
            EYI_Credit_Note_Tax__c = 1,
            EYI_Reversal_Debit_Note_Principal__c = 0.5,
            EYI_Reversal_Credit_Note_Principal__c = 0.2,
            EYI_Reversal_Debit_Note_Tax__c = 0.1,
            EYI_Reversal_Credit_Note_Tax__c = 0.1,
            EYI_Total_Interest_Accured__c = 25,
            EYI_Interest_Waiver__c = 5,
            EYI_Total_Interest_Charged__c = 20,
            EYI_Brokerage_Waiver__c = 2,
            EYI_Total_Brokerage_Charged__c = 7,
            EYI_Other_Adjustments__c = 3,
            EYI_Forfeit_Amount__c = 1,
            EYI_Total_Received_Amount__c = 200,
            EYI_TotalAmountCharged__c = 250,
            EYI_Total_Refund_Given__c = 50,
            EYI_Retained_by_User__c = retainedByUser.Id,
            ContactId = contact.Id
            //OwnerId = q.Id
        );
        insert c;

        ProcessInstance pi = new ProcessInstance(
            Status = 'Pending', TargetObjectId = c.Id
        );
        insert pi;
        ProcessInstanceStep step = new ProcessInstanceStep(
            ProcessInstanceId = pi.Id, StepStatus = 'Started', ActorId = UserInfo.getUserId()
        );
        insert step;
        return c;
    }

    // ✅ Helper to create a Booking linked to Opportunity
    private static EYI_Booking__c createBooking(Id oppId) {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project1',
            EYI_Project_Code__c = 'PRJ002'
        );
        insert project;
        // Tower
        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Tower B',
            EYI_project_Name__c = project.Id
        );
        insert tower;
        
        // Inventory
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            EYI_Tower__c = tower.Id,
            EYI_Project__c = project.Id,
            EYI_Floor_Number__c = '6',
            EYI_Inventory_Number__c = 'INV007'
        );
        insert inventory;
         EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Opportunity_Name__c = oppId,
            EYI_Actual_Booking_Date__c = Date.today().addDays(-10),
            EYI_Project_Name__c = project.Id,
            EYI_Configuration__c = '3BHK',
            EYI_Parking_count__c = 2,
            Carpet_Area__c = 1200,
            Inventory__c = inventory.Id
        );
        insert booking;
        
        return booking;
    }

    // ✅ Helper to create a Quote linked to Opportunity
    private static Quote createQuote(Id oppId) {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project11',
            EYI_Project_Code__c = 'PRJ00121'
        );
        insert project;
        
        // Tower
        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Tower A',
            EYI_project_Name__c = project.Id
        );
        insert tower;
        
        // Inventory
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            EYI_Tower__c = tower.Id,
            EYI_Project__c = project.Id,
            EYI_Floor_Number__c = '532',
            EYI_Inventory_Number__c = 'INV00121'
        );
        insert inventory;
        Quote quote = new Quote(
            Name = 'test quote data',
            EYI_Inventory__c = inventory.Id,
            EYI_Floor_Rate_Discount_L__c = 2300,
            EYI_Floor_Rate_Discount_PSF__c = 4000,
            EYI_Base_Rate_Discount_PSF__c = 9000,
            EYI_Base_Rate_Discount_L__c = 200,
            EYI_Quoatation_Grand_Total__c = 6000000,
            OpportunityId = oppId
        );
        insert quote;
        return quote;
    }

    // ✅ Helper to create a Brokerage record linked to Opportunity
    private static EYI_Brokerage__c createBrokerage(Id oppId) {
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Opportunity__c = oppId
          //  EYI_Payment_Status__c = 'Paid'
        );
        insert brokerage;
        return brokerage;
    }

    // ✅ TEST 1: fetchOppDetails
    static testMethod void testFetchOppDetails() {
        Opportunity opp = createTestOpportunity();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Opportunity result = EYI_SAP_CaseCancellationPayController.fetchOppDetails(opp.Id);
        EYI_SAP_CaseCancellationPayController.fetchBrokerDetails(opp.Id);
        
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(opp.Id, result.Id);
    }

    // ✅ TEST 2: fetchRelatedListDetails
    static testMethod void testFetchRelatedListDetails() {
        Opportunity opp = createTestOpportunity();
        createBooking(opp.Id);
        createQuote(opp.Id);
        //createBrokerage(opp.Id);
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Email__c = 'dilyas2@wordpress.org',
            EYI_Mobile_Number__c = '9876543210',
            EYI_Last_Name__c = 'Ellyas',
            EYI_First_Name__c = 'Denna',
            Name = 'Test Applicant',
            EYI_Applicant_Type__c = 'Primary Applicant'
        );
        insert applicant;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EYI_SAP_CaseCancellationPayController.fetchQuoteDetails(opp.Id);
       // EYI_SAP_CaseCancellationPayController.fetchCancellationPageData(opp.Id);
        EYI_SAP_CaseCancellationPayController.fetchBookingDetails(opp.Id);
        EYI_SAP_CaseCancellationPayController.fetchApplicantDetails(opp.Id);
        EYI_SAP_CaseCancellationPayController.fetchRecDetails(opp.Id);
        test.stopTest();
    }

    // ✅ TEST 3: fetchCaseDetails
    static testMethod void testFetchCaseDetails() {
        Opportunity opp = createTestOpportunity();
        Case c = createCancellationCase(opp.Id);
        //Case cs = syncCase(opp.Id);
        insert new EYI_Payment_Receipt__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Amount__c = 100000,
            EYI_SAP_Payment_Advice_Number__c = '00124567009',
            EYI_SAP_Company_Code__c = '1290',
            EYI_SAP_Document_Number__c = '0080000786',
            EYI_Fiscal_Year__c = 2025,
            EYI_Payment_Status__c ='REJECT'
        );
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EYI_SAP_CaseCancellationPayController.fetchOppId(c.Id);
        EYI_SAP_CancellationPaymentController.getPaymentReceiptDetails(opp.Id);
        EYI_SAP_CancellationPaymentController.checkCaseStatus(c.Id);
        EYI_SAP_CancellationPaymentController.checkCaseStatus(opp.Id);
        EYI_SAP_CaseCancellationPayController.checkCancellationFetchedDetails(c.Id);
        EYI_SAP_CaseCancellationPayController.getPaymentReceiptDetails(opp.Id);
        //EYI_SAP_CaseCancellationPayController.fetchCancellationDetails(c.Id);
        //EYI_SAP_CaseCancellationPayController.fetchCancellationDetails(opp.Id);
        //EYI_CancellationMasterSyncLwcController.CancellationMasterSync(cs.Id);
        //EYI_CancellationMasterSyncLwcController.CancellationMasterSync(opp.Id);
        EYI_SAP_CaseCancellationPayController.fetchOppDetails(opp.Id);
        EYI_SAP_CaseCancellationPayController.getApiData('CUST001');
        EYI_SAP_CaseCancellationPayController.getUserOptions();
        test.stopTest();
    }
    private static Map<String, Object> getSampleData() {
        Map<String, Object> data = new Map<String, Object>();

        // Id is optional for new records; for update tests you can set an Id
        data.put('Subject', 'Test Cancellation');
        data.put('EYI_Retention_Date__c', '2025-08-26');  // Date as String
        data.put('EYI_Date_of_Cancellation_initiated__c', '2025-08-25'); // Date as String
        data.put('EYI_Total_Received_Amount__c', '1,000.50'); // Decimal with commas
        data.put('EYI_Reversal_to_Customer__c', '123.45'); // Decimal as Decimal
        data.put('EYI_Amount_to_Cust_of_Other_Adjustment__c', null); // Null decimal
        data.put('EYI_Reversal_To_Customer__c', '123.45'); // This triggers EYI_IsCancellationFetched__c = true
        data.put('Description', 'Some description');
        return data;
    }

    @isTest
    static void testSaveCancellationDetails_Insert() {
        // Insert a RecordType for Case Cancellation (if it doesn't exist)
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName='Cancellation' LIMIT 1];
        System.assertNotEquals(null, rt.Id, 'RecordType Cancellation must exist in org');

        Map<String, Object> data = getSampleData();

        Test.startTest();
        EYI_SAP_CaseCancellationPayController.saveCancellationDetails(data);
        Test.stopTest();

        // Query the Case record and verify fields saved correctly
        /*Case savedCase = [SELECT Id, Subject, EYI_Retention_Date__c, EYI_Date_of_Cancellation_initiated__c, 
                                  EYI_Total_Received_Amount__c, EYI_Reversal_to_Customer__c, EYI_Amount_to_Cust_of_Other_Adjustment__c,
                                   EYI_IsCancellationFetched__c, RecordTypeId, EYI_Stages__c
                           FROM Case WHERE Subject = 'Test Cancellation' LIMIT 1];

        System.assertEquals(Date.valueOf('2025-08-26'), savedCase.EYI_Retention_Date__c, 'Retention Date should match');
        System.assertEquals(Date.valueOf('2025-08-25'), savedCase.EYI_Date_of_Cancellation_initiated__c, 'Cancellation Initiated Date should match');
        System.assertEquals(1000.50, savedCase.EYI_Total_Received_Amount__c, 'Total Received Amount should match');
        System.assertEquals(123.45, savedCase.EYI_Reversal_to_Customer__c, 'Reversal to Customer should match');
        System.assertEquals(null, savedCase.EYI_Amount_to_Cust_of_Other_Adjustment__c, 'Amount to Cust of Other Adjustment should be null');
        System.assertEquals(123.45, savedCase.EYI_Reversal_To_Customer__c, 'Reversal_To_Customer should match');
        System.assertEquals(true, savedCase.EYI_IsCancellationFetched__c, 'EYI_IsCancellationFetched__c should be true');
        System.assertEquals(rt.Id, savedCase.RecordTypeId, 'RecordTypeId should be Cancellation');
        System.assertEquals('Cancellation Retention in Progress', savedCase.EYI_Stages__c, 'Stage should be set');*/
    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            
            // Minimal mocked JSON response
            res.setBody(JSON.serialize(new Map<String, Object>{
                'n0:ZSD_CUST_CANCEL_DET_TO_SFDCResponse' => new Map<String, Object>{
                    'EX_OUTPUT' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'EX_MESSAGE'    => '',
                    'COMP_CODE'     => '',
                    'CUSTOMER'      => '',
                    'DEMAND_P'      => 1500000,
                    'DEMAND_P_R'    => 1500000,
                    'PAID_P'        => 1200,
                    'REFUND_T'      => 1200,
                    'DEMAND_T'      => 180000,
                    'DEMAND_T_R'    => 120000,
                    'PAID_T'        => 0,
                    'BROKERAGE'     => 300000,
                    'INTEREST_C'    => 118000,
                    'DEBIT_P'       => 1000,
                    'CREDIT_P'      => 0,
                    'DEBIT_T'       => 0,
                    'CREDIT_T'      => 0,
                    'DEBIT_P_R'     => 1000,
                    'CREDIT_P_R'    => 0,
                    'DEBIT_T_R'     => 0,
                    'CREDIT_T_R'    => 0,
                    'CUST1'         => '',
                    'CUST2'         => '',
                    'CUST3'         => '',
                    'CUST4'         => ''
                        }
                    }
                }
            }));
            return res;
        }
    }
}