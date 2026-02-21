@isTest
public class EYI_OpportunityFilesTest {

    @testSetup
    public static void setupTestData() {
        Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Test Opportunity';
            testOpportunity.StageName = 'Prospecting';
            testOpportunity.CloseDate = Date.today().addDays(30);
        	testOpportunity.EYI_Ownership_Status__c = 'Accepted';
        	insert testOpportunity;

        ContentVersion testContentVersion = new ContentVersion();
            testContentVersion.Title = 'Test Document';
            testContentVersion.PathOnClient = 'Test.pdf';
            testContentVersion.VersionData = Blob.valueOf('Test File Content');
        	insert testContentVersion;
        
        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId 
                                                 FROM ContentVersion 
                                                 WHERE Id = :testContentVersion.Id];
        
        ContentDocumentLink docLink = new ContentDocumentLink();
            docLink.LinkedEntityId = testOpportunity.Id;
            docLink.ShareType = 'V';
        	docLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
        	insert docLink;
    }

    @isTest
    public static void testGetOpportunityFiles() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        EYI_OpportunityFiles.getOpportunityFiles(opp.Id);
        Test.stopTest();        
    }
}