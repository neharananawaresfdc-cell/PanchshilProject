@isTest
public class EYI_CollectionAchievementBatchTest {
    @testSetup
    static void setupTestData() {
        // Insert prerequisite records for the batch job
        Monthly_Target__c mt = new Monthly_Target__c(
            Name = 'Test Target',
            EYI_Month__c = Date.newInstance(2025, 6, 1)
        );
        insert mt;
        
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
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
            EYI_SAP_Profit_Center__c='R150R1R15I' 
        );
        insert invtry;

        // Create CIF record first
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_Email_Id__c = 'test@example.com',
            EYI_First_Name__c = 'Test',
            EYI_Mobile_number__c = '1234567890',
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert cif;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            EYI_Collectible_Status__c = 'Collectible',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_Inventory__c = invtry.Id,
            EYI_SAP_Customer_Number__C = 'CUST123',
            EYI_CIF_Record__c = cif.Id  // Link to CIF record
        );
        insert opp;

        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Opportunity__c = opp.Id,
            //EYI_Tower__c = opp.Id,
            EYI_Demand_Status__c = 'Open',
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Amount_to_be_paid__c = 500.00,
            EYI_Billing_Date__c = Date.today().toStartOfMonth().addDays(5),  // ✅ 5th of the month
            EYI_Actual_Date__c = Date.today().toStartOfMonth().addDays(4)    // ✅ also early
        );
        insert demand; 
        
        EYI_Payment_Receipt__c payment = new EYI_Payment_Receipt__c(
            EYI_Amount__c = 1000,
            EYI_Payment_Status__c = 'Approve',
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Customer_Number__c = 'CUST123'
        );
        insert payment;
        
        EYI_Demand_Receipt_Mapping__c drm = new EYI_Demand_Receipt_Mapping__c(
            EYI_Demand__c = demand.Id,
            EYI_Bank_Payment_Receipt__c = payment.Id
        );
        insert drm;
        
        EYI_Collection_Achievement__c ach = new EYI_Collection_Achievement__c(
            EYI_Monthly_Target__c = mt.Id,
            Name = 'Test Target',
            EYI_Collected_Amount__c = 500,
            EYI_Tower__c = mt.EYI_Tower__c,
            EYI_Opportunity__c = opp.Id
        );
        // Get the correct RecordTypeId for 'SAP Outstanding Report'
        RecordType sapRecordType = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'EYI_SAP_Report__c' 
            AND Name = 'SAP Outstanding Report' 
            LIMIT 1
        ];
        
        // Create SAP Report record for the test Opportunity
        insert ach;
        EYI_SAP_Report__c sapReport = new EYI_SAP_Report__c(
            Name = 'Test SAP Report',
            Opportunity__c = opp.Id,
            EYI_Outstanding_Amount__c = 2000.00,
            RecordTypeId = sapRecordType.Id
        );
        insert sapReport;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        // Run the batch job with scope size 1
        EYI_CollectionAchievementBatch batch = new EYI_CollectionAchievementBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Validate that Collection Achievement records are created/updated
        List<EYI_Collection_Achievement__c> achList = [
            SELECT Id, EYI_Collected_Amount__c, Name
            FROM EYI_Collection_Achievement__c
            WHERE Name = 'Test Target'
        ];
        System.assert(!achList.isEmpty(), 'Collection Achievement records should be created or updated.');
        // Add more assertions as appropriate for your batch logic
    }
}