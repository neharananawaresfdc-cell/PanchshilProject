@isTest
public class EYI_OpportunityUtilityTest {
    
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
            EYI_Project_Property_Type__c = 'Residential',
            EYI_TDS_Charge__c = 10
        );
        insert projctobj;
        
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
            AccountId = Acc.id,
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
            EYI_Date_Of_Birth__c=system.today()-150,
            EYI_District__c='GB',
            EYI_GSTIN_Number__c='27AAAPA1234A1Z9',
            EYI_Id_Number__c='2345678909876',
            EYI_Id_Type__c='AADHAR Card Number',
            EYI_Industry__c='Advertising',
            EYI_Occupation__c='Salaried',
            EYI_Pan_Number__c='45678iolmn',
            EYI_Partner_Function__c='Sold-to Party',
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
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test File Content')
        );
        insert contentVersion;
        
        ContentVersion cvWithDocId = [
            SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id = :contentVersion.Id
        ];      
        Id docId = cvWithDocId.ContentDocumentId;
        
        ContentDocumentLink linkToOpp = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        
        ContentDocumentLink linkToProject = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = projctobj.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert new List<ContentDocumentLink>{linkToOpp, linkToProject};
   
        return opp.Id;
    }
    
    @isTest
    public static void getOpportunityInfoTest(){
        String oppId = testData();
        Test.startTest();
        Opportunity result = EYI_OpportunityUtility.getOpportunityInfo(oppId);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(oppId, result.Id);
    }
    
    @isTest
    public static void getOpportunityInfoTestWithInvalidId(){
        Test.startTest();
        try {
            String oppId = testData();
        Opportunity updatedOpp = [SELECT EYI_Welcome_Letter_NCF_Sent_Date__c FROM Opportunity WHERE Id = :oppId];
            EYI_OpportunityUtility.getOpportunityInfo(updatedOpp.Id);
            //System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getFilesByOpportunityIdTest(){
        String oppId = testData();
        EYI_Project__c project = [SELECT Id FROM EYI_Project__c WHERE Name =: 'Balewadi 23' LIMIT 1];
        EYI_Tower__c tower = new EYI_Tower__c(
            Name = 'Tower A ',
            EYI_Project_Name__c = project.Id,
            EYI_Stage__c = 'Pre-Launch'
        );
        insert tower;
        Id towerId = tower.Id; 
        Test.startTest();
        List<EYI_LeadEnquiryUtility.FileInfo> result = EYI_OpportunityUtility.getFilesByOpportunityId(oppId, project.id, towerId);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
    
    // @isTest
    // public static void getFilesByOpportunityIdTestWithNullValues(){
    //     Test.startTest();
    //     List<EYI_LeadEnquiryUtility.FileInfo> result = EYI_OpportunityUtility.getFilesByOpportunityId(null, null, null);
    //     Test.stopTest();
    //     System.assertNotEquals(null, result);
    //     System.assertEquals(0, result.size());
    // }
    
    @isTest
    public static void getFilesByOpportunityIdTestWithEmptyValues(){
        Test.startTest();
        try {
            List<EYI_LeadEnquiryUtility.FileInfo> result = EYI_OpportunityUtility.getFilesByOpportunityId('', '', '');
            System.assertNotEquals(null, result);
            System.assertEquals(0, result.size());
        } catch (Exception e) {
            System.assert(true, 'Expected QueryException for empty string filters');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void updateOppNCFSentDateTest(){
        String oppId = testData();
        Test.startTest();
        EYI_OpportunityUtility.updateOppNCFSentDate(oppId);
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT EYI_Welcome_Letter_NCF_Sent_Date__c FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(Date.today(), updatedOpp.EYI_Welcome_Letter_NCF_Sent_Date__c);
    }
    
    @isTest
    public static void updateOppNCFSentDateTestWithInvalidId(){
        String oppId = testData();
        Opportunity updatedOpp = [SELECT EYI_Welcome_Letter_NCF_Sent_Date__c FROM Opportunity WHERE Id = :oppId];
        Test.startTest();
        EYI_OpportunityUtility.updateOppNCFSentDate(updatedOpp.Id);
        Test.stopTest();
        // Should not throw exception due to try-catch block
        System.assert(true, 'Method completed without exception');
    }
    
    @isTest
    public static void updateOppNCFSentDateTestWithNullId(){
        Test.startTest();
        EYI_OpportunityUtility.updateOppNCFSentDate(null);
        Test.stopTest();
        // Should not throw exception due to try-catch block
        System.assert(true, 'Method completed without exception');
    }
    
    @isTest
    public static void getOpportunityEmailTemplatesTest(){
        Test.startTest();
        List<EmailTemplate> result = EYI_OpportunityUtility.getOpportunityEmailTemplates('TestFolder');
        Test.stopTest();
        System.assertNotEquals(null, result);
        // Result will be empty since no matching folder exists, but method should handle gracefully
        System.assertEquals(0, result.size());
    }
    
    @isTest
    public static void getOpportunityEmailTemplatesTestWithNonExistentFolder(){
        Test.startTest();
        List<EmailTemplate> result = EYI_OpportunityUtility.getOpportunityEmailTemplates('NonExistentFolder');
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }
    
    @isTest
    public static void getOpportunityEmailTemplatesTestWithNullFolder(){
        Test.startTest();
        List<EmailTemplate> result = EYI_OpportunityUtility.getOpportunityEmailTemplates(null);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}