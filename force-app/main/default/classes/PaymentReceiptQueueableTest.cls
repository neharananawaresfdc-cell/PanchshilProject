@isTest
public class PaymentReceiptQueueableTest {
    // Mock callout for EY_SAP_Gateway.sendPayementReceipt
    class MyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testExecute() {
        // Create a Payment Receipt record
        // 
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
            EYI_Mobile_number__c = '1234567890'
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
        
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
            EYI_Amount__c = 1000,
            EYI_Payment_Status__c = 'Approve',
            EYI_Opportunity__c = opp.Id,
            EYI_SAP_Customer_Number__c = 'CUST123'
        );
        insert receipt;

        // Prepare updatedRecords (can be empty or minimal)
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        updatedRecords.add(new Map<String, Object>{
            'someKey' => 'someValue'
        });

        // Prepare formData, must include 'paymentReceiptId'
        Map<String, Object> formData = new Map<String, Object>{
            'paymentReceiptId' => receipt.Id
        };

        // Register callout mock
        Test.setMock(HttpCalloutMock.class, new MyMock());

        // Enqueue the queueable
        Test.startTest();
        System.enqueueJob(new PaymentReceiptQueueable(updatedRecords, formData));
        Test.stopTest();

        // Assert the record still exists
        EYI_Payment_Receipt__c fetched = [SELECT Id FROM EYI_Payment_Receipt__c WHERE Id = :receipt.Id];
        System.assertEquals(receipt.Id, fetched.Id);
    }
}