@isTest
public class EYI_DocData_test {
    
    @isTest(SeeAllData=false)
    public static void testEYIDocDataMethods() {
        // Create EYI_Project__c
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Project_Status__c = 'Teaser',
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
            EYI_Project_Property_Type__c = 'Residential'
        );
        insert projctobj;
        
        // Create EYI_Tower__c
        EYI_Tower__c towerobj = new EYI_Tower__c(
            Name = 'Balewadi Tower A',
            EYI_Stage__c = 'Pre-Launch',
            EYI_Pass_Code__c = 'BTA',
            EYI_Project_Name__c = projctobj.id,
            EYI_RERA_Certificate_Date__c = System.today() - 10,
            EYI_RERA_Number__c = 'A43242343',
            EYI_RERA_Possesion_Date__c = System.today() - 15,
            EYI_Tower_Number__c = 'A01',
            EYI_Tower_Property_Type__c = 'Apartments;Shops',
            EYI_SAP_Delivery_Plant_Code__c = 'R15D',
            EYI_SAP_Plant_ID__c = 'R15I', 
            EYI_Total_Car_Park__c = 1,
            EYI_Onboarding_Manager__c = UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert towerobj;
        
        // Create Account
        Account acc = new Account(
        
            Name = 'test Account',
            EYI_Marital_Status__c = 'Single',
            EYI_Nationality__c = 'Indian',
            EYI_Occupation__c = 'Salaried',
            EYI_Email__c = 'nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c = System.today() - 10
        );
        insert acc;
        
        // Create EYI_Applicants__c
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Name = 'Nilesh Arvind Ghodke',
            EYI_Last_Name__c = 'Arvind Ghodke',
            EYI_Pancard_Number__c = 'DLWPG4197L',
            EYI_Applicant_Type__c = 'Primary Applicant'
        );
        insert applicant;
        
        // Create EYI_City__c
        EYI_City__c city = new EYI_City__c(
            Name = 'Pune',
            EYI_State__c = 'Maharashtra',
            EYI_Pincode__c = '410405'
        );
        insert city;
        
        // Create EYI_Panchshil_Master__c
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            EYI_City__c = 'Pune',
            EYI_State__c = 'Maharashtra',
            EYI_Pincode__c = '410405',
            Master_Type__c = 'Pincode',
            EYI_Zone__c = 'Pune Region',
            EYI_Sub_Urb__c = 'Pune Moffusil Division'
        );
        insert mster;
        
        // Create EYI_Customer_Information_Form__c
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_City__c = city.id,
            EYI_Salutation__c = 'Mr.',
            EYI_Pincode__c = mster.id,
            EYI_First_Name__c = 'test applicant',
            EYI_Last_Name__c = 'cif',
            EYI_Mobile_number__c = '9764212568',
            EYI_Address_1__c = 'noida test',
            EYI_Address_2__c = 'test',
            EYI_Address_3__c = 'test',
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert cif;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            EYI_CIF_Record__c = cif.id,
            AccountId = acc.id,
            EYI_Project_Tower_Enquired__c = towerobj.id,
            EYI_Primary_Applicant__c = applicant.id,
            EYI_Salutation__c = 'Mr.',
            Name = 'Tushar test',
            StageName = 'Cancellation',
            CloseDate = System.today() + 20,
            EYI_First_Name__c = 'Tushar test',
            EYI_Last_Name__c = 'testOPP',
            EYI_Address3__c = 'Film city',
            EYI_Nationality__c = 'Indian',
            EYI_Project_Enquired__c = projctobj.id,
            EYI_Address2__c = 'sector 16',
            EYI_Address1__c = 'sector 16 a',
            EYI_City__c = 'Noida',
            EYI_Country_Classification__c = 'India',
            EYI_Country_Key__c = 'IN',
            GST_Applicable__c = true,
            EYI_Customer_Currency__c = 'INR',
            EYI_BP_Type__c = '1',
            EYI_Segment__c = 'Residential',
            EYI_Date_Of_Birth__c = System.today() - 150,
            EYI_District__c = 'GB',
            EYI_GSTIN_Number__c = '27AAAPA1234A1Z9',
            EYI_Id_Number__c = '2345678909876',
            EYI_Id_Type__c = 'AADHAR Card Number',
            EYI_Industry__c = 'Advertising',
            EYI_Occupation__c = 'Salaried',
            EYI_Pan_Number__c = '45678iolmn',
            EYI_Partner_Function__c = 'Sold-to Party',
            EYI_Payment_Terms__c = '15 Days Credit From the Date of Invoice',
            EYI_Postal_Code__c = '201301',
            EYI_Sales_Group__c = 'Pune Sales Group',
            EYI_Sales_Office__c = 'Mumbai Office',
            EYI_TCS_Applicable__c = true,
            EYI_Mobile_Number__c = '23456789987654',
            EYI_Alternate_Mobile_No__c = '98765432124',
            EYI_SAP_Customer_Number__c = '23456789098765',
			EYI_Ownership_Status__c = 'Accepted',
            EYI_Primary_Closing_Manager__c = UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c = UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
            EYI_AutomationBypassDatetime__c = System.now()
        );
        insert opp;
        
        // Create EYI_Booking__c
        EYI_Booking__c book = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c = '1234400994',
            EYI_Opportunity_Name__c = opp.id,
            EYI_Project_Name__c = projctobj.id,
            EYI_Divisions__c = 'Residential',
            EYI_Account_Name__c = acc.id,
            EYI_Actual_Booking_Date__c = System.today() - 10,
            EYI_Cancellation_Reason__c = 'Sales call',
            EYI_Sourcing_manager__c = UserInfo.getUserId(),
            isDraft__c = true
        );
        insert book;
        
        // Create EYI_Inventory__c
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Booking__c = book.id,
            EYI_Inventory_Number__c = 'PATN04020',
            Name = 'Balewadi Inventory 2',
            EYI_SAP_Material_Type__c = 'Finished Unit',
            EYI_TCS_Tax_Classification__c = 'TDS Applicable',
            EYI_GST_Tax_Classification__c = 'Non Taxable GST',
            EYI_SAP_Material_Description__c = 'qwerty',
            EYI_Tower__c = towerobj.id,
            EYI_Project__c = projctobj.id,
            EYI_Inventory_Type__c = 'Residential Sales',
            EYI_UOM__c = 'Square foot',
            EYI_Material_Group__c = 'Apartment',
            EYI_Super_Built_up_Area__c = 20,
            EYI_Carpet_Area__c = 14,
            EYI_Garden_Area__c = 20,
            EYI_Terrace_Area__c = '50',
            EYI_Balcony_Area__c = '30',
            EYI_Built_up_Area__c = 10,
            EYI_Common_Area__c = 10,
            EYI_Inventory_Status__c = 'Reserve',
            EYI_Floor_Number__c = '003',
            Configuration__c = 'Studio',
            EYI_View_based_on_Directions__c = 'East',
            EYI_View_based_on_Amenities__c = 'Amenity Facing',
            EYI_SAP_Affordable_Type__c = 'Affordable Housing',
            EYI_SAP_Profit_Center__c = 'R150R1R15I'
        );
        insert invtry;
        
        // Create EYI_Car_Park_Master__c
        EYI_Car_Park_Master__c carprk = new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c = 'Saleable Service',
            EYI_Material_Group__c = 'Parking',
            EYI_Base_UOM__c = 'Each',
            EYI_Tower__c = towerobj.id,
            EYI_Project__c = projctobj.id,
            EYI_Inventory__c = invtry.id,
            EYI_SAP_Material_Description__c = 'Description Description',
            EYI_Status__c = 'Vacant',
            EYI_Parking_Number__c = 'P-502',
            EYI_Distruibution_Channel__c = 'Residential Sales',
            EYI_External_Material_Group__c = '10',
            EYI_Lab_Office__c = '20',
            EYI_Built_up_Area__c = 100,
            EYI_Floor_Number__c = '003',
            EYI_SAP_Affordable_Type__c = 'Affordable Housing',
            Configuration__c = 'Parking',
            EYI_SAP_Profit_Center__c = 'R150R1R15I',
            EYI_X_Plant_Mat_Status__c = 'Blocked for procment/whse',
            EYI_Account_Assignment_Group__c = 'Vehicle Parking',
            EYI_Item_Category__c = 'Parking Item Cat Grp',
            EYI_TCS_Tax_Classification__c = 'TCS Applicable',
            EYI_GST_Tax_Classification__c = 'Taxable under GST'
        );
        insert carprk;
        
        // Create EYI_Rate_List__c
        EYI_Rate_List__c rate = new EYI_Rate_List__c(
            EYI_Condition_Type__c = 'Percentage',
            EYI_Pricing_Percentage__c = 12,
            EYI_Amount__c = 20,
            EYI_Pricing_Quantity__c = 10,
            EYI_Inventory__c = invtry.id
        );
        insert rate;
        
        // Create EYI_Applicants__c for Opportunity
        EYI_Applicants__c oppAplicant = new EYI_Applicants__c(
            Name = 'Nilesh Arvind Ghodke',
            EYI_Title__c = 'Mr.',
            EYI_Email__c = 'neha.rananaware@in.ey.com',
            EYI_Last_Name__c = 'Ghodke',
            EYI_Mobile_Number__c = '09765117411',
            EYI_Pancard_Number__c = 'DLWPG4197L',
            EYI_Applicant_Type__c = 'Primary Applicant',
            Opportunity__c = opp.id
        );
        insert oppAplicant;
        
        // Create EYI_Bank_GL_Codes__c
        EYI_Bank_GL_Codes__c bnk = new EYI_Bank_GL_Codes__c(
            EYI_Bank_Account_Type__c = 'COLLECTION Acc',
            EYI_Project__c = projctobj.id
        );
        insert bnk;
        
        // Create EYI_REC__c
        EYI_REC__c rec = new EYI_REC__c(
            EYI_Salutation__c = 'Mr.',
            EYI_First_Name__c = 'Test01',
            EYI_Middle_Name__c = 'REC',
            EYI_Last_Name__c = 'Account01',
            EYI_Gender__c = 'Male',
            EYI_Marital_Status__c = 'Single',
            EYI_Nationality__c = 'Indian',
            EYI_Occupation__c = 'Salaried',
            EYI_Organization__c = 'test org',
            EYI_Designation__c = 'test Desination',
            EYI_Birth_Date__c = System.today() - 186,
            EYI_Anniversary_Date__c = System.today() - 1356,
            EYI_MSME__c = System.today() - 1356,
            EYI_Company_Code__c = '987543',
            EYI_Reconciliation_Account__c = 'Creditors - Material Domestic',
            EYI_Payment_Terms__c = 'Immediately after Goods Receipt',
            EYI_Minority_Indicator__c = 'Medium',
            EYI_GSTIN__c = '27AAAPA1234A1Z9',
            EYI_Aadhar__c = '981356897543',
            EYI_Udyog_Adhar__c = '713264675759',
            EYI_Company_Regisration__c = 'EYI_Company_Regisration__c',
            EYI_ESIC_Number__c = 'ESIC_Number',
            EYI_RERA_Number__c = '56HJHK89198',
            EYI_City__c = city.id,
            EYI_Country__c = 'India',
            EYI_State__c = 'Delhi',
            EYI_Mobile__c = '9988776671',
            EYI_Alternate_Mobile__c = '7080808091',
            EYI_Type_Of_RERA_Registration__c = 'Individual',
            EYI_REC_Firm_Name__c = 'ABHI Group',
            EYI_PAN_No__c = 'ABCDE1234D',
            EYI_Pincode_Office__c = '987722443',
            EYI_REC_Owner_Mobile_Number__c = '9877654321',
            EYI_Email__c = 'kumarswami1.mathapati089@in.ey.com',
            EYI_Alternate_Email__c = 'kumarswami1.mathapati.904@in.ey.com',
            EYI_REC_Correspondence_Mobile_Number__c = '9876545432146',
            EYI_REC_Correspondence_Email_ID__c = 'abhishek@mail.com',
            EYI_Tax_Classification__c = 'GST Registered',
            EYI_REC_Vendor_Code__c = '876543',
            EYI_Address1__c = 'noida.',
            EYI_Address2__c = 'Noida',
            EYI_Address3__c = 'Sector 3',
            EYI_E_Invoicing_Applicable__c = true,
            EYI_Is_MSME__c = true,
            EYI_MSME_Number__c = 'Test MSME',
            EYI_Country_Code_for_Secondary_Mobile__c = 'India',
            EYI_Country_Code_REC_Primary_Mobile__c = 'India',
            EYI_Country_Code_for_REC_Owner_Mobile__c = 'India',
            EYI_REC_Owner_Telephone_Number__c = '98765432345',
            EYI_Primary_Telephone_Number__c = '9876543362',
            EYI_Secondary_Telephone_Number__c = '9876543362',
            EYI_REC_Correspondence_Last_Name__c = 'test',
            EYI_Correspondence_City__c = city.id,
            EYI_Correspondence_Country__c = 'India',
            EYI_Correspondence_State__c = 'Delhi',
            EYI_Correspondence_Address_1__c = 'noida.',
            EYI_Correspondence_Address_2__c = 'Noida',
            EYI_Correspondence_Address_3__c = 'Sector 3',
            EYI_Correspondence_Pincode_Office__c = '987722443',
            EYI_REC_Correspondence_Contact_Name__c = '9887765434567',
            EYI_CP_Contact_1_Mobile_Number__c = '987556789966',
            EYI_First_Name_of_Contact_Person__c = 'test cont',
            EYI_Last_Name_of_Contact_Person__c = 'contact',
            EYI_CP_E_Mail_Address__c = 'abhishek@mail.com',
            EYI_Title__c = 'Mr.',
            EYI_Correspondence_Title__c = 'Mr.',
            EYI_RERA_Certificate_No__c = '9agt7899ijnd'
        );
        insert rec;
        
        // Create EYI_Bank_Details__c
        EYI_Bank_Details__c bnkDet = new EYI_Bank_Details__c(
            EYI_Account_Holder_Name__c = 'TEST VENDOR SYNC',
            EYI_Bank_Country__c = 'India',
            EYI_IFSC_Code__c = 'ICIC0000424',
            EYI_Bank_Account_Number__c = 'P00000000101',
            EYI_Name_of_Bank_Account__c = 'Pune State',
            EYI_REC_Account__c = rec.id            
        );
        insert bnkDet;
        
        // Create Lead
        Lead leads = new Lead(
            FirstName = 'test lead',
            LastName = 'lead',
            EYI_LeadType__c = 'Villa',
            EYI_Segment__c = 'Residential',
            Company = 'test cloud',
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Purpose_of_Purchase__c = 'Investment',
            EYI_Project_Enquired__c = projctobj.id
        );
        insert leads;
        
        // Create Campaign with Status = 'Planned' to satisfy Validate_Status_On_Campaign_Create
        Campaign camp = new Campaign(
            Name = 'Campaign approval testing',
            EYI_Campaign_Level__c = 'Project',
            Type = 'Telemarketing',
            Status = 'Planned', // Satisfies validation rule
            IsActive = false, // Initially false to avoid conflicts
            EYI_Source__c = 'Email',
            EYI_Campaign_Purpose__c = 'Fixed Cost',
            EYI_Campaign_Type__c = 'Fixed',
            EYI_Project_Name__c = projctobj.id,
            EYI_DID_Number__c = 627289 // Smaller value to avoid potential issues
        );
        insert camp;
        
        // Update Campaign to satisfy EYI_Lead_Enquiry__c lookup filter
        camp.Status = 'In Progress';
        camp.IsActive = true;
        update camp;
        
        // Create EYI_Lead_Enquiry__c
        EYI_Lead_Enquiry__c LeadEnq = new EYI_Lead_Enquiry__c(
            Name = 'Test Campaign',
            EYI_Email__c = 'viksit.rana@in.ey.com',
            EYI_Lead_Source__c = 'Direct Client',
            DNC__c = false,
            EYI_Campaign_Name__c = camp.id,
            EYI_Parent_Record__c = leads.id
        );
        insert LeadEnq;
        
        // Create ContentVersion and ContentDocumentLink for EYI_DocData testing
        ContentVersion testVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf', // Use .pdf to match EYI_DocData.getData
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testVersion;
        
        ContentVersion testVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion.Id];
        
        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = acc.Id,
            ContentDocumentId = testVersion1.ContentDocumentId,
            ShareType = 'V'
        );
        insert testCDL;
        
        ContentVersion testVersion2 = new ContentVersion(
            Title = 'Test Document 2',
            PathOnClient = 'TestDocument2.pdf', // Use .pdf
            VersionData = Blob.valueOf('Test Data 2'),
            IsMajorVersion = true
        );
        insert testVersion2;
        
        ContentVersion testVersion2Query = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion2.Id];
        
        ContentDocumentLink testCDL2 = new ContentDocumentLink(
            LinkedEntityId = acc.Id,
            ContentDocumentId = testVersion2Query.ContentDocumentId,
            ShareType = 'V'
        );
        insert testCDL2;
        
        // Mock HTTP callout for EYI_DocData
        String mockResponse = '{"n0:ZSD_CREATE_CUSTOMER_FROM_SFResponse":{"EX_CUTSOMER":"23","EX_RETURN":{"item":{"TYPE":"S","ID":"CVI_EI","NUMBER":"033","MESSAGE":"Enter the complete key for the sales area","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""}}}}';
        Test.setMock(HttpCalloutMock.class, new EYI_testHttpServiceConsumerMock(mockResponse));
        
        Test.startTest();
        // Test EYI_DocData methods
        String result = EYI_DocData.getRecordsId(acc.id);
        System.assertNotEquals('', result, 'getRecordsId should return a non-empty string');
        
        List<String> files = EYI_DocData.getData(acc.id);
        System.assertEquals(2, files.size(), 'getData should return two PDF files');
        
        EYI_DocData.createContentVersion('base64Pdf', 'fileName.pdf', acc.id);
        
        Boolean exceptionThrown = false;
        try {
            EYI_DocData.createContentVersion('not_base64', 'BadFile.pdf', acc.id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception should be thrown for invalid base64');
        
        Test.stopTest();
    }
    
    // Mock class for HTTP callout
    public class EYI_testHttpServiceConsumerMock implements HttpCalloutMock {
        private String response;
        
        public EYI_testHttpServiceConsumerMock(String response) {
            this.response = response;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
}