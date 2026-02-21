public with sharing class EYI_TaskTriggerHelper {
    //This method updates escalation time
    public static void updateEscalationTime(List<Task> taskList) {
        Map<String, EYI_Lead_Enquiry_Escalation_Settings__mdt> callTypeToMDTMap = EYI_CustomMetadataUtility.getEscalationTimeMatrix('Outbound');

        Datetime outboundL1;
        Datetime outboundL2;       
        Integer minutesToAdd = 0;
        for(Task tsk: taskList) {
            for(String callType: callTypeToMDTMap.keyset()) {
               if(callType == 'Outbound'){
                    if(callTypeToMDTMap.get(callType).L1_Escalation_Time__c !=NULL && tsk.ReminderDateTime != NULL){
                        minutesToAdd = (Integer)callTypeToMDTMap.get(callType).L1_Escalation_Time__c;
                        outboundL1 = EYI_BusinessHoursUtility.addBusinessMinutes(tsk.ReminderDateTime,minutesToAdd);  
                    }
                    if(callTypeToMDTMap.get(callType).L2_Escalation_Time__c !=NULL && tsk.ReminderDateTime != NULL){
                        minutesToAdd = (Integer)callTypeToMDTMap.get(callType).L2_Escalation_Time__c;
                        outboundL2 = EYI_BusinessHoursUtility.addBusinessMinutes(tsk.ReminderDateTime, minutesToAdd);
                    }
                }
            }
            tsk.EYI_Outbound_L1_Escalation_Time__c = outboundL1;
            tsk.EYI_Outbound_L2_Escalation_Time__c = outboundL2;
        }
    }
    
    public static void updateEscalationDayRM(List<Task> taskList){
        Datetime outboundL1;
        Datetime outboundL2;       
        Integer minutesToAdd = 0;
        Map<String, EYI_Lead_Enquiry_Escalation_Settings__mdt> callTypeToMDTMap = EYI_CustomMetadataUtility.getEscalationTimeMatrix('Inbound');

        
        for(Task tsk: taskList) {
            for(String callType: callTypeToMDTMap.keyset()) {
                if(tsk.ReminderDateTime != null ){
                    tsk.EYI_RM_T1_Escalation_Time__c = tsk.ReminderDateTime.addDays((Integer) (callTypeToMDTMap.get(callType).L1_Escalation_Time__c));  
                    tsk.EYI_RM_T2_Escalation_Time__c = tsk.ReminderDateTime.addDays( (Integer) (callTypeToMDTMap.get(callType).L2_Escalation_Time__c ));  
                    tsk.EYI_RM_T3_Escalation_Time__c = tsk.ReminderDateTime.addDays((Integer) (callTypeToMDTMap.get(callType).L3_Escalation_Time__c));  
                }
            }
            
            
        }
    }
}