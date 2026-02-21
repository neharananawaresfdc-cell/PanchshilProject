@IsTest
public class EYI_GetQuotaionValue_Test {
    @isTest(SeeAlldata= False)
    static void testUpdateTotalCountOnLead() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser3@example.com',
            Username = 'testpanchshil1234@mail.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        
        insert testUser;
        // User userLogwith = [Select id from User where email='rishikesh.kale@in.ey.com'] ;
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
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
            EYI_Email__c='nilesh@mail.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert Acc;
        
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
            //Name='Pune',
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
        );
        insert CIF;
        
        
        Opportunity opp = new Opportunity(
            // EYI_Inventory__c= invtry.id,
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
            EYI_Payment_Terms__c='15 Days Credit From the Date of Invoice',
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
        	EYI_AutomationBypassDatetime__c = System.now()
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
            isDraft__c=true
        );
        insert book;
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Booking__c=book.id,
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
            EYI_SAP_Material_Code__c='SAP-T-0109',
            EYI_Saleable_Area__c=20.3,
            EYI_RERA_Carpet_Area__c= 22.3
        );
        insert invtry;
        
        EYI_Car_Park_Master__c carprk= new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c= 'Saleable Service',
            EYI_Material_Group__c='Parking' ,
            EYI_Base_UOM__c='Each' ,
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            EYI_Inventory__c =invtry.id,
            EYI_SAP_Material_Description__c='Description Description' ,
            EYI_Status__c='Vacant' ,
            EYI_Parking_Number__c='P-502' ,
            EYI_Distruibution_Channel__c='Residential Sales' ,
            EYI_External_Material_Group__c='10' ,
            EYI_Lab_Office__c='20' ,
            EYI_Built_up_Area__c=100 ,
            EYI_Floor_Number__c='003' ,
            EYI_SAP_Affordable_Type__c='Affordable Housing' ,
            Configuration__c='Parking' ,
            EYI_SAP_Profit_Center__c='R150R1R15I' ,
            EYI_X_Plant_Mat_Status__c='Blocked for procment/whse' ,
            EYI_Account_Assignment_Group__c='Vehicle Parking' ,
            EYI_Item_Category__c='Parking Item Cat Grp' ,
            EYI_TCS_Tax_Classification__c='TCS Applicable' ,
            EYI_GST_Tax_Classification__c='Taxable under GST' ,
            EYI_Category__c = 'Earmarked'
        );
        insert carprk;
        
        EYI_Car_Park_Master__c carprk1 = new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c= 'Saleable Service',
            EYI_Material_Group__c='Parking' ,
            EYI_Base_UOM__c='Each' ,
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            EYI_Inventory__c =invtry.id,
            EYI_SAP_Material_Description__c='Description Description' ,
            EYI_Status__c='Vacant' ,
            EYI_Parking_Number__c='P-501' ,
            EYI_Distruibution_Channel__c='Residential Sales' ,
            EYI_External_Material_Group__c='10' ,
            EYI_Lab_Office__c='20' ,
            EYI_Built_up_Area__c=1000 ,
            EYI_Floor_Number__c='004' ,
            EYI_SAP_Affordable_Type__c='Affordable Housing' ,
            Configuration__c='Parking' ,
            EYI_SAP_Profit_Center__c='R150R1R15I' ,
            EYI_X_Plant_Mat_Status__c='Blocked for procment/whse' ,
            EYI_Account_Assignment_Group__c='Vehicle Parking' ,
            EYI_Item_Category__c='Parking Item Cat Grp' ,
            EYI_TCS_Tax_Classification__c='TCS Applicable' ,
            EYI_GST_Tax_Classification__c='Taxable under GST'
            //EYI_Category__c = 'Earmarked'
        );
        insert carprk1;
        
        
        EYI_Global_Charges__c gcharge = new EYI_Global_Charges__c(
            Name = 'Test',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'test material'
        );
        insert gcharge;    
        
        EYI_Rate_List__c rate = new EYI_Rate_List__c(
            //EYI_Condition_Type__c ='Percentage',
            EYI_Pricing_Percentage__c = 12,
            EYI_Amount__c= 20,
            EYI_Condition_Type__c='Base Price',
            EYI_Pricing_Quantity__c=10,
            EYI_Inventory__c= invtry.id,
            EYI_Global_Charges__c = gcharge.Id,            
            EYI_Rate__c=12,
            EYI_Calculation_Mode__c = 'RERA Carpet Area'
        );
        insert rate;
        
        EYI_Rate_List__c rate1 = new EYI_Rate_List__c(
            //EYI_Condition_Type__c ='Percentage',
            EYI_Pricing_Percentage__c = 11,
            EYI_Amount__c= 21,
            EYI_Condition_Type__c='Base Price',
            EYI_Pricing_Quantity__c=11,
            EYI_Inventory__c= invtry.id,
            EYI_Global_Charges__c = gcharge.Id,            
            EYI_Rate__c=10,
            EYI_Calculation_Type__c = 'Quantity'
        );
        insert rate1;
        
        EYI_Rate_List__c rate2 = new EYI_Rate_List__c(
            //EYI_Condition_Type__c ='Percentage',
            EYI_Pricing_Percentage__c = 11,
            EYI_Amount__c= 21,
            EYI_Condition_Type__c='Floor Rise',
            EYI_Pricing_Quantity__c=11,
            EYI_Inventory__c= invtry.id,
            EYI_Global_Charges__c = gcharge.Id,            
            EYI_Rate__c=10,
            EYI_Calculation_Type__c = 'Quantity',
            EYI_Calculation_Mode__c = 'RERA Carpet Area'            
        );
        insert rate2;
        
        EYI_Rate_List__c rate3 = new EYI_Rate_List__c(
            //EYI_Condition_Type__c ='Percentage',
            EYI_Pricing_Percentage__c = 11,
            EYI_Amount__c= 21,
            EYI_Condition_Type__c='Floor Rise',
            EYI_Pricing_Quantity__c=11,
            EYI_Inventory__c= invtry.id,
            EYI_Global_Charges__c = gcharge.Id,            
            EYI_Rate__c=10,
            EYI_Calculation_Type__c = 'Quantity',
            EYI_Calculation_Mode__c = 'Saleable Area'            
        );
        insert rate3;
        
        EYI_Rate_List__c rate4 = new EYI_Rate_List__c(
            //EYI_Condition_Type__c ='Percentage',
            EYI_Pricing_Percentage__c = 11,
            EYI_Amount__c= 21,
            EYI_Condition_Type__c='Floor Rise',
            EYI_Pricing_Quantity__c=11,
            EYI_Inventory__c= invtry.id,
            EYI_Global_Charges__c = gcharge.Id,            
            EYI_Rate__c=10,
            EYI_Calculation_Type__c = 'Fixed Amount',
            EYI_Calculation_Mode__c = 'RERA Carpet Area',
EYI_Pricing_Amount__c = 20            
        );
        insert rate4;
        
        Project_Charges__c pcobj = new Project_Charges__c(
            Name = 'Registration Charges',
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Charge_Bucket__c = 'Stamp Duty and Registration',
            EYI_Active__c = true,
            EYI_Project__c =projctobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_Rate__c = 5
        );
        insert pcobj;
        Project_Charges__c pcobj1 = new Project_Charges__c(
            Name = 'Basic',
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Charge_Bucket__c = 'Agreement Value',
            EYI_Active__c = true,
            EYI_Project__c =projctobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_Rate__c = 5,
            EYI_GST_Applicable_on_this_charge__c = true,
            EYI_GST_Percentage__c = 'GST-12'
        );
        insert pcobj1;
        
        EYI_Applicants__c oppAplicant = new EYI_Applicants__c(
            Name='Nilesh Arvind Ghodke',
            EYI_Title__c='Mr.',
            EYI_Email__c='neha@mail.com	',
            EYI_Last_Name__c='Ghodke',
            EYI_Mobile_Number__c='09765117411',
            EYI_Pancard_Number__c='DLWPG4197L',
            EYI_Applicant_Type__c='Primary Applicant',
            Opportunity__c=opp.id,
			EYI_Gender__c = 'F'
        );
        
        EYI_Applicants__c oppAplicant1 = new EYI_Applicants__c(
            Name='Nilesh Arvind Ghodke1',
            EYI_Title__c='Mr.',
            EYI_Email__c='neha1.rananaware@in.ey.com	',
            EYI_Last_Name__c='Ghodke1',
            EYI_Mobile_Number__c='01765117411',
            EYI_Pancard_Number__c='DLWPG4117L',
            EYI_Applicant_Type__c='Primary Applicant',
            Opportunity__c=opp.id,
            EYI_Gender__c = 'M'
        );
        
        opp.EYI_AutomationBypassDatetime__c = System.now();
        update opp;
        insert oppAplicant;
		insert oppAplicant1;
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Commercial' AND SObjectType = 'EYI_Project__c' LIMIT 1].Id;
        EYI_Project__c projectrecord = new EYI_Project__c(
            Name = 'Yoopune',
            EYI_Project_Code__c = 'P-0001',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_Stamp_Duty__c= 10,
            RecordTypeId = recordTypeId // Assign the RecordTypeId based on input 'projectType'
            
        );
        insert projectrecord;
        
        Lead leads = new Lead(
            FirstName = 'Test',
            LastName =  'test lead', 
            Status='',
            LeadSource = 'Direct Client',
            EYI_Lead_Sub_Source__c = 'Direct walk-in at site',
            EYI_Designation__c='Test',
            Company='Panchshil',
            Description='test',
            EYI_Segment__c = 'Residential',
            EYI_LeadType__c = 'Apartment',
            EYI_Property__c = 'Yoopune',
            //EYI_Property__c = '99Acres',
            //EYI_Budget__c='NA',
            //EYI_Unit_Configuration__c='1.5BHK',
            EYI_Client_Communication_Preference__c='SMS;WhatsApp',
            EYI_Nature_of_Lead__c='Outright',
            EYI_Project_Enquired__c=projectrecord.id,
            Email = 'qwerty786@example.com', 
            Phone = '98766478232'
        );
        insert leads;
        
        EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c(
            EYI_Parent_Record__c = leads.Id,
            EYI_Lead_Source__c = 'Direct Client',
            EYI_Segment__c = 'Residential',
            Name='Test Campaign',
            EYI_Property__c = 'Trump Towers',
            EYI_Secondary_Owner__c= UserInfo.getUserId(),
            // EYI_Closing_Manager__c= ,
            // OwnerId=testUser.id,
            DNC__c= true,
            EYI_Email__c ='viksit.rana@in.ey.com'
        );
        insert enq;
        
        /* EYI_Lead_Enquiry__c enqs = new EYI_Lead_Enquiry__c(
EYI_Parent_Record__c = leads.Id,
EYI_Lead_Source__c = 'Direct Client',
EYI_Segment__c = 'Residential',
Name='Test Campaign',
EYI_Property__c = 'Trump Towers',
EYI_Secondary_Owner__c= UserInfo.getUserId(),
EYI_Closing_Manager__c= UserInfo.getUserId(),
OwnerId=testUser.id,
EYI_Email__c ='viksit.rana@in.ey.com'
);
insert enqs;*/
        
        
        EYI_Bank_GL_Codes__c bnk = new EYI_Bank_GL_Codes__c(
            EYI_Bank_Account_Type__c ='COLLECTION Acc',
            EYI_Project__c= projctobj.id
            // EYI_Tower__c =towerobj.id
        );
        insert bnk;
        quote qut = new quote(
            Name='test quote data',
            EYI_Inventory__c =invtry.id,
            EYI_Floor_Rate_Discount_L__c=2300,
            EYI_Floor_Rate_Discount_PSF__c= 4000,
            EYI_Base_Rate_Discount_PSF__c=9000,
            EYI_Base_Rate_Discount_L__c= 200,
            OpportunityId = opp.id
        );
        insert qut;
        
        quote qut1 = new quote(
            Name='test quote data',
            EYI_Inventory__c =invtry.id,
            EYI_Floor_Rate_Discount_L__c=2300,
            //EYI_Floor_Rate_Discount_PSF__c= 4000,
            //EYI_Base_Rate_Discount_PSF__c=9000,
            EYI_Base_Rate_Discount_L__c= 200,
            OpportunityId = opp.id
        );
        insert qut1;
        
        EYI_Global_Charges__c globalCharge1 = new EYI_Global_Charges__c(
        	Name = 'Basic',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'test1EYI_SAP_Material_Name__c'
        );
        insert globalCharge1;
        
        EYI_Global_Charges__c globalCharge2 = new EYI_Global_Charges__c(
        	Name = 'Maintenance Charges',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'test2EYI_SAP_Material_Name__c'
        );
        insert globalCharge2;
        
        EYI_Global_Charges__c globalCharge3 = new EYI_Global_Charges__c(
        	Name = 'Maintenance Deposit',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'test3EYI_SAP_Material_Name__c'
        );
        insert globalCharge3;
        
        Project_Charges__c projectCharge = new Project_Charges__c(
        	Name = 'Test123',
            EYI_Global_Charges__c = globalCharge3.id,                                                                                    
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = false,
            EYI_Charge_Bucket__c = 'Other Charges',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11,
            EYI_Rate__c = 10
        );
        insert projectCharge;
        
        Project_Charges__c projectCharge1 = new Project_Charges__c(
        	Name = 'Registration Charges',
            EYI_Global_Charges__c = globalCharge3.id,                                                                        
            EYI_Charge_Calculated_As__c = 'Percentage of Agreement Value',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = false,
            EYI_Charge_Bucket__c = 'Other Charges',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11,
            EYI_Rate__c = 10,
            EYI_Amount__c = 100
        );
        insert projectCharge1;
        
        Project_Charges__c projectCharge2 = new Project_Charges__c(
        	Name = 'Stamp Duty',
            EYI_Global_Charges__c = globalCharge3.id,                                                            
            EYI_Charge_Calculated_As__c = 'Lumpsum at Project Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = false,
            EYI_Charge_Bucket__c = 'Other Charges',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11,
            EYI_Rate__c = 10,
			EYI_Amount__c = 100
        );
        insert projectCharge2;
        
        
        
        Project_Charges__c projectCharge3 = new Project_Charges__c(
        	Name = 'Maintenance Deposit',
            EYI_Global_Charges__c = globalCharge3.id,                                                
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = true,
            EYI_Charge_Bucket__c = 'Maintenance Charges',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11,
            EYI_Rate__c = 10
        );
        insert projectCharge3;
       
        
        Project_Charges__c projectCharge4 = new Project_Charges__c(
        	Name = 'Maintenance Charges',
            EYI_Global_Charges__c = globalCharge3.id,                                    
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = false,
            EYI_Charge_Bucket__c = 'Maintenance Charges',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11,
            EYI_Rate__c = 10
        );
        insert projectCharge4;
        
        Project_Charges__c projectCharge5 = new Project_Charges__c(
        	Name = 'Legal Charges',
            EYI_Global_Charges__c = globalCharge2.id,                        
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = false,
            EYI_Charge_Bucket__c = 'Maintenance Charges',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11,
            EYI_Rate__c = 10
        );
        insert projectCharge5;
        
        
        
        Project_Charges__c projectCharge6 = new Project_Charges__c(
        	Name = 'Basic',
            EYI_Global_Charges__c = globalCharge1.id,            
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = true,
            EYI_Charge_Bucket__c = 'Stamp Duty and Registration',
            EYI_Registration_charge__c = true,
            EYI_Charge_Percentage__c = 11
        );
        insert projectCharge6;
        
        
        
        Project_Charges__c projectCharge7 = new Project_Charges__c(
        	Name = 'Test123',
            EYI_Global_Charges__c = globalCharge1.id,
            EYI_Charge_Calculated_As__c = 'Rate List at Unit Level',
            EYI_Project__c = projctobj.Id,
			EYI_Active__c = true,
            EYI_Charge_Type__c = 'Other Charges',
			EYI_GST_Percentage__c = 'GST-18',
            EYI_Tower__c = towerobj.id,
            EYI_Apply_This_Charge_to_FA__c = true,
            EYI_GST_Applicable_on_this_charge__c = true,
            EYI_Charge_Bucket__c = 'Stamp Duty and Registration',
            EYI_Registration_charge__c = false,
            EYI_Charge_Percentage__c = 11
        );
        insert projectCharge7;
        
        Offer__c offer1 = new Offer__c(
        	Name = 'Offer1',
            Start_Date__c = System.today(),
            End_Date__c = System.today()
        );
        insert offer1;
        
        
            
        List<Offer__c> offerList = new List<Offer__c>();
        offerList.add(offer1);
        
        Offer__c offer2 = new Offer__c(
        	Name = 'Offer12',
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Project__c = projctobj.id,
            Offer_Active_Status__c = 'Active',
            EYI_Amount__c = 100
        );
        insert offer2;
        
        EYI_Applied_Offers_To_Quotation__c offerQuotation = new EYI_Applied_Offers_To_Quotation__c(
        	EYI_Quote__c = qut1.id,
            EYI_Offer__c = offer2.id
        );
        
        insert offerQuotation;
        
        EYI_Applied_Project_Charge__c appliedProjectCharge = new EYI_Applied_Project_Charge__c(
        	Name = 'Test123',
            EYI_Quote__c = qut1.id
        );
		insert appliedProjectCharge;
        
        Test.startTest();
        
        String mockResponse = '{"respcode":"200", "respdesc":"Success", "status":"Success", "kycdetails": {' +
            '"name":"John Doe", "fname":"Father Name", "dob":"01-01-1990", "gender":"Male", "uid":"1234567890", ' +
            '"address":"Some Address"}}';
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_GetQuotaionValue.fetchCarParks(invtry.id);
        EYI_GetQuotaionValue.fetchCarParks(qut.id);
        EYI_GetQuotaionValue.fetchCarParks(null);
        EYI_GetQuotaionValue.fetchinventoryDetails(invtry.id);
        EYI_GetQuotaionValue.fetchinventoryDetails(qut.id);
        EYI_GetQuotaionValue.fetchinventoryDetails(null);
        EYI_GetQuotaionValue.fetchQuotationValue(invtry.id,opp.Id);
        EYI_GetQuotaionValue.fetchQuotationValue(qut.id,opp.Id);        
        EYI_GetQuotaionValue.fetchQuotationValue(qut1.id,opp.Id);                
        EYI_GetQuotaionValue.fetchQuoteDetails(qut.id);
        EYI_GetQuotaionValue.fetchQuoteDetails(null);        
        EYI_GetQuotaionValue.getBaseRate(invtry.id);
        rate.EYI_Condition_Type__c = 'Floor Rise';
        update rate;
        EYI_GetQuotaionValue.getFloorRise(invtry.id);
        EYI_GetQuotaionValue.fetchQuotationValue(invtry.id,opp.Id);
        rate.EYI_Condition_Type__c = 'Base Price';
        rate.EYI_Calculation_Type__c='Fixed Amount';
        rate.EYI_Pricing_Amount__c=23.34;
        update rate;
        EYI_GetQuotaionValue.fetchQuotationValue(invtry.id,opp.Id);
        EYI_GetQuotaionValue.createRecord('Test123', qut1.id, projectCharge.id, 100);
        EYI_GetQuotaionValue.addOfferToQuote(qut1.id, offerList);
        EYI_GetQuotaionValue.addOfferToQuote(null, offerList);
        EYI_GetQuotaionValue.fetchOffers(qut1.id);
        EYI_GetQuotaionValue.offerSection(qut1.id);
        
        
        EYI_GetQuotaionValue.getGSTSpilt('CGST-18');
        EYI_GetQuotaionValue.Subsection sub = new EYI_GetQuotaionValue.Subsection();
        sub.setSubsection('Tax', 100);
		EYI_GetQuotaionValue.section sect = new EYI_GetQuotaionValue.section();
        List<EYI_GetQuotaionValue.Subsection> subList = new List<EYI_GetQuotaionValue.Subsection>{sub};
        sect.section('Main Tax Section', 200, subList);
        
        EYI_GetQuotaionValue.quotationValWrapper wrapper = new EYI_GetQuotaionValue.quotationValWrapper();
        wrapper.setSection(new List<EYI_GetQuotaionValue.section>{sect});
        EYI_GetQuotaionValue.fetchQuotationDiscountValue(qut1.id, 10, 1000, 5, 500, opp.id);
        projectCharge1.EYI_GST_Applicable_on_this_charge__c = true;
        projectCharge2.EYI_GST_Applicable_on_this_charge__c = true;
        update projectCharge1;
        update projectCharge2;
        EYI_GetQuotaionValue.fetchQuotationDiscountValue(qut1.id, 10, 1000, 5, 500, opp.id);
        EYI_GetQuotaionValue.fetchQuotationDiscountValue(qut1.id, null, 1000, null, 500, null);
        EYI_GetQuotaionValue.fetchQuotationDiscountValue(invtry.id, null, 1000, null, 500, null);
        
        
        EYI_GetQuotaionValue.Subsection sub1 = new EYI_GetQuotaionValue.Subsection();
        sub1.setSubsection('SGST', 90);
		EYI_GetQuotaionValue.Subsection sub2 = new EYI_GetQuotaionValue.Subsection();
        sub2.setSubsection('CGST', 90);
        EYI_GetQuotaionValue.Subsection sub3 = new EYI_GetQuotaionValue.Subsection();
        sub3.setSubsection('Registration Charges', 500);
        EYI_GetQuotaionValue.Subsection sub4 = new EYI_GetQuotaionValue.Subsection();
        sub4.setSubsection('Legal Charges', 200);
		EYI_GetQuotaionValue.Subsection sub5 = new EYI_GetQuotaionValue.Subsection();
        sub5.setSubsection('Stamp Duty', 250);
        EYI_GetQuotaionValue.Subsection sub6 = new EYI_GetQuotaionValue.Subsection();
        sub6.setSubsection('Maintenance Charges', 300);
        EYI_GetQuotaionValue.Subsection sub7 = new EYI_GetQuotaionValue.Subsection();
        sub7.setSubsection('Maintenance Deposit', 600);
        
        EYI_GetQuotaionValue.section otherSection = new EYI_GetQuotaionValue.section();
        otherSection.section('Other', 0, new List<EYI_GetQuotaionValue.Subsection>{ sub1, sub2, sub3, sub4, sub5, sub6, sub7 });

        EYI_GetQuotaionValue.section baseSection = new EYI_GetQuotaionValue.section();
        baseSection.section('Base', 1000, null);

        EYI_GetQuotaionValue.section agreementSection = new EYI_GetQuotaionValue.section();
        agreementSection.section('Agreement Value', 2000, null);

        EYI_GetQuotaionValue.section totalSection = new EYI_GetQuotaionValue.section();
        totalSection.section('Grand Total', 4000, null);
        
        EYI_GetQuotaionValue.section infrastructureSection = new EYI_GetQuotaionValue.section();
        infrastructureSection.section('Infrastructure Charges', 5000, null);
        
        EYI_GetQuotaionValue.Subsection baseDiscount = new EYI_GetQuotaionValue.Subsection();
        baseDiscount.setSubsection('Base Price Discount', 100);

        EYI_GetQuotaionValue.Subsection floorDiscount = new EYI_GetQuotaionValue.Subsection();
        floorDiscount.setSubsection('Floor Price Discount', 50);

        EYI_GetQuotaionValue.section discountSection = new EYI_GetQuotaionValue.section();
        discountSection.section('Discount Base', 0, new List<EYI_GetQuotaionValue.Subsection>{ baseDiscount, floorDiscount });

        List<EYI_GetQuotaionValue.section> sectionList = new List<EYI_GetQuotaionValue.section>{
            baseSection,
            agreementSection,
            totalSection,
			infrastructureSection,                
            otherSection,
            discountSection
        };

        EYI_GetQuotaionValue.quotationValWrapper wrapper1 = new EYI_GetQuotaionValue.quotationValWrapper();
        wrapper1.setSection(sectionList);

        String wrapperJson = JSON.serialize(wrapper1.section);
        EYI_GetQuotaionValue.createQuoatationRecord(invtry.Id, wrapperJson, null, null, opp.Id);
       // EYI_GetQuotaionValue.createQuoatationRecord(qut1.Id, wrapperJson, null, opp.Id, null);

        
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void testgetUserRole(){
        
        //UserRole role = new UserRole(Name = 'Sales Manager', DeveloperName = 'Sales_Manager');
        UserRole role1 = [SELECT Id FROM UserRole WHERE DeveloperName =: 'Sales_Manager' LIMIT 1];
        //insert role;
        
        User u = new User(
            FirstName = 'Test',
            LastName = 'SalesMgr',
            Email = 'test.salesmgr@example.com',
            Username = 'test.salesmgr@example.com.test',
            Alias = 'tsmgr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            UserRoleId = role1.Id
        );
        insert u;
        Test.startTest();
        EYI_GetQuotaionValue.getUserRole(u.id);
        EYI_GetQuotaionValue.getUserRole(UserInfo.getUserId());
        
		Test.stopTest();
    }
    
}