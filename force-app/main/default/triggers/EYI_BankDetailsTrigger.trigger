trigger EYI_BankDetailsTrigger on EYI_Bank_Details__c (after insert, after update, after delete) {
	if(EYI_Trigger_Control__mdt.getInstance('EYI_BankDetailsTrigger').EYI_Active__c){
        if (Trigger.isAfter){
            if(Trigger.isUpdate || Trigger.isInsert){
            	EYI_BrokerVendorSyncLwcController.updatedBankDetails(Trigger.old, Trigger.new);
            }
        } 
        
        //Below code added by Akshay Salunke for Bank Details Sync with SAP
        if (Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate){
                for(EYI_Bank_Details__c bankDetails : Trigger.New){
                    if(bankDetails.Opportunity__c != null){
                        EYI_CustomerMasterSyncLwcController.syncToSAP(bankDetails.Opportunity__c);
                    }
                } 
            }
            if(Trigger.isDelete){
                System.debug('Inside is Delete');
                for(EYI_Bank_Details__c bankDetails : Trigger.Old){
                    if(bankDetails.Opportunity__c != null){
                        System.debug('Inside Delete Bank '+bankDetails.Opportunity__c);
                        EYI_CustomerMasterSyncLwcController.syncToSAP(bankDetails.Opportunity__c);
                    }
                }
            }
        }
	}
}