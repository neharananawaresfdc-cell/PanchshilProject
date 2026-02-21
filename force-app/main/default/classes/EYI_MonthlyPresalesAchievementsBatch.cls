global with sharing class EYI_MonthlyPresalesAchievementsBatch implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([ SELECT Id, Name,OwnerId,EYI_Project__c, EYI_Target_Module__c,EYI_Target_KPI__c,EYI_Tower__c,EYI_Target_Month_Date__c 
        FROM EYI_Target_Management__c WHERE EYI_Target_Month_Date__c = LAST_MONTH AND EYI_Target_Module__c = 'Presales'  ]);
    }
    global void execute(Database.BatchableContext BC, List<EYI_Target_Management__c> monthlyTargetRec) {
        system.debug('monthlyTargetRec'+monthlyTargetRec);
        Map<Id,String> monthlyTargetMap = new Map<Id,String>();
        Map<String,Id> monthlyTargetMapValues = new Map<String,Id>();
        
        Set<String> filterKeys = new Set<String>();
        for(EYI_Target_Management__c mt:monthlyTargetRec){
          if (mt.OwnerId != null && mt.EYI_Target_KPI__c != null ) {
            String key = mt.OwnerId + '_' + mt.EYI_Target_KPI__c;
                monthlyTargetMap.put(mt.Id, key);
              	monthlyTargetMapValues.put(key,mt.Id);
              	filterKeys.add(mt.OwnerId);
           }
        }
        
        Map<String, Integer> achievementCounts = new Map<String, Integer>();
        //for visit done
        Map<String,Integer> leadWalkinRatio1 = new Map<String,Integer>();
        List<AggregateResult> leadVisitDoneAggResults = [
            SELECT EYI_Lead_Enquiry__r.OwnerId, EYI_Lead_Enquiry__r.EYI_Lead_Status__c,  COUNT(Id) totalCount
            FROM EYI_Customer_Information_Form__c
            WHERE 
                EYI_Lead_Enquiry__r.OwnerId IN :filterKeys
                AND EYI_Lead_Enquiry__r.EYI_Lead_Status__c = 'Visit Done'
            	AND  EYI_Walk_in_Source__c != 'PREC'
                //AND EYI_Lead_Enquiry__r.EYI_Project_Enquired__r.EYI_Residential_Type__c != null
            	AND CreatedDate = LAST_MONTH
            GROUP BY EYI_Lead_Enquiry__r.OwnerId,EYI_Lead_Enquiry__r.EYI_Lead_Status__c
        ];
        for (AggregateResult ar : leadVisitDoneAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Visit Done';
            String key3 = (Id)ar.get('OwnerId') + '_' + 'Visit Confirmed';
            String key2 = (Id)ar.get('OwnerId') + '_' + 'Lead to Walk-In Conversion ratio' ;
            Integer count = (Integer)ar.get('totalCount');
            //Decimal sumValue = (Decimal)ar.get('totalCount');
			//Integer count = sumValue != null ? sumValue.intValue() : 0;
			
			leadWalkinRatio1.put(key2,count);
            system.debug('leadWalkinRatio1'+leadWalkinRatio1);
            // Only store if the key is relevant
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count);
                
            }
            if (monthlyTargetMapValues.containsKey(key3)) {
                achievementCounts.put(monthlyTargetMapValues.get(key3), count);
                
            }
        }
        //for visit confirmed 
        List<AggregateResult> leadConfirmedAggResults = [
            SELECT OwnerId, EYI_Lead_Status__c,  COUNT(Id) totalCount
            FROM EYI_Lead_Enquiry__c
            WHERE 
                OwnerId IN :filterKeys
                AND EYI_Lead_Status__c = 'Visit Confirmed'
                //AND EYI_Project_Enquired__r.EYI_Residential_Type__c != null
            	AND EYI_Site_Visit_Date__c = LAST_MONTH
            GROUP BY OwnerId,EYI_Lead_Status__c
        ];
        
        system.debug('leadConfirmedAggResults'+leadConfirmedAggResults);
        for (AggregateResult ar : leadConfirmedAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + (String)ar.get('EYI_Lead_Status__c') ;
            Integer count = (Integer)ar.get('totalCount');
            // Only store if the key is relevant
            if (monthlyTargetMapValues.containsKey(key)) {
                if(achievementCounts.containsKey(monthlyTargetMapValues.get(key))){
                    Integer totalCount = achievementCounts.get(monthlyTargetMapValues.get(key));
                    achievementCounts.put(monthlyTargetMapValues.get(key), count+totalCount);
                }
                else{
                    achievementCounts.put(monthlyTargetMapValues.get(key), count);
                }
                
            }
        }
        
        
        //lead to walk in conversion ratio
        List<AggregateResult> leadCreatedAggResults = [
            SELECT OwnerId,  COUNT(Id) totalCount
            FROM EYI_Lead_Enquiry__c
            WHERE 
                OwnerId IN :filterKeys
            	AND EYI_Lead_Source__c != 'PREC'
                //AND EYI_Project_Enquired__r.EYI_Residential_Type__c != null
            	AND CreatedDate = LAST_MONTH
            GROUP BY OwnerId
        ];
        for (AggregateResult ar : leadCreatedAggResults) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Lead to Walk-In Conversion ratio' ;
            Integer count = (Integer)ar.get('totalCount');
            Integer LWRatio = null;
            system.debug('LWRatio'+leadWalkinRatio1.get(key));
            system.debug('count'+count);
            if (leadWalkinRatio1.containsKey(key)) {
                system.debug('LWRatio22'+((Decimal.valueOf(leadWalkinRatio1.get(key)) / count)));
             LWRatio = (Integer)((Decimal.valueOf(leadWalkinRatio1.get(key)) / count) *100) ;
                system.debug('LWRatio--'+LWRatio);
            }else{
              LWRatio = 0;   
            }
            system.debug('LWRatioPP--'+LWRatio);
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), LWRatio); 
            }
        }
        //for average talk time
        List<AggregateResult> averageTalkTime = [
            SELECT OwnerId,  SUM(tdc_360CTI__Answered_Seconds__c) totalCount
            FROM tdc_360CTI__Call_Log__c 
            WHERE 
                OwnerId IN :filterKeys
                AND CreatedDate = LAST_MONTH
                AND CustomLead_Enquiry__c != null
            	//AND CustomLead_Enquiry__r.EYI_Project_Enquired__r.EYI_Residential_Type__c != null
            	GROUP BY OwnerId
        ];
        for (AggregateResult ar : averageTalkTime) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Average Talk Time' ;
            //Integer count = (Integer)ar.get('totalCount');
            Decimal sumValue = (Decimal)ar.get('totalCount');
			Integer count = sumValue != null ? sumValue.intValue() : 0;
            // Only store if the key is relevant
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), (count/60));
            }
        }
        //For outbondCalls
        List<AggregateResult> outbondCalls = [
            SELECT COUNT(Id) totalCount,  CustomLead_Enquiry__r.OwnerId 
            FROM tdc_360CTI__Call_Log__c 
            where tdc_360CTI__Call_Type__c = 'Outgoing' AND CustomLead_Enquiry__c != null   AND CreatedDate = LAST_MONTH 
            AND tdc_360CTI__Answered_Seconds__c > 10
            GROUP BY   CustomLead_Enquiry__r.OwnerId 
        ];
        for (AggregateResult ar : outbondCalls) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Total Outbound Calls to be Done' ;
            //Integer count = (Integer)ar.get('totalCount');
            Decimal sumValue = (Decimal)ar.get('totalCount');
			Integer count = sumValue != null ? sumValue.intValue() : 0;
            // Only store if the key is relevant
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count);
            }
        }
        //for inbound calls
        List<AggregateResult> inboundCalls = [
            SELECT COUNT(Id) totalCount,  CustomLead_Enquiry__r.OwnerId 
            FROM tdc_360CTI__Call_Log__c 
            where tdc_360CTI__Call_Type__c = 'Incoming' AND CustomLead_Enquiry__c != null   AND CreatedDate = LAST_MONTH 
            GROUP BY   CustomLead_Enquiry__r.OwnerId 
        ];
        for (AggregateResult ar : inboundCalls) {
            String key = (Id)ar.get('OwnerId') + '_' + 'Total Inbound Calls Completed' ;
            //Integer count = (Integer)ar.get('totalCount');
            Decimal sumValue = (Decimal)ar.get('totalCount');
			Integer count = sumValue != null ? sumValue.intValue() : 0;
            // Only store if the key is relevant
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), count);
            }
        }
        //for outbond calls
       /* List<Task> tasks = [
            SELECT Id, OwnerId, WhatId
            FROM Task
            WHERE 
                OwnerId IN :filterKeys
                AND CallDurationInSeconds > 10
                AND Subject LIKE '%Outgoing%'
                AND What.Type = 'EYI_Lead_Enquiry__c'
            	AND CreatedDate =  THIS_MONTH
        ];
        Set<Id> enquiryIds = new Set<Id>();
        for (Task t : tasks) {
            if (t.WhatId != null) enquiryIds.add(t.WhatId);
        }
        Map<Id, EYI_Lead_Enquiry__c> enquiryMap = new Map<Id, EYI_Lead_Enquiry__c>(
            [SELECT Id, EYI_Project_Enquired__r.EYI_Residential_Type__c FROM EYI_Lead_Enquiry__c WHERE Id IN :enquiryIds AND EYI_Project_Enquired__r.EYI_Residential_Type__c != null]
        );
        Map<String, Integer> callCountsOutbond = new Map<String, Integer>();
        for (Task t : tasks) {
            EYI_Lead_Enquiry__c enquiry = enquiryMap.get(t.WhatId);
            if (enquiry != null && enquiry.EYI_Project_Enquired__r != null) {
                String key = t.OwnerId + '_' +'Total Outbound Calls to be Done'+'_'+ enquiry.EYI_Project_Enquired__r.EYI_Residential_Type__c;
                Integer currentCount = callCountsOutbond.containsKey(key) ? callCountsOutbond.get(key) : 0;
				callCountsOutbond.put(key, currentCount + 1);
            }
        }
        for(String key :callCountsOutbond.keySet()){
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), callCountsOutbond.get(key));
            }
        }
        
        //for inbound calls
        List<Task> tasksInboundCall = [
            SELECT Id, OwnerId, WhatId
            FROM Task
            WHERE 
                OwnerId IN :filterKeys
                AND Subject LIKE '%Inbound%'
                AND What.Type = 'EYI_Lead_Enquiry__c'
            	AND CreatedDate =  THIS_MONTH
        ];
        Set<Id> enquiryIdsForInbound = new Set<Id>();
        for (Task t : tasksInboundCall) {
            if (t.WhatId != null) enquiryIdsForInbound.add(t.WhatId);
        }
        Map<Id, EYI_Lead_Enquiry__c> enquiryMapForInbound = new Map<Id, EYI_Lead_Enquiry__c>(
            [SELECT Id, EYI_Project_Enquired__r.EYI_Residential_Type__c FROM EYI_Lead_Enquiry__c WHERE Id IN :enquiryIds AND EYI_Project_Enquired__r.EYI_Residential_Type__c!=null]
        );
        Map<String, Integer> callCountsInbound = new Map<String, Integer>();
        for (Task t : tasks) {
            EYI_Lead_Enquiry__c enquiry = enquiryMapForInbound.get(t.WhatId);
            if (enquiry != null && enquiry.EYI_Project_Enquired__r != null) {
                String key = t.OwnerId + '_' +'Total Inbound Calls Completed'+'_'+ enquiry.EYI_Project_Enquired__r.EYI_Residential_Type__c;
                Integer currentCount = callCountsInbound.containsKey(key) ? callCountsInbound.get(key) : 0;
				callCountsInbound.put(key, currentCount + 1);
            }
        }
        for(String key :callCountsInbound.keySet()){
            if (monthlyTargetMapValues.containsKey(key)) {
                achievementCounts.put(monthlyTargetMapValues.get(key), callCountsInbound.get(key));
            }
        } */
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