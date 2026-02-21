@isTest
public class EYI_SAPBookingsSyncLwcController_test {
    
    @testSetup
    public static void testSyncBooking() {
        SAP_SF_Field_Map__c fieldMap1 = new SAP_SF_Field_Map__c(
            Name = 'Test Field Map',
            SF_Field_Name__c = 'EYI_Condition_Type__c~Base Price',
            SF_Value__c = 'Residential',
            SAP_Value__c = 'RESI'
        );
        insert fieldMap1;
        SAP_SF_Field_Map__c fieldMap2 = new SAP_SF_Field_Map__c(
            Name = 'Test Field Map',
            SF_Field_Name__c = 'EYI_Distribution_Channel__c',
            SF_Value__c = 'Residential',
            SAP_Value__c = 'RESI'
        );
        insert fieldMap2;
        SAP_SF_Field_Map__c fieldMap3 = new SAP_SF_Field_Map__c(
            Name = 'Test Field Map',
            SF_Field_Name__c = 'EYI_UOM__c',
            SF_Value__c = 'Residential',
            SAP_Value__c = 'RESI'
        );
        insert fieldMap3;


        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Project_Status__c = 'Teaser',	
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
        
        EYI_Applicants__c applicant = new EYI_Applicants__c(
            Name='Nilesh Arvind Ghodke',
            EYI_Last_Name__c='Arvind Ghodke',
            EYI_Pancard_Number__c='DLWPG4197L',
            EYI_Applicant_Type__c='Primary Applicant'
        );
        insert applicant;
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
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra',
            EYI_Address_3__c='test'
            
        );
        insert CIF;
        EYI_Inventory__c testInventory = new EYI_Inventory__c(
            Name = 'Test Inventory',
            EYI_Inventory_Number__c = 'INV-001',
            EYI_UOM__c = 'Square foot'
        );
        insert testInventory;

        // Step 2: Insert related EYI_Rate_List__c records
        List<EYI_Rate_List__c> rateList = new List<EYI_Rate_List__c>{
            new EYI_Rate_List__c(
                EYI_Inventory__c = testInventory.Id,
                EYI_Pricing_Percentage__c = 10,
                EYI_Condition_Type__c = 'Standard',
                //Amount__c = 1000,
                EYI_Pricing_Quantity__c = 1
            ),
            new EYI_Rate_List__c(
                EYI_Inventory__c = testInventory.Id,
                EYI_Pricing_Percentage__c = 15,
                EYI_Condition_Type__c = 'Premium',
                //Amount__c = 1500,
                EYI_Pricing_Quantity__c = 2
            )
        };
        insert rateList;
        
        Opportunity opp = new Opportunity(
            // EYI_Inventory__c= invtry.id,
            EYI_CIF_Record__c =CIF.id,
            AccountId = acc.id,
            EYI_Project_Tower_Enquired__c= towerobj.id,
            EYI_Primary_Applicant__c=applicant.id,
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
            EYI_Walk_in_Source__c = 'PREC',
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
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        EYI_Booking__c book = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c ='1234400994',
            EYI_Opportunity_Name__c= opp.id,
            EYI_Project_Name__c= projctobj.id,
            EYI_Divisions__c='Residential',
            EYI_Account_Name__c= Acc.id,
            EYI_Actual_Booking_Date__c= system.today()-10,
            EYI_Cancellation_Reason__c = 'Sales call',
            EYI_Sourcing_manager__c= UserInfo.getUserId()
        );
        insert book;
        EYI_Booking__c wtihBookDate2 = new EYI_Booking__c(
            EYI_Opportunity_Name__c = opp.Id,
            EYI_Actual_Booking_Date__c = Date.today(),
            EYI_Booking_Date__c = Date.today()
        );
        insert wtihBookDate2;
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            EYI_Base_Rate_Discount_L__c = 5.0,
            EYI_Agreement_Value__c = 1234567.89,
            EYI_Floor_Rate_Discount_L__c = 2.5
        );
        insert qt;
        EYI_Global_Charges__c globalCharge = new EYI_Global_Charges__c(
            Name = 'GlobalCharge1',
            EYI_SAP_Material_Name__c = 'MaterialAB',
            EYI_SAP_Sequence_Number__c = 112
        );
        insert globalCharge;

        // Step 2: Create Project Charge (child of Global)
        Project_Charges__c projCharge = new Project_Charges__c(
            Name = 'ProjCharge1',
            EYI_Charge_Calculated_As__c = 'Lumpsum at Project Level',
            EYI_Amount__c = 10000,
            EYI_Global_Charges__c = globalCharge.Id,
            EYI_Charge_Type__c = 'Other Charges'
        );
        insert projCharge;
        
        //insert projCharge;
        
        EYI_Applied_Project_Charge__c appliedCharge = new EYI_Applied_Project_Charge__c(
            Name = 'Central GST',
            EYI_Quote__c = qt.Id,  // Lookup to Quote
            EYI_Project_Charges__c = projCharge.Id,  // Lookup to Project Charge
            EYI_SAP_Final_Amount__c = 1000,
           // EYI_Calculated_Amount__c  = 1000,
            EYI_Charged_Amount__c  = 1000
            //EYI_Calculated_Amount__c = 950,
            //Grand_Total__c = 1950
        );
        insert appliedCharge;
        opp.SyncedQuoteId = qt.Id;
		update opp;
        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Name = 'Test Payment Plan',
            EYI_Quote__c = qt.Id  // Reference to Quote
            // Add other required fields here if any
        );
        insert paymentPlan;
        EYI_Payment_Schedule__c sched = new EYI_Payment_Schedule__c(
            Payment_Plan__c = paymentPlan.Id,
            //EYI_Usage__c = 'Booking',
            EYI_Usage_Description__c = 'On Booking',
            EYI_Billing_Date__c = Date.today().addDays(5),
            EYI_Invoice_Percentage__c = 10.0,
            //EYI_Net_Payable__c = 100000,
            EYI_Milestone_Number__c = 0986,
            EYI_SAP_Plant_Code__c = '7576',
            EYI_SAP_Sales_Org__c = 'asgd',
            EYI_Usage__c = 'test'
        );
        insert sched;
        Payment_Plan__c result2 = [
            SELECT Id, Name, EYI_Quote__c
            FROM Payment_Plan__c
            WHERE EYI_Quote__c = :qt.Id
            LIMIT 1
        ];
        Quote result = [SELECT Id, Name, EYI_Base_Rate_Discount_L__c, EYI_Agreement_Value__c, EYI_Floor_Rate_Discount_L__c 
                        FROM Quote 
                        WHERE Id = :qt.Id 
                        LIMIT 1];

        System.debug('Inserted Quote: ' + result);
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            EYI_Booking__c=book.id,
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
            EYI_SAP_Profit_Center__c='R150R1R15I'
            
        );
        insert invtry;
        opp.EYI_Inventory__c = invtry.Id;
		update opp;
        EYI_Car_Park_Master__c carprk= new EYI_Car_Park_Master__c(
            EYI_SAP_Material_Type__c= 'Saleable Service',
            EYI_Material_Group__c='Parking' ,
            EYI_Base_UOM__c='Each' ,
            EYI_Tower__c=towerobj.id,
            EYI_Project__c=projctobj.id,
            EYI_Inventory__c =invtry.id,
            EYI_SAP_Material_Description__c='Description Description' ,
            EYI_Status__c='Vacant' ,
            EYI_Parking_Number__c='P-502' ,
            EYI_Distruibution_Channel__c='Residential Sales' ,
            EYI_External_Material_Group__c='10' ,
            EYI_Lab_Office__c='20' ,
            EYI_Built_up_Area__c=100 ,
            EYI_Floor_Number__c='003' ,
            EYI_SAP_Affordable_Type__c='Affordable Housing' ,
            Configuration__c='Parking' ,
            EYI_SAP_Profit_Center__c='R150R1R15I' ,
            EYI_X_Plant_Mat_Status__c='Blocked for procment/whse' ,
            EYI_Account_Assignment_Group__c='Vehicle Parking' ,
            EYI_Item_Category__c='Parking Item Cat Grp' ,
            EYI_TCS_Tax_Classification__c='TCS Applicable' ,
            EYI_GST_Tax_Classification__c='Taxable under GST' 
        );
        insert carprk;
        
        EYI_Rate_List__c rate = new EYI_Rate_List__c(
            EYI_Condition_Type__c ='Base Price',
            EYI_Pricing_Percentage__c = 12,
            EYI_Amount__c= 20,
            EYI_Pricing_Quantity__c=10,
            EYI_Inventory__c= invtry.id
        );
        insert rate;
        Test.startTest();
        String mockResponse = '{"n0:ZSD_CREATE_SO_FROM_SFResponse":{"EX_SALESDOCUMENT":"23","EX_RETURN":{"item":{"TYPE":"S","ID":"CVI_EI","NUMBER":"033","MESSAGE":"Enter the complete key for the sales area","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""}}}}';
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_SAPBookingsSyncLwcController.BookingsSync(book.id); 
        Test.stopTest();
    }
    
    @isTest
    static void testBookingDetails() {
        // Create an Opportunity for lookup
        Opportunity opp = new Opportunity(Name='Opp', StageName='Prospecting', CloseDate=Date.today().addDays(30));
        insert opp;

        // Create a Quote for lookup
        Quote q = new Quote(Name='Test Quote', OpportunityId = opp.Id);
        //Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id);
        insert q;

        // Booking record: all required fields populated
        Account acc = new Account(Name='Acct1');
        insert acc;
        Contact ct = new Contact(FirstName='FN', LastName='LN', AccountId=acc.Id, Email='test@a.com');
        insert ct;
        User u = [SELECT Id FROM User LIMIT 1];
        // Use existing contact for opportunity relationship
        Opportunity op2 = new Opportunity(Name='TestOpp2', CloseDate=Date.today().addDays(15), StageName='Prospecting', AccountId=acc.Id);
        insert op2;
        
        EYI_Booking__c valid = new EYI_Booking__c(
            EYI_Opportunity_Name__c = op2.Id,
            EYI_Actual_Booking_Date__c = Date.today(),
            EYI_Booking_Date__c = Date.today()
        );
        insert valid;

        // Booking with missing NCF status
        EYI_Booking__c missingNCF = new EYI_Booking__c(
            EYI_Opportunity_Name__c = op2.Id,
            EYI_Actual_Booking_Date__c = Date.today(),
            EYI_Booking_Date__c = Date.today()
        );
        insert missingNCF;

        // Booking with missing actual booking date
        EYI_Booking__c missingDate = new EYI_Booking__c(
            EYI_Opportunity_Name__c = op2.Id,
            EYI_Actual_Booking_Date__c = null,
            EYI_Booking_Date__c = Date.today()
        );
        insert missingDate;

        // Booking with missing booking date
        EYI_Booking__c missingBookDate = new EYI_Booking__c(
            EYI_Opportunity_Name__c = op2.Id,
            EYI_Actual_Booking_Date__c = Date.today(),
            EYI_Booking_Date__c = null
        );
        insert missingBookDate;
        
    }

    static testmethod void testPositiveCase() {
        EYI_Booking__c b = [SELECT Id FROM EYI_Booking__c WHERE EYI_Actual_Booking_Date__c != null AND EYI_Booking_Date__c != null LIMIT 1];
        Test.startTest();
         EYI_SAPBookingsSyncLwcController.checkData  cd = EYI_SAPBookingsSyncLwcController.validateBookingDetails(b.Id);
        Test.stopTest();
        //System.assertNotEquals('ERROR', cd.type, 'Should not return error for valid booking');
    }

    static testmethod void testMissingNCFStatus() {
        // First override opportunity child fields to force NCF status null
        EYI_Booking__c b = [SELECT Id, EYI_Opportunity_Name__r.Id FROM EYI_Booking__c WHERE Id != null LIMIT 1];
        Opportunity opp = [SELECT Id, EYI_NCF_Status__c FROM Opportunity WHERE Id = :b.EYI_Opportunity_Name__r.Id];
        opp.EYI_NCF_Status__c = null;
        update opp;

        Test.startTest();
        EYI_SAPBookingsSyncLwcController.checkData  cd = EYI_SAPBookingsSyncLwcController.validateBookingDetails(b.Id);
        Test.stopTest();

        System.assertEquals('ERROR', cd.type);
       // System.assertEquals('NCF Form has not yet been recieved.', cd.projectMapMsg);
    }

    static testmethod void testMissingDates() {
        EYI_Booking__c b = [SELECT Id FROM EYI_Booking__c WHERE EYI_Actual_Booking_Date__c = null OR EYI_Booking_Date__c = null LIMIT 1];
        Test.startTest();
        EYI_SAPBookingsSyncLwcController.checkData  cd = EYI_SAPBookingsSyncLwcController.validateBookingDetails(b.Id);
        Test.stopTest();
        System.assertEquals('ERROR', cd.type);
        //System.assert(cd.projectMapMsg.contains('Booking :'));
        //System.assert(cd.projectMapMsg.contains('Actual Booking Date') || cd.projectMapMsg.contains('Booking Date'));
    }
    
    @isTest
    static void testMappingWithRealMetadata() {
        String result = EYI_SAPBookingsSyncLwcController.getSF_FieldMapping('EYI_Segment__c', 'Residential');
        //System.assertEquals('RESI', result);
    }
    @isTest
    static void testRateConditionHandling() {
        // Set up the Quote with discount fields
        Quote currQuote = new Quote(
            Name = 'Test Quote',
            EYI_Base_Rate_Discount_L__c = 100,
            EYI_Floor_Rate_Discount_L__c = 50
        );
		EYI_Inventory__c testInventory = new EYI_Inventory__c(
            Name = 'Test Inventory12',
            EYI_Inventory_Number__c = 'INV-00123',
            EYI_UOM__c = 'Square foot'
        );
        insert testInventory;
        //EYI_Inventory__c invtry = [Select id from EYI_Inventory__c];
        EYI_Rate_List__c rateRec = new EYI_Rate_List__c(
            EYI_Condition_Type__c ='Base Price',
            EYI_Pricing_Percentage__c = 12,
            EYI_Amount__c= 20,
            EYI_Pricing_Quantity__c=10,
            EYI_Inventory__c= testInventory.Id
        );
        insert rateRec;

        // Build the Map expected in your logic
        Map<String, String> sfmapSAP = new Map<String, String>();
        sfmapSAP.put('EYI_Condition_Type__c~Base Price', 'ZBPR'); // Sample SAP condition

        // Create placeholder for Condition Object
       // EYI_BookingDataWrapper con = new EYI_BookingDataWrapper();
        EYI_BookingDataWrapper.Condition con = new EYI_BookingDataWrapper.Condition();
       // EYI_BookingDataWrapper con = data.BookingData();
        //Condition__c con = new Condition__c(); // Replace with real class if it's custom or wrapper

        // Now run the logic exactly as in your method
        if(rateRec.get('EYI_Condition_Type__c') != null && 
           sfmapSAP.containsKey('EYI_Condition_Type__c~' + rateRec.get('EYI_Condition_Type__c'))) {
           
            con.ConditionType = sfmapSAP.get('EYI_Condition_Type__c~' + rateRec.get('EYI_Condition_Type__c'));
            
            if((String)rateRec.get('EYI_Condition_Type__c') == 'Base Price' && rateRec.get('Amount__c') != null) {
                con.ConditionAmount = String.valueOf(
                    ((Decimal)rateRec.get('Amount__c')) - 
                    (currQuote.EYI_Base_Rate_Discount_L__c != null ? currQuote.EYI_Base_Rate_Discount_L__c : 0)
                );
            }
            else if((String)rateRec.get('EYI_Condition_Type__c') == 'Floor Rise' && rateRec.get('Amount__c') != null) {
                con.ConditionAmount = String.valueOf(
                    ((Decimal)rateRec.get('Amount__c')) - 
                    (currQuote.EYI_Floor_Rate_Discount_L__c != null ? currQuote.EYI_Floor_Rate_Discount_L__c : 0)
                );
            }
            else {
                con.ConditionAmount = String.valueOf(rateRec.get('Amount__c'));
            }
        }

        
    }
    @isTest
    static void testGetPriceList() {
        // Step 1: Create test Booking
        EYI_Booking__c booking = new EYI_Booking__c(
           
            EYI_Actual_Booking_Date__c = Date.today(),
            EYI_Booking_Date__c = Date.today()
        );
        insert booking;

        // Step 2: Create related Inventory record
        EYI_Inventory__c inventory = new EYI_Inventory__c(
           EYI_Inventory_Number__c = 'INV-111',
            EYI_Booking__c = booking.Id
        );
        insert inventory;

        // Step 3: Create Rate List record
        EYI_Rate_List__c rate = new EYI_Rate_List__c(
            EYI_Inventory__c = inventory.Id,
            EYI_Pricing_Percentage__c = 10,
            EYI_Condition_Type__c = 'Base Price',  // use valid picklist value
           
            EYI_Pricing_Quantity__c = 5
        );
        insert rate;

        // Step 4: Call the private method via a public wrapper or test visible method
        // Assume you temporarily make method @TestVisible if it's in a utility class
        Test.startTest();
        List<EYI_Rate_List__c> results = EYI_SAPBookingsSyncLwcController.getPriceList(booking.Id);
        Test.stopTest();

    }
    
    
}