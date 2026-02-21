/**
 * @description       : 
 * @author            : Abhishek Verma
 * @group             : 
 * @last modified on  : 05-29-2025
 * @last modified by  : Abhishek Verma
**/
public class EYI_CaseCancellationMasterSyncController {
    
    @AuraEnabled
    public static lwcMessage CancellationMasterSync(Id recordId){
        lwcMessage lm = new lwcMessage();
        Boolean isPATCHOperation = false;
        Map<String, String> sfmapSAP = new Map<String, String>();
        String apiResponse;
        CancellationSyncDataWrapper data = new CancellationSyncDataWrapper();
        List<ProcessInstance> approvalProcesses = [
            SELECT Id, Status, TargetObjectId, CreatedDate, LastModifiedDate,
            (SELECT Id, StepStatus, Comments, ActorId, OriginalActorId, CreatedDate
            FROM Steps
            ORDER BY CreatedDate ASC)
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId
            ORDER BY CreatedDate DESC
        ];
        Case cancellationDetails = [SELECT Id,EYI_Is_Cancellation_Sync__c,EYI_Opportunity__r.EYI_SAP_Customer_Number__c,EYI_Cancellation_Type__c,
                                           EYI_Sub_Type__c,EYI_Cancellation_Remarks__c,EYI_Cancellation_Request_Date__c,EYI_Date_of_Cancellation_initiated__c,
                                           EYI_Cancellation_Status__c,EYI_Cancellation_Commencement__c,EYI_Registration_Status__c,
                                           EYI_Opportunity__r.SyncedQuote.EYI_Agreement_Value__c,
                                           EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c,EYI_Opportunity__r.EYI_SalesOrder_Number__c,
                                           EYI_Opportunity__r.SyncedQuote.EYI_Quoatation_Grand_Total__c,EYI_Opportunity__r.EYI_Walk_in_Source__c,
                                           EYI_Opportunity__r.SyncedQuote.Stamp_Duty__c,EYI_Opportunity__r.EYI_REC__r.Name,
                                           EYI_Opportunity__r.EYI_REC__r.EYI_REC_Code__c,EYI_Opportunity__r.EYI_REC__r.EYI_REC_Vendor_Code__c,EYI_Opportunity__r.EYI_REC__r.EYI_RERA_Certificate_No__c,
                                           EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c,EYI_Retained_by_User__r.Name,
                                    					  EYI_Opportunity__r.EYI_Registration_Status__c,
                                                          EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name,EYI_Opportunity__r.EYI_Relationship_Manager__r.Name,
                                                          EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name,EYI_Demanded_Amount_Principal__c,
                                                          EYI_Reversal_Demanded_Amount_Principal__c,Owner.Name,
                                                          EYI_Refund_Amount_Principal__c,EYI_Demanded_Amount_Tax__c,EYI_Demand_Amount_Charged_to_Customer__c,
                                                          EYI_Paid_Amount_Principal__c,EYI_TDS_Amount__c,
                                                          EYI_Paid_Amount_Tax__c,EYI_Refund_Amount_Tax__c,
                                                          EYI_Brokerage_Amount__c,EYI_Debit_Note_Principal__c,EYI_Credit_Note_Principal__c,
                                                          EYI_Debit_Note_Tax__c,EYI_Credit_Note_Tax__c,EYI_Reversal_Debit_Note_Principal__c,
                                                          EYI_Reversal_Credit_Note_Principal__c,
                                    					  EYI_Reversal_Debit_Note_Tax__c,EYI_Reversal_Credit_Note_Tax__c,
                                    					  EYI_Credit_Note_Charged_to_Customer__c,EYI_Debit_Note_Charged_to_Customer__c,
                                                          EYI_Total_Interest_Accured__c,EYI_Interest_Waiver__c,EYI_Total_Interest_Charged__c,
                                                          EYI_Brokerage_Waiver__c,EYI_Total_Brokerage_Charged__c,EYI_Remark_For_Finance__c,
                                    EYI_Interest_Charged_Remarks__c,EYI_Brokerage_Charged_Remarks__c,EYI_Adjustment_Remarks__c,EYI_Forfeiture_Remarks__c,
                                                          EYI_Other_Adjustments__c,EYI_Forfeit_Amount__c,EYI_Total_Received_Amount__c,
                                                          EYI_TotalAmountCharged__c,EYI_Total_Refund_Given__c,EYI_Reversal_Demanded_Amount_Tax__c,
                                    EYI_Down_Payment_Amount_Principal__c,EYI_Down_Payment_Amount_Tax__c,EYI_Reversal_Down_Payment_Amt_Tax__c,EYI_Reversal_Down_Payment_Amt_Principal__c,EYI_Down_Payment_Amt_Charged_To_Customer__c
                                                          from Case
                                                          Where Id=:recordId];
        
          if(cancellationDetails!= null){
            try{
                //Mrinal change starts -> Required fields missing
                String reqFieldError = System.Label.EYI_Cust_Sync_Req_field_Error;
                reqFieldError+=' Opportunity : ';

                if (String.isBlank(cancellationDetails.EYI_Cancellation_Type__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Type__c, ';
                }else{
                    data.CancellationType = cancellationDetails.EYI_Cancellation_Type__c;
                }
                System.debug('Sub type : '+cancellationDetails.EYI_Sub_Type__c);
                if (String.isBlank(cancellationDetails.EYI_Sub_Type__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Sub_Type__c, ';
                }else{
                    data.CancellationSubtype = cancellationDetails.EYI_Sub_Type__c;
                }
                
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Remarks__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Remarks__c, ';
                }else{
                    data.CancellationRemarks = cancellationDetails.EYI_Cancellation_Remarks__c;
                }
				data.Remarks  = cancellationDetails.EYI_Remark_For_Finance__c;
                data.DateOfCancellationInitiated = cancellationDetails.EYI_Date_of_Cancellation_initiated__c;
                data.CUST1 = String.valueOf(cancellationDetails.EYI_Cancellation_Request_Date__c);
                data.CancellationStatus = cancellationDetails.EYI_Cancellation_Status__c;
                
                data.CancellationRequestInitiatedby = cancellationDetails.Owner.Name;

                data.RetainedByUser = cancellationDetails.EYI_Retained_by_User__r.Name; 

				data.DownPayAmtPrincipal = cancellationDetails.EYI_Down_Payment_Amount_Principal__c;
                data.RevDownPayAmtPrincipal = cancellationDetails.EYI_Reversal_Down_Payment_Amt_Principal__c;
                data.DownPayAmtTax = cancellationDetails.EYI_Down_Payment_Amount_Tax__c;
                data.RevDownPayAmtTax = cancellationDetails.EYI_Reversal_Down_Payment_Amt_Tax__c;
                data.DownPayAmtCTC = cancellationDetails.EYI_Down_Payment_Amt_Charged_To_Customer__c;
                
                data.DemandAmtPrincipal = cancellationDetails.EYI_Demanded_Amount_Principal__c;
                data.RevDemandAmtPrincipal = cancellationDetails.EYI_Reversal_Demanded_Amount_Principal__c;
                data.DemandAmtTax = cancellationDetails.EYI_Demanded_Amount_Tax__c;
                data.RevDemandAmtTax = cancellationDetails.EYI_Reversal_Demanded_Amount_Tax__c;
                data.DemandAmtCTC = cancellationDetails.EYI_Demand_Amount_Charged_to_Customer__c;
                
				/*data.PaidAmountPrincipal = cancellationDetails.EYI_Paid_Amount_Principal__c;
                data.RefundAmountPrincipal = cancellationDetails.EYI_Refund_Amount_Principal__c;
                data.PaidAmtTax = cancellationDetails.EYI_Paid_Amount_Tax__c;
                data.RefundAmountTax = cancellationDetails.EYI_Refund_Amount_Tax__c;*/
                
                data.DebitNotePrincipal = cancellationDetails.EYI_Debit_Note_Principal__c;
                data.DebitNoteTax = cancellationDetails.EYI_Debit_Note_Tax__c;
                data.ReversalDebitNotePrincipal = cancellationDetails.EYI_Reversal_Debit_Note_Principal__c;
                data.ReversalDebitNoteTax = cancellationDetails.EYI_Reversal_Debit_Note_Tax__c;
                data.DebitNoteCTC = cancellationDetails.EYI_Debit_Note_Charged_to_Customer__c;
                
                data.CreditNotePrincipal = cancellationDetails.EYI_Credit_Note_Principal__c;
                data.CreditNoteTax = cancellationDetails.EYI_Credit_Note_Tax__c;
                data.ReversalCreditNotePrincipal = cancellationDetails.EYI_Reversal_Credit_Note_Principal__c;
				data.ReversalCreditNoteTax = cancellationDetails.EYI_Reversal_Credit_Note_Tax__c;
				data.CreditNoteCTC = cancellationDetails.EYI_Credit_Note_Charged_to_Customer__c;
                
                
                data.TotalInterestAccured = cancellationDetails.EYI_Total_Interest_Accured__c;
                data.InterestWaiver = cancellationDetails.EYI_Interest_Waiver__c;
                data.TotalInterestCharged = cancellationDetails.EYI_Total_Interest_Charged__c;
                data.InterestChargedRemarks =cancellationDetails.EYI_Interest_Charged_Remarks__c;
                
                data.BrokerageAmount = cancellationDetails.EYI_Brokerage_Amount__c;
				data.BrokerageWaiver = cancellationDetails.EYI_Brokerage_Waiver__c;
                data.TotalBrokerageCharged = cancellationDetails.EYI_Total_Brokerage_Charged__c;
                data.BrokerageChargedRemarks = cancellationDetails.EYI_Brokerage_Charged_Remarks__c;
                
                data.OtherAdjustments = cancellationDetails.EYI_Other_Adjustments__c;
                data.AdjustmentRemarks = cancellationDetails.EYI_Adjustment_Remarks__c;
   
                data.ForfeitAmount = cancellationDetails.EYI_Forfeit_Amount__c;
                data.ForfeitureRemarks = cancellationDetails.EYI_Forfeiture_Remarks__c;
                
                /*if (String.isBlank(String.valueOf(cancellationDetails.EYI_Total_Received_Amount__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Total_Received_Amount__c, ';
                }else{*/
                    data.TotalRecievedAmount = cancellationDetails.EYI_Total_Received_Amount__c;
               // }
                
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_TotalAmountCharged__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_TotalAmountCharged__c, ';
                }else{
                    data.TotalAmountCharged = cancellationDetails.EYI_TotalAmountCharged__c;
                }
                
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Total_Refund_Given__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Total_Refund_Given__c, ';
                }else{
                    data.TotalRefundGiven = cancellationDetails.EYI_Total_Refund_Given__c;
                }
                /*if (String.isBlank(String.valueOf(cancellationDetails.EYI_TDS_Amount__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_TDS_Amount__c, ';
                }else{*/
                    data.TDSAmount = cancellationDetails.EYI_TDS_Amount__c;
               // }

                
                

                // Checking EYI_Opportunity__r lookup fields
                if (cancellationDetails.EYI_Opportunity__r != null) {
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Registration_Status__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_Registration_Status__c, ';
                    }else{
                        data.RegistrationStatus = cancellationDetails.EYI_Opportunity__r.EYI_Registration_Status__c;
                    }
                    
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_SAP_Customer_Number__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_SAP_Customer_Number__c, ';
                    }else{
                        data.SapCustomerNo = cancellationDetails.EYI_Opportunity__r.EYI_SAP_Customer_Number__c;
                    }
                    
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Walk_in_Source__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Walk_in_Source__c, ';
                    }else{
                        data.BookingSource = cancellationDetails.EYI_Opportunity__r.EYI_Walk_in_Source__c;
                    }
                    
                    /*if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_SalesOrder_Number__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_SalesOrder_Number__c, ';
                    }else{*/
                        data.SalesOrderNo = cancellationDetails.EYI_Opportunity__r.EYI_SalesOrder_Number__c;
                    //}
                    
                    /*if (String.isBlank(String.valueOf(cancellationDetails.EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c))) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c, ';
                    }else{*/
                        data.BrokerageTotalAmount  = cancellationDetails.EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c;
                    //}
                    //sourcing Manager
                    //if(cancellationDetails.EYI_Opportunity__r.EYI_Sourcing_Manager__r != null){
                        /*if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name)){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name, ';
                        }else{*/
                           data.SourcingManager = cancellationDetails.EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name; 
                        //}
                    //}
                    //Relationship Manager
                   // if(cancellationDetails.EYI_Opportunity__r.EYI_Relationship_Manager__r != null){
                       /* if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Relationship_Manager__r.Name)){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Opportunity__r.EYI_Relationship_Manager__r.Name, ';
                        }else{*/
                           data.RelationshipManager = cancellationDetails.EYI_Opportunity__r.EYI_Relationship_Manager__r.Name; 
                       // }
                    //}
                    //primary Manager
                    //if(cancellationDetails.EYI_Opportunity__r.EYI_Primary_Closing_Manager__r != null){
                       /* if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name)){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name, ';
                        }else{*/
                           data.ClosingManager = cancellationDetails.EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name;
                       // }
                    //}
                    
                     // Checking SyncedQuote lookup fields 
                    //if (cancellationDetails.EYI_Opportunity__r.SyncedQuote != null) {
                        if (String.isBlank(String.valueOf(cancellationDetails.EYI_Opportunity__r.SyncedQuote.EYI_Agreement_Value__c))) {
                            lm.type = 'e';
                            reqFieldError += 'SyncedQuote.EYI_Agreement_Value__c, ';
                        }else{
                            data.AgreementValue = cancellationDetails.EYI_Opportunity__r.SyncedQuote.EYI_Agreement_Value__c;
                        }
                        
                        /*if (String.isBlank(String.valueOf(cancellationDetails.EYI_Opportunity__r.SyncedQuote.EYI_Quoatation_Grand_Total__c))) {
                            lm.type = 'e';
                            reqFieldError += 'SyncedQuote.EYI_Quoatation_Grand_Total__c, ';
                        }else{*/
                            data.TotalCost = cancellationDetails.EYI_Opportunity__r.SyncedQuote.EYI_Quoatation_Grand_Total__c;
                       // }
                        
                        /*if(String.isBlank(String.valueOf(cancellationDetails.EYI_Opportunity__r.SyncedQuote.Stamp_Duty__c))){
                            lm.type = 'e';
                            reqFieldError += 'SyncedQuote.Stamp_Duty__c, ';
                        }else{*/
                           data.StampDuty = cancellationDetails.EYI_Opportunity__r.SyncedQuote.Stamp_Duty__c; 
                        //}
                  //  }
    
                    // Checking EYI_Inventory__r lookup fields
                    if (cancellationDetails.EYI_Opportunity__r.EYI_Inventory__r != null) {
                        if (String.isBlank(String.valueOf(cancellationDetails.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c))){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Inventory__r.EYI_Inventory_Number__c, ';
                        }else{
                            data.SapInventoryNo = String.valueOf(cancellationDetails.EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c);
                        }
                    }
                    
                    if (cancellationDetails.EYI_Opportunity__r.EYI_REC__r != null) {
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_REC__r.Name)){
                            lm.type = 'e';
                           reqFieldError += 'EYI_REC__r.Name, '; 
                        }else{
                            data.RecName = cancellationDetails.EYI_Opportunity__r.EYI_REC__r.Name;
                        }
                        
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_REC_Vendor_Code__c)){
                            lm.type = 'e';
                           reqFieldError += 'EYI_REC__r.EYI_REC_Vendor_Code__c, '; 
                        }else{
                            data.RecCode = cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_REC_Vendor_Code__c;
                        }
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_RERA_Certificate_No__c)){
                            lm.type = 'e';
                           reqFieldError += 'EYI_REC__r.EYI_RERA_Certificate_No__c, '; 
                        }else{
                            data.ReraNumber = cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_RERA_Certificate_No__c;
                        }
                        
                    }
                    
                }
                List<ProcessInstance> instances = [
                    SELECT Id, TargetObjectId, ProcessDefinition.Name,ProcessDefinition.DeveloperName
                    FROM ProcessInstance
                    WHERE TargetObjectId = :recordId
                    ORDER BY CreatedDate DESC
				];
                System.debug('instances '+instances);
                
                /*List<ProcessInstance> instances = [
            SELECT Id, TargetObjectId, ProcessDefinition.Name
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId
              AND (ProcessDefinition.DeveloperName = 'Cancellation_Deviation_Approval_for_RM' OR ProcessDefinition.DeveloperName = 'Cancellation_Deviation_Approval_for_SM')
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];*/
                if(!instances.isEmpty()){
                    
                    
                    //Id processInstanceId = instances[0].Id;
                    ProcessInstance targetInstance;
                    for (ProcessInstance pi : instances) {
                        System.debug('pi.ProcessDefinition.DeveloperName : '+pi.ProcessDefinition.DeveloperName);
                        if (pi.ProcessDefinition != null && (pi.ProcessDefinition.DeveloperName == 'Cancellation_Deviation_Approval_for_RM' || pi.ProcessDefinition.DeveloperName == 'Cancellation_Deviation_Approval_for_SM')) {
                            targetInstance = pi;
                            break; // Stop at the first matching instance
                        }
                    }
                    Id processInstanceId = targetInstance.Id;

        // Step 2: Get Approval Steps
        List<ProcessInstanceStep> steps = [
            SELECT StepStatus, Comments, ActorId, CreatedDate, OriginalActor.Name
            FROM ProcessInstanceStep
            WHERE ProcessInstanceId = :processInstanceId
            ORDER BY CreatedDate ASC
        ];
		if (!steps.isEmpty()) {
            ProcessInstanceStep finalStep = steps[steps.size() - 1];
        
            String finalApproverName = finalStep.OriginalActor != null ? finalStep.OriginalActor.Name : '';
            Date finalApprovalDate = finalStep.CreatedDate.date();
            Time finalApprovalTime = Time.newInstance(finalStep.CreatedDate.hour(), finalStep.CreatedDate.minute(), finalStep.CreatedDate.second(), 0);
        
            data.FinalCancellationApprover = finalApproverName;
            data.FinalCancellationApprovedOn = finalApprovalDate;
            data.FinalCancellationApprovedAt = finalApprovalTime;
        }
        // Step 3: Dynamically populate the wrapper
        Integer level = 1;

        for (ProcessInstanceStep step : steps) {
            if (level > 5) break;

            String approverName = step.OriginalActor != null ? step.OriginalActor.Name : '';
            String action = step.StepStatus;
            String comment = step.Comments;
            Date approvalDate = step.CreatedDate.date();
            //Time approvalTime = Time.newInstance(step.CreatedDate.hour(), step.CreatedDate.minute(), step.CreatedDate.second(), 0);
			Time t = Time.newInstance(step.CreatedDate.hour(), step.CreatedDate.minute(), step.CreatedDate.second(), 0);

String formattedTime = 
    (t.hour() < 10 ? '0' + t.hour() : String.valueOf(t.hour())) + ':' +
    (t.minute() < 10 ? '0' + t.minute() : String.valueOf(t.minute())) + ':' +
    (t.second() < 10 ? '0' + t.second() : String.valueOf(t.second()));

            // Dynamically assign based on level
            switch on level {
                when 1 {
                    data.CancellationApproverL1 = approverName;
                    data.L1RequestApprovedAction = action;
                    data.L1RequestApprovedRemark = comment;
                    data.L1RequestApprovedOn = approvalDate;
                    data.L1RequestApprovedAt = formattedTime;
                }
                when 2 {
                    data.CancellationApproverL2 = approverName;
                    data.L2RequestApprovedAction = action;
                    data.L2RequestApprovedRemark = comment;
                    data.L2RequestApprovedOn = approvalDate;
                    data.L2RequestApprovedAt = formattedTime;
                }
                when 3 {
                    data.CancellationApproverL3 = approverName;
                    data.L3RequestApprovedAction = action;
                    data.L3RequestApprovedRemark = comment;
                    data.L3RequestApprovedOn = approvalDate;
                    data.L3RequestApprovedAt = formattedTime;
                }
                when 4 {
                    data.CancellationApproverL4 = approverName;
                    data.L4RequestApprovedAction = action;
                    data.L4RequestApprovedRemark = comment;
                    data.L4RequestApprovedOn = approvalDate;
                    data.L4RequestApprovedAt = formattedTime;
                }
                when 5 {
                    data.CancellationApproverL5 = approverName;
                    data.L5RequestApprovedAction = action;
                    data.L5RequestApprovedRemark = comment;
                    data.L5RequestApprovedOn = approvalDate;
                    data.L5RequestApprovedAt = formattedTime;
                }
            }

            level++;
        }
                }
        

               
                
                // Remove the trailing comma and space before setting the error message
                if (lm.type == 'e') {
                    reqFieldError = reqFieldError.trim();
                    if (reqFieldError.endsWith(',')) {
                        reqFieldError = reqFieldError.substring(0, reqFieldError.length() - 1);
                    }
                    lm.message = reqFieldError;
                    return lm;
                } else{
                    Map<String, Object> payload = new Map<String, Object>();
                    payload.put('CancellationDetails', data);
                    String filterString = JSON.serialize(payload);
                    System.debug('Generated JSON: ' + filterString);
                    try{
                        HTTPResponse res = new HTTPResponse();
                        res = EY_SAP_Gateway.postCancellationDetails(filterString);
                        apiResponse = res.getBody();
                        Integer statusCode = res.getStatusCode();
                        System.debug('statusCode : '+statusCode);
                        System.debug('apiResponse : '+apiResponse);  
                        lm.type ='s';
                        lm.message = 'Record Synced Successfully...!';
                        cancellationDetails.EYI_Is_Cancellation_Sync__c = true;
                        update cancellationDetails;
                    }catch(Exception e){
                        System.debug('e.getMessage() : '+e.getMessage());
                        if (e.getMessage().contains('StatusCode=404')) {
                            lm.type ='e';
                            lm.message = 'StatusCode 404 Received';
                        }
                    }
                    
                    return lm;
                }
                
                
            } catch (Exception e) {
                // Handle exceptions
                lm.type =  'E';
                lm.message = e.getMessage()+'---' +e.getLineNumber();
                system.debug('Error:: ' +e.getMessage());
                return lm;
                
            }
        
    }else{
        lm.type =  'E';
        lm.message = 'Record Id Missing';
        return lm;
    }

       // return lm;
    }
    
    public class lwcMessage{
        @AuraEnabled  public string type;
        @AuraEnabled  public string message;
    } 
    public class CancellationSyncDataWrapper {
        // Picklist or Text Fields
    @AuraEnabled public String SapCustomerNo = '';
    @AuraEnabled public String CancellationType = '';
    @AuraEnabled public String CancellationSubtype ='';
    @AuraEnabled public String CancellationReason ='';
    @AuraEnabled public String CancellationRemarks;
    @AuraEnabled public String CancellationStatus;
    @AuraEnabled public String CancellationCommencement;
    @AuraEnabled public String RegistrationStatus;
    @AuraEnabled public String SapInventoryNo;
    @AuraEnabled public String SalesOrderNo;
    @AuraEnabled public String RecName = '';
    @AuraEnabled public String RecCode ='';
    @AuraEnabled public String ReraNumber;
    @AuraEnabled public String RetainedByUser;
    @AuraEnabled public String FinalCancellationApprover;
   // @AuraEnabled public String remarks;
    @AuraEnabled public String SourcingManager;
    @AuraEnabled public String RelationshipManager;
    @AuraEnabled public String ClosingManager;
    @AuraEnabled public String BookingSource;
    @AuraEnabled public String CancellationRequestInitiatedby;
    @AuraEnabled public String CUST1;
    @AuraEnabled public String CUST2;
    @AuraEnabled public String CUST3;
    @AuraEnabled public String CUST4;
    @AuraEnabled public String Remarks;
    @AuraEnabled public String InterestChargedRemarks;
    @AuraEnabled public String BrokerageChargedRemarks;
    @AuraEnabled public String AdjustmentRemarks;
    @AuraEnabled public String ForfeitureRemarks;
    @AuraEnabled public String CancellationApproverL1;
    @AuraEnabled public String CancellationApproverL2;
    @AuraEnabled public String CancellationApproverL3;
    @AuraEnabled public String CancellationApproverL4;
	@AuraEnabled public String CancellationApproverL5;
    
    @AuraEnabled public String L1RequestApprovedRemark;
    @AuraEnabled public String L2RequestApprovedRemark;
    @AuraEnabled public String L3RequestApprovedRemark;
    @AuraEnabled public String L4RequestApprovedRemark;
	@AuraEnabled public String L5RequestApprovedRemark;
        
    @AuraEnabled public String L1RequestApprovedAction;
    @AuraEnabled public String L2RequestApprovedAction;
    @AuraEnabled public String L3RequestApprovedAction;
    @AuraEnabled public String L4RequestApprovedAction;
	@AuraEnabled public String L5RequestApprovedAction;
        
    // Date and Time Fields
    @AuraEnabled public Date DateOfCancellationInitiated;
    @AuraEnabled public Date FinalCancellationApprovedOn;
    @AuraEnabled public Date L1RequestApprovedOn;
    @AuraEnabled public Date L2RequestApprovedOn;
    @AuraEnabled public Date L3RequestApprovedOn;
    @AuraEnabled public Date L4RequestApprovedOn;
    @AuraEnabled public Date L5RequestApprovedOn;
    @AuraEnabled public Time FinalCancellationApprovedAt;
    @AuraEnabled public String L1RequestApprovedAt;
    @AuraEnabled public String L2RequestApprovedAt;
    @AuraEnabled public String L3RequestApprovedAt;
    @AuraEnabled public String L4RequestApprovedAt;
    @AuraEnabled public String L5RequestApprovedAt;

    // Number Fields
    @AuraEnabled public Decimal AgreementValue;
    @AuraEnabled public Decimal TotalCost;
    @AuraEnabled public Decimal StampDuty;
    @AuraEnabled public Decimal BrokerageTotalAmount;
    @AuraEnabled public Decimal DemandAmtPrincipal;
    @AuraEnabled public Decimal RevDemandAmtPrincipal;
    @AuraEnabled public Decimal PaidAmountPrincipal;
    @AuraEnabled public Decimal RefundAmountPrincipal;
    @AuraEnabled public Decimal DemandAmtTax;
    @AuraEnabled public Decimal RevDemandAmtTax;
    @AuraEnabled public Decimal PaidAmtTax;
    @AuraEnabled public Decimal RefundAmountTax;
    @AuraEnabled public Decimal BrokerageAmount;
    @AuraEnabled public Decimal DebitNotePrincipal;
    @AuraEnabled public Decimal CreditNotePrincipal;
    @AuraEnabled public Decimal DebitNoteTax;
    @AuraEnabled public Decimal CreditNoteTax;
    @AuraEnabled public Decimal ReversalDebitNotePrincipal;
    @AuraEnabled public Decimal ReversalCreditNotePrincipal;
    @AuraEnabled public Decimal ReversalDebitNoteTax;
    @AuraEnabled public Decimal ReversalCreditNoteTax;
    @AuraEnabled public Decimal TotalInterestAccured;
    @AuraEnabled public Decimal InterestWaiver;
    @AuraEnabled public Decimal TotalInterestCharged;
    @AuraEnabled public Decimal BrokerageWaiver;
    @AuraEnabled public Decimal TotalBrokerageCharged;
    @AuraEnabled public Decimal OtherAdjustments;
    @AuraEnabled public Decimal ForfeitAmount;
    @AuraEnabled public Decimal TotalRecievedAmount;
    @AuraEnabled public Decimal TotalAmountCharged;
    @AuraEnabled public Decimal TotalRefundGiven;
    @AuraEnabled public Decimal TDSAmount;
    @AuraEnabled public Decimal DownPayAmtPrincipal;
    @AuraEnabled public Decimal RevDownPayAmtPrincipal;
    @AuraEnabled public Decimal RevDownPayAmtTax;
    @AuraEnabled public Decimal DownPayAmtTax;
    @AuraEnabled public Decimal DownPayAmtCTC;
    @AuraEnabled public Decimal DemandAmtCTC;
    @AuraEnabled public Decimal CreditNoteCTC;
    @AuraEnabled public Decimal DebitNoteCTC;
    }
}