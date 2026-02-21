public with sharing class EYI_SAP_AgeingOverdueReportController {
    public static List<Map<String, String>> getReportData(Map<String, String> filters) {
        List<Map<String, String>> records = new List<Map<String, String>>();
        
        // Dummy Data (Replace this with actual query logic)
        for (Integer i = 1; i <= 5; i++) {
            Map<String, String> record = new Map<String, String>();
            record.put('SalesOrg', String.valueOf(i));
            record.put('Segment', 'C200');
            record.put('profitCenter', 'C130C2C130');
            records.add(record);
        }

        return records;
    }
}