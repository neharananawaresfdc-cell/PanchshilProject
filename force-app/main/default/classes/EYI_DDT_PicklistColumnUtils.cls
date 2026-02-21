public with sharing class EYI_DDT_PicklistColumnUtils {
    public class PicklistValue {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    
    public static List<PicklistValue> getPicklistValues(String objectName, String fieldName) {
        List<Schema.PicklistEntry> entries = new List<Schema.PicklistEntry>();
        
        // Get global describe map
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        // Get field describe without loading full object describe
        Schema.SObjectField sObjectField = globalDescribe.get(objectName).getDescribe().fields.getMap().get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
        
        // Get picklist values
        entries = fieldDescribe.getPicklistValues();
        entries = getActivePicklistEntries(entries);
        
        List<PicklistValue> picklistValues = new List<PicklistValue>();
        for (Schema.PicklistEntry pvalue : entries) {
            picklistValues.add(new PicklistValue(pvalue.getLabel(), pvalue.getValue()));
        }
        System.Debug('@ picklistValues : '+picklistValues);
        return picklistValues;
    }
    
    
    private static List<Schema.PicklistEntry> getActivePicklistEntries(List<Schema.PicklistEntry> entries) {
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry);
            }
        }
        return activeEntries;
    }
    
}