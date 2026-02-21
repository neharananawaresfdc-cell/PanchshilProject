@isTest
public class EYI_CaseCancellationSyncCntlTest {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account19000');
        insert acc;
        System.debug('account :: '+acc);
        

        // Get Profile for Users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        // Create Users for lookups
        User sourcingMgr = new User(
            FirstName='Sourcing', LastName='Manager', Email='srcmgr@example.com',
            Username='srcmgr' + System.currentTimeMillis() + '@example.com', Alias='srcmgr',
            TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId=p.Id
        );
        User relMgr = new User(
            FirstName='Rel', LastName='Manager', Email='relmgr@example.com',
            Username='relmgr' + System.currentTimeMillis() + '@example.com', Alias='relmgr',
            TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId=p.Id
        );
        User closeMgr = new User(
            FirstName='Close', LastName='Manager', Email='clsmgr@example.com',
            Username='clsmgr' + System.currentTimeMillis() + '@example.com', Alias='clsmgr',
            TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId=p.Id
        );
        User retainedByUser = new User(
            FirstName='Retain', LastName='User', Email='retain@example.com',
            Username='retain' + System.currentTimeMillis() + '@example.com', Alias='retu',
            TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId=p.Id
        );
        insert new List<User>{sourcingMgr, relMgr, closeMgr, retainedByUser};
            EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
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

        EYI_Tower__c newTower = new EYI_Tower__c(
            EYI_project_Name__c = projctobj.Id,
            Name = 'Tower Name',
            EYI_RERA_Number__c = 'huiqhdugfy7uy',
            EYI_Stage__c ='Launch'
        );
        insert newTower;
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
            //EYI_City__c =city.id,
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
           // EYI_Correspondence_City__c=city.id,
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
		EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Tower__c=newTower.id,
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
         Quote qut = new Quote(
            Name = 'test quote data',
           // EYI_Inventory__c = inventory.Id,
            EYI_Floor_Rate_Discount_L__c = 2300,
            EYI_Floor_Rate_Discount_PSF__c = 4000,
            EYI_Base_Rate_Discount_PSF__c = 9000,
            EYI_Base_Rate_Discount_L__c = 200,
            EYI_Quoatation_Grand_Total__c = 6000000,
             EYI_Agreement_Value__c =12000000
            //OpportunityId = testOpportunity.Id
        );
        insert qut;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name='Test Opp', StageName='Registration Completed', CloseDate=Date.today().addDays(10), AccountId=acc.Id,
            EYI_SAP_Customer_Number__c='SAP123', EYI_Walk_in_Source__c='Direct Client', EYI_SalesOrder_Number__c='SO123',
            EYI_Sourcing_Manager__c = sourcingMgr.Id,
            //EYI_Relationship_Manager__c = relMgr.Id,
            EYI_Primary_Closing_Manager__c = closeMgr.Id,
            EYI_Total_Brokerage_Amount_Paid__c=100,
            EYI_Ownership_Status__c = 'Accepted',
            EYI_Last_Name__c='test'
            //EYI_Registration_Status__c = 'Registration Completed'
        );
        insert opp;
         Opportunity opp1 = new Opportunity(
            Name='Test New Opp', StageName='Registration Completed', 
            CloseDate=Date.today().addDays(10), AccountId=acc.Id,
            EYI_Ownership_Status__c = 'Accepted',
             EYI_Last_Name__c='test Con',
             EYI_Sourcing_Manager__c = sourcingMgr.Id,
           // EYI_Relationship_Manager__c = relMgr.Id,
            EYI_Primary_Closing_Manager__c = closeMgr.Id,
             EYI_Registration_Status__c = 'Registration Completed',
             EYI_REC__c = rec.Id,
             EYI_SAP_Customer_Number__c = '1000002000',
             EYI_Walk_in_Source__c='Direct Client',
             SyncedQuoteId =qut.Id,
             EYI_Inventory__c = invtry.Id,
             EYI_Project_Tower_Enquired__c= newTower.Id
        );
        insert opp1;
        
        Opportunity opp2 = new Opportunity(
            Name='TestRec', StageName='Registration Completed', 
            CloseDate=Date.today().addDays(10), AccountId=acc.Id,
            EYI_Ownership_Status__c = 'Accepted',
             EYI_Last_Name__c='test Con',
             EYI_Sourcing_Manager__c = sourcingMgr.Id,
           // EYI_Relationship_Manager__c = relMgr.Id,
            EYI_Primary_Closing_Manager__c = closeMgr.Id,
             //EYI_Registration_Status__c = 'Registration Completed',
             EYI_REC__c = rec.Id,
            EYI_Project_Tower_Enquired__c= newTower.Id,
             EYI_Inventory__c = invtry.Id,
            EYI_SAP_Customer_Number__c='0020000373',
            EYI_Walk_in_Source__c='Direct Client',
            SyncedQuoteId =qut.Id
        );
        insert opp2;

        

       /* EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Tower__c=newTower.Id,
            EYI_Project__c=projctobj.Id,
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
        insert invtry;*/

        // Create Quote linked to Opportunity
        Quote q = new Quote(
            Name='Test Quote', OpportunityId=opp.Id,
            EYI_Agreement_Value__c=500000, Stamp_Duty__c=10000
        );
        insert q;

        // Update Opportunity with Quote Id
        opp.SyncedQuoteId = q.Id;
        update opp;
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    }

    @isTest
    static void testCancellationMasterSync_happyPath() {
        System.debug('testCancellationMasterSync_happyPath 129');
        // Set HTTP mock BEFORE callout
       
	System.debug('testCancellationMasterSync_happyPath 132');
        // Fetch a Case linked to the Opportunity with all required fields
        Opportunity opp2 = [SELECT Id FROM Opportunity where Name ='TestRec' LIMIT 1];
        //Opportunity opp1 = [SELECT Id FROM Opportunity where Name ='Test New Opp' LIMIT 1];

        EYI_REC__c recInsert = new EYI_REC__c(
            Name='Test REC', EYI_REC_Firm_Name__c='Firm', EYI_Mobile__c='9876543210',
            EYI_Email__c='test1@example.com', EYI_Last_Name__c='TestLast'
        );
        insert recInsert;

        //User retainedByUser = [SELECT Id FROM User WHERE Email = 'retain@example.com' LIMIT 1];
        Contact cont = new Contact(LastName = 'TestContact', Email = 'utest@example.com');
        insert cont;
		Case caseObj1 = new Case(
            //EYI_Cancellation_Type__c = 'Voluntary',
            EYI_Opportunity__c = opp2.Id,
            //EYI_Case_Approval_Status__c = 'Submitted',
            EYI_Closing_Head__c	= UserInfo.getUserId(),
            EYI_CRM_Head__c	 = UserInfo.getUserId(),
            S_C_User__c = UserInfo.getUserId(),
            //EYI_Sub_Type__c = 'Pre Onboarding',
            RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cancellation').getRecordTypeId()
            );
        insert caseObj1;
        Case caseObj = new Case(
            RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cancellation').getRecordTypeId(),
            EYI_Opportunity__c = opp2.Id,
            EYI_Cancellation_Type__c = 'Voluntary',
            EYI_Sub_Type__c = 'Pre Onboarding',
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
            EYI_Retained_by_User__c = UserInfo.getUserId(),
            EYI_Case_Approval_Status__c ='Submitted',
            ContactId = cont.Id,
            S_C_User__c = UserInfo.getUserId()
        );
        insert caseObj;

      /*  ProcessInstance pi = new ProcessInstance(
            Status = 'Pending', TargetObjectId = c.Id
        );
        insert pi;

        ProcessInstanceStep step = new ProcessInstanceStep(
            ProcessInstanceId = pi.Id, StepStatus = 'Started', ActorId = UserInfo.getUserId()
        );
        insert step;*/
        // Step 2: Submit the Case for approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting for approval');
        req.setObjectId(caseObj.Id);
        req.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result = Approval.process(req);

        // Step 3: Approve the first step (simulate approval)
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :caseObj.Id
        ];

        for (ProcessInstanceWorkitem item : workItems) {
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkitemId(item.Id);
            approvalReq.setComments('Approved by test');
            approvalReq.setAction('Approve');
            approvalReq.setNextApproverIds(new Id[] {UserInfo.getUserId()}); // Optional
            Approval.ProcessResult approvalResult = Approval.process(approvalReq);
        }

        Test.startTest();
        EYI_CaseCancellationMasterSyncController.lwcMessage msg = EYI_CaseCancellationMasterSyncController.CancellationMasterSync(caseObj1.Id);
        EYI_CaseCancellationMasterSyncController.lwcMessage msg1 = EYI_CaseCancellationMasterSyncController.CancellationMasterSync(caseObj.Id);
        Test.stopTest();
    }

    /*@isTest
    static void testCancellationMasterSync_missingRequiredFields() {
        Test.setMock(HttpCalloutMock.class, new DummySAPGatewayMock());

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        // Insert a Case with minimal fields to trigger validation errors
        Case c = new Case(EYI_Opportunity__c = opp.Id);
        insert c;

        Test.startTest();
        EYI_CaseCancellationMasterSyncController.lwcMessage msg =
            EYI_CaseCancellationMasterSyncController.CancellationMasterSync(c.Id);
        Test.stopTest();

        //System.assertEquals('e', msg.type, 'Should return error type for missing required fields');
        //System.assert(msg.message.contains('EYI_Cancellation_Type__c'), 'Should mention missing EYI_Cancellation_Type__c');
    }

    @isTest
    static void testCancellationMasterSync_nullId() {
        Test.setMock(HttpCalloutMock.class, new DummySAPGatewayMock());

        Test.startTest();
        EYI_CaseCancellationMasterSyncController.lwcMessage msg =
            EYI_CaseCancellationMasterSyncController.CancellationMasterSync(null);
        Test.stopTest();
    }*/

    // Mock HTTP callout to simulate SAP gateway response
   public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        System.debug('MockHttpResponseGenerator invoked');
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{' +
            '"n0:ZSD_CREATE_SO_FROM_SFResponse": {' +
                '"EX_RETURN": {' +
                    '"TYPE": "S", ' +
                    '"MESSAGE": "Success"' +
                '}' +
            '}' +
        '}');
        System.debug('res : '+res);
        return res;
    }
}
 @isTest
    static void testCancellationSyncDataWrapperInitialization() {
        EYI_CaseCancellationMasterSyncController.CancellationSyncDataWrapper wrapper = new EYI_CaseCancellationMasterSyncController.CancellationSyncDataWrapper();

      EYI_CaseCancellationMasterSyncController.lwcMessage lwcmsg = new EYI_CaseCancellationMasterSyncController.lwcMessage();


    }
}