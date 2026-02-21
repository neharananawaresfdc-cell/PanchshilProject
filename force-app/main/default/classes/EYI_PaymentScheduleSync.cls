@RestResource(urlMapping='/PaymentScheduleSync/*')
    global class EYI_PaymentScheduleSync {
        public  static Map<String,Id>  projectMap{get; set;}
        public  static Map<String,Id>  towerMap{get; set;}
        global class PaymentSchedule {
            public String SFDCId;
            public String Milestone;
            public String SAPSalesOrg;
            public String SAPPlantCode;
            public String SAPActivityNumber;
            public String Usage;
            public String UsageDescription;
            public String WBSElement;
            public String BillingDate;
            public String ActualDate;
            public String InvoicePercentage;
        }
        
        global class PaymentScheduleRequest {
            public List<PaymentSchedule> PaymentScheduleSync;
        }
        
        global class CustomResponse {
            public String id;
            public String sapExternalId;
            public Boolean success;
            public String message;
            //public List<String> errors;
            
            public CustomResponse(String id, String sapExternalId,  Boolean success, String message) {
                this.id = id;
                this.sapExternalId = sapExternalId;
                this.success = success;
                this.message = message;
                //this.errors = errors;
            }
        }
        
        @HttpPost
        global static List<CustomResponse> syncPaymentSchedules() {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String requestBody = req.requestBody.toString();
            String sapExternalId;
            System.debug('requestBody ==> ' + requestBody);
            List<CustomResponse> responses = new List<CustomResponse>(); // List to hold responses for each record
            projectMap= new Map<String,Id>();
            towerMap= new Map<String,Id>();

            try {
                // Deserialize the JSON request body into a custom request class
                PaymentScheduleRequest paymentScheduleRequest = (PaymentScheduleRequest)JSON.deserialize(requestBody, PaymentScheduleRequest.class);
                List<PaymentSchedule> paymentSchedules = paymentScheduleRequest.PaymentScheduleSync;
                Set<String> plantCodeSet =  new Set<String>();
                Set<String> sapOrgSet =  new Set<String>();

                for (PaymentSchedule paymentSchedule : paymentSchedules) {
                    plantCodeSet.add(paymentSchedule.SAPPlantCode);
                    sapOrgSet.add(paymentSchedule.SAPSalesOrg);
                }

                for(EYI_Project__c  projectobj : [select id ,EYI_SAP_Salesorg__c from EYI_Project__c where EYI_SAP_Salesorg__c in:sapOrgSet]){
                    projectMap.put(projectobj.EYI_SAP_Salesorg__c,projectobj.Id);
                }
                for(EYI_Tower__c  twrobj : [select id ,EYI_SAP_Plant_ID__c from EYI_Tower__c Where EYI_SAP_Plant_ID__c in :plantCodeSet]){
                    towerMap.put(twrobj.EYI_SAP_Plant_ID__c,twrobj.Id);
                }

                List<EYI_Payment_Schedule__c> recordsToInsertOrUpdate = new List<EYI_Payment_Schedule__c>();
                for (PaymentSchedule paymentSchedule : paymentSchedules) {
                    EYI_Payment_Schedule__c record = new EYI_Payment_Schedule__c(
                        EYI_SAP_Milestone_Code__c = (paymentSchedule.Milestone != null && paymentSchedule.SAPActivityNumber != null) ? paymentSchedule.Milestone + paymentSchedule.SAPActivityNumber : null,
                        EYI_Milestone_Number__c = (paymentSchedule.Milestone != null && paymentSchedule.Milestone != '') ? Decimal.valueOf(paymentSchedule.Milestone) : null,
                        EYI_SAP_Sales_Org__c = paymentSchedule.SAPSalesOrg,
                        EYI_SAP_Plant_Code__c = paymentSchedule.SAPPlantCode,
                        EYI_Milestone_Type__c = 'CLP',  
                       
                        //EYI_Project__c =getProject( paymentSchedule.SAPSalesOrg).id,
                        EYI_SAP_Activity_Number__c = (paymentSchedule.SAPActivityNumber != null && paymentSchedule.SAPActivityNumber != '') ? Decimal.valueOf(paymentSchedule.SAPActivityNumber) : 0,
                        EYI_Usage__c = paymentSchedule.Usage,
                       // Payment_Plan__c = createpaymentPlan(paymentSchedule.SAPPlantCode,paymentSchedule.SAPSalesOrg).id,
                        EYI_AutomationBypassDatetime__c = system.today(),
                        EYI_Usage_Description__c = paymentSchedule.UsageDescription,
                        EYI_WBS_Element__c = (paymentSchedule.WBSElement != null && paymentSchedule.WBSElement != '') ? Decimal.valueOf(paymentSchedule.WBSElement) : null,
                        EYI_Billing_Date__c = (paymentSchedule.BillingDate != null && paymentSchedule.BillingDate != '') ? Date.valueOf(paymentSchedule.BillingDate) : null,
                        EYI_Actual_Date__c = (paymentSchedule.ActualDate != null && paymentSchedule.ActualDate != '') ? Date.valueOf(paymentSchedule.ActualDate) : null,
                        EYI_Invoice_Percentage__c = (paymentSchedule.InvoicePercentage != null && paymentSchedule.InvoicePercentage != '') ? Decimal.valueOf(paymentSchedule.InvoicePercentage) : null
                    );
                    if(towerMap.containskey(paymentSchedule.SAPPlantCode)){
                        record.EYI_Tower__c = towerMap.get( paymentSchedule.SAPPlantCode);
                    }
                    if(projectMap.containskey(paymentSchedule.SAPSalesOrg)){
                        record.EYI_Project__c = projectMap.get( paymentSchedule.SAPSalesOrg);
                    }
                    //record.EYI_SAP_Milestone_Code__c = String.ValueOf(record.EYI_Milestone_Number__c + record.EYI_SAP_Activity_Number__c);
                    recordsToInsertOrUpdate.add(record);
                }
                
                // Perform bulk DML operation (insert or update)
                List<Database.UpsertResult> results;
                
                Schema.SObjectField externalIdField = EYI_Payment_Schedule__c.EYI_SAP_Milestone_Code__c;

                results = Database.upsert(recordsToInsertOrUpdate,externalIdField, false);
                system.debug('results ==> '+results);
                // Iterate through each result to construct the response
                for (Integer i = 0; i < results.size(); i++) {
                    Database.UpsertResult result = results[i];
                    PaymentSchedule paymentSchedule = paymentSchedules[i];
                    sapExternalId = paymentSchedule.Milestone + paymentSchedule.SAPActivityNumber;
                    if (result.isSuccess()) {
                        // Success response for each record
                        String successMessage = result.isCreated() ? 'Record was successfully created.' : 'Record was successfully updated.';
                        if(result.isCreated()){
                            responses.add(new CustomResponse(
                                result.getId(),
								//result.EYI_SAP_Milestone_Code__c,
								sapExternalId,
                                true,
                                successMessage
                            ));                            
                        }else{
                            responses.add(new CustomResponse(
                                result.getId(),
								//result.EYI_SAP_Milestone_Code__c,
								sapExternalId,
                                true,
                                successMessage
                            ));                            
                        }
					  
                    } else {
                        // Error response for each record
                        String errorMessage;
                        for (Database.Error err : result.getErrors()) {
                            errorMessage = err.getMessage();
                        }
                        responses.add(new CustomResponse(
                            null,
                            sapExternalId,
                            false,
                            errorMessage
                            
                        ));
                    }
                }
            } catch (Exception e) {
                system.debug('e.getMessage()  -> '+e.getMessage()+'--'+e.getlinenumber());
                // General error response if an exception occurs
                //String errorMessage = e.getMessage();
                responses.add(new CustomResponse(
                    null,
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
        
        global static EYI_Project__c getProject(string SAPSalesOrg){
          EYI_Project__c  projectobj = [select id ,EYI_SAP_Salesorg__c from EYI_Project__c where EYI_SAP_Salesorg__c =:SAPSalesOrg limit 1];
                  system.debug(' projectobj  '+projectobj);
            return projectobj;
            
        }
        global static EYI_Tower__c  getTower(string SAPPlantCode){
                        system.debug(' SAPPlantCode  '+SAPPlantCode);
            EYI_Tower__c twrobj =[select id ,EYI_SAP_Plant_ID__c from EYI_Tower__c where EYI_SAP_Plant_ID__c =:SAPPlantCode limit 1];
            system.debug(' twrobj  '+twrobj);
            return twrobj;
            
        }
        
         global static String  createpaymentPlan(string SAPPlantCode , string SAPSalesOrg){
             string  ExternalId = SAPPlantCode+'-'+SAPSalesOrg;
             Payment_Plan__c payobj = new Payment_Plan__c();
             if(SAPPlantCode!= null && SAPSalesOrg!= null){
                payobj.name = ExternalId;
                //  payobj.Project__c = getProject(SAPSalesOrg).id;
                //  payobj.Tower__c = getTower(SAPPlantCode).id;
                payobj.Project__c = projectMap.get(SAPSalesOrg);
                payobj.Tower__c = towerMap.get(SAPPlantCode);
                payobj.EYI_SAP_ExternalId__c = ExternalId;
                payobj.EYI_Plan_Type__c ='Construction Linked Payment';
             }
             Schema.SObjectField PaymentPLan_Numberftoken = Payment_Plan__c.Fields.EYI_SAP_ExternalId__c;
             Database.UpsertResult srList = Database.upsert(payobj,PaymentPLan_Numberftoken, false);
             system.debug(' srList   '+srList.id);
             //Payment_Plan__c paymentPlnobj =[select id , name from Payment_Plan__c  where EYI_SAP_ExternalId__c=: ExternalId limit 1];
            return srList.id;
        }
    }