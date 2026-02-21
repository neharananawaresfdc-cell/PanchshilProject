/**
* @description       : This class is used to create the test records for the testing purposes.
* @group             : EY Notification Framework
* @last modified by  : Digambar Ganage 
**/
@isTest
public with sharing class EYI_TestDataFactory {

    public static List<Account> createAccounts(String Name, Integer numberOfAccounts, Boolean isInsert) {
        List<Account> accountList = new List<Account>();
        for(Integer i=0; i<numberOfAccounts; i++) {
            Account account = new Account(
                Name = Name
            );
            accountList.add(account);
        }
        if(isInsert){
            insert accountList;
        }
        return accountList;
    }

    public static List<EYI_Project__c> createProjects(String Name, Integer numberOfProjects, Boolean isInsert, String projectType) {
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, SObjectType, DeveloperName FROM RecordType WHERE SObjectType = 'EYI_Project__c' AND (DeveloperName = 'Commercial' OR DeveloperName = 'Residential')]) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        String uniqueId = String.valueOf(DateTime.now().getTime()) + String.valueOf(Math.random()).substring(2,8);
        for(Integer i=0; i<numberOfProjects; i++) {
            EYI_Project__c project = new EYI_Project__c(
                Name = Name + '_' + uniqueId + '_' + i,
                EYI_Project_Code__c = 'P-00'+uniqueId+i,
                EYI_Project_Property_Type__c = 'Commercial',
                RecordTypeId = recordTypeMap.get(projectType),
				EYI_Stamp_Duty__c= 10,
                EYI_Opportunity_TAT__c = 1
            );
            projectList.add(project);
        }
        if(isInsert){
            insert projectList;
        }
        return projectList;
    }
	
    public static List<EYI_Project__c> createProjectsForLeads(String Name, Integer numberOfProjects, Boolean isInsert, String projectType) {
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, SObjectType, DeveloperName FROM RecordType WHERE SObjectType = 'EYI_Project__c' AND (DeveloperName = 'Commercial' OR DeveloperName = 'Residential')]) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        String uniqueId = String.valueOf(DateTime.now().getTime()) + String.valueOf(Math.random()).substring(2,8);
        for(Integer i=0; i<numberOfProjects; i++) {
            EYI_Project__c project = new EYI_Project__c(
                Name = Name,
                EYI_Project_Code__c = 'P-00'+uniqueId+i,
                EYI_Project_Property_Type__c = 'Commercial',
                RecordTypeId = recordTypeMap.get(projectType),
				EYI_Stamp_Duty__c= 10,
                EYI_Opportunity_TAT__c = 1
            );
            projectList.add(project);
        }
        if(isInsert){
            insert projectList;
        }
        return projectList;
    }
    public static List<Lead> createLeads(String LastName,String Project, Integer numberOfLeads,String MobileNo, String Source, String SubSource, Boolean isInsert) {
        String uniqueId = String.valueOf(DateTime.now().getTime()) + String.valueOf(Math.random()).substring(2,8);
        List<EYI_Project__c> projectList = createProjectsForLeads(Project, 1, true,'Commercial');        
        List<Lead> leadList = new List<Lead>();
        for(Integer i=0; i<numberOfLeads; i++) {
            Lead lead = new Lead(
                FirstName = 'Test' + i,
                LastName = LastName + i, 
                Status='',
                LeadSource = Source,
                EYI_Lead_Sub_Source__c = SubSource,
                EYI_Segment__c = 'Commercial',
                EYI_Designation__c='Test',
                Company='Panchshil',
                Description='test',
                EYI_LeadType__c = 'Retail',
                EYI_Property__c = 'Golden Bell',
                //EYI_Budget__c='3.25 Crore to 3.50 Crore',
                EYI_Client_Communication_Preference__c='SMS;WhatsApp',
                EYI_Nature_of_Lead__c='Outright',
                EYI_Project_Enquired__c=projectList[0].id,
                Email = LastName+i+'@example.com', 
                Phone = MobileNo + i,
                MobilePhone = MobileNo + i
            );
            
            leadList.add(lead);
        }
        if(isInsert){
            insert leadList;
        }
        return leadList;
    }

    public static List<Contact> createContacts(String LastName, Integer numberOfContacts, Boolean isInsert) {
        List<Account> accountList = createAccounts('Test', 1, true);
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i<numberOfContacts;  i++  ){
            Contact contact = new Contact(
                FirstName = 'FirstName',
                LastName = LastName + i,
                Email = 'test'+i+'@test.com',
                description = 'Title',
                AccountId = accountList[0].Id
            ); 
            contactList.add(contact);
        }
        if(isInsert){
            insert contactList;
        }   
        return contactList;
    }     

    public static List<Task> createPresalesTask(String Subject, Integer numberOfTasks, Boolean isInsert) {
        List<Task> taskList = new List<Task>();
        List<Lead> leadList = createLeads('Test','Panchshil Towers',4,'983434334','Direct Client','',true);
        EYI_Lead_Enquiry__c enq = new EYI_Lead_Enquiry__c();
        enq.EYI_Parent_Record__c = leadList[0].Id;
        enq.EYI_Lead_Source__c = 'Web';
        enq.OwnerId = UserInfo.getUserId();
        enq.EYI_Phone__c = '1234567890';
        insert enq;
        System.debug('Lead Id: '+enq);
		System.debug('System.Label.EYI_Presales_Record_Type_Id ==> '+System.Label.EYI_Presales_Record_Type_Id);
        for(Integer i=0; i<numberOfTasks; i++) {
            Task task = new Task(
                Subject = 'Follow Up',
                WhatId = enq.Id,
                RecordTypeId =System.Label.EYI_Presales_Record_Type_Id,
                Priority = 'Normal',
                Status = 'Open',
                Type = 'Presales Task',
                EYI_Next_Action_Date__c =  System.today(),
                EYI_Next_Action_Time__c =  '10:30 AM - 11:30 AM',
                ReminderDateTime = System.now(),
                OwnerId = UserInfo.getUserId(),
				EYI_Next_Action_Date_Time__c = DateTime.newInstance(System.today().addDays(1), Time.newInstance(10, 30, 0, 0))
            );
			System.debug('task.recordTypeId ==> '+task.recordTypeId);
            taskList.add(task);
        }
        if(isInsert){
            insert taskList;
        }
        return taskList;
    }

    public static User createUser(String userName, String profileName) {
        // Fetch the profile by its name dynamically
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        
        // Create a new User record with the dynamic name and profile
        User newUser = new User(
            FirstName = userName.split(' ')[0],  // Assuming the first name is the first part of the name
            LastName = userName.split(' ')[1],   // Assuming the last name is the second part of the name
            Alias = userName.substring(0, 5),    // Alias is typically a shortened version of the name
            Username = userName.replace(' ', '.') +System.now().getTime()+ '@example.com', // Make username unique with email domain
            Email = userName.replace(' ', '.') + '@example.com',   // Create an email using the name
            ProfileId = userProfile.Id,   // Set the profile ID dynamically
            TimeZoneSidKey = 'America/Los_Angeles',  // Set default timezone
            LocaleSidKey = 'en_US',      // Set default locale
            LanguageLocaleKey = 'en_US', // Set default language
            EmailEncodingKey = 'UTF-8'  // Set email encoding
        );
        
        // Insert the user record into the database
        insert newUser;
        // Return the created user
        return newUser;
    }

    public static EYI_Assignment_Group__c createassignmentGroup(String grpName, Boolean isInsert) {
        user user1 = createUser('Jay Shah', System.Label.Presales_Assignment_Group_Label);
        EYI_Assignment_Group__c grp = new EYI_Assignment_Group__c();
        grp.Name = grpName;
        grp.EYI_Presales_Head__c = user1.Id;
        grp.EYI_Team_Lead_TL__c = user1.Id;
        if(isinsert){
            insert grp;
        }
        return grp;
    }
    public static EYI_Assignment_Group_Member__c createAssignmentGroupMember(String grpName, Boolean isInsert) {
        EYI_Assignment_Group__c grp = createassignmentGroup(grpName,true);
        user user1 = createUser('Jaydip Shah', System.Label.Presales_Assignment_Group_Label);

        EYI_Assignment_Group_Member__c grpMember = new EYI_Assignment_Group_Member__c();
        grpMember.EYI_Assignment_Group__c = grp.Id;
        grpMember.EYI_Assignment_Member__c = user1.Id;
        if(isInsert){
            insert grpMember;
        }
        return grpMember;
    }

   
}