public without sharing class EYI_LeadEnquiryTriggerHandler {
    public static void updateTotalCountOnLead(List<EYI_Lead_Enquiry__c> EnquiryList){
        List<Lead> updateLeadList = new List<Lead>();
        Set<ID> leadID = new Set<Id>();
        Map<Id,Integer> leadMap = new Map<Id,Integer>();
        for(EYI_Lead_Enquiry__c enquiry: EnquiryList) {
            leadID.add(enquiry.EYI_Parent_Record__c);
            //system.debug('ldId'+enquiry.ownerid__c);
            
        }
        List<Lead> getAllLead = [Select Name,OwnerId,Id, EYI_Total_Lead_Inquiries__c from Lead where Id IN : leadID];

        for(Lead l: getAllLead){
            leadMap.put(l.Id,l.EYI_Total_Lead_Inquiries__c!=null?(Integer)l.EYI_Total_Lead_Inquiries__c:0);
            system.debug('id'+l.id);
            system.debug('leadName'+l.Name);
            system.debug('leadOwner'+l.OwnerId);
            
        }
        for(EYI_Lead_Enquiry__c enquiry: EnquiryList) {
            if(leadMap.containsKey(enquiry.EYI_Parent_Record__c)){
                leadMap.put(enquiry.EYI_Parent_Record__c, leadMap.get(enquiry.EYI_Parent_Record__c) + 1);
            }
        }
        for(Id lID: leadMap.keySet()){
            Lead leadUpdate = new Lead();
            leadUpdate.id = lID;
            leadUpdate.EYI_Total_Lead_Inquiries__c = leadMap.get(lID);
            updateLeadList.add(leadUpdate);
        }      
        if(!updateLeadList.isEmpty()){
            update updateLeadList;
        }
    }
    public static void updateProjectOnLead(List<EYI_Lead_Enquiry__c> enquiryList, Map<id,EYI_Lead_Enquiry__c> oldMap){
        List<EYI_Lead_Enquiry__c> leadList = new List<EYI_Lead_Enquiry__c>();
        List<String> projectVal = new List<String>();
        Map<String,EYI_Project__c> projectDetails = new Map<String, EYI_Project__c>();
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        for(EYI_Lead_Enquiry__c ld: enquiryList){
           if(oldMap ==null){
            projectVal.add(ld.EYI_Property__c);
           }
            else if(oldMap != null && oldMap.get(ld.id).EYI_Property__c != ld.EYI_Property__c){
             projectVal.add(ld.EYI_Property__c);
            }
        
            
        }
        if(!projectVal.isEmpty()){
            projectList  = [SELECT Id,Name,EYI_Project_Property_Type__c FROM EYI_Project__c WHERE Name IN: projectVal];
        }
        if(!projectList.isEmpty()){
            for(EYI_Project__c p: projectList){
                projectDetails.put(p.Name, p);
            }
            for(EYI_Lead_Enquiry__c ld: enquiryList){
                if(projectDetails.containsKey(ld.EYI_Property__c)){
                ld.EYI_Project_Enquired__c = projectDetails.get(ld.EYI_Property__c).Id;
                ld.EYI_Segment__c = projectDetails.get(ld.EYI_Property__c).EYI_Project_Property_Type__c;
                
                }
    
            }
        }
        
    }
    
    //@future
    public static void shareRecordAccess(List<EYI_Lead_Enquiry__c> enquiryList, Map<id,EYI_Lead_Enquiry__c> oldMap){
        List<EYI_Lead_Enquiry__Share> shareRecords = new List<EYI_Lead_Enquiry__Share>();
        Map<Id,Id> primaryToSecondayShare = new Map<Id,Id>();
        Map<Id,Id> deleteAccess = new Map<Id,Id>();

        for(EYI_Lead_Enquiry__c enquiry: enquiryList){
            if(enquiry.EYI_Secondary_Owner__c != null && enquiry.EYI_Secondary_Owner__c != oldMap.get(enquiry.Id).EYI_Secondary_Owner__c && enquiry.OwnerId != enquiry.EYI_Secondary_Owner__c){
                primaryToSecondayShare.put(enquiry.id,enquiry.EYI_Secondary_Owner__c);
                
                

            }
            if(oldMap.get(enquiry.Id).EYI_Secondary_Owner__c != null && oldMap.get(enquiry.Id).EYI_Secondary_Owner__c != null && oldMap.get(enquiry.Id).EYI_Secondary_Owner__c != enquiry.EYI_Secondary_Owner__c){
                deleteAccess.put(enquiry.Id,oldMap.get(enquiry.Id).EYI_Secondary_Owner__c);
            }
        }
        List<EYI_Lead_Enquiry__Share> shareRecordsToDelete = new List<EYI_Lead_Enquiry__Share>();

        for(Id leadId :primaryToSecondayShare.keySet() ){
           // EYI_Lead_Enquiry__Share enquiryShare = new EYI_Lead_Enquiry__Share();
            EYI_Lead_Enquiry__Share leadShare = new EYI_Lead_Enquiry__Share();
                leadShare.ParentId = leadId;           // The Lead record to be shared
                leadShare.UserOrGroupId = primaryToSecondayShare.get(leadId);     // The User with whom the record will be shared
                leadShare.AccessLevel = 'Edit';  // Access level (e.g., 'Read' or 'Edit')
                leadShare.RowCause = 'Manual';
                shareRecords.add(leadShare);
        }
        if (!shareRecords.isEmpty()) {
            insert shareRecords;
        }
        List<EYI_Lead_Enquiry__Share> existingShareRecords = [ 
        SELECT Id, ParentId, UserOrGroupId 
        FROM EYI_Lead_Enquiry__Share 
        WHERE ParentId IN :deleteAccess.keySet() 
          AND UserOrGroupId IN :deleteAccess.values()
        ];
        for (EYI_Lead_Enquiry__Share shareRecord : existingShareRecords) {
            // Check if the sharing record matches the correct user and lead, then add it to the delete list
            if (deleteAccess.containsKey(shareRecord.ParentId) && 
            deleteAccess.get(shareRecord.ParentId) == shareRecord.UserOrGroupId) {
                shareRecordsToDelete.add(shareRecord);
            }
        }
        if (!shareRecordsToDelete.isEmpty()) {
            try {
                delete shareRecordsToDelete;
            } catch (DmlException e) {
                System.debug('Error deleting sharing records: ' + e.getMessage());
            }
        }
    }
    
    public static void shareRecordAccesstoLeasingTeam(Map<id,EYI_Lead_Enquiry__c> oldMap,Map<id,EYI_Lead_Enquiry__c> newMap) {
        Map<String,String> LeasingTeamIDVsPreviousIDMap = new Map<String,String>();
        String leasingQueueTeam = System.label.EYI_Leasing_Queue_Id;
        List<EYI_Lead_Enquiry__Share> shareEnqList = new List<EYI_Lead_Enquiry__Share>();
        System.debug('newMap.keySet()==>'+newMap.keySet());
        System.debug('oldMap==>'+oldMap);
        System.debug('newMap==>'+newMap);
        for(String leadId: newMap.keySet()){
            if(newMap.get(leadId).OwnerId == leasingQueueTeam && newMap.get(leadId).OwnerId != oldMap.get(leadId).OwnerId && oldMap.get(leadId).OwnerId != leasingQueueTeam){
                LeasingTeamIDVsPreviousIDMap.Put(leadId,oldMap.get(leadId).OwnerId);
            }
        }
        System.debug('LeasingTeamIDVsPreviousIDMap==>'+LeasingTeamIDVsPreviousIDMap);

        if(!LeasingTeamIDVsPreviousIDMap.isEmpty()){
            for(String leadId: LeasingTeamIDVsPreviousIDMap.keySet()){
                EYI_Lead_Enquiry__Share customObjectShare = new EYI_Lead_Enquiry__Share();
                customObjectShare.ParentId = leadId;
                Id userId = LeasingTeamIDVsPreviousIDMap.get(leadId);
                customObjectShare.UserOrGroupId = userId;
                customObjectShare.AccessLevel = 'Read';
                customObjectShare.RowCause = Schema.EYI_Lead_Enquiry__Share.RowCause.Manual;
                shareEnqList.add(customObjectShare);
            }
        }
        if(!shareEnqList.isEmpty()){
            insert shareEnqList;
        }
    }


    public static void shareRecordToClosingManager(Map<id,EYI_Lead_Enquiry__c> oldMap,Map<id,EYI_Lead_Enquiry__c> newMap) {
        Map<String,String> closingManagerVsRecordIdMap = new Map<String,String>();
        List<EYI_Lead_Enquiry__Share> shareEnqList = new List<EYI_Lead_Enquiry__Share>();

        for(String leadId: newMap.keySet()){
            /*if(oldMap.get(leadId).EYI_Closing_Manager__c == '' && newMap.get(leadId).EYI_Closing_Manager__c != ''){
                closingManagerVsRecordIdMap.put(leadId,newMap.get(leadId).EYI_Closing_Manager__c);
            }*/
             if(oldMap.get(leadId).EYI_Closing_Manager__c != NULL){

            }else{
                if(oldMap.get(leadId).EYI_Closing_Manager__c == '' && newMap.get(leadId).EYI_Closing_Manager__c != ''){
                    closingManagerVsRecordIdMap.put(leadId,newMap.get(leadId).EYI_Closing_Manager__c);
                }
            }
        }
        if(!closingManagerVsRecordIdMap.isEmpty()){
            for(String leadId: closingManagerVsRecordIdMap.keySet()){
                EYI_Lead_Enquiry__Share customObjectShare = new EYI_Lead_Enquiry__Share();
                customObjectShare.ParentId = leadId;
                Id userId = closingManagerVsRecordIdMap.get(leadId);
                customObjectShare.UserOrGroupId = userId;
                customObjectShare.AccessLevel = 'Read';
                customObjectShare.RowCause = Schema.EYI_Lead_Enquiry__Share.RowCause.Manual;
                shareEnqList.add(customObjectShare);
            }
        }
        if(!shareEnqList.isEmpty()){
            insert shareEnqList;
        }
    }

    public static void updateEscalationTimeOnEnquiry(List<EYI_Lead_Enquiry__c> leadList) {
        Map<String, EYI_Lead_Enquiry_Escalation_Settings__mdt> callTypeToMDTMap = EYI_CustomMetadataUtility.getEscalationTimeMatrix('Inbound');
        EYI_Lead_Enquiry_Escalation_Settings__mdt callTypeToMDT;
        Datetime inboundL1;
        Datetime inboundL2;
        Datetime InboundL3;
        if(callTypeToMDTMap.size()>0){
            callTypeToMDT = callTypeToMDTMap.get('Inbound');
            if(callTypeToMDT.L1_Escalation_Time__c != NULL){
                inboundL1 = EYI_BusinessHoursUtility.addBusinessMinutes(System.now(),(Integer)callTypeToMDT.L1_Escalation_Time__c);
            }
            if(callTypeToMDT.L2_Escalation_Time__c !=NULL){
                inboundL2 = EYI_BusinessHoursUtility.addBusinessMinutes(System.now(),(Integer)callTypeToMDT.L2_Escalation_Time__c);
            }
            if(callTypeToMDT.L3_Escalation_Time__c !=NULL){
                inboundL3 = EYI_BusinessHoursUtility.addBusinessMinutes(System.now(),(Integer)callTypeToMDT.L3_Escalation_Time__c);
            } 
        }
        for(EYI_Lead_Enquiry__c enquiry: leadList) {
            system.debug('enquiry.CreatedDate'+(System.now()));
            system.debug('enquiry.CreatedDate12'+(System.now()).time());
            system.debug('enquiry.CreatedDate'+enquiry.CreatedDate);
            Time createdTime = (System.now()).time();
            Time startTime = Time.newInstance(9, 30, 0, 0);  // 9:30 AM
            Time endTime = Time.newInstance(18, 30, 0, 0);
            if(enquiry.EYI_Lead_Source__c != null && enquiry.EYI_Lead_Source__c != '' && (createdTime >= startTime && createdTime <= endTime) ) {
                if(System.Label.EYI_Lead_Source_For_Escalation.contains(enquiry.EYI_Lead_Source__c)){
                    enquiry.EYI_Inbound_L1_Escalation_Time__c = inboundL1;
                    enquiry.EYI_Inbound_L2_Escalation_Time__c = inboundL2;
                    enquiry.EYI_Inbound_L3_Escalation_Time__c = InboundL3;
                }
            }
        }
    }
    private static Boolean isTriggerRunning = false;
     public static void updateDNCOnAllRecords(List<EYI_Lead_Enquiry__c> leadList) {
        if (isTriggerRunning) {
            return; // Exit if the trigger is already running
        }
        
        isTriggerRunning = true; // Set the flag to prevent recursion

        system.debug('check if calling');
        List<String> phoneList = new List<String>();
        Set<String> leadID = new Set<String>();
        
        for (EYI_Lead_Enquiry__c lead : leadList) {
            leadID.add(lead.id);
            if (lead.DNC__c == true && lead.EYI_DNC__c != true && lead.EYI_Lead_Status__c != 'Lost'  && (lead.EYI_Phone__c != null && lead.EYI_Phone__c != '')) {
                phoneList.add(lead.EYI_Phone__c);
            }
            if (lead.DNC__c == true && lead.EYI_DNC__c != true && lead.EYI_Lead_Status__c != 'Lost'  && (lead.EYI_Mobile__c != null && lead.EYI_Mobile__c != '')) {
                phoneList.add(lead.EYI_Mobile__c);
            }
        }

        system.debug('phoneList' + phoneList);

        if (!phoneList.isEmpty()) {
            List<EYI_Lead_Enquiry__c> leadEnquiryList = [
                SELECT DNC__c
                FROM EYI_Lead_Enquiry__c
                WHERE (EYI_Mobile__c IN :phoneList OR EYI_Phone__c IN :phoneList)
                AND DNC__c != true
                AND Id NOT IN :leadID
            ];

            system.debug('phoneList2' + leadEnquiryList);

            for (EYI_Lead_Enquiry__c leadEnquiry : leadEnquiryList) {
                if (!leadID.contains(leadEnquiry.id)) {
                    leadEnquiry.DNC__c = true;
                    leadEnquiry.EYI_DNC__c = false;
                }
            }

            system.debug('phoneList23' + leadEnquiryList);
            update leadEnquiryList;
        }

        isTriggerRunning = false; // Reset the flag after the update is completed
    }
    public static void updateParentOwnerTLLostLead(List<EYI_Lead_Enquiry__c> leadList){
        Set<Id> ownerIds = new Set<Id>();
         Set<Id> parentLeadIds = new Set<Id>();
        for (EYI_Lead_Enquiry__c lead : leadList) {
            if (lead.EYI_Lost_Lead__c == true && lead.OwnerId != null) {
                ownerIds.add(lead.OwnerId);
                if (lead.EYI_Parent_Record__c != null) {
                    parentLeadIds.add(lead.EYI_Parent_Record__c);
                }
            }
        }
        
        Map<Id, Id> ownerToManagerMap = new Map<Id, Id>();
        for (User u : [SELECT Id, ManagerId FROM User WHERE Id IN :ownerIds]) {
            ownerToManagerMap.put(u.Id, u.ManagerId);
        }
         List<EYI_Lead_Enquiry__c> leadsToUpdate = new List<EYI_Lead_Enquiry__c>();
        List<Lead> parentLeadsToUpdate = new List<Lead>();
        for (EYI_Lead_Enquiry__c leadEnquiry : leadList) {
            
            if (leadEnquiry.EYI_Lost_Lead__c == true && ownerToManagerMap.containsKey(leadEnquiry.OwnerId)) {
                Id managerId = ownerToManagerMap.get(leadEnquiry.OwnerId);
                leadEnquiry.OwnerId = managerId;
                leadEnquiry.EYI_AutomationBypassDatetime__c =  System.now();
               // if (leadEnquiry.EYI_Parent_Record__c != null ){
              //  Lead parent = new Lead();
              //  parent.Id = leadEnquiry.EYI_Parent_Record__c;
              //  parent.OwnerId = managerId;
              //  parentLeadsToUpdate.add(parent);
              //  }
            }   
            
        }
       // if (!parentLeadsToUpdate.isEmpty()) {
       //     update parentLeadsToUpdate;
       // }
        // if (!leadsToUpdate.isEmpty()) {
        // update leadsToUpdate;
        // }

    }        
    
}