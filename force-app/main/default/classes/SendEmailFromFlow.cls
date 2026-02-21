public with sharing class SendEmailFromFlow {
    
    @InvocableMethod(label='Send Emails from Flow')
    public static void sendEmails(List<String> recordIds) {
        system.debug('recordIds : '+recordIds);
        String recordIdsString = String.join(recordIds, ',');
        List<String> InventoryRecordIds = recordIdsString.split(',');
        System.debug('InventoryRecordIds : '+InventoryRecordIds);
        if(InventoryRecordIds.size() > 0){
          List<EYI_Inventory__c> oppList = [SELECT Id,EYI_Opportunity__r.Name, EYI_Opportunity__r.EYI_Email__c FROM EYI_Inventory__c WHERE Id IN :InventoryRecordIds];
            System.debug('oppList : '+oppList);
            
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for (EYI_Inventory__c env : oppList) {
            if (env.EYI_Opportunity__r.EYI_Email__c != null) {
                String oppName = env.EYI_Opportunity__r.Name; // Replace this with your actual Opportunity Name
				String body = 'Hi ' + oppName + ',\n'
                + 'Please complete overdue payment.\n\n'
                + 'Thanks,\n'
                + 'Panchshil Team.';
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{env.EYI_Opportunity__r.EYI_Email__c});
                email.setSubject('Overdue Payment Remainder');
                //email.setPlainTextBody('Please complete overdue payment');
                email.setPlainTextBody(body);
                messages.add(email);
            }
        }

        if (!messages.isEmpty()) {
            Messaging.sendEmail(messages);
        }  
        }
    }
}