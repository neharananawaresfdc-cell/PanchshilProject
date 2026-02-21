// public class EYI_RECCategoryService {
//     // Method to update the REC Category Lifetime
//     public static void updateRecCategoryLifetime(Set<ID> recIds) {
//         List<EYI_REC__c> recsToUpdate = new List<EYI_REC__c>();
//         // Query to retrieve all RECs (Accounts) with related Bookings, Walkins, and Activities
//         List<EYI_REC__c> recs = [SELECT Id,EYI_REC_Overall_Performance__c
//                                 , (SELECT Id FROM tasks)
//                                 , (SELECT Id FROM Bookings__r)
//                                 , (SELECT Id FROM Sitevisits__r) //vp/vc
//                                 , (SELECT Id FROM CIF_Records__r), // CIF Record
//                                 (SELECT Id FROM Joint_Business_Plans__r),
//                                 (SELECT Id, Subject, ActivityDate FROM ActivityHistories)
//                                 FROM EYI_REC__c WHERE Id IN: recIds];
//         for(EYI_REC__c rec : recs) {
//             String overallPerformance = 'CAT D';
//             if (rec.ActivityHistories.size() > 0 || rec.Joint_Business_Plans__r.size() > 0) { 
//                 overallPerformance = 'CAT C';
//             } else if (rec.Sitevisits__r.size() > 0 || rec.CIF_Records__r.size() > 0) {
//                 overallPerformance = 'CAT B';
//             } else if (rec.Bookings__r.size() > 0) {
//                 overallPerformance = 'CAT A';
//             }
//             rec.EYI_REC_Overall_Performance__c = overallPerformance;  // Update the lifetime category
//             //rec.REC_Classification_Legacy__c = classificationCurrent;
//             System.debug('REC===>'+rec);
//             recsToUpdate.add(rec);
//         }
//         if (!recsToUpdate.isEmpty()) {
//             update recsToUpdate;  // Save updates to the database
//         }
//     }
    
//     // Method to update the REC Category Current (based on last 180 days)
//     public static void updateRecCategoryCurrent(Set<ID> recIds) {
//         List<EYI_REC__c> recsToUpdate = new List<EYI_REC__c>();
//         Integer lastNDays = Integer.valueOf(System.Label.EYI_REC_Performance_Days);

//         // Query to retrieve RECs that had any activity in the last n days
//         String query = 'SELECT Id, EYI_REC_Current_Status__c, ' +
//                '(SELECT Id FROM Bookings__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
//                '(SELECT Id FROM Sitevisits__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
//                '(SELECT Id FROM Joint_Business_Plans__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
//                '(SELECT Id, Subject, ActivityDate FROM ActivityHistories WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + ') ' +
//                'FROM EYI_REC__c WHERE Id IN :recIds';

//         // Execute the dynamic SOQL query
//         List<EYI_REC__c> recs = Database.query(query);
//         System.debug('recs :: ' + recs);
        
//         for(EYI_REC__c rec : recs) {
//             String categoryCurrent = 'CAT D';
//             if (rec.ActivityHistories.size() > 0 || rec.Joint_Business_Plans__r.size() > 0) { 
//                 categoryCurrent = 'CAT C';
//             } else if (rec.Sitevisits__r.size() > 0) {
//                 categoryCurrent = 'CAT B';
//             } else if (rec.Bookings__r.size() > 0) {
//                 categoryCurrent = 'CAT A';
//             }
//             rec.EYI_REC_Current_Status__c = categoryCurrent;  
//             recsToUpdate.add(rec);
//         }
        
//         if (!recsToUpdate.isEmpty()) {
//             update recsToUpdate;  // Save updates to the database
//         }
//     }
// }
public class EYI_RECCategoryService {
    public static void updateRecCategories(Set<Id> recIds) {
        // Map to store overall performance
        Map<Id, EYI_REC__c> overallPerformanceMap = new Map<Id, EYI_REC__c>();
        
        // Query to retrieve overall performance
        List<EYI_REC__c> overallRecs = [SELECT Id, EYI_REC_Overall_Performance__c,
                                         (SELECT Id FROM tasks),
                                         (SELECT Id FROM Bookings__r),
                                         (SELECT Id FROM Sitevisits__r),
                                         (SELECT Id FROM CIF_Records__r),
                                         (SELECT Id FROM Joint_Business_Plans__r)
                                         FROM EYI_REC__c WHERE Id IN :recIds];
        
        for (EYI_REC__c rec : overallRecs) {
            String overallPerformance = 'CAT D';
            if (rec.tasks.size() > 0 || rec.Joint_Business_Plans__r.size() > 0) {
                overallPerformance = 'CAT C';
            } else if (rec.Sitevisits__r.size() > 0 || rec.CIF_Records__r.size() > 0) {
                overallPerformance = 'CAT B';
            } else if (rec.Bookings__r.size() > 0) {
                overallPerformance = 'CAT A';
            }
            rec.EYI_REC_Overall_Performance__c = overallPerformance;
            overallPerformanceMap.put(rec.Id, rec);
        }
        System.debug('overallPerformance ==> ' + overallPerformanceMap.keySet());
        System.debug('overallPerformance ==> ' + overallPerformanceMap.values());

        // Map to store current performance based on last N days
        Map<Id, EYI_REC__c> currentPerformanceMap = new Map<Id, EYI_REC__c>();
        Integer lastNDays = Integer.valueOf(System.Label.EYI_REC_Performance_Days);

        // Construct the dynamic SOQL query for current performance based on last N days
        String query = 'SELECT Id, EYI_REC_Current_Status__c, ' +
                       '(SELECT Id FROM Bookings__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
                       '(SELECT Id FROM CIF_Records__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
                       '(SELECT Id FROM Sitevisits__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
                       '(SELECT Id FROM Joint_Business_Plans__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
                       '(SELECT Id FROM tasks WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + ') ' +
                       'FROM EYI_REC__c WHERE Id IN :recIds';

        // Execute the dynamic SOQL query
        List<EYI_REC__c> currentRecs = Database.query(query);
        System.debug('recs :: ' + currentRecs);

        for (EYI_REC__c rec : currentRecs) {
            String categoryCurrent = 'CAT D';
            if (rec.tasks.size() > 0 || rec.Joint_Business_Plans__r.size() > 0) {
                categoryCurrent = 'CAT C';
            } else if (rec.Sitevisits__r.size() > 0 || rec.CIF_Records__r.size() > 0) {
                categoryCurrent = 'CAT B';
            } else if (rec.Bookings__r.size() > 0) {
                categoryCurrent = 'CAT A';
            }
            rec.EYI_REC_Current_Status__c = categoryCurrent;
            currentPerformanceMap.put(rec.Id, rec);
        }
        System.debug('currentPerformanceMap ==> ' + currentPerformanceMap.keySet());
        System.debug('currentPerformanceMap ==> ' + currentPerformanceMap.values());

        // Map to store combined results
        Map<Id, EYI_REC__c> combinedMap = new Map<Id, EYI_REC__c>();

        // Combine results from both maps
        for (Id recId : recIds) {
            EYI_REC__c overallRec = overallPerformanceMap.get(recId);
            EYI_REC__c currentRec = currentPerformanceMap.get(recId);
            EYI_REC__c combinedRec = new EYI_REC__c();
            combinedRec.Id = recId;
            combinedRec.EYI_AutomationBypassDatetime__c	= System.now();
            if (overallRec != null) {
                combinedRec.EYI_REC_Overall_Performance__c = overallRec.EYI_REC_Overall_Performance__c;
            }
            if (currentRec != null) {
                combinedRec.EYI_REC_Current_Status__c = currentRec.EYI_REC_Current_Status__c;
            }
            combinedMap.put(recId, combinedRec);
        }
        
        System.debug('combinedMap ==> ' + combinedMap.keySet());
        System.debug('combinedMap ==> ' + combinedMap.values());
        // Perform a single update DML statement
        if (!combinedMap.isEmpty()) {
            update combinedMap.values();
        }
    }


    public static void updateRecProjectCategories(Set<Id> recIds) {
        // Add a specific ID to the recIds set
        // Map to store overall performance for EYI_Project_REC_Mapping__c
        Map<Id, EYI_Project_REC_Mapping__c> overallPerformanceMap = new Map<Id, EYI_Project_REC_Mapping__c>();

        // Query to retrieve overall performance for EYI_Project_REC_Mapping__c
        List<EYI_Project_REC_Mapping__c> overallMappings = [SELECT Id, EYI_Project__c
                                                            FROM EYI_Project_REC_Mapping__c WHERE EYI_REC_Account__c IN :recIds];

        // Iterate above and get projectIds
        Set<Id> projectIds = new Set<Id>();
        for (EYI_Project_REC_Mapping__c mapping : overallMappings) {
            projectIds.add(mapping.EYI_Project__c);
        }

        // Retrieve project-related child records for lifetime and last N days
        Map<Id, Map<String, List<SObject>>> projectChildRecordsMap = getProjectChildRecords(projectIds);
        Map<Id, Map<String, List<SObject>>> projectChildRecordsLastNDaysMap = getProjectChildRecordsLastNDays(projectIds);

        // Classify projects based on related records
        for (EYI_Project_REC_Mapping__c mapping : overallMappings) {
            String overallPerformance = 'P4';
            String categoryCurrent = 'P4';
            Map<String, List<SObject>> childRecords = projectChildRecordsMap.get(mapping.EYI_Project__c);
            Map<String, List<SObject>> childRecordsLastNDays = projectChildRecordsLastNDaysMap.get(mapping.EYI_Project__c);

            if (childRecords != null) {
                if ((childRecords.get('activities') != null && !childRecords.get('activities').isEmpty()) ||
                    (childRecords.get('joint_business_plans') != null && !childRecords.get('joint_business_plans').isEmpty())) {
                    overallPerformance = 'P3';
                } else if ((childRecords.get('sitevisits') != null && !childRecords.get('sitevisits').isEmpty()) ||
                           (childRecords.get('cif') != null && !childRecords.get('cif').isEmpty())) {
                    overallPerformance = 'P2';
                } else if (childRecords.get('bookings') != null && !childRecords.get('bookings').isEmpty()) {
                    overallPerformance = 'P1';
                }
            }

            if (childRecordsLastNDays != null) {
                if ((childRecordsLastNDays.get('activities') != null && !childRecordsLastNDays.get('activities').isEmpty()) ||
                    (childRecordsLastNDays.get('joint_business_plans') != null && !childRecordsLastNDays.get('joint_business_plans').isEmpty())) {
                    categoryCurrent = 'P3';
                } else if ((childRecordsLastNDays.get('sitevisits') != null && !childRecordsLastNDays.get('sitevisits').isEmpty()) ||
                           (childRecordsLastNDays.get('cif') != null && !childRecordsLastNDays.get('cif').isEmpty())) {
                    categoryCurrent = 'P2';
                } else if (childRecordsLastNDays.get('bookings') != null && !childRecordsLastNDays.get('bookings').isEmpty()) {
                    categoryCurrent = 'P1';
                }
            }

            mapping.EYI_REC_Classification_Lifetime__c = overallPerformance;
            mapping.EYI_REC_Classification_Current__c = categoryCurrent;
            overallPerformanceMap.put(mapping.Id, mapping);
        }
        
        System.debug('overallPerformanceMap.values()===>'+overallPerformanceMap.values());
        System.debug('overallPerformanceMap ===>'+overallPerformanceMap.keySet());

        // Perform a single update DML statement
        if (!overallPerformanceMap.isEmpty()) {
            update overallPerformanceMap.values();
        }
    }

    // Method to retrieve project-related child records for lifetime
    public static Map<Id, Map<String, List<SObject>>> getProjectChildRecords(Set<Id> projectIds) {
        Map<Id, Map<String, List<SObject>>> projectChildRecordsMap = new Map<Id, Map<String, List<SObject>>>();

        List<EYI_Project__c> projects = [SELECT Id, Name,
                                         (SELECT Id FROM activities__r),
                                         (SELECT Id FROM Bookings__r),
                                         (SELECT Id FROM VP_VC__r),
                                         (SELECT Id FROM CIF__r),
                                         (SELECT Id FROM Joint_Business_Plans__r)
                                         FROM EYI_Project__c WHERE Id IN :projectIds];

        for (EYI_Project__c project : projects) {
            Map<String, List<SObject>> childRecordsMap = new Map<String, List<SObject>>();
            childRecordsMap.put('activities', project.activities__r);
            childRecordsMap.put('bookings', project.Bookings__r);
            childRecordsMap.put('vp_vc', project.VP_VC__r);
            childRecordsMap.put('cif', project.CIF__r);
            childRecordsMap.put('joint_business_plans', project.Joint_Business_Plans__r);
            projectChildRecordsMap.put(project.Id, childRecordsMap);
        }

        return projectChildRecordsMap;
    }

    // Method to retrieve project-related child records for last N days
    public static Map<Id, Map<String, List<SObject>>> getProjectChildRecordsLastNDays(Set<Id> projectIds) {
        Map<Id, Map<String, List<SObject>>> projectChildRecordsMap = new Map<Id, Map<String, List<SObject>>>();
        Integer lastNDays = Integer.valueOf(System.Label.EYI_REC_Performance_Days);

        String query = 'SELECT Id, Name, ' +
        '(SELECT Id FROM activities__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
        '(SELECT Id FROM Bookings__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
        '(SELECT Id FROM VP_VC__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
        '(SELECT Id FROM CIF__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + '), ' +
        '(SELECT Id FROM Joint_Business_Plans__r WHERE CreatedDate >= LAST_N_DAYS:' + lastNDays + ') ' +
        'FROM EYI_Project__c WHERE Id IN :projectIds';

        // Execute the dynamic query
        List<EYI_Project__c> projects = Database.query(query);
        for (EYI_Project__c project : projects) {
            Map<String, List<SObject>> childRecordsMap = new Map<String, List<SObject>>();
            childRecordsMap.put('activities', project.activities__r);
            childRecordsMap.put('bookings', project.Bookings__r);
            childRecordsMap.put('vp_vc', project.VP_VC__r);
            childRecordsMap.put('cif', project.CIF__r);
            childRecordsMap.put('joint_business_plans', project.Joint_Business_Plans__r);
            projectChildRecordsMap.put(project.Id, childRecordsMap);
        }
        return projectChildRecordsMap;
    }






}