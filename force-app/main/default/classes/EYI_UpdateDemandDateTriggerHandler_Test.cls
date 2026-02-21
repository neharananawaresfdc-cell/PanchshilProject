@isTest
public class EYI_UpdateDemandDateTriggerHandler_Test {
	@isTest
    public static void handleAfterUpdateTest(){
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        newTower.EYI_SAP_Delivery_Plant_Code__c = 'R15D';
        insert newTower;
        
        EYI_Payment_Schedule__c paymentSchedule = new EYI_Payment_Schedule__c();
        paymentSchedule.EYI_SAP_Milestone_Code__c = '306' + '3';
        paymentSchedule.EYI_Milestone_Number__c = 306;
        paymentSchedule.EYI_SAP_Sales_Org__c = 'R150';
        paymentSchedule.EYI_SAP_Plant_Code__c = 'R15D';
		paymentSchedule.EYI_SAP_Activity_Number__c = 3;
        paymentSchedule.EYI_Usage__c = 'Z0002';
		paymentSchedule.EYI_SAP_Activity_Number__c = 3;
		paymentSchedule.EYI_AutomationBypassDatetime__c = System.today();
        paymentSchedule.EYI_Usage_Description__c = 'On Booking Changed';
        paymentSchedule.EYI_WBS_Element__c = 10609;
        paymentSchedule.EYI_Billing_Date__c = System.today();
		paymentSchedule.EYI_Actual_Date__c = System.today();
        paymentSchedule.EYI_Invoice_Percentage__c = 20;
        paymentSchedule.EYI_Tower__c = newTower.id;
        
        insert paymentSchedule;
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert Acc;
        
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Name='Nilesh Arvind Ghodke',
            EYI_Last_Name__c='Arvind Ghodke',
            EYI_Pancard_Number__c='DLWPG4197L',
            EYI_Applicant_Type__c='Primary Applicant'
        );
        insert applicant;
        
        Opportunity opp = new Opportunity(
            // EYI_Inventory__c= invtry.id,
            //EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
            EYI_Project_Tower_Enquired__c= newTower.id,
            EYI_Primary_Applicant__c=applicant.id,
            EYI_Salutation__c='Mr.',
            Name='Tushar test',
            StageName ='Cancellation',
            CloseDate = system.today()+20,
            EYI_First_Name__c='Tushar test',
            EYI_Last_Name__c='testOPP',
            EYI_Address3__c='Film city',
            EYI_Nationality__c='Indian',
            //EYI_Project_Enquired__c =projctobj.id,
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
            EYI_Payment_Terms__c='15 Days Credit From the Date of Invoice',
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
            EYI_AutomationBypassDatetime__c = System.now()
        );
        insert opp;
        
        EYI_Demand__c demandRec = new EYI_Demand__c(
        	EYI_Opportunity__c = opp.id,
            EYI_Payment_Schedule__c = paymentSchedule.id
        );
        insert demandRec;
        
        Map<Id, EYI_Payment_Schedule__c> oldMap = new Map<Id, EYI_Payment_Schedule__c>();
        EYI_Payment_Schedule__c oldPaymentSchedule = paymentSchedule.clone(false, true, true, true);
        oldPaymentSchedule.EYI_Actual_Date__c = System.today(); // Set old value of the field for oldMap
        oldMap.put(paymentSchedule.Id, oldPaymentSchedule);
        paymentSchedule.EYI_Actual_Date__c = System.today() + 2;
		Map<Id, EYI_Payment_Schedule__c> newMap = new Map<Id, EYI_Payment_Schedule__c>();
        update paymentSchedule;
        newMap.put(paymentSchedule.Id, paymentSchedule);        
        Test.startTest();
        EYI_UpdateDemandDateTriggerHandler.handleAfterUpdate(newMap, oldMap);
        Test.stopTest();
    }
}