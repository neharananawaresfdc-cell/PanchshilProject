trigger PaymentLineItemTrigger on EYI_Payment_Line_Item__c (after insert, after update, after delete) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_Payment_Line_Item').EYI_Active__c){
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> receiptIds = new Set<Id>();
            for (EYI_Payment_Line_Item__c pli : Trigger.new) {
                if (pli.EYI_Payment_Receipt__c != null) {
                    receiptIds.add(pli.EYI_Payment_Receipt__c);
                }
            }
            if (!receiptIds.isEmpty()) {
                PaymentReceiptHandler.processFromReceiptIds(receiptIds);
            }
        }
        
        if (Trigger.isDelete) {
            Set<Id> receiptIds = new Set<Id>();
            for (EYI_Payment_Line_Item__c pli : Trigger.old) {
                if (pli.EYI_Payment_Receipt__c != null) {
                    receiptIds.add(pli.EYI_Payment_Receipt__c);
                }
            }
            if (!receiptIds.isEmpty()) {
                PaymentReceiptHandler.cleanUpDeletedLineItems(receiptIds);
            }
        }
    }
}