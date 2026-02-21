@RestResource(urlMapping='/UpdatePaymentReceiptStatus/*')
global without sharing class EYI_PaymentReceipt {
    
    global class CustomResponse {
        public String id;
        // public String sapExternalId;
        public Boolean success;
        public String message;
        //public List<String> errors;
        
        public CustomResponse(String id, Boolean success, String message) {
            this.id = id;
            //this.sapExternalId = sapExternalId;
            this.success = success;
            this.message = message;
            //this.errors = errors;
        }
    }
    
    @HttpPatch
    global static List<CustomResponse> createPaymentReceipts(){
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        List<EYI_Payment_Receipt__c> recordsToInsertOrUpdate = new List<EYI_Payment_Receipt__c>();
        System.debug('requestBody ==> ' + requestBody);
        
        List<CustomResponse> responses = new List<CustomResponse>(); // List to hold responses for each record
        
        try{
            EYI_PaymentReceitStatusWrapper paymentReceiptRequest = (EYI_PaymentReceitStatusWrapper)JSON.deserialize(requestBody, EYI_PaymentReceitStatusWrapper.class);
            List<EYI_PaymentReceitStatusWrapper.PaymentWrapper> payment = paymentReceiptRequest.ReceiptStatus;
            for (EYI_PaymentReceitStatusWrapper.PaymentWrapper paymentReceipt : payment){
                system.debug('insidefor-->116');
                EYI_Payment_Receipt__c record = new EYI_Payment_Receipt__c(
                    EYI_Receivable_Desk_Tracking_Number__c = paymentReceipt.ReceivableDeskTrackingNumber,
                    EYI_Receivable_Desk_Document_Version__c = (paymentReceipt.ReceivableDeskDocumentVersion !=null && paymentReceipt.ReceivableDeskDocumentVersion != '')? Decimal.valueOf(paymentReceipt.ReceivableDeskDocumentVersion) : 0,
                    EYI_SAP_Company_Code__c = paymentReceipt.SapCompanyCode,
                    EYI_House_Bank__c = paymentReceipt.HouseBank,            
                    EYI_Account_ID__c = paymentReceipt.AccountId,
                    EYI_Short_Key__c = (paymentReceipt.ShortKey !=null && paymentReceipt.ShortKey != '')? Decimal.valueOf(paymentReceipt.ShortKey) : 0,
                    EYI_G_L_Account__c = paymentReceipt.GlAccount,
                    EYI_Statement_Number__c = (paymentReceipt.StatementNumber !=null && paymentReceipt.StatementNumber != '')? Decimal.valueOf(paymentReceipt.StatementNumber) : 0,
                    EYI_Memo_Record_Number__c = (paymentReceipt.MemoRecordNumber !=null && paymentReceipt.MemoRecordNumber != '')? Decimal.valueOf(paymentReceipt.MemoRecordNumber) : 0,
                    EYI_Business_Trans_Code__c = paymentReceipt.BusinessTransCode,
                    EYI_SAP_Transaction__c = paymentReceipt.SapTransaction,
                    EYI_Payment_Confirmed_Amount_From_SAP__c = paymentReceipt.PaymentConfirmedAmountFromSAP,
                    EYI_Account_Type__c = paymentReceipt.AccountType,
                    EYI_Account__c = paymentReceipt.Account,
                    EYI_SAP_Document_Number__c = paymentReceipt.SapDocumentNumber,
                    EYI_Fiscal_Year__c = (paymentReceipt.FiscalYear !=null && paymentReceipt.FiscalYear != '')? Decimal.valueOf(paymentReceipt.FiscalYear) : 0,
                    EYI_Is_Reversed__c = (paymentReceipt.IsReversed !=null && paymentReceipt.IsReversed!= '')? Decimal.valueOf(paymentReceipt.IsReversed) : 0,	
                    EYI_Company_Name__c = paymentReceipt.CompanyName,
                    EYI_Reference__c = paymentReceipt.Reference,
                    EYI_Assignment__c = paymentReceipt.Assignment,
                    EYI_Check_number__c = paymentReceipt.Checknumber,
                    EYI_Department_ID__c = paymentReceipt.DepartmentID,
                    EYI_Department_Name__c = paymentReceipt.DepartmentName,
                    EYI_Description__c = paymentReceipt.Description,
                    EYI_Site__c = paymentReceipt.Site,
                    EYI_Site_Name__c = paymentReceipt.SiteName,
                    EYI_Payment_Status__c = paymentReceipt.PaymentStatus,
                    EYI_SAP_Customer_Name__c = paymentReceipt.SapCustomerNumber,
                    EYI_SAP_Customer_Number__c = paymentReceipt.SapCustomerName,
                    EYI_SAP_Payment_Advice_Number__c = paymentReceipt.SapPaymentAdviceNumber,
                    EYI_Initial_Remark__c = paymentReceipt.InitialRemark,
                    EYI_Attachment_Remark__c = paymentReceipt.AttachmentRemark,
                    EYI_Attached_By__c = paymentReceipt.AttachedBy,
                    EYI_DMS_Doc_Type__c = paymentReceipt.DmsDocType,
                    EYI_DMS_Doc_Part__c = paymentReceipt.DmsDocPart,
                    EYI_DMS_Doc_No__c = paymentReceipt.DmsDocNo,
                    EYI_SAP_Reason_Code__c = paymentReceipt.SapReasonCode,
                    EYI_SAP_Reason_Description__c = paymentReceipt.SapReasonDescription,
                    EYI_SAP_Rejection_Hold_Remark__c = paymentReceipt.SapRejectionHoldRemarks,
                    EYI_Delay_WRT_Creation__c = paymentReceipt.DelayWRTCreation,
                    EYI_SAP_BRS_Document_Number__c = paymentReceipt.SapBRSDocumentNumber,
                    EYI_Processed_By__c = paymentReceipt.ProcessedBy,
                    EYI_Recv_Desk_Approved_By__c = paymentReceipt.RecvDeskApprovedBy,
                    EYI_Recv_Desk_Approved_By_Name__c = paymentReceipt.RecvDeskApprovedByName,
                    EYI_Recv_Desk_Changed_By__c = paymentReceipt.RecvDeskChangedBy,
                    EYI_Recv_Desk_Created_By__c = paymentReceipt.RecvDeskCreatedBy,
                    EYI_Recv_Desk_Created_By_Name__c = paymentReceipt.RecvDeskCreatedByName,
                    EYI_Recv_Desk_Created_Date__c = paymentReceipt.RecvDeskCreatedDate,
                    EYI_Recv_Desk_Processed_By__c = paymentReceipt.RecvDeskProcessedBy,
                    EYI_Recv_Desk_Changed_By_Name__c = paymentReceipt.RecvDeskChangedByName,
                    EYI_SAP_Sync_Date__c = System.now(),
                    
                    EYI_Bank_Payment_Confirmation_Date__c = String.isBlank(paymentReceipt.BankPaymentConfirmationDate) ? null : Date.valueOf(paymentReceipt.BankPaymentConfirmationDate),
                    EYI_Statement_Date__c = String.isBlank(paymentReceipt.StatementDate) ? null : Date.valueOf(paymentReceipt.StatementDate),
                    EYI_Change_Remark__c = String.isBlank(paymentReceipt.ChangeRemark) ? null : Date.valueOf(paymentReceipt.ChangeRemark),
                    EYI_Attached_On__c = String.isBlank(paymentReceipt.AttachedOn) ? null : Date.valueOf(paymentReceipt.AttachedOn),
                    EYI_Bank_Posting_Date__c = String.isBlank(paymentReceipt.BankPostingDate) ? null : Date.valueOf(paymentReceipt.BankPostingDate),
                    EYI_Recv_Desk_Approved_Date__c = String.isBlank(paymentReceipt.RecvDeskApprovedDate) ? null : Date.valueOf(paymentReceipt.RecvDeskApprovedDate),
                    EYI_Recv_Desk_Changed_On__c = String.isBlank(paymentReceipt.RecvDeskChangedOn) ? null : Date.valueOf(paymentReceipt.RecvDeskChangedOn),
                    EYI_Recv_Desk_Processed_Date__c = String.isBlank(paymentReceipt.RecvDeskProcessedDate) ? null : Date.valueOf(paymentReceipt.RecvDeskProcessedDate),
                    
                    EYI_Attached_At__c = String.isBlank(paymentReceipt.AttachedAt) ? null : Time.newInstance(
                        Integer.valueOf(paymentReceipt.AttachedAt.split(':')[0]),
                        Integer.valueOf(paymentReceipt.AttachedAt.split(':')[1]),
                        Integer.valueOf(paymentReceipt.AttachedAt.split(':')[2]),
                        0
                    ),
                    EYI_Recv_Desk_Approved_Time__c = String.isBlank(paymentReceipt.RecvDeskApprovedTime) ? null : Time.newInstance(
                        Integer.valueOf(paymentReceipt.RecvDeskApprovedTime.split(':')[0]),
                        Integer.valueOf(paymentReceipt.RecvDeskApprovedTime.split(':')[1]),
                        Integer.valueOf(paymentReceipt.RecvDeskApprovedTime.split(':')[2]),
                        0
                    ),
                    EYI_Recv_Desk_Changed_Time__c = String.isBlank(paymentReceipt.RecvDeskChangedTime) ? null : Time.newInstance(
                        Integer.valueOf(paymentReceipt.RecvDeskChangedTime.split(':')[0]),
                        Integer.valueOf(paymentReceipt.RecvDeskChangedTime.split(':')[1]),
                        Integer.valueOf(paymentReceipt.RecvDeskChangedTime.split(':')[2]),
                        0
                    ),
                    EYI_Recv_Desk_Created_Time__c = String.isBlank(paymentReceipt.RecvDeskCreatedTime) ? null : Time.newInstance(
                        Integer.valueOf(paymentReceipt.RecvDeskCreatedTime.split(':')[0]),
                        Integer.valueOf(paymentReceipt.RecvDeskCreatedTime.split(':')[1]),
                        Integer.valueOf(paymentReceipt.RecvDeskCreatedTime.split(':')[2]),
                        0
                    ),
                    EYI_Recv_Desk_Processed_Time__c = String.isBlank(paymentReceipt.RecvDeskProcessedTime) ? null : Time.newInstance(
                        Integer.valueOf(paymentReceipt.RecvDeskProcessedTime.split(':')[0]),
                        Integer.valueOf(paymentReceipt.RecvDeskProcessedTime.split(':')[1]),
                        Integer.valueOf(paymentReceipt.RecvDeskProcessedTime.split(':')[2]),
                        0
                    )
                    
                    
                    
                );
                    system.debug('recordsToInsertOrUpdate'+ recordsToInsertOrUpdate);
                    recordsToInsertOrUpdate.add(record);
            }
            
            
            // Perform bulk DML operation (insert or update)
            List<Database.UpsertResult> results;
            Schema.SObjectField externalIdField = EYI_Payment_Receipt__c.EYI_SAP_Payment_Advice_Number__c;
            
            results = Database.upsert(recordsToInsertOrUpdate,externalIdField, false);
            system.debug('results ==> '+results);
            
            
            
            
            
            // Iterate through each result to construct the response
            for (Integer i = 0; i < results.size(); i++) {
                Database.UpsertResult result = results[i];
                if (result.isSuccess()) {
                    // Success response for each record
                    String successMessage = result.isCreated() ? 'Record was successfully created.' : 'Record was successfully updated.';
                    if(result.isCreated()){
                        responses.add(new CustomResponse(
                            result.getId(),
                            true,
                            successMessage
                        ));                            
                    }else{
                        responses.add(new CustomResponse(
                            result.getId(),
                            true,
                            successMessage
                        ));                            
                    }
                    
                } else {
                    // Error response for each record
                    String errorMessage;
                    for (Database.Error err : result.getErrors()) {
                        if(err.getMessage() == 'EYI_SAP_Payment_Advice_Number__c not specified'){
                            errorMessage = System.label.Payment_Receipt_Error;
                        }else{
                            errorMessage = err.getMessage();
                        }
                        
                        
                    }
                    responses.add(new CustomResponse(
                        null,
                        false,
                        errorMessage
                        
                    ));
                }
            }
        } catch (Exception e) {
            // General error response if an exception occurs
            //String errorMessage = e.getMessage();
            
            responses.add(new CustomResponse(
                null,
                false,
                e.getMessage()
                
            ));
        }
        system.debug('responses -> '+responses);
        system.debug('serialized responses -> '+JSON.serialize(responses));
        // Serialize the list of responses and return it
        return responses;
        
        
    }
    
    
    
    
}