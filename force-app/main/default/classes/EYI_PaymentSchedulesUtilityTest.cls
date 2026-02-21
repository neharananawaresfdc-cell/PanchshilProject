@isTest
public class EYI_PaymentSchedulesUtilityTest {
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}'); // Adjust response based on expected API response
            res.setStatusCode(200);
            return res;
        }
    }
    public static String testData(){
        
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Distribution_Channel__c = '10',
            EYI_Project_Status__c = 'Pre- Launch',
            EYI_Project_Type__c = 'Flat',
            EYI_Zone__c = 'Pune City',
            EYI_Chatbot_Active__c = true,
            EYI_Project_Location__c = 'Kharadi',
            EYI_Project_Site_Location_Link__c = 'https://maps.app.goo.gl/ZzSkyikTyHoDYoKr5',
            EYI_Project_Start_Date__c = System.today() - 10,
            EYI_SAP_Company_Code__c = '1320',
            EYI_SAP_Plant_Code__c = 'R15A',
            EYI_Sales_District__c = 'IN0001',
            EYI_SAP_Salesorg__c = 'R152',
            EYI_Stamp_Duty__c = 5,
            EYI_RDS_State__c = 'Maharashtra',
            EYI_Asset_Class__c = 'Outright',
            EYI_Sub_Asset_Class__c = 'Plot',
            EYI_Total_Budget__c = 1000000,
            EYI_Project_Code__c = '83',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_TDS_Charge__c = 10
        );
        insert projctobj;
        
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert Acc;
        
        Opportunity opp = new Opportunity(
            //SyncedQuoteId = quote.id,
            //EYI_Inventory__c= invtry.id,
            //EYI_CIF_Record__c =CIF.id,
            AccountId = Acc.id,
            //EYI_Project_Tower_Enquired__c= towerobj.id,
            //EYI_Primary_Applicant__c=applicant.id,
            EYI_Salutation__c='Mr.',
            Name='Tushar test',
            StageName ='Cancellation',
            CloseDate = system.today()+20,
            EYI_First_Name__c='Tushar test',
            EYI_Last_Name__c='testOPP',
            EYI_Address3__c='Film city',
            EYI_Nationality__c='Indian',
            EYI_Project_Enquired__c =projctobj.id,
            EYI_Address2__c='sector 16',
            EYI_Address1__c='sector 16 a',
            EYI_City__c='Noida',
            EYI_Country_Classification__c='India',
            EYI_Country_Key__c='IN',
            GST_Applicable__c= true,
            EYI_Customer_Currency__c='INR',
            EYI_BP_Type__c='1',
            EYI_Segment__c='Residential',
            //EYI_Distribution_Channel__c='Residential Sale',
            EYI_Date_Of_Birth__c=system.today()-150,
            EYI_District__c='GB',
            EYI_GSTIN_Number__c='27AAAPA1234A1Z9',
            EYI_Id_Number__c='2345678909876',
            EYI_Id_Type__c='AADHAR Card Number',
            EYI_Industry__c='Advertising',
            EYI_Occupation__c='Salaried',
            EYI_Pan_Number__c='45678iolmn',
            EYI_Partner_Function__c='Sold-to Party',
            //EYI_Payment_Terms__c='Immediate Due after Invoice',
            EYI_Postal_Code__c='201301',
            EYI_Sales_Group__c='Pune Sales Group',
            EYI_Sales_Office__c='Mumbai Office',
            EYI_TCS_Applicable__c= true,
            EYI_Mobile_Number__c='23456789987654',
            EYI_Alternate_Mobile_No__c='98765432124',
            EYI_SAP_Customer_Number__c= '23456789098765',
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
            EYI_AutomationBypassDatetime__c = System.now(),
            EYI_Walk_in_Source__c = 'Management'
        );
        insert opp;
        
        
         Quote quote = new Quote(
            Name = 'Test Quote',
            Status = 'Approved',
            OpportunityId = opp.Id,
            Stamp_Duty__c = 10000,
            Central_GST__c = 5000,
            State_GST__c = 5000,
            EYI_Registration_Charges__c = 15000,
            EYI_Quoatation_Grand_Total__c = 1000,
            EYI_Agreement_Value__c = 4000000
        );
        insert quote;
        
        
        
        Payment_Plan__c paymentPlan = new Payment_Plan__c(
        	Name = 'Test132',
            EYI_Plan_Type__c = 'Subvention',
            Project__c = projctobj.id,
            EYI_Quote__c = quote.id
            
        );
        
        EYI_Payment_Schedule__c paymentSchedule = new EYI_Payment_Schedule__c(
        	EYI_Usage_Description__c = 'EYI_SAP_Plant_Code__c',
            EYI_SAP_Plant_Code__c = '12345',
            EYI_Usage__c = 'Usage',
            EYI_Billing_Date__c = System.today(),
            EYI_SAP_Sales_Org__c = '123',
            EYI_Milestone__c = true,
            EYI_Invoice_Percentage__c = 10,
            EYI_Due_Amount__c = 10,
            EYI_Amount_to_be_paid__c = 100,
            EYI_GST__c = 20,
            Payment_Plan__c = paymentPlan.id,
            EYI_Milestone_Number__c = 100
        );
        insert paymentSchedule;
        
        return paymentPlan.id;
    }
    
    @isTest
    public static void getPaymentSchedulesTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String paymentPlanId = testData();
        Test.startTest();
        EYI_PaymentSchedulesUtility.getPaymentSchedules(paymentPlanId);
        Test.stopTest();
    }
    
    @isTest
    public static void updatePaymentSchedulesTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String paymentPlanId = testData();
        EYI_Payment_Schedule__c paymentSchedule = [Select Id, Payment_Plan__r.EYI_Plan_Type__c,EYI_Usage_Description__c, EYI_Invoice_Percentage__c, EYI_Billing_Date__c,EYI_Due_Amount__c,EYI_Amount_to_be_paid__c,EYI_Payable_Amount__c,EYI_TDS__c,Payment_Plan__r.Project__r.EYI_TDS_Charge__c,Payment_Plan__r.EYI_Quote__r.EYI_Quoatation_Grand_Total__c,EYI_Net_Payable__c,EYI_GST__c from EYI_Payment_Schedule__c
                Where Payment_Plan__c = :paymentPlanId LIMIT 1];
        List<EYI_Payment_Schedule__c> psList = new List<EYI_Payment_Schedule__c>();
        pslist.add(paymentSchedule);
        Test.startTest();
        EYI_PaymentSchedulesUtility.updatePaymentSchedules(psList);
        Test.stopTest();
    }
    
    @isTest
    public static void deletePaymentSchedulesTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String paymentPlanId = testData(); 
        EYI_Payment_Schedule__c paymentSchedule = [Select Id, Payment_Plan__r.EYI_Plan_Type__c,EYI_Usage_Description__c, EYI_Invoice_Percentage__c, EYI_Billing_Date__c,EYI_Due_Amount__c,EYI_Amount_to_be_paid__c,EYI_Payable_Amount__c,EYI_TDS__c,Payment_Plan__r.Project__r.EYI_TDS_Charge__c,Payment_Plan__r.EYI_Quote__r.EYI_Quoatation_Grand_Total__c,EYI_Net_Payable__c,EYI_GST__c from EYI_Payment_Schedule__c
                Where Payment_Plan__c = :paymentPlanId LIMIT 1];
        Test.startTest();
        EYI_PaymentSchedulesUtility.deletePaymentSchedules(paymentSchedule.id);
        Test.stopTest();
    }
}