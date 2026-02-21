/**
* @description       : 
* @author            : Viksit Rana
* @group             : 
* @last modified on  : 11-06-2025
* @last modified by  : Swapnil
**/
@isTest
public class EYI_InventorySyncLwcController_test {

    @testSetup
	static void setupBatchSetting() {
    	insert new Dynamic_Batch_Setting__c(Name='Inventory Sync', Batch_size__c=1, Last_Batch_Run__c=System.now());
	}
    
    @isTest
    static void testSyncTowerInventory() {
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
            EYI_AutomationBypassDatetime__c = system.today(),
            EYI_Usage_Description__c ='On Booking Changed',
            EYI_WBS_Element__c = 10609,
            EYI_Billing_Date__c =system.today()-5,
            EYI_Actual_Date__c = system.today()+10,
            EYI_Invoice_Percentage__c =20
        );
        insert paymentschl;

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
            EYI_Typology__c = 'Villa',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I'
        );
        insert invtry;
            SAP_SF_Field_Map__c mapRec = new SAP_SF_Field_Map__c(
            Name = 'Test',
            SF_Field_Name__c = 'EYI_SAP_Material_Type__c',
            SF_Value__c = 'TestValue',
            SAP_Value__c = 'SAPTestValue'
        );
        insert mapRec;


        insert new Dynamic_Batch_Setting__c(Name='Inventory Sync', Batch_size__c=1, Last_Batch_Run__c=System.now());
        Test.startTest();
        String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{"EX_RETURN":{"item":{"TYPE":"S","ID":"MM","NUMBER":"356","MESSAGE":"The material P101 has been created or extended","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"P101","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":"DS4CLNT120"}},"EX_UNIT":"P101"}}';
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_InventorySyncLwcController.InventorySync(towerobj.id); 
        Test.stopTest();
    }


                @isTest
        static void testProcessInventoryRecords_FieldMapCoverage() {
            // Insert required SAP_SF_Field_Map__c record
            SAP_SF_Field_Map__c mapRec = new SAP_SF_Field_Map__c(
                Name = 'Test',
                SF_Field_Name__c = 'EYI_SAP_Material_Type__c',
                SF_Value__c = 'TestValue',
                SAP_Value__c = 'SAPTestValue'
            );
            insert mapRec;

            // Insert minimal EYI_Inventory__c record with matching field
            EYI_Inventory__c inv = new EYI_Inventory__c(
                Name = 'TestInv',
                EYI_Inventory_Number__c = 'INV-001',
                EYI_SAP_Material_Type__c = 'Saleable Service'
                // Add other required fields as per your org
            );
            insert inv;

            // Call the method
            Test.startTest();
            EYI_InventorySyncLwcController.processInventoryRecords(new List<EYI_Inventory__c>{inv}, false, false);
            Test.stopTest();
        }

    @isTest
    static void testSyncProjectInventory () {
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
            EYI_AutomationBypassDatetime__c = system.today(),
            EYI_Usage_Description__c ='On Booking Changed',
            EYI_WBS_Element__c = 10609,
            EYI_Billing_Date__c =system.today()-5,
            EYI_Actual_Date__c = system.today()+10,
            EYI_Invoice_Percentage__c =20
        );
        insert paymentschl;

        EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Saleable Service',
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
            EYI_Typology__c='Villa',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I'
        );
        insert invtry;
	
        insert new Dynamic_Batch_Setting__c(Name='Inventory Sync', Batch_size__c=1, Last_Batch_Run__c=System.now());
        Test.startTest();
        String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{"EX_RETURN":{"item":{"TYPE":"S","ID":"MM","NUMBER":"356","MESSAGE":"The material P101 has been created or extended","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"P101","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":"DS4CLNT120"}},"EX_UNIT":"P101"}}';
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_InventorySyncLwcController.InventorySync(projctobj.id); 
        Test.stopTest();
    }
        @isTest
        static void testProcessInventoryRecords_StatusChange() {
            
            SAP_SF_Field_Map__c statusMap = new SAP_SF_Field_Map__c(
                Name = 'StatusMap',
                SF_Field_Name__c = 'EYI_Inventory_Status__c',
                SF_Value__c = 'Available',
                SAP_Value__c = 'MappedStatus'
            );
            insert statusMap;

            // Insert minimal required inventory record
            EYI_Inventory__c inv = new EYI_Inventory__c(
                Name = 'TestInv',
                EYI_Inventory_Number__c = 'INV-002',
                EYI_Inventory_Status__c = 'Reserve' 
            );
            insert inv;

            Test.startTest();
            EYI_InventorySyncLwcController.processInventoryRecords(
                new List<EYI_Inventory__c>{inv}, false, true
            );
            Test.stopTest();
        }

    @isTest
    static void testErrorInventory () {
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
            EYI_AutomationBypassDatetime__c = system.today(),
            EYI_Usage_Description__c ='On Booking Changed',
            EYI_WBS_Element__c = 10609,
            EYI_Billing_Date__c =system.today()-5,
            EYI_Actual_Date__c = system.today()+10,
            EYI_Invoice_Percentage__c =20
        );
        insert paymentschl;

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
            EYI_Typology__c='Villa',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I'
        );
        insert invtry;
		
        insert new Dynamic_Batch_Setting__c(Name = 'Inventory Sync', Batch_size__c = 1, Last_Batch_Run__c = System.now());
        Test.startTest();
        String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{}}';
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_InventorySyncLwcController.InventorySync(projctobj.id); 
        Test.stopTest();
    }
    
    @isTest
static void testProcessInventoryRecords_ItemListCoverage() {
    // Insert required SAP_SF_Field_Map__c record for mapping
    SAP_SF_Field_Map__c mapRec = new SAP_SF_Field_Map__c(
        Name = 'Test',
        SF_Field_Name__c = 'EYI_SAP_Material_Type__c',
        SF_Value__c = 'TestValue',
        SAP_Value__c = 'SAPTestValue'
    );
    insert mapRec;

    // Insert minimal required inventory record
    EYI_Inventory__c inv = new EYI_Inventory__c(
        Name = 'TestInv',
        EYI_Inventory_Number__c= 'INV-002',
        EYI_SAP_Material_Type__c = 'Finished Unit'
        // Add other required fields as per your org
    );
    insert inv;

    // Mock response with item as a list
    String mockResponse = '{"n0:ZSD_CREATE_UNITS_FROM_SFResponse":{"EX_RETURN":{"item":[{"TYPE":"E","MESSAGE":"Error 1"},{"TYPE":"S","MESSAGE":"Success 1"}]},"EX_UNIT":"P101"}}';
    EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    EYI_InventorySyncLwcController.processInventoryRecords(new List<EYI_Inventory__c>{inv}, false, false);
    Test.stopTest();
}
    @isTest
	static void testNullRecordId() {
    	EYI_InventorySyncLwcController.lwcMessage result = EYI_InventorySyncLwcController.InventorySync(null);
    	System.assertEquals('E', result.type);
    	System.assertEquals('Record Id Missing', result.message);
	}
    
    @isTest
	static void testUnsupportedRecordType() {
    	Account acc = new Account(Name='Test Acc');
    	insert acc;
    	EYI_InventorySyncLwcController.lwcMessage result = EYI_InventorySyncLwcController.InventorySync(acc.Id);
    	System.assertEquals('E', result.type);
    	System.assertEquals('Unsupported record type for Inventory Sync', result.message);
	}
   
    @isTest
	static void testRemoveDuplicate() {
    	String input = 'A,B,C,A,B';
    	String result = EYI_InventorySyncLwcController.removeDuplicate(input);
    	// The result should contain A, B, and C each only once, order may vary due to Set
    	System.assert(result.contains('A'), 'Should contain A');
    	System.assert(result.contains('B'), 'Should contain B');
    	System.assert(result.contains('C'), 'Should contain C');
    	System.assert(result.split(',').size() == 3, 'Should only have 3 unique elements');
	}

	@isTest
	static void testRequiredFieldValidationError() {
        insert new Dynamic_Batch_Setting__c(Name = 'Inventory Sync', Batch_size__c = 1, Last_Batch_Run__c = System.now());

    	// Create a project and tower for reference
    	EYI_Project__c proj = new EYI_Project__c(Name = 'Validation Test', EYI_Project_Code__c = 'VT1');
    	insert proj;
    	EYI_Tower__c tower = new EYI_Tower__c(Name = 'Validation Tower', EYI_Project_Name__c = proj.Id);
    	insert tower;

    	// Create inventory with missing required field (e.g., EYI_Project__c missing)
    	EYI_Inventory__c inv = new EYI_Inventory__c(
        	Name = 'Invalid Inventory',
        	EYI_Tower__c = tower.Id,  // EYI_Project__c is missing!
        	EYI_Inventory_Number__c = 'INV-123'
    	);
    	insert inv;

    	// Call InventorySync (which will call requiredFieldForInventorySync and hit error logic)
    	Test.setMock(HttpCalloutMock.class, new CarParkingCalloutMock()); 
    	EYI_InventorySyncLwcController.lwcMessage result = EYI_InventorySyncLwcController.InventorySync(tower.Id);

    	System.assert(result.message != null && result.message != '', 'Should return error message');
	}

}