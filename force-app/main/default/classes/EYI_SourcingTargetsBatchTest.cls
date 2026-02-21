@IsTest
public with sharing class EYI_SourcingTargetsBatchTest {
   

    @testSetup
    static void setupData() {
       
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1];

        // Step 2: Create the test user with current user as manager
        User u = new User(
            FirstName = 'Test',
            LastName = 'SalesUser',
            Email = 'salesuser@example.com',
            Username = 'salesuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tsales',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = salesProfile.Id,
            ManagerId = UserInfo.getUserId()
        );

        insert u;
        // Calculate fiscal year boundaries based on April start
        Integer fiscalStartMonth = 4; // April
        Date today = Date.today();
        Integer fiscalYear;
        
        if (today.month() >= fiscalStartMonth) {
            fiscalYear = today.year() + 1;
        } else {
            fiscalYear = today.year();
        }
        
        Integer fiscalStartYear = fiscalYear - 1;
        Date fiscalStart = Date.newInstance(fiscalStartYear, fiscalStartMonth, 1);
        Date fiscalEnd = fiscalStart.addYears(1).addDays(-1);
        
        // Reference an existing project and owner
        //EYI_Project__c project = [SELECT Id FROM EYI_Project__c LIMIT 1];
        // Create Project
        EYI_Project__c project2 = new EYI_Project__c(
            Name = 'Test Project2',
            EYI_Project_Code__c = 'P123',
            EYI_Stamp_Duty__c = 123
        );
        insert project2;
		Id ownerId = UserInfo.getUserId();

		// Create target records for each KPI type the batch uses
		List<EYI_Target_Management__c> sourcingTargets = new List<EYI_Target_Management__c>();

		sourcingTargets.add(new EYI_Target_Management__c(
          //  Name = 'Meeting Target',
            OwnerId = ownerId,
            EYI_Project__c = project2.Id,
            EYI_Target_Module__c = 'Sourcing',
            EYI_Target_KPI__c = 'Meeting Target',
            EYI_Target_Start_Date__c = fiscalStart,
            EYI_Target_End_Date__c = fiscalEnd,
            EYI_Target_Month_Date__c = Date.today()
        ));

            sourcingTargets.add(new EYI_Target_Management__c(
               // Name = 'New CP Empanelment',
                OwnerId = ownerId,
                EYI_Project__c = project2.Id,
                EYI_Target_Module__c = 'Sourcing',
                EYI_Target_KPI__c = 'New CP Empanelment',
                EYI_Target_Start_Date__c = fiscalStart,
                EYI_Target_End_Date__c = fiscalEnd,
                EYI_Target_Month_Date__c = Date.today()
            ));
            
            sourcingTargets.add(new EYI_Target_Management__c(
               // Name = 'Walkin Achieved',
                OwnerId = ownerId,
                EYI_Project__c = project2.Id,
                EYI_Target_Module__c = 'Sourcing',
                EYI_Target_KPI__c = 'Walkin Achieved',
                EYI_Target_Start_Date__c = fiscalStart,
                EYI_Target_End_Date__c = fiscalEnd,
                EYI_Target_Month_Date__c = Date.today()
            ));
            
            sourcingTargets.add(new EYI_Target_Management__c(
             //   Name = 'VC/VP Target',
                OwnerId = ownerId,
                EYI_Project__c = project2.Id,
                EYI_Target_Module__c = 'Sourcing',
                EYI_Target_KPI__c = 'VC/VP Target',
                EYI_Target_Start_Date__c = fiscalStart,
                EYI_Target_End_Date__c = fiscalEnd,
                EYI_Target_Month_Date__c = Date.today()
            ));
            
            insert sourcingTargets;

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

        

        // Project REC Mapping
        EYI_Project_REC_Mapping__c mapping = new EYI_Project_REC_Mapping__c(
            EYI_Project__c = project2.Id,
            EYI_REC_Account__c = rec.Id,
            EYI_Sourcing_Manager__c = UserInfo.getUserId()
        );
        insert mapping;

        Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Test Opportunity';
            testOpportunity.StageName = 'Prospecting';
            testOpportunity.EYI_Project_Enquired__c = project2.Id;
            testOpportunity.EYI_Sourcing_Manager__c = UserInfo.getUserId();
            testOpportunity.EYI_REC__c = rec.Id;
            testOpportunity.CloseDate = Date.today().addDays(30);
        insert testOpportunity;
        
        Quote q = new Quote(
            Name='Test Quote', OpportunityId=testOpportunity.Id,
            EYI_Agreement_Value__c=500000, Stamp_Duty__c=10000
        );
        insert q;

        testOpportunity.EYI_Ownership_Status__c='Accepted';
        testOpportunity.SyncedQuoteId = q.Id;
        testOpportunity.EYI_AutomationBypassDatetime__c = System.Now();
        update testOpportunity;
        // Booking
        EYI_Booking__c booking = new EYI_Booking__c(
            EYI_Project_Name__c = project2.Id,
            EYI_Opportunity_Name__c = testOpportunity.Id,
            EYI_Sourcing_manager__c = UserInfo.getUserId(),
            EYI_Booking_Date__c = System.today(),
            EYI_Actual_Booking_Date__c = System.today(),
            EYI_REC_Account__c = rec.Id
        );
        insert booking;

        
        Opportunity testOpportunity2 = new Opportunity();
            testOpportunity2.Name = 'Test Opportunity';
            testOpportunity2.StageName = 'Prospecting';
            testOpportunity2.EYI_Project_Enquired__c = project2.Id;
            testOpportunity2.EYI_Sourcing_Manager__c = UserInfo.getUserId();
            testOpportunity2.EYI_REC__c = rec.Id;
            testOpportunity2.EYI_Primary_Closing_Manager__c = UserInfo.getUserId();
            testOpportunity2.CloseDate = Date.today().addDays(30);
        insert testOpportunity2;
        
        Quote q2 = new Quote(
            Name='Test Quote', OpportunityId=testOpportunity2.Id,
            EYI_Agreement_Value__c=500000, Stamp_Duty__c=10000
        );
        insert q2;
        testOpportunity2.EYI_Ownership_Status__c='Accepted';
        testOpportunity2.SyncedQuoteId = q2.Id;
        testOpportunity2.EYI_AutomationBypassDatetime__c = System.Now();
        update testOpportunity2;
        // Booking
        EYI_Booking__c booking2 = new EYI_Booking__c(
            EYI_Project_Name__c = project2.Id,
            EYI_Opportunity_Name__c = testOpportunity2.Id,
            EYI_Sourcing_manager__c = UserInfo.getUserId(),
            EYI_Booking_Date__c = System.today(),
            EYI_Actual_Booking_Date__c = System.today(),
            EYI_REC_Account__c = rec.Id
        );
        insert booking2;
          Opportunity testOpportunity3 = new Opportunity();
            testOpportunity3.Name = 'Test Opportunity';
            testOpportunity3.StageName = 'Prospecting';
            testOpportunity3.EYI_Project_Enquired__c = project2.Id;
            testOpportunity3.EYI_Sourcing_Manager__c = UserInfo.getUserId();
            testOpportunity3.EYI_REC__c = rec.Id;
            testOpportunity3.EYI_Primary_Closing_Manager__c = u.id;
            testOpportunity3.CloseDate = Date.today().addDays(30);
        insert testOpportunity3;
        
        Quote q3 = new Quote(
            Name='Test Quote', OpportunityId=testOpportunity3.Id,
            EYI_Agreement_Value__c=500000, Stamp_Duty__c=10000
        );
        insert q3;
        testOpportunity3.EYI_Ownership_Status__c='Accepted';
        testOpportunity3.SyncedQuoteId = q3.Id;
        testOpportunity3.EYI_AutomationBypassDatetime__c = System.Now();
        update testOpportunity2;
        // Booking
        EYI_Booking__c booking3 = new EYI_Booking__c(
            EYI_Project_Name__c = project2.Id,
            EYI_Opportunity_Name__c = testOpportunity3.Id,
            EYI_Sourcing_manager__c = UserInfo.getUserId(),
            EYI_Booking_Date__c = System.today(),
            EYI_Actual_Booking_Date__c = System.today(),
            EYI_REC_Account__c = rec.Id
        );
        insert booking3;
        // CIF
        
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'John',
            EYI_Last_Name__c = 'Doe',
            EYI_Email_Id__c = 'john.doe@example.com',
            EYI_Mobile_number__c = '9876543210',
            EYI_Project_Enquired__c = project2.Id,
			EYI_Customer_Address_Type__c = 'Mumbai',
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
            EYI_Next_Action_Date_Time__c = System.now().addDays(1) 
        );
        insert task;

        // VPVC
        EYI_VP_VC__c vpvc = new EYI_VP_VC__c(
            EYI_Client_Name__c = 'Client X',
            EYI_Company_Name__c = 'Company Y',
            EYI_Project__c = project2.Id,
            EYI_REC_Account__c = rec.Id,
            EYI_Visit_Proposed_Date__c = Date.today(),
            EYI_Visit_Confirmed_Date__c = Date.today(),
            OwnerId = UserInfo.getUserId(),
            EYI_Status__c = 'Visit Proposed'
        );
        insert vpvc;

        

    }

    @IsTest
    static void methodName(){
        
        Test.startTest();
        AggregateResult[] taskResults = [
                SELECT OwnerId, COUNT(Id) taskCount
                FROM Task
                WHERE EYI_REC_Account__c != null
                AND Createddate = THIS_MONTH
                GROUP BY OwnerId
            ];
            System.debug('taskResults====>'+taskResults);
            database.executebatch(new EYI_SourcingTargetsAchievementBatch(),10);
        Test.stopTest();
        
    }
}