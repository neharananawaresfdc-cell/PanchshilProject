@IsTest
private class EYI_OpportunitySearchResourceTest {
    
    // Simple mock to bypass any callouts triggered
    private class MockCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
    
    @TestSetup
    static void setupData() {
        // Mock callouts BEFORE any inserts
        Test.setMock(HttpCalloutMock.class, new MockCallout());
        
        // Project
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'PRJ001'
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
            EYI_Floor_Number__c = '5',
            EYI_Inventory_Number__c = 'INV001'
        );
        insert inventory;
        
        // Account
        Account acc = new Account(
            Name = 'Test Account',
            EYI_Email__c = 'dilyas2@wordpress.org',
            EYI_Mobile_Number__c = '9999999999',
            EYI_Date_Of_Birth__c = System.Today()
        );
        insert acc;
        
        // Panchshil Master
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            EYI_City__c = 'Pune',
            EYI_State__c = 'Maharashtra',
            EYI_Pincode__c = '410405',
            Master_Type__c = 'Pincode',
            EYI_Zone__c = 'Pune Region',
            EYI_Sub_Urb__c = 'Pune Moffusil Division'
        );
        insert mster;
        
        // City
        EYI_City__c city = new EYI_City__c(
            Name = 'Pune',
            EYI_State__c = 'Maharashtra',
            EYI_Pincode__c = '410405'
        );
        insert city;
        
        // CIF
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_City__c = city.Id,
            EYI_Salutation__c = 'Mr.',
            EYI_Pincode__c = mster.Id,
            EYI_First_Name__c = 'test applicant',
            EYI_Last_Name__c = 'cif',
            EYI_Mobile_number__c = '9764212568',
            EYI_Address_1__c = 'noida test',
            EYI_Address_2__c = 'test',
            EYI_Address_3__c = 'test',
            EYI_Email_Id__c = 'dilyas2@wordpress.org',
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert cif;
        
        // Opportunity
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
			EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        RecordType outStandingId = [Select Id,DeveloperName from RecordType where DeveloperName ='EYI_SAP_Outstanding_Report'];
        EYI_SAP_Report__c saprep = new EYI_SAP_Report__c();
        saprep.Opportunity__c = opp.Id;
        saprep.EYI_Outstanding_Amount__c =1234;
        saprep.EYI_SAP_Outstanding_Amount__c = 1234;
        saprep.RecordTypeId = outStandingId.Id;
        insert saprep;
        RecordType ageingId = [Select Id,DeveloperName from RecordType where DeveloperName ='EYI_SAP_Ageing_Report'];
        EYI_SAP_Report__c saprep1 = new EYI_SAP_Report__c();
        saprep1.Opportunity__c = opp.Id;
        saprep1.EYI_Ageing_Delay_Days__c =1234;
        saprep1.EYI_SAP_Outstanding_Amount__c = 1234;
        saprep1.RecordTypeId = ageingId.Id;
        insert saprep1;
        
        // Roll-up source record
        insert new EYI_SAP_Report__c(
            Opportunity__c = opp.Id,
            EYI_Outstanding_Amount__c = 150000
        );
        
        // Applicant
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Opportunity__c = opp.Id,
            EYI_Email__c = 'dilyas2@wordpress.org',
            EYI_Mobile_Number__c = '9876543210',
            EYI_Last_Name__c = 'Ellyas',
            EYI_First_Name__c = 'Denna',
            Name = 'Test Applicant'
        );
        insert applicant;
        
        // Booking
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Opportunity_Name__c = opp.Id,
            EYI_Actual_Booking_Date__c = Date.today().addDays(-10),
            EYI_Project_Name__c = project.Id,
            EYI_Configuration__c = '3BHK',
            EYI_Parking_count__c = 2,
            Carpet_Area__c = 1200,
            Inventory__c = inventory.Id
        );
        insert booking;
        
        // Demand
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Demand_Status__c = 'Open',
            EYI_IsOtherChargeDemand__c = 'Yes'
        );
        insert demand;
        
        // Payment Receipts
        insert new EYI_Payment_Receipt__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Amount__c = 100000,
            EYI_SAP_Payment_Advice_Number__c = '00124567009',
            EYI_SAP_Company_Code__c = '1290',
            EYI_SAP_Document_Number__c = '0080000786',
            EYI_Fiscal_Year__c = 2025
        );
        
        insert new EYI_Payment_Receipt__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Amount__c = 200000,
            EYI_SAP_Payment_Advice_Number__c = '00224567009',
            EYI_SAP_Company_Code__c = '1290',
            EYI_SAP_Document_Number__c = '0080000986',
            EYI_Fiscal_Year__c = 2025
        );
        
        // Project Logo
        insert new EYI_DMS__c(
            EYI_Project__c = opp.EYI_Project_Enquired__c,
            EYI_Document_Link__c = 'https://example.com/logo.png'
        );
        
        // Charges
        insert new Project_Charges__c(
            EYI_Project__c = opp.EYI_Project_Enquired__c,
            EYI_Charge_Type__c = 'Other Charges'
        );
        
        // Quote
        Quote qut = new Quote(
            Name = 'test quote data',
            EYI_Inventory__c = inventory.Id,
            EYI_Floor_Rate_Discount_L__c = 2300,
            EYI_Floor_Rate_Discount_PSF__c = 4000,
            EYI_Base_Rate_Discount_PSF__c = 9000,
            EYI_Base_Rate_Discount_L__c = 200,
            EYI_Quoatation_Grand_Total__c = 6000000,
            OpportunityId = opp.Id
        );
        insert qut;
        
        // Payment Plan
        Payment_Plan__c plan = new Payment_Plan__c(
            Name = 'Standard CLP',
            EYI_Plan_Type__c = 'Construction Linked Payment',
            Project__c = project.Id,
            Tower__c = tower.Id,
            EYI_Quote__c = qut.Id
        );
        insert plan;
        
        // Payment Schedule
        insert new EYI_Payment_Schedule__c(
            EYI_Project__c = project.Id,
            EYI_Invoice_Percentage__c = 10,
            EYI_Billing_Date__c = Date.today(),
            EYI_Milestone_Number__c = 1,
            EYI_SAP_Activity_Number__c = 12,
            EYI_Usage__c = 'Z0112',
            EYI_SAP_Sales_Org__c = 'C130',
            EYI_SAP_Plant_Code__c = 'C130',
            EYI_Usage_Description__c = 'On Possession',
            Payment_Plan__c = plan.Id
        );
        
        // Second Quote
        Quote qut1 = new Quote(
            Name = 'test quote data',
            EYI_Inventory__c = inventory.Id,
            EYI_Floor_Rate_Discount_L__c = 2300,
            EYI_Base_Rate_Discount_L__c = 200,
            EYI_Quoatation_Grand_Total__c = 6000000,
            OpportunityId = opp.Id,
            Payment_Plan__c = plan.Id
        );
        insert qut1;
         EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
         //   Name = 'Receipt1',
            EYI_Amount__c = 100,
            EYI_Payment_Status__c = 'SUBMITTED',
            EYI_Opportunity__c = opp.Id
             
        );
        insert receipt;
        receipt.EYI_Payment_Status__c ='APPROVE';
        update receipt;
    }
    
    @IsTest static void testSearchOpportunities_FullMatch() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerBookingDetailsAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"email":"dilyas2@wordpress.org","mobileNumber":"9876543210"}');
        RestContext.request = req;
        RestContext.response = res;
        EYI_OpportunitySearchResource.searchOpportunities();
        Test.stopTest();
    }
    
    @IsTest static void testSearchOpportunities_EmailOnly() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerBookingDetailsAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"email":"dilyas2@wordpress.org"}');
        RestContext.request = req;
        RestContext.response = res;
        EYI_OpportunitySearchResource.searchOpportunities();
        Test.stopTest();
    }
    
    @IsTest static void testSearchOpportunities_MobileOnly() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerBookingDetailsAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"mobileNumber":"9876543210"}');
        RestContext.request = req;
        RestContext.response = res;
        EYI_OpportunitySearchResource.searchOpportunities();
        Test.stopTest();
    }
    
    @IsTest static void testSearchOpportunities_NoDataFound() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerBookingDetailsAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"email":"nomatch@example.com","mobileNumber":"0000000000"}');
        RestContext.request = req;
        RestContext.response = res;
        EYI_OpportunitySearchResource.searchOpportunities();
        Test.stopTest();
    }
    
    @IsTest static void testSearchOpportunities_InvalidPayload() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerBookingDetailsAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response = res;
        EYI_OpportunitySearchResource.searchOpportunities();
        Test.stopTest();
    }
}