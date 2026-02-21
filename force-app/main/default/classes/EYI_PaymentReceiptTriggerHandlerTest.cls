@isTest
private class EYI_PaymentReceiptTriggerHandlerTest {

    @isTest
    static void testApprovedReceiptInsert() {
        // Create a Demand record
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_SAP_Demand_Number__c = 'DOC123',
            EYI_Amount_to_be_paid__c = 1000
        );
        insert demand;

        // Create a Payment Receipt
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
            EYI_Payment_Status__c = 'APPROVE',
            EYI_Amount__c = 1000
        );
        insert receipt;

        // Create a Payment Line Item linking the receipt to the demand document
        EYI_Payment_Line_Item__c lineItem = new EYI_Payment_Line_Item__c(
            EYI_Payment_Receipt__c = receipt.Id,
            EYI_Billing_Document__c = 'DOC123'
        );
        insert lineItem;

        Test.startTest();
        // Trigger should fire and create mapping
        EYI_Payment_Receipt__c newReceipt = new EYI_Payment_Receipt__c(
            EYI_Payment_Status__c = 'APPROVE',
            EYI_Amount__c = 1000
        );
        insert newReceipt;

        EYI_Payment_Line_Item__c newLineItem = new EYI_Payment_Line_Item__c(
            EYI_Payment_Receipt__c = newReceipt.Id,
            EYI_Billing_Document__c = 'DOC123'
        );
        insert newLineItem;
        Test.stopTest();
    }

    @isTest
    static void testApprovedReceiptUpdate() {
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
            EYI_Payment_Status__c = 'PENDING',
            EYI_Amount__c = 500
        );
        insert receipt;

        receipt.EYI_Payment_Status__c = 'APPROVE';

        Test.startTest();
        update receipt;
        Test.stopTest();
    }
}