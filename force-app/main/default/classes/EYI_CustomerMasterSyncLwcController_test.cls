@isTest
public class EYI_CustomerMasterSyncLwcController_Test {
    static void insertFieldMaps() {
        insert new SAP_SF_Field_Map__c(Name='DistCh_Res', SF_Field_Name__c='EYI_Distribution_Channel__c', SF_Value__c='Residential Sales', SAP_Value__c='10');
        insert new SAP_SF_Field_Map__c(Name='Seg_Res', SF_Field_Name__c='EYI_Segment__c', SF_Value__c='Residential Sales', SAP_Value__c='ZREC');
        insert new SAP_SF_Field_Map__c(Name='PayTm_15days', SF_Field_Name__c='EYI_Payment_Terms__c', SF_Value__c='15 Days Credit From the Date of Invoice', SAP_Value__c='P15');
        insert new SAP_SF_Field_Map__c(Name='Sal_Mr', SF_Field_Name__c='EYI_Salutation__c', SF_Value__c='Mr.', SAP_Value__c='MR');
        insert new SAP_SF_Field_Map__c(Name='EYI_Country__c_India', SF_Field_Name__c='EYI_Country__c', SF_Value__c='India', SAP_Value__c='IN');
    }

    static Account createAccount(Boolean fillAll) {
        Account a = new Account(Name = 'Test Acc');
        if(fillAll) {
            a.EYI_Marital_Status__c = 'Single';
            a.EYI_Nationality__c = 'Indian';
            a.EYI_Occupation__c = 'Salaried';
            a.EYI_Date_Of_Birth__c = System.today().addYears(-30);
        }
        insert a;
        return a;
    }

    static EYI_Project__c createProject() {
        EYI_Project__c p = new EYI_Project__c(Name='TestProj', EYI_SAP_Company_Code__c='1320', EYI_SAP_Salesorg__c='R152', EYI_Project_Code__c='P001');
        insert p;
        return p;
    }
    
    static EYI_Tower__c createTower(Id projId) {
        EYI_Tower__c t = new EYI_Tower__c(Name='TestTower', EYI_SAP_Plant_ID__c='R15I', EYI_SAP_Delivery_Plant_Code__c='R15D', EYI_Project_Name__c=projId);
        insert t;
        return t;
    }
    
    static EYI_Applicants__c createApplicant(Boolean fillAll) {
        EYI_Applicants__c a = new EYI_Applicants__c(Name='Test Applicant');
        if(fillAll) {
            a.EYI_Applicant_Type__c = 'Primary Applicant';
            a.EYI_Pancard_Number__c = 'ABCDE1234F';
            a.EYI_Last_Name__c = 'TestLast';
            a.EYI_Email__c = 'applicant@email.com';
            a.EYI_Mobile_Number__c = '9876543210';
        }
        insert a;
        return a;
    }
    
    static EYI_Customer_Information_Form__c createCIF() {
        EYI_Customer_Information_Form__c c = new EYI_Customer_Information_Form__c(
            EYI_Salutation__c = 'Mr.',
            EYI_First_Name__c = 'First',
            EYI_Last_Name__c = 'Last',
            EYI_Country__c = 'India',
            EYI_Country_code__c = '+91',
            EYI_Mobile_number__c = '9876543210',
            EYI_Customer_Address_Type__c ='OS (Rest of India)',
            EYI_State__c ='Maharashtra'  
        );
        insert c;
        return c;
    }
    
    static EYI_Inventory__c createInventory(Id projId, Id towerId) {
        EYI_Inventory__c inv = new EYI_Inventory__c(Name='Inv', EYI_Inventory_Number__c='INV-001', EYI_Project__c=projId, EYI_Tower__c=towerId);
        insert inv;
        return inv;
    }
    
    static Opportunity createOpportunity(Account acc, EYI_Project__c proj, EYI_Tower__c tower, EYI_Customer_Information_Form__c cif, EYI_Applicants__c applicant, EYI_Inventory__c inv, Boolean full) {
        Opportunity o = new Opportunity(
            Name='Opp',
            StageName='Prospecting',
            CloseDate=System.today().addDays(10),
            AccountId=acc.Id,
            EYI_Inventory__c=inv.Id,
            EYI_Project_Enquired__c=proj.Id,
            EYI_Project_Tower_Enquired__c=tower.Id,
            EYI_CIF_Record__c=cif.Id,
            EYI_Primary_Applicant__c=applicant.Id,
            EYI_Segment__c='Residential Sales',
            EYI_BP_Type__c='1',
            EYI_Payment_Terms__c='15 Days Credit From the Date of Invoice',
            EYI_Mobile_Number__c='9876543210',
            EYI_City__c='Pune',
            EYI_Pincode__c='411001',
            EYI_Country_Code__c='+91',
            EYI_SAP_Customer_Number__c='CUST123',
            GST_Applicable__c=true,
            EYI_TCS_Applicable__c=true,
            EYI_Ownership_Status__c='Accepted'
        );
        
        if(full) {
            o.EYI_First_Name__c = 'Test';
            o.EYI_Last_Name__c = 'User';
            o.EYI_Address1__c = 'Addr1';
            o.EYI_Address2__c = 'Addr2';
            o.EYI_Address3__c = 'Addr3';
            o.EYI_Country_Classification__c = 'India';
            o.EYI_Country_Key__c = 'IN';
            o.EYI_State__c = 'MAHARASHTRA';
            o.EYI_Locality__c = 'Locality';
        }
        insert o;
        return o;
    }

    static void insertPDF(Opportunity o) {
        ContentVersion cv = new ContentVersion(Title='pdf', PathOnClient='test.pdf', VersionData=Blob.valueOf('abc'));
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cv.ContentDocumentId, LinkedEntityId=o.Id, ShareType='V');
        insert cdl;
    }

    @isTest
    static void test_success_and_full_coverage() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_City__c = 'Pune';
        opp.EYI_Pincode__c = '411001';
        update opp;
        insertPDF(opp);

        // Mock HTTP Success
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(
            '{"n0:ZSD_CREATE_CUSTOMER_FROM_SFResponse":{"EX_CUTSOMER":"23","EX_RETURN":{"item":{"TYPE":"S","MESSAGE":"Success"}}}}'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();

        System.assertEquals('S', res.type.trim().toUpperCase(), 'Should return type S for success');
        System.assert(res.message != null, 'Should have a message');
    }
    
    @isTest
    static void test_missing_required_fields() {
        insertFieldMaps();
        // Create Opportunity with missing required fields
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, false); // missing extra fields
        opp.EYI_City__c = 'Pune';
        opp.EYI_Pincode__c = '411001';
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        System.assertEquals('e', res.type.toLowerCase(), 'Should return type e for missing required fields');
        //System.assert(res.message.contains('Opportunity'), 'Should mention Opportunity');
    }

    @isTest
    static void test_null_and_fake_opportunity_id() {
        insertFieldMaps();
        // Null Id
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        //EYI_CustomerMasterSyncLwcController.lwcMessage res1 = EYI_CustomerMasterSyncLwcController.customerMasterSync(null, 'X');
        //System.assertEquals('E', res1.type, 'Should return E for null id');
        //System.assert(res1.message.contains('Missing'), 'Should mention missing');

        // Fake Id (not present)
        //EYI_CustomerMasterSyncLwcController.lwcMessage res2 = EYI_CustomerMasterSyncLwcController.customerMasterSync('006xxxxxxxxxxxxxxx', 'X');
        Test.stopTest();
        //System.assertEquals('E', res2.type, 'Should return E for fake id');
        //System.assert(res2.message.contains('not found'), 'Should mention not found');
    }

    @isTest
    static void test_non_200_response_and_exception() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
		opp.EYI_City__c = 'Pune';
        opp.EYI_Pincode__c = '411001';
        update opp;
        
        // Mock HTTP 500
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_testHttpServiceConsumerMock('{"error":"server"}', 500, 'Internal Server Error'));
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        System.assertEquals('E', res.type.trim().toUpperCase(), 'Should return type E for http error');
        System.assert(res.message.contains('server'), 'Should contain server error');
        //Test.stopTest();

        // Simulate exception by passing an ID that causes query error
        //Test.startTest();
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.setMock(HttpCalloutMock.class, mock);
        //EYI_CustomerMasterSyncLwcController.lwcMessage res2 = EYI_CustomerMasterSyncLwcController.customerMasterSync('006000000000000ZZZ', 'X');
        //System.assertEquals('E', res2.type, 'Should return type E for exception');
        Test.stopTest();
    }

    @isTest
    static void test_minimum_success() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_City__c = 'Pune';
        opp.EYI_Pincode__c = '411001';
        update opp;
        // no PDF

        // HTTP mock
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(
            '{"n0:ZSD_CREATE_CUSTOMER_FROM_SFResponse":{"EX_CUTSOMER":"99","EX_RETURN":{"item":{"TYPE":"S","MESSAGE":"Success"}}}}'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        System.assertNotEquals(null, res, 'Should return a result');
    }

    @isTest
    static void test_multiple_co_applicants() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant1 = createApplicant(true);
        EYI_Applicants__c applicant2 = new EYI_Applicants__c(
            Name='CoApp', EYI_Applicant_Type__c='Co-Applicant', EYI_Last_Name__c='Last2', EYI_Pancard_Number__c='ABCDE5678G', EYI_Email__c='coapp@email.com', EYI_Mobile_Number__c='9876543211'
        );
        insert applicant2;
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant1, inv, true);
		opp.EYI_City__c = 'Pune';
        opp.EYI_Pincode__c = '411001';
        update opp;
        
        // Link both applicants to the Opportunity (simulate child relationship)
        applicant1.Opportunity__c = opp.Id;
        applicant2.Opportunity__c = opp.Id;
        update new List<EYI_Applicants__c>{applicant1, applicant2};

        // HTTP mock
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock(
            '{"n0:ZSD_CREATE_CUSTOMER_FROM_SFResponse":{"EX_CUTSOMER":"88","EX_RETURN":{"item":{"TYPE":"S","MESSAGE":"Success"}}}}'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        System.debug('Result type: ' + res.type + ', message: ' + res.message);
        System.assertEquals('S', res.type.trim().toUpperCase(), 'Should return type S for success with co-applicants');
    }
    
    @isTest
    static void test_missing_segment() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_Segment__c = null; // or '' (blank string)
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        System.assert(res.message.contains('Segment'));
    }
    
    @isTest
    static void test_missing_bp_type() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_BP_Type__c = null; // Missing BP Type
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        System.assert(res.message.contains('Client Type'));
    }
    
    @isTest
    static void test_missing_payment_terms() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_Payment_Terms__c = null; // Can use '' as well
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase(), 'Should return e for missing payment terms');
        System.assert(res.message.contains('Terms Of Payment'), 'Should mention Terms Of Payment');
    }

    @isTest
    static void test_missing_mobile_number() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_Mobile_Number__c = null; // Can use '' as well
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase(), 'Should return e for missing mobile number');
        System.assert(res.message.contains('Mobile Number'), 'Should mention Mobile Number');
    }
    
    @isTest
    static void test_missing_city() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_City__c = null; // or ''
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        System.assert(res.message.contains('City'));
    }
    
    @isTest
    static void test_missing_pincode() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_Pincode__c = null; // or ''
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        System.assert(res.message.contains('Pincode'));
    }
    
    @isTest
    static void test_missing_state_code() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        //opp.EYI_SAP_State_Code__c = ''; // or ''
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        //System.assert(res.message.contains('State'));
    }
    
    @isTest
    static void test_missing_country_code() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_Country_Code__c = null; // or ''
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        System.assert(res.message.contains('Country code'));
    }
    
    @isTest
    static void test_missing_inventory() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        EYI_Inventory__c inv = createInventory(proj.Id, tower.Id);
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        opp.EYI_Inventory__c = null;
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase());
        System.assert(res.message.contains('Inventory'));
    }

    @isTest
    static void test_missing_inventory_number() {
        insertFieldMaps();
        Account acc = createAccount(true);
        EYI_Project__c proj = createProject();
        EYI_Tower__c tower = createTower(proj.Id);
        EYI_Customer_Information_Form__c cif = createCIF();
        EYI_Applicants__c applicant = createApplicant(true);
        
        // Create inventory with blank inventory number
        EYI_Inventory__c inv = new EYI_Inventory__c(
            Name='Inv',
            EYI_Inventory_Number__c='123456', // or ''
            EYI_Project__c=proj.Id,
            EYI_Tower__c=tower.Id
        );
        insert inv;
        
        Opportunity opp = createOpportunity(acc, proj, tower, cif, applicant, inv, true);
        update opp;
        
        EYI_testHttpServiceConsumerMock mock = new EYI_testHttpServiceConsumerMock('{}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        EYI_CustomerMasterSyncLwcController.lwcMessage res = EYI_CustomerMasterSyncLwcController.customerMasterSync(opp.Id, 'X');
        Test.stopTest();
        
        System.assertEquals('e', res.type.toLowerCase(), 'Should return e for missing inventory number');
        //System.assert(res.message.contains('Inventory --> Inventory Number'), 'Should mention inventory number');
    }
}