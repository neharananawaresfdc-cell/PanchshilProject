trigger EYI_RecTrigger on EYI_REC__c (after insert, after update) {
	if(EYI_Trigger_Control__mdt.getInstance('EYI_RecTrigger').EYI_Active__c){
        if (Trigger.isAfter && Trigger.isUpdate) {
            for (EYI_REC__c rec : Trigger.new) {
                EYI_REC__c oldRec = Trigger.oldMap.get(rec.Id);
                
                if (EYI_BrokerVendorSyncLwcController.hasSignificantChanges(oldRec, rec) && rec.EYI_REC_Vendor_Code__c != null) {
                    EYI_BrokerVendorSyncLwcController.syncToSAP(rec.Id);
                }
            }
        }
	}
}