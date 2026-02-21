public with sharing class EYI_TaskTriggerHandler {
    public static void handleEscalation(List<Task> taskList) {
        List<Task> taskListToUpdate = new List<Task>();
        List<Task> taskListToUpdateRM = new List<Task>();
        for(Task task: taskList) {
            if(task.subject == 'Follow Up' && task.recordTypeId == System.Label.EYI_Presales_Record_Type_Id) {
                taskListToUpdate.add(task);
            }
            if(task.subject == 'Follow Up' && task.recordTypeId == System.Label.EYI_Task_PostSales_Id) {
                taskListToUpdateRM.add(task);
            }
        }
        if(taskListToUpdate.size() > 0) {
            EYI_TaskTriggerHelper.updateEscalationTime(taskListToUpdate);
        }
        if(taskListToUpdateRM.size() > 0) {
            EYI_TaskTriggerHelper.updateEscalationDayRM(taskListToUpdateRM);
        }
    }
}