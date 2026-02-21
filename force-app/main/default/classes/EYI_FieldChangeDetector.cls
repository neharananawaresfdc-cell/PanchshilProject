/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Digambar Ganage
**/
public with sharing class EYI_FieldChangeDetector {
    private static final Set<String> SYSTEM_FIELDS = new Set<String>{
        'Id',         // Record ID
        'CreatedDate',// Created Date
        'CreatedById',// Created By
        'LastModifiedDate', // Last Modified Date
        'LastModifiedById', // Last Modified By
        'SystemModstamp'    // System Modstamp
    };

    public static Map<String, Object> getChangedFields(SObject oldRecord, SObject newRecord) {
        Map<String, Object> changedFields = new Map<String, Object>();
        for (SObjectField field : newRecord.getSObjectType().getDescribe().fields.getMap().values()) {
            String fieldName = field.getDescribe().getName();
            if (!SYSTEM_FIELDS.contains(fieldName)) {
                Object oldValue = oldRecord.get(field);
                Object newValue = newRecord.get(field);
                if (oldValue != newValue) {
                    changedFields.put(fieldName, newValue);
                }
            }
        }
        return changedFields;
    }
}