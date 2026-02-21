@RestResource(urlMapping='/CustomerBookingDetailsAPI')
global class EYI_OpportunitySearchResource {

    @HttpPost
global static void searchOpportunities() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');

    try {
        String reqBody = req.requestBody.toString();
        RequestWrapper requestBody = (RequestWrapper) JSON.deserialize(reqBody, RequestWrapper.class);

        if (String.isBlank(requestBody.email) && String.isBlank(requestBody.MobileNumber)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"Email or Mobile Number is required."}');
            return;
        }

        String email = String.isNotBlank(requestBody.email) ? String.escapeSingleQuotes(requestBody.email) : null;
        String mobileNumber = String.isNotBlank(requestBody.MobileNumber) ? String.escapeSingleQuotes(requestBody.MobileNumber) : null;
	    /*List<EYI_Applicants__c> applicantList  =[SELECT Id,Opportunity__c FROM EYI_Applicants__c
                                                 where EYI_Email__c=:email  OR EYI_Mobile_Number__c=:mobileNumber];
        if (applicantList.isEmpty()) {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"message": "No matching customer found"}');
            return;
        }*/
        List<EYI_Applicants__c> applicantList;

        if (email != null && mobileNumber != null) {
            applicantList = [
                SELECT Id, Opportunity__c 
                FROM EYI_Applicants__c 
                WHERE EYI_Email__c = :email OR EYI_Mobile_Number__c = :mobileNumber
            ];
        } else if (email != null) {
            applicantList = [
                SELECT Id, Opportunity__c 
                FROM EYI_Applicants__c 
                WHERE EYI_Email__c = :email
            ];
        } else if (mobileNumber != null) {
            applicantList = [
                SELECT Id, Opportunity__c 
                FROM EYI_Applicants__c 
                WHERE EYI_Mobile_Number__c = :mobileNumber
            ];
        } else {
            applicantList = new List<EYI_Applicants__c>();
        }
        Set<Id> oppIdSet = new Set<Id>();
        if(applicantList.isEmpty()){
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"message": "No matching customer found"}');
            return;
        }
        for(EYI_Applicants__c app : applicantList){
            if(app.Opportunity__c != null){
                oppIdSet.add(app.Opportunity__c);
            }
        }
        if (oppIdSet.isEmpty()) {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"message": "No matching customer found"}');
            return;
        }
        List<String> filters = new List<String>();
        if (email != null && mobileNumber != null) {
           // filters.add("(EYI_Email__c = '" + email + "' AND EYI_Mobile_Number__c = '" + mobileNumber + "')");
            filters.add('(EYI_Email__c = \'' + email + '\' OR EYI_Mobile_Number__c = \'' + mobileNumber + '\')');
        } else if (email != null) {
            filters.add('EYI_Email__c = \'' + email + '\'');
        } else if (mobileNumber != null) {
            filters.add('EYI_Mobile_Number__c = \'' + mobileNumber + '\'');
        }
		
        String whereClause = filters.isEmpty() ? '' : ' WHERE ' + String.join(filters, ' OR ');

        String query = 'SELECT Id,Name,EYI_Agreement_Value__c,EYI_Registration_Scheduled_Date__c,EYI_Inventory__r.EYI_Inventory_Number__c,EYI_Total_SD_Amount_Received__c,EYI_Project_Enquired__c, EYI_First_Name__c, EYI_Last_Name__c, EYI_Email__c, EYI_Mobile_Number__c, AccountId,Account.EYI_Email__c, Account.EYI_Date_Of_Birth__c,Account.EYI_Mobile_Number__c,EYI_Country_Code__c,EYI_Booking_Form_Status__c,EYI_NCF_Status__c,EYI_SAP_Customer_Number__c, ' +
                       'EYI_Registration_Status__c,EYI_Total_Pending_Booking_Amount_in_Per__c, EYI_SD_Status__c, EYI_Signed_Agreement_Status__c, EYI_Franking_status__c, EYI_Total_Outstanding_Incl_All__c, EYI_Collection_Ageing__c, ' +
                       'SyncedQuote.Stamp_Duty__c, SyncedQuote.State_GST__c, SyncedQuote.Central_GST__c, SyncedQuote.EYI_Registration_Charges__c, ' +'EYI_Primary_Closing_Manager__r.Name, EYI_Relationship_Manager__r.Name, EYI_Relationship_Manager__r.Email, EYI_Relationship_Manager__r.phone, ' +
                       '(SELECT Id, EYI_First_Name__c,Verified_AADHAR_Card_DOB__c, EYI_Last_Name__c, EYI_Email__c, EYI_Mobile_Number__c, EYI_Gender__c, EYI_Applicant_Type__c, EYI_Pancard_Number__c, EYI_Aadhar_Number__c, EYI_Permanent_Address__c,EYI_Date_of_Birth__c,EYI_DOB__c,Name FROM Applicants__r), ' +
                       '(Select id,EYI_Usage_Description__c,EYI_Amount_to_be_paid__c,EYI_Billing_Date__c,EYI_Demand_Send_Date__c,EYI_Demand_Status__c,EYI_GST__c,EYI_SAP_Demand_Number__c,EYI_IsOtherChargeDemand__c from Demands__r), '+
                       '(Select id,EYI_Amount__c,CreatedDate,Name,EYI_Non_Bankable_Payment__c,EYI_SAP_Payment_Advice_Number__c,EYI_SAP_Company_Code__c,EYI_SAP_Document_Number__c,EYI_Fiscal_Year__c from Payment_Receipts__r where EYI_Non_Bankable_Payment__c = false and EYI_Payment_Status__c = \'APPROVE\'), '+
                       '(SELECT Id, Name, EYI_SAP_Sales_Order_Number__c,EYI_Opportunity_Name__c,  EYI_Booking_Form_Status__c, EYI_Actual_Booking_Date__c, EYI_Agreement_Value__c, ' +'EYI_Stamp_Duty_Amount_Received__c, EYI_Registration_Date__c, EYI_Unit_Number__c, EYI_Parking_count__c, Carpet_Area__c, ' +
                       'Inventory__r.EYI_Tower__r.Name, Inventory__r.EYI_Floor_Number__c, EYI_Project_Name__r.Name, EYI_SAP_Customer_Number__c,ownerId,EYI_Configuration__c FROM Bookings__r LIMIT 1) ' +
                       'FROM Opportunity WHERE Id IN :oppIdSet';//* + whereClause
                       System.debug('query : '+query);

        List<Opportunity> oppList = Database.query(query);
        System.debug('oppList : '+oppList.size());
        if (oppList.isEmpty()) {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"message": "No matching opportunities found"}');
            return;
        }

        MAP<Id,List<EYI_Payment_Schedule__c>> paymentMileStoneMap = new MAP<Id,List<EYI_Payment_Schedule__c>>();
        List<EYI_Payment_Schedule__c> paymentList = new List<EYI_Payment_Schedule__c>();
        List<EYI_DMS__c> DMSList = new List<EYI_DMS__c>();
        Map<String,String> otherChargeMap = new Map<String, String>();
        Set<Id> OppIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        Date latestSendDate;
        for (Opportunity opp : oppList) {
           OppIds.add(opp.Id);
            if(opp.EYI_Project_Enquired__c != null){
               projectIds.add(opp.EYI_Project_Enquired__c); 
            }    
        }
        if(!OppIds.isEmpty()){
             paymentList = [SELECT Id,EYI_Usage_Description__c,EYI_Actual_Date__c,EYI_Billing_Date__c,Payment_Plan__r.EYI_Quote__r.OpportunityId,EYI_Amount_to_be_paid__c,EYI_GST__c,EYI_Net_Payable__c FROM  EYI_Payment_Schedule__c where Payment_Plan__r.EYI_Quote__r.OpportunityId IN : OppIds];
        }
        
        if(!projectIds.isEmpty()){
        	DMSList = [Select id,EYI_Document_Name__c,EYI_Document_Link__c,EYI_Project__c from EYI_DMS__c  where EYI_Document_Name__c ='Project_Logo' and EYI_Project__c IN: projectIds]; 
            List<Project_Charges__c> projectChargeList = [Select Id, Name, EYI_Project__c From Project_Charges__c Where EYI_Project__c IN : projectIds ];
            for(Project_Charges__c pc : [Select Id, EYI_Project__c, EYI_Global_Charges__r.Name, EYI_Global_Charges__r.EYI_SAP_Material_Name__c from Project_Charges__c Where EYI_Project__c IN : projectIds ] ){
                otherChargeMap.put( pc.EYI_Global_Charges__r.EYI_SAP_Material_Name__c, pc.EYI_Global_Charges__r.Name);
            }
        }
        
        if(!paymentList.isEmpty()){
            for(EYI_Payment_Schedule__c paySch : paymentList){  
                Id oppId = paySch.Payment_Plan__r.EYI_Quote__r.OpportunityId;
                if (!paymentMileStoneMap.containsKey(oppId)) {
                    paymentMileStoneMap.put(oppId, new List<EYI_Payment_Schedule__c>());
                }
                paymentMileStoneMap.get(oppId).add(paySch);
            }
        }
        MAP<id,String> docURLDMSMap = new MAP<id,String>();
        if(!DMSList.isEmpty()){
            for(EYI_DMS__c dmsObj : DMSList){
                docURLDMSMap.put(dmsObj.EYI_Project__c, dmsObj.EYI_Document_Link__c);
            }
        }
        
        
        List<Map<String, Object>> bookingsList = new List<Map<String, Object>>();
        Map<String, Object> customerMap = new Map<String, Object>();
        //List<Map<String, Object>> customers = new List<Map<String, Object>>();

        for (Opportunity oppRec : oppList) {
            if (oppRec.Bookings__r != null) {

                    for (EYI_Booking__c booking : oppRec.Bookings__r) {
                        Map<String, Object> bookingMap = new Map<String, Object>();

                        List<Map<String, Object>> milestonesMap = new List<Map<String, Object>>();
                        List<Map<String, Object>> otherMilestonesMap = new List<Map<String, Object>>();
                        if (oppRec.Demands__r != null) {
                            for (EYI_Demand__c app : oppRec.Demands__r) {
                               Date raiseDate = app.EYI_Demand_Send_Date__c != null ? app.EYI_Demand_Send_Date__c+ 15 : null;
                                if (app.EYI_Demand_Send_Date__c != null) {
                                    if (latestSendDate == null || app.EYI_Demand_Send_Date__c > latestSendDate) {
                                        latestSendDate = app.EYI_Demand_Send_Date__c;
                                    }
                                }
                                Map<String, Object> payMilestoneMap = new Map<String, Object>();
                                Map<String, Object> otherChanrges = new Map<String, Object>();
                                Decimal baseAmt = app.EYI_Amount_to_be_paid__c != null ? app.EYI_Amount_to_be_paid__c : 0;
                                Decimal gstAmt = app.EYI_GST__c != null ? app.EYI_GST__c : 0;
                                if(otherChargeMap.containsKey(app.EYI_Usage_Description__c)){
                                	payMilestoneMap.put('name', otherChargeMap.get(app.EYI_Usage_Description__c) );
                                }else{
                                	payMilestoneMap.put('name',app.EYI_Usage_Description__c );
                                }
                                payMilestoneMap.put('expected_date', app.EYI_Billing_Date__c);
                                payMilestoneMap.put('triggered_date',raiseDate);
                                payMilestoneMap.put('status',(app.EYI_Demand_Status__c != 'Demand Sent') ? 'Open' : 'Triggered');
                                payMilestoneMap.put('base_amount', baseAmt);
                                payMilestoneMap.put('taxable_amount', gstAmt);
                                payMilestoneMap.put('total_amount', baseAmt + gstAmt);
                                payMilestoneMap.put('sap_demand_no', app.EYI_SAP_Demand_Number__c);
                                milestonesMap.add(payMilestoneMap);

                                if(app.EYI_IsOtherChargeDemand__c == 'Yes' ){
                                    otherChanrges.put('name', otherChargeMap.get(app.EYI_Usage_Description__c));
                                    otherChanrges.put('expected_date', app.EYI_Billing_Date__c);
                                    otherChanrges.put('triggered_date', app.EYI_Demand_Send_Date__c);
                                    otherChanrges.put('status',(app.EYI_Demand_Status__c != 'Demand Sent') ? 'Open' : 'Triggered');
                                    otherChanrges.put('base_amount', baseAmt);
                                    otherChanrges.put('taxable_amount', gstAmt);
                                    otherChanrges.put('total_amount', baseAmt + gstAmt);
                                    otherChanrges.put('sap_demand_no', app.EYI_SAP_Demand_Number__c);
                                    otherMilestonesMap.add(otherChanrges);
                                }
                            }
                        }
                        
                        bookingMap.put('milestones', milestonesMap);
                        bookingMap.put('other_charges', otherMilestonesMap);

                        //Payment Receipt
                        List<Map<String, Object>> paymentReceiptMap = new List<Map<String, Object>>();
                        if (oppRec.Payment_Receipts__r != null) {
                            for (EYI_Payment_Receipt__c app : oppRec.Payment_Receipts__r) {
                                Map<String, Object> payRecMap = new Map<String, Object>();
                                payRecMap.put('pr_no', app.Name);
                                payRecMap.put('pr_date', app.CreatedDate);
                                payRecMap.put('pr_amount', app.EYI_Amount__c); 
                                payRecMap.put('sap_payment_advice_no', app.EYI_SAP_Payment_Advice_Number__c);
                                payRecMap.put('company_code', app.EYI_SAP_Company_Code__c);
                                payRecMap.put('sap_document_number', app.EYI_SAP_Document_Number__c);
                                payRecMap.put('fiscal_year', app.EYI_Fiscal_Year__c);
                                paymentReceiptMap.add(payRecMap);
                            }
                        }
                        bookingMap.put('payment_receipt', paymentReceiptMap);
                        //Stage
                        Map<String, Object> stagesMap = new Map<String, Object>();
                        stagesMap.put('booking_details_status','Completed');

                        stagesMap.put('stamp_duty_status', oppRec.EYI_SD_Status__c == 'SD received' ? 'Completed' : 'Open');
                        stagesMap.put('sales_deed_status',oppRec.EYI_Signed_Agreement_Status__c == 'Handed Over' ? 'Completed' : 'Open' );
                        stagesMap.put('franking_status', oppRec.EYI_Franking_status__c == 'Done' ? 'Completed' :'Open');
                        stagesMap.put('registration_status', oppRec.EYI_Registration_Status__c == 'Registration Completed' ?'Completed' :'Open');
                        stagesMap.put('ncf_status', oppRec.EYI_NCF_Status__c == 'Received' ?'Completed' :'Open');

                        bookingMap.put('stages', stagesMap);

                        // other_applicants inside each booking
                        List<Map<String, Object>> otherApplicants = new List<Map<String, Object>>();
                        if (oppRec.Applicants__r != null) {
                            for (EYI_Applicants__c app : oppRec.Applicants__r) {
                                Map<String, Object> appMap = new Map<String, Object>();
                                appMap.put('firstname', app.EYI_First_Name__c);
                                appMap.put('lastname', app.Name);
                                //appMap.put('name', app.Name);
                                appMap.put('applicant_type', app.EYI_Applicant_Type__c);
                                appMap.put('email', app.EYI_Email__c);
                                appMap.put('mobile', app.EYI_Mobile_Number__c);
                                appMap.put('gender', app.EYI_Gender__c);
                                appMap.put('pan', app.EYI_Pancard_Number__c);
                                appMap.put('aadhar', app.EYI_Aadhar_Number__c);
                                appMap.put('address', app.EYI_Permanent_Address__c);
                                appMap.put('date_of_birth', app.Verified_AADHAR_Card_DOB__c);
                                otherApplicants.add(appMap);
                            }
                        }
                        bookingMap.put('other_applicants', otherApplicants);

                        Boolean isPrimary = false;
                    if (oppRec.Applicants__r != null) {
                        for (EYI_Applicants__c app : oppRec.Applicants__r) {
                            System.debug('Opp Name : '+oppRec.Name);
                            System.debug('oppRec.Account.EYI_Email__c : '+oppRec.Account.EYI_Email__c);
                            System.debug('app.EYI_Applicant_Type__c  : '+app.EYI_Applicant_Type__c +' app.EYI_Email__c : '+app.EYI_Email__c);
                            if (app.EYI_Applicant_Type__c == 'Primary Applicant' && app.EYI_Email__c != null && oppRec.EYI_Email__c != null && app.EYI_Email__c.trim().toLowerCase() == oppRec.Account.EYI_Email__c.trim().toLowerCase()) {
                                isPrimary = true;
                                break;
                            }
                        }
                    }
                    System.debug('isPrimary : '+isPrimary);
                    
                        Date payment_due_date = latestSendDate != null ? latestSendDate + 15 : null; 
                       // bookingMap.put('sap_customer_code', booking.EYI_SAP_Customer_Number__c);
                        bookingMap.put('booking_number', booking.Name);
                        bookingMap.put('status', '1'); // static
                        bookingMap.put('ownership', 'owner'); // static
                        bookingMap.put('sales_manager_name', oppRec.EYI_Primary_Closing_Manager__r != null ? oppRec.EYI_Primary_Closing_Manager__r.Name : null);
                        bookingMap.put('rm_name', oppRec.EYI_Relationship_Manager__r != null ? oppRec.EYI_Relationship_Manager__r.Name : null);
                        bookingMap.put('rm_mobile', oppRec.EYI_Relationship_Manager__r != null ? oppRec.EYI_Relationship_Manager__r.phone : null);
                        bookingMap.put('rm_email', oppRec.EYI_Relationship_Manager__r != null ? oppRec.EYI_Relationship_Manager__r.Email : null);
                        bookingMap.put('agreement_value', oppRec.EYI_Agreement_Value__c);
                        bookingMap.put('stamp_duty_amount',(oppRec.SyncedQuote != null ? oppRec.SyncedQuote.Stamp_Duty__c : null));
                        bookingMap.put('stamp_duty_amount_received', booking.EYI_Stamp_Duty_Amount_Received__c != null ? String.valueOf(booking.EYI_Stamp_Duty_Amount_Received__c) : oppRec.EYI_Total_SD_Amount_Received__c != null ? String.valueOf(oppRec.EYI_Total_SD_Amount_Received__c) : null);
                        bookingMap.put('stamp_duty_status', oppRec.EYI_SD_Status__c != null ? oppRec.EYI_SD_Status__c : 'pending');
                        bookingMap.put('registration_amount', (oppRec.SyncedQuote != null ? oppRec.SyncedQuote.EYI_Registration_Charges__c : null) != null ? String.valueOf((oppRec.SyncedQuote != null ? oppRec.SyncedQuote.EYI_Registration_Charges__c : null)) : null);
                        bookingMap.put('registration_status', oppRec.EYI_Registration_Status__c != null ? oppRec.EYI_Registration_Status__c : 'pending');
                        bookingMap.put('booking_date', booking.EYI_Actual_Booking_Date__c != null ? String.valueOf(booking.EYI_Actual_Booking_Date__c) : null);
                        decimal amountDue = 0;
                        if(oppRec.EYI_Total_Pending_Booking_Amount_in_Per__c != null){
                            amountDue = 100 - oppRec.EYI_Total_Pending_Booking_Amount_in_Per__c;
                        }
                        bookingMap.put('amount_due_percentage', amountDue); // static example
                        bookingMap.put('amount_due', oppRec.EYI_Total_Outstanding_Incl_All__c != null ? String.valueOf(oppRec.EYI_Total_Outstanding_Incl_All__c) : null);
                        bookingMap.put('balance_days', oppRec.EYI_Collection_Ageing__c != null ? String.valueOf(oppRec.EYI_Collection_Ageing__c) : null);
                        bookingMap.put('payment_due_date', payment_due_date); // static example
                        bookingMap.put('tower', booking.Inventory__r != null && booking.Inventory__r.EYI_Tower__r != null ? booking.Inventory__r.EYI_Tower__r.Name : null);
                        bookingMap.put('floor', booking.Inventory__r != null ? booking.Inventory__r.EYI_Floor_Number__c : null);
                        bookingMap.put('unit', oppRec.EYI_Inventory__r.EYI_Inventory_Number__c);
                        if(oppRec.EYI_Project_Enquired__c != null){
                         bookingMap.put('project_logo', docURLDMSMap.get(oppRec.EYI_Project_Enquired__c));   
                        }
                        bookingMap.put('project_name', booking.EYI_Project_Name__r != null ? booking.EYI_Project_Name__r.Name : null);
                        bookingMap.put('carpet_area', booking.Carpet_Area__c);
                        bookingMap.put('configuration_type', booking.EYI_Configuration__c);
                        bookingMap.put('no_of_parkings', booking.EYI_Parking_count__c);
                        bookingMap.put('garden_facing', '');
                        bookingMap.put('registration_date', oppRec.EYI_Registration_Scheduled_Date__c != null ? String.valueOf(oppRec.EYI_Registration_Scheduled_Date__c) : '');
                        bookingMap.put('is_primary', isPrimary ? '1' : '0');
                        bookingsList.add(bookingMap);
                    }
                }
        }
        customerMap.put('booking_details', bookingsList);
        Opportunity oppObj = oppList[0];
        Account acc = oppObj.Account;
        
            customerMap.put('gender', '');
            customerMap.put('birth_date', acc.EYI_Date_Of_Birth__c != null ? String.valueOf(acc.EYI_Date_Of_Birth__c) : null);
            customerMap.put('Customer_Sf_Id', acc.Id);
            customerMap.put('sap_cust_no', oppObj.EYI_SAP_Customer_Number__c);
            customerMap.put('firstname', oppObj.EYI_First_Name__c);
            customerMap.put('lastname', oppObj.EYI_Last_Name__c);
            customerMap.put('email', acc.EYI_Email__c);
            customerMap.put('mobile_number', acc.EYI_Mobile_Number__c);
            customerMap.put('country_code', oppObj.EYI_Country_Code__c);
        
        //List<Map<String, String[]>> caseCategories = new List<Map<String, String[]>>();
        List<Map<String, Object>> caseStatus = new List<Map<String, Object>>();
List<String> statuses = new List<String>{
    'New', 'Working', 'Closed', 'Resolved', 'Reopen', 'In Progress', 'On Hold', 
    'Waiting for Customer', 'Escalated', 'Merged', 'Response Received'
};

Map<String, Object> statusMap = new Map<String, Object>();
//statusMap.put('statuses', statuses);
caseStatus.add(statusMap);
        
         //List<Map<String, Object>> caseType = new List<Map<String, Object>>();
/*List<String> caseType = new List<String>{
    'Feature Request','Problem','Question',
'Pre Possession','Post Possession','Cancellation'};*/


        List<Map<String, Object>> caseCategories = new List<Map<String, Object>>();
        Map<String, Object> customer = new Map<String, Object>();
        //Map<String, String[]> complaintCategory = new Map<String, String[]>();
       /* Map<String, Object> complaintCategory = new Map<String, Object>();
        //complaintCategory.put('categoryName', new String[] { 'Complaint' });
        complaintCategory.put('subCategories', new List<String> {
            'Client experience',
            'Commission Delay',
            'Commission Dispute',
            'Delay In Possession',
            'Delay In REC Empanelment',
            'Delay In Registration',
            'Lead Clash',
            'Marketing Support',
            'Over-promising',
            'Post Sales - Response/Complaint',
            'Slow response time',
            'SM Integrity',
            'Others'
        });
        complaintCategory.put('categoryName', 'Complaint');
        caseCategories.add(complaintCategory);

       // Map<String, String[]> requestCategory = new Map<String, String[]>();
        Map<String, Object> requestCategory = new Map<String, Object>();
        requestCategory.put('subCategories',new List<String> {
            'Branding at office',
            'Brokerage information',
            'Client Event',
            'Client pick-up request',
            'Declaration of account change',
            'Lead Generation Support',
            'Marketing Support',
            'New Registration /Empanelment',
            'Personal information Update',
            'Project information',
            'Others'
        });
        requestCategory.put('categoryName','Request');
        caseCategories.add(requestCategory);*/

        //Map<String, String[]> qyeriesPrePossession = new Map<String, String[]>();
        Map<String, Object> ncfCorrection = new Map<String, Object>();
        ncfCorrection.put('subCategories', new List<String> {'Full Name','Age','Occupation','Current Address'
        });
        ncfCorrection.put('categoryName', 'NCF Correction');
        ncfCorrection.put('type', 'Pre Possession');
        caseCategories.add(ncfCorrection);
        Map<String, Object> ncfChange = new Map<String, Object>();
        ncfChange.put('subCategories', new List<String> {'Occupation','Current Address','Add/Update Applicant','Change in Applicant Sequence','Remove Applicant'});
        ncfChange.put('categoryName', 'NCF Change');
        ncfChange.put('type', 'Pre Possession');
        caseCategories.add(ncfChange);
        //
        Map<String, Object> qyeriesPrePossession = new Map<String, Object>();
        qyeriesPrePossession.put('subCategories', new List<String> { 'Amenities Details', 'Apartment Specification', 'Documentation Queries', 'General Queries','Handover Process & Formalities','Legal Queries','Payment Queries','Status of the Unit'});
        qyeriesPrePossession.put('categoryName', 'Queries Pre Possession');
        qyeriesPrePossession.put('type', 'Pre Possession');
        caseCategories.add(qyeriesPrePossession);

        // Map<String, String[]> requestPrePossession = new Map<String, String[]>();
         Map<String, Object> requestPrePossession = new Map<String, Object>();
		requestPrePossession.put('subCategories', new List<String>{'Add Secondary Applicant','Apartment Visit - Inspection Request','Applicant Address Update','Applicant Email Update','Applicant Mobile Number Update','Applicant Name Update','Applicants Swap','Change Floor/Unit no','Change of Ownership( Resale before possession)','Customization','Customization or Modification Requests','Document request','Floor Plan','General Request','Payment Schedule','Special Request','Update KYC'});

        requestPrePossession.put('categoryName', 'Request Pre Possession');
        requestPrePossession.put('type', 'Pre Possession');
        caseCategories.add(requestPrePossession);

         //Map<String, String[]> complaintsPrePossession = new Map<String, String[]>();
         Map<String, Object> complaintsPrePossession = new Map<String, Object>();
		complaintsPrePossession.put('subCategories', new List<String>{'Delay in possession','Delay in Receiving Documents','False Commitment','Payment and Financial Issues','Project Related','Unclear Communication'});

        complaintsPrePossession.put('categoryName', 'Complaints Pre Possession');
        complaintsPrePossession.put('type', 'Pre Possession');
         caseCategories.add(complaintsPrePossession);
         //Map<String, String[]> communicationPrePossession = new Map<String, String[]>();
         Map<String, Object> communicationPrePossession = new Map<String, Object>();
		communicationPrePossession.put('subCategories', new List<String>{'Clarification on Agreement Terms','Customer Support and Assistance','Escalation process','Feedback and Suggestions','General Inquiries and Information','Panchshil App Login','Point of Contact','Status Updates and Progress Communication','Utility Connections and Setup Requests'});

        communicationPrePossession.put('categoryName', 'Communication Pre Possession');
        communicationPrePossession.put('type', 'Pre Possession');
        caseCategories.add(communicationPrePossession);
         //Map<String, String[]> queriesPostPossession = new Map<String, String[]>();
         Map<String, Object> queriesPostPossession = new Map<String, Object>();
		queriesPostPossession.put('subCategories', new List<String>{'Building Infrastructure Queries','Conveyance & Handover','Escalation Matrix','Fitout Guidelines','FM My Gate App','Maintenance and Support','Security and Safety','Society Formation','Utilities and Connections'});

        queriesPostPossession.put('categoryName', 'Queries Post Possession');
        queriesPostPossession.put('type', 'Post possession');
        caseCategories.add(queriesPostPossession);
        //Map<String, String[]> requestsPostPossession  = new Map<String, String[]>();
        Map<String, Object> requestsPostPossession = new Map<String, Object>();
		requestsPostPossession.put('subCategories', new List<String>{'Change of Ownership( Resale before possession)','Customization','Document request','Maintenance and Repairs Requests','Project Team Visit','Special Request','Update KYC','Utilities and Services Requests'});

        requestsPostPossession.put('categoryName', 'Requests Post Possession');
        requestsPostPossession.put('type', 'Post possession');
        caseCategories.add(requestsPostPossession);
        //Map<String, String[]> complaintsPostPossession  = new Map<String, String[]>();
        Map<String, Object> complaintsPostPossession = new Map<String, Object>(); 
        complaintsPostPossession.put('subCategories', new List<String>{'Amenities Usage and Issues','Automation','Building Infrastructure Complaints','Construction or Quality Complaints','Customer Service and Support Complaints','Delays in Communication','Delays in Documentation','General Complaints','Handover Related','Payments and Billing Complaints','Project Legal/Compliance Issues','Security and Safety Complaints','Utilities and Services Complaints','Utility and Service Complaints','Warranty & Defects'});
        complaintsPostPossession.put('categoryName', 'Complaints Post Possession');
        complaintsPostPossession.put('type', 'Post possession');
        caseCategories.add(complaintsPostPossession);
        //Map<String, String[]> communicationPostPossession   = new Map<String, String[]>();
        Map<String, Object> communicationPostPossession = new Map<String, Object>();
        
        communicationPostPossession.put('subCategories', new List<String>{'Community and Association Communication','Customer Support and Assistance','Feedback and Suggestions','General Inquiries and Information','Maintenance and Repairs Communication','Ownership and Documentation','Point of Contact','Update on Follow up','Utilities and Services Communication','Utility Connections and Setup Requests'});
        communicationPostPossession.put('categoryName', 'Communication Post Possession');
        communicationPostPossession.put('type', 'Post possession');
        caseCategories.add(communicationPostPossession);
        // ✅ Add this after all customer nodes (applicants, booking, etc.) have been added
        //customer.put('case_category', caseCategories);
        //customers.add(customer);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('case_category', caseCategories);
        responseMap.put('case_status', statuses);
        //responseMap.put('case_type', caseType);
        responseMap.put('Customers', customerMap);
        
        //Map<String, Object> finalResponse = new Map<String, Object>();
       // finalResponse.put('customers', customers);

        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serializePretty(responseMap));

    } catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        res.statusCode = 500;
        res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '", "line": "' + e.getLineNumber() + '"}');
    }
}

    
    // Request Wrapper
    public class RequestWrapper {
        public String email;
        public String MobileNumber;
        public String flat_details;
        public String booking_details;
        public String other_applicants;
        public String transactional_financials;
        public String transactional_milestones;
        public String transactional_receipts;
    }
    
    // Response Wrapper
    global class ResponseWrapper {
        public String ProjectName;
        public String TowerName;
        public AddressWrapper ProjectAddress;
        public String UnitNumber;
        public String RelatnManagerName;
        public String RelatnManagerNumber;
        
        
        public ResponseWrapper(String project, String tower, AddressWrapper address, String unit, String relatnManagerName, String phone) {
            this.ProjectName = project;
            this.TowerName = tower;
            this.ProjectAddress = address;
            this.UnitNumber = unit;
            this.RelatnManagerName = relatnManagerName;
            this.RelatnManagerNumber = phone;
        }
    }
    
    // Address Wrapper
    public class AddressWrapper {
        public String street;
        public String city;
        // public String state;
        public String postalCode;
        // public String country;
        
        public AddressWrapper(String street, String city, String postalCode) {
            this.street = street;
            this.city = city;
            //  this.state = state;
            this.postalCode = postalCode;
            //this.country = country;
        }
    }
    
    // Custom Exception
    public class CustomException extends Exception {}
}