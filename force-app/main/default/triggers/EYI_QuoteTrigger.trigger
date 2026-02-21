trigger EYI_QuoteTrigger on Quote (before insert, before update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_QuoteTrigger').EYI_Active__c){
	if(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate)){
        /*for (Quote q : Trigger.new) {
            if (q.EYI_Agreement_Value__c != null) {
                q.EYI_Agreement_Value_in_Words__c = EYI_QuoteTriggerHandler.convert(q.EYI_Agreement_Value__c);
            }
        }*/
        EYI_QuoteTriggerHandler.convert(Trigger.new);
    }
    }
}