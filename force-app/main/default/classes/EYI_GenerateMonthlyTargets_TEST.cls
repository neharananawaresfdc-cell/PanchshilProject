@isTest
private class EYI_GenerateMonthlyTargets_TEST{
    @isTest
    private static void execute_TEST(){
        Test.startTest();
        EYI_GenerateMonthlyTargets obj = new EYI_GenerateMonthlyTargets();
        obj.execute(null);
        Test.stopTest();
    }
    @isTest
    private static void createMonthlyTargetsRecords_TEST(){
        Database.SaveResult dsr;
        EYI_Project__c drEYI_Project_c;
        EYI_Demand__c drEYI_Demand_c;
        drEYI_Project_c=new EYI_Project__c(EYI_Project_Code__c='a',EYI_Stamp_Duty__c=1.1);
        dsr=Database.insert(drEYI_Project_c,false);
        drEYI_Demand_c=new EYI_Demand__c(EYI_Collectible_Status__c='Collectible',EYI_Billing_Date__c=Date.today());
        Database.insert(drEYI_Demand_c,false);
        Test.startTest();
        EYI_GenerateMonthlyTargets.createMonthlyTargetsRecords();
        Test.stopTest();
    }
    @isTest
    private static void getMonthTest(){
        Test.startTest();
            EYI_GenerateMonthlyTargets.getCurrentMonthName();
        Test.stopTest();
    }
    @IsTest
    static void demandTest(){

        User usr = EYI_TestDataFactory.createUser('Relation Manager','System Administrator');

          EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = '234',
            EYI_SAP_Salesorg__c = '12345',
            EYI_Project_Status__c = 'Launch',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_Target_Percentage__c = 10
        );
        insert proj;
          EYI_SubProject__c subProj = new EYI_SubProject__c(
            Name = 'Test SubProject',
            EYI_Project_name__c = proj.Id
        );
        insert subProj;

        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Test Tower',
            EYI_Project_name__c = proj.Id,
            EYI_SubProject_name__c = subProj.Id,
            EYI_Relationship_Manager__c = usr.Id,
            EYI_SAP_Plant_ID__c = '1234',
            EYI_SAP_Delivery_Plant_Code__c = '1234'
        );
        insert tower;
         Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            EYI_SubProject_Name__c = subProj.Id,
            CloseDate = Date.today().addDays(30),
            EYI_Project_Enquired__c = proj.Id,
            EYI_Project_Tower_Enquired__c = tower.Id,
            EYI_Collectible_Status__c = 'Collectible',
            EYI_First_Name__c = 'Test',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_SAP_Customer_Number__c = '1234567890',
            EYI_Mobile_Number__c = '9876543210'
        );
        insert opp;

        RecordType rd = [ SELECT Id, Name, DeveloperName FROM RecordType 
        WHERE SObjectType = 'EYI_SAP_Report__c' and DeveloperName = 'EYI_SAP_Outstanding_Report'];
        
        EYI_SAP_Report__c sapReport = new EYI_SAP_Report__c();
        sapReport.Name = '1234567890';
        sapReport.EYI_Outstanding_Amount__c = 1000000;
        sapReport.Opportunity__c = opp.Id;
        sapReport.RecordTypeId = rd.Id;
        sapReport.EYI_Sales_Org__c ='12345';
        sapReport.EYI_Plant__c ='1234' ;  
        insert sapReport;

        List<EYI_Demand__c> demandlist = new List<EYI_Demand__c>();
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand);

        EYI_Demand__c demand1 = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Demand Sent',
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand1);
        
        EYI_Demand__c demand2 = new EYI_Demand__c(
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBookingFormSuccess());

            insert demandlist;
            EYI_GenerateMonthlyTargets.createMonthlyTargetsRecords();
        Test.stopTest();
    }
    @IsTest
    static void demandTest1(){

        User usr = EYI_TestDataFactory.createUser('Relation Manager','System Administrator');

          EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = '234',
            EYI_SAP_Salesorg__c = '12345',
            EYI_Project_Status__c = 'Launch',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_Target_Percentage__c = 10
        );
        insert proj;
          EYI_SubProject__c subProj = new EYI_SubProject__c(
            Name = 'Test SubProject',
            EYI_Project_name__c = proj.Id
        );
        insert subProj;

        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Test Tower',
            EYI_Project_name__c = proj.Id,
            EYI_SubProject_name__c = subProj.Id,
            EYI_Relationship_Manager__c = usr.Id,
            EYI_SAP_Plant_ID__c = '1234',
            EYI_SAP_Delivery_Plant_Code__c = '1234'
        );
        insert tower;
         Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            EYI_SubProject_Name__c = subProj.Id,
            CloseDate = Date.today().addDays(30),
            EYI_Project_Enquired__c = proj.Id,
            EYI_Project_Tower_Enquired__c = tower.Id,
            EYI_Collectible_Status__c = 'Collectible',
            EYI_First_Name__c = 'Test',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_SAP_Customer_Number__c = '1234567890',
            EYI_Mobile_Number__c = '9876543210'
        );
        insert opp;

        RecordType rd = [ SELECT Id, Name, DeveloperName FROM RecordType 
        WHERE SObjectType = 'EYI_SAP_Report__c' and DeveloperName = 'EYI_SAP_Outstanding_Report'];
        
        EYI_SAP_Report__c sapReport = new EYI_SAP_Report__c();
        sapReport.Name = '1234567890';
        sapReport.EYI_Outstanding_Amount__c = 1000000;
        sapReport.Opportunity__c = opp.Id;
        sapReport.RecordTypeId = rd.Id;
        sapReport.EYI_Sales_Org__c ='12345';
        sapReport.EYI_Plant__c ='1234' ;  
        insert sapReport;

        List<EYI_Demand__c> demandlist = new List<EYI_Demand__c>();
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand);

        EYI_Demand__c demand1 = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Demand Sent',
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand1);
        
        EYI_Demand__c demand2 = new EYI_Demand__c(
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBookingFormSuccess());

            Database.executeBatch(new EYI_MonthlyTargetOAmtUpdateBatch(),100);
        Test.stopTest();
        
    }
     @IsTest
    static void demandTest2(){

        User usr = EYI_TestDataFactory.createUser('Relation Manager','System Administrator');

          EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = '234',
            EYI_SAP_Salesorg__c = '12345',
            EYI_Project_Status__c = 'Launch',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_Target_Percentage__c = 10
        );
        insert proj;
          EYI_SubProject__c subProj = new EYI_SubProject__c(
            Name = 'Test SubProject',
            EYI_Project_name__c = proj.Id
        );
        insert subProj;

        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Test Tower',
            EYI_Project_name__c = proj.Id,
            EYI_SubProject_name__c = subProj.Id,
            EYI_Relationship_Manager__c = usr.Id,
            EYI_SAP_Plant_ID__c = '1234',
            EYI_SAP_Delivery_Plant_Code__c = '1234'
        );
        insert tower;
         Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            EYI_SubProject_Name__c = subProj.Id,
            CloseDate = Date.today().addDays(30),
            EYI_Project_Enquired__c = proj.Id,
            EYI_Project_Tower_Enquired__c = tower.Id,
            EYI_Collectible_Status__c = 'Collectible',
            EYI_First_Name__c = 'Test',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_SAP_Customer_Number__c = '1234567890',
            EYI_Mobile_Number__c = '9876543210'
        );
        insert opp;

        RecordType rd = [ SELECT Id, Name, DeveloperName FROM RecordType 
        WHERE SObjectType = 'EYI_SAP_Report__c' and DeveloperName = 'EYI_SAP_Outstanding_Report'];
        
        EYI_SAP_Report__c sapReport = new EYI_SAP_Report__c();
        sapReport.Name = '1234567890';
        sapReport.EYI_Outstanding_Amount__c = 1000000;
        sapReport.Opportunity__c = opp.Id;
        sapReport.RecordTypeId = rd.Id;
        sapReport.EYI_Sales_Org__c ='12345';
        sapReport.EYI_Plant__c ='1234' ;  
        insert sapReport;

        List<EYI_Demand__c> demandlist = new List<EYI_Demand__c>();
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand);

        EYI_Demand__c demand1 = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Demand Sent',
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand1);
        
        EYI_Demand__c demand2 = new EYI_Demand__c(
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBookingFormSuccess());

            insert demandlist;
            EYI_GenerateMonthlyTargets.createMonthlyTargetsRecords();
            Database.executeBatch(new EYI_MonthlyTargetReceivedAmtBatch(),100);

        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        // Simulate the Schedulable context
        EYI_MonTargetReceivedAmtBatchScheduler scheduler = new EYI_MonTargetReceivedAmtBatchScheduler();
        scheduler.execute(null);
        Test.stopTest();

        // Assert that a batch job was enqueued
        // (Optional - you can verify debug logs or custom logic inside the batch class)
    }

    @isTest
    static void testScheduleNextRun() {
        Test.startTest();
        EYI_MonTargetReceivedAmtBatchScheduler.scheduleNextRun();
        Test.stopTest();

        // Query the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE CronJobDetail.Name LIKE 'EYI_Monthly Collection Received Job%' 
                          LIMIT 1];

        System.assertNotEquals(null, ct);
        System.assert(ct.NextFireTime != null, 'NextFireTime should not be null');
    }

  @IsTest
    static void demandTest3(){

        User usr = EYI_TestDataFactory.createUser('Relation Manager','System Administrator');

          EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_Project_Code__c = '234',
            EYI_SAP_Salesorg__c = '12345',
            EYI_Project_Status__c = 'Launch',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_Target_Percentage__c = 10
        );
        insert proj;
          EYI_SubProject__c subProj = new EYI_SubProject__c(
            Name = 'Test SubProject',
            EYI_Project_name__c = proj.Id
        );
        insert subProj;

        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Test Tower',
            EYI_Project_name__c = proj.Id,
            EYI_SubProject_name__c = subProj.Id,
            EYI_Relationship_Manager__c = usr.Id,
            EYI_SAP_Plant_ID__c = '1234',
            EYI_SAP_Delivery_Plant_Code__c = '1234'
        );
        insert tower;
         Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            EYI_SubProject_Name__c = subProj.Id,
            CloseDate = Date.today().addDays(30),
            EYI_Project_Enquired__c = proj.Id,
            EYI_Project_Tower_Enquired__c = tower.Id,
            EYI_Collectible_Status__c = 'Collectible',
            EYI_First_Name__c = 'Test',
            EYI_Ownership_Status__c = 'Accepted',
            EYI_SAP_Customer_Number__c = '1234567890',
            EYI_Mobile_Number__c = '9876543210'
        );
        insert opp;

        RecordType rd = [ SELECT Id, Name, DeveloperName FROM RecordType 
        WHERE SObjectType = 'EYI_SAP_Report__c' and DeveloperName = 'EYI_SAP_Outstanding_Report'];
        
        List<EYI_SAP_Report__c> sapReportList = new List<EYI_SAP_Report__c>();
        EYI_SAP_Report__c sapReport = new EYI_SAP_Report__c();
        sapReport.Name = '1234567890';
        sapReport.EYI_Outstanding_Amount__c = 1000000;
        sapReport.Opportunity__c = opp.Id;
        sapReport.RecordTypeId = rd.Id;
        sapReport.EYI_Sales_Org__c ='12345';
        sapReport.EYI_Plant__c ='1234' ;  
        sapReport.EYI_Ageing_Delay_Days__c = 1;
        sapReportList.add(sapReport);

        EYI_SAP_Report__c sapReport1 = new EYI_SAP_Report__c();
        sapReport1.Name = '1234567890';
        sapReport1.EYI_Outstanding_Amount__c = 1000000;
        sapReport1.Opportunity__c = opp.Id;
        sapReport1.RecordTypeId = rd.Id;
        sapReport1.EYI_Sales_Org__c ='12345';
        sapReport1.EYI_Plant__c ='1234' ;  
        sapReport1.EYI_Ageing_Delay_Days__c = 50;
        sapReportList.add(sapReport1);

        EYI_SAP_Report__c sapReport2 = new EYI_SAP_Report__c();
        sapReport2.Name = '1234567890';
        sapReport2.EYI_Outstanding_Amount__c = 1000000;
        sapReport2.Opportunity__c = opp.Id;
        sapReport2.RecordTypeId = rd.Id;
        sapReport2.EYI_Sales_Org__c ='12345';
        sapReport2.EYI_Plant__c ='1234' ;  
        sapReport.EYI_Ageing_Delay_Days__c = 100;
        sapReportList.add(sapReport2);


        List<EYI_Demand__c> demandlist = new List<EYI_Demand__c>();
        EYI_Demand__c demand = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand);

        EYI_Demand__c demand1 = new EYI_Demand__c(
            EYI_Actual_Date__c = Date.today().toStartOfMonth(),
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Demand Sent',
            EYI_Demand_Payment_Status__c = 'Pending',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand1);
        
        EYI_Demand__c demand2 = new EYI_Demand__c(
            EYI_Amount_to_be_paid__c = 10000,
            EYI_Project__c = proj.Id,
            EYI_Tower__c = tower.Id,
            EYI_Billing_Date__c = Date.today().toStartOfMonth(),
            EYI_Demand_Status__c = 'Open',
            EYI_Opportunity__c = opp.Id
        );
        demandlist.add(demand2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBookingFormSuccess());

            insert sapReportList;
            insert demandlist;
            EYI_GenerateMonthlyTargets.createMonthlyTargetsRecords();
            Database.executeBatch(new EYI_OpportunitySegregationBatch(),100);

        Test.stopTest();
        
    }

}