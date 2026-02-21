/*
@author : Aakash Shirawale
@created date : 17-04-2025
*/

public with sharing class EYI_GenerateMonthlyTargets implements Schedulable{
    public void execute(SchedulableContext sc) {
        createMonthlyTargetsRecords();
    }
    public static void createMonthlyTargetsRecords() {
        Decimal currMonCollectibleAmt = 0;
        Map<String,Id> demandIdMap =  new Map<String,Id>();
        Map<String,Id> targetIdMap =  new Map<String,Id>();
        List<EYI_Demand__c> demandUpdateList = new List<EYI_Demand__c>();
        List<Monthly_Target__c> monTargetToBeInserted = new List<Monthly_Target__c>();
        //8*************************************************************************************************************
        Date firstDayOfMonth = Date.today().toStartOfMonth();
        Date lastDayOf15Days = firstDayOfMonth.addDays(14);

        // Define two maps to store tower-wise sums
        Map<Id, Decimal> towerToPastAmountMap = new Map<Id, Decimal>(); // before current month
        Map<Id, Decimal> towerToCurrent15DaysAmountMap = new Map<Id, Decimal>(); // 1st to 15th
        String statusLabel = System.Label.EYI_ActiveProjectStatusValues; // "Launch,Post Launch,Sustenance"
        List<String> statusList = new List<String>();
        for (String status : statusLabel.split(',')) {
            statusList.add(status.trim()); // Trim to remove any extra spaces
        }
        List<EYI_Tower__c> towerList =  [SELECT Id, name, EYI_Project_Name__c, EYI_Project_Name__r.Name
                                        , EYI_Project_Name__r.EYI_Target_Percentage__c ,EYI_Relationship_Manager__c,
                                        EYI_Relationship_Manager__r.Name FROM EYI_Tower__c 
                                        WHERE EYI_Project_Name__r.EYI_Project_Status__c IN :statusList
                                        //WHERE EYI_Project_Name__r.EYI_Target_Percentage__c != null
                                        ];
        // Query all relevant demands: before current month or within first 15 days
        List<EYI_Demand__c> allRelevantDemands = [
                SELECT Id, EYI_Tower__c, EYI_Demand_Status__c, EYI_Demand_Payment_Status__c,
                    EYI_Opportunity__c, EYI_Opportunity__r.EYI_Collectible_Status__c,
                    EYI_Actual_Date__c, EYI_Collectible_Status__c, EYI_Billing_Date__c,
                    EYI_Amount_to_be_paid__c 
                FROM EYI_Demand__c
                WHERE EYI_Amount_to_be_paid__c != null
                AND EYI_Opportunity__r.EYI_Collectible_Status__c = 'Collectible'
                AND EYI_Demand_Status__c IN ('Open')
                // Uncomment the following line if needed in Apex logic, not in SOQL directly:
                // AND EYI_Collectible_Status__c = 'Collectible'
                AND (EYI_Billing_Date__c <= :lastDayOf15Days OR EYI_Actual_Date__c <= :lastDayOf15Days)
            ];

        // Iterate and populate maps
        for (EYI_Demand__c demand : allRelevantDemands) {
            if (demand.EYI_Tower__c == null) continue;
        //     if ( (demand.EYI_Demand_Status__c == 'Demand Sent' || demand.EYI_Demand_Status__c == 'Demand Raised' ) && demand.EYI_Demand_Payment_Status__c ==     'Pending') {
        //         towerToPastAmountMap.put(
        //             demand.EYI_Tower__c,
        //             towerToPastAmountMap.get(demand.EYI_Tower__c) != null ? towerToPastAmountMap.get(demand.EYI_Tower__c) + demand.EYI_Amount_to_be_paid__c : demand.EYI_Amount_to_be_paid__c
        //         );
        //   //  } else if (demand.EYI_Billing_Date__c >= firstDayOfMonth && demand.EYI_Billing_Date__c <= lastDayOf15Days && demand.EYI_Demand_Status__c == 'Open') {
        //     } else 
            if(demand.EYI_Actual_Date__c != NULL && demand.EYI_Demand_Status__c == 'Open') {
                if ( demand.EYI_Actual_Date__c <= lastDayOf15Days) {
                        towerToCurrent15DaysAmountMap.put(
                            demand.EYI_Tower__c,
                            towerToCurrent15DaysAmountMap.get(demand.EYI_Tower__c) != null ? towerToCurrent15DaysAmountMap.get(demand.EYI_Tower__c) + demand.EYI_Amount_to_be_paid__c : demand.EYI_Amount_to_be_paid__c
                        );
                }
            } else if(demand.EYI_Billing_Date__c != NULL && demand.EYI_Demand_Status__c == 'Open'){         
                if ( demand.EYI_Billing_Date__c <= lastDayOf15Days) {
                    towerToCurrent15DaysAmountMap.put(
                        demand.EYI_Tower__c,
                        towerToCurrent15DaysAmountMap.get(demand.EYI_Tower__c) != null ? towerToCurrent15DaysAmountMap.get(demand.EYI_Tower__c) + demand.EYI_Amount_to_be_paid__c : demand.EYI_Amount_to_be_paid__c
                    );
                }
            }
        }

        // Debug the output
        System.debug('Tower-wise amount before current month: ' + towerToPastAmountMap);
        System.debug('Tower-wise amount for 1st to 15th current month: ' + towerToCurrent15DaysAmountMap);
    //**********************************************************************************************************************
             for(EYI_Tower__c tower : towerList) {
                Decimal pastAmount = towerToPastAmountMap.containsKey(tower.Id) ? towerToPastAmountMap.get(tower.Id) : 0;
                Decimal currentAmount = towerToCurrent15DaysAmountMap.containsKey(tower.Id) ? towerToCurrent15DaysAmountMap.get(tower.Id) : 0;

                Monthly_Target__c monTarget = new Monthly_Target__c();
                monTarget.Name = getCurrentMonthName() +': '+ tower.EYI_Project_Name__r.Name+' - '+tower.Name + ' Target';
                monTarget.EYI_Project__c = tower.EYI_Project_Name__r.Id;
                monTarget.EYI_Tower__c = tower.Id;
                monTarget.EYI_Status__c = 'Pending';
                montarget.EYI_RM__c = tower.EYI_Relationship_Manager__c;
                monTarget.EYI_Month__c = system.now().Date();
                monTarget.RM_Name__c = tower.EYI_Relationship_Manager__r.Name;
                //monTarget.EYI_Overall_Outstanding_Amount1__c = pastAmount;
                monTarget.EYI_Demand_Raised_1st_to_15th__c = currentAmount;
                monTarget.EYI_Target_Percentage__c = tower.EYI_Project_Name__r.EYI_Target_Percentage__c;
               // monTarget.EYI_Target_Amount__c = ((currentAmount + pastAmount) * tower.EYI_Project_Name__r.EYI_Target_Percentage__c)/100;
                monTarget.EYI_Overall_Outstanding_Amount_Percent__c = tower.EYI_Project_Name__r.EYI_Target_Percentage__c;
                monTarget.EYI_Demand_Raised_1st_to_15th_percent__c = tower.EYI_Project_Name__r.EYI_Target_Percentage__c;
                System.debug('Tower====>'+tower);
                System.debug('Target====>'+monTarget);
                monTargetToBeInserted.add(monTarget);
            }
            
          
            try{
                if(!monTargetToBeInserted.isEmpty()) {
                    insert monTargetToBeInserted;
                }
                for(Monthly_Target__c mt :monTargetToBeInserted){
                    demandIdMap.put(mt.EYI_Tower__c, mt.Id);
                }
                for(EYI_Demand__c demand: allRelevantDemands){
                    EYI_Demand__c demandObj = new EYI_Demand__c();
                    demandObj.Id = demand.Id;
                    demandObj.EYI_Monthly_Target__c = demandIdMap.get(demand.EYI_Tower__c);
                    demandUpdateList.add(demandObj);
                }
                if(!demandUpdateList.isEmpty()){
                    update demandUpdateList;
                }
            }
            catch(exception e) {
                system.debug('Error creating monthly targets' + e);
            }

            Database.executebatch(new EYI_MonthlyTargetOAmtUpdateBatch(),1);
            
        }
    
    
    public static String getCurrentMonthName() {
        List<String> monthNames = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        Integer monthIndex = Date.today().month() - 1; // Apex months are 1-based, so subtract 1
        return monthNames[monthIndex]+' '+Date.today().year();
    }
}