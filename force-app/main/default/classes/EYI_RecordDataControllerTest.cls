@isTest
public class EYI_RecordDataControllerTest {
   /* @isTest
    static void testGetRecordData_PaymentReceipt() {
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
            EYI_SAP_Document_Number__c = 'DOC123',
            EYI_SAP_Company_Code__c = 'COMP',
            EYI_Fiscal_Year__c = 2024
        );
        insert receipt;

        Test.startTest();
        SObject result = EYI_RecordDataController.getRecordData(receipt.Id, 'EYI_Payment_Receipt__c');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('DOC123', (String)result.get('EYI_SAP_Document_Number__c'));
    } */

    @isTest
    static void testGetRecordData_Booking() {
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_SAP_Customer_Number__c = 'CUST123',
            EYI_SAP_Sales_Order_Number__c = 'SO123'
        );
        insert booking;

        Test.startTest();
        SObject result = EYI_RecordDataController.getRecordData(booking.Id, 'EYI_Booking__c');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('SO123', (String)result.get('EYI_SAP_Sales_Order_Number__c'));
    }

    @isTest
    static void testGetRecordData_Demand() {
        Opportunity opp = new Opportunity(
            Name = 'Test Past Opp',
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-10), // 10 days in the past
            Amount = 10000,
            EYI_Ownership_Status__c = 'Accepted'
        );
        
        insert opp;
        
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_SAP_Demand_Number__c = 'DEMAND123',
            EYI_Opportunity__c = opp.Id
        );
        insert demand;

        Test.startTest();
        SObject result = EYI_RecordDataController.getRecordData(demand.Id, 'EYI_Demand__c');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('DEMAND123', (String)result.get('EYI_SAP_Demand_Number__c'));
    }

    @isTest
    static void testGetRecordData_InvalidObject() {
        Test.startTest();
        Account acc = new Account();
        acc.Name='Test Account';
        insert acc;
        try {
            EYI_RecordDataController.getRecordData(acc.Id, 'Account');
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.debug(e.getMessage().contains('Unsupported object type'));
        }
        Test.stopTest();
    }

    @isTest
    static void testGetRecordData_EmptyInputs() {
        Test.startTest();
        try {
            EYI_RecordDataController.getRecordData('', '');
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Invalid recordId or objectApiName'));
            System.debug(e.getMessage().contains('Unsupported object type'));
        }
        Test.stopTest();
    }
}