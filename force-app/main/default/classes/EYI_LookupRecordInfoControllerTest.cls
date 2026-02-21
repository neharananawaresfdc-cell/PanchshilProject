@isTest
public class EYI_LookupRecordInfoControllerTest {
    @testSetup
    static void setup() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;
    }

    @isTest
    static void testGetRecords() {
        // Get the test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Define the field names to query
        List<String> fieldNames = new List<String>{'Id', 'Name'};
        
        // Call the getRecords method
        Test.startTest();
        List<SObject> records = EYI_LookupRecordInfoController.getRecords(testAccount.Id, fieldNames);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, records);
        System.assertEquals(1, records.size());
        System.assertEquals(testAccount.Id, records[0].Id);
    }

    @isTest
    static void testGetFieldLabels() {
        // Get the test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Call the getFieldLabels method
        Test.startTest();
        Map<String, String> fieldLabels = EYI_LookupRecordInfoController.getFieldLabels(testAccount.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, fieldLabels);
    }
}