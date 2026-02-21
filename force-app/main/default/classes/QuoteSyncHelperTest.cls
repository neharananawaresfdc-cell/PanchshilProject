@isTest
public class QuoteSyncHelperTest {
    
    @isTest
    public static void testData(){
         Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Test Opportunity';
            testOpportunity.StageName = 'Prospecting';
            testOpportunity.CloseDate = Date.today().addDays(30);
        	insert testOpportunity;
        Quote qut = new Quote(
            Name = 'test quote data',
           // EYI_Inventory__c = inventory.Id,
            EYI_Floor_Rate_Discount_L__c = 2300,
            EYI_Floor_Rate_Discount_PSF__c = 4000,
            EYI_Base_Rate_Discount_PSF__c = 9000,
            EYI_Base_Rate_Discount_L__c = 200,
            EYI_Quoatation_Grand_Total__c = 6000000,
            OpportunityId = testOpportunity.Id
        );
        insert qut;
        
        QuoteSyncHelper.updateSyncedQuoteId(testOpportunity.Id,qut.Id);
    }

}