public class EYI_CancellationMasterSyncLwcController {
    
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
        Case cancellationDetails = [SELECT Id,EYI_Opportunity__c,EYI_Opportunity__r.EYI_SAP_Customer_Number__c,EYI_Cancellation_Type__c,EYI_Cancellation_Reason__c,EYI_Payment_Done__c,EYI_Reversal_to_Customer__c,
                                                          EYI_Cancellation_Subtype__c,EYI_Cancellation_Remarks__c,EYI_Date_of_Cancellation_initiated__c,
                                                          EYI_Cancellation_Status__c,EYI_Cancellation_Commencement__c,EYI_Registration_Status__c,
                                                          EYI_Opportunity__r.SyncedQuote.EYI_Agreement_Value__c,
                                                          EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c,EYI_Opportunity__r.EYI_SalesOrder_Number__c,
                                                          EYI_Opportunity__r.SyncedQuote.TotalPrice,EYI_Opportunity__r.EYI_Walk_in_Source__c,
                                                          EYI_Opportunity__r.SyncedQuote.Stamp_Duty__c,EYI_Opportunity__r.EYI_REC__r.Name,
                                                          EYI_Opportunity__r.EYI_REC__r.EYI_REC_Vendor_Code__c,EYI_Opportunity__r.EYI_REC__r.EYI_RERA_Certificate_No__c,
                                                          EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c,EYI_Retained_by_User__r.Name,
                                                          EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name,EYI_Opportunity__r.EYI_Relationship_Manager__r.Name,
                                                          EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name,
                                                          EYI_Opportunity__r.EYI_Registration_Status__c,EYI_Demanded_Amount_Principal__c,
                                                          EYI_Reversal_Demanded_Amount_Principal__c,
                                                          EYI_Refund_Amount_Principal__c,EYI_Demanded_Amount_Tax__c,
                                                          EYI_Paid_Amount_Principal__c,
                                                          EYI_Paid_Amount_Tax__c,EYI_Refund_Amount_Tax__c,
                                                          EYI_Brokerage_Amount__c,EYI_Debit_Note_Principal__c,EYI_Credit_Note_Principal__c,
                                                          EYI_Debit_Note_Tax__c,EYI_Credit_Note_Tax__c,EYI_Reversal_Debit_Note_Principal__c,
                                                          EYI_Reversal_Credit_Note_Principal__c,EYI_Reversal_Debit_Note_Tax__c,EYI_Reversal_Credit_Note_Tax__c,
                                                          EYI_Total_Interest_Accured__c,EYI_Interest_Waiver__c,EYI_Total_Interest_Charged__c,
                                                          EYI_Brokerage_Waiver__c,EYI_Total_Brokerage_Charged__c,
                                                          EYI_Other_Adjustments__c,EYI_Forfeit_Amount__c,EYI_Total_Received_Amount__c,
                                                          EYI_TotalAmountCharged__c,EYI_Total_Refund_Given__c,EYI_Reversal_Demanded_Amount_Tax__c,
                                                          EYI_Down_Payment_Amount_Principal__c,EYI_Down_Payment_Amount_Tax__c,
                                                          EYI_Down_Payment_Amt_Charged_To_Customer__c,EYI_Reversal_Down_Payment_Amt_Principal__c,
                                                          EYI_Reversal_Down_Payment_Amt_Tax__c,EYI_Demand_Amount_Charged_to_Customer__c,
                                                          EYI_Credit_Note_Charged_to_Customer__c,EYI_Debit_Note_Charged_to_Customer__c,EYI_TDS_Amount__c,
                                                          EYI_Forfeiture_Remarks__c,EYI_Brokerage_Charged_Remarks__c,EYI_Interest_Charged_Remarks__c,EYI_Adjustment_Remarks__c
                                                          from Case
                                                          Where Id=:recordId];

        
          if(cancellationDetails!= null){
            try{
               List<Quote> quoteList = [Select id,EYI_Agreement_Value__c,Stamp_Duty__c,TotalPrice from Quote where OpportunityId =:cancellationDetails.EYI_Opportunity__c];
                //Mrinal change starts -> Required fields missing
                String reqFieldError = System.Label.EYI_Cust_Sync_Req_field_Error;
                reqFieldError+=' Opportunity : ';
                //Cancellation Details
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Type__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Type__c, ';
                }else{
                    data.CancellationType = cancellationDetails.EYI_Cancellation_Type__c;
                }
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Subtype__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Subtype__c, ';
                }else{
                    data.CancellationSubtype = cancellationDetails.EYI_Cancellation_Subtype__c;
                }
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Reason__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Reason__c, ';
                }else{
                    data.CancellationReason = cancellationDetails.EYI_Cancellation_Reason__c;
                }
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Status__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Status__c, ';
                }else{
                    data.CancellationStatus = cancellationDetails.EYI_Cancellation_Status__c;
                }
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Commencement__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Commencement__c, ';
                }else{
                    data.CancellationCommencement = cancellationDetails.EYI_Cancellation_Commencement__c;
                }
                if (String.isBlank(cancellationDetails.EYI_Cancellation_Remarks__c)) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Cancellation_Remarks__c, ';
                }else{
                    data.CancellationRemarks = cancellationDetails.EYI_Cancellation_Remarks__c;
                } 
                if (cancellationDetails.EYI_Date_of_Cancellation_initiated__c == null) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Date_of_Cancellation_initiated__c, ';
                }else{
                    data.DateOfCancellationInitiated = cancellationDetails.EYI_Date_of_Cancellation_initiated__c;
                }
                if(String.isBlank(cancellationDetails.EYI_Retained_by_User__r.Name)){
                    reqFieldError += 'EYI_Retained_by_User__r.Name, ';
                }else{
                    data.RetainedByUser = cancellationDetails.EYI_Retained_by_User__r.Name; 
                }

               /*** SAP Fields Mapping Start **/
               //Receipts Approved
               if (String.isBlank(String.valueOf(cancellationDetails.EYI_Payment_Done__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Payment_Done__c, ';
                }else{
                    data.PaidAmountPrincipal = cancellationDetails.EYI_Payment_Done__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_to_Customer__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_to_Customer__c, ';
                }else{
                    data.RefundAmountPrincipal = cancellationDetails.EYI_Reversal_to_Customer__c;
                }

                //Demanded Amount
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Demanded_Amount_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Demanded_Amount_Principal__c, ';
                }else{
                    data.DemandAmtPrincipal = cancellationDetails.EYI_Demanded_Amount_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Demanded_Amount_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Demanded_Amount_Principal__c, ';
                }else{
                    data.RevDemandAmtPrincipal = cancellationDetails.EYI_Reversal_Demanded_Amount_Principal__c;
                }  
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Demanded_Amount_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Demanded_Amount_Tax__c, ';
                }else{
                    data.DemandAmtTax = cancellationDetails.EYI_Demanded_Amount_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Demanded_Amount_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Demanded_Amount_Tax__c, ';
                }else{
                    data.RevDemandAmtTax = cancellationDetails.EYI_Reversal_Demanded_Amount_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Demand_Amount_Charged_to_Customer__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Demand_Amount_Charged_to_Customer__c, ';
                }else{
                    data.DemandAmtCTC = cancellationDetails.EYI_Demand_Amount_Charged_to_Customer__c;
                }

                //Down Payment Amount
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Down_Payment_Amount_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Down_Payment_Amount_Principal__c, ';
                }else{
                    data.DownPayAmtPrincipal = cancellationDetails.EYI_Down_Payment_Amount_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Down_Payment_Amt_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Down_Payment_Amt_Principal__c, ';
                }else{
                    data.RevDownPayAmtPrincipal = cancellationDetails.EYI_Reversal_Down_Payment_Amt_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Down_Payment_Amount_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Down_Payment_Amount_Tax__c, ';
                }else{
                    data.DownPayAmtTax = cancellationDetails.EYI_Down_Payment_Amount_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Down_Payment_Amt_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Down_Payment_Amt_Tax__c, ';
                }else{
                    data.RevDownPayAmtTax = cancellationDetails.EYI_Reversal_Down_Payment_Amt_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Down_Payment_Amt_Charged_To_Customer__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Down_Payment_Amt_Charged_To_Customer__c, ';
                }else{
                    data.DownPayAmtCTC = cancellationDetails.EYI_Down_Payment_Amt_Charged_To_Customer__c;
                }

                //Other Debit Notes
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Debit_Note_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Debit_Note_Principal__c, ';
                }else{
                    data.DebitNotePrincipal = cancellationDetails.EYI_Debit_Note_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Debit_Note_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Debit_Note_Principal__c, ';
                }else{
                    data.ReversalDebitNotePrincipal = cancellationDetails.EYI_Reversal_Debit_Note_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Debit_Note_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Debit_Note_Tax__c, ';
                }else{
                    data.DebitNoteTax = cancellationDetails.EYI_Debit_Note_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Debit_Note_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Debit_Note_Tax__c, ';
                }else{
                    data.ReversalDebitNoteTax = cancellationDetails.EYI_Reversal_Debit_Note_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Debit_Note_Charged_to_Customer__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Debit_Note_Charged_to_Customer__c, ';
                }else{
                    data.DebitNoteCTC = cancellationDetails.EYI_Debit_Note_Charged_to_Customer__c;
                }
                
                //Other Credit Notes
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Credit_Note_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Credit_Note_Principal__c, ';
                }else{
                    data.CreditNotePrincipal = cancellationDetails.EYI_Credit_Note_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Credit_Note_Principal__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Credit_Note_Principal__c, ';
                }else{
                    data.ReversalCreditNotePrincipal = cancellationDetails.EYI_Reversal_Credit_Note_Principal__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Credit_Note_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Credit_Note_Tax__c, ';
                }else{
                    data.CreditNoteTax = cancellationDetails.EYI_Credit_Note_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Reversal_Credit_Note_Tax__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Reversal_Credit_Note_Tax__c, ';
                }else{
                    data.ReversalCreditNoteTax = cancellationDetails.EYI_Reversal_Credit_Note_Tax__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Credit_Note_Charged_to_Customer__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Credit_Note_Charged_to_Customer__c, ';
                }else{
                    data.CreditNoteCTC = cancellationDetails.EYI_Credit_Note_Charged_to_Customer__c;
                }

                //Interest charged to customer
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Total_Interest_Accured__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Total_Interest_Accured__c, ';
                }else{
                    data.TotalInterestAccured = cancellationDetails.EYI_Total_Interest_Accured__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Interest_Waiver__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Interest_Waiver__c, ';
                }else{
                    data.InterestWaiver = cancellationDetails.EYI_Interest_Waiver__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Total_Interest_Charged__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Total_Interest_Charged__c, ';
                }else{
                    data.TotalInterestCharged = cancellationDetails.EYI_Total_Interest_Charged__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Interest_Charged_Remarks__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Interest_Charged_Remarks__c, ';
                }else{
                    data.InterestChargedRemarks = cancellationDetails.EYI_Interest_Charged_Remarks__c;
                }


                //Brokerage Amount
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Brokerage_Amount__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Brokerage_Amount__c, ';
                }else{
                    data.BrokerageAmount = cancellationDetails.EYI_Brokerage_Amount__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Brokerage_Waiver__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Brokerage_Waiver__c, ';
                }else{
                    data.BrokerageWaiver = cancellationDetails.EYI_Brokerage_Waiver__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Total_Brokerage_Charged__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Total_Brokerage_Charged__c, ';
                }else{
                    data.TotalBrokerageCharged = cancellationDetails.EYI_Total_Brokerage_Charged__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Brokerage_Charged_Remarks__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Brokerage_Charged_Remarks__c, ';
                }else{
                    data.BrokerageChargedRemarks = cancellationDetails.EYI_Brokerage_Charged_Remarks__c;
                }

                //Other Adjustments
                 if (String.isBlank(String.valueOf(cancellationDetails.EYI_Other_Adjustments__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Other_Adjustments__c, ';
                }else{
                    data.OtherAdjustments = cancellationDetails.EYI_Other_Adjustments__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Adjustment_Remarks__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Adjustment_Remarks__c, ';
                }else{
                    data.AdjustmentRemarks = cancellationDetails.EYI_Adjustment_Remarks__c;
                }
                
                //Forfeiture Amount
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Forfeit_Amount__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Forfeit_Amount__c, ';
                }else{
                    data.ForfeitAmount = cancellationDetails.EYI_Forfeit_Amount__c;
                }
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Forfeiture_Remarks__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Forfeiture_Remarks__c, ';
                }else{
                    data.ForfeitureRemarks = cancellationDetails.EYI_Forfeiture_Remarks__c;
                }
                
                //Main Hearder
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_Total_Received_Amount__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_Total_Received_Amount__c, ';
                }else{
                    data.TotalRecievedAmount = cancellationDetails.EYI_Total_Received_Amount__c;
                }
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
                if (String.isBlank(String.valueOf(cancellationDetails.EYI_TDS_Amount__c))) {
                    lm.type = 'e';
                    reqFieldError += 'EYI_TDS_Amount__c, ';
                }else{
                    data.TDSAmount = cancellationDetails.EYI_TDS_Amount__c;
                }

                // Checking EYI_Opportunity__r lookup fields
                if (cancellationDetails.EYI_Opportunity__r != null) {
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_SAP_Customer_Number__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_SAP_Customer_Number__c, ';
                    }else{
                        data.SapCustomerNo = cancellationDetails.EYI_Opportunity__r.EYI_SAP_Customer_Number__c;
                    }
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Registration_Status__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_Registration_Status__c, ';
                    }else{
                        data.RegistrationStatus = cancellationDetails.EYI_Opportunity__r.EYI_Registration_Status__c;
                    }
                    
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Walk_in_Source__c)) {
                    	lm.type = 'e';
                    	reqFieldError += 'EYI_Walk_in_Source__c, ';
                    }else{
                        data.BookingSource = cancellationDetails.EYI_Opportunity__r.EYI_Walk_in_Source__c;
                    }
                    
                    if (String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_SalesOrder_Number__c)) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_SalesOrder_Number__c, ';
                    }else{
                        data.SalesOrderNo = cancellationDetails.EYI_Opportunity__r.EYI_SalesOrder_Number__c;
                    }
                    
                    if (String.isBlank(String.valueOf(cancellationDetails.EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c))) {
                        lm.type = 'e';
                        reqFieldError += 'EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c, ';
                    }else{
                        data.BrokerageTotalAmount  = cancellationDetails.EYI_Opportunity__r.EYI_Total_Brokerage_Amount_Paid__c;
                    }
                    //sourcing Manager
                    //if(cancellationDetails.EYI_Opportunity__r.EYI_Sourcing_Manager__r != null){
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name)){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name, ';
                        }else{
                           data.SourcingManager = cancellationDetails.EYI_Opportunity__r.EYI_Sourcing_Manager__r.Name; 
                        }
                	//}
                    //Relationship Manager
                   // if(cancellationDetails.EYI_Opportunity__r.EYI_Relationship_Manager__r != null){
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Relationship_Manager__r.Name)){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Opportunity__r.EYI_Relationship_Manager__r.Name, ';
                        }else{
                           data.RelationshipManager = cancellationDetails.EYI_Opportunity__r.EYI_Relationship_Manager__r.Name; 
                        }
                	//}
                    //primary Manager
                    //if(cancellationDetails.EYI_Opportunity__r.EYI_Primary_Closing_Manager__r != null){
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name)){
                            lm.type = 'e';
                            reqFieldError += 'EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name, ';
                        }else{
                           data.ClosingManager = cancellationDetails.EYI_Opportunity__r.EYI_Primary_Closing_Manager__r.Name;
                        }
                	//}
                    
                     // Checking SyncedQuote lookup fields 
                    if (!quoteList.isEmpty()) {
                        if (String.isBlank(String.valueOf(quoteList[0].EYI_Agreement_Value__c))) {
                            lm.type = 'e';
                            reqFieldError += 'SyncedQuote.EYI_Agreement_Value__c, ';
                        }else{
                            data.AgreementValue = quoteList[0].EYI_Agreement_Value__c;
                        }
                        
                        if (String.isBlank(String.valueOf(quoteList[0].TotalPrice))) {
                            lm.type = 'e';
                            reqFieldError += 'SyncedQuote.TotalPrice, ';
                        }else{
                            data.TotalCost = quoteList[0].TotalPrice;
                        }
                        
                        if(String.isBlank(String.valueOf(quoteList[0].Stamp_Duty__c))){
                            lm.type = 'e';
                            reqFieldError += 'SyncedQuote.Stamp_Duty__c, ';
                        }else{
                           data.StampDuty = quoteList[0].Stamp_Duty__c; 
                        }
                    }
    
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
                        
                        /*if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_REC_Code__c)){
                            lm.type = 'e';
                           reqFieldError += 'EYI_REC__r.EYI_REC_Code__c, '; 
                        }else{*/
                            data.RecCode = cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_REC_Vendor_Code__c;
                        //}
                        if(String.isBlank(cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_RERA_Certificate_No__c)){
                            lm.type = 'e';
                           reqFieldError += 'EYI_REC__r.EYI_RERA_Certificate_No__c, '; 
                        }else{
                            data.ReraNumber = cancellationDetails.EYI_Opportunity__r.EYI_REC__r.EYI_RERA_Certificate_No__c;
                        }
                    }
                    Set<Id> actorIds = new Set<Id>();
for (ProcessInstance pi : approvalProcesses) {
    for (ProcessInstanceStep step : pi.Steps) {
        if (step.ActorId != null) {
            actorIds.add(step.ActorId);
        }
    }
}

// 3. Query User map for Id -> Name
Map<Id, User> userMap = new Map<Id, User>([
    SELECT Id, Name FROM User WHERE Id IN :actorIds
]);

// 4. Iterate steps and assign to your variables
Integer count = 1;

// Assuming this code is inside your AuraEnabled class, you can do:

for (ProcessInstance pi : approvalProcesses) {
    for (ProcessInstanceStep step : pi.Steps) {
        if (count > 5) break;

        String approverName = userMap.containsKey(step.ActorId) ? userMap.get(step.ActorId).Name : 'Unknown';
        Date approvedOnDate = step.CreatedDate.date();
        Time approvedOnTime = Time.newInstance(step.CreatedDate.hour(), step.CreatedDate.minute(), step.CreatedDate.second(), step.CreatedDate.millisecond());
        String approvalAction = step.StepStatus;
        String approvalRemark = step.Comments;

        if (count == 1) {
            data.CancellationApproverL1 = approverName;
            data.L1RequestApprovedOn = approvedOnDate;
            data.L1RequestApprovedAt = approvedOnTime;
            data.L1RequestApprovedAction = approvalAction;
            data.L1RequestApprovedRemark = approvalRemark;
        } else if (count == 2) {
            data.CancellationApproverL2 = approverName;
            data.L2RequestApprovedOn = approvedOnDate;
            data.L2RequestApprovedAt = approvedOnTime;
            data.L2RequestApprovedAction = approvalAction;
            data.L2RequestApprovedRemark = approvalRemark;
        } else if (count == 3) {
            data.CancellationApproverL3 = approverName;
            data.L3RequestApprovedOn = approvedOnDate;
            data.L3RequestApprovedAt = approvedOnTime;
            data.L3RequestApprovedAction = approvalAction;
            data.L3RequestApprovedRemark = approvalRemark;
        } else if (count == 4) {
            data.CancellationApproverL4 = approverName;
            data.L4RequestApprovedOn = approvedOnDate;
            data.L4RequestApprovedAt = approvedOnTime;
            data.L4RequestApprovedAction = approvalAction;
            data.L4RequestApprovedRemark = approvalRemark;
        } else if (count == 5) {
            data.CancellationApproverL5 = approverName;
            data.L5RequestApprovedOn = approvedOnDate;
            data.L5RequestApprovedAt = approvedOnTime;
            data.L5RequestApprovedAction = approvalAction;
            data.L5RequestApprovedRemark = approvalRemark;
        }

        count++;
    }
    if (count > 5) break;
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
                    //String filterString = JSON.serialize(data);
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

    // Date and Time Fields
    @AuraEnabled public Date DateOfCancellationInitiated;
    @AuraEnabled public Date FinalCancellationApprovedOn;
    @AuraEnabled public Time FinalCancellationApprovedAt;

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
    @AuraEnabled public Decimal DownPayAmtPrincipal;
    @AuraEnabled public Decimal RevDownPayAmtPrincipal;
    @AuraEnabled public Decimal DownPayAmtTax;
    @AuraEnabled public Decimal RevDownPayAmtTax;
    @AuraEnabled public Decimal DownPayAmtCTC;
    @AuraEnabled public Decimal DemandAmtCTC;
    @AuraEnabled public Decimal CreditNoteCTC;
    @AuraEnabled public Decimal DebitNoteCTC;
    @AuraEnabled public Decimal TDSAmount;
    @AuraEnabled public String CancellationApproverL1;
    @AuraEnabled public String CancellationApproverL2;
    @AuraEnabled public String CancellationApproverL3;
    @AuraEnabled public String CancellationApproverL4;
    @AuraEnabled public String CancellationApproverL5;
    @AuraEnabled public Date L1RequestApprovedOn;
    @AuraEnabled public Date L2RequestApprovedOn;
    @AuraEnabled public Date L3RequestApprovedOn;
    @AuraEnabled public Date L4RequestApprovedOn;
    @AuraEnabled public Date L5RequestApprovedOn;
    @AuraEnabled public Time L1RequestApprovedAt;
    @AuraEnabled public Time L2RequestApprovedAt;
    @AuraEnabled public Time L3RequestApprovedAt;
    @AuraEnabled public Time L4RequestApprovedAt;
    @AuraEnabled public Time L5RequestApprovedAt;
    @AuraEnabled public String L1RequestApprovedAction;
    @AuraEnabled public String L2RequestApprovedAction;
    @AuraEnabled public String L3RequestApprovedAction;
    @AuraEnabled public String L4RequestApprovedAction;
    @AuraEnabled public String L5RequestApprovedAction;
    @AuraEnabled public String L1RequestApprovedRemark;
    @AuraEnabled public String L2RequestApprovedRemark;
    @AuraEnabled public String L3RequestApprovedRemark;
    @AuraEnabled public String L4RequestApprovedRemark;
    @AuraEnabled public String L5RequestApprovedRemark;
    @AuraEnabled public String InterestChargedRemarks;
    @AuraEnabled public String BrokerageChargedRemarks;
    @AuraEnabled public String AdjustmentRemarks;
    @AuraEnabled public String ForfeitureRemarks;
	}
}