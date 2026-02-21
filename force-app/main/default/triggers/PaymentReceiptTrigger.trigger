trigger PaymentReceiptTrigger on EYI_Payment_Receipt__c (after insert, after update) {
    if(EYI_Trigger_Control__mdt.getInstance('EYI_Payment_Receipt').EYI_Active__c){
       Set<Id> approvedReceiptIds = new Set<Id>();
    
    for (EYI_Payment_Receipt__c pr : Trigger.new) {
        if (pr.EYI_Payment_Status__c == 'APPROVE') {
            approvedReceiptIds.add(pr.Id);
        }
    }

    
    if(trigger.isAfter && trigger.isUpdate){
         PaymentReceiptHandler.handleStatusChange(Trigger.oldMap, Trigger.newMap);
    }
 
    }
    
}