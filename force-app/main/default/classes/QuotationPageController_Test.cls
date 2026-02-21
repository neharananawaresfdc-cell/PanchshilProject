/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class QuotationPageController_Test {
  @isTest
    public static void searchRecordsTest(){
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
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
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
            //EYI_City__c =city.id,
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
        
        Payment_Plan__c paymentPlantRec = new Payment_Plan__c(
          name = 'Test123',
            Project__c = projctobj.id
        );
        insert paymentPlantRec;
        
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
            EYI_Opportunity__c = opp.id,
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            Payment_Plan__c = paymentPlantRec.id,
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
            EYI_Parking_Count__c = 10,
            EYI_Saleable_Area_in_Sq_Mtr__c = 20
        );
        insert invtry;
        
        EYI_Global_Charges__c globalChargeRec = new EYI_Global_Charges__c(
          Name = 'Test1',
            EYI_Charge_Type__c = 'Pricing Charges',
            EYI_SAP_Material_Name__c = 'EYI_SAP_Material_Name__c'
        );
        insert globalChargeRec;
        
        EYI_Rate_List__c rateListRec = new EYI_Rate_List__c(
          EYI_Inventory__c = invtry.Id,
            EYI_Global_Charges__c = globalChargeRec.id
        );
        insert rateListRec;
        
        EYI_Project_Unit__c pUnitRec = new EYI_Project_Unit__c(
          EYI_Project__c = projctobj.id
            //CGST__c = 9.9,
            //SGST__c = 9.9
        );
        insert pUnitRec;
        
        
        Test.startTest();
        QuotationPageController.searchRecords('Tushar test','opportunity');
    QuotationPageController.searchRecords('Balewadi 23','project');
    QuotationPageController.searchRecords('Test123','plantype');
        QuotationPageController.searchRecords(null,'opportunity');
    QuotationPageController.searchRecords(null,'project');
    QuotationPageController.searchRecords(null,'plantype');
        QuotationPageController.getPlanType(projctobj.id,'test');
        QuotationPageController.getDummyOpportunity();
        QuotationPageController.getInventory(invtry.id);
        QuotationPageController.getQuoteValues(invtry.id);
        QuotationPageController.getQuoteValues(null);
        QuotationPageController.inventoryData inv = new QuotationPageController.inventoryData();
        inv.centralGst = 12;
        inv.unit = 12;
        inv.infrastructureCharge = 12;
        inv.stateGst = 12;
        inv.stampDuty = 12;
        inv.registration = 12;
        inv.mainitenance_deposit = 12;
        inv.msebc_charges = 12;
        inv.legal_charges = 12;
        inv.maintenance_charges = 12;
        
        Test.stopTest();
    }
}