public class QuoteSyncHelper {
    @future
    public static void updateSyncedQuoteId(Id opportunityId, Id quoteId) { //0Q09H0000004MQeSAM 
        Opportunity opp = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id = :opportunityId];
        opp.SyncedQuoteId = quoteId;
        update opp;
        
    }
}