trigger EYI_BaseOfTargetSettingCalculationTr on EYI_Demand__c (after insert,after update) {
    if(Trigger.isInsert || Trigger.isUpdate)
        EYI_BaseOfTargetSettingHandler.calculateBasedOnDate(Trigger.new, Trigger.OldMap);
}