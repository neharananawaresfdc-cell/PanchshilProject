public without sharing class EYI_DeviationPlanTriggerHandler {
    public static void makeRejectionCommentMandatory(List < EYI_Deviation_Plan__c > newDAFs, Map < Id, EYI_Deviation_Plan__c > oldDAFs) {
        Map < Id, EYI_Deviation_Plan__c > rejectedStatements = new Map < Id, EYI_Deviation_Plan__c > {};
            
            for (EYI_Deviation_Plan__c DAF: newDAFs) {
                /* 
Get the old object record, and check if the approval status 
field has been updated to rejected. If so, put it in a map 
so we only have to use 1 SOQL query to do all checks.
*/
                EYI_Deviation_Plan__c oldDAF = oldDAFs.get(DAF.Id);
                System.debug('All');
                System.debug(oldDAF.EYI_Final_Approval_Status__c);
                System.debug(DAF.EYI_Final_Approval_Status__c);
                //oldDAF.EYI_Final_Approval_Status__c != null && !oldDAF.EYI_Final_Approval_Status__c.contains('Rejected') &&
                if ((DAF.EYI_Final_Approval_Status__c != null && 
                     DAF.EYI_Final_Approval_Status__c.contains('Rejected'))) {
                        System.debug('Found');
                         rejectedStatements.put(DAF.Id, DAF);
                     }
            }
        
        if (!rejectedStatements.isEmpty()) {
            // Get the most recent approval process instance for the object.
            // If there are some approvals to be reviewed for approval, then
            // get the most recent process instance for each object.
            List < Id > processInstanceIds = new List < Id > {};
                
                for (EYI_Deviation_Plan__c DAFs: [SELECT(SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1)
                                                    FROM EYI_Deviation_Plan__c
                                                    WHERE ID IN: rejectedStatements.keySet()
                                                   ]) {
                                                       processInstanceIds.add(DAFs.ProcessInstances[0].Id);
                                                   }
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments.  

            for (ProcessInstance pi: [SELECT TargetObjectId,
                                      (SELECT Id, StepStatus, Comments FROM StepsAndWorkitems ORDER BY CreatedDate DESC LIMIT 1)
                                      FROM ProcessInstance
                                      WHERE Id IN: processInstanceIds
                                      ORDER BY CreatedDate DESC
                                     ]) {
                                        System.debug('Pi Steps');
                                        System.debug(JSON.serializePretty(pi.StepsAndWorkitems));
                                        System.debug(pi.StepsAndWorkitems[0].Id);
                                        System.debug(pi.StepsAndWorkitems[0].Comments);
                                         if ((pi.StepsAndWorkitems[0].Comments == null ||
                                              pi.StepsAndWorkitems[0].Comments.trim().length() == 0)) {
                                                  rejectedStatements.get(pi.TargetObjectId).addError(
                                                  'Please provide reason for rejection in comments');
                                              }
                                     }
        }
    }
}