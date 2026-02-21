/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class EYI_LeadConvertionClassTest {
    //Test class for EYI_LeadConvertionClass methods:
    //Testing updateLeadOnCif method
    @isTest
    public static void testUpdateLeadOnCIF(){
        //Setting the customSetting to False
        EYI_Notification_Settings__c customSetting = new EYI_Notification_Settings__c();
        customSetting.EYI_Is_Notifications_Enabled__c = False;
        insert customSetting;
        
        //Lead Creation
        Lead testLead = EYI_TestDataFactory.createLeads('TestLead','Abc', 1, '9876543210', 'Web', 'AIC', true)[0];
        
        //Lead enquiry creation with projectId and leadId
        EYI_Lead_Enquiry__c testLeadEnquiry = new EYI_Lead_Enquiry__c(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Segment__c = 'Commercial',
            EYI_Lead_Status__c = 'Open',
            EYI_LeadType__c = 'Retail',
            EYI_Parent_Record__c = testLead.Id,
            Name = 'testLeadEnquiry',
            EYI_Company__c = 'Panchsil',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Project_Enquired__c = testLead.EYI_Project_Enquired__c,
            EYI_Phone__c = '9876543210',
            EYI_Mobile__c = '9876543210',
            EYI_Email__c = 'test@salesforce.com',
            EYI_Lead_Source__c = 'Email',
            //EYI_Lead_Sub_Source__c = 'Email',
            EYI_Property__c = 'Golden Bell',
            EYI_Rating__c = 'Hot'
        );
        insert testLeadEnquiry;
    
        // Creating an Account - Used in Opportunity creation:
        Account testAccount = EYI_TestDataFactory.createAccounts('Test Account', 1, true)[0];//Account creation
        
        //Creating a User - Used in CIF creation:
        User user = EYI_TestDataFactory.createUser('Test User', 'Sales');
        
       
        //Creating a CIF
        EYI_Customer_Information_Form__c testCIF = new EYI_Customer_Information_Form__c(
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
            EYI_Lead_Enquiry__c = testLeadEnquiry.Id,
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert testCIF;
    
        //Creating a Lead Enquiry with CIF & projectName
        //String leadEnquiryId = EYI_TestDataFactory.createLead(testCIF, 'Golden Bell');
    
        //Creating an Opportunity
        Opportunity opprec = new Opportunity(
            Name = 'testOppRec',
            AccountId = testAccount.Id,
            CloseDate = System.today(),
            StageName = 'Walk-in',
            OwnerId = user.Id,
            EYI_AutomationBypassDatetime__c =  System.now(),
            EYI_Converted_Lead_Enquiry__c = testLeadEnquiry.Id,
            EYI_CIF_Record__c = testCIF.Id,
            EYI_First_Name__c = testCIF.EYI_First_Name__c,
            EYI_Last_Name__c = testCIF.EYI_Last_Name__c,
            EYI_Property__c = testCIF.EYI_Property__c
        );
        insert opprec;
    
        //Creating a REC Account:
        EYI_REC__c testRec = new EYI_REC__c(
            EYI_First_Name__c = 'TestFirstName',
            EYI_Last_Name__c = 'TestLastName',
            EYI_Mobile__c = '0000000009',
            EYI_Email__c = 'test@salesforce.com',
            EYI_Type_Of_RERA_Registration__c = 'Individual',
            EYI_RERA_Registered__c = 'Yes',
            EYI_RERA_Certificate_No__c = 'ABCDEFGHIJKL',
            EYI_PAN_No__c = 'ABCDE1234A',
            EYI_REC_Correspondence_Contact_Name__c = 'TestFirstName',
            EYI_REC_Correspondence_Email_ID__c = 'test@salesforce.com',
            EYI_REC_Correspondence_Mobile_Number__c = '0000000009',
            EYI_REC_Team_Size__c = 10,
            EYI_REC_Subregion__c = 'Thane',
            EYI_REC_Firm_Address__City__s = 'Pune',
            EYI_REC_Firm_Address__CountryCode__s = 'IN',
            EYI_REC_Firm_Address__GeocodeAccuracy__s = null,
            EYI_REC_Firm_Address__Latitude__s = null,
            EYI_REC_Firm_Address__Longitude__s = null,
            EYI_REC_Firm_Address__PostalCode__s = '12345',
            EYI_REC_Firm_Address__StateCode__s = 'AN',
            EYI_REC_Firm_Address__Street__s = 'testStreet',
            EYI_REC_Ticket_Size__c = '1cr',
            EYI_Product_Type__c = 'Retail',
            EYI_Stage_Of_Operation__c = 'New Launch',
            EYI_Marketing_Approach__c = 'Digital',
            EYI_Area_Of_Operation__c = 'City',
            EYI_Primary_Market__c = 'Pune',
            Expertise__c = 'Fresh',
            EYI_Top_Project_1__c = 'TestTopProject1'
        );
        insert testRec;
        
        //Calling the method:
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_ProjectSyncToMobileApp_Mock());
        EYI_LeadConvertionClass.updateLeadOnCIF(testCIF.Id, testRec.Id, testLeadEnquiry.Id, opprec.Id);
        Test.stopTest();
        
        // Checking:
        testCIF = [SELECT Id, EYI_Opportunity__c, EYI_Lead_Enquiry__c FROM EYI_Customer_Information_Form__c WHERE Id = :testCIF.Id];
        if(testCIF.EYI_Opportunity__c != null){
            System.debug('Opportunity updated');
        }
        else{
            System.debug('Opportunity not updated');
        }
    }    
    
    
     //Testing updatesOnLeadEnquiry method
    @isTest
    public static void testUpdatesOnLeadEnquiry(){
        //Setting the customSetting to False
        EYI_Notification_Settings__c customSetting = new EYI_Notification_Settings__c();
        customSetting.EYI_Is_Notifications_Enabled__c = False;
        insert customSetting;
        
        //Test Data Creation
        //Creating a Record Account
        EYI_REC__c testRec = new EYI_REC__c(
            EYI_First_Name__c = 'TestFirstName',
            EYI_Last_Name__c = 'TestLastName',
            EYI_Mobile__c = '0000000009',
            EYI_Email__c = 'test@salesforce.com',
            EYI_Type_Of_RERA_Registration__c = 'Individual',
            EYI_RERA_Registered__c = 'Yes',
            EYI_RERA_Certificate_No__c = 'ABCDEFGHIJKL',
            EYI_PAN_No__c = 'ABCDE1234A',
            EYI_REC_Correspondence_Contact_Name__c = 'TestFirstName',
            EYI_REC_Correspondence_Email_ID__c = 'test@salesforce.com',
            EYI_REC_Correspondence_Mobile_Number__c = '0000000009',
            EYI_REC_Team_Size__c = 10,
            EYI_REC_Subregion__c = 'Thane',
            EYI_REC_Firm_Address__City__s = 'Pune',
            EYI_REC_Firm_Address__CountryCode__s = 'IN',
            EYI_REC_Firm_Address__GeocodeAccuracy__s = null,
            EYI_REC_Firm_Address__Latitude__s = null,
            EYI_REC_Firm_Address__Longitude__s = null,
            EYI_REC_Firm_Address__PostalCode__s = '12345',
            EYI_REC_Firm_Address__StateCode__s = 'AN',
            EYI_REC_Firm_Address__Street__s = 'testStreet',
            EYI_REC_Ticket_Size__c = '1cr',
            EYI_Product_Type__c = 'Retail',
            EYI_Stage_Of_Operation__c = 'New Launch',
            EYI_Marketing_Approach__c = 'Digital',
            EYI_Area_Of_Operation__c = 'City',
            EYI_Primary_Market__c = 'Pune',
            Expertise__c = 'Fresh',
            EYI_Top_Project_1__c = 'TestTopProject1'
        );
        insert testRec;
        
        //Lead Creation
        Lead testLead = EYI_TestDataFactory.createLeads('TestLead','ABC', 1, '9876543210', 'Web', 'AIC', true)[0];
        //Lead enquiry creation with projectId and leadId
        EYI_Lead_Enquiry__c testLeadEnquiry = new EYI_Lead_Enquiry__c(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Segment__c = 'Commercial',
            EYI_Lead_Status__c = 'Open',
            EYI_LeadType__c = 'Retail',
            EYI_Parent_Record__c = testLead.Id,
            Name = 'testLeadEnquiry',
            EYI_Company__c = 'Panchsil',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Project_Enquired__c = testLead.EYI_Project_Enquired__c,
            EYI_Phone__c = '9876543210',
            EYI_Email__c = 'test@salesforce.com',
            EYI_Lead_Source__c = 'Email',
            //EYI_Lead_Sub_Source__c = 'Email',
            EYI_Property__c = 'Golden Bell',
            EYI_Rating__c = 'Hot'
        );
        insert testLeadEnquiry;
        
        
        // Creating an Account - Used in Opportunity creation:
        Account testAccount = EYI_TestDataFactory.createAccounts('Test Account', 1, true)[0];//Account creation
        
        //Creating a User - Used in CIF creation:
        User user = EYI_TestDataFactory.createUser('Test User', 'Sales');
        
       
        //Creating a CIF
        EYI_Customer_Information_Form__c testCIF = new EYI_Customer_Information_Form__c(
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
            //EYI_Walk_in_Sub_source__c = 'Google',
            EYI_Closing_Manager__c = user.Id,
            EYI_Lead_Enquiry__c = testLeadEnquiry.Id,
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert testCIF;
    
        //Creating an Opportunity
        Opportunity opprec = new Opportunity(
            Name = 'testOppRec',
            AccountId = testAccount.Id,
            CloseDate = System.today(),
            StageName = 'Walk-in',
            OwnerId = user.Id,
            EYI_AutomationBypassDatetime__c =  System.now(),
            EYI_Converted_Lead_Enquiry__c = testLeadEnquiry.Id,
            EYI_CIF_Record__c = testCIF.Id,
            EYI_First_Name__c = testCIF.EYI_First_Name__c,
            EYI_Last_Name__c = testCIF.EYI_Last_Name__c,
            EYI_Property__c = testCIF.EYI_Property__c
            
        );
        insert opprec;
        
        //Testing
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_ProjectSyncToMobileApp_Mock());
        EYI_LeadConvertionClass.updatesOnLeadEnquiry(opprec.Id, testLeadEnquiry.Id, testRec.Id);
        Test.stopTest();
        //Checking if update is successfull
        testLeadEnquiry = [SELECT Id, EYI_Lead_Status__c, EYI_AutomationBypassDatetime__c FROM EYI_Lead_Enquiry__c WHERE Id = :testLeadEnquiry.Id];
        
        if(testLeadEnquiry.EYI_Lead_Status__c == 'Visit Done'){
            System.debug('Updated Successfully');
        }
        else{
            System.debug('Updated UnSuccessfully');
        }
    }
    
 
    @isTest
    public static void testConvertLeadEnquiryToOpp(){
        //Setting the customSetting to False
        EYI_Notification_Settings__c customSetting = new EYI_Notification_Settings__c();
        customSetting.EYI_Is_Notifications_Enabled__c = False;
        insert customSetting;
        
        //Lead Creation
        Lead testLead = EYI_TestDataFactory.createLeads('TestLead','ABC', 1, '9876543210', 'Web', 'AIC', true)[0];
        //Lead enquiry creation with projectId and leadId
        EYI_Lead_Enquiry__c testLeadEnquiry = new EYI_Lead_Enquiry__c(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Segment__c = 'Commercial',
            EYI_Lead_Status__c = 'Open',
            EYI_LeadType__c = 'Retail',
            EYI_Parent_Record__c = testLead.Id,
            Name = 'testLeadEnquiry',
            EYI_Company__c = 'Panchshil',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Project_Enquired__c = testLead.EYI_Project_Enquired__c,
            EYI_Phone__c = '9876543210',
            EYI_Email__c = 'test@salesforce.com',
            EYI_Lead_Source__c = 'Email',
            //EYI_Lead_Sub_Source__c = 'Email',
            EYI_Property__c = 'Golden Bell',
            EYI_Rating__c = 'Hot'
        );
        insert testLeadEnquiry;
        
        //Creating a User - Used in CIF creation:
        User user = EYI_TestDataFactory.createUser('Test User', 'Sales');
        
       
        //Creating a CIF
        EYI_Customer_Information_Form__c testCIF = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'TestFirstName',
            EYI_Last_Name__c = 'TestLastName',
            EYI_Email_Id__c = 'test@salesforce1.com',
            EYI_Mobile_number__c = '9876543210',
            EYI_Secondary_Mobile_Number__c = '9876543210',
            EYI_Project_Type__c = 'Commercial',
            EYI_Address_1__c = 'testAddress',
            EYI_Property__c = 'Golden Bell',
            EYI_Lead_Enquiry__c = testLeadEnquiry.Id,
            //EYI_Budget__c = 'NA',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Walk_in_Source__c = 'Web',
            EYI_Walk_in_Sub_source__c = 'Google',
            EYI_Closing_Manager__c = user.Id,
            EYI_Project_Enquired__c = testLead.EYI_Project_Enquired__c,
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert testCIF;
        
        //Testing
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_ProjectSyncToMobileApp_Mock());
        String opportunityId = EYI_LeadConvertionClass.convertLeadEnquiryToOpp(testCIF.Id);
        Test.stopTest();
        
        //Checking
        Opportunity createdOpp = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id = :opportunityId];
        if(createdOpp.StageName == 'Walk-in'){
            System.debug('Opportunity Created Successfully');
        }
        else{
            System.debug('Opportunity Not Created');
        }
    }

    //Testing getCIFData method
    @isTest
    public static void testGetCIFData() {
        //Setting the customSetting to False
        EYI_Notification_Settings__c customSetting = new EYI_Notification_Settings__c();
        customSetting.EYI_Is_Notifications_Enabled__c = False;
        insert customSetting;
        
        //Lead Creation
        Lead testLead = EYI_TestDataFactory.createLeads('TestLead','ABC', 1, '9876543210', 'Web', 'AIC', true)[0];
        //Lead enquiry creation with projectId and leadId
        EYI_Lead_Enquiry__c testLeadEnquiry = new EYI_Lead_Enquiry__c(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Segment__c = 'Commercial',
            EYI_Lead_Status__c = 'Open',
            EYI_LeadType__c = 'Retail',
            EYI_Parent_Record__c = testLead.Id,
            Name = 'testLeadEnquiry',
            EYI_Company__c = 'Panchsil',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Project_Enquired__c = testLead.EYI_Project_Enquired__c,
            EYI_Phone__c = '9876543210',
            EYI_Email__c = 'test@salesforce.com',
            EYI_Lead_Source__c = 'Email',
            //EYI_Lead_Sub_Source__c = 'Email',
            EYI_Property__c = 'Golden Bell',
            EYI_Rating__c = 'Hot'
        );
        insert testLeadEnquiry;
    
        
        //Creating a User - Used in CIF creation:
        User user = EYI_TestDataFactory.createUser('Test User', 'Sales');
        
       
        //Creating a CIF
        EYI_Customer_Information_Form__c testCIF = new EYI_Customer_Information_Form__c(
            EYI_First_Name__c = 'TestFirstName',
            EYI_Last_Name__c = 'TestLastName',
            EYI_Email_Id__c = 'test@salesforce.com',
            EYI_Mobile_number__c = '9876543210',
            EYI_Secondary_Mobile_Number__c = '9876543210',
            EYI_Project_Type__c = 'Commercial',
            EYI_Address_1__c = 'testAddress',
            EYI_Property__c = 'Golden Bell',
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Budget__c = '2-4 Cr',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Walk_in_Source__c = 'PREC',
            //EYI_Walk_in_Sub_source__c = 'Google',
            EYI_Closing_Manager__c = user.Id,
            EYI_Customer_Address_Type__c = 'OS (Rest of India)',
            EYI_State__c = 'Maharashtra'
        );
        insert testCIF;

        
        //testing
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EYI_ProjectSyncToMobileApp_Mock());
        List<EYI_Customer_Information_Form__c> cifRecords = EYI_LeadConvertionClass.getCIFData(testCIF.Id, new List<String>{'EYI_Mobile_number__c', 'EYI_Email_Id__c'});
        Test.stopTest();
        //Checking if CIF is returned:
        if(cifRecords.size()>0){
            System.debug('Customer Information Records are returned Successfully');
        }
        else{
            System.debug('Customer Information Records are not returned');
        }
    }

    //Testing getAllCustomMetadata (Last method)
    @isTest
    public static void testGetAllCustomMetadata() {
        //testing:
        Test.startTest();
        List<EYI_Lead_Conversion_Metadata__mdt> customMetadataRecords = EYI_LeadConvertionClass.getAllCustomMetadata('Lead_Conversion', 'EYI_Lead_Conversion_Metadata__mdt');
        Test.stopTest();
        //Aserts:
        if(customMetadataRecords.size()>0){
            System.debug('customMetadataRecords--> '+customMetadataRecords);
            System.debug('getAllCustomMetaData fetching is successfull');
        }
        else{
            System.debug('getAllCustomMetaData fetching is unsuccessfull');
        }
    }
    
    
    
}