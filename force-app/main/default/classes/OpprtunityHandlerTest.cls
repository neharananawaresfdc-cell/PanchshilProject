@isTest
public class OpprtunityHandlerTest {
    @isTest
	static void testProcessFromReceiptsAndReceiptIds() {
        //payment receipt trigger and handler test class
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            EYI_City__c='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405',
            Master_Type__c='Pincode',
            EYI_Zone__c ='Pune Region',
            EYI_Sub_Urb__c='Pune Moffusil Division'
        );
        insert mster;
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        
        EYI_Customer_Information_Form__c CIF = new EYI_Customer_Information_Form__c(
            EYI_City__c =city.id,
            EYI_Salutation__c='Mr.',
            //EYI_REC_Account__c= Acc.id,
            EYI_Pincode__c =mster.id,
            EYI_First_Name__c ='test applicant',
            EYI_Last_Name__c='cif',
            EYI_Mobile_number__c= '9764212568',
            EYI_Address_1__c ='noida test',
            EYI_Address_2__c='test',
            EYI_Address_3__c='test',
            EYI_Email_Id__c='test@gmail.com',
            EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c= 'Maharashtra'
            
        );
        insert CIF;
        
         Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
             
        );
        insert Acc;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            AccountId=Acc.Id,
            EYI_CIF_Record__c =CIF.id,
            CloseDate = Date.today().addDays(30),
            EYI_Primary_Closing_Manager__c=UserInfo.getUserId(),
            Primary_Closing_Manager_Head__c= UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert testOpportunity;
        
        EYI_FCM_Detail__c fcm = new EYI_FCM_Detail__c(
            EYI_Opportunity__c = testOpportunity.Id,
            EYI_Custom_Device_ID__c = 'mock_device_token_123'
        );
        insert fcm;
        Test.setMock(HttpCalloutMock.class, new EYI_FCMCalloutMock());
        test.startTest();
        testOpportunity.EYI_NCF_Status__c = 'Received';
        update testOpportunity;
        test.stopTest();
    }
}