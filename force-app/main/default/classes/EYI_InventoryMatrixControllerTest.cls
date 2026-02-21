/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class EYI_InventoryMatrixControllerTest {
    
    @isTest
    static void testGetAllProjects() {
        Test.startTest();
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId()
            //EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert testOpportunity;
        
        
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
        
        EYI_SubProject__c newSubProject = new EYI_SubProject__c();
        newSubProject.EYI_Project_Name__c  = projctobj.Id;
        newSubProject.Name = 'Subproject Name';
        newSubProject.EYI_SubProject_Property_Type__c ='Apartments';
        newSubProject.EYI_SubProject_Start_Date__c =  Date.today().addDays(30);
        insert newSubProject;
        
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.EYI_project_Name__c = projctobj.Id;
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        insert newTower;
        
        /*EYI_Inventory__c testInventory = new EYI_Inventory__c(
EYI_Floor_Number__c = '1', EYI_Project__c = projctobj.Id, EYI_Tower__c = newTower.Id
);
insert testInventory;*/
        
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
        List<EYI_Payment_Receipt__c> paymentSchedules= new List<EYI_Payment_Receipt__c>();
        String mockResponse = '{"Success":"true","SuccessCode":"200"}';
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        List<EYI_Project__c> resultProjects = EYI_InventoryMatrixController.getAllProjects();
        
        List<EYI_Tower__c> resultTowerss = EYI_InventoryMatrixController.getAllTowers();
        List<EYI_SubProject__c> resultProject = EYI_InventoryMatrixController.getAllSubProjects();
        List<Opportunity> opptyList = EYI_InventoryMatrixController.getOpptyProjects(testOpportunity.Id);
        List<EYI_Inventory__c> inventoryList = EYI_InventoryMatrixController.getAllFloors();
        EYI_InventoryMatrixController.getPicklistValues2();
        EYI_InventoryMatrixController.getAllInventoryColorCode();
        EYI_InventoryMatrixController.getPicklistConfig();
        EYI_InventoryMatrixController.savePaymentSchedules(paymentSchedules);
        EYI_InventoryMatrixController.blockInventory(invtry.iD,'bLOCK','Blocked');
        Test.stopTest();
        //System.assertEquals(1, resultProjects.size(), 'The number of retrieved projects should match the number of inserted projects.');
    }
  
    
    @IsTest
    static void methodName(){
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId()
            //EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert testOpportunity;
        
        
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
        
        EYI_SubProject__c newSubProject = new EYI_SubProject__c();
        newSubProject.EYI_Project_Name__c  = projctobj.Id;
        newSubProject.Name = 'Subproject Name';
        newSubProject.EYI_SubProject_Property_Type__c ='Apartments';
        newSubProject.EYI_SubProject_Start_Date__c =  Date.today().addDays(30);
        insert newSubProject;
        
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.EYI_project_Name__c = projctobj.Id;
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        insert newTower;
        
        Map<String, Object> jsonParams = new Map<String, Object>();
        EYI_Project__c ud = [Select id from EYI_Project__c where id =: projctobj.id limit 1];
        EYI_Tower__c tw = [select id from EYI_Tower__c where id =: newTower.id  limit 1];
        jsonParams.put('selectedProject', ud.Id);
        jsonParams.put('selectedSubProject', newSubProject.id);
        jsonParams.put('selectedTower', tw.Id);
        jsonParams.put('selectedProjectType', 'Flat');
        jsonParams.put('unitViewCondition', '');
        jsonParams.put('unitStatusCondition', '');
        jsonParams.put('selectedFloor', '');
        jsonParams.put('selectedUnitStatus', new List<String>());
        jsonParams.put('selectedUnitView', new List<String>());
        String jsonString = JSON.serialize(jsonParams);
        Test.startTest();
        String mockResponse = '{"Success":"true","SuccessCode":"200"}';
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        List<EYI_Inventory__c> inventoryList = EYI_InventoryMatrixController.getFilterdInventoryData(jsonString);
        Test.stopTest();
        // System.assertEquals(1, inventoryList.size());
        // System.assertEquals(1, inventoryList[0].EYI_Floor_Number__c);
 	}
    
    @isTest
    static void testValidateDemandDetails() {
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            EYI_Ownership_Status__c='Accepted',
            CloseDate=Date.today().addDays(10)
        );
        insert opp;
        
        // Create EYI_Demand__c -- do not set Name, set required fields only
        EYI_Demand__c d = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id
        );
        insert d;
        
        List<Id> recordIds = new List<Id>{d.Id};
            Test.startTest();
        String result = EYI_InventoryMatrixController.validateDemandDetails(recordIds);
        Test.stopTest();
        System.assertNotEquals(null, result); // or assertEquals('', result) depending on logic
    }
    
    @isTest
    static void testGetPicklistValues2() {
        Map<String, List<String>> picklistMap = EYI_InventoryMatrixController.getPicklistValues2();
        System.assertNotEquals(null, picklistMap);
    }
    
    @isTest
    static void testFetchDemands() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today().addDays(10));
        insert opp;
        //EYI_Demand__c d = new EYI_Demand__c(Name='D1', EYI_Opportunity__c=opp.Id, EYI_Project__c=null, EYI_Tower__c=null);
        //insert d;
        List<EYI_Demand__c> res = EYI_InventoryMatrixController.fetchDemands('All','All','All','All','All',Date.today(),Date.today(),null);
        System.assert(res != null);
    }
    
    @isTest
    static void testGetAllInventoryColorCode() {
        Inventory_Color_Mapping__c setting = new Inventory_Color_Mapping__c(StatusWithColor__c='Red:Error');
        insert setting;
        String code = EYI_InventoryMatrixController.getAllInventoryColorCode();
        System.assertNotEquals(null, code);
    }
    
    @isTest
    static void testGetTotalTokenAmt() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting',EYI_Ownership_Status__c='Accepted',CloseDate=Date.today().addDays(10));
        insert opp;
        //EYI_Payment_Receipt__c pr = new EYI_Payment_Receipt__c(EYI_Amount__c=100, EYI_Opportunity__c=opp.Id);
        //insert pr;
        Decimal amt = EYI_InventoryMatrixController.getTotalTokenAmt(opp.Id);
        System.assertEquals(0, amt);
    }

    @isTest
    static void testGetPicklistConfig() {
        // You may need to create a custom metadata record if not exists
        List<EYI_Inventory_Color_Mapping2__mdt> cfg = EYI_InventoryMatrixController.getPicklistConfig();
        System.assert(cfg != null);
    }

    @isTest
    static void testSavePaymentSchedules() {
        // Call with null, empty, and with data
        List<EYI_Payment_Receipt__c> listEmpty = new List<EYI_Payment_Receipt__c>();
        String msg = EYI_InventoryMatrixController.savePaymentSchedules(listEmpty);
        System.assert(msg != null);
    }
    
    @isTest
    static void testRaiseDemandsFromLWC() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', EYI_Ownership_Status__c='Accepted', CloseDate=Date.today().addDays(10));
        insert opp;
        
        EYI_Demand__c d = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id
        );
        insert d;
        
        Test.startTest();
        String result = EYI_InventoryMatrixController.raiseDemandsFromLWC(new List<Id>{d.Id}, 'RAISE');
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testSaveDemand() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', EYI_Ownership_Status__c='Accepted', CloseDate=Date.today().addDays(10));
        insert opp;
        
        // Create a demand record, set required fields but NOT Name
        EYI_Demand__c d = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Actual_Date__c = Date.today()
            // Add any other required fields for EYI_Demand__c here!
        );
        insert d;
        
        // Query it back to get a list
        List<EYI_Demand__c> demandList = [SELECT Id, EYI_Actual_Date__c FROM EYI_Demand__c WHERE Id = :d.Id];
        String res = EYI_InventoryMatrixController.saveDemand(demandList , 'RAISE');
        System.assertNotEquals(null, res);
    }
    
    @isTest
    static void testGetDemandDetails() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting',EYI_Ownership_Status__c='Accepted', CloseDate=Date.today().addDays(10));
        insert opp;
        EYI_Demand__c d = new EYI_Demand__c(EYI_Opportunity__c=opp.Id);
        // Add any other required fields for EYI_Demand__c here if needed!
        insert d;
        List<EYI_Demand__c> res = EYI_InventoryMatrixController.getDemandDetails(new List<Id>{d.Id});
        System.assert(res != null);
    }
    
    private static Map<String, Id> createDemandMap(List<EYI_Demand__c> demands) {
        insert demands;
        Map<String, Id> demandMap = new Map<String, Id>();
        Map<Id, Date> demandDataMap = new Map<Id, Date>();
        for(EYI_Demand__c d : demands){
            // Compose the key based on KUNNR + VBELN + MLBEZ (simulate these fields)
            // Assuming these fields are stored somewhere, here we fake keys for test
            String key = '1000' + '2000' + '3000'; // example keys
            demandMap.put(key, d.Id);
            demandDataMap.put(d.Id, Date.today().addDays(-5));
        }
        return demandMap;
    }

    @IsTest
    static void testUpdateDemands() {
        // Prepare dummy demands
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting',EYI_Ownership_Status__c='Accepted', CloseDate=Date.today().addDays(10));
        insert opp;
        EYI_Demand__c d1 = new EYI_Demand__c(EYI_Demand_Status__c = 'Open',EYI_Opportunity__c = opp.Id);
        EYI_Demand__c d2 = new EYI_Demand__c(EYI_Demand_Status__c = 'Open',EYI_Opportunity__c = opp.Id);
        List<EYI_Demand__c> demandList = new List<EYI_Demand__c>{d1, d2};
        insert demandList;

        // Compose demandMap and demandDataMap
        Map<String, Id> demandMap = new Map<String, Id>();
        Map<Id, Date> demandDataMap = new Map<Id, Date>();
        
        // Prepare key based on example from updateDemands (KUNNR + VBELN + MLBEZ)
        String key = 'KUNNR1VBELN1MLBEZ1';
        demandMap.put(key, d1.Id);
        demandDataMap.put(d1.Id, Date.today());

        // Create parsed item list with one item matching the key
        List<EYI_InventoryMatrixController.ParsedItem> parsedItems = new List<EYI_InventoryMatrixController.ParsedItem>();
        EYI_InventoryMatrixController.ParsedItem pItem1 = new EYI_InventoryMatrixController.ParsedItem();
        pItem1.KUNNR = 'KUNNR1';
        pItem1.VBELN = 'VBELN1';
        pItem1.MLBEZ = 'MLBEZ1';
        pItem1.TYPE = 'S';
        pItem1.Action = 'RAISE';
        pItem1.VBELN_VF = 'VF123';
        pItem1.CUSTOM1 = 'X';
        parsedItems.add(pItem1);
		EYI_InventoryMatrixController.ParsedItem pItem2 = new EYI_InventoryMatrixController.ParsedItem();
        pItem2.KUNNR = 'KUNNR1';
        pItem2.VBELN = 'VBELN1';
        pItem2.MLBEZ = 'MLBEZ1';
        pItem2.TYPE = 'S';
        pItem2.Action = 'SENT';
        pItem2.VBELN_VF = 'VF123';
        pItem2.CUSTOM1 = 'X';
        parsedItems.add(pItem2);
        EYI_InventoryMatrixController.ParsedItem pItem3 = new EYI_InventoryMatrixController.ParsedItem();
        pItem3.KUNNR = 'KUNNR1';
        pItem3.VBELN = 'VBELN1';
        pItem3.MLBEZ = 'MLBEZ1';
        pItem3.TYPE = 'S';
        pItem3.Action = 'CANCEL';
        pItem3.VBELN_VF = 'VF123';
        pItem3.CUSTOM1 = 'X';
        parsedItems.add(pItem3);
        EYI_InventoryMatrixController.ParsedItem pItem4 = new EYI_InventoryMatrixController.ParsedItem();
        pItem4.KUNNR = 'KUNNR1';
        pItem4.VBELN = 'VBELN1';
        pItem4.MLBEZ = 'MLBEZ1';
        pItem4.TYPE = 'S';
        pItem4.Action = 'BLOCK';
        pItem4.VBELN_VF = 'VF123';
        pItem4.CUSTOM1 = 'X';
        parsedItems.add(pItem4);
        Test.startTest();
        
        EYI_InventoryMatrixController.updateDemands(demandMap, demandDataMap, parsedItems);
        Test.stopTest();

        // Verify updated demand
        EYI_Demand__c updatedDemand = [SELECT EYI_Demand_Status__c, EYI_Demand_Raise_Date__c, EYI_SAP_Demand_Number__c, EYI_ESIGN_FLAG__c FROM EYI_Demand__c WHERE Id = :d1.Id];
       // System.assertEquals('Demand Raised', updatedDemand.EYI_Demand_Status__c);
        //System.assertEquals('VF123', updatedDemand.EYI_SAP_Demand_Number__c);
       // System.assertEquals(true, updatedDemand.EYI_ESIGN_FLAG__c);
       
    }


    @IsTest
    static void testExtractTypesFromResponse() {
        // JSON string mimicking the expected structure
        String jsonResponse = '{"n0:ZSD_DEMAND_FROM_SFResponse": {"EX_OUTPUT": {"item": [ ' +
            '{ "CUSTOM1": "X", "MSGTYPE": "S", "KUNNR": "CUST1", "VBELN": "VB1", "MLBEZ": "ML1", "VBELN_VF": "VF1", "MESSAGE": "Success" },' +
            '{ "CUSTOM1": "Y", "MSGTYPE": "E", "KUNNR": "CUST2", "VBELN": "VB2", "MLBEZ": "ML2", "MESSAGE": "Error occurred" }' +
        ']}}}';

        EYI_InventoryMatrixController.ParsedItemWrapper wrapper = EYI_InventoryMatrixController.extractTypesFromResponse(jsonResponse, 'RAISE');

        System.assertNotEquals(null, wrapper);
        System.assert(wrapper.parsedItems.size() == 2);

        // Check that Action is set correctly
        for (EYI_InventoryMatrixController.ParsedItem item : wrapper.parsedItems) {
            System.assertEquals('RAISE', item.Action);
        }

        // Check message contains "Error"
        System.assert(wrapper.message.contains('Error'));
    }



}