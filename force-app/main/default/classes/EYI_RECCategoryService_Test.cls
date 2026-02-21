@isTest
public class EYI_RECCategoryService_Test {
    class DummyHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success":true}');
            return res;
        }
    }
    public static String testData(){
        
        
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
            EYI_Pincode_Office__c='187722442',
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
            EYI_Correspondence_Pincode_Office__c='927122443',
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
        
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Distribution_Channel__c = '10',
            EYI_Project_Status__c = 'Sustenance',
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
        
        
        
        Opportunity opp = new Opportunity(
            //SyncedQuoteId = quote.id,
            EYI_Inventory__c= invtry.id,
            //EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
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
            EYI_Walk_in_Source__c = 'Presales'
        );
        insert opp;
        
        
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
        
        EYI_Project_REC_Mapping__c projectRecMapping = new EYI_Project_REC_Mapping__c(
        	EYI_REC_Account__c = rec.id,
            EYI_Project__c = projctobj.id,
            EYI_Sourcing_Manager__c = UserInfo.getUserId()
        );
        insert projectRecMapping;
        
        return rec.id;
        
    }
    
    @isTest
    public static void updateRecCategoriesTest(){
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        String recID = testData();
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c WHERE Id = :recId];
		EYI_Project__c project = [SELECT Id FROM EYI_Project__c WHERE Name =: 'Balewadi 23'];
        EYI_Joint_Business_Plan__c jointBusinessPlan = new EYI_Joint_Business_Plan__c(
        	EYI_Activity_type__c = 'SMS',
            EYI_Activity_Support_Required__c = 'Yes',
            EYI_JBP_Name__c = 'EYI_JBP_Name__c',
            EYI_Project__c = project.id,
            EYI_Start_Date__c = System.today(),
            EYI_End_Date__c  = System.today() + 10,
            EYI_Cost__c = 1000,
            REC_Account__c = rec.id
        );
        insert jointBusinessPlan;
        
        Task task = new Task(
        	Subject = 'Follow Up',
            WhatId = rec.Id,
            RecordTypeId =System.Label.EYI_Presales_Record_Type_Id,
            Priority = 'Normal',
            Status = 'Open',
            //Type = 'Presales Task',
            EYI_Next_Action_Date__c =  System.today(),
            EYI_Next_Action_Time__c =  '10:30 AM - 11:30 AM',
            ReminderDateTime = System.now(),
            OwnerId = UserInfo.getUserId(),
            EYI_Next_Action_Date_Time__c = DateTime.newInstance(System.today().addDays(1), Time.newInstance(10, 30, 0, 0))
        );
        insert task;
        
        
        Set<Id> recIds = new Set<Id>();
        recIds.add(recId);
        Test.startTest();
        EYI_RECCategoryService.updateRecCategories(recIds);
        Test.stopTest();
    }
    
    @isTest
    public static void updateRecCategoriesTest1(){
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        String recID = testData();
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c WHERE Id = :recId];
		EYI_Project__c project = [SELECT Id FROM EYI_Project__c WHERE Name =: 'Balewadi 23'];
		EYI_City__c city = [Select Id from EYI_City__c Where Name =: 'Pune' And EYI_Pincode__c =: '410405'];        
        EYI_Panchshil_Master__c mster = [Select Id from EYI_Panchshil_Master__c Where EYI_City__c =: 'Pune' And EYI_Pincode__c =: '410405'];
        
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
            EYI_Address_3__c='test',
            EYI_Customer_Address_Type__c = 'Pune',
			EYI_State__c = 'Maharashtra'
            //EYI_REC_Account__c = rec.id
            
        );
        insert CIF;
        
        Set<Id> recIds = new Set<Id>();
        recIds.add(recId);
        Test.startTest();
        EYI_RECCategoryService.updateRecCategories(recIds);
        Test.stopTest();
    }
    
    @isTest
    public static void updateRecCategoriesTest2(){
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        String recID = testData();
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c WHERE Id = :recId];
        Set<Id> recIds = new Set<Id>();
        recIds.add(recId);
        Test.startTest();
        EYI_RECCategoryService.updateRecCategories(recIds);
        Test.stopTest();
    }
    
    
    @isTest
    public static void updateRecProjectCategoriesTest(){
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        String recID = testData();
        Set<Id> recIds = new Set<Id>();
        recIds.add(recId);
        Test.startTest();
        EYI_RECCategoryService.updateRecProjectCategories(recIds);
        Test.stopTest();
    }
    
}