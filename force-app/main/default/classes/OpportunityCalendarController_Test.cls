@isTest
public class OpportunityCalendarController_Test {
	@isTest
    public static void createEventTest(){
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
            // EYI_Inventory__c= invtry.id,
            //EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
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
            //EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId(),
            EYI_AutomationBypassDatetime__c = System.now()
        );
        insert opp;
        String startDatetime = '2025-05-12T14:30:00.000Z';
		String endDatetime = '2025-05-13T14:30:00.000Z';

        
        Test.startTest();
        String result = OpportunityCalendarController.createEvent(startDatetime, endDatetime, opp.id);
        OpportunityCalendarController.checkIfOpportunityLinked(opp.id);
        OpportunityCalendarController.updateEventWithOpportunity(result, opp.id, true);
		OpportunityCalendarController.updateEventWithOpportunity(result, opp.id, false);
        OpportunityCalendarController.unlinkOpportunityFromEvent(opp.id);
		OpportunityCalendarController.updateEventWithOpportunity(result, opp.id, true);
		OpportunityCalendarController.unlinkOpportunityFromEvent(opp.id);
		OpportunityCalendarController.updateEventWithOpportunity(result, opp.id, false);
		Event event = [SELECT Id, StartDateTime,ActivityDate, EndDateTime, whatId, IsRegistrationScheduled__c, Registration_Status__c 
                   FROM Event 
                   WHERE Id = :result LIMIT 1];
        event.ActivityDate = System.today();
        event.StartDateTime = System.today() + 2;
        event.EndDateTime = System.today() + 3;
        event.IsRegistrationScheduled__c = true;
        update event;
        System.debug('event ==> '+event);
        OpportunityCalendarController.getAvailableTimeSlots(System.today());
        event.ActivityDate = System.today()-2;
        update event;
		OpportunityCalendarController.getAvailableTimeSlots(System.today()-2);
        Test.stopTest();
    }
}