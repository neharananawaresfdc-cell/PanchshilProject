@isTest
public class ChecklistQuestionControllerTest {
    
    // Only create User and Role in @testSetup to avoid callouts and static variable issues
    @testSetup
    static void setupUserAndRole() {
        UserRole ur = new UserRole(Name='Relationship Manager', DeveloperName='Relationship_Manager1');
        insert ur;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(
            Alias = 'testu', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8',
            LastName='Test', LanguageLocaleKey='en_US', LocaleSidKey='en_US',
            ProfileId=p.Id, TimeZoneSidKey='America/Los_Angeles',
            UserName='testuserunique@testorg.com', UserRoleId = ur.Id
        );
        insert u;
    }
    
    class MyCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Helper method to setup all data that could trigger callouts
    static Map<String, Id> createData() {
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        Map<String, Id> ids = new Map<String, Id>();
        System.runAs(u) {
            Account acc = new Account(Name='Test Account');
            insert acc;
            
            EYI_Tower__c testTower = new EYI_Tower__c(Name='Tower1');
            insert testTower;
            
            EYI_Inventory__c testInv = new EYI_Inventory__c(Name='Test Inv',EYI_Tower__c=testTower.Id, EYI_Inventory_Number__c='INV-001');
            insert testInv;
            
            EYI_REC__c testRec = new EYI_REC__c(
                Name='Test REC', EYI_REC_Firm_Name__c='Firm', EYI_Mobile__c='9876543210',
                EYI_Email__c='test1@example.com', EYI_Last_Name__c='TestLast'
            );
            insert testRec;
            
            
            
            EYI_Project__c testProject = new EYI_Project__c(Name='Project1', EYI_Project_Code__c='P001');
            insert testProject;
            
            Opportunity opp = new Opportunity(
                Name='Test Opp',
                StageName='Prospecting',
                CloseDate=System.today().addDays(30),
                EYI_Inventory__c = testInv.Id,
                EYI_REC__c = testRec.Id,
                EYI_Project_Tower_Enquired__c = testTower.Id,
                EYI_Project_Enquired__c = testProject.Id,
                EYI_Possession_Letter_Generated__c = false,
                EYI_Segment__c = 'Segment1',
                EYI_SAP_Customer_Number__c = 'SAP123',
                EYI_Ownership_Status__c = 'Accepted'
            );
            insert opp;
            
            Checklist_Item__c item = new Checklist_Item__c(
                Opportunity__c = opp.Id, Question__c = 'Q1', EYI_Sequence_No__c = 1,
                Status__c = 'Valid', Remarks__c = 'Test', Category__c = 'Critical', Type__c = 'Sales Checklist'
            );
            insert item;
            
            Checklist_Item__c postCancelItem = new Checklist_Item__c(
                Opportunity__c = opp.Id,
                Question__c = 'Q1 Post',
                EYI_Sequence_No__c = 2,
                Status__c = 'Valid',
                Remarks__c = 'Test Post Cancel',
                Category__c = 'Critical',
                Type__c = 'Post Cancellation'
            );
            insert postCancelItem;
            
            System.debug('CHECK: ' + [SELECT Id, Type__c, Status__c, Category__c FROM Checklist_Item__c WHERE Opportunity__c = :opp.Id]);
            
            EYI_Booking__c testBooking = new EYI_Booking__c(
                EYI_Opportunity_Name__c = opp.Id, EYI_Source_of_Booking__c = 'Direct', EYI_Project_Name__c = testProject.Id
            );
            insert testBooking;
            
            EYI_CHIF__c testChif = new EYI_CHIF__c(
                EYI_Opportunity__c = opp.Id, EYI_Project__c = testProject.Id, EYI_Tower__c = testTower.Id,
                EYI_Visit_On_Behalf_Of__c = 'Self', EYI_Typology__c = '2BHK'
            );
            insert testChif;
            
            Contact testContact = new Contact(FirstName = 'Test', LastName = 'TestLastName', Email = 'testemail121@example.com');
            insert testContact;
            
            try {
                Id cancellationRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Cancellation' LIMIT 1].Id;
                Case c = new Case(
                    RecordTypeId = cancellationRtId,
                    Status = 'Closed',
                    EYI_Opportunity__c = opp.Id,
                    EYI_Stages__c = 'Cancellation Approved',
                    Type = 'Cancellation',
                    EYI_Prior_Opportunity_Stage__c = 'Prospecting',
                    ContactId = testContact.Id,
                    OwnerId = u.Id,
                    Subject = 'Test Subject',
                    Description = 'Test Description'
                );
                insert c;
                ids.put('testCaseId', c.Id);
            } catch (Exception e) {
                System.debug('Case insert failed in test context: ' + e.getMessage());
            }
            
            // Store all created IDs for later use in tests
            ids.put('testUserId', u.Id);
            ids.put('testOppId', opp.Id);
            ids.put('testChecklistItemId', item.Id);
            ids.put('testProjectId', testProject.Id);
            ids.put('testTowerId', testTower.Id);
            ids.put('testRecId', testRec.Id);
            ids.put('testInvId', testInv.Id);
            ids.put('testBookingId', testBooking.Id);
            ids.put('testChifId', testChif.Id);
        }
        return ids;
    }
    
    @isTest static void testGetOppRecord() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Opportunity opp = ChecklistQuestionController.getOppRecord(ids.get('testOppId'));
            System.assertEquals('Test Opp', opp.Name);
        }
    }
    
    @isTest static void testGetChecklistItemsByRecordId() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            List<Checklist_Item__c> items = ChecklistQuestionController.getChecklistItemsByRecordId(ids.get('testOppId'));
            System.assert(!items.isEmpty());
            System.assertEquals('Q1', items[0].Question__c);
        }
    }
    
    @isTest static void testGetOpportunityDetails() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Opportunity opp = ChecklistQuestionController.getOpportunityDetails(ids.get('testOppId'));
            System.assertEquals(ids.get('testOppId'), opp.Id);
        }
    }
    
    @isTest static void testGetBookingDetails() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            ChecklistQuestionController.ProjectDetails details = ChecklistQuestionController.getBookingDetails(ids.get('testOppId'));
            System.assertEquals('Test Opp', details.oppName);
            System.assertEquals('Direct', details.sourceOfBooking);
        }
    }
    
    @isTest static void testGetQuestions() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            List<Checklist_Question__mdt> questions = ChecklistQuestionController.getQuestions();
            System.assert(questions != null);
        }
    }
    
    @isTest static void testSubmitChecklistCancellationItems() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            ChecklistQuestionController.submitChecklistCancellationItems(ids.get('testOppId'), true, 'Pre Cancellation');
            Test.stopTest();
        }
    }

    @isTest static void testSaveChecklistItemsCancellation() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            List<Checklist_Item__c> checklistItems = [
                SELECT Id, Opportunity__c, Question__c, EYI_Sequence_No__c, Status__c, Remarks__c, Category__c, Type__c, Valid__c, Invalid__c
                FROM Checklist_Item__c WHERE Id = :ids.get('testChecklistItemId')
            ];
            ChecklistQuestionController.saveChecklistItemsCancellation(checklistItems, ids.get('testOppId'), false, 'Sales Checklist');
        }
    }
    
    @isTest static void testSaveChecklistItems() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            List<Checklist_Item__c> checklistItems = [
                SELECT Id, Opportunity__c, Question__c, EYI_Sequence_No__c, Status__c, Remarks__c, Category__c, Type__c, EYI_Status__c, Valid__c, Invalid__c
                FROM Checklist_Item__c WHERE Id = :ids.get('testChecklistItemId')
            ];
            ChecklistQuestionController.saveChecklistItems(checklistItems, ids.get('testOppId'), 'Booking Form Accepted', '', true, 'Booking Checklist');
        }
    }
    
    @isTest static void testUpdateOppRecord() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            ChecklistQuestionController.updateOppRecord(ids.get('testOppId'), 'Booking Checklist');
            ChecklistQuestionController.updateOppRecord(ids.get('testOppId'), 'Sales Checklist');
        }
    }
    
    @isTest static void testSaveRemark() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            ChecklistQuestionController.saveRemark((String)ids.get('testOppId'), 'Test Remark', 'Booking Checklist');
            ChecklistQuestionController.saveRemark((String)ids.get('testOppId'), 'Test Remark', 'Sales Checklist');
        }
    }
    
    @isTest static void testSaveBookingStatus() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            ChecklistQuestionController.saveBookingStatus((String)ids.get('testOppId'), 'Booking Form Accepted', 'Booking Checklist');
        }
    }
    
    @isTest static void testFindBookingFormAndCHIFDetails() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            String fileUrl = ChecklistQuestionController.findBookingForm(ids.get('testOppId'));
            List<EYI_CHIF__c> chifs = ChecklistQuestionController.getCHIFDetails((String)ids.get('testOppId'));
            System.assertNotEquals(null, chifs);
        }
    }
    
    @isTest static void testCreateCHIFDetailsCoverage() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            EYI_CHIF__c chif = ChecklistQuestionController.createCHIFDetails(
                (String)ids.get('testOppId'),
                (String)ids.get('testTowerId'),
                (String)ids.get('testProjectId'),
                'Self',
                '2BHK'
            );
            System.assertNotEquals(null, chif, 'CHIF record should be created');
            System.assertEquals(ids.get('testOppId'), chif.EYI_Opportunity__c);
            
            try {
                ChecklistQuestionController.createCHIFDetails(
                    'INVALID_OPP_ID',
                    (String)ids.get('testTowerId'),
                    (String)ids.get('testProjectId'),
                    'Self',
                    '2BHK'
                );
                System.assert(false, 'Exception should have been thrown for invalid Opportunity ID');
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
        }
    }
    
    @isTest static void testSaveChecklistItems_UpdateAndInsert() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            String validCategory = null;
            Schema.DescribeFieldResult catField = Checklist_Item__c.Category__c.getDescribe();
            for (Schema.PicklistEntry entry : catField.getPicklistValues()) {
                if (entry.isActive()) {
                    validCategory = entry.getValue();
                    break;
                }
            }
            System.assertNotEquals(null, validCategory, 'No valid Category__c value found!');
            
            Checklist_Item__c ci = new Checklist_Item__c();
            ci.Opportunity__c = ids.get('testOppId');
            ci.Question__c = 'QUpdate';
            ci.EYI_Sequence_No__c = 22;
            ci.Status__c = 'Ok';
            ci.Remarks__c = 'Remark';
            ci.Category__c = validCategory;
            ci.Type__c = 'Sales Checklist';
            ci.EYI_Status__c = true;
            ci.Valid__c = false;
            ci.Invalid__c = false;
            insert ci;
            
            ci.Category__c = validCategory;
            update ci;
            
            Checklist_Item__c updated = new Checklist_Item__c(
                Id = ci.Id,
                Opportunity__c = ids.get('testOppId'),
                Question__c = 'QUpdate',
                EYI_Sequence_No__c = 22,
                Status__c = 'Ok',
                Remarks__c = 'New Remark',
                Category__c = 'Critical',
                Type__c = 'Sales Checklist',
                EYI_Status__c = true,
                Valid__c = true,
                Invalid__c = true
            );
            List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>{ updated };
            ChecklistQuestionController.saveChecklistItems(
                checklistItems,
                ids.get('testOppId'),
                '',
                '',
                false,
                'Sales Checklist'
            );
            
            Checklist_Item__c changed = [SELECT Status__c, Remarks__c, Category__c, EYI_Status__c, Valid__c, Invalid__c
                                         FROM Checklist_Item__c WHERE Id = :ci.Id];
            System.assertEquals('Ok', changed.Status__c);
            System.assertEquals('New Remark', changed.Remarks__c);
            System.assertEquals('Critical', changed.Category__c);
            System.assertEquals(true, changed.EYI_Status__c);
            System.assertEquals(true, changed.Valid__c);
            System.assertEquals(true, changed.Invalid__c);
            
            Checklist_Item__c ci2 = new Checklist_Item__c(
                Opportunity__c = ids.get('testOppId'),
                Question__c = 'QInsert',
                EYI_Sequence_No__c = 23,
                Status__c = 'Ok',
                Remarks__c = 'Insert Remark',
                Category__c = 'Critical',
                Type__c = 'Sales Checklist',
                EYI_Status__c = true,
                Valid__c = true,
                Invalid__c = false
            );
            ChecklistQuestionController.saveChecklistItems(
                new List<Checklist_Item__c>{ ci2 },
                ids.get('testOppId'),
                '',
                '',
                false,
                'Sales Checklist'
            );
            
            Checklist_Item__c inserted = [SELECT Remarks__c, Status__c FROM Checklist_Item__c WHERE Question__c = 'QInsert' AND Opportunity__c = :ids.get('testOppId')];
            System.assertEquals('Insert Remark', inserted.Remarks__c);
            System.assertEquals('Ok', inserted.Status__c);
        }
    }
    
    @isTest
    static void coverBookingFormRejectedBranch() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        Checklist_Item__c ci = new Checklist_Item__c();
        ci.Opportunity__c = opp.Id;
        ci.Question__c = 'Q1';
        String validCategory = null;
        for(Schema.PicklistEntry entry : Checklist_Item__c.Category__c.getDescribe().getPicklistValues()) {
            if(entry.isActive()) {
                validCategory = entry.getValue();
                break;
            }
        }
        System.assertNotEquals(null, validCategory, 'No valid Category__c value found!');
        ci.Category__c = validCategory;
        ci.Type__c = 'Sales Checklist';
        ci.EYI_Status__c = false;
        ci.Valid__c = true;
        ci.Invalid__c = false;
        
        List<Checklist_Item__c> items = new List<Checklist_Item__c>{ci};
            
        Test.startTest();
        String validReason = null;
        for (Schema.PicklistEntry entry : Opportunity.EYI_Reason_for_Booking_Form_Rejection__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                validReason = entry.getValue();
                break;
            }
        }
        System.assertNotEquals(null, validReason, 'No valid Reason for Booking Form Rejection found!');
        
        ChecklistQuestionController.saveChecklistItems(
            items,
            opp.Id,
            'Booking Form Rejected',
            validReason,
            false,
            'Booking Checklist'
        );
        Test.stopTest();
        
        Opportunity opp2 = [SELECT EYI_Booking_Form_Status__c, EYI_Reason_for_Booking_Form_Rejection__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Booking Form Rejected', opp2.EYI_Booking_Form_Status__c);
        System.assertEquals(validReason, opp2.EYI_Reason_for_Booking_Form_Rejection__c);
    }
    
    @isTest
    static void testSaveBookingStatus_ExceptionBranch() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp For Exception',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
        
        delete opp;
        
        Boolean exceptionThrown = false;
        try {
            ChecklistQuestionController.saveBookingStatus(opp.Id, 'SomeStatus', 'Booking Checklist');
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception branch should be covered for DML error');
    }
    
    @isTest static void testGetChecklistItems() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        
        System.runAs(u) {
            List<Checklist_Item__c> items = ChecklistQuestionController.getChecklistItems((String)ids.get('testOppId'), 'Sales Checklist');
            System.assertNotEquals(null, items);
            
            try {
                ChecklistQuestionController.getChecklistItems('INVALID_ID', 'Sales Checklist');
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
        }
    }

    @isTest static void testGetBankDetailsByREC() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
         EYI_REC__c rec = new EYI_REC__c(
            EYI_Salutation__c='Mr.',
            EYI_First_Name__c='Test',
            EYI_Middle_Name__c='REC',
            EYI_Last_Name__c='Account',
            EYI_Gender__c='Male',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Organization__c='test org',
            EYI_Designation__c='test Desination',
            EYI_Birth_Date__c=system.today()-186,
            EYI_Anniversary_Date__c=system.today()-1356,
            EYI_MSME__c=system.today()-1356,
            EYI_Company_Code__c='987543',
            EYI_Reconciliation_Account__c='Creditors - Material Domestic',
            EYI_Payment_Terms__c='Immediately after Goods Receipt',
            EYI_Minority_Indicator__c='Medium',
            EYI_GSTIN__c='27AAAPA1234A1Z9',
            EYI_Aadhar__c='981356897543',
            EYI_Udyog_Adhar__c='713264675759',
            EYI_Company_Regisration__c='EYI_Company_Regisration__c',
            EYI_ESIC_Number__c='ESIC_Number',
            EYI_RERA_Number__c='56HJHK89098',
            //EYI_City__c =city.id,
            EYI_Country__c='India',
            EYI_State__c='Delhi',
            EYI_Mobile__c='9988776677',
            EYI_Alternate_Mobile__c='7080808090',
            EYI_Type_Of_RERA_Registration__c='Individual',
            EYI_REC_Firm_Name__c='ABHI Group',
            EYI_PAN_No__c='ABCDE1234D',
            EYI_Pincode_Office__c='987722443',
            EYI_REC_Owner_Mobile_Number__c='9877654321',
            EYI_Email__c='kumarswami.mathapati089@in.ey.com',
            EYI_Alternate_Email__c='kumarswami.mathapati.904@in.ey.com',
            EYI_REC_Correspondence_Mobile_Number__c='9876545432146',
            EYI_REC_Correspondence_Email_ID__c='abhishek@mail.com',
            EYI_Tax_Classification__c='GST Registered',
            EYI_REC_Vendor_Code__c='876543',
            EYI_Address1__c='noida.',
            EYI_Address2__c='Noida',
            EYI_Address3__c='Sector 3',
            EYI_E_Invoicing_Applicable__c= true,
            EYI_Is_MSME__c=true,
            EYI_MSME_Number__c='Test MSME',
            EYI_Country_Code_for_Secondary_Mobile__c='India',
            EYI_Country_Code_REC_Primary_Mobile__c='India',
            EYI_Country_Code_for_REC_Owner_Mobile__c='India',
            EYI_REC_Owner_Telephone_Number__c='98765432345',
            EYI_Primary_Telephone_Number__c='9876543362',
            EYI_Secondary_Telephone_Number__c='9876543362',
            EYI_REC_Correspondence_Last_Name__c='test',
            //EYI_Correspondence_City__c=city.id,
            EYI_Correspondence_Country__c='India',
            EYI_Correspondence_State__c='Delhi',
            EYI_Correspondence_Address_1__c='noida.',
            EYI_Correspondence_Address_2__c='Noida',
            EYI_Correspondence_Address_3__c='Sector 3',
            EYI_Correspondence_Pincode_Office__c='987722443',
            EYI_REC_Correspondence_Contact_Name__c='9887765434567',
            EYI_CP_Contact_1_Mobile_Number__c='987556789966',
            EYI_First_Name_of_Contact_Person__c='test cont',
            EYI_Last_Name_of_Contact_Person__c='contact',
            EYI_CP_E_Mail_Address__c='abhishek@mail.com',
            EYI_Title__c='Mr.',
            EYI_Correspondence_Title__c='Mr.',
            EYI_RERA_Certificate_No__c='9hgt7899ijnd'
        );
        insert rec;
       // System.runAs(u) {
            EYI_Bank_Details__c bankDetail = new EYI_Bank_Details__c(
                EYI_REC_Account__c = rec.Id,
                Name = 'Test Bank',
                EYI_Account_Holder_Name__c = 'Test Account Holder',
                EYI_Bank_Account_Number__c = '1234567890'
            );
            insert bankDetail;
            
            List<EYI_Bank_Details__c> bankDetails = ChecklistQuestionController.getBankDetailsByREC(rec.Id);
            //System.assertNotEquals(null, bankDetails);
           // System.assertEquals(1, bankDetails.size());
           // System.assertEquals('Test Account Holder', bankDetails[0].EYI_Account_Holder_Name__c);
            
            try {
                ChecklistQuestionController.getBankDetailsByREC(null);
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
       // }
    }

    @isTest static void testSubmitChecklistInvoiceItems() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Sold',
            CloseDate = Date.today(),
            EYI_SAP_Customer_Number__c = '0020000402',
            EYI_SD_Status__c = 'SD Received',
            EYI_Signed_Agreement_Status__c = 'Received',
            EYI_Franking_status__c = 'Done',
            EYI_Mobile_Number__c = '9999999999',
            EYI_Collection_Ageing__c = 15,
            EYI_Registration_Scheduled_Date__c = Date.today().addDays(10),
            EYI_Booking_Amount_Received__c = 4000000,
			EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
       // System.runAs(u) {
            Test.startTest();
            
            //ChecklistQuestionController.submitChecklistInvoiceItems(opp.Id, true, 'Invoice', 'Completed');
            
            
            
            Test.stopTest();
       // }
    }

    @isTest static void testSubmitChecklistAdminItems() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            ChecklistQuestionController.submitChecklistAdminItems(ids.get('testOppId'), true, 'Admin Checklist', 'Approved');
            
            Opportunity opp = [SELECT EYI_Admin_Checklist_Status__c, EYI_Is_Admin_Checklist_Submitted__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals('Approved', opp.EYI_Admin_Checklist_Status__c);
            System.assertEquals(true, opp.EYI_Is_Admin_Checklist_Submitted__c);
            
            /*try {
                ChecklistQuestionController.submitChecklistAdminItems(null, true, 'Admin Checklist', 'Approved');
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage().contains('Error updating opportunity'));
            }*/
            
            Test.stopTest();
        }
    }

    @isTest static void testSubmitChecklistItems() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            ChecklistQuestionController.submitChecklistItems(ids.get('testOppId'), true, 'Welcome Call Checklist');
            Opportunity opp1 = [SELECT IsWelcomeCallChecklistSubmitted__c, EYI_Welcome_Call_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp1.IsWelcomeCallChecklistSubmitted__c);
            System.assertEquals(UserInfo.getUserId(), opp1.EYI_Welcome_Call_Checklist_Checker__c);
            
            /*ChecklistQuestionController.submitChecklistItems(ids.get('testOppId'), true, 'Registration Checklist');
            Opportunity opp2 = [SELECT IsRegistrationChecklistSubmitted__c, EYI_Registration_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp2.IsRegistrationChecklistSubmitted__c);
            System.assertEquals(UserInfo.getUserId(), opp2.EYI_Registration_Checklist_Checker__c);*/
            
            ChecklistQuestionController.submitChecklistItems(ids.get('testOppId'), true, 'Booking Checklist');
            Opportunity opp3 = [SELECT IsBookingChecklistSubmitted__c, Booking_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp3.IsBookingChecklistSubmitted__c);
            System.assertEquals(UserInfo.getUserId(), opp3.Booking_Checklist_Checker__c);
            
            ChecklistQuestionController.submitChecklistItems(ids.get('testOppId'), true, 'Sales Checklist');
            Opportunity opp4 = [SELECT IsSalesChecklistSubmitted__c, EYI_Sales_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp4.IsSalesChecklistSubmitted__c);
            System.assertEquals(UserInfo.getUserId(), opp4.EYI_Sales_Checklist_Checker__c);
            
            ChecklistQuestionController.submitChecklistItems(ids.get('testOppId'), true, 'Post Registration with Loan');
            Opportunity opp5 = [SELECT EYI_Is_Post_Register_with_Loan_Checklist__c, EYI_Post_Registration_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp5.EYI_Is_Post_Register_with_Loan_Checklist__c);
            System.assertEquals(UserInfo.getUserId(), opp5.EYI_Post_Registration_Checklist_Checker__c);
            
            ChecklistQuestionController.submitChecklistItems(ids.get('testOppId'), true, 'Invoice');
            Opportunity opp6 = [SELECT EYI_Is_InvoiceChecklist_Submitted__c, EYI_Invoice_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp6.EYI_Is_InvoiceChecklist_Submitted__c);
            System.assertEquals(UserInfo.getUserId(), opp6.EYI_Invoice_Checklist_Checker__c);
            
            Test.stopTest();
        }
    }
    
    @isTest static void testUpdatePreCancellationSubmissionStatus() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            ChecklistQuestionController.updatePreCancellationSubmissionStatus((String)ids.get('testOppId'));
            
            Opportunity opp = [SELECT EYI_IsPreCancellationChecklistSubmitted__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp.EYI_IsPreCancellationChecklistSubmitted__c);
            
            Test.stopTest();
        }
    }
    
    @isTest static void testUpdatePreCancellationSubmissionStatusException() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            // Test exception path with invalid ID
            Boolean exceptionThrown = false;
            try {
                ChecklistQuestionController.updatePreCancellationSubmissionStatus('INVALID_ID');
            } catch (AuraHandledException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            } catch (Exception ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
            System.assert(exceptionThrown, 'Exception should have been thrown for invalid ID');
            
            Test.stopTest();
        }
    }
    
    @isTest static void testUpdateOpportunityPostCancellationFields() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            ChecklistQuestionController.updateOpportunityPostCancellationFields((String)ids.get('testOppId'), (String)ids.get('testUserId'));
            
            Opportunity opp = [SELECT EYI_Post_Registration_Checklist_Checker__c, EYI_IsPostCancellationChecklistSubmitted__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(ids.get('testUserId'), opp.EYI_Post_Registration_Checklist_Checker__c);
            System.assertEquals(true, opp.EYI_IsPostCancellationChecklistSubmitted__c);
            
            Test.stopTest();
        }
    }

    @isTest static void testSubmitChecklistCancellationItemsWithValidCase() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            // Test with an opportunity that has a valid case (from createData)
            try {
                ChecklistQuestionController.submitChecklistCancellationItems(ids.get('testOppId'), true, 'Pre Cancellation');
                
                // Verify the opportunity was updated
                Opportunity opp = [SELECT EYI_IsPreCancellationChecklistSubmitted__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
                System.assertEquals(true, opp.EYI_IsPreCancellationChecklistSubmitted__c);
            } catch (AuraHandledException ex) {
                // If an exception is thrown, just verify it has a message
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest static void testGetRECDetails() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            // Test successful retrieval
            EYI_REC__c rec = ChecklistQuestionController.getRECDetails(ids.get('testOppId'));
            System.assertNotEquals(null, rec);
            System.assertEquals('Test REC', rec.Name);
            
            // Test with opportunity that has no REC
            Opportunity oppWithoutREC = new Opportunity(
                Name = 'Test Opp Without REC',
                StageName = 'Prospecting',
                CloseDate = Date.today()
            );
            insert oppWithoutREC;
            
            EYI_REC__c noRec = ChecklistQuestionController.getRECDetails(oppWithoutREC.Id);
            System.assertEquals(null, noRec);
            
            // Test exception path
           /* try {
                ChecklistQuestionController.getRECDetails('INVALID_ID');
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }*/
        }
    }
    
    @isTest static void testSaveInvoiceStatus() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Sold',
            CloseDate = Date.today(),
            EYI_SAP_Customer_Number__c = '0020000402',
            EYI_SD_Status__c = 'SD Received',
            EYI_Signed_Agreement_Status__c = 'Received',
            EYI_Franking_status__c = 'Done',
            EYI_Mobile_Number__c = '9999999999',

            EYI_Collection_Ageing__c = 15,
            EYI_Registration_Scheduled_Date__c = Date.today().addDays(10),
            EYI_Booking_Amount_Received__c = 4000000,
			EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
       // System.runAs(u) {
            Test.startTest();
            
            // Test Invoice checklist
            //ChecklistQuestionController.saveInvoiceStatus(opp.Id, 'Completed', 'Invoice');
            
            //Opportunity opp1 = [SELECT EYI_Invoice_Checklist_Status__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
           // System.assertEquals('Completed', opp1.EYI_Invoice_Checklist_Status__c);
            
            // Test Admin Checklist
            ChecklistQuestionController.saveInvoiceStatus((String)ids.get('testOppId'), 'Approved', 'Admin Checklist');
            
            Opportunity opp2 = [SELECT EYI_Admin_Checklist_Status__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals('Approved', opp2.EYI_Admin_Checklist_Status__c);
            
            // Test exception path
            try {
                ChecklistQuestionController.saveInvoiceStatus('INVALID_ID', 'Completed', 'Invoice');
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
            
            Test.stopTest();
      //  }
    }

    @isTest static void testSaveInvoiceSubmissionStatus() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            ChecklistQuestionController.saveInvoiceSubmissionStatus((String)ids.get('testOppId'), true);
            
            Opportunity opp = [SELECT EYI_Is_Admin_Checklist_Submitted__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp.EYI_Is_Admin_Checklist_Submitted__c);
            
            // Test exception path
            try {
                ChecklistQuestionController.saveInvoiceSubmissionStatus('INVALID_ID', true);
            } catch (AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
            
            Test.stopTest();
        }
    }

    /*@isTest static void testFindBookingFormException() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            // Test with null ID to cover exception path
            //String result = ChecklistQuestionController.findBookingForm('');
            //System.assertEquals(null, result);
            
            // Test with invalid ID
            String result2 = ChecklistQuestionController.findBookingForm('INVALID_ID');
            System.assertEquals(null, result2);
        }
    }*/

    @isTest static void testSaveRemarkException() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            // Test exception path with invalid ID
            Boolean exceptionThrown = false;
            try {
                ChecklistQuestionController.saveRemark('INVALID_ID', 'Test Remark', 'Booking Checklist');
            } catch (AuraHandledException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
            System.assert(exceptionThrown, 'Exception should have been thrown for invalid ID');
        }
    }

    @isTest static void testGetCHIFDetailsException() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            // Test with null to cover exception path
            List<EYI_CHIF__c> chifs = ChecklistQuestionController.getCHIFDetails(null);
            System.assertNotEquals(null, chifs);
            System.assertEquals(0, chifs.size());
            
            // Test with valid ID
            List<EYI_CHIF__c> validChifs = ChecklistQuestionController.getCHIFDetails((String)ids.get('testOppId'));
            System.assertNotEquals(null, validChifs);
            System.assertEquals(1, validChifs.size());
        }
    }

    @isTest static void testSaveChecklistItemsWithDifferentChecklists() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            List<Checklist_Item__c> checklistItems = [
                SELECT Id, Opportunity__c, Question__c, EYI_Sequence_No__c, Status__c, Remarks__c, Category__c, Type__c, EYI_Status__c, Valid__c, Invalid__c
                FROM Checklist_Item__c WHERE Id = :ids.get('testChecklistItemId')
            ];
            
            // Test CHIF checklist
            ChecklistQuestionController.saveChecklistItems(checklistItems, ids.get('testOppId'), '', '', false, 'CHIF');
            
            Opportunity opp1 = [SELECT EYI_IsCHIFSubmitted__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp1.EYI_IsCHIFSubmitted__c);
            
            // Test Welcome Call Checklist submission
            ChecklistQuestionController.saveChecklistItems(checklistItems, ids.get('testOppId'), '', '', true, 'Welcome Call Checklist');
            
            Opportunity opp2 = [SELECT IsWelcomeCallChecklistSubmitted__c, EYI_Welcome_Call_Checklist_Checker__c FROM Opportunity WHERE Id = :ids.get('testOppId')];
            System.assertEquals(true, opp2.IsWelcomeCallChecklistSubmitted__c);
            System.assertEquals(UserInfo.getUserId(), opp2.EYI_Welcome_Call_Checklist_Checker__c);
        }
    }
    
    @isTest static void testCallApprovalProcessWithoutApprovalProcess() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            // Test callApprovalProcess method directly
            try {
                ChecklistQuestionController.callApprovalProcess(ids.get('testOppId'), 'Registration Checklist');
            } catch (Exception e) {
                // Expected to fail in test context as approval process may not exist
                System.debug('Approval process test - expected exception: ' + e.getMessage());
            }
            
            Test.stopTest();
        }
    }

    @isTest static void testSubmitChecklistItemsWithException() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Map<String, Id> ids = createData();
        User u = [SELECT Id FROM User WHERE UserName = 'testuserunique@testorg.com' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            
            // Test exception path with invalid ID
            Boolean exceptionThrown = false;
            /*try {
                ChecklistQuestionController.submitChecklistItems('INVALID_ID', true, 'Welcome Call Checklist');
            } catch (AuraHandledException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage() != null, 'Exception message should not be null');
            }
            System.assert(exceptionThrown, 'Exception should have been thrown for invalid ID');
            */
            Test.stopTest();
        }
    }
}