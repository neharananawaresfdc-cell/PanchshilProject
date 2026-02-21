public class EYI_RECHelper{
    @future
    public static void createMappings(List<Id> recIds, Set<Id> ownerIds) {
        // Query all projects for the given owners
        String statusLabel = System.Label.EYI_ActiveProjectStatusValues; // "Launch,Post Launch,Sustenance"
        List<String> statusList = new List<String>();
        for (String status : statusLabel.split(',')) {
            statusList.add(status.trim()); // Trim to remove any extra spaces
        }
        List<EYI_Project__c> projects = [
            SELECT Id, Name, EYI_Project_Status__c
            FROM EYI_Project__c
            WHERE EYI_Project_Status__c IN :statusList
        ];

        // Query REC records to get OwnerId mapping
        Map<Id, EYI_REC__c> recMap = new Map<Id, EYI_REC__c>([SELECT Id, OwnerId FROM EYI_REC__c WHERE Id IN :recIds]);

        List<EYI_Project_REC_Mapping__c> mappingsToInsert = new List<EYI_Project_REC_Mapping__c>();

        for (EYI_REC__c rec : recMap.values()) {
            for (EYI_Project__c proj : projects) {
                if (rec.Id != null) {
                    mappingsToInsert.add(new EYI_Project_REC_Mapping__c(
                        EYI_REC_Account__c = rec.Id,
                        EYI_Project__c = proj.Id,
                        EYI_Sourcing_Manager__c = rec.OwnerId
                    ));
                }
            }
        }

        if (!mappingsToInsert.isEmpty()) {
            try {
                insert mappingsToInsert;
            } catch (DMLException e) {
                
            }             
        }
    }
}