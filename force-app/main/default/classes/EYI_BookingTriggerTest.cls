@isTest
private class EYI_BookingTriggerTest {

    @isTest
    static void testAfterUpdateBookingTrigger() {
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c = '3010000468' // Replace with a real writeable field
        );
        insert booking;

        booking.EYI_SAP_Sales_Order_Number__c = '3010000468'; // Update to trigger after update logic

        Test.startTest();
        update booking;
        Test.stopTest();

        EYI_Booking__c updated = [SELECT EYI_SAP_Sales_Order_Number__c FROM EYI_Booking__c WHERE Id = :booking.Id];
        System.assertEquals('3010000468', updated.EYI_SAP_Sales_Order_Number__c);
    }
}