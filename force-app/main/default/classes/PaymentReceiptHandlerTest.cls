@isTest
public class PaymentReceiptHandlerTest {
	@isTest
    static  void testProcessFromReceiptsAndReceiptIds() {
        //payment receipt trigger and handler test class
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            EYI_City__c='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405',
            Master_Type__c='Pincode',
            EYI_Zone__c ='Pune Region',
            EYI_Sub_Urb__c='Pune Moffusil Division'
        );
        insert mster;
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        
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
            EYI_Email_Id__c='test@gmail.com',
            EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c ='Maharashtra'            
        );
        insert CIF;
        
         Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
             
        );
        insert Acc;
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
            EYI_Project_Property_Type__c = 'Residential',
            EYI_TDS_Charge__c = 10
        );
        insert projctobj;
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.EYI_project_Name__c = projctobj.Id;
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        insert newTower;
         EYI_Inventory__c invtry = new EYI_Inventory__c(
            // EYI_Booking__c=book.id,
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
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            AccountId=Acc.Id,
            EYI_CIF_Record__c =CIF.id,
            CloseDate = Date.today().addDays(30),
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
            EYI_Inventory__c = invtry.Id
        );
        insert testOpportunity;
        // Create mock Demand
        EYI_Demand__c demand = new EYI_Demand__c(
           // Name = 'Demand1',
            EYI_SAP_Demand_Number__c = 'DOC123',
            EYI_Amount_to_be_paid__c = 100,
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert demand;

        // Create Payment Receipt
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
         //   Name = 'Receipt1',
            EYI_Amount__c = 100,
            EYI_Payment_Status__c = 'SUBMITTED',
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert receipt;
        receipt.EYI_Payment_Status__c ='APPROVE';
        update receipt;

        // Create Line Item linking receipt and demand (via document number)
        EYI_Payment_Line_Item__c pli = new EYI_Payment_Line_Item__c(
            EYI_Payment_Receipt__c = receipt.Id,
            EYI_Billing_Document__c = 'DOC123'
           // EYI_Opportunity__c = testOpportunity.Id
        );
        insert pli;

        Test.startTest();
        // Test processFromReceipts
       // PaymentReceiptHandler.processFromReceipts(new List<EYI_Payment_Receipt__c>{ receipt });
        Test.setMock(HttpCalloutMock.class, new EYI_FCMCalloutMock());

        Test.stopTest();

        // Assert mapping was created
        EYI_Demand_Receipt_Mapping__c drm = [
            SELECT Id, EYI_Demand__c, EYI_Bank_Payment_Receipt__c 
            FROM EYI_Demand_Receipt_Mapping__c 
            WHERE EYI_Bank_Payment_Receipt__c = :receipt.Id
        ];
        System.assertNotEquals(null, drm);
    }
	@isTest
    static void testCleanUpDeletedLineItems() {
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
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        
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
			EYI_Email_Id__c = 'test@gmail.com',
            EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c ='Maharashtra' 
            
        );
        insert CIF;
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
             
        );
        insert Acc;
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
            EYI_Project_Property_Type__c = 'Residential',
            EYI_TDS_Charge__c = 10
        );
        insert projctobj;
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.EYI_project_Name__c = projctobj.Id;
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        insert newTower;
         EYI_Inventory__c invtry = new EYI_Inventory__c(
            // EYI_Booking__c=book.id,
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
         Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
             EYI_CIF_Record__c =CIF.id,
             AccountId = Acc.Id,
            CloseDate = Date.today().addDays(30),
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
             EYI_Inventory__c = invtry.Id
        );
        insert testOpportunity;
        // Setup: Create Demand, Receipt, Mapping and a Line Item
        EYI_Demand__c demand = new EYI_Demand__c(
           // Name = 'Demand2',
            EYI_SAP_Demand_Number__c = 'DOC456',
            EYI_Amount_to_be_paid__c = 200,
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert demand;

        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
         //   Name = 'Receipt2',
            EYI_Amount__c = 200,
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert receipt;

        // Create a Mapping manually
        EYI_Demand_Receipt_Mapping__c drm = new EYI_Demand_Receipt_Mapping__c(
            EYI_Demand__c = demand.Id,
            EYI_Bank_Payment_Receipt__c = receipt.Id
        );
        insert drm;

        // Create a line item with DOC456 and then delete it to simulate cleanup
        EYI_Payment_Line_Item__c pli = new EYI_Payment_Line_Item__c(
            EYI_Payment_Receipt__c = receipt.Id,
            EYI_Billing_Document__c = 'DOC456'
        );
        insert pli;
        delete pli;

        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new EYI_FCMCalloutMock());
        PaymentReceiptHandler.cleanUpDeletedLineItems(new Set<Id>{receipt.Id});
        Test.stopTest();

        List<EYI_Demand_Receipt_Mapping__c> remaining = [
            SELECT Id FROM EYI_Demand_Receipt_Mapping__c WHERE EYI_Bank_Payment_Receipt__c = :receipt.Id
        ];
        System.assertEquals(0, remaining.size(), 'Mapping should have been deleted after line item removal');
    }
	@isTest
    static void testUpdateDemandStatusForApprovedReceipts() {
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
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        
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
            EYI_Email_Id__c='test@gmail.com',
            EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c ='Maharashtra' 
            
        );
        insert CIF;
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
             
        );
        insert Acc;
        
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
            EYI_Project_Property_Type__c = 'Residential',
            EYI_TDS_Charge__c = 10
        );
        insert projctobj;
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.EYI_project_Name__c = projctobj.Id;
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        insert newTower;
         EYI_Inventory__c invtry = new EYI_Inventory__c(
            // EYI_Booking__c=book.id,
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
         Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
             EYI_CIF_Record__c =CIF.id,
             AccountId = Acc.Id,
            CloseDate = Date.today().addDays(30),
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
             EYI_Inventory__c = invtry.Id
        );
        insert testOpportunity;
        // Setup demands and receipts for both One-to-Many and Many-to-One cases
        EYI_Demand__c demand1 = new EYI_Demand__c(
          //  Name = 'Demand3',
            EYI_SAP_Demand_Number__c = 'DOC789',
            EYI_Amount_to_be_paid__c = 300,
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert demand1;

        EYI_Demand__c demand2 = new EYI_Demand__c(
           // Name = 'Demand4',
            EYI_SAP_Demand_Number__c = 'DOC101',
            EYI_Amount_to_be_paid__c = 200,
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert demand2;

        EYI_Payment_Receipt__c receipt1 = new EYI_Payment_Receipt__c(
          //  Name = 'Receipt3',
            EYI_Amount__c = 300,
            EYI_Payment_Status__c = 'APPROVE',
            EYI_Opportunity__c = testOpportunity.Id
            
        );
        EYI_Payment_Receipt__c receipt2 = new EYI_Payment_Receipt__c(
         //   Name = 'Receipt4',
            EYI_Amount__c = 200,
            EYI_Payment_Status__c = 'APPROVE',
            EYI_Opportunity__c = testOpportunity.Id
        );
        insert new List<EYI_Payment_Receipt__c>{ receipt1, receipt2 };

        // Create mappings
        insert new List<EYI_Demand_Receipt_Mapping__c>{
            new EYI_Demand_Receipt_Mapping__c(EYI_Demand__c = demand1.Id, EYI_Bank_Payment_Receipt__c = receipt1.Id),
            new EYI_Demand_Receipt_Mapping__c(EYI_Demand__c = demand2.Id, EYI_Bank_Payment_Receipt__c = receipt2.Id)
        };

        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new EYI_FCMCalloutMock());
        PaymentReceiptHandler.updateDemandStatusForApprovedReceipts(new Set<Id>{receipt1.Id, receipt2.Id});
        Test.stopTest();

        EYI_Demand__c updated1 = [SELECT EYI_Demand_Payment_Status__c FROM EYI_Demand__c WHERE Id = :demand1.Id];
        EYI_Demand__c updated2 = [SELECT EYI_Demand_Payment_Status__c FROM EYI_Demand__c WHERE Id = :demand2.Id];

        System.assertEquals('Completed', updated1.EYI_Demand_Payment_Status__c);
        System.assertEquals('Completed', updated2.EYI_Demand_Payment_Status__c);
    }
}