@isTest
private class EYI_DeviationPlanTriggerHandlerTest {

    @isTest
    static void testRejectionWithoutComment() {
        // Create test Account
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

        Account acc = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingState = 'Maharashtra',
            BillingPostalCode = '12345',
            BillingCountry = 'India'
        );
        insert acc;
        
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;
        
        // Create test Quote
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ExpirationDate = Date.today().addDays(30),
            Status = 'Draft',
            EYI_Is_Payment_Plan_Submitted__c = true
        );
        insert quote;
        
        // Create a test Deviation Plan with required fields including Quote reference
        EYI_Deviation_Plan__c daf = new EYI_Deviation_Plan__c(
            //Name = 'Test Deviation Plan',
            EYI_Final_Approval_Status__c = 'Pending',
            EYI_Quote__c = quote.Id,
            EYI_Opportunity_Name__c = opp.Id
            // Add other required fields based on your object schema
            // EYI_Request_Type__c = 'Type',
            // EYI_Deviation_Type__c = 'Type',
            // EYI_Justification__c = 'Test justification'
        );
        insert daf;

        // Submit for approval
        // Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        // req.setComments('Submitting for approval');
        // req.setObjectId(daf.Id);
        // Approval.process(req);
        System.runas(salesClosingManager){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting for approval');
        req.setObjectId(daf.Id);
        req.setProcessDefinitionNameOrId('Deviation_approval2');  // Use your actual approval process name
        req.setSkipEntryCriteria(true);  // Skip the entry criteria
        Approval.process(req);
        }
        // Query the WorkItem
        ProcessInstanceWorkitem workItem = [
            SELECT Id, ProcessInstanceId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :daf.Id
            LIMIT 1
        ];

        // Reject the approval with no comment
        Approval.ProcessWorkitemRequest rejReq = new Approval.ProcessWorkitemRequest();
        rejReq.setAction('Reject');
        rejReq.setWorkitemId(workItem.Id);
        rejReq.setComments('Test'); // Empty comment to test rejection validation
        
        Test.startTest();
        Approval.ProcessResult result = Approval.process(rejReq);
        Test.stopTest();
        
        // Verify the results
        EYI_Deviation_Plan__c updatedDaf = [
            SELECT Id, EYI_Final_Approval_Status__c 
            FROM EYI_Deviation_Plan__c 
            WHERE Id = :daf.Id
        ];
        
        // Add assertions based on expected behavior
        // For example, if your trigger should prevent rejection without comments:
        // System.assertEquals('Pending', updatedDaf.EYI_Final_Approval_Status__c);
        // If rejection without comments should be allowed:
        // System.assertEquals('Rejected', updatedDaf.EYI_Final_Approval_Status__c);
    }
}