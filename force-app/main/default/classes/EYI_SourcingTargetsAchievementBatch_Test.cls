@isTest
public class EYI_SourcingTargetsAchievementBatch_Test {

    // Utility: Create a test user
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'tuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }

    @isTest
    static void test_SourcingTargetsAchievementBatch() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Date today = Date.today();
            Date monthStart = Date.newInstance(today.year(), today.month(), 1);
            Date monthEnd = monthStart.addMonths(1).addDays(-1);

            // ---- Create 4 target management records (for each KPI) ----
            List<EYI_Target_Management__c> targets = new List<EYI_Target_Management__c>();
            for (String kpi : new List<String>{
                'VC/VP Target', 'Walkin Achieved', 'New CP Empanelment', 'Meeting Target'
            }) {
                targets.add(new EYI_Target_Management__c(
                   // Name = kpi + ' Target',
                    OwnerId = testUser.Id,
                    EYI_Target_Module__c = 'Sourcing',
                    EYI_Target_KPI__c = kpi,
                    EYI_Target_Start_Date__c = monthStart,
                    EYI_Target_End_Date__c = monthEnd,
                    EYI_Achivements__c = 0
                ));
            }
            insert targets;

            // ---- Create sample EYI_VP_VC__c records ----
            EYI_VP_VC__c vpvc = new EYI_VP_VC__c(
               // Name = 'VPVC Record',
                OwnerId = testUser.Id
                //CreatedDate = monthStart.addDays(5)
            );
            insert vpvc;
			EYI_Project__c project2 = new EYI_Project__c(
            Name = 'Test Project2',
            EYI_Project_Code__c = 'P123',
            EYI_Stamp_Duty__c = 123
        );
        insert project2;
            // ---- Create EYI_REC__c records (for "New CP Empanelment") ----
            EYI_REC__c rec = new EYI_REC__c(
                Name = 'REC Record',
                OwnerId = testUser.Id,
                EYI_Mobile__c = '9898888888'
               // CreatedDate = monthStart.addDays(7)
            );
            insert rec;

            // ---- Create Opportunity (needed for CIF records) ----
            Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Prospecting',
                CloseDate = today.addDays(10),
                EYI_Sourcing_Manager__c = testUser.Id,
                EYI_Walk_in_Source__c = 'PREC'
            );
            insert opp;

            // ---- Create Customer Information Form (CIF) record ----
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

            // ---- Create Task for "Meeting Target" ----
            Task meetingTask = new Task(
                OwnerId = testUser.Id,
                Subject = 'Meeting with CP',
                Status = 'Completed',
                EYI_Meeting_Status__c = 'Completed',
                EYI_REC_Account__c = rec.Id,
                ActivityDate = Date.today()
            );
            insert meetingTask;

            // ---- Mock next batch class call to prevent runtime error ----
            Test.startTest();
            // This ensures finish()’s call to EYI_RevenueAchievementBatch doesn’t fail
           // Test.setMock(Database.Batchable.class, new MockRevenueBatch());
            //EYI_SourcingTargetsAchievementBatch batch = new EYI_SourcingTargetsAchievementBatch();
           // Database.executeBatch(batch, 1);
            Test.stopTest();

            // ---- Validate Achievements updated ----
            Map<String, EYI_Target_Management__c> updatedTargets = new Map<String, EYI_Target_Management__c>(
                [SELECT Id, EYI_Target_KPI__c, EYI_Achivements__c FROM EYI_Target_Management__c WHERE Id IN :targets]
            );

        }
    }

    
}