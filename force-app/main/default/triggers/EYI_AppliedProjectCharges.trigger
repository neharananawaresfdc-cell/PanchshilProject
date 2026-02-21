trigger EYI_AppliedProjectCharges on EYI_Applied_Project_Charge__c (before insert, before update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_AppliedProjectCharges').EYI_Active__c){
    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        EYI_AppliedProjectChargesHandler.convert(trigger.new);
    }
    }
}