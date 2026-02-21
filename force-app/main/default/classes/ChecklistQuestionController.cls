public class ChecklistQuestionController {
   
    @AuraEnabled
    public static Opportunity getOppRecord(Id recordId){
        Opportunity oppRec = [Select Id,StageName,EYI_Franking_status__c, Name,EYI_Post_Registration_Checklist_Checker__c,EYI_IsPostCancellationChecklistSubmitted__c,EYI_IsPreCancellationChecklistSubmitted__c,EYI_Pre_Registration_Checklist_Checker__c,EYI_Registration_Checklist_Checker__r.Name,EYI_Welcome_Call_Checklist_Checker__r.Name,EYI_Sales_Checklist_Checker__r.Name,Booking_Checklist_Checker__r.Name,
        IsWelcomeCallChecklistSubmitted__c,IsRegistrationChecklistSubmitted__c,IsBookingChecklistSubmitted__c,EYI_Booking_Form_Status__c,EYI_Invoice_Checklist_Status__c,IsSalesChecklistSubmitted__c,EYI_Sales_Checklist_Status__c,EYI_Primary_Closing_Manager__r.Name, 
        EYI_Primary_Closing_Manager__c,EYI_Inventory__r.Name,EYI_Segment__c,EYI_Possession_Letter_Generated__c,EYI_Inventory__r.EYI_Typology__c,EYI_IsCHIFSubmitted__c,EYI_CHIF_OTP__c,EYI_Opportunity_Number__c,EYI_Project_Tower_Enquired__c,EYI_Project_Tower_Enquired__r.Name,
        EYI_Project_Enquired__r.Name,EYI_Project_Enquired__c,EYI_Is_InvoiceChecklist_Submitted__c,EYI_Is_Post_Register_with_Loan_Checklist__c,EYI_Registration_Status__c,
        EYI_Admin_Checklist_Status__c,EYI_Is_Admin_Checklist_Submitted__c,EYI_Invoice_Checklist_Checker__r.Name from Opportunity Where Id=:recordId];
        return oppRec;
    }
   
    @AuraEnabled
    public static List<Checklist_Item__c> getChecklistItemsByRecordId(Id recordId) {
        // Fetch the checklist items related to the given recordId
        List<Checklist_Item__c> checklistItems = [SELECT Id, Opportunity__c,EYI_Area__c, Question__c,EYI_Sequence_No__c, Status__c, Remarks__c, Category__c, Type__c,CreatedBy.Name,EYI_Status__c,Valid__c,Invalid__c
                                                  FROM Checklist_Item__c
                                                  WHERE Opportunity__c = :recordId Order by EYI_Sequence_No__c ASC];
        return checklistItems;
    }
   
    @AuraEnabled
    Public static Opportunity getOpportunityDetails(Id recordId){
        return [Select Id,EYI_Booking_Form_Status__c,EYI_IsPostCancellationChecklistSubmitted__c,EYI_Invoice_Checklist_Status__c,EYI_Segment__c,EYI_Possession_Letter_Generated__c,EYI_CHIF_OTP__c,EYI_Reason_for_Booking_Form_Rejection__c,EYI_Sales_Checklist_Status__c from Opportunity Where Id=:recordId ];
    }
    public class ProjectDetails {
    @AuraEnabled public String oppName;
    @AuraEnabled public String closingCM;
    @AuraEnabled public String closingTL;
    @AuraEnabled public String closingCRM;
    @AuraEnabled public String unitNo;
    @AuraEnabled public Date createdDate;
    @AuraEnabled public String sourceOfBooking;
   // @AuraEnabled public Date registrationDate;
    @AuraEnabled public String sourcingSM;
    @AuraEnabled public String projectName;
    @AuraEnabled public String rec;
    @AuraEnabled public String recName;
    @AuraEnabled public String recCode;    
    @AuraEnabled public String paymentTerm;
    @AuraEnabled public String modeOfPayment;
    @AuraEnabled public Decimal paymentAmount;
}
 
@AuraEnabled(cacheable=true)
public static ProjectDetails getBookingDetails(Id recordId) {
    System.debug('getBookingDetails : '+recordId);
    // Initialize the wrapper class
    ProjectDetails projectDetailRec = new ProjectDetails();
   
    // Query the relevant fields from the EYI_Booking__c object
    EYI_Booking__c bookingRec = [SELECT
        EYI_Unit_No__c,
        CreatedDate,
        EYI_Source_of_Booking__c,
        EYI_Opportunity_Name__r.Name,
        //EYI_Opportunity_Name__r.Registration_Date__c,
        EYI_Opportunity_Name__r.EYI_Sourcing_Manager__r.Name,
        EYI_Opportunity_Name__r.EYI_Primary_Closing_Manager__r.Name,
        EYI_Opportunity_Name__r.Closing_TL__r.Name,
        EYI_Opportunity_Name__r.Closing_Head__r.Name,
        EYI_Opportunity_Name__r.EYI_REC__c,
        EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Firm_Name__c,
        EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Code__c,
        EYI_Opportunity_Name__r.EYI_Payment_Terms__c,
        EYI_Project_Name__r.Name,
        EYI_Opportunity_Name__r.EYI_Inventory__r.EYI_Inventory_Number__c
                                 
    FROM EYI_Booking__c
    WHERE EYI_Opportunity_Name__c = :recordId
    LIMIT 1];
   
    List<EYI_Payment_Receipt__c> paymentReceipt = [Select Id, EYI_Mode_of_Payment__c,EYI_Amount__c from EYI_Payment_Receipt__c Where EYI_Opportunity__c=:recordId AND EYI_Token_Amount__c = true];
   
    // Assign values to the wrapper class from the query result
    projectDetailRec.oppName = bookingRec.EYI_Opportunity_Name__r.Name;
    projectDetailRec.closingCM = bookingRec.EYI_Opportunity_Name__r.EYI_Primary_Closing_Manager__r.Name;
    projectDetailRec.closingTL = bookingRec.EYI_Opportunity_Name__r.Closing_TL__r.Name;
    projectDetailRec.closingCRM = bookingRec.EYI_Opportunity_Name__r.Closing_Head__r.Name;
    projectDetailRec.unitNo = bookingRec.EYI_Opportunity_Name__r.EYI_Inventory__r.EYI_Inventory_Number__c;
    projectDetailRec.createdDate = bookingRec.CreatedDate.date();
    projectDetailRec.sourceOfBooking = bookingRec.EYI_Source_of_Booking__c;
   // projectDetailRec.registrationDate = bookingRec.EYI_Opportunity_Name__r.Registration_Date__c;
    projectDetailRec.sourcingSM = bookingRec.EYI_Opportunity_Name__r.EYI_Sourcing_Manager__r.Name;
    projectDetailRec.projectName = bookingRec.EYI_Project_Name__r.Name;
    projectDetailRec.rec = bookingRec.EYI_Opportunity_Name__r.EYI_REC__c;
    projectDetailRec.recName = bookingRec.EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Firm_Name__c;
    projectDetailRec.recCode = bookingRec.EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Code__c;
    projectDetailRec.paymentTerm = bookingRec.EYI_Opportunity_Name__r.EYI_Payment_Terms__c;
    if(paymentReceipt.size() > 0){
        projectDetailRec.modeOfPayment= paymentReceipt[0].EYI_Mode_of_Payment__c;
        projectDetailRec.paymentAmount= paymentReceipt[0].EYI_Amount__c;
    }else{
        projectDetailRec.modeOfPayment = null;
        projectDetailRec.paymentAmount = null;
    }
   
    // Return the populated wrapper class
    return projectDetailRec;
}
 
   
    @AuraEnabled
    public static List<Checklist_Question__mdt> getQuestions() {
        return [SELECT Id,Question__c,Type__c,Category__c,Area__c,IsActive__c,Sequence_No__c FROM Checklist_Question__mdt
                WHERE IsActive__c = TRUE order by Sequence_No__c ASC];
    }

     @AuraEnabled
    public static void submitChecklistCancellationItems(Id recordId,Boolean isSubmit, String checkListLabel){
        
        System.debug('=== submitChecklistCancellationItems Debug ===');
        System.debug('recordId: ' + recordId);
        System.debug('isSubmit: ' + isSubmit);
        System.debug('checkListLabel: ' + checkListLabel);
        
        Opportunity oppRec = [Select Id,StageName,EYI_Registration_Checklist_Checker__c,EYI_IsPostCancellationChecklistSubmitted__c,EYI_Pre_Registration_Checklist_Checker__c,EYI_IsPreCancellationChecklistSubmitted__c,EYI_Welcome_Call_Checklist_Checker__c,EYI_Sales_Checklist_Checker__c,IsWelcomeCallChecklistSubmitted__c,IsRegistrationChecklistSubmitted__c,IsBookingChecklistSubmitted__c from Opportunity Where Id=: recordId];
        String canRecTypeId = System.Label.EYI_Case_Cancellation_Record_Type_Id;
        List<Case> getCaseRec = [Select id, EYI_Prior_Opportunity_Stage__c,EYI_Stages__c from Case where EYI_Opportunity__c =:recordId AND Status='Closed' AND RecordTypeId =:canRecTypeId ];
            
        System.debug('Current Opportunity Stage: ' + oppRec.StageName);
        System.debug('Case Records Found: ' + getCaseRec.size());
        
        if(checkListLabel == 'Pre Cancellation'){
            System.debug('Processing Pre Cancellation if block');
            //oppRec.StageName = 'Cancellation Requested'; 
            oppRec.EYI_AutomationBypassDatetime__c = System.now();
            oppRec.EYI_Pre_Registration_Checklist_Checker__c = UserInfo.getUserId();
            oppRec.EYI_IsPreCancellationChecklistSubmitted__c = true;
            System.debug('oppRec Pre Cancellation after if block: '+oppRec);
        }
        else if(checkListLabel == 'Post Cancellation'){
            System.debug('Processing Post Cancellation else if');
            
            if(getCaseRec.size() <= 0){
                throw new AuraHandledException('There will be no proper approval taken for it');
            }
            else{
                if(getCaseRec[0].EYI_Stages__c == 'Cancellation Approved'){
                    //oppRec.StageName = 'Cancelled';
                    oppRec.EYI_AutomationBypassDatetime__c = System.now();
                    oppRec.EYI_IsPostCancellationChecklistSubmitted__c = true;
                    oppRec.EYI_Post_Registration_Checklist_Checker__c = UserInfo.getUserId();
                    System.debug('oppRec Post Cancellation: '+oppRec);
                }
                else if(getCaseRec[0].EYI_Stages__c == 'Retention Approved'){
                    oppRec.StageName = getCaseRec[0].EYI_Prior_Opportunity_Stage__c;
                    oppRec.EYI_IsPostCancellationChecklistSubmitted__c = true;
                    oppRec.EYI_Post_Registration_Checklist_Checker__c = UserInfo.getUserId();
                    oppRec.EYI_AutomationBypassDatetime__c = System.now();
                    System.debug('oppRec Post Cancellation Retention Approved: '+oppRec);
                }
            }
        }
        
        System.debug('About to update opportunity with stage: ' + oppRec.StageName);
        System.debug('IsRegistrationChecklistSubmitted__c will be set to: ' + oppRec.IsRegistrationChecklistSubmitted__c);
        
        try{
            update oppRec;  
            System.debug('Opportunity updated successfully');
        }catch(Exception e){
            System.debug('Error updating opportunity: ' + e.getMessage());
            throw new AuraHandledException('Error updating opportunity: ' + e.getMessage());
        }
    }
    /* Created by: Mrinal Tripathi (EYIN)
        Purpose: Function to submit invoice/brokerage checklist by CRM admin
    */
    @AuraEnabled
    public static void submitChecklistInvoiceItems(Id recordId,Boolean isSubmit, String checkListLabel, String invoiceStatus){
    
    Opportunity oppRec = [Select Id,EYI_Registration_Checklist_Checker__c,EYI_Invoice_Checklist_Status__c,EYI_Welcome_Call_Checklist_Checker__c,EYI_Sales_Checklist_Checker__c,IsWelcomeCallChecklistSubmitted__c,IsRegistrationChecklistSubmitted__c,IsBookingChecklistSubmitted__c,EYI_Is_InvoiceChecklist_Submitted__c from Opportunity Where Id=: recordId];
    
    if(checkListLabel == 'Invoice'){
        oppRec.EYI_AutomationBypassDatetime__c = System.now();
        // Update the invoice status field with the passed value
        if(String.isNotBlank(invoiceStatus)){
            oppRec.EYI_Invoice_Checklist_Status__c = invoiceStatus;
        }
        
        // Set submission checkbox to true when submitting
        if(isSubmit) {
            oppRec.EYI_Is_InvoiceChecklist_Submitted__c = true;
        }
    }
    
    try{
        update oppRec;  
    }catch(Exception e){
        throw new AuraHandledException('Error updating opportunity: ' + e.getMessage());
    }
}


@AuraEnabled
public static void submitChecklistAdminItems(Id recordId, Boolean isSubmit, String checkListLabel, String adminChecklistStatus){
    
    System.debug('=== submitChecklistAdminItems Debug ===');
    System.debug('recordId: ' + recordId);
    System.debug('isSubmit: ' + isSubmit);
    System.debug('checkListLabel: ' + checkListLabel);
    System.debug('adminChecklistStatus: ' + adminChecklistStatus);
    
    Opportunity oppRec = [Select Id, EYI_Admin_Checklist_Status__c, EYI_Is_Admin_Checklist_Submitted__c 
                         FROM Opportunity WHERE Id = :recordId LIMIT 1];
    
    System.debug('Current EYI_Admin_Checklist_Status__c value: ' + oppRec.EYI_Admin_Checklist_Status__c);
    System.debug('Current EYI_Is_Admin_Checklist_Submitted__c value: ' + oppRec.EYI_Is_Admin_Checklist_Submitted__c);
    
    if(checkListLabel == 'Admin Checklist'){
        oppRec.EYI_AutomationBypassDatetime__c = System.now();
        
        // Update the Admin Checklist status field with the passed value
        if(String.isNotBlank(adminChecklistStatus)){
            oppRec.EYI_Admin_Checklist_Status__c = adminChecklistStatus;
            System.debug('Setting EYI_Admin_Checklist_Status__c to: ' + adminChecklistStatus);
        }
        
        // Set submission checkbox to true when submitting
        if(isSubmit) {
            oppRec.EYI_Is_Admin_Checklist_Submitted__c = true;
            System.debug('Setting EYI_Is_Admin_Checklist_Submitted__c to true');
        }
    }
    
    System.debug('About to update opportunity with Admin Checklist fields');
    
    try{
        update oppRec;
        System.debug('Opportunity updated successfully with Admin Checklist data');
    }catch(Exception e){
        System.debug('Error updating opportunity: ' + e.getMessage());
        throw new AuraHandledException('Error updating opportunity: ' + e.getMessage());
    }
}

// Add a new method specifically for saving invoice status
@AuraEnabled
public static void saveInvoiceStatus(String recordId, String invoiceStatus, String checklistName) {
    try {
        if(checklistName == 'Invoice'){
            Opportunity oppRec = [SELECT Id, EYI_Invoice_Checklist_Status__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if(String.isNotBlank(invoiceStatus)){
                oppRec.EYI_Invoice_Checklist_Status__c = invoiceStatus;
            }
            update oppRec;
        }
        else if(checklistName == 'Admin Checklist'){
            Opportunity oppRec = [SELECT Id, EYI_Admin_Checklist_Status__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if(String.isNotBlank(invoiceStatus)){
                oppRec.EYI_Admin_Checklist_Status__c = invoiceStatus;
            }
            update oppRec;
        }
    } catch (Exception e) {
        throw new AuraHandledException('Error while saving the status: ' + e.getMessage());
    }
}

// Update the existing saveInvoiceSubmissionStatus method to handle Admin Checklist
@AuraEnabled
public static void saveInvoiceSubmissionStatus(String recordId, Boolean isSubmitted) {
    try {
        // Query for both fields to handle either checklist type
        Opportunity oppRec = [SELECT Id, EYI_Is_InvoiceChecklist_Submitted__c, EYI_Is_Admin_Checklist_Submitted__c 
                             FROM Opportunity WHERE Id = :recordId LIMIT 1];
        
        // For now, we'll update the Admin Checklist submission status
        // You might need to add a parameter to distinguish between Invoice and Admin Checklist
        oppRec.EYI_Is_Admin_Checklist_Submitted__c = isSubmitted;
        update oppRec;
    } catch (Exception e) {
        throw new AuraHandledException('Error while saving the submission status: ' + e.getMessage());
    }
}
    
    @AuraEnabled
    public static void saveChecklistItemsCancellation(List<Checklist_Item__c> checklistItems,Id recordId, Boolean isSubmit, String checklistName) {
        System.debug('checklistItems : '+checklistItems);
        Map<String, Checklist_Item__c> existingItemsMap = new Map<String, Checklist_Item__c>();
        List<Opportunity> oppRec = [Select Id,StageName from Opportunity where Id=:recordId LIMIT 1];
        System.debug('oppRec : '+oppRec);
        Set<String> questionNames = new Set<String>();
        for (Checklist_Item__c item : checklistItems) {
            questionNames.add(item.Question__c);
        }
        System.debug('questionNames : '+questionNames);
        
        for (Checklist_Item__c item : [SELECT Id,Status__c, Question__c, Remarks__c,Category__c,Valid__c,Invalid__c FROM Checklist_Item__c WHERE Opportunity__c=:recordId AND Question__c IN :questionNames]) {
            existingItemsMap.put(item.Question__c, item);
        }
        System.debug('existingItemsMap : '+existingItemsMap);
        List<Checklist_Item__c> itemsToInsert = new List<Checklist_Item__c>();
        List<Checklist_Item__c> itemsToUpdate = new List<Checklist_Item__c>();
        
        for (Checklist_Item__c newItem : checklistItems) {
            if (existingItemsMap.containsKey(newItem.Question__c)) {
                System.debug('newItem.Question__c : '+newItem.Question__c);
                Checklist_Item__c existingItem = existingItemsMap.get(newItem.Question__c);
                
                // Update all fields including Valid__c
                if (existingItem.Remarks__c != newItem.Remarks__c){
                  existingItem.Remarks__c = newItem.Remarks__c;  
                }
                if(existingItem.Category__c != newItem.Category__c){
                   existingItem.Category__c = newItem.Category__c; 
                }
                if(existingItem.Status__c != newItem.Status__c){
                    existingItem.Status__c = newItem.Status__c;
                }
                // Add Valid__c field update - this was missing!
                if(existingItem.Valid__c != newItem.Valid__c){
                    existingItem.Valid__c = newItem.Valid__c;
                }
                // Add Invalid__c field update if needed
                if(existingItem.Invalid__c != newItem.Invalid__c){
                    existingItem.Invalid__c = newItem.Invalid__c;
                }
                
                System.debug('existingItem : '+existingItem); 
              itemsToUpdate.add(existingItem);
         	}
             else {
                itemsToInsert.add(newItem);
            }
        }
        if (!itemsToInsert.isEmpty()) {
            insert itemsToInsert;
        }
        if (!itemsToUpdate.isEmpty()) {
            update itemsToUpdate;
        }
       
        
    }
   
    @AuraEnabled
    public static void submitChecklistItems(Id recordId,Boolean isSubmit, String checkListLabel){
   
    System.debug('=== submitChecklistItems Debug ===');
    System.debug('recordId: ' + recordId);
    System.debug('isSubmit: ' + isSubmit);
    System.debug('checkListLabel: ' + checkListLabel);
    
    Opportunity oppRec = [Select Id,EYI_Registration_Checklist_Checker__c,IsSalesChecklistSubmitted__c,EYI_Welcome_Call_Checklist_Checker__c,Booking_Checklist_Checker__c,EYI_Sales_Checklist_Checker__c,IsWelcomeCallChecklistSubmitted__c,IsRegistrationChecklistSubmitted__c,IsBookingChecklistSubmitted__c,EYI_Is_Post_Register_with_Loan_Checklist__c from Opportunity Where Id=: recordId];
    
    System.debug('Current EYI_Is_Post_Register_with_Loan_Checklist__c value: ' + oppRec.EYI_Is_Post_Register_with_Loan_Checklist__c);
    
    if(checkListLabel == 'Welcome Call Checklist'){
       oppRec.IsWelcomeCallChecklistSubmitted__c = true;
       oppRec.EYI_Welcome_Call_Checklist_Checker__c = UserInfo.getUserId();
    }
    if(checkListLabel == 'Registration Checklist'){
        oppRec.IsRegistrationChecklistSubmitted__c =true;
        oppRec.EYI_Registration_Checklist_Checker__c =UserInfo.getUserId();
    }
    if(checkListLabel == 'Booking Checklist'){
        oppRec.IsBookingChecklistSubmitted__c =true;
        oppRec.Booking_Checklist_Checker__c =UserInfo.getUserId();
    }
    if(checkListLabel == 'Sales Checklist'){
        oppRec.IsSalesChecklistSubmitted__c =true;
        oppRec.EYI_Sales_Checklist_Checker__c =UserInfo.getUserId();
    }
    
    if(checkListLabel == 'Post Registration with Loan'){
        System.debug('Setting EYI_Is_Post_Register_with_Loan_Checklist__c to true');
        oppRec.EYI_Is_Post_Register_with_Loan_Checklist__c = true;
        oppRec.EYI_Post_Registration_Checklist_Checker__c =UserInfo.getUserId();
    }
    
    if(checkListLabel == 'Invoice'){
        oppRec.EYI_Is_InvoiceChecklist_Submitted__c =true;
        oppRec.EYI_Invoice_Checklist_Checker__c =UserInfo.getUserId();
    }
    
    
    System.debug('About to update opportunity with EYI_Is_Post_Register_with_Loan_Checklist__c: ' + oppRec.EYI_Is_Post_Register_with_Loan_Checklist__c);
    
    try{
      update oppRec;  
      System.debug('Opportunity updated successfully');
      
      if(checkListLabel == 'Registration Checklist'){
        callApprovalProcess(recordId,checkListLabel);
      }
     
    }catch(Exception e){
       System.debug('Error updating opportunity: ' + e.getMessage());
       throw new AuraHandledException('Error updating opportunity: ' + e.getMessage());
    }
   
}
   
   
    @AuraEnabled
    public static void saveChecklistItems(List<Checklist_Item__c> checklistItems, String recordId, String bookingFormStatus, String bookingFormRejection, Boolean isSubmit, String checklistName) {
    try {
        System.debug('checklistItems : '+checklistItems);
        Map<String, Checklist_Item__c> existingItemsMap = new Map<String, Checklist_Item__c>();
        Opportunity oppRec = [Select Id,StageName,EYI_Booking_Form_Status__c,IsWelcomeCallChecklistSubmitted__c,IsRegistrationChecklistSubmitted__c,EYI_Reason_for_Booking_Form_Rejection__c,IsBookingChecklistSubmitted__c
            ,EYI_Registration_Checklist_Checker__c,EYI_Welcome_Call_Checklist_Checker__c,EYI_Sales_Checklist_Checker__c,EYI_Sales_Checklist_Status__c,IsSalesChecklistSubmitted__c,EYI_Is_Post_Register_with_Loan_Checklist__c from Opportunity where Id=:recordId];
        System.debug('oppRec : '+oppRec);
        
        if(bookingFormStatus != ''){
            if(checklistName== 'Booking Checklist'){
                if(bookingFormStatus =='Booking Form Rejected' && bookingFormRejection != ''){
                    oppRec.EYI_Booking_Form_Status__c ='Booking Form Rejected';
                    oppRec.EYI_Reason_for_Booking_Form_Rejection__c = bookingFormRejection;
                }else if(bookingFormStatus =='Accept With Non-Critical Discrepancy' || bookingFormStatus =='Booking Form Accepted'){
                    oppRec.EYI_Booking_Form_Status__c = 'Booking Form Accepted';
                    oppRec.EYI_Reason_for_Booking_Form_Rejection__c ='';
                    if(isSubmit == true){
                    oppRec.StageName = 'Booking Form Submitted';  
                    }
                } else{
                    oppRec.EYI_Booking_Form_Status__c = bookingFormStatus;
                }   
            }  
            if(checklistName== 'Sales Checklist'){
                oppRec.EYI_Sales_Checklist_Status__c = bookingFormStatus;
            }
            try{
               update oppRec;
            }catch(Exception ex){
               System.debug('Exception type caught: ' + ex.getTypeName());    
            }
        }
       
        if(isSubmit == true && checklistName== 'Welcome Call Checklist' ){
            oppRec.IsWelcomeCallChecklistSubmitted__c = true;
            oppRec.StageName = 'Welcome Call Submitted';
            oppRec.EYI_Welcome_Call_Checklist_Checker__c = UserInfo.getUserId();
        }
        if(isSubmit == true && checklistName== 'Registration Checklist' ){
            oppRec.IsRegistrationChecklistSubmitted__c = true;
            //oppRec.StageName = 'Registration Completed';
            oppRec.EYI_Registration_Checklist_Checker__c =UserInfo.getUserId();
        }
        if(isSubmit == true && checklistName== 'Booking Checklist'){
            if(bookingFormStatus == 'Discrepancy Resolved'){
                  oppRec.IsBookingChecklistSubmitted__c = false;  
            }else{
                oppRec.IsBookingChecklistSubmitted__c = true;
                if(bookingFormStatus == 'Accept With Non-Critical Discrepancy'){
                    oppRec.EYI_Booking_Form_Status__c = 'Booking Form Accepted';
                }
            }
            oppRec.Booking_Checklist_Checker__c =UserInfo.getUserId();
        }
        if(isSubmit == true && checklistName== 'Sales Checklist'){
            oppRec.IsSalesChecklistSubmitted__c = true;
            oppRec.EYI_Sales_Checklist_Checker__c =UserInfo.getUserId();
        }
        // Add the Post Registration with Loan checklist logic
        if(isSubmit == true && checklistName == 'Post Registration with Loan'){
            oppRec.EYI_Is_Post_Register_with_Loan_Checklist__c = true;
            oppRec.EYI_Post_Registration_Checklist_Checker__c =UserInfo.getUserId();
        }
        
        if(isSubmit == true && checklistName == 'Invoice'){
            oppRec.EYI_Is_InvoiceChecklist_Submitted__c = true;
            oppRec.EYI_Invoice_Checklist_Checker__c =UserInfo.getUserId();
        }
        if(checklistName =='CHIF'){
            oppRec.EYI_IsCHIFSubmitted__c = true;
            oppRec.EYI_AutomationBypassDatetime__c = System.now();
        }
        update oppRec;
        Set<String> questionNames = new Set<String>();
        for (Checklist_Item__c item : checklistItems) {
            questionNames.add(item.Question__c);
        }
       
        for (Checklist_Item__c item : [SELECT Id,Status__c,EYI_Status__c,EYI_Sequence_No__c, Question__c, Remarks__c,Category__c,Valid__c,Invalid__c 
            FROM Checklist_Item__c WHERE Opportunity__c=:recordId AND Question__c IN :questionNames order by EYI_Sequence_No__c]) {
            existingItemsMap.put(item.Question__c, item);
        }
        List<Checklist_Item__c> itemsToInsert = new List<Checklist_Item__c>();
        // List<Checklist_Item__c> itemsToUpdate = new List<Checklist_Item__c>();
        Map<Id, Checklist_Item__c> itemsToUpdateMap = new Map<Id, Checklist_Item__c>();

        for (Checklist_Item__c newItem : checklistItems) {
            System.debug('newItem.Question__c : '+newItem);
            if (existingItemsMap.containsKey(newItem.Question__c)) {
                Checklist_Item__c existingItem = existingItemsMap.get(newItem.Question__c);
                System.debug('existingItem.Question__c : '+existingItem);

                if (!itemsToUpdateMap.containsKey(existingItem.Id)) {
                    if (
                        existingItem.Remarks__c != newItem.Remarks__c ||
                        existingItem.Category__c != newItem.Category__c ||
                        existingItem.Status__c != newItem.Status__c ||
                        existingItem.EYI_Status__c != newItem.EYI_Status__c ||
                        existingItem.Valid__c != newItem.Valid__c ||
                        existingItem.Invalid__c != newItem.Invalid__c
                    ) {
                        existingItem.Remarks__c = newItem.Remarks__c;
                        existingItem.Category__c = newItem.Category__c;
                        existingItem.Status__c = newItem.Status__c;
                        existingItem.EYI_Status__c = newItem.EYI_Status__c;
                        existingItem.Valid__c = newItem.Valid__c;
                        existingItem.Invalid__c = newItem.Invalid__c;

                        System.debug('In map existingItem.Question__c : ' + existingItem);

                        itemsToUpdateMap.put(existingItem.Id, existingItem);
                    }
                }
            } else {
                itemsToInsert.add(newItem);
            }
        }
        System.debug('itemsToUpdate : '+itemsToUpdateMap);

        System.debug('itemsToInsert : '+itemsToInsert);
        if (!itemsToInsert.isEmpty()) {
            insert itemsToInsert;
        }
        if (!itemsToUpdateMap.isEmpty()) {
            update itemsToUpdateMap.values();
        }
        System.debug('itemsToUpdateMap.values() : '+itemsToUpdateMap.values());

        if(isSubmit == true && checklistName== 'Registration Checklist'){
          callApprovalProcess(recordId,checklistName);  
        }
       
    } catch (Exception e) {
        throw new AuraHandledException('Error saving checklist items: ' + e.getMessage());
    }
}


    public static void callApprovalProcess(Id recordId,String checklistName){
        String currentUserRole = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].UserRole.Name;
        if(checklistName == 'Registration Checklist' && currentUserRole == 'Relationship Manager'){
            ProcessDefinition approvalProcess = [
            SELECT Id,DeveloperName
            FROM ProcessDefinition
            WHERE DeveloperName = 'EYI_Registration_Checklist_Approval'
            LIMIT 1
        ];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Please verify the Registration Checklist and approve it.');
        req.setObjectId(recordId);
        Approval.ProcessResult result = Approval.process(req);
        if (result.isSuccess()) {
            System.debug('Approval process successfully submitted.');
        } else {
            System.debug('Approval process submission failed: ' + result.getErrors());
        }
        }
    }
    @AuraEnabled
    public static void updateOppRecord(Id recordId,String checklistName){
        Opportunity oppRec = [Select Id,IsBookingChecklistSubmitted__c,Booking_Checklist_Checker__c,IsSalesChecklistSubmitted__c,EYI_Sales_Checklist_Checker__c From Opportunity Where id=:recordId];
        if(checklistName == 'Booking Checklist'){
            oppRec.IsBookingChecklistSubmitted__c = false;
        	oppRec.Booking_Checklist_Checker__c = null;
        }
        if(checklistName == 'Sales Checklist'){
          oppRec.IsSalesChecklistSubmitted__c = false;
          oppRec.EYI_Sales_Checklist_Checker__c = null;  
        }
        
        update oppRec;
    }
   
    @AuraEnabled
    public static void saveRemark(String recordId, String remark,String checklistName) {
        try {
            Opportunity oppRec = [SELECT Id, EYI_Closing_Manager_Checklist_Remark__c,Closing_Manager_Sales_Checklist_Remark__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if(checklistName == 'Booking Checklist'){
                oppRec.EYI_Closing_Manager_Checklist_Remark__c = remark;
            }
            if(checklistName == 'Sales Checklist'){
                oppRec.Closing_Manager_Sales_Checklist_Remark__c = remark;
            }
            
            update oppRec;
        } catch (Exception e) {
            throw new AuraHandledException('Error while saving the remark: ' + e.getMessage());
        }
    }
   
    @AuraEnabled
    public static void saveBookingStatus(String recordId, String bookingFormStatus,String checklistName) {
        try {
            Opportunity oppRec = [SELECT Id, EYI_Booking_Form_Status__c,EYI_Sales_Checklist_Status__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if(checklistName == 'Booking Checklist'){
                oppRec.EYI_Booking_Form_Status__c = bookingFormStatus;
            }
            if(checklistName == 'Sales Checklist'){
                oppRec.EYI_Sales_Checklist_Status__c = bookingFormStatus;
            }
            update oppRec;
        } catch (Exception e) {
            throw new AuraHandledException('Error while saving the remark: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String findBookingForm(Id oppId) {
        
        try {
            Opportunity oppRec = [Select id, Name,EYI_Project_Enquired__r.Name from Opportunity Where Id =:oppId];
            String fileName = 'Application Form';
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocument.Title, ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :oppId AND ContentDocument.Title LIKE : ('%' + fileName + '%')
                LIMIT 1
            ];

            if (!docLinks.isEmpty()) {
                ContentVersion contentVersion = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId = :docLinks[0].ContentDocumentId
                    ORDER BY CreatedDate DESC LIMIT 1
                ];
                String fileUrl = '/sfc/servlet.shepherd/version/download/' + contentVersion.Id;
                return fileUrl;
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error while fetching Booking Form: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<EYI_CHIF__c> getCHIFDetails(String oppId){
        System.debug('oppId ******>>>'+oppId);
        List<EYI_CHIF__c> chifList = new List<EYI_CHIF__c>();
        try {
            chifList = [Select Id From EYI_CHIF__c Where EYI_Opportunity__c =:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return chifList;
    }

    @AuraEnabled
    public static EYI_CHIF__c createCHIFDetails(String oppId,String towerId, String projectId, String onBehalf,String type){
        EYI_CHIF__c chifRec =  new EYI_CHIF__c();
        try {   
            chifRec.EYI_Opportunity__c = oppId != null ? oppId : null;
            chifRec.EYI_Project__c = projectId != null ? projectId : null;
            chifRec.EYI_Tower__c = towerId != null ? towerId : null;
            chifRec.EYI_Visit_On_Behalf_Of__c = onBehalf != null ? onBehalf : '';
            chifRec.EYI_Typology__c = type != null ? type : '';
            insert chifRec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return chifRec;
    }

    @AuraEnabled(cacheable=true)
    public static EYI_REC__c getRECDetails(Id opportunityId) {
        try {
        List<Opportunity> opportunities = [
            SELECT Id, EYI_REC__c 
            FROM Opportunity 
            WHERE Id = :opportunityId 
            LIMIT 1
        ];
        
        if (!opportunities.isEmpty() && opportunities[0].EYI_REC__c != null) {
            EYI_REC__c recRecord = [
                SELECT Id, Name, CreatedDate,
                       EYI_SAP_ID__c,
                       EYI_GSTIN__c,
                       EYI_RERA_Registered__c, 
                       EYI_REC_Vendor_Code__c,
                       EYI_RERA_Certificate_No__c,
                       EYI_PAN_No__c,
                       EYI_Pan_Uploaded__c
                FROM EYI_REC__c 
                WHERE Id = :opportunities[0].EYI_REC__c 
                LIMIT 1
            ];
            
            return recRecord;
        }
        
        return null;
    } catch (Exception e) {
        throw new AuraHandledException('Error fetching REC details: ' + e.getMessage());
    }
}

// Add this method to your ChecklistQuestionController class
@AuraEnabled(cacheable=true)
public static EYI_Brokerage__c getBrokerageDetails(Id opportunityId) {
    try {
        // Get the REC from Opportunity (not AccountId)
        Opportunity opp = [SELECT Id, EYI_REC__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        if (opp.EYI_REC__c == null) {
            return null;
        }
        
        // Query EYI_Brokerage__c records related to both Opportunity AND REC
        List<EYI_Brokerage__c> brokerageList = [
            SELECT Id, Name, CreatedDate, LastModifiedDate,
                   EYI_Brokerage_Amount__c, EYI_Brokerage_Percentage__c, 
                   Stages__c, EYI_Invoice_Approval_Status__c,
                   EYI_Is_20_Booking_Received__c,
                   EYI_Opportunity__c, EYI_REC_Account__c
            FROM EYI_Brokerage__c 
            WHERE EYI_Opportunity__c = :opportunityId 
               AND EYI_REC_Account__c = :opp.EYI_REC__c
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        return brokerageList.isEmpty() ? null : brokerageList[0];
        
    } catch (Exception e) {
        System.debug('Error fetching Brokerage details: ' + e.getMessage());
        return null;
    }
}

// Replace the getChecklistItems method with this corrected version:

@AuraEnabled(cacheable=true)
public static List<Checklist_Item__c> getChecklistItems(String opportunityId, String checklistType) {
    try {
        return [
            SELECT Id, Question__c, Remarks__c, Valid__c, Type__c, Status__c,
                   CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate
            FROM Checklist_Item__c 
            WHERE Opportunity__c = :opportunityId 
            AND Type__c = :checklistType
            ORDER BY CreatedDate DESC
        ];
    } catch (Exception e) {
        System.debug('Error fetching checklist items: ' + e.getMessage());
        throw new AuraHandledException('Error fetching checklist items: ' + e.getMessage());
    }
}

@AuraEnabled(cacheable=true)
public static List<EYI_Bank_Details__c> getBankDetailsByREC(Id recId) {
    try {
        return [
            SELECT Id, Name, EYI_Bank_Name__c, EYI_Bank_Account_Number__c, EYI_IFSC_Code__c
            FROM EYI_Bank_Details__c
            WHERE EYI_REC_Account__c = :recId
            AND (EYI_Deactivated__c = false OR EYI_Deactivated__c = null)
        ];
    } catch (Exception e) {
        throw new AuraHandledException('Error fetching Bank Details: ' + e.getMessage());
    }
}

// Add this new method specifically for Pre Cancellation checklist
@AuraEnabled
public static void updatePreCancellationSubmissionStatus(String recordId) {
    try {
        Opportunity opp = new Opportunity(
            Id = recordId,
            EYI_IsPreCancellationChecklistSubmitted__c = true,
            EYI_Pre_Registration_Checklist_Checker__c = UserInfo.getUserId()
        );
        
        update opp;
        
        System.debug('Pre Cancellation checklist submission status updated for Opportunity: ' + recordId);
        
    } catch (Exception e) {
        System.debug('Error updating Pre Cancellation checklist status: ' + e.getMessage());
        throw new AuraHandledException('Error updating checklist submission status: ' + e.getMessage());
    }
}

@AuraEnabled
public static void updateOpportunityPostCancellationFields(String opportunityId, String userId) {
    try {
        System.debug('Updating opportunity with ID: ' + opportunityId + ', User ID: ' + userId);
        
        Opportunity opp = new Opportunity();
        opp.Id = opportunityId;
        opp.EYI_Post_Registration_Checklist_Checker__c = userId;
        opp.EYI_IsPostCancellationChecklistSubmitted__c = true;
        
        update opp;
        
        System.debug('Opportunity updated successfully: ' + opportunityId);
    } catch (Exception e) {
        System.debug('Error updating opportunity: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
        throw new AuraHandledException('Error updating opportunity: ' + e.getMessage());
    }
}
}