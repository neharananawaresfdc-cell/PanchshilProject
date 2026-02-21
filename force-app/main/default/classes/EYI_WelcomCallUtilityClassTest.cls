@isTest
public class EYI_WelcomCallUtilityClassTest {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create Project
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'TEST001'
        );
        insert project;
        
        // Create Inventory
        EYI_Inventory__c inventory = new EYI_Inventory__c(
            Name = 'Test Inventory',
            EYI_Inventory_Number__c = 'INV001',
            EYI_Project__c = project.Id
        );
        insert inventory;
        
        // Create User for Relationship Manager
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User relationshipManager = new User(
            Alias = 'rmgr',
            Email = 'rmgr@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'rmgr@test' + System.currentTimeMillis() + '.com'
        );
        insert relationshipManager;
        
        // Create Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAccount.Id,
            EYI_First_Name__c = 'John',
            EYI_Last_Name__c = 'Doe',
            EYI_Project_Enquired__c = project.Id,
            EYI_Inventory__c = inventory.Id,
            EYI_Relationship_Manager__c = relationshipManager.Id
        );
        insert testOpp;
        
        // Create Second Applicant with required fields for the flow
        EYI_Applicants__c secondApplicant = new EYI_Applicants__c(
            Name = 'Second Applicant',
            Opportunity__c = testOpp.Id,
            EYI_Applicant_No__c = 2,
            Verified_AADHAR_Card_Name__c = 'Second Applicant Name',
            EYI_Last_Name__c = 'Applicant'  // Required for the flow that creates Contact
        );
        insert secondApplicant;
    }
    
    @isTest
    static void testGetOppRec_Success() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Opportunity result = EYI_WelcomCallUtilityClass.getOppRec(testOpp.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Opportunity should not be null');
        System.assertEquals(testOpp.Id, result.Id, 'Opportunity Id should match');
        System.assertEquals('Test Opportunity', result.Name, 'Opportunity Name should match');
        System.assertEquals('John', result.EYI_First_Name__c, 'First Name should match');
        System.assertEquals('Doe', result.EYI_Last_Name__c, 'Last Name should match');
    }
    
    @isTest
    static void testGetOppRec_InvalidId() {
        // Use a fake ID
       // String fakeId = '006000000000000';
        Account acc = new Account();
        acc.Name ='Test Account';
        insert acc;
        Test.startTest();
        try {
            EYI_WelcomCallUtilityClass.getOppRec(acc.Id);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetSecondApp_Success() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        EYI_Applicants__c result = EYI_WelcomCallUtilityClass.getSecondApp(testOpp.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Second applicant should not be null');
        System.assertEquals('Second Applicant', result.Name, 'Second applicant name should match');
        System.assertEquals('Second Applicant Name', result.Verified_AADHAR_Card_Name__c, 'Verified name should match');
    }
    
    @isTest
    static void testGetSecondApp_NoSecondApplicant() {
        // Create opportunity without second applicant
        Account testAccount = new Account(Name = 'Test Account 2');
        insert testAccount;
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAccount.Id
        );
        insert testOpp;
        
        Test.startTest();
        try {
            EYI_WelcomCallUtilityClass.getSecondApp(testOpp.Id);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetSecondApp_InvalidId() {
        // Use a fake ID
        //String fakeId = '006000000000000';
        Account acc = new Account();
        acc.Name ='Test Account';
        insert acc;
        
        Test.startTest();
        try {
            EYI_WelcomCallUtilityClass.getSecondApp(acc.Id);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
}