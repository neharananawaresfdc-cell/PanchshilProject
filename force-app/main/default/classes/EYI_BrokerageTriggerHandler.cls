public without sharing class EYI_BrokerageTriggerHandler {
    public static void makeRejectionCommentMandatory(List<EYI_Brokerage__c> newBrokerages, Map<Id, EYI_Brokerage__c> oldBrokerages) {
        Map<Id, EYI_Brokerage__c> statementsToValidate = new Map<Id, EYI_Brokerage__c>{};
            
        for (EYI_Brokerage__c brokerage : newBrokerages) {

            EYI_Brokerage__c oldBrokerage = oldBrokerages.get(brokerage.Id);
            System.debug('All');
            System.debug(oldBrokerage.EYI_Final_Approval_Status__c);
            System.debug(brokerage.EYI_Final_Approval_Status__c);
            
            // Check for both 'Rejected' and 'Approved'
            if (brokerage.EYI_Final_Approval_Status__c != null && 
                (brokerage.EYI_Final_Approval_Status__c.contains('Rejected') ||
                 brokerage.EYI_Final_Approval_Status__c.contains('Approved'))) {
                    System.debug('Found');
                    statementsToValidate.put(brokerage.Id, brokerage);
                }
        }
        
        if (!statementsToValidate.isEmpty()) {
            List<Id> processInstanceIds = new List<Id>{};
                
            for (EYI_Brokerage__c brokerages : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1)
                                                FROM EYI_Brokerage__c
                                                WHERE ID IN: statementsToValidate.keySet()
                                               ]) {
                // Add null check for ProcessInstances
                if (!brokerages.ProcessInstances.isEmpty()) {
                    processInstanceIds.add(brokerages.ProcessInstances[0].Id);
                }
            }

            for (ProcessInstance pi : [SELECT TargetObjectId,
                                      (SELECT Id, StepStatus, Comments FROM StepsAndWorkitems ORDER BY CreatedDate DESC LIMIT 1)
                                      FROM ProcessInstance
                                      WHERE Id IN: processInstanceIds
                                      ORDER BY CreatedDate DESC
                                     ]) {
                System.debug('Pi Steps');
                System.debug(JSON.serializePretty(pi.StepsAndWorkitems));
                
                // Add null check for StepsAndWorkitems
                if (!pi.StepsAndWorkitems.isEmpty()) {
                    System.debug('Id: ' + pi.StepsAndWorkitems[0].Id);
                    System.debug('Comments: ' + pi.StepsAndWorkitems[0].Comments);

                    if ((pi.StepsAndWorkitems[0].Comments == null ||
                         pi.StepsAndWorkitems[0].Comments.trim().length() == 0)) {
                            statementsToValidate.get(pi.TargetObjectId).addError(
                            'Please provide reason for approval/rejection in comments');
                        }
                }
            }
        }
    }
}