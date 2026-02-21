trigger EYI_CarParkingTrigger on EYI_Car_Park_Master__c (after Update, before update, after insert, before insert, after delete, before delete, after undelete) {
    private static Set<Id> carParkingIds = new Set<Id> ();
    if(EYI_Trigger_Control__mdt.getInstance('EYI_CarParkingTrigger').EYI_Active__c){
      if(Trigger.IsBefore && Trigger.IsUpdate){
      EYI_CarParkingTriggerHandler.handleBeforeUpdate();
      }
      
      if(Trigger.IsAfter){
        if(Trigger.IsDelete){
          EYI_CarParkingTriggerHandler.updateratelists(Trigger.old,Trigger.oldMap);
        }else{
          EYI_CarParkingTriggerHandler.updateratelists(Trigger.new,Trigger.oldMap);
        }
      }
    }
}