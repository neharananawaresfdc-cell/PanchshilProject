public class EYI_RateListTriggerHandler {
    
    public static void handleBeforeInsert(List<EYI_Rate_List__c> newRateLists){
        Set<Id> projectIds = new Set<Id>();
        Set<Id> towerIds = new Set<Id>();
        Map<Id, Id> rateListToGlobalCharge = new Map<Id, Id>();
        Set<Id> globalChargeId = new Set<Id>();
        
        for (EYI_Rate_List__c rl : newRateLists) {
            if (rl.EYI_Project__c != null) {
                projectIds.add(rl.EYI_Project__c);
            }
            if (rl.EYI_Tower__c != null) {
                towerIds.add(rl.EYI_Tower__c);
            }
            if (rl.EYI_Global_Charges__c != null) {
                rateListToGlobalCharge.put(rl.Id, rl.EYI_Global_Charges__c);
                globalChargeId.add(rl.EYI_Global_Charges__c);
            }
        }
        
        Map<Id, String> globalChargeToCalculationType = new Map<Id, String>();
        Map<Id, String> globalChargeToConditionType = new Map<Id, String>();
        
        List<EYI_Global_Charges__c> globalChargeList = [
            SELECT Id, EYI_Condition_Type__c, EYI_SAP_Calculation_Type__c
            FROM EYI_Global_Charges__c
            WHERE Id IN :globalChargeId
        ];
        System.debug('globalChargeList : '+globalChargeList);
        if(globalChargeList.size() > 0){
            for (EYI_Global_Charges__c gbCharge : globalChargeList) {
                globalChargeToCalculationType.put(gbCharge.Id, gbCharge.EYI_SAP_Calculation_Type__c);
                globalChargeToConditionType.put(gbCharge.Id, gbCharge.EYI_Condition_Type__c);
            }
            System.debug('globalChargeToCalculationType : '+globalChargeToCalculationType);
            System.debug('globalChargeToConditionType : '+globalChargeToConditionType);
            
            List<Project_Charges__c> existingProjectCharges = [
                SELECT Id, EYI_Global_Charges__c,EYI_Charge_Type__c, EYI_Project__c, EYI_Tower__c,EYI_Active__c
                FROM Project_Charges__c
                WHERE (EYI_Project__c IN :projectIds OR EYI_Tower__c IN :towerIds)
                      AND EYI_Global_Charges__c != null AND EYI_Charge_Type__c='Pricing Charges' AND EYI_Active__c = true
            ];
            
            
            Set<Id> conflictingGlobalCharges = new Set<Id>();
            Map<Id, Set<Id>> projectToGlobalCharges = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> towerToGlobalCharges = new Map<Id, Set<Id>>();
            for (Project_Charges__c pc : existingProjectCharges) {
                if (pc.EYI_Project__c != null) {
                    if (!projectToGlobalCharges.containsKey(pc.EYI_Project__c)) {
                        projectToGlobalCharges.put(pc.EYI_Project__c, new Set<Id>());
                    }
                    projectToGlobalCharges.get(pc.EYI_Project__c).add(pc.EYI_Global_Charges__c);
                }
                if (pc.EYI_Tower__c != null) {
                    if (!towerToGlobalCharges.containsKey(pc.EYI_Tower__c)) {
                        towerToGlobalCharges.put(pc.EYI_Tower__c, new Set<Id>());
                    }
                    towerToGlobalCharges.get(pc.EYI_Tower__c).add(pc.EYI_Global_Charges__c);
                }
            }
            System.debug('projectToGlobalCharges : '+projectToGlobalCharges);
            System.debug('towerToGlobalCharges : '+towerToGlobalCharges);
            
            for (EYI_Rate_List__c rl : newRateLists) {
                System.debug('rl.EYI_Global_Charges__c : '+rl.EYI_Global_Charges__c);
                if (rl.EYI_Global_Charges__c == null){
                    rl.addError('Global Charge can not be blank');
                }
                if (globalChargeToCalculationType.containsKey(rl.EYI_Global_Charges__c)) {
                    rl.EYI_Calculation_Type__c = globalChargeToCalculationType.get(rl.EYI_Global_Charges__c);
                }
                if (globalChargeToConditionType.containsKey(rl.EYI_Global_Charges__c)) {
                    rl.EYI_Condition_Type__c = globalChargeToConditionType.get(rl.EYI_Global_Charges__c);
                }
                Boolean isChargeAvailableInProject = false;
                Boolean isChargeAvailableInTower = false;
                Boolean isChargeNotAvailableInTower = false;
                // Check Tower-GlobalCharge conflict
                Set<Id> globalCharges = new Set<Id>();
                
                //check and store tower related global charges
                if(!towerToGlobalCharges.isEmpty()){
                    globalCharges = towerToGlobalCharges.get(rl.EYI_Tower__c);
                }
                System.debug('globalCharges : '+globalCharges);
                
                //check tower related global charges is not blank and tower is present in towerToGlobalCharges map
                if (rl.EYI_Tower__c != null && 
                    towerToGlobalCharges.containsKey(rl.EYI_Tower__c) && !globalCharges.isEmpty()) {
                    System.debug('Inside globalCharges if not empty');
                        //Display error if global charge is not present in that map for repsective tower
                        if(!towerToGlobalCharges.get(rl.EYI_Tower__c).contains(rl.EYI_Global_Charges__c)){
                            System.debug('inside tower error');
                            isChargeNotAvailableInTower = true;
                            rl.addError('Global charge is not applicable for this Tower');
                        }else if(towerToGlobalCharges.get(rl.EYI_Tower__c).contains(rl.EYI_Global_Charges__c)){ // this condition indicated rate list created 
                            System.debug('inside update of tower');
                            isChargeAvailableInTower = true;
                        }
                    }
    
                // Check Project-GlobalCharge conflict
                 if (rl.EYI_Project__c != null &&
                     !projectToGlobalCharges.containsKey(rl.EYI_Project__c) && isChargeAvailableInTower == false && isChargeNotAvailableInTower == false){
                         System.debug('Insdie Project First Error');
                         rl.addError('Global charge is not applicablea for this Project'); 
                 } 
                 else if (rl.EYI_Project__c != null &&
                     projectToGlobalCharges.containsKey(rl.EYI_Project__c) && !projectToGlobalCharges.get(rl.EYI_Project__c).contains(rl.EYI_Global_Charges__c) && isChargeAvailableInTower == false && isChargeNotAvailableInTower == false) {
                    System.debug('Insdie Project Second Error');
                    //isChargeAvailableInProject = true;
                    rl.addError('Global charge is not applicable for this Project');
                }
            }
        }
    }

}