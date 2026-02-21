public without sharing class EYI_LookupRecordInfoController {
    public EYI_LookupRecordInfoController() {
        
    }
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String recordId, List<String> fieldNames) {
        // Get the SObject type from the record ID
        SObjectType sObjectType = Id.valueOf(recordId).getSObjectType();
        
        // Use getName() directly on SObjectType to avoid eager loading
        String objectName = String.valueOf(sObjectType);
        
        // Build the SOQL query dynamically
        String query = 'SELECT ';
        for (String fieldName : fieldNames) {
            query += fieldName + ', ';
        }
        query = query.removeEnd(', ') + ' FROM ' + objectName + ' WHERE Id = :recordId';
        
        // Execute the query and return the results
        List<SObject> records = Database.query(query);
        return records;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getFieldLabels(String recordId) {
        Map<String, String> fieldLabels = new Map<String, String>();
        
        if (String.isNotBlank(recordId)) {
            // Get the object type from the record ID
            SObjectType sObjectType = Id.valueOf(recordId).getSObjectType();
            Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
            
            // Get only field names without loading child relationships
            List<Schema.SObjectField> fieldList = objDescribe.fields.getMap().values();
            
            for (Schema.SObjectField field : fieldList) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                fieldLabels.put(fieldDescribe.getName(), fieldDescribe.getLabel());
            }
        }
        return fieldLabels;
    } 
}