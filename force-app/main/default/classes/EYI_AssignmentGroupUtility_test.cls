@isTest
public class EYI_AssignmentGroupUtility_test {
    @isTest
    public static void testAssignmentGroup() {
        // Create test Assignment Group
        EYI_Assignment_Group__c assignmentGroup = new EYI_Assignment_Group__c(
            Name = 'Pre-Sales For Lead Enquiry',
            EYI_Team_Lead_TL__c = UserInfo.getUserId(),
            EYI_Presales_Head__c = UserInfo.getUserId()
        );
        insert assignmentGroup;

        // Create test Assignment Group Member
        EYI_Assignment_Group_Member__c member = new EYI_Assignment_Group_Member__c(
            Name = 'Test Member',
            EYI_Assignment_Group__c = assignmentGroup.Id,
            EYI_Assignment_Member__c = UserInfo.getUserId()
        );
        insert member;

        Test.startTest();
        List<EYI_Assignment_Group__c> groupData = EYI_AssignmentGroupUtility.getGroupAssignedData(assignmentGroup.Name);
        System.assertEquals(1, groupData.size(), 'Group data should return one record');

        List<EYI_Assignment_Group_Member__c> escalationUsers = EYI_AssignmentGroupUtility.getEscalationUsers();
       // System.assertEquals(1, escalationUsers.size(), 'Escalation users should return one record');
        Test.stopTest();
    }
}