@isTest
public class EYI_CancellationMasterSyncLwcContTest {

    // Mock for the HTTP callout in the controller
    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Users needed for lookups
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sourcingMgr = [SELECT Id FROM User WHERE ProfileId =: p.Id LIMIT 1];
        User relMgr =[SELECT Id FROM User WHERE ProfileId =: p.Id LIMIT 1];
        User closeMgr = [SELECT Id FROM User WHERE ProfileId =: p.Id LIMIT 1];
        User retainedByUser = [SELECT Id FROM User WHERE ProfileId =: p.Id LIMIT 1];
        

        // Create Inventory and REC
        EYI_Inventory__c inv = new EYI_Inventory__c(EYI_Unit_No__c=1, EYI_Inventory_Number__c='INV-001');
        insert inv;

        /*EYI_REC__c rec = new EYI_REC__c(Name='REC1', EYI_RERA_Number__c='RERA123', EYI_Mobile__c='9876543210');
        insert rec;*/

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name='Test Opp', StageName='Prospecting', CloseDate=Date.today().addDays(10), AccountId=acc.Id,
            EYI_SAP_Customer_Number__c='SAP123', EYI_Walk_in_Source__c='Direct Client', EYI_SalesOrder_Number__c='SO123',
            //EYI_Inventory__c=inv.Id, EYI_REC__c=rec.Id,
            EYI_Sourcing_Manager__c = sourcingMgr.Id,
            EYI_Relationship_Manager__c = relMgr.Id,
            EYI_Primary_Closing_Manager__c = closeMgr.Id,
            EYI_Total_Brokerage_Amount_Paid__c=100,
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;

        // Create Synced Quote (note: IsSyncing is not writeable, but SyncedQuoteId on Opp is)
        Quote q = new Quote(
            Name='Test Quote', OpportunityId=opp.Id,
            EYI_Agreement_Value__c=500000, Stamp_Duty__c=10000
        );
        insert q;

        opp.SyncedQuoteId = q.Id;
        update opp;
    }

    @isTest
    static void testCancellationMasterSync_happyPath() {
        
        Opportunity opp = [SELECT Id, EYI_Inventory__c, EYI_REC__c FROM Opportunity LIMIT 1];
        
        EYI_REC__c recInsert = new EYI_REC__c(
                Name='Test REC', EYI_REC_Firm_Name__c='Firm', EYI_Mobile__c='9876543210',
                EYI_Email__c='test1@example.com', EYI_Last_Name__c='TestLast'
            );
        insert recInsert;
        
        // Now your query will always find at least one record:
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        User retainedByUser = [SELECT Id, Name FROM User WHERE Email = 'retain@example.com' LIMIT 1];

        Contact cont = new Contact(LastName = 'TestContact', Email = 'utest@example.com');
		insert cont;
        
        // Create the Queue (Group)
        Group q = new Group();
        q.Name = 'Test Case Queue';
        q.Type = 'Queue';
        //q.DoesIncludeBosses = false;
        insert q;
        
        // Create a Case (cancellation) with all required fields for success
        Case c = new Case(
            EYI_Opportunity__c = opp.Id,
            EYI_Cancellation_Type__c = 'Voluntary',
            EYI_Cancellation_Subtype__c = 'Financial Inability',
            EYI_Cancellation_Remarks__c = 'Some remarks',
            EYI_Date_of_Cancellation_initiated__c = Date.today(),
            EYI_Cancellation_Status__c = 'Inprogress',
            EYI_Cancellation_Commencement__c = 'On Booking',
            EYI_Registration_Status__c = 'Registered',
            EYI_Demanded_Amount_Principal__c = 100,
            EYI_Reversal_Demanded_Amount_Principal__c = 10,
            EYI_Paid_Amount_Principal__c = 90,
            EYI_Refund_Amount_Principal__c = 20,
            EYI_Demanded_Amount_Tax__c = 15,
            EYI_Reversal_Demanded_Amount_Tax__c = 1,
            EYI_Paid_Amount_Tax__c = 14,
            EYI_Refund_Amount_Tax__c = 2,
            EYI_Brokerage_Amount__c = 5,
            EYI_Debit_Note_Principal__c = 3,
            EYI_Credit_Note_Principal__c = 2,
            EYI_Debit_Note_Tax__c = 1,
            EYI_Credit_Note_Tax__c = 1,
            EYI_Reversal_Debit_Note_Principal__c = 0.5,
            EYI_Reversal_Credit_Note_Principal__c = 0.2,
            EYI_Reversal_Debit_Note_Tax__c = 0.1,
            EYI_Reversal_Credit_Note_Tax__c = 0.1,
            EYI_Total_Interest_Accured__c = 25,
            EYI_Interest_Waiver__c = 5,
            EYI_Total_Interest_Charged__c = 20,
            EYI_Brokerage_Waiver__c = 2,
            EYI_Total_Brokerage_Charged__c = 7,
            EYI_Other_Adjustments__c = 3,
            EYI_Forfeit_Amount__c = 1,
            EYI_Total_Received_Amount__c = 200,
            EYI_TotalAmountCharged__c = 250,
            EYI_Total_Refund_Given__c = 50,
            EYI_Retained_by_User__c = retainedByUser.Id,
            ContactId = cont.Id,
            OwnerId = q.Id
        );
        insert c;

        // Insert approval process records (ProcessInstance and Step)
        ProcessInstance pi = new ProcessInstance(
            Status = 'Pending', TargetObjectId = c.Id
        );
        insert pi;
        ProcessInstanceStep step = new ProcessInstanceStep(
            ProcessInstanceId = pi.Id, StepStatus = 'Started', ActorId = UserInfo.getUserId()
        );
        insert step;

        // Mock HTTP callout for EY_SAP_Gateway.postCancellationDetails
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DummySAPGatewayMock(200, 'Success!'));

        EYI_CancellationMasterSyncLwcController.lwcMessage msg =
            EYI_CancellationMasterSyncLwcController.CancellationMasterSync(c.Id);

        Test.stopTest();

        System.assertEquals('s', msg.type, 'Should return success type');
        System.assertEquals('Record Synced Successfully...!', msg.message);
    }

    @isTest
    static void testCancellationMasterSync_missingRequiredFields() {
        // Arrange
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Insert a Case with missing required fields
        Case c = new Case(EYI_Opportunity__c = opp.Id);
        insert c;

        Test.startTest();
        EYI_CancellationMasterSyncLwcController.lwcMessage msg =
            EYI_CancellationMasterSyncLwcController.CancellationMasterSync(c.Id);
        Test.stopTest();

        System.assertEquals('e', msg.type, 'Should return error type for missing fields');
        System.assert(msg.message.contains('EYI_Cancellation_Type__c'), 'Should mention missing field');
    }

    @isTest
    static void testCancellationMasterSync_nullId() {
        // Test null/invalid Id for full branch coverage
        Test.startTest();
        EYI_CancellationMasterSyncLwcController.lwcMessage msg =
            EYI_CancellationMasterSyncLwcController.CancellationMasterSync(null);
        Test.stopTest();
        System.assertEquals('E', msg.type, 'Should return error type for missing record');
        System.assertEquals('Record Id Missing', msg.message, 'Should return missing record message');
    }

    // Dummy callout mock for HTTP callout
    class DummySAPGatewayMock implements HttpCalloutMock {
        Integer statusCode;
        String respBody;
        DummySAPGatewayMock(Integer code, String body) {
            statusCode = code;
            respBody = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(respBody);
            return res;
        }
    }
}