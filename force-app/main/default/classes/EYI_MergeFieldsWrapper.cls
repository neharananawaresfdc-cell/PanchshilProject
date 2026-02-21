public with sharing class EYI_MergeFieldsWrapper {
    public String recordId { get; set; }
    public String fieldName { get; set; }
    public String fieldValue { get; set; }
    public String replaceField { get; set; }
    // Constructor to initialize the class with values
    public EYI_MergeFieldsWrapper(String recordId, String fieldName, String fieldValue,String replaceField) {
        this.recordId = recordId;
        this.fieldName = fieldName;
        this.fieldValue = fieldValue;
        this.replaceField = replaceField;
    }
}