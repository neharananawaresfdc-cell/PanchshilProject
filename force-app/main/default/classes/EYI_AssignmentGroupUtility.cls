/**
 * @description       : 
 * @author            : Digambar Ganage 
 * @group             : EY Notification Framework
 * @last modified on  : 11-21-2024
 * @last modified by  : Digambar Ganage 
**/
public with sharing class EYI_AssignmentGroupUtility {
    public static List<EYI_Assignment_Group__c> getGroupAssignedData(String groupName) {
        List<EYI_Assignment_Group__c> assignedGroupList = new List<EYI_Assignment_Group__c>();
        assignedGroupList = [SELECT Id, Name, EYI_Team_Lead_TL__c,EYI_Team_Lead_TL__r.Email ,EYI_Presales_Head__c,EYI_Presales_Head__r.Email
                                FROM EYI_Assignment_Group__c 
                                WHERE Name =: groupName
                                LIMIT 1];
        return assignedGroupList;
    }

    public static List<EYI_Assignment_Group_Member__c> getEscalationUsers() {
        List<EYI_Assignment_Group_Member__c> assignedGroupList = new List<EYI_Assignment_Group_Member__c>();
        assignedGroupList = [SELECT Id, Name, EYI_Assignment_Member__r.Email 
                                FROM EYI_Assignment_Group_Member__c 
                                WHERE EYI_Assignment_Group__r.Name =: System.Label.EYI_PresalesL3EscalationGroupLabel
                                LIMIT 1];
        return assignedGroupList;
    }

}