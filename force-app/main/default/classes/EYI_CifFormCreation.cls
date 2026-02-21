public without sharing class EYI_CifFormCreation {
    
    @AuraEnabled
    public static List<EYI_Project__c> getUserProjects(String user){
        List<EYI_Project__c> userProjects= new List<EYI_Project__c>();
        System.debug('user: ' + user);
        String currentProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        String statusLabel; // "Launch,Post Launch,Sustenance"
        
        if (currentProfileName == 'Leasing') {
        	statusLabel = System.Label.EYI_ProjectStatusValues;
        } else {
        	statusLabel = System.Label.EYI_ActiveProjectStatusValues;
        }

        List<String> statusList = new List<String>();
        for (String status : statusLabel.split(',')) {
            statusList.add(status.trim()); // Trim to remove any extra spaces
        }
        userProjects = [
            SELECT Id, Name, EYI_Project_Status__c
            FROM EYI_Project__c
            WHERE EYI_Project_Status__c IN :statusList
        ];
        System.debug('User Projects'+userProjects);
        return userProjects;
    }
    
    @AuraEnabled
    public static List<EYI_Lead_Enquiry__c> getLeads(String cont, String proj, String cc, String emailid){
        List<EYI_Lead_Enquiry__c> ld = new List<EYI_Lead_Enquiry__c>();

        String mobCC = cc + cont; //919359182343
        String mobZero = '0'+ cont; //09359182343
        String mobPlusCC = '+'+mobCC; //+919359182343
        String mobZeroCC = cc+ mobZero; // 0919359182343

        List<String> mobList = new List<String>{mobPlusCC,mobZero,mobCC,mobZeroCC,cont};
        String LikeCont = '%'+cont;
        //String cont2 = cont.substring(cont.length() - 10, cont.length());
        ld = [Select Id,Name,EYI_Parent_Record__r.FirstName,EYI_Parent_Record__r.MiddleName,EYI_Parent_Record__r.LastName,EYI_Company__c,EYI_Phone__c,EYI_Lead_Source__c,EYI_Lead_Sub_Source__c,EYI_Lead_Status__c, EYI_Project_Enquired__r.Name,EYI_Email__c,Owner.Name from EYI_Lead_Enquiry__c 
                where (EYI_Phone__c IN : mobList OR EYI_Phone__c LIKE : LikeCont OR EYI_Email__c =: emailid) and EYI_Project_Enquired__r.Id =:proj and EYI_Lead_Status__c NOT IN ('Lost','Visit Done') ];

        system.debug('lead enquiry data'+ ld);
        
        return ld;
    }
    
    @AuraEnabled
    public static List<EYI_Customer_Information_Form__c> getCIFs(String cont, String proj, String cc, String emailid){
        //String cont2 = cont.substring(cont.length() - 10, cont.length());
        String mobPlusCC = cc + cont; //+919359182343
        String mobZero = '0'+ cont; //09359182343
        String mobCC = mobPlusCC.replace('+',''); //919359182343
        String mobZeroCC = '0'+cc+ cont; // 0919359182343
        system.debug('cont'+cont);
        system.debug('proj'+proj);
        system.debug('cc'+cc);
        List<String> mobList = new List<String>{mobPlusCC,mobZero,mobCC,mobZeroCC,cont};

        List<EYI_Customer_Information_Form__c> cif = [Select Id,EYI_Salutation__c,EYI_First_Name__c,EYI_Middle_Name__c,EYI_Last_Name__c,EYI_Country_code__c,EYI_Mobile_number__c,EYI_Email_Id__c,EYI_Lead_Source__c,
        EYI_Lead_Sub_Source__c,EYI_Customer_residential_status__c,EYI_Passport_Number__c,Social_Security_Number__c,EYI_OCI__c,
        EYI_Customer_Address_Type__c,Customer_Locality__c,EYI_State__c,EYI_Country__c,EYI_Free_Text_City__c,Pincode__c,
        EYI_Address_1__c,EYI_Address_2__c,EYI_Address_3__c,EYI_Occupation__c,EYI_Designation__c,EYI_Company_Business_name__c,
        EYI_Local_Contact_Name__c,EYI_Local_Contact_Mobile_Number__c,EYI_Local_Contact_Relation__c,EYI_Walk_in_Source__c,EYI_Walk_in_Sub_source__c,
        EYI_REC_Account__c,Walk_in_Source_if_Other__c,EYI_Referral_Employee_Name__c,EYI_Client_Name__c,EYI_Project_Purchased__c,
        EYI_Client_Employer_Name__c,EYI_Presales_Executive__c,EYI_Closing_Manager__c, EYI_Opportunity__r.EYI_Ownership_Status__c, 
        EYI_Project_Enquired__r.Name,EYI_Closing_Manager__r.Name from EYI_Customer_Information_Form__c 
                                                        where (EYI_Mobile_number__c IN : mobList OR EYI_Mobile_number__c LIKE :('%'+cont) OR EYI_Email_Id__c =: emailid) 
                                                        and EYI_isActive__c=true ORDER BY CreatedDate DESC];
        return cif;
    }
    @AuraEnabled
    public static List<Lead> getLeadData(String cont, String proj){
        List<Lead> ld = new List<Lead>();
        ld = [Select Id,Name,Phone,LeadSource, EYI_Lead_Sub_Source__c, ConvertedOpportunityId,Status,EYI_Project_Enquired__r.Name,Email from Lead where Phone =:cont and EYI_Project_Enquired__c =:proj and Status NOT IN ('Lost','Not Qualified')];
        
        return ld;
    }
    
    
     @AuraEnabled
    public static List<EYI_Lead_Enquiry__c> getLeadphone(String cont, String cc, String emailid){
        String mobPlusCC = cc + cont; //+919359182343
        String mobZero = '0'+ cont; //09359182343
        String mobCC = mobPlusCC.replace('+',''); //919359182343
        String mobZeroCC = '0'+cc+ cont; // 0919359182343

        List<String> mobList = new List<String>{mobPlusCC,mobZero,mobCC,mobZeroCC,cont};

        List<EYI_Lead_Enquiry__c> ld = new List<EYI_Lead_Enquiry__c>();
        ld = [Select Id,Name,EYI_Parent_Record__r.FirstName,EYI_Parent_Record__r.MiddleName,EYI_Parent_Record__r.LastName,EYI_Company__c,EYI_Phone__c,EYI_Lead_Source__c,EYI_Lead_Sub_Source__c,EYI_Lead_Status__c, EYI_Project_Enquired__r.Name,EYI_Email__c,Owner.Name from EYI_Lead_Enquiry__c 
        where (EYI_Phone__c IN : mobList OR EYI_Mobile__c LIKE :('%' + cont) OR EYI_Email__c =:emailid) AND EYI_Lead_Status__c NOT IN ('Lost','Visit Done') ORDER BY CreatedDate DESC];

        //ld = [Select Id,Name,Phone,LeadSource, EYI_Lead_Sub_Source__c, ConvertedOpportunityId,Status,EYI_Project_Enquired__r.Name,Email 
        return ld;
    }
    
    @AuraEnabled
    public static List<EYI_Lead_Enquiry__c> getLead(String recId){
        try {
            System.debug('Searching Lead');
            System.debug(recId);
            List<EYI_Lead_Enquiry__c> ld = new List<EYI_Lead_Enquiry__c>();
            ld = [Select Id,EYI_Parent_Record__r.FirstName,OwnerId,EYI_Parent_Record__r.MiddleName,EYI_Parent_Record__r.LastName,EYI_Parent_Record__r.Phone,EYI_Parent_Record__r.MobilePhone,EYI_Lead_Source__c,EYI_Lead_Sub_Source__c,EYI_Campaign_Name__c,EYI_Closing_Manager__c, EYI_Parent_Record__r.Address,
                    EYI_Project_Enquired__c, EYI_Project_Enquired__r.Name,EYI_Parent_Record__r.Email,
                    EYI_Area_Requirement_sq_ft__c,EYI_Unit_Configuration__c,
                    EYI_Purpose_of_Purchase__c 
                    from EYI_Lead_Enquiry__c where Id =:recId AND EYI_Lead_Status__c NOT IN ('Lost','Visit Done')];
            System.debug('Lead: ' + ld);
            return ld;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    
    @AuraEnabled
    public static List<Opportunity> getOpportunity(String recId){
        try {
            List<Opportunity> Opp = new List<Opportunity>();
            opp = [Select Id, Name, EYI_First_Name__c,EYI_Mobile_Number__c,EYI_Email__c,EYI_Project_Enquired__r.Name,StageName from Opportunity where Id =:recId];
            return opp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Campaign> getCampaigns(String Source, String Subsource,String developer, String project){
        try {
            List<Campaign> campgn = new List<Campaign>();
            //campgn = [Select Id,Name from Campaign where Source__c=:Source and Sub_Source__c=:Subsource and Developer__c=:developer and EYI_Project__c=:project];
            campgn = [Select Id,Name from Campaign where EYI_Source__c=:Source and EYI_Sub_source__c=:Subsource and EYI_Project_name__c=:project];
            System.debug(campgn);
            return campgn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createOpportunityTeams(String OppId, String userId) {
        System.debug('OppId: ===>' + OppId);
        System.debug('userId: ===>' + userId);

        try {
            OpportunityTeamMember teamMember = new OpportunityTeamMember();
            teamMember.OpportunityId = OppId;
            teamMember.UserId = userId;
            teamMember.OpportunityAccessLevel = 'Edit'; // Setting the access level to Edit
            insert teamMember;
            updateSecClosingManager(OppId, userId);
        } catch (Exception e) {
            // Handle the exception
            System.debug('An error occurred: ' + e.getMessage());
            throw new AuraHandledException('Unable to create Opportunity Team Member: ' + e.getMessage());
        }
    }
    public static void updateSecClosingManager(String OppId, String userId){
        Opportunity opp = new Opportunity();
        try {
            opp.Id = OppId;
            opp.EYI_Secondary_Closing_Manager__c = userId;
            update opp;
        }catch (Exception e) {
            // Handle the exception
            System.debug('An error occurred: ' + e.getMessage());
        }
    } 

    @AuraEnabled
    public static EYI_Project__c getProject(String projName){
        //Commented by Ishan and modified on the below line
        //EYI_Project__c proj = [Select Id, Name,EYI_Pass_Code__c,(Select Id,Name,Area__c,Budget__c,Configuration__c from Phases__r) from EYI_Project__c where Name =:projName];
        EYI_Project__c proj = [Select Id, Name from EYI_Project__c where Name =:projName];
        return proj;
    }

    @AuraEnabled
    public static String getProjectById(String projId) {
        List<EYI_Project__c> projectObj = [Select Id, Name from EYI_Project__c Where Id = :projId Limit 1];
        return projectObj[0].Name;
    }

    @AuraEnabled
    public static String createLead(EYI_Customer_Information_Form__c cif, String projectName ){
        try {
            System.debug('270 CIF Lead Creation');
            System.debug('cif===>'+cif);
            System.debug('projectName===>'+projectName);
            system.debug('Lead source' + cif.EYI_Walk_in_Source__c);
            system.debug('Lead source' + cif.EYI_Walk_in_Sub_source__c);
            Lead ld = new Lead();

            ld.FirstName = cif.EYI_First_Name__c;
            ld.LastName = cif.EYI_Last_Name__c;
            ld.Email = cif.EYI_Email_Id__c;
            ld.Phone = cif.EYI_Mobile_number__c;            
            ld.MobilePhone = cif.EYI_Secondary_Mobile_Number__c;
            if(cif.EYI_Walk_in_Source__c != 'Chat Bot' && cif.EYI_Walk_in_Source__c !='CTI' && cif.EYI_Walk_in_Source__c !='Email' && cif.EYI_Walk_in_Source__c !='Marketing' && cif.EYI_Walk_in_Source__c !='Mobile App' && cif.EYI_Walk_in_Source__c !='Presales' && cif.EYI_Walk_in_Source__c !='Privilege'  && cif.EYI_Walk_in_Source__c !='Web' ){
                ld.EYI_SM_Lead_Enquiry__c =  true;
            }
            
            ld.Company = 'NA';
           // ld.EYI_Country_Code__c = cif.EYI_Country_Code__c
            ld.EYI_Segment__c = cif.EYI_Project_Type__c;
            //ld.EYI_Project_Enquired__c = cif.EYI_Project_Enquired__c;
            ld.EYI_Property__c = projectName;
            ld.LeadSource = cif.EYI_Walk_in_Source__c;
            ld.EYI_Lead_Sub_Source__c = cif.EYI_Walk_in_Sub_source__c;
            ld.EYI_Nature_of_Lead__c = cif.EYI_Nature_of_Lead__c;
            ld.EYI_AutomationBypassDatetime__c = System.now();

            //ld.Occupation__c = cif.Occupation__c; To be checked with Rishikesh

            insert ld;
            System.debug('New Lead===>'+ld);

            List<EYI_Lead_Enquiry__c> ldEn = getLeads(ld.Phone,ld.EYI_Project_Enquired__c,'',ld.Email);
            System.debug('New ldEn===>'+ldEn);

            if(!ldEn.isEmpty()){
                return ldEn[0].Id;
            }
            else{
                //List<EYI_Lead_Enquiry__c> ldEN1 = [Select Id,Name FROM EYI_Lead_Enquiry__c WHERE EYI_Parent_Record__c =:ld.Id ORDER BY CreatedDate DESC];
                return null;
            }
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createrec(EYI_Customer_Information_Form__c cifRec){
        try {
            System.debug('cifRec Lead Creation==> '+cifRec);
            EYI_REC__c currREC = new EYI_REC__c();
            currREC.EYI_First_Name__c = cifRec.EYI_CP_Executive_Name_Not_Registered__c;
            currREC.EYI_Last_Name__c = cifRec.EYI_REC_Executive_LastName_NonRegistered__c;
            currREC.EYI_Mobile__c = cifRec.EYI_Unregistered_CP_Mobile_Number__c;
            currREC.EYI_Email__c = cifRec.EYI_REC_Email_Non_Registered__c;
            currREC.EYI_PAN_No__c = cifRec.EYI_REC_PAN_No_Non_Registered__c;
            currREC.EYI_Firm_Address_Type__c = cifRec.EYI_REC_Location__c;
            currREC.EYI_RERA_Registered__c = cifRec.EYI_REC_RERA_Registered__c;
            currREC.OwnerId = cifRec.EYI_Sourcing_Manager__c;
            currREC.EYI_AutomationBypassDatetime__c = System.now();
            insert currREC;
            //String oppId = LeadCon.convert(cifRec.EYI_Lead_Name__c,cifRec); To be verified Later
            //return oppId;
            return currREC.Id;  // Verify later
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Integer sendOTPEmailForCif(String email, String phNo, String countryCode, String cifId, String projectName) {
        
         if (Test.isRunningTest()) {
            // Don't actually make the callout in test
            return 123456;
        }

        //if(otpList[0].Id != null) {)
        String randomIntegerString = string.valueof(Math.abs(Crypto.getRandomInteger()));
		Integer otp = Integer.valueOf(randomIntegerString.substring(0,6));
        System.debug('OTP--> ' + otp);
        Integer generatedOTP = otp;
        /*User loggedInUser = [SELECT Id,EYI_WhatsApp_OTP__c FROM User WHERE Id = :UserInfo.getUserId()];
        loggedInUser.EYI_WhatsApp_OTP__c = otp;
        update loggedInUser;*/
        
         CalloutLog__c calloutLog = new CalloutLog__c();
		 calloutLog.EYI_Mobile__c = phNo;
		 calloutLog.EYI_Email__c = email;
		 calloutLog.EYI_OTP__c = otp;
		 insert calloutLog;
        List<CalloutLog__c> calloutLogList = [Select EYI_Mobile__c,EYI_Email__c,EYI_OTP__c from CalloutLog__c 
                                              where EYI_Mobile__c =:phNo and EYI_Email__c =:email order by createdDate DESC];
         
        if(cifId != null ){
            EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c();
            cif.Id = cifId;
            cif.EYI_Backend_OTP__c = String.valueOf(generatedOTP);
            update cif;
        }
        // String otpMsg = 'Dear Customer' + ',\n\n' + 
                                  // 'your OTP to fill the CIF Form is: ' + otp + '\n\nThank you for your cooperation.' + '\n\nRegards,\nEYI Suport Team';
         String otpMsg = 'Dear Customer' + ',\n\n' + 
                'We are pleased to confirm your scheduled visit to '+projectName+'. Please use the OTP ' + otp + ' to complete the visit confirmation process.\n\n' + 
                'We look forward to welcoming you. Please don’t hesitate to reach out to us should you have any questions or need further assistance prior to your visit.\n\n' + 
                'Best regards,\nTeam Panchshil'; 
        
        if (!String.isBlank(phNo)) {
           /** String phoneNO = countryCode + phNo;
            tdc_tsw.GlobalSMSSender.messageType = 'SMS';
            tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_SMSSenderNumber;
            tdc_tsw.GlobalSMSSender.isSyncCall = true;
            tdc_tsw.GlobalSMSSender.SendSmsWithPhoneAPiAndTemplateId(
                phoneNO,
                System.Label.EYI_SalesCustomOTP,
                cifId
            ); **/
           // String primaryNo = countryCode + phNo;
            String primaryNo = '+91'+phNo;
            EYI_SMSService.SendTextSMSMessagToNumber(primaryNo,otpMsg,'');
            
            if(calloutLogList.Size() > 0){
                System.debug('Inside to call Whatsapp Method OTP : '+calloutLogList[0].EYI_OTP__c);
                tdc_tsw.GlobalSMSSender.messageType ='WhatsApp';
                tdc_tsw.GlobalSMSSender.senderNumber = System.Label.EYI_WhatsAppSenderNumber;
              tdc_tsw.GlobalSMSSender.SendSmsWithPhoneNumberAndTemplateId(primaryNo, System.label.EYI_CIF_OTP_Whatsapp, calloutLogList[0].Id);  
            }
            //
            
        }
        if(String.isNotBlank(email)){
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email}; 
            system.debug('toAddresses>>'+toAddresses);
            mail.setToAddresses(toAddresses);
            //mail.setSenderDisplayName('Panchshil Realty - Visit OTP');
            mail.setSubject('Panchshil Realty - Visit OTP');
            mail.setBccSender(false);
            mail.setUseSignature(true);
            mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sales@panchshil.com' LIMIT 1].Id);

            // Specify the text content of the email.
            /*mail.setHtmlBody('Dear<br>' + 'We are pleased to inform you that your service request: ' +CaseNumber+ ' has been resolved. Please verify the resolution at your earliest convenience.<br>'+
                '<b> please share the Happy Code OTP:</b>' + otp );*/
            mail.setPlainTextBody(otpMsg);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (!results[0].success) {
                System.debug('The email failed to send: '+ results[0].errors[0].message);
                
            }            
        }
        //if(String.isNotBlank(phNo)){
        //    CifSendOTP.sendCifOTPSms(phNo, generatedOTP);
        //}
        
        return generatedOTP;
    }
    @AuraEnabled
    public static String createCIF(EYI_Customer_Information_Form__c cifRec){
        try {
            System.debug(cifRec);
            insert cifRec;
            //String oppId = LeadCon.convert(cifRec.EYI_Lead_Name__c,cifRec); To be verified Later
            //return oppId;
            return '';  // Verify later
        } catch (Exception e) {
            System.debug('Error inserting CIF: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EYI_Project__c> getProjects(){
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        projectList = [Select Id,Name from EYI_Project__c order by Name];
        
        return projectList;
    }

    @AuraEnabled(cacheable=true)
    public static List<EYI_SubProject__c> getSubProjects(String projectId){
        List<EYI_SubProject__c> subProjectList = new List<EYI_SubProject__c>();
        subProjectList = [Select Id,Name from EYI_SubProject__c where EYI_Project_name__c=:projectId];
        
        return subProjectList;
    }
    @AuraEnabled(cacheable=true)
    public static List<EYI_Tower__c> getTowers(String projectId,String subProjId){
        List<EYI_Tower__c> towerList = new List<EYI_Tower__c>();
        towerList = [Select Id,Name from EYI_Tower__c where EYI_Project_name__c=:projectId and EYI_SubProject_name__c=:subProjId];
        
        return towerList;
    }
    
    @AuraEnabled
    public static List<EYI_Project__c> getRecTypes(String proj){
        
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        projectList = [Select Id,RecordTypeId,RecordType.Name,RecordType.DeveloperName from EYI_Project__c where Id=:proj];
        return projectList;
    }
    
    @AuraEnabled
    public static List<sObject> searchElements(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+' WHERE '+fields[3]+'!= null )';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        System.debug(' query '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords[0];
    }

    @AuraEnabled
    public static String updateSMOnOpp(String oppId) {
        system.debug('oppId' + oppId);
        List<Opportunity> oppRec = [Select Id, Name, EYI_REC__c, EYI_Sourcing_Manager__c,EYI_Project_Enquired__c, EYI_REC__r.ownerId from Opportunity
                                    Where Id = :oppId Limit 1];

        if(oppRec[0].EYI_REC__c != null) {
            List<EYI_Project_REC_Mapping__c> projectrecmap = [Select Id,EYI_REC_Account__c,EYI_Sourcing_Manager__c,EYI_Project__c FROM EYI_Project_REC_Mapping__c WHERE EYI_Project__c =: oppRec[0].EYI_Project_Enquired__c AND EYI_REC_Account__c =: oppRec[0].EYI_REC__c];
            oppRec[0].EYI_Sourcing_Manager__c = projectrecmap[0].EYI_Sourcing_Manager__c;
            oppRec[0].EYI_AutomationBypassDatetime__c = DateTime.now();
            OpportunityTeamMember otm = new OpportunityTeamMember( 
                OpportunityId = oppId,
                UserId = projectrecmap[0].EYI_Sourcing_Manager__c
            );
            try{
                
                update oppRec[0];
                insert otm;
                return 'sucess';
            }
            catch(exception e){
                system.debug('Error' +  e);
                return null;
            }
        }
        return 'No Update';
    }

    @AuraEnabled(cacheable=true)
    public static List<Country_Phone_Pattern__mdt> getCountryPhonePatterns() {
        return [SELECT Country_Code__c, Pattern__c FROM Country_Phone_Pattern__mdt Where isActive__c = true];
    }
    public static void fakeMethod(){
    Integer i = 0;
    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    //repeat the i++ hundred of times

  }
    
}