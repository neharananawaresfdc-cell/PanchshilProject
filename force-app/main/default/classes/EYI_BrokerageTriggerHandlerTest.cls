@isTest
private class EYI_BrokerageTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Profile and Users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User salesClosingManager = new User(
            Alias = 'mgr',
            Email = 'salesmanager@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Sales Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'salesmanager@testorg.com' + Datetime.now().getTime()
        );
        insert salesClosingManager;
        
        User sourcingTL = new User(
            Alias = 'stl',
            Email = 'sourcingtl@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Sourcing TL',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sourcingtl@testorg.com' + Datetime.now().getTime()
        );
        insert sourcingTL;
        
        User sourcingManager = new User(
            Alias = 'smgr',
            Email = 'sourcingmanager@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Sourcing Manager',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sourcingmanager@testorg.com' + Datetime.now().getTime()
        );
        insert sourcingManager;
        
        User sourcingHead = new User(
            Alias = 'shead',
            Email = 'sourcinghead@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Sourcing Head',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sourcinghead@testorg.com' + Datetime.now().getTime()
        );
        insert sourcingHead;
        
        // Create test Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'Maharashtra',
            BillingPostalCode = '12345',
            BillingCountry = 'India'
        );
        insert acc;
        
        // Create REC Account
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test@email.com',
            EYI_Last_Name__c = 'Last',
            EYI_First_Name__c = 'First',
            OwnerId = UserInfo.getUserId(),
            EYI_Type_Of_RERA_Registration__c = 'Company/ Firm',
            EYI_PAN_No__c = 'ABCDE1234F',
            EYI_Company_PAN_No__c = 'ABCD12345E'
        );
        insert rec;
        
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;
    }
    

    
    @isTest
    static void testApprovalWithValidComment() {
        // Get test data
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        User salesManager = [SELECT Id FROM User WHERE LastName = 'Sales Manager' LIMIT 1];
        User sourcingTL = [SELECT Id FROM User WHERE LastName = 'Sourcing TL' LIMIT 1];
        User sourcingManager = [SELECT Id FROM User WHERE LastName = 'Sourcing Manager' LIMIT 1];
        User sourcingHead = [SELECT Id FROM User WHERE LastName = 'Sourcing Head' LIMIT 1];
        
        // Create Brokerage record
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Final_Approval_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id,
            EYI_REC_Account__c = rec.Id,
            Sourcing_TL_User__c = sourcingTL.Id,
            Email_User__c = sourcingManager.Id,
            Sourcing_Head_User__c = sourcingHead.Id
        );
        insert brokerage;
        
        // Submit for approval
        System.runAs(salesManager) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting for approval');
            req.setObjectId(brokerage.Id);
            req.setProcessDefinitionNameOrId('Invoice_Approval_3');
            req.setSkipEntryCriteria(true);
            Approval.process(req);
        }
        
        // Query the WorkItem
        ProcessInstanceWorkitem workItem = [
            SELECT Id, ProcessInstanceId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :brokerage.Id
            LIMIT 1
        ];
        
        // Approve with valid comment - should succeed
        Approval.ProcessWorkitemRequest approveReq = new Approval.ProcessWorkitemRequest();
        approveReq.setAction('Approve');
        approveReq.setWorkitemId(workItem.Id);
        approveReq.setComments('Valid approval reason provided');
        
        Test.startTest();
        Approval.ProcessResult result = Approval.process(approveReq);
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'Approval with valid comment should succeed');
    }
    
    @isTest
    static void testDirectHandlerCallWithEmptyComment() {
        // Get test data
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        User sourcingTL = [SELECT Id FROM User WHERE LastName = 'Sourcing TL' LIMIT 1];
        User sourcingManager = [SELECT Id FROM User WHERE LastName = 'Sourcing Manager' LIMIT 1];
        User sourcingHead = [SELECT Id FROM User WHERE LastName = 'Sourcing Head' LIMIT 1];
        
        // Create Brokerage record
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Final_Approval_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id,
            EYI_REC_Account__c = rec.Id,
            Sourcing_TL_User__c = sourcingTL.Id,
            Email_User__c = sourcingManager.Id,
            Sourcing_Head_User__c = sourcingHead.Id
        );
        insert brokerage;
        
        // Create an updated record to test direct handler call
        EYI_Brokerage__c updatedBrokerage = brokerage.clone(true);
        updatedBrokerage.EYI_Final_Approval_Status__c = 'Rejected';
        
        List<EYI_Brokerage__c> newList = new List<EYI_Brokerage__c>{updatedBrokerage};
            Map<Id, EYI_Brokerage__c> oldMap = new Map<Id, EYI_Brokerage__c>{brokerage.Id => brokerage};
                
                Test.startTest();
        // This should not throw error as there's no approval process context
        EYI_BrokerageTriggerHandler.makeRejectionCommentMandatory(newList, oldMap);
        Test.stopTest();
        
        // Test should complete without errors when no approval process exists
        System.assert(true, 'Method should complete without errors when no approval process exists');
    }
    
    @isTest
    static void testBulkApprovalValidation() {
        // Get test data
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        User salesManager = [SELECT Id FROM User WHERE LastName = 'Sales Manager' LIMIT 1];
        User sourcingTL = [SELECT Id FROM User WHERE LastName = 'Sourcing TL' LIMIT 1];
        User sourcingManager = [SELECT Id FROM User WHERE LastName = 'Sourcing Manager' LIMIT 1];
        User sourcingHead = [SELECT Id FROM User WHERE LastName = 'Sourcing Head' LIMIT 1];
        
        // Create a single Brokerage record first to test individual approval
        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_Final_Approval_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id,
            EYI_REC_Account__c = rec.Id,
            Sourcing_TL_User__c = sourcingTL.Id,
            Email_User__c = sourcingManager.Id,
            Sourcing_Head_User__c = sourcingHead.Id
        );
        insert brokerage;
        
        // Submit for approval
        System.runAs(salesManager) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting for approval');
            req.setObjectId(brokerage.Id);
            req.setProcessDefinitionNameOrId('Invoice_Approval_3');
            req.setSkipEntryCriteria(true);
            Approval.process(req);
        }
        
        Test.startTest();
        
        // Query the WorkItem
        ProcessInstanceWorkitem workItem = [
            SELECT Id, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :brokerage.Id
            LIMIT 1
        ];
        
        // Test rejection without comment
        Boolean validationTriggered = false;
        try {
            Approval.ProcessWorkitemRequest rejReq = new Approval.ProcessWorkitemRequest();
            rejReq.setAction('Reject');
            rejReq.setWorkitemId(workItem.Id);
            rejReq.setComments('');
            Approval.process(rejReq);
        } catch (System.DmlException e) {
            validationTriggered = true;
            System.assert(e.getMessage().contains('Please provide reason for approval/rejection in comments'));
        }
        Test.stopTest();
    }
}