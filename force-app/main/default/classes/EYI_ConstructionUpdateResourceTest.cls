@isTest
private class EYI_ConstructionUpdateResourceTest {

    // Helper method to create test bookings
    private static List<EYI_Booking__c> createTestBookings(Integer count) {
        
        EYI_Tower__c tower = new EYI_Tower__c(Name = 'Test');
        insert tower;
        List<EYI_Booking__c> bookings = new List<EYI_Booking__c>();
        for (Integer i = 0; i < count; i++) {
            bookings.add(new EYI_Booking__c(
                EYI_Tower__c = tower.Id
            ));
        }
        insert bookings;
        return bookings;
    }

    static testMethod void testSingleBookingNumber() {
        List<EYI_Booking__c> bookings = createTestBookings(1);

        // Prepare JSON input with single booking number
        String inputJson = JSON.serialize(new Map<String, Object>{
            'booking_number' => bookings[0].Name
        });

        // Set REST context
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(inputJson);
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestURI = '/services/apexrest/ConstructionUpdates/';

        Test.startTest();
        EYI_ConstructionUpdateResource.getConstructionUpdates();
        Test.stopTest();
    }

    static testMethod void testMultipleBookingNumbers() {
        List<EYI_Booking__c> bookings = createTestBookings(2);

        // Prepare JSON input with booking_numbers array
        String inputJson = JSON.serialize(new Map<String, Object>{
            'booking_numbers' => new List<String>{bookings[0].Name, bookings[1].Name}
        });

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(inputJson);
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestURI = '/services/apexrest/ConstructionUpdates/';

        Test.startTest();
        EYI_ConstructionUpdateResource.getConstructionUpdates();
        Test.stopTest();
    }

    static testMethod void testMissingInput() {
        // No booking_number or booking_numbers in request
        String inputJson = '{}';

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(inputJson);
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestURI = '/services/apexrest/ConstructionUpdates/';

        Test.startTest();
        EYI_ConstructionUpdateResource.getConstructionUpdates();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400');
        System.assert(RestContext.response.responseBody.toString().contains('booking_number'), 'Expected error message');
    }

    static testMethod void testInvalidJson() {
        // Send invalid JSON
        String inputJson = 'not a json';

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(inputJson);
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestURI = '/services/apexrest/ConstructionUpdates/';

        Test.startTest();
        EYI_ConstructionUpdateResource.getConstructionUpdates();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Expected status code 400');
        System.assert(RestContext.response.responseBody.toString().contains('Invalid input'), 'Expected error message');
    }
}