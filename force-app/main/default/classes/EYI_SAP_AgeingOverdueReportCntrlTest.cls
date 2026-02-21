@isTest
private class EYI_SAP_AgeingOverdueReportCntrlTest {

    @isTest
    static void testGetReportData() {
        // Prepare dummy filters
        Map<String, String> filters = new Map<String, String>{
            'Segment' => 'C200',
            'SalesOrg' => '1'
        };

        // Call the method
        List<Map<String, String>> result = EYI_SAP_AgeingOverdueReportController.getReportData(filters);

        // Assert that the dummy data is returned correctly
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(5, result.size(), 'Should return 5 records as per the loop');

        for (Map<String, String> rec : result) {
            System.assertEquals('C200', rec.get('Segment'), 'Segment should be C200');
            System.assert(rec.containsKey('SalesOrg'), 'SalesOrg should be present');
            System.assert(rec.containsKey('profitCenter'), 'profitCenter should be present');
        }
    }
}