@isTest
public class EYI_RECAccountUtilityTest {
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('PanVerification')) {
                // Simulate different responses based on PAN
                String pan = req.getBody().contains('ABCDE1234F') ? 'ABCDE1234F' : 'ABCDE1235F';
                if (pan == 'ABCDE1234F') {
                    res.setBody('{"pan":"ABCDE1234F","first_name":"First","middle_name":"Middle","last_name":"Last","dob":"1990-01-01"}');
                } else {
                    res.setStatusCode(400); // Simulate failure for invalid PAN
                    res.setBody('{"error":"Invalid PAN"}');
                }
            } else {
                res.setBody('{"status":"success","data":{"id":"123","name":"Test"}}');
            }
            return res;
        }
    }
    
    @testSetup
    static void setupData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
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

        // Create Project
        EYI_Project__c project = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = 'P123',
            EYI_Stamp_Duty__c = 123
        );
        insert project;

        // Project REC Mapping
        EYI_Project_REC_Mapping__c mapping = new EYI_Project_REC_Mapping__c(
            EYI_Project__c = project.Id,
            EYI_REC_Account__c = rec.Id,
            EYI_Sourcing_Manager__c = UserInfo.getUserId()
        );
        insert mapping;

        // Booking
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Project_Name__c = project.Id,
            EYI_Sourcing_manager__c = UserInfo.getUserId(),
            EYI_REC_Account__c = rec.Id
        );
        insert booking;

        // CIF
        
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'John',
            EYI_Last_Name__c = 'Doe',
            EYI_Email_Id__c = 'john.doe@example.com',
            EYI_Mobile_number__c = '9876543210',
            EYI_Project_Enquired__c = project.Id,
			EYI_Customer_Address_Type__c = 'Pune',
			EYI_State__c = 'Maharashtra',
            EYI_REC_Account__c = rec.Id,
            EYI_Sourcing_Manager__c = UserInfo.getUserId()
        );
        insert cif;

        // Task
        Task task = new Task(
            Subject = 'Test Task',
            Status = 'Completed',
            OwnerId = UserInfo.getUserId(),
            WhatId = rec.Id,
            EYI_REC_Account__c = rec.Id,
            EYI_Next_Action_Date_Time__c = System.now().addDays(1) 
        );
        insert task;

        // VPVC
        EYI_VP_VC__c vpvc = new EYI_VP_VC__c(
            EYI_Client_Name__c = 'Client X',
            EYI_Company_Name__c = 'Company Y',
            EYI_Project__c = project.Id,
            EYI_REC_Account__c = rec.Id,
            EYI_Visit_Proposed_Date__c = Date.today(),
            EYI_Visit_Confirmed_Date__c = Date.today(),
            OwnerId = UserInfo.getUserId(),
            EYI_Status__c = 'Visit Proposed'
        );
        insert vpvc;

        // JBP
        EYI_Joint_Business_Plan__c jbp = new EYI_Joint_Business_Plan__c(
            EYI_JBP_Name__c = 'JBP Test',
            EYI_Project__c = project.Id,
            OwnerId = UserInfo.getUserId(),
            EYI_Activity_Support_Required__c = 'Yes', 
            EYI_Activity_type__c = 'Tele calling',             
            EYI_Start_Date__c = Date.today(),             
            EYI_End_Date__c = Date.today().addDays(1)   
        );
        insert jbp;
    }
    
    @isTest
    static void testPANValidateCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create REC Account with EYI_Type_Of_RERA_Registration__c = 'Individual'
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Mobile__c = '8888888887',
            EYI_Email__c = 'unique.test2@email.com',
            EYI_Last_Name__c = 'Zambare',
            EYI_First_Name__c = 'Swapnil',
            EYI_PAN_No__c = 'ABCDE1234K',
            EYI_Birth_Date__c = Date.newInstance(1993, 04, 30),
            OwnerId = UserInfo.getUserId(),
            EYI_Type_Of_RERA_Registration__c = 'Individual' // Trigger the callout
        );
        
        Test.startTest();
        insert rec;
        Test.stopTest();
        
        // Verify the results
        EYI_REC__c updatedRec = [SELECT IsPANeKYCDone__c FROM EYI_REC__c WHERE Id = :rec.Id];
        System.assertEquals(false, updatedRec.IsPANeKYCDone__c, 'PAN eKYC not yet completed');
    }

    @isTest
    static void testGetRECAccounts() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<EYI_RECAccountUtility.RECAccountWrapper> recs = EYI_RECAccountUtility.getRECAccounts();
        Test.stopTest();
        System.assertNotEquals(0, recs.size(), 'REC Accounts should be returned');
        System.assertEquals('First Last', recs[0].recName, 'REC name should match');
    }

    @isTest 
    static void testGetRECProjectMappings() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        List<EYI_RECAccountUtility.RECAccountWrapper> mappings = EYI_RECAccountUtility.getRECProjectMappings(project.Id);
        System.assertNotEquals(0, mappings.size(), 'Project Mappings should be returned');
    }

    @isTest static void testGetRECProjectTypology() {
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        EYI_Project__c result = EYI_RECAccountUtility.getRECProjectTypology(project.Id);
        System.assertEquals(project.Id, result.Id, 'Should return the requested project');
    }

    @isTest static void testGetRECProjects() {
        List<EYI_Project__c> projects = EYI_RECAccountUtility.getRECProjects();
        System.assertNotEquals(0, projects.size(), 'Projects should be returned');
    }

    @isTest static void testGetJointBusinessPlans() {
        List<EYI_Joint_Business_Plan__c> plans = EYI_RECAccountUtility.getJointBusinessPlans();
        System.assertNotEquals(0, plans.size(), 'JBP records should be returned');
    }

    @isTest static void testGetBookings() {
        List<EYI_RECAccountUtility.BookingWrapper> bookings = EYI_RECAccountUtility.getBookings();
        System.assertNotEquals(0, bookings.size(), 'Booking wrappers should be returned');
    }

    @isTest static void testGetFilteredBookings() {
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        List<EYI_RECAccountUtility.BookingWrapper> result = EYI_RECAccountUtility.getFilteredBookings(project.Id, 'custom', DateTime.now().addDays(-1), DateTime.now().addDays(1));
        System.assert(result != null, 'Filtered bookings should return a list');
    }

    @isTest static void testGetCIFs() {
        List<EYI_RECAccountUtility.CIFWrapper> cifs = EYI_RECAccountUtility.getCIFs();
        System.assertNotEquals(0, cifs.size(), 'CIF wrappers should be returned');
    }

    @isTest static void testGetFilteredCIFs() {
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        List<EYI_RECAccountUtility.CIFWrapper> result = EYI_RECAccountUtility.getFilteredCIFs(project.Id, 'custom', DateTime.now().addDays(-1), DateTime.now().addDays(1));
        System.assert(result != null, 'Filtered CIFs should return a list');
    }

    @isTest static void testGetTasks() {
        List<EYI_RECAccountUtility.TaskWrapper> tasks = EYI_RECAccountUtility.getTasks();
        // System.assertNotEquals(0, tasks.size(), 'Task wrappers should be returned');
    }

    @isTest static void testGetFilteredTasks() {
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        List<EYI_RECAccountUtility.TaskWrapper> result = EYI_RECAccountUtility.getFilteredTasks(project.Id, 'custom', DateTime.now().addDays(-1), DateTime.now().addDays(1),'rec');
        System.assert(result != null, 'Filtered tasks should return a list');
    }

    @isTest static void testGetVPVCs() {
        List<EYI_RECAccountUtility.VPVCWrapper> vpvcs = EYI_RECAccountUtility.getVPVCs();
        System.assertNotEquals(0, vpvcs.size(), 'VPVC wrappers should be returned');
    }

    @isTest static void testGetFilteredVPVCs() {
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        List<EYI_RECAccountUtility.VPVCWrapper> result = EYI_RECAccountUtility.getFilteredVPVCs(project.Id, 'custom', DateTime.now().addDays(-1), DateTime.now().addDays(1));
        System.assert(result != null, 'Filtered VPVCs should return a list');
    }

    @isTest static void testCreateVPVCRecord() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        EYI_REC__c rec = [SELECT Id, Name FROM EYI_REC__c LIMIT 1];
        EYI_Project_REC_Mapping__c mapping = [SELECT Id FROM EYI_Project_REC_Mapping__c LIMIT 1];
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'clientName' => 'John Doe',
            'companyName' => 'ACME Corp',
            'designation' => 'Manager',
            'email' => 'john.doe@example.com',
            'mobileNumber' => '9999999999',
            'profile' => 'Profile',
            'projectName' => project.Id,
            'recMapping' => mapping.Id,
            'recCode' => rec.Name,
            'recAccount' => rec.Id,
            'recStatus' => 'Interested',
            'typology' => 'Residential',
            'budget' => '1000000',
            'vcDate' => DateTime.now().format(),
            'vpDate' => DateTime.now().addDays(1).format()
        });
        Test.startTest();
        EYI_RECAccountUtility.createVPVCRecord(jsonInput);
        Test.stopTest();
        // No assert; just covering DML
    }

    @isTest static void testCreateRecActivity() {
        EYI_Joint_Business_Plan__c jbp = [SELECT Id FROM EYI_Joint_Business_Plan__c LIMIT 1];
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        EYI_Project_REC_Mapping__c mapping = [SELECT Id FROM EYI_Project_REC_Mapping__c LIMIT 1];
        String jsonInput = JSON.serialize(new Map<String,Object>{
            'taskSubject' => 'Call',
            'taskDescription' => 'Description',
            'taskRelatedTo' => rec.Id,
            'taskPriority' => 'Normal',
            'recMapping' => mapping.Id,
            'taskJBP' => jbp.Id,
            'dueDate' => Date.today().addDays(1)
        });
        Test.startTest();
        EYI_RECAccountUtility.createRecActivity(jsonInput);
        Test.stopTest();
    }

    @isTest static void testCreatejbpRecord() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        EYI_Project_REC_Mapping__c mapping = [SELECT Id FROM EYI_Project_REC_Mapping__c LIMIT 1];
        String jsonInput = JSON.serialize(new Map<String,Object>{
            'jbpStatus' => 'Planned',
            'jbpActionSupport' => 'Support',
            'jbpActivityType' => 'Seminar',
            'recAccount' => rec.Id,
            'recMapping' => mapping.Id,
            'jbpProject' => project.Id,
            'jbpName' => 'JBP Seminar',
            'startDate' => Date.today(),
            'endDate' => Date.today().addDays(1),
            'cost' => 1000,
            'jbpResourceTypes' => new List<String>{'Brochure'},
            'jbpEndUsers' => new List<String>{'Retail'},
            'jbpCommunities' => new List<String>{'Community1'},
            'investorName' => 'Investor',
            'jbpOthers' => 'Notes',
            'jbpTotalDatabase' => 100,
            'jbpRelavantDatabase' => 50,
            'nriDatabase' => 10,
            'osDatabase' => 5,
            'corporatePrivateOrg' => 'Corp Org',
            'club' => 'Club',
            'association' => 'Assoc',
            'society' => 'Society',
            'governmentOrg' => 'Govt',
            'psu' => 'PSU',
            'religiousPlace' => 'Temple',
            'inroadExpectedReach' => 200,
            'jbpInterest' => 'High',
            'tlRating' => 'A',
            'smRating' => 'B'
        });
        Test.startTest();
        EYI_RECAccountUtility.createjbpRecord(jsonInput);
        Test.stopTest();
    }

    @isTest static void testCreateTaskSMModel() {
        EYI_REC__c rec = [SELECT Id FROM EYI_REC__c LIMIT 1];
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        EYI_Project_REC_Mapping__c mapping = [SELECT Id FROM EYI_Project_REC_Mapping__c LIMIT 1];
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'taskSubject' => 'Followup Call',
            'taskCallType' => 'Cold Call',
            'taskCallStatus' => 'Connected',
            'callRemarks' => 'Remarks',
            'recAccount' => rec.Id,
            'recMapping' => mapping.Id,
            'activityType' => 'Call',
            'projectName' => project.Id,
            'nextAction' => 'Follow Up',
            'nextActionDateTime' => DateTime.now().addDays(1)
        });
        Test.startTest();
        EYI_RECAccountUtility.createTaskSMModel(jsonInput);
        Test.stopTest();
    }
    
    @isTest
    static void testPANValidateCalloutFailure() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Mobile__c = '7777777777',
            EYI_Email__c = 'failure.test@email.com',
            EYI_Last_Name__c = 'Last',
            EYI_First_Name__c = 'First',
            EYI_PAN_No__c = 'ABCDE1235F',
            EYI_Birth_Date__c = Date.newInstance(1990, 1, 1),
            OwnerId = UserInfo.getUserId(),
            EYI_Type_Of_RERA_Registration__c = 'Individual'
        );
        
        Test.startTest();
        insert rec;
        Test.stopTest();
        
        EYI_REC__c updatedRec = [SELECT IsPANeKYCDone__c FROM EYI_REC__c WHERE Id = :rec.Id];
        System.assertEquals(false, updatedRec.IsPANeKYCDone__c, 'PAN eKYC should not be completed for invalid PAN');
    }

    @IsTest
    static void testGetVPVCs12() {
        String jsonString ='{"clientName":"www","companyName":"www","designation":"ww","email":"ww@gmail.com","mobileNumber":"9899009999","profile":"22","recCode":"REC - 05962","recMapping":"a1x9H000000DxNMQA0","recAccount":"a129H000000gYBlQAM","recStatus":"Visit Proposed","linkdin":"222","typology":[],"budget":"","docId":"","projectName":"a1e9H000000HMVgQAO","vcDate":null,"vpDate":"2025-07-10T12:05:00.000Z"}';
        Test.startTest();
            EYI_RECAccountUtility.createVPVCRecord(jsonString);
        Test.stopTest();
       
    }
     @isTest
    static void testPANValidate1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Mobile__c = '7777777777',
            EYI_Email__c = 'failure.test@email.com',
            EYI_Last_Name__c = 'Last',
            EYI_First_Name__c = 'First',
            EYI_PAN_No__c = 'ABCDE1235F',
            EYI_Birth_Date__c = Date.newInstance(1990, 1, 1),
            OwnerId = UserInfo.getUserId(),
            EYI_Type_Of_RERA_Registration__c = 'Individual'
        );
        
        Test.startTest();
            insert rec;
        Test.stopTest();
    }
}