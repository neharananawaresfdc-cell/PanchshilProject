/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EYI_BrokerageStatusHistoryUtility {
    @AuraEnabled(cacheable=true)
    public static List<StageHistoryWrapper> getStageHistory(Id brokerageId) {
        List<StageHistoryWrapper> result = new List<StageHistoryWrapper>();
        
        List<EYI_Brokerage__History> historyRecords = [
            SELECT CreatedDate, CreatedBy.Name, CreatedById, Field, OldValue, NewValue
            FROM EYI_Brokerage__History
            WHERE ParentId = :brokerageId AND Field = 'Stages__c'
            ORDER BY CreatedDate ASC
        ];
        
        for (Integer i = 0; i < historyRecords.size(); i++) {
            EYI_Brokerage__History current = historyRecords[i];
            EYI_Brokerage__History next = (i + 1 < historyRecords.size()) ? historyRecords[i + 1] : null;
            
            DateTime currentDate = current.CreatedDate;
            DateTime nextDate = (next != null) ? next.CreatedDate : DateTime.now();
            Long timeSpentMs = nextDate.getTime() - currentDate.getTime();
            Decimal timeSpentDays = (Decimal)timeSpentMs / (1000 * 60 * 60 * 24);
            
            result.add(new StageHistoryWrapper(
                current.CreatedBy.Name,
                current.NewValue,
                timeSpentDays.setScale(2),
                current.CreatedDate
            ));
        }
        return result;
    }

    public class StageHistoryWrapper {
        @AuraEnabled public String userName;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal timeSpentDays;
        @AuraEnabled public DateTime lastModified;

        public StageHistoryWrapper(String userName, Object status, Decimal timeSpentDays, DateTime lastModified) {
            this.userName = userName;
            this.status = String.valueOf(status);
            this.timeSpentDays = timeSpentDays;
            this.lastModified = lastModified;
        }
    }
}