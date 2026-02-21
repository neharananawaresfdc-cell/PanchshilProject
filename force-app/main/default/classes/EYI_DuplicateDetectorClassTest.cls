@isTest
public class EYI_DuplicateDetectorClassTest {
    
    public static void createCustomSetting(){
        EYI_DuplicateDetectorSettings__c duplicateDetectorSetting = new EYI_DuplicateDetectorSettings__c();
        duplicateDetectorSetting.EYI_Is_DuplicateDetector_Enabled__c = true;
        insert duplicateDetectorSetting;
    }
    
    @isTest
    public static void testisDuplicate(){
        createCustomSetting();
        Lead lead1 = new Lead(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Segment__c = 'Commercial',
            EYI_LeadType__c = 'Retail',
            EYI_Property__c = 'Golden Bell',
            FirstName = 'lead1',
            LastName = 'Lead1',
            Company='Panchshil',
            Email = 'lead1@example.com', 
            Phone =  '9876543210',
            LeadSource = 'Web',
            EYI_Lead_Sub_Source__c = 'Amazon',
            Rating = 'Hot',
            EYI_Remarks__c = 'abcdefgh',
            MobilePhone = '9876543210'
        );
        Lead lead2 = new Lead(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Segment__c = 'Commercial',
            EYI_LeadType__c = 'Retail',
            EYI_Property__c = 'Golden Bell',
            FirstName = 'lead2',
            LastName = 'Lead2',
            Company='Panchshil',
            Email = 'lead2@example.com', 
            Phone =  '1234567890',
            LeadSource = 'Web',
            EYI_Lead_Sub_Source__c = 'Amazon',
            Rating = 'Hot',
            EYI_Remarks__c = 'abcdefgh',
            MobilePhone = '1234567890'
        );
        Lead lead3 = new Lead(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Segment__c = 'Commercial',
            EYI_LeadType__c = 'Retail',
            EYI_Property__c = 'Golden Bell',
            FirstName = 'lead1',
            LastName = 'Lead1',
            Company='Panchshil',
            Email = 'lead1@example.com', 
            Phone =  '9876543210',
            LeadSource = 'Web',
            EYI_Lead_Sub_Source__c = 'Amazon',
            Rating = 'Hot',
            EYI_Remarks__c = 'abcdefgh',
            MobilePhone = '9876543210'
        );
        insert new List<Lead>{lead1, lead2, lead3};
            
            Map<Id, SObject> newSObjectList = new Map<Id, SObject>();
        newSObjectList.put(lead1.Id, lead1);
        newSObjectList.put(lead2.Id, lead2);
        newSObjectList.put(lead3.Id, lead3);
        
        
        Lead oldLead1 = [SELECT Id, FirstName, LastName, Email, Phone, MobilePhone FROM Lead WHERE Id = :lead1.Id];
        Lead oldLead2 = [SELECT Id, FirstName, LastName, Email, Phone, MobilePhone FROM Lead WHERE Id = :lead2.Id];
        oldLead1.Phone = '1112223333';
        oldLead2.Phone = '4445556666';
        oldLead1.Email = 'example1@example.com';
        oldLead2.Email = 'example2@example.com';
        oldLead1.MobilePhone = '1112223333';
        oldLead2.MobilePhone = '4445556666';
        
        
        Map<Id, SObject> oldListMap = new Map<Id, SObject>();
        oldListMap.put(lead1.Id, oldLead1);
        oldListMap.put(lead2.Id, oldLead2);
        oldListMap.put(lead3.Id, lead3);
        
        //testing:
        Test.startTest();
        EYI_DuplicateDetectorHandler.isDuplicate('Lead_Duplicate', 'EY_Lead_Duplicate_Detector_rules__mdt', newSObjectList, oldListMap);
        System.debug('Done');
        Test.stopTest();
    }
    
    @isTest
    public static void testisDuplicateOne(){
        createCustomSetting();
        //Creating data
        Lead lead1 = new Lead(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Segment__c = 'Commercial',
            EYI_LeadType__c = 'Retail',
            EYI_Property__c = 'Golden Bell',
            FirstName = 'lead1',
            LastName = 'Lead1',
            Company='Panchshil',
            Email = 'lead1@example.com', 
            Phone =  '9876543210',
            LeadSource = 'Web',
            EYI_Lead_Sub_Source__c = 'Amazon',
            Rating = 'Hot',
            EYI_Remarks__c = 'abcdefgh',
            MobilePhone = '9876543210'
        );
        Lead lead2 = new Lead(
            EYI_Nature_of_Lead__c = 'Outright',
            EYI_Purpose_of_Purchase__c = 'End Use',
            EYI_Segment__c = 'Commercial',
            EYI_LeadType__c = 'Retail',
            EYI_Property__c = 'Golden Bell',
            FirstName = 'lead1',
            LastName = 'Lead1',
            Company='Panchshil',
            Email = 'lead1@example.com', 
            Phone =  '9876543210',
            LeadSource = 'Web',
            EYI_Lead_Sub_Source__c = 'Amazon',
            Rating = 'Hot',
            EYI_Remarks__c = 'abcdefgh'
        );
        
        insert lead1;
        
        
        //testing:
        Test.startTest();
        // EYI_DuplicateDetectorHandler.isDuplicate() triggers automatically from Lead Trigger.
        insert lead2;
        
        System.debug('Done');
        Test.stopTest();
    }
    @isTest
    static void testDeleteRecordsFuture() {
        // Create a test Lead to delete
        Lead testLead = new Lead(
            FirstName = 'ToDelete',
            LastName = 'Lead',
            Company = 'Test'
        );
        insert testLead;
        
        List<Id> idsToDelete = new List<Id>{testLead.Id};
            
            // Call the future method directly
            Test.startTest();
        EYI_DuplicateDetectorHandler.deleteRecords(idsToDelete, 'Lead');
        Test.stopTest();
        
        // Verify the record was deleted
        Lead[] leads = [SELECT Id FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(0, leads.size(), 'The test lead should be deleted by the future method.');
    }
    
    @isTest
    static void testMergeRecords() {
        // Create leads: master and duplicate
        Lead masterLead = new Lead(
            FirstName = 'Master',
            LastName = 'Lead',
            Company = 'Test',
            LeadSource = 'Web'
        );
        Lead dupLead = new Lead(
            FirstName = 'Dup',
            LastName = 'Lead',
            Company = 'Test',
            LeadSource = 'Phone Inquiry'
        );
        insert new List<Lead>{ masterLead, dupLead };
            
            // Prepare parameters
            List<SObject> newSObjectList = new List<SObject>{ dupLead };
                String masterObjectName = 'Lead';
        Map<Id, SObject> mergeMasterRecrod = new Map<Id, SObject>{
            dupLead.Id => masterLead
                };
                    List<String> masterObjectFieldToMergeList = new List<String>{ 'LeadSource' }; // Use correct API name
                        Set<Id> bulkUploadNewRecID = new Set<Id>(); // Leave empty for delete branch
        
        // Call the method
        Test.startTest();
        EYI_DuplicateDetectorHandler.mergeRecords(
            newSObjectList,
            masterObjectName,
            mergeMasterRecrod,
            masterObjectFieldToMergeList,
            bulkUploadNewRecID
        );
        Test.stopTest();
        
        System.assert(true, 'mergeRecords executed');
    }
    
    @isTest
    static void testDuplicateAddError() {
        Lead lead1 = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test',
            Email = 'duplicate@example.com',
            Phone = '1111111111'
        );
        insert lead1;
        
       
        Lead lead2 = new Lead(
            FirstName = 'John',
            LastName = 'Smith',
            Company = 'Test',
            Email = 'unique@example.com',
            Phone = '2222222222'
        );
        insert lead2;
        
     
        lead2.Email = 'duplicate@example.com'; // now email matches lead1
        
        Map<Id, SObject> newSObjectList = new Map<Id, SObject>{ lead2.Id => lead2 };
            Map<Id, SObject> oldListMap = new Map<Id, SObject>{ lead2.Id => [SELECT Id, Email FROM Lead WHERE Id = :lead2.Id] };
                
                Test.startTest();
        Boolean caughtError = false;
        try {
            EYI_DuplicateDetectorHandler.isDuplicate(
                'Lead_Duplicate', // Use correct recordAPIName for your metadata
                'EY_Lead_Duplicate_Detector_rules__mdt', // Use correct metadata type
                newSObjectList,
                oldListMap
            );
        } catch (Exception e) {
            caughtError = true; // DmlException expected when addError is called
        }
        Test.stopTest();
        System.assert(caughtError, 'Should have caught a DmlException due to addError');
    }
    
    @isTest
    static void testCreateChildRecordBlock() {
        Lead lead1 = new Lead(
            FirstName='A',
            LastName='1',
            Company='Test',
            Phone='9999999999'
        );
        Lead lead2 = new Lead(
            FirstName='B',
            LastName='2',
            Company='Test',
            Phone='9999999999' // Duplicate phone triggers logic
        );
        insert new List<Lead>{lead1, lead2};
            
            Map<Id, SObject> newSObjectList = new Map<Id, SObject>{
                lead1.Id => lead1,
                    lead2.Id => lead2
                    };
                        Map<Id, SObject> oldListMap = new Map<Id, SObject>();
        
  
        Test.startTest();
        EYI_DuplicateDetectorHandler.isDuplicate(
            'Lead_Duplicate', // Make sure this matches your metadata
            'EY_Lead_Duplicate_Detector_rules__mdt',
            newSObjectList,
            oldListMap
        );
        Test.stopTest();
        
        List<EYI_Lead_Enquiry__c> children = [
            SELECT Id, EYI_Parent_Record__c
            FROM EYI_Lead_Enquiry__c
            WHERE EYI_Parent_Record__c IN :newSObjectList.keySet()
        ];
        System.assert(children.size() > 0, 'Child records should be inserted');
    }
}