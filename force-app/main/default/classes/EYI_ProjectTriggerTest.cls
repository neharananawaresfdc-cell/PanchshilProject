@isTest
private class EYI_ProjectTriggerTest {

    @isTest
    static void testAfterInsertTrigger() {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project Insert',
            EYI_Project_Code__c = 'PRJ001',
            EYI_SAP_Salesorg__c = '1000',
            EYI_SAP_Plant_Code__c = '1100'
        );

        Test.startTest();
        insert project;
        Test.stopTest();

        EYI_Project__c result = [SELECT EYI_Project_Code__c FROM EYI_Project__c WHERE Id = :project.Id];
        System.assertEquals('PRJ001', result.EYI_Project_Code__c);
    }

    @isTest
    static void testAfterUpdateTrigger_CodeUnchanged() {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Before Update',
            EYI_Project_Code__c = 'PRJ002',
            EYI_SAP_Salesorg__c = '1000',
            EYI_SAP_Plant_Code__c = '1100'
        );
        insert project;

        project.Name = 'After Update'; // EYI_Project_Code__c remains the same

        Test.startTest();
        update project;
        Test.stopTest();

        EYI_Project__c updatedProject = [SELECT Name FROM EYI_Project__c WHERE Id = :project.Id];
        System.assertEquals('After Update', updatedProject.Name);
    }

    @isTest
    static void testAfterUpdateTrigger_CodeChanged() {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Initial Record',
            EYI_Project_Code__c = 'PRJ003',
            EYI_SAP_Salesorg__c = '1000',
            EYI_SAP_Plant_Code__c = '1100'
        );
        insert project;

        project.EYI_Project_Code__c = 'PRJ004'; // Code has changed — sync logic is skipped

        Test.startTest();
        update project;
        Test.stopTest();

        EYI_Project__c changedProject = [SELECT EYI_Project_Code__c FROM EYI_Project__c WHERE Id = :project.Id];
        System.assertEquals('PRJ004', changedProject.EYI_Project_Code__c);
    }
}