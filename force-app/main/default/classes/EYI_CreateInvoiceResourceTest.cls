@isTest
public class EYI_CreateInvoiceResourceTest {
	 // Mock callout class
    public class MockSAPCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"n0:ZSD_REC_INVOICE_FROM_SFResponse":{"EX_OUTPUT":{"item":{"EBELN":"4500012345","TRACK_ID":"ABC123XYZ","MESSAGE":"Success","TYPE":"S"}}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    static testMethod void test_validateInvoiceSync_success() {
        Test.setMock(HttpCalloutMock.class, new MockSAPCallout());
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Project_Status__c = 'Pre- Launch',
            EYI_Project_Type__c = 'Flat',
            EYI_Zone__c = 'Pune City',
            EYI_City__c='Pune',
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

        Account acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert acc;

        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Name='Nilesh Arvind Ghodke',
            EYI_Last_Name__c='Arvind Ghodke',
            EYI_Pancard_Number__c='DLWPG4197L',
            EYI_Applicant_Type__c='Primary Applicant'
        );
        insert applicant;

        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;

        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            EYI_City__c='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405',
            Master_Type__c='Pincode',
            EYI_Zone__c ='Pune Region',
            EYI_Sub_Urb__c='Pune Moffusil Division'
        );
        insert mster;

        EYI_Customer_Information_Form__c CIF = new EYI_Customer_Information_Form__c(
            EYI_City__c =city.id,
            EYI_Salutation__c='Mr.',
            EYI_Pincode__c =mster.id,
            EYI_First_Name__c ='test applicant',
            EYI_Last_Name__c='cif',
            EYI_Mobile_number__c= '9764212568',
            EYI_Address_1__c ='noida test',
            EYI_Address_2__c='test',
            EYI_Address_3__c='test',
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert CIF;

        EYI_Inventory__c invtry = new EYI_Inventory__c(
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
            EYI_SAP_Profit_Center__c='R150R1R15I'
        );
        insert invtry;

        Opportunity opp = new Opportunity(
            EYI_Inventory__c= invtry.id,
            EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
            EYI_Project_Tower_Enquired__c= towerobj.id,
            EYI_Primary_Applicant__c=applicant.id,
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
            EYI_Date_Of_Birth__c=system.today()-150,
            EYI_District__c='GB',
            EYI_GSTIN_Number__c='27AAAPA1454A1Z9',
            EYI_Id_Number__c='2345678909876',
            EYI_Id_Type__c='AADHAR Card Number',
            EYI_Industry__c='Advertising',
            EYI_Occupation__c='Salaried',
            EYI_Pan_Number__c='45678iolmn',
            EYI_Partner_Function__c='Sold-to Party',
            EYI_Ownership_Status__c= 'Accepted',
            EYI_Payment_Terms__c='15 Days Credit From the Date of Invoice',
            EYI_Postal_Code__c='201301',
            EYI_Sales_Group__c='Pune Sales Group',
            EYI_Sales_Office__c='Mumbai Office',
            EYI_TCS_Applicable__c= true,
            EYI_Mobile_Number__c='9089898090',
            EYI_Alternate_Mobile_No__c='98765432124',
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
            EYI_AutomationBypassDatetime__c = System.now()
        );
        insert opp;

        EYI_Applicants__c oppAplicant = new EYI_Applicants__c(
            Name='Nilesh Arvind Ghodke',
            EYI_Title__c='Mr.',
            EYI_Email__c='neha.rananaware@in.ey.com',
            EYI_Last_Name__c='Ghodke',
            EYI_Mobile_Number__c='09765117411',
            EYI_Pancard_Number__c='DLWPG4197L',
            EYI_Applicant_Type__c='Primary Applicant',
            Opportunity__c=opp.id
        );
        insert oppAplicant;

        EYI_REC__c rec = new EYI_REC__c(
            EYI_Salutation__c='Mr.',
            EYI_First_Name__c='Test',
            EYI_Middle_Name__c='REC',
            EYI_Last_Name__c='Account',
            EYI_Gender__c='Male',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Organization__c='test org',
            EYI_Designation__c='test Desination',
            EYI_Birth_Date__c=system.today()-186,
            EYI_Anniversary_Date__c=system.today()-1356,
            EYI_MSME__c=system.today()-1356,
            EYI_Company_Code__c='987543',
            EYI_Reconciliation_Account__c='Creditors - Material Domestic',
            EYI_Payment_Terms__c='Immediately after Goods Receipt',
            EYI_Minority_Indicator__c='Medium',
            EYI_GSTIN__c='27AAAPA1234A1Z9',
            EYI_Aadhar__c='981356897543',
            EYI_Udyog_Adhar__c='713264675759',
            EYI_Company_Regisration__c='EYI_Company_Regisration__c',
            EYI_ESIC_Number__c='ESIC_Number',
            EYI_RERA_Number__c='56HJHK89098',
            EYI_City__c =city.id,
            EYI_Country__c='India',
            EYI_State__c='Delhi',
            EYI_Mobile__c='9988776677',
            EYI_Alternate_Mobile__c='7080808090',
            EYI_Type_Of_RERA_Registration__c='Individual',
            EYI_REC_Firm_Name__c='ABHI Group',
            EYI_PAN_No__c='ABCDE1234D',
            EYI_Pincode_Office__c='987722443',
            EYI_REC_Owner_Mobile_Number__c='9877654321',
            EYI_Email__c='kumarswami.mathapati089@in.ey.com',
            EYI_Alternate_Email__c='kumarswami.mathapati.904@in.ey.com',
            EYI_REC_Correspondence_Mobile_Number__c='9876545432146',
            EYI_REC_Correspondence_Email_ID__c='abhishek@mail.com',
            EYI_Tax_Classification__c='GST Registered',
            EYI_REC_Vendor_Code__c='876543',
            EYI_Address1__c='noida.',
            EYI_Address2__c='Noida',
            EYI_Address3__c='Sector 3',
            EYI_E_Invoicing_Applicable__c= true,
            EYI_Is_MSME__c=true,
            EYI_MSME_Number__c='Test MSME',
            EYI_Country_Code_for_Secondary_Mobile__c='India',
            EYI_Country_Code_REC_Primary_Mobile__c='India',
            EYI_Country_Code_for_REC_Owner_Mobile__c='India',
            EYI_REC_Owner_Telephone_Number__c='98765432345',
            EYI_Primary_Telephone_Number__c='9876543362',
            EYI_Secondary_Telephone_Number__c='9876543362',
            EYI_REC_Correspondence_Last_Name__c='test',
            EYI_Correspondence_City__c=city.id,
            EYI_Correspondence_Country__c='India',
            EYI_Correspondence_State__c='Delhi',
            EYI_Correspondence_Address_1__c='noida.',
            EYI_Correspondence_Address_2__c='Noida',
            EYI_Correspondence_Address_3__c='Sector 3',
            EYI_Correspondence_Pincode_Office__c='987722443',
            EYI_REC_Correspondence_Contact_Name__c='9887765434567',
            EYI_CP_Contact_1_Mobile_Number__c='987556789966',
            EYI_First_Name_of_Contact_Person__c='test cont',
            EYI_Last_Name_of_Contact_Person__c='contact',
            EYI_CP_E_Mail_Address__c='abhishek@mail.com',
            EYI_Title__c='Mr.',
            EYI_Correspondence_Title__c='Mr.',
            EYI_RERA_Certificate_No__c='9hgt7899ijnd'
        );
        insert rec;
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Final_Approval_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id,
            EYI_REC_Account__c = rec.Id
            //Sourcing_TL_User__c = sourcingTL.Id,
           // Email_User__c = sourcingManager.Id,
            //Sourcing_Head_User__c = sourcingHead.Id
        );
        insert brokerage;
        EYI_Brokerage__c brokerage2 = new EYI_Brokerage__c(
            EYI_Final_Approval_Status__c = 'Pending',
            //EYI_Opportunity__c = opp.Id,
            EYI_REC_Account__c = rec.Id
            //Sourcing_TL_User__c = sourcingTL.Id,
           // Email_User__c = sourcingManager.Id,
            //Sourcing_Head_User__c = sourcingHead.Id
        );
        insert brokerage2;

        EYI_Bank_Details__c bnkDet = new EYI_Bank_Details__c(
            EYI_Account_Holder_Name__c='TEST VENDOR SYNC',
            EYI_Bank_Country__c='India',
            EYI_IFSC_Code__c='ICIC0000424',
            EYI_Bank_Account_Number__c='P00000000101',
            EYI_Name_of_Bank_Account__c='Pune State',
            EYI_REC_Account__c=rec.id            
        );
        insert bnkDet;

        // Create a ContentVersion and link it to the record (e.g., Opportunity, Account, etc.)
        Blob fileBody = Blob.valueOf('Test PDF content');
        ContentVersion cv = new ContentVersion(
            Title = 'REC_Merged_PDF.pdf',
            PathOnClient = 'REC_Merged_PDF.pdf',
            VersionData = fileBody
        );
        insert cv;

        // Get ContentDocumentId from ContentVersion
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // Link ContentDocument to your record (replace rec.id with the correct record Id)
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = brokerage.Id,
            ShareType = 'V'
        );
        insert cdl;

        Test.startTest();
        EYI_CreateInvoiceResource.lwcMessage result = EYI_CreateInvoiceResource.validateInvoiceSync(brokerage.Id);
        EYI_CreateInvoiceResource.lwcMessage result2 = EYI_CreateInvoiceResource.validateInvoiceSync(brokerage2.Id);
        EYI_CreateInvoiceResource.lwcMessage result1 = EYI_CreateInvoiceResource.buildRequestBodyFromAccount(brokerage.Id);
        Test.stopTest();

       // System.assertEquals('s', result.type, 'Expected type to be success');
        //System.assertEquals('', result.message, 'Expected no error message');
    }

    /*static testMethod void test_validateInvoiceSync_missingFields() {
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Invoice_Date__c = null, // Intentionally null
            EYI_Invoice_Amount__c = null
        );
        insert brokerage;

        Test.startTest();
        EYI_CreateInvoiceResource.lwcMessage result = EYI_CreateInvoiceResource.validateInvoiceSync(brokerage.Id);
        Test.stopTest();

        System.assertEquals('e', result.type);
        System.assert(result.message.contains('EYI_Invoice_Date__c'), 'Missing invoice date error expected');
    }*/

   /* static testMethod void test_buildRequestBodyFromAccount_success() {
        // Setup mock
        Test.setMock(HttpCalloutMock.class, new MockSAPCallout());

        // Setup mapping data
        insert new SAP_SF_Field_Map__c(
            Name = 'PaymentTermMap',
            SF_Field_Name__c = 'EYI_Payment_Terms__c',
            SF_Value__c = 'PT01',
            SAP_Value__c = 'ZPT'
        );

        // Create required data
        Account recAcc = new Account(Name = 'Test REC', EYI_REC_Vendor_Code__c = 'V123', EYI_Payment_Terms__c = 'PT01');
        insert recAcc;

        EYI_Inventory__c inventory = new EYI_Inventory__c(Name = 'INV123', EYI_Inventory_Number__c = 'MAT001');
        insert inventory;

        EYI_Project_Enquired__c projEnq = new EYI_Project_Enquired__c(Name = 'ProjEnq', EYI_SAP_Company_Code__c = 'CC01');
        insert projEnq;

        EYI_Project_Tower_Enquired__c tower = new EYI_Project_Tower_Enquired__c(Name = 'Tower', EYI_SAP_Plant_ID__c = 'P01');
        insert tower;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            EYI_Sales_Order_Number__c = 'SO123',
            EYI_Project_Enquired__c = projEnq.Id,
            EYI_Project_Tower_Enquired__c = tower.Id,
            EYI_Inventory__c = inventory.Id
        );
        insert opp;

        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_REC_Account__c = recAcc.Id,
            EYI_Invoice_Date__c = Date.today(),
            EYI_Opportunity__c = opp.Id,
            EYI_Invoice_Amount__c = 5000.00,
            Invoice_Number__c = 'INV001',
            EYI_SAP_PO_Number__c = 'PO123'
        );
        insert brokerage;

        // Add ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'REC_Merged_PDF.pdf',
            PathOnClient = 'REC_Merged_PDF.pdf',
            VersionData = Blob.valueOf('PDF content')
        );
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = brokerage.Id,
            ShareType = 'V'
        );
        insert cdl;

        Test.startTest();
        EYI_CreateInvoiceResource.lwcMessage res = EYI_CreateInvoiceResource.buildRequestBodyFromAccount(brokerage.Id);
        Test.stopTest();

        System.assertEquals('S', res.type);
        System.assert(res.message.contains('Purchase Order'), 'Expected success message');
    }*/
}