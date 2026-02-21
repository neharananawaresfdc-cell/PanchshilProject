@IsTest
private class EYI_GetSiteVisitDetails_Test {

    @IsTest
    static void testGetLeadEnquiryStatus_Success() {

        EYI_Project__c project = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Distribution_Channel__c = '10',
            EYI_Project_Status__c = 'Pre- Launch',
            EYI_Project_Type__c = 'Flat',
            EYI_Zone__c = 'Pune City',
            EYI_Chatbot_Active__c = true,
            EYI_Project_Location__c = 'Kharadi',
            EYI_Project_Site_Location_Link__c = 'https://maps.app.goo.gl/ZzSkyikTyHoDYoKr5',
            EYI_Project_Start_Date__c = System.today() - 10,
            EYI_SAP_Company_Code__c = '1320',
            EYI_SAP_Plant_Code__c = 'R15A',
            EYI_Sales_District__c = 'IN0001',
            EYI_SAP_Salesorg__c = 'R152',
            EYI_Stamp_Duty__c = 5,
            EYI_RDS_State__c = 'Maharashtra',
            EYI_Asset_Class__c = 'Outright',
            EYI_Sub_Asset_Class__c = 'Plot',
            EYI_Total_Budget__c = 1000000,
            EYI_Project_Code__c = '83',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_TDS_Charge__c = 10
        );
        insert project;

        // Create sample Lead Enquiry records
        Lead leadEnquiry1 = new Lead(
            LastName = 'Test Lead 1',
            LeadSource = 'Mobile App',
            Email = 'test@example.com',
            Phone = '1234567890',
            EYI_Project_Enquired__c = project.Id,
            EYI_Site_Visit_Date__c = System.now().addDays(1),
            EYI_Referred_By__c = 'Ashu',
            Company='Panchshil',
            EYI_Segment__c ='Residential'
        );
        insert leadEnquiry1;

        EYI_Lead_Enquiry__c leadEnquiry2 = new EYI_Lead_Enquiry__c(
            Name = 'Test Lead 2',
            EYI_Lead_Status__c = 'Open',
            EYI_Email__c = 'test@example.com',
            EYI_Mobile__c = '0987654321',
            EYI_Project_Enquired__c = project.Id,
            EYI_Site_Visit_Date__c = System.now().addDays(-5),
            EYI_Lead_Source__c = 'Mobile App',
            EYI_Parent_Record__c=leadEnquiry1.Id,
            EYI_Property__c ='Avant Garde',
            EYI_Segment__c ='Residential'
        );
        insert leadEnquiry2;

        // Prepare JSON request body
        String jsonRequest = '{"email":"test@example.com","phone":""}';

        // Setup RestRequest and RestContext
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getSiteVisit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;

        // Call the method
        EYI_GetSiteVisitDetails.LeadEnquiryResponse response = EYI_GetSiteVisitDetails.getLeadEnquiryStatus();

        // Verify the response
        System.assert(response.success, 'Response should be successful');
        System.assertEquals('Leads retrieved successfully.', response.message);
       // System.assertEquals(2, response.leads.size(), 'Should return 2 lead enquiries');

        // Validate fields in response
        EYI_GetSiteVisitDetails.LeadRecord leadRec = response.leads[0];
        System.assertNotEquals(null, leadRec.id, 'Lead ID should not be null');
        System.assertEquals('test@example.com', leadRec.email);
        System.assertNotEquals(null, leadRec.projectName, 'Project Name should be populated');
        System.assertNotEquals(null, leadRec.createdDate, 'Created Date should be populated');
    }

    @IsTest
    static void testGetLeadEnquiryStatus_NoInput() {
        // Prepare empty JSON request body
        String jsonRequest = '{"email":"","phone":""}';

        // Setup RestRequest and RestContext
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getSiteVisit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;

        // Call the method
        EYI_GetSiteVisitDetails.LeadEnquiryResponse response = EYI_GetSiteVisitDetails.getLeadEnquiryStatus();

        // Verify response is failure
        System.assert(!response.success, 'Response should fail');
        System.assertEquals('Email or Phone is required', response.message);
        System.assertEquals(0, response.leads.size(), 'No leads should be returned');
    }

    @IsTest
    static void testGetLeadEnquiryStatus_NoLeadsFound() {
        // Prepare JSON with email that doesn't match any record
        String jsonRequest = '{"email":"nonexistent@example.com","phone":""}';

        // Setup RestRequest and RestContext
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getSiteVisit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;

        // Call the method
        EYI_GetSiteVisitDetails.LeadEnquiryResponse response = EYI_GetSiteVisitDetails.getLeadEnquiryStatus();

        // Verify response is success but no leads found
        System.assert(response.success, 'Response should be successful');
        System.assertEquals('No leads found.', response.message);
        System.assertEquals(0, response.leads.size(), 'No leads should be returned');
    }
}