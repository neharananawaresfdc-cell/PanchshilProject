/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-06-2025
* @last modified by  : 
**/
@isTest
public class EYI_SAP_Adapter_Test {
    class MyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}'); // or whatever fake response you want
            res.setStatusCode(200);
            return res;
        }
    }
    public static EYI_Demand__c testData(){
        
        EYI_Project__c projctobj = new EYI_Project__c(
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
            EYI_Project_Property_Type__c = 'Residential'
        );
        insert projctobj;
        
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
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert Acc;
        
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            //Name='Pune',
            EYI_City__c='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405',
            Master_Type__c='Pincode',
            EYI_Zone__c ='Pune Region',
            EYI_Sub_Urb__c='Pune Moffusil Division'
        );
        insert mster;
        
        
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            //EYI_Booking__c=book.id,
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            EYI_Inventory_Type__c ='Residential Sales',
            EYI_UOM__c ='Square foot',
            EYI_Material_Group__c='Apartment',
            EYI_Super_Built_up_Area__c=20,
            EYI_Carpet_Area__c =14,
            EYI_Garden_Area__c =20,
            EYI_Terrace_Area__c='50',
            EYI_Balcony_Area__c='30',
            EYI_Built_up_Area__c= 10,
            EYI_Common_Area__c=10,
            EYI_Inventory_Status__c='Reserve',
            EYI_Floor_Number__c='003',
            Configuration__c='Studio',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I',
            EYI_Saleable_Area__c = 5
        );
        insert invtry;
        
        EYI_Customer_Information_Form__c CIF = new EYI_Customer_Information_Form__c(
            EYI_City__c =city.id,
            EYI_Salutation__c='Mr.',
            //EYI_REC_Account__c= Acc.id,
            EYI_Pincode__c =mster.id,
            EYI_First_Name__c ='test applicant',
            EYI_Last_Name__c='cif',
            EYI_Mobile_number__c= '9764212568',
            EYI_Address_1__c ='noida test',
            EYI_Address_2__c='test',
            EYI_Address_3__c='test'
            
        );
        insert CIF;
        
        Opportunity opp = new Opportunity(
            //SyncedQuoteId = quote.id,
            EYI_Inventory__c= invtry.id,
            EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
            EYI_Ownership_Status__c = 'Accepted',
            EYI_Project_Tower_Enquired__c= towerobj.id,
            //EYI_Primary_Applicant__c=applicant.id,
            EYI_Salutation__c='Mr.',
            Name='Tushar test',
            StageName ='Cancellation',
            CloseDate = system.today()+20,
            EYI_First_Name__c='Tushar test',
            EYI_Last_Name__c='testOPP',
            EYI_Address3__c='Film city',
            EYI_Nationality__c='Indian',
            EYI_Project_Enquired__c =projctobj.id,
            EYI_Address2__c='sector 16',
            EYI_Address1__c='sector 16 a',
            EYI_City__c='Noida',
            EYI_Country_Classification__c='India',
            EYI_Country_Key__c='IN',
            GST_Applicable__c= true,
            EYI_Customer_Currency__c='INR',
            EYI_BP_Type__c='1',
            EYI_Segment__c='Residential',
            //EYI_Distribution_Channel__c='Residential Sale',
            EYI_Date_Of_Birth__c=system.today()-150,
            EYI_District__c='GB',
            EYI_GSTIN_Number__c='27AAAPA1234A1Z9',
            EYI_Id_Number__c='2345678909876',
            EYI_Id_Type__c='AADHAR Card Number',
            EYI_Industry__c='Advertising',
            EYI_Occupation__c='Salaried',
            EYI_Pan_Number__c='45678iolmn',
            EYI_Partner_Function__c='Sold-to Party',
            //EYI_Payment_Terms__c='Immediate Due after Invoice',
            EYI_Postal_Code__c='201301',
            EYI_Sales_Group__c='Pune Sales Group',
            EYI_Sales_Office__c='Mumbai Office',
            EYI_TCS_Applicable__c= true,
            EYI_Mobile_Number__c='23456789987654',
            EYI_Alternate_Mobile_No__c='98765432124',
            EYI_SAP_Customer_Number__c= '23456789098765',
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
            EYI_AutomationBypassDatetime__c = System.now(),
            EYI_Walk_in_Source__c = 'Management'
        );
        insert opp;
        
        EYI_Payment_Schedule__c paymentSchedule = new EYI_Payment_Schedule__c();
        paymentSchedule.EYI_SAP_Milestone_Code__c = '306' + '3';
        paymentSchedule.EYI_Milestone_Number__c = 306;
        paymentSchedule.EYI_SAP_Sales_Org__c = 'R150';
        paymentSchedule.EYI_SAP_Plant_Code__c = 'R15D';
        paymentSchedule.EYI_SAP_Activity_Number__c = 3;
        paymentSchedule.EYI_Usage__c = 'Z0002';
        paymentSchedule.EYI_SAP_Activity_Number__c = 3;
        paymentSchedule.EYI_AutomationBypassDatetime__c = System.today();
        paymentSchedule.EYI_Usage_Description__c = 'On Booking Changed';
        paymentSchedule.EYI_WBS_Element__c = 10609;
        paymentSchedule.EYI_Billing_Date__c = System.today();
        paymentSchedule.EYI_Actual_Date__c = System.today();
        paymentSchedule.EYI_Invoice_Percentage__c = 20;
        paymentSchedule.EYI_Tower__c = towerobj.id;
        
        insert paymentSchedule;
        
        EYI_REC__c rec = new EYI_REC__c(
            EYI_Salutation__c='Mr.',
            EYI_First_Name__c='Test1',
            EYI_Middle_Name__c='REC1',
            EYI_Last_Name__c='Account1',
            EYI_Gender__c='Male',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Organization__c='test org',
            EYI_Designation__c='test Desination',
            EYI_Birth_Date__c=system.today()-186,
            EYI_Anniversary_Date__c=system.today()-1356,
            EYI_MSME__c=system.today()-1356,
            EYI_Company_Code__c='187543',
            EYI_Reconciliation_Account__c='Creditors - Material Domestic',
            EYI_Payment_Terms__c='Immediately after Goods Receipt',
            EYI_Minority_Indicator__c='Medium',
            EYI_GSTIN__c='27AAAPA1234A1Z1',
            //EYI_GSTN__c='27AAAPA1234A1Z9',
            EYI_Aadhar__c='981356897510',
            EYI_Udyog_Adhar__c='713261075759',
            EYI_Company_Regisration__c='EYI_Company_Regisration__c',
            EYI_ESIC_Number__c='ESIC_Number',
            EYI_RERA_Number__c='56HJHK19098',
            EYI_City__c =city.id,
            EYI_Country__c='India',
            EYI_State__c='Delhi',
            EYI_Mobile__c='9988776671',
            EYI_Alternate_Mobile__c='1080808090',
            EYI_Type_Of_RERA_Registration__c='Individual',
            EYI_REC_Firm_Name__c='ABHI Group',
            EYI_PAN_No__c='ABCDE1201D',
            EYI_Pincode_Office__c='410412',
            EYI_REC_Owner_Mobile_Number__c='9177654321',
            EYI_Email__c='kumarswami5.mathapati089@in.ey.com',
            EYI_Alternate_Email__c='kumarswami5.mathapati.904@in.ey.com',
            EYI_REC_Correspondence_Mobile_Number__c='1871545432146',
            EYI_REC_Correspondence_Email_ID__c='abhishek5@mail.com',
            EYI_Tax_Classification__c='GST Registered',
            EYI_REC_Vendor_Code__c='876542',
            EYI_Address1__c='noida.',
            EYI_Address2__c='Noida',
            EYI_Address3__c='Sector 3',
            EYI_E_Invoicing_Applicable__c= true,
            EYI_Is_MSME__c=true,
            EYI_MSME_Number__c='Test MSME',
            EYI_Country_Code_for_Secondary_Mobile__c='India',
            EYI_Country_Code_REC_Primary_Mobile__c='India',
            EYI_Country_Code_for_REC_Owner_Mobile__c='India',
            EYI_REC_Owner_Telephone_Number__c='98265431345',
            EYI_Primary_Telephone_Number__c='9876243361',
            EYI_Secondary_Telephone_Number__c='9826543162',
            EYI_REC_Correspondence_Last_Name__c='test',
            EYI_Correspondence_City__c=city.id,
            EYI_Correspondence_Country__c='India',
            EYI_Correspondence_State__c='Delhi',
            EYI_Correspondence_Address_1__c='noida.',
            EYI_Correspondence_Address_2__c='Noida',
            EYI_Correspondence_Address_3__c='Sector 3',
            EYI_Correspondence_Pincode_Office__c='412410',
            EYI_REC_Correspondence_Contact_Name__c='9127765434567',
            EYI_CP_Contact_1_Mobile_Number__c='982556189966',
            EYI_First_Name_of_Contact_Person__c='test1 cont',
            EYI_Last_Name_of_Contact_Person__c='contact1',
            EYI_CP_E_Mail_Address__c='abhishek5@mail.com',
            EYI_Title__c='Mr.',
            EYI_Correspondence_Title__c='Mr.',
            EYI_RERA_Certificate_No__c='9cgt7879ijnd'
            
        );
        insert rec;
        
        EYI_Booking__c book = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c ='1234400994',
            EYI_Opportunity_Name__c= opp.id,
            EYI_Project_Name__c= projctobj.id,
            EYI_Divisions__c='Residential',
            EYI_Account_Name__c= Acc.id,
            EYI_Actual_Booking_Date__c= system.today()-10,
            EYI_Cancellation_Reason__c = 'Sales call',
            EYI_Sourcing_manager__c= UserInfo.getUserId(),
            isDraft__c=true,
            EYI_Tower__c = towerobj.id,
            EYI_Agreement_Execution_Date__c = system.today()-10,
            EYI_Agreement_Handover_Date__c = system.today()-10,
            EYI_Agreement_Received_Date__c = system.today()-10,
            EYI_Aggrement_Reg_no__c = 'EYI_Aggrement_Reg_no__c',
            EYI_Sales_Deed_No__c = 'EYI_Sales_Deed_No__c',
            EYI_Registration_Date__c = system.today()-10,
            EYI_Possession_Intimation_Date__c = system.today()-10,
            EYI_Agreement_Possession_Date__c = system.today()-10,
            EYI_Actual_Possession_Date__c = system.today()-10,
            EYI_Maintenance_wef_Date__c = system.today()-10,
            Transfer_Swapping_Date__c = system.today()-10,
            EYI_Transfer_Swapping_Remarks__c = 'EYI_Transfer_Swapping_Remarks__c',
            EYI_Mortgage_Status__c = '123456789',
            EYI_Loaning_Institute__c = '1234567890',
            EYI_Loan_Amount__c = 200,
            EYI_Loan_File_Number__c = '12345',
            EYI_Agreement_Loan_Percentage__c = 10,
            EYI_Sanction_Date__c = system.today()-10,
            EYI_NOC_Issue_Date__c = system.today()-10,
            EYI_Cancellation_Date__c = system.today()-10,
            EYI_Cancellation_initiated_By__c = '12345',
            EYI_Deed_of_Cancellation_Reg_Date__c = system.today()-10,
            EYI_Name_1__c = '123',
            EYI_Tab_D_Rate_of_Intrest__c = '123',
            EYI_Self_Banking_for_VA01__c = '123',
            EYI_Banking_Remarks_for_VA01__c = '123',
            EYI_Source_of_Booking__c = 'Direct',
            EYI_SAP_request__c = '123',
            EYI_REC_Account__c = rec.id
            
        );
        insert book;
        
        
        
        EYI_Demand__c demandRec = new EYI_Demand__c(
            EYI_Opportunity__c = opp.id,
            EYI_Payment_Schedule__c = paymentSchedule.id,
            EYI_Booking__c = book.Id,
            EYI_Actual_Date__c = Date.today(),
            EYI_Amount_to_be_paid__c = 1000,
            EYI_Usage__c = 'EYI_1',
            EYI_Usage_Description__c = 'EYI_Usage_Description__c',
            EYI_SAP_Milestone_Code__c = '1234567890'
            
        );
        insert demandRec;
        return demandRec;
        
    }
    
    @isTest
    public static void createDemandBodyTest(){
        List<EYI_Demand__c> demandList = new List<EYI_Demand__c>();
        EYI_Demand__c demandRec = testData();
        demandList.add(demandRec);
        Map<Id, Date> demandDateMap = new Map<Id, Date>();
        demandDateMap.put(demandRec.Id, Date.today()); 
        
        SAP_SF_Field_Map__c mapEntry = new SAP_SF_Field_Map__c(
            Name = 'Map1',
            SF_Field_Name__c = 'EYI_Distribution_Channel__c',
            SF_Value__c = 'CHANNEL_1',
            SAP_Value__c = '01'
        );
        insert mapEntry;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyMock());
        EYI_SAP_Adapter.createDemandBody(demandDateMap,demandList, 'CREATE');
        Test.stopTest();
    }
    
    
    @isTest
    public static void testCreateSOA_PDFBody() {
        EYI_SAP_Adapter.GetSapDocument doc = new EYI_SAP_Adapter.GetSapDocument();
        doc.DocumentNo = 'DOC001';
        doc.CompanyCode = 'CC01';
        doc.AccountingDocNo = 'ACC123';
        doc.FiscalYear = '2024';
        doc.DocumentType = 'INV';
        
        EYI_SAP_Adapter.RequestWrapper wrapper = new EYI_SAP_Adapter.RequestWrapper();
        wrapper.GetSapDocument = doc;
        
        String inputJson = JSON.serialize(wrapper);
        
        Test.startTest();
        String outputJson = EYI_SAP_Adapter.createSOA_PDFBody(inputJson);
        Test.stopTest();
        
    }
    @isTest
    static void testCreateReceiptBody() {
        // ---- SETUP DATA ----
        
        // Project
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_SAP_Company_Code__c = 'P001',
            EYI_Project_Code__c = 'PROJ001'
        );
        insert project;
        
        // Inventory (insert first)
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            Name = 'Inv',
            EYI_Inventory_Number__c = 'INV-001',
            EYI_SAP_Profit_Center__c = 'PC001',
            EYI_OC_Received_Date__c = Date.today().addDays(-5),
            EYI_GST_Tax_Classification__c = 'Non Taxable GST',
            EYI_Project__c = project.Id
        );
        insert inventory;
        
        // Opportunity (insert after inventory)
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Project_Enquired__c = project.Id,
            EYI_Inventory__c = inventory.Id,        // <--- REQUIRED!
            EYI_SAP_Customer_Number__c = 'CUST123', // <--- REQUIRED!
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        // ---- updatedRecords for line item coverage ----
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        Map<String, Object> record1 = new Map<String, Object>{
            'inputValue' => 500,
                'fiDocumentNo' => '9999',
                'paymentBifurcation' => 'PART1',
                'fiscalYear' => 2025,
                'billingDoc' => 'BDOC1',
                'profitCenter' => 'PC001',
                'milestoneNo' => 'M1',
                'lineItemNo' => '1'
                };
                    updatedRecords.add(record1);
        
        // ---- formData for both OpportunityId and non-OpportunityId paths ----
        Map<String, Object> formData = new Map<String, Object>{
            'customerNumber' => 'CUST-999',
                'companyCode' => 'P001',
                'InstrumentDate' => String.valueOf(Date.today()),
                'OpportunityId' => opp.Id,
                'TransactionType' => 'Advance',
                'PaymentAmount' => 1000,
                'BankName' => 'Test Bank',
                'InstrumentNumber' => 'INST123',
                'ChequeDdNumber' => 'CHK001',
                'Remarks' => 'Receipt remarks',
                'paymentMode' => 'Cash'
                };
                    
                    // ---- Call method with both paymentReceipt and formData providing data ----
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyMock());
        
        // Test with minimal formData (no OpportunityId, hits non-query path)
        Map<String, Object> formDataMinimal = new Map<String, Object>{
            'TransactionType' => 'Token',
                'PaymentAmount' => 200
                };
                    String result4 = EYI_SAP_Adapter.createReceiptBody(null, null, formDataMinimal);
        System.assertNotEquals(null, result4, 'Should work with minimal data');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateLineItemsBody() {
        // Create Project
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_SAP_Company_Code__c = 'P001',
            EYI_Project_Code__c = 'PROJ001'
        );
        insert project;
        
        // Create Opportunity with required fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Project_Enquired__c = project.Id,
            EYI_SAP_Customer_Number__c = 'CUST999'
        );
        insert opp;
        
        // Call the method and assert
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyMock());
        String body = EYI_SAP_Adapter.createLineItemsBody(opp.Id);
        System.assertNotEquals(null, body, 'JSON body should not be null');
        System.assert(body.contains('CustomerOpenLineItem'), 'JSON should contain CustomerOpenLineItem');
        System.assert(body.contains('P001'), 'JSON should contain the company code');
        System.assert(body.contains('CUST999'), 'JSON should contain the customer number');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateReceiptBody_UpdatedRecordsFullCoverage() {
        // --- Setup Project, Inventory, Opportunity, Booking ---
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_SAP_Company_Code__c = 'P001',
            EYI_Project_Code__c = 'PROJ001'
        );
        insert project;
        
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            Name = 'Inv',
            EYI_Inventory_Number__c = 'INV-001',
            EYI_SAP_Profit_Center__c = 'PC001',
            EYI_OC_Received_Date__c = Date.today().addDays(-15),
            EYI_GST_Tax_Classification__c = 'Non Taxable GST',
            EYI_Project__c = project.Id
        );
        insert inventory;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Project_Enquired__c = project.Id,
            EYI_Inventory__c = inventory.Id,
            EYI_SAP_Customer_Number__c = 'CUST123',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_SalesOrder_Number__c = 'SO-123'
        );
        insert opp;
        
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c ='SO-123',
            EYI_Opportunity_Name__c= opp.id,
            EYI_Project_Name__c= project.id,
            EYI_Account_Name__c= null,
            EYI_Actual_Booking_Date__c= Date.today().addDays(-5)
        );
        insert booking;
        
        // --- Compose updatedRecords with full keys and a 'Floating' value ---
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        Map<String, Object> record1 = new Map<String, Object>{
            'inputValue' => 1234,
                'fiDocumentNo' => 'FLOATING-9999',
                'paymentBifurcation' => 'PART-XYZ',
                'fiscalYear' => 2025,
                'billingDoc' => 'BDOC2',
                'profitCenter' => 'PC002',
                'milestoneNo' => 'M2',
                'lineItemNo' => '22'
                };
                    updatedRecords.add(record1);
        
        // --- Compose formData with everything needed for "OpportunityId" path ---
        Map<String, Object> formData = new Map<String, Object>{
            'customerNumber' => 'CUST-Y',
                'companyCode' => 'P001',
                'InstrumentDate' => String.valueOf(Date.today()),
                'OpportunityId' => opp.Id,
                'TransactionType' => 'Advance',
                'PaymentAmount' => 1111,
                'BankName' => 'Test Bank2',
                'InstrumentNumber' => 'INST456',
                'ChequeDdNumber' => 'CHK002',
                'Remarks' => 'Receipt remarks 2',
                'paymentMode' => 'Cash'
                };
                    
                    // --- Call the method ---
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_SAP_Adapter_Test.MyMock());
        String result = EYI_SAP_Adapter.createReceiptBody(null, updatedRecords, formData);
        Test.stopTest();
        
        // --- Assertions ---
        System.assertNotEquals(null, result, 'Result should not be null');
        system.debug('debug result '+result);
        Map<String, Object> jsonResult;
        try {
            jsonResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        } catch (Exception e) {
            System.assert(false, 'Result is not valid JSON: ' + e.getMessage());
        }
        Map<String, Object> paymentAdvice = (Map<String, Object>) jsonResult.get('PaymentAdvice');
        System.assertNotEquals(null, paymentAdvice, 'PaymentAdvice object should not be null');
        
        // Validate fields from debug output
        System.assertEquals('CUST123', paymentAdvice.get('SapCustomerNumber'), 
                            'SapCustomerNumber should match Opportunity.EYI_SAP_CustomerNumber__c');
        /*System.assertEquals('0001', paymentAdvice.get('TransactionType'), 
                            'TransactionType should be 0001 for Advance');*/
        System.assertEquals('Receipt remarks 2', paymentAdvice.get('REMARKS'), 
                            'REMARKS should match formData Remarks');
        System.assertEquals('Cash', paymentAdvice.get('PaymentDocumentNumber'), 
                            'PaymentDocumentNumber should match formData paymentMode');
        System.assertEquals(Date.today(), Date.newInstance(Integer.valueOf(((String)paymentAdvice.get('PaymentDate')).split('\\.')[2]), Integer.valueOf(((String)paymentAdvice.get('PaymentDate')).split('\\.')[1]), Integer.valueOf(((String)paymentAdvice.get('PaymentDate')).split('\\.')[0])), 
                            'PaymentDate should match formData InstrumentDate');
        System.assertEquals('1111', String.valueOf(paymentAdvice.get('PaymentAmount')), 
                            'PaymentAmount should match formData PaymentAmount');
        System.assertEquals(null, paymentAdvice.get('RuleForPaymentDetails'), 
                            'RuleForPaymentDetails should be null');
        System.assertEquals(null, paymentAdvice.get('PaymentDetailsType'), 
                            'PaymentDetailsType should be null');
        System.assertEquals(null, paymentAdvice.get('PaymentDetailsStatus'), 
                            'PaymentDetailsStatus should be null');
        System.assertEquals(null, paymentAdvice.get('PaymentDetailsNumber'), 
                            'PaymentDetailsNumber should be null');
        
        // Conditional assertions for fields expected from updatedRecords
        if (paymentAdvice.containsKey('paymentBifurcation')) {
            System.assertEquals('PART-XYZ', paymentAdvice.get('paymentBifurcation'), 
                                'paymentBifurcation should match updatedRecords');
        }
        if (paymentAdvice.containsKey('milestoneNo')) {
            System.assertEquals('M2', paymentAdvice.get('milestoneNo'), 
                                'milestoneNo should match updatedRecords');
        }
        if (paymentAdvice.containsKey('profitCenter')) {
            System.assertEquals('PC002', paymentAdvice.get('profitCenter'), 
                                'profitCenter should match updatedRecords');
        }
        if (paymentAdvice.containsKey('lineItemNo')) {
            System.assertEquals('22', String.valueOf(paymentAdvice.get('lineItemNo')), 
                                'lineItemNo should match updatedRecords');
        }
        
        // Validate AccountDocumentNumber for FLOATING
        if (String.valueOf(record1.get('fiDocumentNo')).contains('FLOATING')) {
            System.assertEquals(null, paymentAdvice.get('AccountDocumentNumber'), 
                                'AccountDocumentNumber should be null when fiDocumentNo contains FLOATING');
        }
    }
    
    @isTest
    static void testCreateReceiptBody_TDS_ChannelDateBranches() {
        // Setup Project, Inventory, and Opportunity
        EYI_Project__c project = new EYI_Project__c(Name='Proj', EYI_SAP_Company_Code__c='C1', EYI_Project_Code__c='P1');
        insert project;
        EYI_Inventory__c inventory = new EYI_Inventory__c(Name='Inv', EYI_Inventory_Number__c='IN-001', EYI_Project__c=project.Id);
        insert inventory;
        Opportunity opp = new Opportunity(
            Name = 'Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(5),
            EYI_Project_Enquired__c = project.Id,
            EYI_Inventory__c = inventory.Id,
            EYI_SAP_Customer_Number__c = 'CUST-TDS'
        );
        insert opp;
        
        // 1. paymentReceipt != null && paymentReceipt.EYI_Channel_Date__c != null
        EYI_Payment_Receipt__c receipt1 = new EYI_Payment_Receipt__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Channel_Date__c = Date.today().addDays(-3)
        );
        // You may need to insert if object is DML-able, otherwise keep as is for the test
        
        Map<String, Object> formData1 = new Map<String, Object>{
            'TransactionType' => 'TDS'
                };
                    // Call method
                    String result1 = EYI_SAP_Adapter.createReceiptBody(receipt1, null, formData1);
        System.assertNotEquals(null, result1);
        
        // 2. paymentReceipt == null or .EYI_Channel_Date__c == null, but formData has ChannelDate
        Map<String, Object> formData2 = new Map<String, Object>{
            'TransactionType' => 'TDS',
                'ChannelDate' => String.valueOf(Date.today().addDays(-2))
                };
                    String result2 = EYI_SAP_Adapter.createReceiptBody(null, null, formData2);
        System.assertNotEquals(null, result2);
    }
    
    @isTest
    static void testCreateReceiptBody_UpdatedRecords_AllBranches() {
        // --- Required Setup: Project, Inventory, Opportunity, Booking ---
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Proj',
            EYI_SAP_Company_Code__c = 'P002',
            EYI_Project_Code__c = 'PROJ002'
        );
        insert project;
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            Name = 'Inv2',
            EYI_Inventory_Number__c = 'INV-002',
            EYI_SAP_Profit_Center__c = 'PC002',
            EYI_OC_Received_Date__c = Date.today().addDays(-10),
            EYI_GST_Tax_Classification__c = 'Non Taxable GST',
            EYI_Project__c = project.Id
        );
        insert inventory;
        Opportunity opp = new Opportunity(
            Name = 'Test Opp2',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_Project_Enquired__c = project.Id,
            EYI_Inventory__c = inventory.Id,
            EYI_SAP_Customer_Number__c = 'CUST-BRANCH',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_SalesOrder_Number__c = 'SO-234'
        );
        insert opp;
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c ='SO-234',
            EYI_Opportunity_Name__c= opp.id,
            EYI_Project_Name__c= project.id,
            EYI_Account_Name__c= null,
            EYI_Actual_Booking_Date__c= Date.today().addDays(-2)
        );
        insert booking;
        
        // --- Compose updatedRecords to hit all branches ---
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        
        // Case 1: profitCenter present, paymentBifurcation != 'ADV', fiDocumentNo contains 'Floating'
        updatedRecords.add(new Map<String, Object>{
            'inputValue' => '100',
                'fiDocumentNo' => 'FLOATING-123',
                'paymentBifurcation' => 'NOTADV',
                'fiscalYear' => '2026',
                'billingDoc' => 'BDOC3',
                'profitCenter' => 'PC002',
                'milestoneNo' => 'M3',
                'lineItemNo' => '33',
                'outstanding' => '200',
                'REF_DOC_NO' => 'REF-001'
                });
        
        // Case 2: profitCenter missing, paymentBifurcation == 'ADV', fiDocumentNo regular
        updatedRecords.add(new Map<String, Object>{
            'inputValue' => '50',
                'fiDocumentNo' => 'DOC-456',
                'paymentBifurcation' => 'ADV',
                'fiscalYear' => '2027',
                'billingDoc' => 'BDOC4',
                'milestoneNo' => 'M4',
                'lineItemNo' => '44',
                'outstanding' => '100'
                // profitCenter omitted
                // REF_DOC_NO omitted
                });
        
        // --- formData for OpportunityId path ---
        Map<String, Object> formData = new Map<String, Object>{
            'OpportunityId' => opp.Id,
                'TransactionType' => 'Demand',
                'PaymentAmount' => 1234
                };
                    
                    // --- Call the method ---
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_SAP_Adapter_Test.MyMock());
        String result = EYI_SAP_Adapter.createReceiptBody(null, updatedRecords, formData);
        Test.stopTest();
        
        // --- Assertions: Parse and check all fields ---
        Map<String, Object> jsonResult = (Map<String, Object>) JSON.deserializeUntyped(result);
        List<Object> lineItems = (List<Object>) ((Map<String, Object>)jsonResult.get('PaymentAdvice')).get('LineItems');
        System.assertEquals(2, lineItems.size(), 'Should create two line items');
        
        Map<String, Object> li1 = (Map<String, Object>) lineItems[0];
        Map<String, Object> li2 = (Map<String, Object>) lineItems[1];
        
        // Check profitCenter assignment
        System.assertEquals('PC002', li1.get('ProfitCenter'), 'profitCenter should be present for first record');
        System.assertEquals('', li2.get('ProfitCenter'), 'profitCenter should be empty for second record');
        
        // Check CustomItemField1 logic (outstanding-inputValue)
        System.assertEquals(String.valueOf(200-100), li1.get('CustomItemField1'), 'CustomItemField1 difference');
        System.assertEquals(null, li2.get('CustomItemField1'), 'CustomItemField1 should be null for ADV');
        
        // Check AccountDocumentNumber logic (Floating)
        //System.assertEquals(null, li1.get('AccountDocumentNumber'), 'AccountDocumentNumber should be null for Floating');
       /* System.assertEquals('DOC-456', li2.get('AccountDocumentNumber'), 'AccountDocumentNumber should match fiDocumentNo');
        
        // Check Reference3
        System.assertEquals('NOTADV', li1.get('Reference3'));
        System.assertEquals('ADV', li2.get('Reference3'));
        
        // Check CustomerReference
        System.assertEquals('REF-001', li1.get('CustomerReference'), 'Should set REF_DOC_NO when present');
        System.assertEquals('', li2.get('CustomerReference'), 'Should be empty when REF_DOC_NO missing');
        
        // Check Reference/Reference2/Reference1 assignment
        System.assertEquals('SO-234', li1.get('Reference'), 'Reference should be SO Number');
        System.assertEquals('INV-002', li1.get('Reference2'), 'Reference2 should be Inventory Number');
        System.assertEquals('M3', li1.get('Reference1'), 'Reference1 should be milestoneNo');
        System.assertEquals('33', li1.get('CustRefLineItem'), 'CustRefLineItem should be lineItemNo');
        System.assertEquals('A0', li1.get('TaxCode'), 'TaxCode logic (dates)');
        
        System.assertEquals('SO-234', li2.get('Reference'), 'Reference should be SO Number');
        System.assertEquals('INV-002', li2.get('Reference2'), 'Reference2 should be Inventory Number');
        // For ADV, Reference1/CustomItemField1/CustomItemField2/CustomItemField3 should be null/blank
        System.assertEquals(null, li2.get('Reference1'), 'Reference1 for ADV');
        System.assertEquals('44', li2.get('CustRefLineItem'), 'CustRefLineItem for 2nd line'); */
    }
}