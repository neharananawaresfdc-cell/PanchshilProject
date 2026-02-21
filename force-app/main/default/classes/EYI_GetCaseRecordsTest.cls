@isTest
public class EYI_GetCaseRecordsTest {
    
    @TestSetup
    public static void testData(){
        
        // Create a test user for email handling to avoid org-wide email issues
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'test123',
            Email = 'test@panchshil.com.test',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test' + Math.random() + '@panchshil.com.test'
        );
        insert testUser;
        
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
            EYI_Walk_in_Source__c = 'PREC'
        );
        insert opp;
        
        // Get the Post_Sales record type for Case
        Id caseRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Post_Sales' LIMIT 1].Id;

        // Create Case with valid email to avoid flow email issues
        Case caseRec = new Case(
            Status = 'New',
            RecordTypeId = caseRecTypeId,
            Type = 'Post possession',
            EYI_Case_Category__c = 'Requests_PostPossession',
            Origin = 'Phone',
            Subject = 'Test OTP',
            EYI_Opportunity__c = opp.Id,
            SuppliedName = 'Testing 123',
            SuppliedEmail = 'test@panchshil.com.test' // Add valid email to prevent flow errors
        );
        
        // Insert Case record - flows may trigger but won't fail tests
        insert caseRec;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test Doc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert cv;

        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        // Link ContentDocument to the Case via ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedVersion.ContentDocumentId,
            LinkedEntityId = caseRec.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    
	@isTest
    public static void findRelatedCasesTest1(){

        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];        
        
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.CaseId = testCase.Id;
        requestObj.CaseNumber = testCase.CaseNumber;

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();

        // Assertions
        System.assert(response.status);
        System.assertEquals('Records retrieved successfully', response.message);
        System.assertEquals(1, response.cases.size());
        System.assertEquals(testCase.CaseNumber, response.cases[0].CaseNumber);
    }
    
    @isTest
    public static void findRelatedCasesTest2(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.OpportunityId = opp.Id;

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Since OpportunityId is not handled in the actual implementation, should return no records
        System.assertEquals(false, response.status);
        System.assertEquals('No records found ', response.message);
        System.assertEquals(0, response.cases.size());
    }
    
    @isTest
    public static void findRelatedCasesTest3(){
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.CaseId = '500XXXXXXXXXXXX';
        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Assertions for invalid case ID - should return exception message
        System.assertEquals(false, response.status);
        System.assert(response.message.contains('Invalid id'), 'Expected error message to contain "Invalid id" but got: ' + response.message);
        System.assertEquals(0, response.cases.size());
    }
    
    @isTest
    public static void findRelatedCasesBySAPCustomerCodeTest(){
        Opportunity opp = [SELECT Id, EYI_SAP_Customer_Number__c FROM Opportunity LIMIT 1];
        
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.sap_customer_codes = opp.EYI_SAP_Customer_Number__c;

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Assertions
        System.assert(response.status);
        System.assertEquals('Records retrieved successfully', response.message);
        System.assertEquals(1, response.cases.size());
    }
    
    @isTest
    public static void findRelatedCasesWithCommentsTest(){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Create a comment record for the case
        EYI_Comments__c comment = new EYI_Comments__c();
        comment.EYI_Synced_Case__c = testCase.Id;
        comment.EYI_Mobile_App_Comments__c = 'Test comment for mobile app';
        insert comment;
        
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.CaseId = testCase.Id;

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Assertions
        System.assert(response.status);
        System.assertEquals('Records retrieved successfully', response.message);
        System.assertEquals(1, response.cases.size());
        System.assertEquals(1, response.cases[0].comments.size());
        System.assertEquals('Test comment for mobile app', response.cases[0].comments[0].mobileAppComment);
    }
    
    @isTest
    public static void findRelatedCasesExceptionTest(){
        // Test exception handling by providing invalid JSON
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf('Invalid JSON String');
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Assertions for exception handling
        System.assertEquals(false, response.status);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(0, response.cases.size());
        System.assert(response.message.contains('Unexpected character'));
    }
    
    @isTest
    public static void findRelatedCasesEmptyRequestTest(){
        // Test with empty request list
        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Assertions for empty request
        System.assertEquals(false, response.status);
        System.assertEquals('No records found ', response.message);
        System.assertEquals(0, response.cases.size());
    }
    
    @isTest
    public static void findRelatedCasesWithBothCaseIdAndNumberTest(){
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.CaseId = testCase.Id;
        requestObj.CaseNumber = testCase.CaseNumber;

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Assertions
        System.assert(response.status);
        System.assertEquals('Records retrieved successfully', response.message);
        System.assertEquals(1, response.cases.size());
        System.assertEquals(1, response.cases[0].documentLinks.size());
    }
    
    @isTest
    public static void getCaseDocumentPublicUrlsEmptySetTest(){
        // Test getCaseDocumentPublicUrls with empty set
        Map<Id, List<GetCaseWrapper.DocumentDetail>> result = EYI_GetCaseRecords.getCaseDocumentPublicUrls(new Set<Id>());
        
        System.assertEquals(0, result.size());
    }
    
    @isTest
    public static void getCaseDocumentPublicUrlsTest(){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Set<Id> caseIds = new Set<Id>{testCase.Id};
        
        Map<Id, List<GetCaseWrapper.DocumentDetail>> result = EYI_GetCaseRecords.getCaseDocumentPublicUrls(caseIds);
        
        // Should return document details for the case
        System.assert(result.containsKey(testCase.Id));
        System.assertEquals(1, result.get(testCase.Id).size());
        System.assert(result.get(testCase.Id)[0].url != null);
        System.assertEquals('PDF', result.get(testCase.Id)[0].type);
    }
    
    @isTest
    public static void findRelatedCasesNullFieldsTest(){
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.CaseId = testCase.Id;
        requestObj.CaseNumber = ''; // Empty string
        requestObj.sap_customer_codes = null; // Null value

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Should still find the case by CaseId
        System.assert(response.status);
        System.assertEquals('Records retrieved successfully', response.message);
        System.assertEquals(1, response.cases.size());
    }
    
    @isTest
    public static void findRelatedCasesInvalidSAPCustomerCodeTest(){
        GetCaseWrapper.CaseRequest requestObj = new GetCaseWrapper.CaseRequest();
        requestObj.sap_customer_codes = 'INVALID_SAP_CODE';

        String reqBody = JSON.serialize(new List<GetCaseWrapper.CaseRequest>{ requestObj });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/caseSearch/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;

        GetCaseWrapper.CaseResponseWrapper response = EYI_GetCaseRecords.findRelatedCases();
        
        // Should return no records found
        System.assertEquals(false, response.status);
        System.assertEquals('No records found ', response.message);
        System.assertEquals(0, response.cases.size());
    }
}