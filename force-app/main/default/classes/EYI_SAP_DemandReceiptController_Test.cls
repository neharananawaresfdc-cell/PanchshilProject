@isTest
public class EYI_SAP_DemandReceiptController_Test {
    
    class MockSuccessPaymentResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
			//res.setBody('{"n0:ZSD_CREATE_SO_FROM_SFResponse":{"EX_RETURN":{"TYPE":"S","MESSAGE":"Success"}}}');
            res.setBody('{"n0:ZSD_CREATE_PAYMT_RCPT_FROM_SFResponse": {"EX_AVSID": "AVS123456","EX_BELNR": "BEL123456","EX_GJAHR": "2025","EX_BUKRS": "1000"}}');
            return res;
        }
    }
    
    private class SAPGatewayMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String mockBody = JSON.serializePretty(new Map<String, Object>{
                'n0:ZSD_OPEN_LINE_ITEMS_CUST_SFResponse' => new Map<String, Object>{
                    'EX_OUTPUT' => new Map<String, Object>{
                        'item' => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'COMP_CODE' => '1000',
                                'CUSTOMER' => 'CUST001',
                                'DOC_NO' => 'DOC123',
                                'FISC_YEAR' => '2024',
                                'ITEM_NUM' => '0001',
                                'BILL_DOC' => 'BILL001',
                                'REF_KEY_1' => 'MS01',
                                'REF_KEY_2' => 'UNIT01',
                                'REF_KEY_3' => 'ADJ01',
                                'LC_AMOUNT' => '500.00',
                                'CURRENCY' => 'USD',
                                'DOC_TYPE' => 'DZ',
                                'SP_GL_IND' => 'A',
                                'DOC_DATE' => '2024-05-01',
                                'PSTNG_DATE' => '2024-05-02',
                                'ALLOC_NMBR' => 'ALLOC123',
                                'REF_DOC_NO' => 'REF001'
                            }
                        }
                    }
                }
            });
            res.setBody(mockBody);
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
            EYI_Project_Property_Type__c = 'Residential'
        );
        insert projctobj;
        
        EYI_Tower__c towerobj = new EYI_Tower__c(
            Name = 'Balewadi Tower A',
            EYI_Stage__c = 'Pre-Launch',
            EYI_Pass_Code__c = 'BTA',
            EYI_Project_Name__c = projctobj.id,
            EYI_RERA_Certificate_Date__c = System.today() - 10,
            EYI_RERA_Number__c = 'A43242343',
            EYI_RERA_Possesion_Date__c = System.today() - 15,
            EYI_Tower_Number__c = 'A01',
            EYI_Tower_Property_Type__c = 'Apartments;Shops',
            EYI_SAP_Delivery_Plant_Code__c = 'R15D',
            EYI_SAP_Plant_ID__c = 'R15I', 
            EYI_Total_Car_Park__c = 1,
            EYI_Onboarding_Manager__c = UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert towerobj;
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert Acc;
        
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            //Name='Pune',
            EYI_City__c='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405',
            Master_Type__c='Pincode',
            EYI_Zone__c ='Pune Region',
            EYI_Sub_Urb__c='Pune Moffusil Division'
        );
        insert mster;
        
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
            EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c= 'Maharashtra'
            
        );
        insert CIF;
        

		EYI_Inventory__c invtry = new EYI_Inventory__c(
            //EYI_Booking__c=book.id,
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            EYI_Inventory_Type__c ='Residential Sales',
            EYI_UOM__c ='Square foot',
            EYI_Material_Group__c='Apartment',
            EYI_Super_Built_up_Area__c=20,
            EYI_Carpet_Area__c =14,
            EYI_Garden_Area__c =20,
            EYI_Terrace_Area__c='50',
            EYI_Balcony_Area__c='30',
            EYI_Built_up_Area__c= 10,
            EYI_Common_Area__c=10,
            EYI_Inventory_Status__c='Reserve',
            EYI_Floor_Number__c='003',
            Configuration__c='Studio',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I',
            EYI_Saleable_Area__c = 5
        );
        insert invtry;
        User user = EYI_TestDataFactory.createUser('Test User', 'Sales');
        EYI_Customer_Information_Form__c testCIF1 = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'TestFirstName',
            EYI_Last_Name__c = 'TestLastName',
            EYI_Email_Id__c = 'test@salesforce.com',
            EYI_Mobile_number__c = '9876543210',
            EYI_Secondary_Mobile_Number__c = '9876543210',
            EYI_Project_Type__c = 'Commercial',
            EYI_Address_1__c = 'testAddress',
            EYI_Property__c = 'Golden Bell',
            EYI_Budget__c = '2-4 Cr',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Walk_in_Source__c = 'PREC',
            //EYI_Walk_in_Sub_source__c = 'IVR',
            EYI_Closing_Manager__c = user.Id,
             EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c= 'Maharashtra'
            //EYI_Lead_Enquiry__c = testLeadEnquiry.Id
        );
        insert testCIF1;
        
        Opportunity opp = new Opportunity(
            //SyncedQuoteId = quote.id,
            EYI_Inventory__c= invtry.id,
            //EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
            EYI_Project_Tower_Enquired__c= towerobj.id,
            //EYI_Primary_Applicant__c=applicant.id,
            EYI_Salutation__c='Mr.',
            Name='Tushar test',
            StageName ='Cancellation',
            CloseDate = system.today()+20,
            EYI_First_Name__c='Tushar test',
            EYI_Last_Name__c='testOPP',
            EYI_CIF_Record__c = testCIF1.Id,
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
            EYI_Walk_in_Source__c = 'PREC',
            EYI_Ownership_Status__c ='Accepted'
        );
        insert opp;
        
        EYI_Payment_Receipt__c paymentReceipt = new EYI_Payment_Receipt__c(
        	EYI_Transaction_Type__c = 'Advance',
            EYI_Amount__c = 1000,
            EYI_Bank_Name__c = 'Axis Bank',
            EYI_Instrument_Number__c = '1234',
            EYI_Instrument_Date__c = System.today(),
            EYI_Currency_Key__c = 'INR',
            EYI_SAP_Error__c = '12345',
            EYI_Is_Syc__c = true,
            EYI_SAP_Payment_Advice_Number__c = '12345',
            EYI_Opportunity__c = opp.id
        );
        insert paymentReceipt;
        
        EYI_Payment_Line_Item__c paymentLineItem = new EYI_Payment_Line_Item__c(
        	EYI_Total_Amount__c = 12000,
            EYI_Status__c = 'Rejected',
            EYI_SAP_External_Id__c = 'EYI_SAP_External_Id__c123',
            EYI_Principal_Tax_Amount__c = 123,
            EYI_Adjustment_Amount__c = 123,
            EYI_Payment_Receipt__c = paymentReceipt.id,
            EYI_Fiscal_Year__c = 12,
            EYI_Number_of_Line_Items__c = '123456789',
            EYI_Billing_Document__c = 'EYI_Billing_Document__c',
            EYI_Milestone_No__c = '123456789',
            EYI_Unit_Code_SAP__c = '1234554321',
            EYI_Adjustment_Type__c = 'SC',
            EYI_FL_Document_Number__c = 'DOC001',
            EYI_Special_G_L_Indicator__c = 'A',
            EYI_Doc_Type__c = 'AA',
            EYI_Customer_Reference__c = 'EYI_Customer_Reference__c'
        );
        insert paymentLineItem;
        return opp.id;
    }
    
    public static String testData1(){
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
            EYI_Project_Property_Type__c = 'Residential'
        );
        insert projctobj;
        
        EYI_Tower__c towerobj = new EYI_Tower__c(
            Name = 'Balewadi Tower A',
            EYI_Stage__c = 'Pre-Launch',
            EYI_Pass_Code__c = 'BTA',
            EYI_Project_Name__c = projctobj.id,
            EYI_RERA_Certificate_Date__c = System.today() - 10,
            EYI_RERA_Number__c = 'A43242343',
            EYI_RERA_Possesion_Date__c = System.today() - 15,
            EYI_Tower_Number__c = 'A01',
            EYI_Tower_Property_Type__c = 'Apartments;Shops',
            EYI_SAP_Delivery_Plant_Code__c = 'R15D',
            EYI_SAP_Plant_ID__c = 'R15I', 
            EYI_Total_Car_Park__c = 1,
            EYI_Onboarding_Manager__c = UserInfo.getUserId(),
            EYI_Relationship_Manager__c = UserInfo.getUserId()
        );
        insert towerobj;
        
        Account Acc = new Account(
            Name='test Account',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Email__c='nilesh.ghodke@in.ey.com',
            EYI_Date_Of_Birth__c= system.today()-10
        );
        insert Acc;
        
        EYI_City__c city = new EYI_City__c(
            Name='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405'
        );
        insert city;
        EYI_Panchshil_Master__c mster = new EYI_Panchshil_Master__c(
            //Name='Pune',
            EYI_City__c='Pune',
            EYI_State__c='Maharashtra',
            EYI_Pincode__c='410405',
            Master_Type__c='Pincode',
            EYI_Zone__c ='Pune Region',
            EYI_Sub_Urb__c='Pune Moffusil Division'
        );
        insert mster;
        
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
        

		
        
        Opportunity opp = new Opportunity(
            //SyncedQuoteId = quote.id,
            //EYI_Inventory__c= invtry.id,
            EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
            EYI_Project_Tower_Enquired__c= towerobj.id,
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
            EYI_Walk_in_Source__c = 'PREC',
            EYI_Ownership_Status__c ='Accepted'
        );
        insert opp;
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            //EYI_Booking__c=book.id,
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            EYI_Inventory_Type__c ='Residential Sales',
            EYI_UOM__c ='Square foot',
            EYI_Material_Group__c='Apartment',
            EYI_Super_Built_up_Area__c=20,
            EYI_Carpet_Area__c =14,
            EYI_Garden_Area__c =20,
            EYI_Terrace_Area__c='50',
            EYI_Balcony_Area__c='30',
            EYI_Built_up_Area__c= 10,
            EYI_Common_Area__c=10,
            EYI_Inventory_Status__c='Reserve',
            EYI_Floor_Number__c='003',
            Configuration__c='Studio',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I',
            EYI_Opportunity__c = opp.Id,
            EYI_Saleable_Area__c = 5
        );
        insert invtry;
        
        /*invtry.EYI_Opportunity__c = opp.Id;
        invtry.EYI_AutomationBypassDatetime__c = System.Now();
        update invtry;*/
        return opp.id;
    }
    
    @isTest
    public static void getApiDataTest(){
        String recordID = testData();
        System.debug('recordID : '+recordID);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SAPGatewayMock());
		EYI_SAP_DemandReceiptController.getApiData(recordID);
        Test.stopTest();
    }
    
    @isTest
    public static void createLineItemsWithReceiptTest(){
        
        String oppId = testData1();
       
        System.debug('oppId :: '+oppId);
        Map<String, Object> formData = new Map<String, Object>{
            'TransactionType' => 'Advance',
            'PaymentAmount' => '1000.00',
             'advanceAmount' => '0',
            'BankName' => 'ICICI Bank',
            'ChequeDdNumber' => '123456',
            'paymentMode' => 'Cheque',
            'InstrumentNumber' => 'INSTR123',
            'InstrumentDate' => String.valueOf(Date.today()),
               'RealizationDate' => String.valueOf(Date.today()),
             'Remark' => 'test',
                'ReceivedFrom' =>'akshay',
                'CategoryofFunnding' =>'Own Contribution'
        };
            
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        System.debug('oppId ::: '+oppId);
        ContentVersion cv = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('dummy content')
        );
        insert cv;
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = oppId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    System.debug('docId : '+docId);
        //Id fileId = (Id)'0695g00000ABCDEFAA3';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccessPaymentResponse());
        EYI_SAP_DemandReceiptController.createLineItemsWithReceipt(updatedRecords, oppId, formData, docId);
        Test.stopTest();
    }
    
    @isTest
    public static void testOpportunityInfo(){
        String recordID = testData(); 
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new SAPGatewayMock()); // Add this line
        EYI_SAP_DemandReceiptController.getOpportunityInfo(recordID);
        //EYI_SAP_DemandReceiptController.getPaymentReceiptList(recordID);
        Test.stopTest();
        
    }
    @isTest
    public static void createLineItemsWithReceiptTest1(){
        
        String oppId = testData1();
       
       
        System.debug('oppId :: '+oppId);
        Map<String, Object> formData = new Map<String, Object>{
            'TransactionType' => 'Demand',
            'PaymentAmount' => '18000.00',
             'advanceAmount' => '20000.00',
            'BankName' => 'ICICI Bank',
            'ChequeDdNumber' => '123456',
            'paymentMode' => 'Cheque',
            'InstrumentNumber' => 'INSTR123',
            'InstrumentDate' => String.valueOf(Date.today()),
             'Remark' => 'test',
                'ReceivedFrom' =>'akshay',
                'CategoryofFunnding' =>'Own Contribution'
        };
            
        List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        updatedRecords.add(new Map<String, Object>{
            'fiDocumentNo' => 'DOC001',
            'inputValue' => '3000.00',
            'amountLocalCurrency' => '18000.00',
                'outstanding' => '15000',
            'paymentBifurcation' => 'SC',
            'unitCodeSAP' => 'UNIT002',
            'milestoneNo' => 'MS002',
            'billingDoc' => 'BILL002',
            'DOC_TYPE' => 'DZ',
            'SP_GL_IND' => 'A',
            'ITEM_NUM' => '003',
            'fiscalYear' => '2024',
            'lineItemNo' => '001',
                'PSTNG_DATE' => String.valueOf(Date.today())
        });
        System.debug('oppId ::: '+oppId);
        ContentVersion cv = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('dummy content')
        );
        insert cv;
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = oppId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    System.debug('docId : '+docId);
        
        //Id fileId = (Id)'0695g00000ABCDEFAA3';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccessPaymentResponse());
        EYI_SAP_DemandReceiptController.createLineItemsWithReceipt(updatedRecords, oppId, formData, docId);
        //EYI_SAP_DemandReceiptController.createLineItems(updatedRecords,pr.Id,oppId,DECIMAL.ValueOf('2200000'),DECIMAL.ValueOf('19000'));
        Test.stopTest();
    }
    
     @isTest
    static void testCheckDuplicateNumber() {
        // Test data
        String recordID = testData();
        EYI_Payment_Receipt__c pr = new EYI_Payment_Receipt__c(
            EYI_Instrument_Number__c = 'INS123',
            EYI_Opportunity__c =recordID,
            EYI_Check_number__c = 'CHK456',
            EYI_Bank_Name__c = 'HDFC',
            EYI_Payment_Status__c = 'APPROVE'
        );
        insert pr;
              

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SAPGatewayMock()); // or appropriate mock
        EYI_SAP_DemandReceiptController.checkDuplicateNumber('InstrumentNumber','INS123','HDFC');
        EYI_SAP_DemandReceiptController.checkDuplicateNumber('','INS123','HDFC');
        EYI_SAP_DemandReceiptController.checkDuplicateNumber('ChequeDdNumber','INS123','HDFC');
        EYI_SAP_DemandReceiptController.checkDuplicateNumber('','INS123','HDFC');
        Test.stopTest();
    }
  
    
    @isTest
    public static void testPaymentReceiptList(){
        
        String oppId = testData1();
        
        EYI_Payment_Receipt__c paymentReceipt = new EYI_Payment_Receipt__c(
        	EYI_Transaction_Type__c = 'Demand',
            EYI_Amount__c = 1000,
            EYI_Bank_Name__c = 'Axis Bank',
            EYI_Instrument_Number__c = '1234',
            EYI_Instrument_Date__c = System.today(),
            EYI_Currency_Key__c = 'INR',
            EYI_SAP_Error__c = '12345',
            EYI_Is_Syc__c = true,
            EYI_SAP_Payment_Advice_Number__c = '12345',
            EYI_Opportunity__c =oppId
        );
        insert paymentReceipt;
        
        EYI_Payment_Line_Item__c paymentLineItem = new EYI_Payment_Line_Item__c(
        	EYI_Total_Amount__c = 12000,
            EYI_Status__c = 'Rejected',
            EYI_SAP_External_Id__c = 'EYI_SAP_External_Id__c123',
            EYI_Principal_Tax_Amount__c = 123,
            EYI_Adjustment_Amount__c = 123,
            EYI_Payment_Receipt__c = paymentReceipt.id,
            EYI_Fiscal_Year__c = 12,
            EYI_Number_of_Line_Items__c = '123456789',
            EYI_Billing_Document__c = 'EYI_Billing_Document__c',
            EYI_Milestone_No__c = '123456789',
            EYI_Unit_Code_SAP__c = '1234554321',
            EYI_Adjustment_Type__c = 'ADV',
            EYI_FL_Document_Number__c = 'DOC001',
            EYI_Special_G_L_Indicator__c = 'A',
            EYI_Doc_Type__c = 'AA',
            EYI_Customer_Reference__c = 'EYI_Customer_Reference__c'
        );
        insert paymentLineItem;
        EYI_Booking__c booking = new EYI_Booking__c();
        booking.EYI_SAP_Sales_Order_Number__c ='1234567890';
		booking.EYI_Opportunity_Name__c = 	oppId;
        insert booking;
        
        EYI_Applicants__c app =new EYI_Applicants__c();
        app.EYI_Last_Name__c ='test app';
        app.Opportunity__c = oppId;
        insert app;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SAPGatewayMock()); // or appropriate mock
        EYI_SAP_DemandReceiptController.getPaymentReceiptList(oppId);
        EYI_SAP_DemandReceiptController.getBookingSalesOrder(oppId);
        EYI_SAP_DemandReceiptController.getApplicants(oppId);
            
        Test.stopTest();
    }
    
    @isTest
    public static void getPicklistValuesTest(){
		Test.startTest();
		EYI_SAP_DemandReceiptController.getPicklistValues('Lead', new List<String>{'Status'});
        Test.stopTest();
    }
    
       /* @isTest
    public static void createLineItemsWithReceiptTest2(){
        
        String oppId = testData();
        
        Map<String, Object> formData = new Map<String, Object>{
            'TransactionType' => 'Demand',
            'PaymentAmount' => '2000.00',
                'advanceAmount' => '0',
            'BankName' => 'BankX',
            'ChequeDdNumber' => '789012',
            'paymentMode' => 'Cheque',
            'InstrumentNumber' => 'INST789',
            'InstrumentDate' => String.valueOf(Date.today())
        };
		
		List<Map<String, Object>> updatedRecords = new List<Map<String, Object>>();
        updatedRecords.add(new Map<String, Object>{
            'fiDocumentNo' => 'DOC001',
            'inputValue' => '1500.00',
            'amountLocalCurrency' => '1500.00',
            'paymentBifurcation' => 'OTH',
            'unitCodeSAP' => 'UNIT002',
            'milestoneNo' => 'MS002',
            'billingDoc' => 'BILL002',
            'DOC_TYPE' => 'DZ',
            'SP_GL_IND' => 'A',
            'ITEM_NUM' => '001',
            'fiscalYear' => '2024',
            'lineItemNo' => '001'
        });
        
        ContentVersion testVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Sample file content'),
            IsMajorVersion = true
        );
        insert testVersion;

        // Step 2: Query the ContentDocumentId
        Id fileId;
        testVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion.Id LIMIT 1];
        fileId = testVersion.ContentDocumentId;
                    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccessPaymentResponse());
        EYI_SAP_DemandReceiptController.createLineItemsWithReceipt(updatedRecords, oppId, formData, fileId);
        Test.stopTest();
    }*/
}