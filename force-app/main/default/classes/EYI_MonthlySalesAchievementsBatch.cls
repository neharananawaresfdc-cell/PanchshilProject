global with sharing class EYI_MonthlySalesAchievementsBatch implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer fiscalStartMonth = Integer.ValueOf(System.Label.EYI_FINANCIAL_START_MONTH); // April
        Date today = Date.today();
        Integer fiscalYear;

        if (today.month() >= fiscalStartMonth) {
            fiscalYear = today.year() + 1;
        } else {
            fiscalYear = today.year();
        }

        // Fiscal year starts in April of the previous calendar year
        Integer fiscalStartYear = fiscalYear - 1;

        Date fiscalStart = Date.newInstance(fiscalStartYear, fiscalStartMonth, 1);
        Date fiscalEnd = fiscalStart.addYears(1).addDays(-1);
        return Database.getQueryLocator([ SELECT Id, Name,OwnerId,EYI_Project__c,EYI_Target_Start_Date__c,EYI_Target_END_Date__c,EYI_Target_KPI__c,EYI_Tower__c,EYI_Target_Month_Date__c 
        FROM EYI_Target_Management__c  WHERE EYI_Target_Start_Date__c >= :fiscalStart
            AND EYI_Target_End_Date__c <= :fiscalEnd AND EYI_Target_KPI__c != 'Revenue Target' AND EYI_Target_Module__c = 'Sales'  ]);
    }
     global void execute(Database.BatchableContext BC, List<EYI_Target_Management__c> monthlyTargetRec) {
          system.debug('monthlyTargetRec'+monthlyTargetRec);
        Map<Id,String> monthlyTargetMap = new Map<Id,String>();
        Map<String,Id> monthlyTargetMapValues = new Map<String,Id>();
        Date monthStart;
        Date monthEnd;
         
        Set<String> filterKeys = new Set<String>();
        for(EYI_Target_Management__c mt:monthlyTargetRec){
            monthStart = mt.EYI_Target_Start_Date__c;
            monthEnd = mt.EYI_Target_End_Date__c;
          if (mt.OwnerId != null && mt.EYI_Target_KPI__c != null ) {
            String key = mt.OwnerId + '_' + mt.EYI_Target_KPI__c;
                monthlyTargetMap.put(mt.Id, key);
              	monthlyTargetMapValues.put(key,mt.Id);
              	filterKeys.add(mt.OwnerId);
           }
        }
        
        Map<String, Integer> achievementCounts = new Map<String, Integer>();
        Map<String,Integer> totaFollowUpMissed = new Map<String,Integer>();
         Map<String,Integer> totaOppCreated = new Map<String,Integer>();
          Map<String,Integer> totaEOICreated = new Map<String,Integer>();
         Map<String,String> stepNameMap = new Map<String,String>();
         Map<String,String> stepNameMapTL = new Map<String,String>();
         Map<String,Id> userNameWithId = new Map<String,Id>();
        List<AggregateResult> followUpMissedAggResults = [
            select Count(id) totalCount, OwnerId  
            from task 
            where Status != 'Completed' AND  CreatedDate >= :monthStart AND CreatedDate < :monthEnd  AND Subject LIKE '%Follow Up%' AND ActivityDate < TODAY AND what.type = 'Opportunity'  
            Group BY OwnerId  
        ];
         //total follow up of this month of non CTI
         List<AggregateResult> totalFollowUpAggResults = [
            select Count(id) totalCount, OwnerId  
            from task 
            where   Status = 'Completed' AND CreatedDate >= :monthStart AND CreatedDate < :monthEnd  AND   EYI_Next_Action_Status__c != null AND EYI_Next_Action_Status__c != ''  AND what.type = 'Opportunity'  
            Group BY OwnerId  
        ];
         List<AggregateResult> totalCTIFollowUpAggResults = [
            select Count(id) totalCount , OwnerId  
            from task 
            where  Status = 'Completed' AND CreatedDate >= :monthStart AND CreatedDate < :monthEnd  AND tdc_360CTI__Call_Log__c  != '' AND EYI_Next_Action_Status__c != null AND EYI_Next_Action_Status__c != '' AND  TaskSubtype = 'Call' AND what.type = 'Opportunity'  
            Group BY OwnerId  
        ];
         //booking cold lost
         List<AggregateResult> totalColdLostBookingResults = [
             select Count(id) totalCount, OwnerId  
            from Opportunity 
            where   EYI_Booked_Date__c >= :monthStart AND EYI_Booked_Date__c < :monthEnd   AND (EYI_Initial_Rating__c = 'Cold' OR EYI_Initial_Rating__c = 'Lost')  AND StageName != 'Cancelled'
            Group BY OwnerId  
        ];
         //booking cold lost
         List<AggregateResult> totalBookingResults = [
             select Count(id) totalCount, OwnerId  
            from Opportunity 
            where  EYI_Booked_Date__c >= :monthStart AND EYI_Booked_Date__c < :monthEnd    AND StageName != 'Cancelled'
            Group BY OwnerId  
        ];
         
         //cooling period extended
         List<AggregateResult> totalCoolingPeriodExtResults = [
             select Count(id) totalCount, OwnerId  
            from Opportunity 
            where  EYI_Close_Date_Before_Extension__c >= :monthStart AND EYI_Close_Date_Before_Extension__c < :monthEnd  AND Extension_Requested__c =  true
            Group BY OwnerId  
        ];
         List<AggregateResult> totalOppCreatedResults = [
            select Count(id) totalCount, OwnerId  
            from Opportunity 
            where  CreatedDate >= :monthStart AND CreatedDate < :monthEnd 
            Group BY OwnerId  
        ];
         List<AggregateResult> oppWalkToBookedResults = [
            select SUM(EYI_Walk_In_to_Booking_TAT__c) totalCount, OwnerId  
            from Opportunity 
            where  EYI_Booked_Date__c >= :monthStart AND EYI_Booked_Date__c < :monthEnd  AND EYI_Booked_Date__c != null AND StageName != 'Cancelled'
            Group BY OwnerId  
        ];
         List<AggregateResult> totalRevisitedOpp = [
            select Count(id) totalCount, OwnerId  
            from Opportunity 
            where  CreatedDate >= :monthStart AND CreatedDate < :monthEnd  AND EYI_Revisit_Count__c >= 1
            Group BY OwnerId  
        ];
         List<AggregateResult> totalCancellationApprovedOpp = [
            select Count(id) totalCount, OwnerId  
            from Opportunity 
            where  EYI_Cancellation_Approval_Date__c >= :monthStart AND EYI_Cancellation_Approval_Date__c < :monthEnd
            Group BY OwnerId  
        ];
         List<AggregateResult> totalNumberOfEOI = [
            select Count(id) totalCount, OwnerId  
            from EYI_Expression_Of_Interest__c 
            where  EYI_Opportunity__c != '' AND CreatedDate >= :monthStart AND CreatedDate < :monthEnd 
            Group BY OwnerId  
        ];
         List<AggregateResult> totalNumberOfEOIConversion = [
            select Count(id) totalCount, OwnerId  
            from EYI_Expression_Of_Interest__c 
            where  EYI_Opportunity__c != '' AND EYI_Opportunity__r.EYI_Booked_Date__c >= :monthStart AND EYI_Opportunity__r.EYI_Booked_Date__c < :monthEnd  AND EYI_Opportunity__r.StageName != 'Cancelled' 
            Group BY OwnerId  
        ];
         //Approval TAT
        /* List<AggregateResult> totalApprovalTAT = [Select StepNodeId,ProcessInstance.SubmittedById ActorId,SUM(ElapsedTimeInMinutes) totalCount   from ProcessInstanceStep where ProcessInstance.ProcessDefinition.Name = 'Deviation approval2' AND StepNodeId!= '' AND CreatedDate >= 2025-06-01T00:00:00Z AND CreatedDate < 2025-07-01T00:00:00Z  GROUP BY StepNodeId,ProcessInstance.SubmittedById];
         List<AggregateResult> totalApprovalTATTL = [Select StepNodeId,ProcessInstance.SubmittedById ActorId,SUM(ElapsedTimeInMinutes) totalCount   from ProcessInstanceStep where ProcessInstance.ProcessDefinition.Name = 'Deviation approval2 for TL' AND StepNodeId!= '' AND CreatedDate >= 2025-06-01T00:00:00Z AND CreatedDate < 2025-07-01T00:00:00Z  GROUP BY StepNodeId,ProcessInstance.SubmittedById];
         List<ProcessNode> tatStep = [Select id, Name, ProcessDefinition.Name from ProcessNode where ProcessDefinition.Name = 'Deviation approval2'];
         List<ProcessNode> tatStepTL = [Select id, Name, ProcessDefinition.Name from ProcessNode where ProcessDefinition.Name = 'Deviation approval2 for TL']; */
         //number of referral 
         List<User> getAllUser = [select id, Name from User where IsActive = true ];
         //List<AggregateResult> referencesGeneratedBySM = [select Count(id), EYI_Referral_Employee__c from EYI_Customer_Information_Form__c where ((EYI_Walk_in_Source__c = 'Referral' AND EYI_Walk_in_Sub_source__c ='Employee' ) OR (EYI_Walk_in_Source__c = 'SM Self Sourcing'))  GROUP BY EYI_Referral_Employee__c];
         List<AggregateResult> referencesGeneratedBySM = [Select Count(id) totalCount,EYI_Sourcing_Manager__c From Opportunity where ((EYI_Walk_in_Source__c = 'Referral' AND EYI_Walk_in_Sub_source__c ='Employee' ) OR (EYI_Walk_in_Source__c = 'SM Self Sourcing')) AND EYI_Sourcing_Manager__c != null  AND CreatedDate = THIS_MONTH  GROUP BY EYI_Sourcing_Manager__c ];
         List<AggregateResult> referencesGeneratedBySMWIthPrimaryOwner = [Select Count(id) totalCount,OwnerID From Opportunity where ((EYI_Walk_in_Source__c = 'Referral' AND EYI_Walk_in_Sub_source__c ='Employee' ) OR (EYI_Walk_in_Source__c = 'SM Self Sourcing')) AND EYI_Sourcing_Manager__c = null AND CreatedDate = THIS_MONTH  GROUP BY OwnerID ];
         for(User us : getAllUser) {
            userNameWithId.put(us.Name, us.Id);
         }
        /* for(ProcessNode node : tatStep) {
            stepNameMap.put(node.Id, node.Name);
         }
         for(ProcessNode node : tatStepTL) {
            stepNameMapTL.put(node.Id, node.Name);
         } */
         //Number of references generated by the Sales Manager
         for (AggregateResult ar : referencesGeneratedBySM) {
                 	String key = (Id)ar.get('EYI_Sourcing_Manager__c') + '_' + 'Number of references generated by the Sales Manager';
            		Integer count = (Integer)ar.get('totalCount');
                 if (monthlyTargetMapValues.containsKey(key)) {
                     if(achievementCounts.containsKey(monthlyTargetMapValues.get(key))){
                         achievementCounts.put(monthlyTargetMapValues.get(key),achievementCounts.get(monthlyTargetMapValues.get(key)) + count);
                     }else{
                         achievementCounts.put(monthlyTargetMapValues.get(key), count);
                     }
                       
                	
            	}   
        }
         for (AggregateResult ar : referencesGeneratedBySMWIthPrimaryOwner) {
                 	String key = (Id)ar.get('OwnerId') + '_' + 'Number of references generated by the Sales Manager';
            		Integer count = (Integer)ar.get('totalCount');
                 if (monthlyTargetMapValues.containsKey(key)) {
                	if(achievementCounts.containsKey(monthlyTargetMapValues.get(key))){
                         achievementCounts.put(monthlyTargetMapValues.get(key),achievementCounts.get(monthlyTargetMapValues.get(key)) + count);
                     }else{
                         achievementCounts.put(monthlyTargetMapValues.get(key), count);
                     }
            	}   
        }
         
		//Cancel count
		/*for (AggregateResult ar : totalCancellationApprovedOpp) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Cancellation Count';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count);
            } 
        }*/
         
         
         //total no of EOI's
         for (AggregateResult ar : totalNumberOfEOI) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Number of EOIs';
            String key2 = (Id)ar.get('OwnerId') + '_' + 'EOI Conversions';
            Integer count = (Integer)ar.get('totalCount');
             totaEOICreated.put(key2,count);
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count);
            } 
        }
       /*  //total no of EOI's conversation
         for (AggregateResult ar : totalNumberOfEOIConversion) {
            String key = (Id)ar.get('OwnerId') + '_' + 'EOI Conversions';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaEOICreated.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key), percentage);
            } 
        } */
         /*
         //average follow Up
         for (AggregateResult ar : totalFollowUpAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Average Follow-Ups';
             String key2 = (Id)ar.get('OwnerId') + '_' + 'Follow-ups missed';
             String key3 = (Id)ar.get('OwnerId') + '_' + 'Follow-up by CTI';
            Integer count = (Integer)ar.get('totalCount');
             totaFollowUpMissed.put(key2,count);
             totaFollowUpMissed.put(key3,count);
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), (count/30));
            } 
        }
         //for missed follow up
        for (AggregateResult ar : followUpMissedAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Follow-ups missed';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaFollowUpMissed.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key),percentage);
            } 
        } */
         /*
         //for followup done by CTI
         for (AggregateResult ar : totalCTIFollowUpAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Follow-up by CTI';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaFollowUpMissed.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key),percentage );
            } 
        }
		*/
        //totla opp        
        for (AggregateResult ar : totalOppCreatedResults) {
           
            String key4 = (Id)ar.get('OwnerId') + '_' + 'Walk-in to Booking Conversion';
            String key3 = (Id)ar.get('OwnerId') + '_' + 'Re-visit (Unique revisits / Total revisits)';
            String key2 = (Id)ar.get('OwnerId') + '_' + 'Number of Cases Where the Cooling Period is Extended';
            Integer count = (Integer)ar.get('totalCount');
            
            totaOppCreated.put(key2,count);
            totaOppCreated.put(key3,count);
            totaOppCreated.put(key4,count);
            
        }
         //walkIn to booking ratio
        for (AggregateResult ar : totalBookingResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Walk-in to Booking Conversion';
             String key2 = (Id)ar.get('OwnerId') + '_' + 'Booking from Cold/Lost leads';
            String key3 = (Id)ar.get('OwnerId') + '_' + 'Average TAT from Walk-in to Booking';
            
            Integer count = (Integer)ar.get('totalCount');
            totaOppCreated.put(key2,count);
            totaOppCreated.put(key3,count);
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaOppCreated.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key), percentage);
            } 
        }
         /*
         //Booking from Cold/Lost leads 

        for (AggregateResult ar : totalColdLostBookingResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Booking from Cold/Lost leads';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaOppCreated.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key), percentage);
            } 
        }
        //oppwalkInBookingTAT
         for (AggregateResult ar : oppWalkToBookedResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Average TAT from Walk-in to Booking';
            Integer count = ((Decimal)ar.get('totalCount')).intValue();
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count/totaOppCreated.get(key));
            } 
        }
        //No of EOI Conversion
        
        //coolingPeriodExtension
        for (AggregateResult ar : totalCoolingPeriodExtResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Number of Cases Where the Cooling Period is Extended';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaOppCreated.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key), percentage);
            } 
        }
        //ApprovalTAT
        for (AggregateResult ar : totalApprovalTAT) {
            if(stepNameMap.get((Id)ar.get('StepNodeId')) == 'TL Approval'){
                String key = (Id)ar.get('ActorId') + '_' + 'L1 TAT Approval';
            	//Decimal count = (Integer)ar.get('totalCount');
                Integer count = ((Decimal)ar.get('totalCount')).intValue();
                if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count);
                }
            } 
            if(stepNameMap.get((Id)ar.get('StepNodeId')) == 'Functional Head Approval'){
                String key2 = (Id)ar.get('ActorId') + '_' + 'L2 TAT Approval';
            	Integer count2 = ((Decimal)ar.get('totalCount')).intValue();
                if (monthlyTargetMapValues.containsKey(key2)) {
                achievementCounts.put(monthlyTargetMapValues.get(key2), count2);
                }     
            } 
            if(stepNameMap.get((Id)ar.get('StepNodeId')) == 'Final Approval'){
                String key3 = (Id)ar.get('ActorId') + '_' + 'L3 TAT Approval';
            	Integer count3 = ((Decimal)ar.get('totalCount')).intValue();
                if (monthlyTargetMapValues.containsKey(key3)) {
                achievementCounts.put(monthlyTargetMapValues.get(key3), count3);
                }
            }     
        }
        for (AggregateResult ar : totalApprovalTATTL) {
            
            if(stepNameMapTL.get((Id)ar.get('StepNodeId')) == 'Functional Head Approval'){
                String key2 = (Id)ar.get('ActorId') + '_' + 'L2 TAT Approval';
            	Integer count2 = ((Decimal)ar.get('totalCount')).intValue();
                if (monthlyTargetMapValues.containsKey(key2)) {
                    if(achievementCounts.containsKey(monthlyTargetMapValues.get(key2))){
                        achievementCounts.put(monthlyTargetMapValues.get(key2),achievementCounts.get(monthlyTargetMapValues.get(key2)) + count2);
                    }else{
                        achievementCounts.put(monthlyTargetMapValues.get(key2), count2);
                    }
                
                }     
            } 
            if(stepNameMapTL.get((Id)ar.get('StepNodeId')) == 'Final Approval'){
                String key3 = (Id)ar.get('ActorId') + '_' + 'L3 TAT Approval';
            	Integer count3 = ((Decimal)ar.get('totalCount')).intValue();
                if (monthlyTargetMapValues.containsKey(key3)) {
                    if(achievementCounts.containsKey(monthlyTargetMapValues.get(key3))){
                        achievementCounts.put(monthlyTargetMapValues.get(key3),achievementCounts.get(monthlyTargetMapValues.get(key3)) + count3);
                    }else{
                        achievementCounts.put(monthlyTargetMapValues.get(key3), count3);
                    }
                //achievementCounts.put(monthlyTargetMapValues.get(key3), count3);
                }
            }     
        } 
        for (AggregateResult ar : totalFollowUpAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Average Follow-Ups';
             String key2 = (Id)ar.get('OwnerId') + '_' + 'Follow-ups missed';
            Integer count = (Integer)ar.get('totalCount');
             totaFollowUpMissed.put(key2,count);
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), (count/30));
            } 
        } */
         //Revist
       for (AggregateResult ar : totalRevisitedOpp) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Re-visit (Unique revisits / Total revisits)';
            Integer count = (Integer)ar.get('totalCount');
            if (monthlyTargetMapValues.containsKey(key)) {
                Integer percentage = (Integer) Math.round(((double) count / totaOppCreated.get(key)) * 100);
                achievementCounts.put(monthlyTargetMapValues.get(key), percentage);
            } 
        }
         List<EYI_Target_Management__c> updateAchievements =  new List<EYI_Target_Management__c>();
        for(String key:achievementCounts.keySet()){
            EYI_Target_Management__c updatetm = new EYI_Target_Management__c();
            updatetm.Id  = key;
            updatetm.EYI_Achivements__c = achievementCounts.get(key);
            updateAchievements.add(updatetm);
        }
        update updateAchievements;
        //lead to walkInRation
        
		system.debug('achievementCounts'+achievementCounts);
     }
         
     
    global void finish(Database.BatchableContext BC) {
    	System.debug('Batch processing completed.');
    } 

}