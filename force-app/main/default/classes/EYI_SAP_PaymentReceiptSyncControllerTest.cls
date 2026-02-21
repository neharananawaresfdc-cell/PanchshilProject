@isTest
public class EYI_SAP_PaymentReceiptSyncControllerTest {

    // Mock class to simulate HTTP callout response
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{' +
                '"n0:ZSD_CREATE_SO_FROM_SFResponse": {' +
                    '"EX_RETURN": {' +
                        '"TYPE": "S", ' +
                        '"MESSAGE": "Success"' +
                    '}' +
                '}' +
            '}');
            return res;
        }
    }

    @isTest
    static void testPaymentsSyncSuccess() {
        // Setup data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

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
            EYI_SAP_Company_Code__c = '1290',
            EYI_SAP_Plant_Code__c = 'R15A',
            EYI_Sales_District__c = 'IN0001',
            EYI_SAP_Salesorg__c = 'R152',
            EYI_Stamp_Duty__c = 5,
            EYI_RDS_State__c = 'Maharashtra',
            EYI_Asset_Class__c = 'Outright',
            EYI_Sub_Asset_Class__c = 'Plot',
            EYI_Total_Budget__c = 1000000,
            EYI_Project_Code__c = '83',
            EYI_Project_Property_Type__c = 'Residential'
          
        );
        insert projctobj;

        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Tower A',
            EYI_Project_Name__c = projctobj.Id,
            EYI_Stage__c = 'Pre-Launch'
        );
        insert tower;

        EYI_Inventory__c inv = new EYI_Inventory__c(
            Name = 'Unit 101',
            EYI_Inventory_Number__c = 'INV001',
            EYI_Tower__c = tower.Id,
            EYI_Project__c = projctobj.Id,
            EYI_Inventory_Status__c = 'Reserve'
        );
        insert inv;

        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_Salutation__c = 'Mr.',
            EYI_First_Name__c = 'John',
            EYI_Last_Name__c = 'Doe',
            EYI_Mobile_number__c = '9999999999',
            EYI_Email_Id__c = 'john@example.com',
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert cif;

        Opportunity opp = new Opportunity(
            Name = 'Opportunity A',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            EYI_Inventory__c = inv.Id,
            EYI_CIF_Record__c = cif.Id,
            EYI_Project_Enquired__c = projctobj.Id,
            EYI_SAP_Customer_Number__c = '123456',
             EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;

        EYI_Payment_Receipt__c payment = new EYI_Payment_Receipt__c(
            EYI_Opportunity__c = opp.Id,
            EYI_Transaction_Type__c = 'Advance',
            EYI_Amount__c = 50000,
            EYI_Bank_Name__c = 'ICICI Bank',
            EYI_Instrument_Date__c = Date.today()
            
        );
        insert payment;
        System.debug('payment '+payment);
EYI_Payment_Receipt__c PaymentData = [Select Id,EYI_Transaction_Type__c,EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c,
                                      		 EYI_Opportunity__r.EYI_SAP_Customer_Number__c,EYI_Amount__c,
                                             EYI_Bank_Name__c,//EYI_Instrument_Number__c,
                                             EYI_Instrument_Date__c,
                                              EYI_Opportunity__r.EYI_Inventory__r.Name, EYI_SAP_Error__c,EYI_Is_Syc__c
 from EYI_Payment_Receipt__c where Id = :payment.Id];
        System.debug('PaymentData : '+PaymentData);
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        EYI_SAP_PaymentReceiptSyncController.lwcMessage result = EYI_SAP_PaymentReceiptSyncController.PaymentsSync(PaymentData.Id);
        Test.stopTest();

        // Fetch the updated payment record
        EYI_Payment_Receipt__c updatedPayment = [SELECT EYI_SAP_Error__c, EYI_Is_Syc__c FROM EYI_Payment_Receipt__c WHERE Id = :payment.Id];

        // Assertions
        /*System.assertEquals('S', result.type);
        System.assertEquals('Success', result.message);
        System.assertEquals('Success', updatedPayment.EYI_SAP_Error__c);
        System.assertEquals(true, updatedPayment.EYI_Is_Syc__c);*/
    }
}