@isTest
private class EYI_ProjectSyncToMobileAppTest {

    @TestSetup
    static void setupProjectData() {
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Sync Project',
            EYI_Project_Code__c = 'PRJ_TEST_001',
            EYI_SAP_Salesorg__c = '1000',
            EYI_SAP_Plant_Code__c = '1100',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_Project_Status__c = 'Teaser',
            EYI_Project_Location__c = 'Mumbai',
            EYI_Configuration_Types__c = '2BHK',
            EYI_Project_Description__c = 'Test description',
            EYI_Price_Onwards__c = '15000000',
            EYI_Project_Size_In_Sq_Mtr__c = 120,
            EYI_Project_Size_In_Sq_Ft__c = 1292,
            EYI_Rera_Carpet_Area_In_Sq_Ft__c = 1100,
            EYI_Number_Of_Towers__c = 2,
            EYI_Number_Of_Units__c = 120,
            EYI_Rera_Number__c = 'RERA123'
            //EYI_Land_Area__c = 5000
        );
        insert project;
       
    }

    @isTest
    static void testProjectSyncCalloutFlow() {
        // Register your existing mock class
        Test.setMock(HttpCalloutMock.class, new EYI_ProjectSyncToMobileApp_Mock());

        EYI_Project__c insertedProject = [
            SELECT Id FROM EYI_Project__c LIMIT 1
        ];

        // Invoke the method that triggers @future callout
        Test.startTest();
        EYI_ProjectSyncToMobileApp.getProjectDetails(new List<EYI_Project__c>{insertedProject}, true);
        Test.stopTest();

        // Optional: verify if project was updated with mocked ID
        EYI_Project__c updated = [SELECT EYI_Project_Code__c FROM EYI_Project__c WHERE Id = :insertedProject.Id];
        System.assertEquals('1234567890', updated.EYI_Project_Code__c); // Based on your mock response
    }
    @isTest
    static void testTowerSyncCalloutFlow() {
        EYI_Project__c insertedProject = [
            SELECT Id FROM EYI_Project__c LIMIT 1
        ];
        EYI_Tower__c towerObj = new EYI_Tower__c();
        towerObj.Name='Tower 1';
        towerObj.EYI_Project_Name__c = insertedProject.Id;
        insert towerObj;
        Test.setMock(HttpCalloutMock.class, new EYI_ProjectSyncToMobileApp_Mock());
        
        Test.startTest();
        EYI_ProjectSyncToMobileApp.syncTowersToMobileApp(new Set<Id>{towerObj.Id});
        Test.stopTest();
	}
}