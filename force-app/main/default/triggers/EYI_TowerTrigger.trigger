trigger EYI_TowerTrigger on EYI_Tower__c (after insert) {
    if(EYI_Trigger_Control__mdt.getInstance('TowerTrigger').EYI_Active__c){
   set<Id> towerIds = new Set<Id> ();
    for(EYI_Tower__c tower : trigger.New){
        if(tower.EYI_Project_Name__c != null){
           towerIds.add(tower.Id);
        } 
    }
    if(!towerIds.isEmpty()){
        EYI_ProjectSyncToMobileApp.syncTowersToMobileApp(towerIds);
    }
   }  
}