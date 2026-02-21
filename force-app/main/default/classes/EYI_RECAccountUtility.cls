public with sharing class EYI_RECAccountUtility {
    public class RECAccountWrapper {
        @AuraEnabled
        public String recId { get; set; }
        @AuraEnabled
        public String recCode { get; set; }
        @AuraEnabled
        public String recName { get; set; }
        @AuraEnabled
        public String recMobile { get; set; }
        @AuraEnabled
        public String recProjectId { get; set; }
        @AuraEnabled
        public String recLifetimeCategory { get; set; }
        @AuraEnabled
        public String recCurrentCategory { get; set; }
        @AuraEnabled
        public String recProjLifetimeCat { get; set; }
        @AuraEnabled
        public String recProjCurrentCat { get; set; }
        @AuraEnabled
        public String recBeat { get; set; }
        @AuraEnabled
        public String recURL { get; set; }
        @AuraEnabled
        public String recMappingId { get; set; }
        @AuraEnabled
        public Integer recBookings { get; set; }
        @AuraEnabled
        public Integer recActivities { get; set; }
        @AuraEnabled
        public Integer recSitevisits { get; set; }
        @AuraEnabled
        public Integer recWalkins { get; set; }
        @AuraEnabled
        public Boolean isSelected { get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static List<RECAccountWrapper> getRECAccounts() {
        List<RECAccountWrapper> recAccountWrapperList = new List<RECAccountWrapper>();
        for (EYI_REC__c recRecord : [SELECT Id, Name, EYI_First_Name__c, EYI_Last_Name__c, 
                            EYI_REC_Overall_Performance__c,EYI_REC_Current_Status__c, EYI_REC_Beat__c,
                            EYI_Mobile__c, EYI_SAP_ID__c, EYI_REC_Code__c,
                            (SELECT Id FROM Tasks WHERE OwnerId = :UserInfo.getUserId()), 
                            (SELECT Id FROM Bookings__r WHERE OwnerId = :UserInfo.getUserId()), 
                            (SELECT Id FROM Sitevisits__r WHERE OwnerId = :UserInfo.getUserId()), 
                            (SELECT Id FROM CIF_Records__r WHERE OwnerId = :UserInfo.getUserId())
                            FROM EYI_REC__c 
                            WHERE OwnerId = :UserInfo.getUserId() 
                            ORDER BY Name ASC]) {
            RECAccountWrapper wrapper = new RECAccountWrapper();
            wrapper.recId = recRecord.Id;
            wrapper.recName = recRecord.EYI_First_Name__c + ' ' + recRecord.EYI_Last_Name__c;
            wrapper.recMobile = recRecord.EYI_Mobile__c;
            wrapper.recCode = recRecord.EYI_REC_Code__c;
            wrapper.recLifetimeCategory = recRecord.EYI_REC_Overall_Performance__c;
            wrapper.recCurrentCategory = recRecord.EYI_REC_Current_Status__c;
            wrapper.recProjLifetimeCat = '';
            wrapper.recProjCurrentCat = '';
            wrapper.recURL = '/' + recRecord.Id;
            wrapper.recMappingId = '';
            wrapper.recBeat = recRecord.EYI_REC_Beat__c;

            // Assign the related counts directly from the subqueries
            wrapper.recActivities = recRecord.Tasks.size();
            wrapper.recBookings = recRecord.Bookings__r.size();
            wrapper.recSitevisits = recRecord.Sitevisits__r.size();
            wrapper.recWalkins = recRecord.CIF_Records__r.size();
            wrapper.isSelected = false;
            recAccountWrapperList.add(wrapper);
        }
        System.debug('recAccountWrapperList===> '+recAccountWrapperList);
        return recAccountWrapperList ;
    }

    @AuraEnabled
    public static List<RECAccountWrapper> getRECProjectMappings(String projectId) {
        List<RECAccountWrapper> recAccountWrapperList = new List<RECAccountWrapper>();
        Set<Id> recIdSet = new Set<Id>();
        List<EYI_REC__c> recDetailsList = new List<EYI_REC__c>();
        for (EYI_Project_REC_Mapping__c recMapping : [SELECT Id, EYI_REC_Account__r.Name,EYI_REC_Account__r.EYI_REC_Code__c,EYI_REC_Account__r.OwnerId,
            EYI_REC_Account__r.EYI_First_Name__c,EYI_REC_Account__r.EYI_Last_Name__c,EYI_Project__c,
            EYI_REC_Account__r.EYI_REC_Overall_Performance__c,EYI_REC_Account__r.EYI_REC_Current_Status__c,
            EYI_REC_Account__r.EYI_Mobile__c, EYI_REC_Account__r.EYI_SAP_ID__c,EYI_REC_Classification_Current__c, EYI_REC_Classification_Lifetime__c
            FROM EYI_Project_REC_Mapping__c 
            WHERE EYI_REC_Account__r.OwnerId =:UserInfo.getUserId() 
            AND EYI_Project__c =:projectId
            ORDER BY EYI_REC_Account__r.Name ASC ]) {
            RECAccountWrapper wrapper = new RECAccountWrapper();
            wrapper.recId = recMapping.EYI_REC_Account__c;
            wrapper.recName = recMapping.EYI_REC_Account__r.EYI_First_Name__c + ' '+ recMapping.EYI_REC_Account__r.EYI_Last_Name__c;
            wrapper.recMobile = recMapping.EYI_REC_Account__r.EYI_Mobile__c;
            wrapper.recProjectId = recMapping.EYI_Project__c;
            wrapper.recCode = recMapping.EYI_REC_Account__r.EYI_REC_Code__c;
            wrapper.recURL = '/'+recMapping.EYI_REC_Account__c;
            wrapper.recLifetimeCategory = recMapping.EYI_REC_Account__r.EYI_REC_Overall_Performance__c;
            wrapper.recCurrentCategory = recMapping.EYI_REC_Account__r.EYI_REC_Current_Status__c;
            wrapper.recProjLifetimeCat = recMapping.EYI_REC_Classification_Lifetime__c;
            wrapper.recProjCurrentCat = recMapping.EYI_REC_Classification_Current__c;
            wrapper.recMappingId = recMapping.Id;
            wrapper.recProjectId = recMapping.EYI_Project__c;
            wrapper.recBookings = 0;
            wrapper.recSitevisits = 0;
            wrapper.recWalkins = 0;
            wrapper.recActivities = 0;

            System.debug('Wrapper==>'+Wrapper);
            recAccountWrapperList.add(wrapper);
            recIdSet.add(recMapping.EYI_REC_Account__c);
        }
        // System.debug('recAccountWrapperList==>'+recAccountWrapperList);

        // for (EYI_REC__c recRecord : [SELECT Id, Name,EYI_First_Name__c,EYI_Last_Name__c,
        //     EYI_REC_Current_Status__c,EYI_Mobile__c,EYI_SAP_ID__c 
        //     FROM EYI_REC__c 
        //     WHERE Id IN :recIdSet 
        //     ORDER BY Name ASC ]) {
        //     RECAccountWrapper wrapper = new RECAccountWrapper();
        //     wrapper.recId = recRecord.Id;
        //     wrapper.recName = recRecord.EYI_First_Name__c + ' '+ recRecord.EYI_Last_Name__c;
        //     wrapper.recMobile = recRecord.EYI_Mobile__c;
        //     wrapper.recCode = recRecord.Name;
        //     wrapper.recURL = '/'+recRecord.Id;
        //     wrapper.recStatus = recRecord.EYI_REC_Current_Status__c;
        //     wrapper.recBookings = 0;
        //     wrapper.recSitevisits = 0;
        //     wrapper.recWalkins = 0;
        //     wrapper.recActivities = 0;

        //     recAccountWrapperList.add(wrapper);
        //     recIdSet.add(recRecord.Id);
        // }
        
        if(recIdSet.size()>0){
            recDetailsList = [SELECT Id, Name,
            (SELECT Id FROM Tasks WHERE OwnerId = :UserInfo.getUserId()), 
            (SELECT Id FROM Bookings__r WHERE OwnerId = :UserInfo.getUserId()), 
            (SELECT Id FROM Sitevisits__r WHERE OwnerId = :UserInfo.getUserId()), 
            (SELECT Id FROM CIF_Records__r WHERE OwnerId = :UserInfo.getUserId())

                                FROM EYI_REC__c  
                                WHERE Id IN:recIdSet];
        }
        System.debug('recAccountWrapperList==>'+recAccountWrapperList);

        for(RECAccountWrapper recWrap:recAccountWrapperList){
            for(EYI_REC__c recDetail:recDetailsList){
                if(recWrap.recId==recDetail.Id){
                    recWrap.recActivities = recDetail.tasks.size();
                    recWrap.recBookings = recDetail.Bookings__r.size();
                    recWrap.recSitevisits = recDetail.Sitevisits__r.size();
                    recWrap.recWalkins = recDetail.CIF_Records__r.size();
                }
            }
        }
        return recAccountWrapperList;
    }

    @AuraEnabled
    public static EYI_Project__c getRECProjectTypology(String projectId) {
        EYI_Project__c project;
        project = [SELECT Id, Name, EYI_Configuration_Types__c FROM EYI_Project__c WHERE Id=:projectId];
        // if (project.EYI_Configuration_Types__c != null) {
        //     return project.EYI_Configuration_Types__c.split(';');
        // }
        return project;
    }

    @AuraEnabled(cacheable=true)
    public static List<EYI_Project__c> getRECProjects() {
        return [SELECT Id, Name  FROM EYI_Project__c ORDER BY Name ASC];
    }
     
    public class VPVCDetails {
        public String clientName;
        public String companyName;
        public String designation;
        public String email;
        public String mobileNumber;
        public String profile;
        public String projectName;
        public String recMapping;
        public String recCode;
        public String recAccount;
        public String recStatus;
        public List<String> typology;
        public String budget;
        public Datetime vcDate;
        public Datetime vpDate;
        public String linkdin;
        public String docId;
    }

    @AuraEnabled(cacheable=true)
    public static List<EYI_Joint_Business_Plan__c> getJointBusinessPlans() {
        return [SELECT Id, Name,EYI_JBP_Name__c FROM EYI_Joint_Business_Plan__c WHERE OwnerId =:UserInfo.getUserId()];
    }
    // Method that accepts the JSON as a string, deserializes it, and processes it
    @AuraEnabled
    public static void createVPVCRecord(String jsonInput) {
        List<EYI_VP_VC__c> vpvcList = new List<EYI_VP_VC__c>();
        try {
            System.debug('jsonInput: ' + jsonInput);
            // Create a list of EYI_VP_VC__c records from the JSON string)
            // Deserialize JSON input into the Person object
            
            if(jsonInput != null && jsonInput != ''){
                VPVCDetails personData = (VPVCDetails) JSON.deserialize(jsonInput, VPVCDetails.class);
                // Create a new record of type EYI_VP_VC__c
                EYI_VP_VC__c vc = new EYI_VP_VC__c();
                vc.EYI_Client_Name__c = personData.clientName;
                vc.EYI_Company_Name__c = personData.companyName;
                vc.EYI_Designation__c = personData.designation;
                vc.EYI_Email__c = personData.email;
                vc.EYI_Mobile_Number__c = personData.mobileNumber;
                vc.EYI_Profile__c = personData.profile;
                vc.EYI_Project_REC_Mapping__c = personData.recMapping;
                vc.EYI_REC_Account__c = personData.recAccount;
                vc.EYI_Status__c = personData.recStatus;
                if (personData.typology != null && !personData.typology.isEmpty()) {
                    vc.EYI_Typology_of_Project__c = String.join(personData.typology, '; ');
                } else {
                    vc.EYI_Typology_of_Project__c = null;
                }
                vc.EYI_Linkdin_URL__c = personData.linkdin;
                vc.EYI_Budget__c = 
                (personData.budget != null) 
                    ? personData.budget
                    : null;

                vc.EYI_Visit_Confirmed_Date__c = 
                    (personData.vcDate != null) 
                        ? DateTime.valueOf(personData.vcDate) 
                        : null;

                vc.EYI_Visit_Proposed_Date__c = 
                (personData.vpDate != null) 
                    ? DateTime.valueOf(personData.vpDate) 
                    : null;
                if(personData.recMapping != null && personData.recMapping != ''){
                    vc.EYI_Project_REC_Mapping__c = personData.recMapping;
                }
                if(personData.projectName != null && personData.projectName != ''){
                    vc.EYI_Project__c = personData.projectName;
                }
                // vc.EYI_Budget__c = personData.budget;
                // Insert the record into the database
                System.debug('vc==>' + vc);
                vpvcList.add(vc);
                System.debug('vpvcList==>' + vpvcList);
                if(!vpvcList.isEmpty()){
                    insert vpvcList;
                }
                System.debug('vpvcList==>' + vpvcList);
                if(personData.docId != '' && personData.docId != null && vpvcList.size()>0 ){
                    try{
                            ContentDocumentLink cdl = new ContentDocumentLink(
                            ContentDocumentId = personData.docId,
                            LinkedEntityId = vpvcList[0].Id,
                            ShareType = 'V',  // V = Viewer access, C = Collaborator
                            Visibility = 'AllUsers'  // or 'InternalUsers' depending on your org's needs
                            );
                            insert cdl;
                    }catch(Exception e){

                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error in deserialization: ' + e.getMessage());
        }
    }
    public class RecMeetingDetails {
        public String subject;
        public String description;
        public String relatedTo;
        public String recMapping;
        public String meetingType;
        public Datetime startDate;
        public Datetime endDate;
        public String status;
        public String projectName;
        public String location;
        public decimal latitude;
        public decimal longitude;
        public String recInterest;
    }

    // @AuraEnabled
    // public static void createRecMeeting(String jsonInput) {
    //     System.debug('jsonInput===>'+jsonInput);
    //     try {
    //         // Deserialize JSON input into the Person object
    //         if(jsonInput != null && jsonInput != ''){
    //             RecMeetingDetails meetingData = (RecMeetingDetails) JSON.deserialize(jsonInput, RecMeetingDetails.class);
    //             Event newEvent = new Event(
    //                 Subject = meetingData.subject,
    //                 StartDateTime = meetingData.startDate,
    //                 EndDateTime = meetingData.endDate,
    //                 Description = meetingData.description,
    //                 WhatId = meetingData.relatedTo,
    //                 EYI_REC_Account__c = meetingData.relatedTo,
    //                 EYI_Meeting_Location__c = meetingData.location,
    //                 EYI_Meeting_Type__c = meetingData.meetingType,
    //                 EYI_Meeting_Status__C = meetingData.Status,
    //                 EYI_Project_Name__c = meetingData.projectName,
    //                 Location__Latitude__s = meetingData.latitude,
    //                 Location__Longitude__s = meetingData.longitude,
    //                 EYI_Interested_in_Event__c = meetingData.recInterest,
    //                 OwnerId = UserInfo.getUserId()
    //             );
                
    //             insert newEvent;
                
    //             if(meetingData.recMapping != null && meetingData.recMapping != ''){
    //                 System.debug('in 2nd event else');
    //                 Event parentEvent = new Event(
    //                 Subject = meetingData.subject,
    //                 StartDateTime = meetingData.startDate,
    //                 EndDateTime = meetingData.endDate,
    //                 Description = meetingData.description,
    //                 WhatId = meetingData.recMapping,
    //                 EYI_Meeting_Location__c = meetingData.location,
    //                 EYI_Meeting_Type__c = meetingData.meetingType,
    //                 EYI_Meeting_Status__C = meetingData.Status,
    //                 EYI_Project_Name__c = meetingData.projectName,
    //                 Location__Latitude__s = meetingData.latitude,
    //                 Location__Longitude__s = meetingData.longitude,
    //                 EYI_Interested_in_Event__c = meetingData.recInterest,
    //                 OwnerId = UserInfo.getUserId()
    //                 );
    //                 insert parentEvent;
    //             }
    //         }
    //     }catch(Exception e){
    //         System.debug('Error in deserialization: ' + e.getMessage());
    //     }
    // }
    public class RecActivityDetails {
        public String taskSubject;
        public String taskDescription;
        public String taskRelatedTo;
        public String taskPriority;
        public String recMapping;
        public String meetingType;
        public String taskJBP;
        public String activityType;
        public Date dueDate;
    }

    @AuraEnabled
    public static void createRecActivity(String jsonInput) {
        try {
            // Deserialize JSON input into the Person object
            if(jsonInput != null && jsonInput != ''){
                System.debug('jsonInput: ' + jsonInput);
                RecActivityDetails taskData = (RecActivityDetails) JSON.deserialize(jsonInput, RecActivityDetails.class);
                System.debug('newEvent: ' + taskData);
                Task newTask = new Task(
                    Subject = taskData.taskSubject,
                    ActivityDate = taskData.dueDate,
                    Description = taskData.taskDescription,
                    WhatId = taskData.taskRelatedTo,
                    EYI_REC_Account__c = taskData.taskRelatedTo,
                    OwnerId = UserInfo.getUserId(),
                    RecordtypeId = System.Label.EYI_SourcingTaskRecordType,
                    EYI_Next_Action_Date_Time__c = System.now().addDays(1),
                    Priority = taskData.taskPriority,
                    EYI_Next_Action_Status__c = 'Follow Up'
                ); 
                if(taskData.taskJBP != null && taskData.taskJBP != ''){
                    newTask.EYI_Joint_Business_Plan__c = taskData.taskJBP;
                }
                insert newTask;
                System.debug('newTask: ' + newTask);

                if(taskData.recMapping != null && taskData.recMapping != '' ){
                    Task parentTask = new Task(
                    Subject = taskData.taskSubject,
                    ActivityDate = taskData.dueDate,
                    Description = taskData.taskDescription,
                    WhatId = taskData.recMapping,
                    OwnerId = UserInfo.getUserId(),
                    RecordtypeId = System.Label.EYI_SourcingTaskRecordType,
                    EYI_Next_Action_Date_Time__c = System.now().addDays(1),
                    Priority = taskData.taskPriority,
                    EYI_Next_Action_Status__c = 'Follow Up'
                    );
                    if(taskData.taskJBP != null && taskData.taskJBP != ''){
                        parentTask.EYI_Joint_Business_Plan__c = taskData.taskJBP;
                    }
                    insert parentTask;
                    System.debug('newTask: ' + parentTask);
                }   
            }
        }catch(Exception e){
            System.debug('Error in deserialization: ' + e.getMessage());
        }
    }

    
    public class JBPDetails {
        public String jbpStatus;
        public String jbpActionSupport;
        public String jbpActivityType;
        public String recAccount;
        public String recMapping;
        public String jbpProject;
        public String jbpName;
        public Date startDate;
        public Date endDate;
        public decimal cost;
        public List<String> jbpResourceTypes;
        public List<String> jbpEndUsers;
        public List<String> jbpCommunities;
        public String investorName; 
        public String jbpOthers; 
        public decimal jbpTotalDatabase;
        public decimal jbpRelavantDatabase;
        public decimal nriDatabase;
        public decimal osDatabase;
        public String corporatePrivateOrg; 
        public String club; 
        public String association; 
        public String society; 
        public String governmentOrg; 
        public String psu; 
        public String religiousPlace;
        public decimal inroadExpectedReach;
        public String jbpInterest;
        public String tlRating;
        public String smRating;
    }

    @AuraEnabled
    public static void createjbpRecord(String jsonInput) {
        try {
            // Deserialize JSON input into the Person object
            if(jsonInput != null && jsonInput != ''){
                System.debug('jsonInput JBP: ' + jsonInput);
                JBPDetails jbpData = (JBPDetails) JSON.deserialize(jsonInput, JBPDetails.class);
                System.debug('newEvent: ' + jbpData);
                EYI_Joint_Business_Plan__c jbpRecord =  new EYI_Joint_Business_Plan__c();
                jbpRecord.EYI_Activity_Status__c = jbpData.jbpStatus;
                jbpRecord.EYI_Activity_Support_Required__c = jbpData.jbpActionSupport;
                jbpRecord.EYI_Activity_type__c = jbpData.jbpActivityType;
                jbpRecord.EYI_Start_Date__c = jbpData.startDate;
                jbpRecord.EYI_End_Date__c = jbpData.endDate;
                jbpRecord.EYI_Project__c = jbpData.jbpProject;
                jbpRecord.EYI_Cost__c = jbpData.cost;
                String Interests = '';
                Boolean Start = true;
                // Process jbpResourceTypes
                //List<String> resourceTypesList = jbpData.jbpResourceTypes.split(',');
                if (!jbpData.jbpResourceTypes.isEmpty()) {
                    for (String str : jbpData.jbpResourceTypes) {
                        if (Start) {
                            Interests = str;
                            Start = false;
                        } else {
                            Interests = Interests + ';' + str;
                        }
                    }
                }

                // Now you have Interests as a semicolon-separated string

                // Process jbpEndUsers
                String EndUsers = '';
                Start = true;
                //List<String> endUserList = jbpData.jbpEndUsers.split(',');
                if (!jbpData.jbpEndUsers.isEmpty()) {
                    for (String str : jbpData.jbpEndUsers) {
                        if (Start) {
                            EndUsers = str;
                            Start = false;
                        } else {
                            EndUsers = EndUsers + ';' + str;
                        }
                    }
                }

                // Process jbpCommunities
                String Communities = '';
                Start = true;
                //List<String> jbpCommunities = jbpData.jbpCommunities.split(',');
                if (!jbpData.jbpCommunities.isEmpty()) {
                    for (String str : jbpData.jbpCommunities) {
                        if (Start) {
                            Communities = str;
                            Start = false;
                        } else {
                            Communities = Communities + ';' + str;
                        }
                    }
                }
                jbpRecord.EYI_Type_of_Resources__c = Interests;  // Assigning Interests to the field
                jbpRecord.EY_End_User__c = EndUsers;           // Assigning EndUsers to the field
                jbpRecord.EYI_Community__c = Communities;
                jbpRecord.EYI_Investor__c = jbpData.investorName;
                jbpRecord.EYI_Others__c = jbpData.jbpOthers;
                jbpRecord.EYI_Total_Database__c = jbpData.jbpTotalDatabase;
                jbpRecord.EYI_Relevant_Database__c = jbpData.jbpRelavantDatabase;
                jbpRecord.EYI_OS_Data__c = jbpData.osDatabase;
                jbpRecord.EYI_NRI_Data__c = jbpData.nriDatabase;
                jbpRecord.EYI_Corporate_Private_organisation__c = jbpData.corporatePrivateOrg;
                jbpRecord.EYI_Club__c = jbpData.club;
                jbpRecord.EYI_Association__c = jbpData.association;
                jbpRecord.EYI_Society__c = jbpData.society;
                jbpRecord.EYI_Government_Org__c = jbpData.governmentOrg;
                jbpRecord.EYI_PSU__c = jbpData.psu;
                jbpRecord.EYI_Religious_Place_ex_iscon__c = jbpData.religiousPlace;
                jbpRecord.EYI_Inroad_Expected_Reach__c = jbpData.inroadExpectedReach;
                jbpRecord.EYI_REC_Interest_Level__c = jbpData.jbpInterest;
                jbpRecord.EYI_SM_Rating__c = jbpData.tlRating;
                jbpRecord.EYI_TL_Rating__c = jbpData.smRating;
                jbpRecord.EYI_JBP_Name__c = jbpData.jbpName;
                if(jbpData.recAccount != null && jbpData.recAccount != ''){
                    jbpRecord.REC_Account__c = jbpData.recAccount;
                }
                if(jbpData.recMapping != null && jbpData.recMapping != ''){
                    jbpRecord.EYI_Project_REC_Mapping__c = jbpData.recMapping;
                }
                //jbpRecord.
                insert jbpRecord;
                System.debug('jbpRecord: ' + jbpRecord);

            }
        }catch(Exception e){
            System.debug('Error in deserialization: ' + e.getMessage());
        }
    }

    public class BookingWrapper {
        @AuraEnabled public String bookingId { get; set; }
        @AuraEnabled public String customerName { get; set; }
        @AuraEnabled public String recName { get; set; }
        @AuraEnabled public String projectName { get; set; }
        @AuraEnabled public String sourcingManager { get; set; }

        public BookingWrapper(EYI_Booking__c booking) {
            this.bookingId = booking.Id;
            this.customerName = booking.Customer_Name__c;
            this.recName = booking.EYI_REC_Account__r.EYI_REC_Full_Name__c;
            this.projectName = booking.EYI_Project_Name__r.Name;
            this.sourcingManager = booking.EYI_Sourcing_manager__c;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<BookingWrapper> getBookings() {
        // Query the bookings
        List<EYI_Booking__c> bookings = [
            SELECT Id, 
                   Customer_Name__c,
                   EYI_REC_Account__r.EYI_REC_Full_Name__c,
                   EYI_Project_Name__r.Name,
                   EYI_Sourcing_manager__c
            FROM EYI_Booking__c
            WHERE EYI_Sourcing_manager__c = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];

        // Wrap the results in the BookingWrapper class
        List<BookingWrapper> result = new List<BookingWrapper>();
        for (EYI_Booking__c booking : bookings) {
            result.add(new BookingWrapper(booking));
        }
        return result;
    }

    
    @AuraEnabled
    public static List<BookingWrapper> getFilteredBookings(String project,String dateRange,  Datetime startDate, Datetime endDate) {
        // Constructing the SOQL query with filters
        if (endDate != null) { endDate = endDate.addDays(1);}

        List<EYI_Booking__c> blist= new List<EYI_Booking__c>();
        // Constructing the SOQL query with filters
        System.debug('project===> ' + project);
        System.debug('startDateTime===> ' + startDate);
        System.debug('endDateTime===> ' + endDate);

        String query = 'SELECT Id, EYI_Sourcing_manager__c, Customer_Name__c, EYI_REC_Account__r.EYI_REC_Full_Name__c, EYI_Project_Name__r.Name ' +
               'FROM EYI_Booking__c ' +
               'WHERE EYI_Sourcing_manager__c = :UserInfo.getUserId() AND Customer_Name__c != null';
        
        if (project != null && project != '') {
            query += ' AND EYI_Project_Name__c = :project'; // Assuming there is a custom field Project__c to filter by project
        }
        
        if(dateRange == 'custom'){            
            if (startDate != null) {
                query += ' AND CreatedDate >= :startDate';
            }
            if (endDate != null) {
                query += ' AND CreatedDate <= :endDate';
            }
        }else if(dateRange != '' && dateRange != null){            
            query += ' AND CreatedDate = ' + dateRange;
        }
        
        query += ' ORDER BY CreatedDate DESC';
        
        System.debug('query===>'+query);
        try{
            blist= Database.query(query);
            System.debug('query= blist==>'+blist);

        }catch(Exception e){
            System.debug(e.getMessage());
        }
        List<BookingWrapper> result = new List<BookingWrapper>();
        for (EYI_Booking__c booking : blist) {
            result.add(new BookingWrapper(booking));
        }
        return result;
        // return blist;
    }
    

    public class CIFWrapper {
        @AuraEnabled public String cifId { get; set; }
        @AuraEnabled public String customerName { get; set; }        
        @AuraEnabled public String recName { get; set; }
        @AuraEnabled public String projectName { get; set; }
        @AuraEnabled public String visitDate{get;set;}

        // Constructor to initialize the wrapper with the queried data
        public CIFWrapper(EYI_Customer_Information_Form__c cif) {
            this.cifId = cif.Id;
            this.customerName = cif.EYI_First_Name__c +' '+ cif.EYI_Last_Name__c;
            this.recName = cif.EYI_REC_Account__r.EYI_REC_Full_Name__c;
            this.projectName = cif.EYI_Project_Enquired__r.Name;

            if(cif.EYI_Visit_Date__c != null){
                this.visitDate = String.valueOf(cif.EYI_Visit_Date__c);
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CIFWrapper> getCIFs() {
        // Query the Customer Information Form records
        List<EYI_Customer_Information_Form__c> cifs = [
            SELECT Id, 
                   EYI_First_Name__c, 
                   EYI_Last_Name__c,
                   EYI_REC_Account__r.EYI_REC_Full_Name__c,
                   EYI_Project_Enquired__c,
                   EYI_Project_Enquired__r.Name,
                   EYI_Visit_Date__c
            FROM EYI_Customer_Information_Form__c
            WHERE CreatedById = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC 
            LIMIT 10
        ];

        // Wrap the results into the CIFWrapper class
        List<CIFWrapper> result = new List<CIFWrapper>();
        for (EYI_Customer_Information_Form__c cif : cifs) {
            result.add(new CIFWrapper(cif));
        }
        return result;
    }

    
    @AuraEnabled
    public static  List<CIFWrapper> getFilteredCIFs(String project,String dateRange,  Datetime startDate, Datetime endDate) {
        // Constructing the SOQL query with filters
        if (endDate != null) { endDate = endDate.addDays(1);}

        List<EYI_Customer_Information_Form__c> blist= new List<EYI_Customer_Information_Form__c>();
        // Constructing the SOQL query with filters
        System.debug('project===> ' + project);
        System.debug('startDateTime===> ' + startDate);
        System.debug('endDateTime===> ' + endDate);

        String query = 'SELECT Id,EYI_Project_Enquired__c, EYI_First_Name__c, EYI_Visit_Date__c, EYI_Last_Name__c,EYI_REC_Account__r.EYI_REC_Full_Name__c,EYI_Project_Enquired__r.Name FROM EYI_Customer_Information_Form__c WHERE Id != null ';
        
        if (project != null && project != '') {
            query += ' AND EYI_Project_Enquired__c = :project'; // Assuming there is a custom field Project__c to filter by project
        }
        
        if(dateRange == 'custom'){            
            if (startDate != null) {
                query += ' AND CreatedDate >= :startDate';
            }
            if (endDate != null) {
                query += ' AND CreatedDate <= :endDate';
            }
        }else if(dateRange != '' && dateRange != null){            
            query += ' AND CreatedDate = ' + dateRange;
        }
        
        query += ' ORDER BY CreatedDate DESC';
        
        System.debug('query===>'+query);
        try{
            blist= Database.query(query);
            System.debug('query= blist==>'+blist);

        }catch(Exception e){
            System.debug(e.getMessage());
        }
        List<CIFWrapper> result = new List<CIFWrapper>();
        for (EYI_Customer_Information_Form__c cif : blist) {
            result.add(new CIFWrapper(cif));
        }
        return result;
    }
    
    
    public class TaskWrapper {
        @AuraEnabled public String nextactiondate { get; set; }
        @AuraEnabled public String taskId { get; set; }
        @AuraEnabled public String taskSubject { get; set; }
        @AuraEnabled public String taskCreatedBy { get; set; }
        @AuraEnabled public String taskCreatedDate { get; set; }  // CreatedDate as string
        @AuraEnabled public String taskProjectName { get; set; }  // New field for EYI_Project_Name__c
        @AuraEnabled public String taskStatus { get; set; }  // New field for Status
        @AuraEnabled public String whatId { get; set; }  // WhatId (ID of the related object)
        @AuraEnabled public String Description { get; set; }  // WhatId (ID of the related object)
        @AuraEnabled public String recName { get; set; }  // WhatId (ID of the related object)

        // Constructor to initialize the wrapper with queried Task data
        public TaskWrapper(Task task) {
            this.taskId = task.Id;
            this.taskSubject = task.Subject;
            this.taskCreatedBy = task.CreatedBy.Name;
            this.taskCreatedDate = task.CreatedDate.date().format(); // Convert CreatedDate to string
            this.taskProjectName = task.EYI_Project_Name__r.Name;  // Assign the EYI_Project_Name__c value
            this.taskStatus = task.Status;  // Assign the Status value
            this.whatId = task.WhatId;  // Assign the WhatId (ID of the related record)
            this.Description = task.Description;  // Assign the Description value
            this.recName = task.EYI_REC_Account__r.EYI_REC_Full_Name__c;
            //this.nextactiondate = task.EYI_Next_Action_Date_Time__c;
             if (task.EYI_Next_Action_Date_Time__c != null) {
            this.nextactiondate = task.EYI_Next_Action_Date_Time__c.format('MMM dd, yyyy hh:mm a');
                // Example: "Jun 23, 2025 03:15 PM"
            } else {
                this.nextactiondate = '';
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TaskWrapper> getTasks() {
        // Query the Task records with additional fields
        List<Task> tasks = [
            SELECT Id, Subject, CreatedBy.Name,WhatId,EYI_REC_Account__c,EYI_REC_Account__r.EYI_REC_Full_Name__c, CreatedDate, EYI_Project_Name__r.Name, Status,Description,EYI_Next_Action_Date_Time__c
            FROM Task
            WHERE CreatedById = :UserInfo.getUserId() AND EYI_REC_Account__c != null
            ORDER BY CreatedDate DESC
        ];

        // Wrap the Task records into TaskWrapper objects
        List<TaskWrapper> result = new List<TaskWrapper>();
        for (Task task : tasks) {
            result.add(new TaskWrapper(task));
        }
        return result;
    }
    @AuraEnabled
    public static List<TaskWrapper>  getFilteredTasks(String project,String dateRange,  Datetime startDate, Datetime endDate , String recId) {
        // Constructing the SOQL query with filters
        if (endDate != null) { endDate = endDate.addDays(1);}
        List<Task> taskList= new List<Task>();
        // Constructing the SOQL query with filters
        System.debug('project===> ' + project);
        System.debug('startDateTime===> ' + startDate);
        System.debug('endDateTime===> ' + endDate);

        String userId = UserInfo.getUserId(); // Store the UserId in a variable
        String query = 'SELECT Id, Subject, CreatedBy.Name,WhatId,EYI_REC_Account__r.EYI_REC_Full_Name__c,EYI_Next_Action_Date_Time__c, CreatedDate, EYI_Project_Name__r.Name, Status,Description FROM Task WHERE OwnerId = \'' + userId + '\' AND Subject != null';

       if (recId != null && recId != '') {
            query += ' AND EYI_REC_Account__r.EYI_REC_Full_Name__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\'';
        }

        
        if(dateRange == 'custom'){            
            if (startDate != null) {
                query += ' AND CreatedDate >= :startDate';
            }
            if (endDate != null) {
                query += ' AND CreatedDate <= :endDate';
            }
        }else if(dateRange != '' && dateRange != null){            
            query += ' AND CreatedDate = ' + dateRange;
        }
        
        query += ' ORDER BY CreatedDate DESC';
        
        System.debug('query===>'+query);
        try{
            taskList= Database.query(query);
            System.debug('query= blist==>'+taskList);

        }catch(Exception e){
            System.debug(e.getMessage());
        }
        List<TaskWrapper> result = new List<TaskWrapper>();
        for (Task task : taskList) {
            result.add(new TaskWrapper(task));
        }
        return result;
        //return taskList;
    }
    

    public class VPVCWrapper {
        @AuraEnabled public String vpvcId { get; set; }
        @AuraEnabled public String vpvcName { get; set; }
        @AuraEnabled public String clientName { get; set; }
        @AuraEnabled public String companyName { get; set; }
        @AuraEnabled public String recName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String proposedDate { get; set; }
        @AuraEnabled public String visitDate { get; set; }
        @AuraEnabled public String projectName { get; set; }

        // Constructor to map the queried data to the wrapper
        public VPVCWrapper(EYI_VP_VC__c vpvc) {
            this.vpvcId = vpvc.Id;
            this.clientName = vpvc.EYI_Client_Name__c;
            this.companyName = vpvc.EYI_Company_Name__c;
            this.recName = vpvc.EYI_REC_Account__r.EYI_REC_Full_Name__c;
            this.status = vpvc.EYI_Status__c;
            this.proposedDate = (vpvc.EYI_Visit_Proposed_Date__c != null) ? vpvc.EYI_Visit_Proposed_Date__c.date().format() : ''; 
            this.visitDate = (vpvc.EYI_Visit_Confirmed_Date__c != null) ? vpvc.EYI_Visit_Confirmed_Date__c.date().format() : '';
            this.projectName = vpvc.EYI_Project__r.Name;
            this.vpvcName = vpvc.Name;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<VPVCWrapper> getVPVCs() {
        // Query the EYI_VP_VC__c records
        List<EYI_VP_VC__c> vpvcs = [
            SELECT Id, Name,
                   EYI_Client_Name__c, 
                   EYI_Company_Name__c, 
                   EYI_REC_Account__r.EYI_REC_Full_Name__c,
                   EYI_Status__c, 
                   EYI_Visit_Proposed_Date__c,
                   EYI_Visit_Confirmed_Date__c,
                   EYI_Project__r.Name
            FROM EYI_VP_VC__c
            WHERE OwnerId = :UserInfo.getUserId()
            AND EYI_REC_Account__r.OwnerId = :UserInfo.getUserId()
        ];

        // Wrap the queried records into VPVCWrapper objects
        List<VPVCWrapper> result = new List<VPVCWrapper>();
        for (EYI_VP_VC__c vpvc : vpvcs) {
            result.add(new VPVCWrapper(vpvc));
        }
        System.debug('result===>'+result);

        return result;
    }
    
    @AuraEnabled
    public static List<VPVCWrapper> getFilteredVPVCs(String project,String dateRange, Datetime startDate, Datetime endDate) {
        // Constructing the SOQL query with filters
        if (endDate != null) { endDate = endDate.addDays(1);}

        List<EYI_VP_VC__c> vpvcList= new List<EYI_VP_VC__c>();
        // Constructing the SOQL query with filters
        System.debug('project===> ' + project);
        System.debug('dateRange===> ' + dateRange);
        System.debug('startDateTime===> ' + startDate);
        System.debug('endDateTime===> ' + endDate);
        List<VPVCWrapper> result = new List<VPVCWrapper>();

        String userId = UserInfo.getUserId();
        String query = 'SELECT Id,NAme, EYI_Client_Name__c,EYI_Visit_Proposed_Date__c,EYI_Visit_Confirmed_Date__c, EYI_Company_Name__c,EYI_REC_Account__r.EYI_REC_Full_Name__c,EYI_Status__c, EYI_Project__r.Name FROM EYI_VP_VC__c WHERE OwnerId = :userId';
        
        if (project != null && project != '') {
            query += ' AND EYI_Project__c = :project'; // Assuming there is a custom field Project__c to filter by project
        }
        
        if(dateRange == 'custom'){            
            if (startDate != null) {
                query += ' AND CreatedDate >= :startDate';
            }
            if (endDate != null) {
                query += ' AND CreatedDate <= :endDate';
            }
        }else if(dateRange != '' && dateRange != null){            
            query += ' AND CreatedDate = ' + dateRange;
        }
        
        query += ' ORDER BY CreatedDate DESC';
        
        System.debug('query===>'+query);
        try{
            vpvcList= Database.query(query);
            System.debug('query= blist==>'+vpvcList);
            for (EYI_VP_VC__c vpvc : vpvcList) {
                result.add(new VPVCWrapper(vpvc));
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return result;    
    }
    public class taskDetailsSmModel {
        public String taskSubject;
        public String taskCallType;
        public String taskCallStatus;
        public String taskCallReason;
        public String taskNotConnectReason;
        public String callRemarks;
        public String recAccount;
        public String recMapping;
        public String activityType;

        public String taskJBP;
        public String meetingStatus;
        public String taskMeetingType;
        public String taskMeetingReason;
        public String meetingRemarks;
        public String meetingLocation;
        public String meetingInterest;
        public Double meetingLatitude;
        public Double meetingLongitude;
        public String projectName;
        public String taskDescription;
        public Date activityStartDate;
        public Date activityEndDate;

        public String nextAction;
        public String recName;
        public Datetime nextActionDateTime;

    }
    @AuraEnabled
    public static void createTaskSMModel(String jsonInput) {
        try {
            // Deserialize JSON input into the Person object
            if(jsonInput != null && jsonInput != ''){
                System.debug('jsonInput: ' + jsonInput);
                taskDetailsSmModel taskData = (taskDetailsSmModel) JSON.deserialize(jsonInput, taskDetailsSmModel.class);
                Task newTask = new Task();
                newTask.OwnerId = UserInfo.getUserId();
                newTask.EYI_AutomationBypassDatetime__c = System.now();
                newTask.RecordtypeId = System.Label.EYI_SourcingTaskRecordType;
                newTask.WhatId = taskData.recAccount;
                newTask.EYI_REC_Account__c = taskData.recAccount;
                newTask.status = 'Completed';
                
                if(taskData.taskSubject != ''){
                    newTask.Subject = taskData.taskSubject;
                }else{
                    newTask.Subject = 'Other';
                }
                if(taskData.taskCallType != null && taskData.taskCallType != ''){
                    newTask.EYI_Call_Type__c = taskData.taskCallType;
                }
                if(taskData.taskCallStatus != null && taskData.taskCallStatus != ''){
                    newTask.EYI_Call_Status__c = taskData.taskCallStatus;
                }
                if(taskData.taskJBP != null && taskData.taskJBP != ''){
                    newTask.EYI_Joint_Business_Plan__c = taskData.taskJBP;
                }
                if(taskData.recMapping != null && taskData.recMapping != ''){
                    newTask.EYI_Project_REC_Mapping__c = taskData.recMapping;
                }
                 if(taskData.callRemarks != null && taskData.callRemarks != ''){
                    newTask.EYI_Call_Remarks__c = taskData.callRemarks;
                    newTask.Description = taskData.callRemarks;
                 }
                 
                 if(taskData.meetingRemarks != null && taskData.meetingRemarks != ''){
                    newTask.EYI_Meeting_Remarks__c = taskData.meetingRemarks;
                    newTask.Description = taskData.meetingRemarks;
                 }
                 if(taskData.taskMeetingType != null && taskData.taskMeetingType != ''){
                    newTask.EYI_Meeting_Type__c = taskData.taskMeetingType;
                }
                if(taskData.taskMeetingReason != null && taskData.taskMeetingReason != ''){
                    newTask.EYI_Reason_for_meeting__c = taskData.taskMeetingReason;
                }
                if(taskData.meetingInterest != null && taskData.meetingInterest != ''){
                    newTask.EYI_Interested_in_Event__c = taskData.meetingInterest;
                }
                if(taskData.meetingLocation != null && taskData.meetingLocation != ''){
                    newTask.EYI_Meeting_Location__c = taskData.meetingLocation;
                }
                if(taskData.meetingLatitude != null && taskData.meetingLatitude != 0){
                    newTask.Location__Latitude__s   = taskData.meetingLatitude;
                }
                if(taskData.meetingLongitude != null && taskData.meetingLongitude != 0){
                    newTask.Location__Longitude__s = taskData.meetingLongitude;
                }
                if(taskData.projectName != null && taskData.projectName != ''){
                    newTask.EYI_Project_Name__c = taskData.projectName;
                }
                if(taskData.meetingStatus != null && taskData.meetingStatus != ''){
                    newTask.EYI_Meeting_Status__c = taskData.meetingStatus;
                }
                if(taskData.activityStartDate != null){
                    newTask.EYI_Activity_Start_Date__c = taskData.activityStartDate;
                }
                if(taskData.activityEndDate != null){
                    newTask.EYI_Activity_End_Date__c = taskData.activityEndDate;
                }
                if(taskData.taskCallReason != null && taskData.taskCallReason != ''){
                    newTask.EYI_Calling_Reason__c = taskData.taskCallReason;
                }
                if(taskData.taskNotConnectReason != null && taskData.taskNotConnectReason != ''){
                    newTask.EYI_Call_Not_Connected_Reasons__c = taskData.taskNotConnectReason;
                }
                if(taskData.nextAction != null && taskData.nextAction != ''){
                    newTask.EYI_Next_Action_Status__c = taskData.nextAction;
                }
                if(taskData.nextActionDateTime != null){
                    newTask.EYI_Next_Action_Date_Time__c = taskData.nextActionDateTime;
                }
                if(taskData.activityType != null){
                    newTask.EYI_Activity_Type__c = taskData.activityType;
                }
                if(taskData.taskDescription != null && taskData.taskDescription != ''){
                    newTask.Description = taskData.taskDescription;
                    newTask.EYI_Meeting_Remarks__c = taskData.taskDescription;
                }
                insert newTask;
                System.debug('newTask deserialization: ' + newTask);
                // if( taskData.nextAction != '' && taskData.nextActionDateTime != null){
                //     Datetime nextActionDateTime = taskData.nextActionDateTime;
                //     Datetime reminderDateTime = nextActionDateTime.addMinutes(-15);
                //     Task followUpTask = new Task(
                //         Subject = 'Follow up with ' + taskData.recName,
                //         Status = 'Open',
                //         Priority = 'Normal',
                //         ActivityDate = Date.newInstance(nextActionDateTime.year(), nextActionDateTime.month(), nextActionDateTime.day()),
                //         ReminderDateTime = reminderDateTime,
                //         IsReminderSet = true,
                //         EYI_AutomationBypassDatetime__c= system.now(),
                //         WhatId = taskData.recAccount
                //     );
                //     insert followUpTask;
                //     System.debug('followUpTask deserialization: ' + followUpTask);
                //     System.debug('followUpTask deserialization: ' + followUpTask.Id);
                // }
            }
        }catch(Exception e){
            System.debug('Error in deserialization: ' + e.getMessage());
        }
    }
}