public class EYI_RECHandler {
    public static void createRecMappings(Map<Id, EYI_REC__c> recMap) {
        Set<Id> ownerIds = new Set<Id>();
        for (EYI_REC__c rec : recMap.values()) {
            if (rec.OwnerId != null) {
                ownerIds.add(rec.OwnerId);
            }
        }

        // Call future method with REC Ids and Owner Ids
        EYI_RECHelper.createMappings(new List<Id>(recMap.keySet()), ownerIds);
    }
}