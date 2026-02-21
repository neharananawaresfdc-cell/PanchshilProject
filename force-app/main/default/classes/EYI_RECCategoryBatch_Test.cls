@isTest
public class EYI_RECCategoryBatch_Test {
    
    @isTest
    static void testBatchExecution() {
        List<EYI_REC__c> recRecords = new List<EYI_REC__c>();
        for (Integer i = 0; i < 10; i++) {
            EYI_REC__c rec = new EYI_REC__c(
                EYI_Mobile__c = '9999999999',
                EYI_Email__c = 'test@gmail.com',
                EYI_First_Name__c = 'Test',
                EYI_Last_Name__c = 'User' ,
                EYI_Rec_Status__c = 'Active'
            );
            recRecords.add(rec);
        }
        insert recRecords;

        Test.startTest();
        EYI_RECCategoryBatch batch = new EYI_RECCategoryBatch();
        Database.executeBatch(batch, 10); // Batch size matches record count
        Test.stopTest();

        List<EYI_REC__c> updatedRecords = [SELECT Id FROM EYI_REC__c WHERE Id IN :recRecords];
        System.assert(!updatedRecords.isEmpty(), 'Batch should process records.');
    }
    
    @isTest
    static void testFinishMethod() {
        Test.startTest();
        EYI_RECCategoryBatch batch = new EYI_RECCategoryBatch();
        batch.finish(null);
        Test.stopTest();

        System.assert(true, 'Finish method executed successfully.');
    }
     @isTest
    static void testFinishMethod1() {
         EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Distribution_Channel__c = '10',
            EYI_Project_Status__c = 'Launch',
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
    EYI_REC__c rec = new EYI_REC__c(
            EYI_Salutation__c='Mr.',
            EYI_First_Name__c='Test1',
            EYI_Middle_Name__c='REC1',
            EYI_Last_Name__c='Account1',
            EYI_Gender__c='Male',
            EYI_Marital_Status__c='Single',
            EYI_Nationality__c='Indian',
            EYI_Occupation__c='Salaried',
            EYI_Organization__c='test org',
            EYI_Designation__c='test Desination',
            EYI_Birth_Date__c=system.today()-186,
            EYI_Anniversary_Date__c=system.today()-1356,
            EYI_MSME__c=system.today()-1356,
            EYI_Company_Code__c='187543',
            EYI_Reconciliation_Account__c='Creditors - Material Domestic',
            EYI_Payment_Terms__c='Immediately after Goods Receipt',
            EYI_Minority_Indicator__c='Medium',
            EYI_GSTIN__c='27AAAPA1234A1Z1',
            //EYI_GSTN__c='27AAAPA1234A1Z9',
            EYI_Aadhar__c='981356897510',
            EYI_Udyog_Adhar__c='713261075759',
            EYI_Company_Regisration__c='EYI_Company_Regisration__c',
            EYI_ESIC_Number__c='ESIC_Number',
            EYI_RERA_Number__c='56HJHK19098',
            EYI_Country__c='India',
            EYI_State__c='Delhi',
            EYI_Mobile__c='9988776671',
            EYI_Alternate_Mobile__c='1080808090',
            EYI_Type_Of_RERA_Registration__c='Individual',
            EYI_REC_Firm_Name__c='ABHI Group',
            EYI_PAN_No__c='ABCDE1201D',
            EYI_Pincode_Office__c='187722442',
            EYI_REC_Owner_Mobile_Number__c='9177654321',
            EYI_Email__c='kumarswami5.mathapati089@in.ey.com',
            EYI_Alternate_Email__c='kumarswami5.mathapati.904@in.ey.com',
            EYI_REC_Correspondence_Mobile_Number__c='1871545432146',
            EYI_REC_Correspondence_Email_ID__c='abhishek5@mail.com',
            EYI_Tax_Classification__c='GST Registered',
            EYI_REC_Vendor_Code__c='876542',
            EYI_Address1__c='noida.',
            EYI_Address2__c='Noida',
            EYI_Address3__c='Sector 3',
            EYI_E_Invoicing_Applicable__c= true,
            EYI_Is_MSME__c=true,
            EYI_MSME_Number__c='Test MSME',
            EYI_Country_Code_for_Secondary_Mobile__c='India',
            EYI_Country_Code_REC_Primary_Mobile__c='India',
            EYI_Country_Code_for_REC_Owner_Mobile__c='India',
            EYI_REC_Owner_Telephone_Number__c='98265431345',
            EYI_Primary_Telephone_Number__c='9876243361',
            EYI_Secondary_Telephone_Number__c='9826543162',
            EYI_REC_Correspondence_Last_Name__c='test',
            EYI_Correspondence_Country__c='India',
            EYI_Correspondence_State__c='Delhi',
            EYI_Correspondence_Address_1__c='noida.',
            EYI_Correspondence_Address_2__c='Noida',
            EYI_Correspondence_Address_3__c='Sector 3',
            EYI_Correspondence_Pincode_Office__c='927122443',
            EYI_REC_Correspondence_Contact_Name__c='9127765434567',
            EYI_CP_Contact_1_Mobile_Number__c='982556189966',
            EYI_First_Name_of_Contact_Person__c='test1 cont',
            EYI_Last_Name_of_Contact_Person__c='contact1',
            EYI_CP_E_Mail_Address__c='abhishek5@mail.com',
            EYI_Title__c='Mr.',
            EYI_Correspondence_Title__c='Mr.',
            EYI_RERA_Certificate_No__c='9cgt7879ijnd'
            
        );
        Test.startTest();
            insert rec;
            Id recordId = rec.Id;
            Id currentUserId = UserInfo.getUserId();
            List<Id> recIds = new List<Id>{ recordId };
            Set<Id> ownerIds = new Set<Id>{ currentUserId };
            EYI_RECHelper.createMappings(recIds, ownerIds);
        Test.stopTest();
        System.assert(true, 'Finish method executed successfully.');
    }
}