@isTest
public class EYI_CarParkingSyncLwcController_test {
    
    @isTest
    public static void testSyncTowerCarparking() {
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
        
        Dynamic_Batch_Setting__c setting = new Dynamic_Batch_Setting__c(
            Name = 'Car Park Sync Tower Test',
            Batch_size__c = 5
        );
        insert setting;
        
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
        
        EYI_Payment_Schedule__c paymentschl = new EYI_Payment_Schedule__c(
            EYI_SAP_Milestone_Code__c ='3193',
            EYI_Milestone_Number__c = 319,
            EYI_SAP_Sales_Org__c = 'R152',
            EYI_SAP_Plant_Code__c = 'R15D',
            EYI_Tower__c =towerobj.id,
            EYI_Project__c =projctobj.id,
            EYI_SAP_Activity_Number__c =3,
            EYI_Usage__c ='Z0002',
            //Payment_Plan__c ='',
            EYI_AutomationBypassDatetime__c = system.today(),
            EYI_Usage_Description__c ='On Booking Changed',
            EYI_WBS_Element__c = 10609,
            EYI_Billing_Date__c =system.today()-5,
            EYI_Actual_Date__c = system.today()+10,
            EYI_Invoice_Percentage__c =20
        );
        insert paymentschl;
        
        EYI_Inventory__c inv = new EYI_Inventory__c(
    		Name = 'Test Inventory',
    		EYI_Project__c = projctobj.Id,
    		EYI_Tower__c = towerobj.Id,
    		EYI_Inventory_Number__c = 'INV-001'
            //
		);
		insert inv;
        EYI_Car_Park_Master__c carprk = new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c = 'Saleable Service',
            EYI_Material_Group__c = 'Parking',
            EYI_Base_UOM__c = 'Each',
            EYI_Tower__c = towerobj.id,
            EYI_Project__c = projctobj.id,
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
            EYI_GST_Tax_Classification__c = 'Taxable under GST',
			EYI_Inventory__c = inv.Id
        );
        insert carprk;
        Test.startTest();
         String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{"EX_RETURN":{"item":{"TYPE":"S","ID":"MM","NUMBER":"356","MESSAGE":"The material P101 has been created or extended","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"P101","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":"DS4CLNT120"}},"EX_UNIT":"P101"}}';
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CarParkingSyncLwcController.CarParkingSync(towerobj.id); 
        Test.stopTest();
        
    }
    @isTest
    public static void testSyncProjectCarparking () {
          EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 256',
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
  
        Dynamic_Batch_Setting__c setting = new Dynamic_Batch_Setting__c(
            Name = 'Car Park Sync Project Test',
            Batch_size__c = 5
        );
        insert setting;
        
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
        
        EYI_Payment_Schedule__c paymentschl = new EYI_Payment_Schedule__c(
            EYI_SAP_Milestone_Code__c ='3193',
            EYI_Milestone_Number__c = 319,
            EYI_SAP_Sales_Org__c = 'R152',
            EYI_SAP_Plant_Code__c = 'R15D',
            EYI_Tower__c =towerobj.id,
            EYI_Project__c =projctobj.id,
            EYI_SAP_Activity_Number__c =3,
            EYI_Usage__c ='Z0002',
            //Payment_Plan__c ='',
            EYI_AutomationBypassDatetime__c = system.today(),
            EYI_Usage_Description__c ='On Booking Changed',
            EYI_WBS_Element__c = 10609,
            EYI_Billing_Date__c =system.today()-5,
            EYI_Actual_Date__c = system.today()+10,
            EYI_Invoice_Percentage__c =20
        );
        insert paymentschl;
        
        EYI_Inventory__c inv = new EYI_Inventory__c(
    		Name = 'Test Inventory',
    		EYI_Inventory_Number__c = 'INV-002',
    		EYI_Project__c = projctobj.Id,
    		EYI_Tower__c = towerobj.Id
    		// 
		);
		insert inv;
        
        EYI_Car_Park_Master__c carprk = new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c = 'Saleable Service',
            EYI_Material_Group__c = 'Parking',
            EYI_Base_UOM__c = 'Each',
            EYI_Tower__c = towerobj.id,
            EYI_Project__c = projctobj.id,
            EYI_Inventory__c = inv.Id,
            EYI_SAP_Material_Description__c = 'Description Description',
            EYI_Status__c = 'Vacant',
            EYI_Parking_Number__c = 'P-301',
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
                
        Test.startTest();
        String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{"EX_RETURN":{"item":{"TYPE":"S","ID":"MM","NUMBER":"356","MESSAGE":"The material P101 has been created or extended","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"P101","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":"DS4CLNT120"}},"EX_UNIT":"P101"}}';
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CarParkingSyncLwcController.CarParkingSync(projctobj.id); 
        Test.stopTest();
        
    }
   
     @isTest
    public static void testErorCarparking () {
          EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 256',
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
        
        Dynamic_Batch_Setting__c setting = new Dynamic_Batch_Setting__c(
            Name = 'Car Park Sync Error Test',
            Batch_size__c = 5
        );
        insert setting;
            
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
        
        EYI_Payment_Schedule__c paymentschl = new EYI_Payment_Schedule__c(
            EYI_SAP_Milestone_Code__c ='3193',
            EYI_Milestone_Number__c = 319,
            EYI_SAP_Sales_Org__c = 'R152',
            EYI_SAP_Plant_Code__c = 'R15D',
            EYI_Tower__c =towerobj.id,
            EYI_Project__c =projctobj.id,
            EYI_SAP_Activity_Number__c =3,
            EYI_Usage__c ='Z0002',
            //Payment_Plan__c ='',
            EYI_AutomationBypassDatetime__c = system.today(),
            EYI_Usage_Description__c ='On Booking Changed',
            EYI_WBS_Element__c = 10609,
            EYI_Billing_Date__c =system.today()-5,
            EYI_Actual_Date__c = system.today()+10,
            EYI_Invoice_Percentage__c =20
        );
        insert paymentschl;
        
        EYI_Inventory__c inv = new EYI_Inventory__c(
    		Name = 'Test Inventory',
    		EYI_Inventory_Number__c = 'INV-003', 
    		EYI_Project__c = projctobj.Id,
    		EYI_Tower__c = towerobj.Id
    		// 
		);
		insert inv;
        
        EYI_Car_Park_Master__c carprk = new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c = 'Saleable Service',
            EYI_Material_Group__c = 'Parking',
            EYI_Base_UOM__c = 'Each',
            EYI_Tower__c = towerobj.id,
            EYI_Project__c = projctobj.id,
			EYI_Inventory__c = inv.Id,
            EYI_SAP_Material_Description__c = 'Description Description',
            EYI_Status__c = 'Vacant',
            EYI_Parking_Number__c = 'P-301',
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
                
        Test.startTest();
        String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{}}';
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CarParkingSyncLwcController.CarParkingSync(projctobj.id); 
        Test.stopTest();
        
    }
    
    @isTest
	public static void testCarParkingSyncWithNullId() {
    	EYI_CarParkingSyncLwcController.lwcMessage result = EYI_CarParkingSyncLwcController.CarParkingSync(null);
    	System.assertEquals('E', result.type);
    	System.assert(result.message.contains('Record Id Missing'), 'Should return error for missing Id');
	}

	@isTest	
	public static void testCarParkingSyncWithUnsupportedId() {
    	Account acc = new Account(Name='Test Acc');
    	insert acc;
    	EYI_CarParkingSyncLwcController.lwcMessage result = EYI_CarParkingSyncLwcController.CarParkingSync(acc.Id);
    	System.assertEquals('E', result.type);
    	System.assert(result.message.contains('Unsupported record type'), 'Should return error for unsupported type');
	}
    
    @isTest
    public static void testNoCarParksOnTower() {
        // Create a minimal project
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'NoCP',
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

        // Create a minimal tower linked to the project
        EYI_Tower__c towerobj = new EYI_Tower__c(
            Name = 'TowerNoCP',
            EYI_Stage__c = 'Pre-Launch',
            EYI_Pass_Code__c = 'TNC',
            EYI_Project_Name__c = projctobj.Id,
            EYI_RERA_Certificate_Date__c = System.today() - 10,
            EYI_RERA_Number__c = 'TNC-123',
            EYI_RERA_Possesion_Date__c = System.today() - 15,
            EYI_Tower_Number__c = 'T01',
            EYI_Tower_Property_Type__c = 'Apartments',
            EYI_SAP_Delivery_Plant_Code__c = 'R15D',
            EYI_SAP_Plant_ID__c = 'R15I', 
            EYI_Total_Car_Park__c = 0, // No car parks
            EYI_Onboarding_Manager__c = UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert towerobj;

        // Insert a Dynamic_Batch_Setting__c if needed
        Dynamic_Batch_Setting__c setting = new Dynamic_Batch_Setting__c(
            Name = 'Car Park Sync No CP Test',
            Batch_size__c = 5
        );
        insert setting;
        
         // SET THE MOCK
    	EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{"EX_RETURN":{"item":{"TYPE":"S","MESSAGE":"Success"}}}}');
    	Test.setMock(HttpCalloutMock.class, mock);

        // No car park records created/inserted

        Test.startTest();
        EYI_CarParkingSyncLwcController.lwcMessage result = EYI_CarParkingSyncLwcController.CarParkingSync(towerobj.Id);
        Test.stopTest();

        System.assertEquals('S', result.type, 'Should return success type when no car parks to sync');
        System.assertNotEquals(null, result, 'Result should not be null');
    }
}