@RestResource(urlMapping='/UpdateDemandStatus/*')
global class EYI_DemandStatusUpdate {
    global class CustomResponse {
        public String VBELN_VF;
        // public String sapExternalId;
        public String TYPE;
        public String MESSAGE;
        //public List<String> errors;
        
        public CustomResponse(String VBELN_VF, String TYPE, String MESSAGE) {
            this.VBELN_VF = VBELN_VF;
            //this.sapExternalId = sapExternalId;
            this.TYPE = TYPE;
            this.MESSAGE = MESSAGE;
            //this.errors = errors;
        }
    }
    @HttpPatch
    global static List<CustomResponse> updateDemandStatus(){
    RestRequest req = RestContext.request;
    String requestBody = req.requestBody.toString();
    List<EYI_Demand__c> recordsToUpdate = new List<EYI_Demand__c>();
    Set<String> sapDemandNumber = new Set<string>();
        Map<String,String> sapCNWithID = new Map<String,String>();
        Map<String,String> sapIDWithCN = new Map<String,String>();
    System.debug('requestBody ==> ' + requestBody);
    List<CustomResponse> responses = new List<CustomResponse>();
    try{
		DemandStatusWrapper wrapper = (DemandStatusWrapper) JSON.deserialize(requestBody, DemandStatusWrapper.class);

        System.debug('demandStatusRequest : '+wrapper);
        System.debug('wrapper.DemandStatus : '+wrapper.DemandStatus);
        for (DemandStatusItem item : wrapper.DemandStatus){
            sapDemandNumber.add(item.VBELN_VF);
        }
        List<EYI_Demand__c> demandRecord = [Select id,EYI_SAP_Demand_Number__c from EYI_Demand__c where EYI_SAP_Demand_Number__c IN :sapDemandNumber ];
        for(EYI_Demand__c sCN :demandRecord ){
            sapCNWithID.put(sCN.EYI_SAP_Demand_Number__c,sCN.Id);
            sapIDWithCN.put(sCN.Id,sCN.EYI_SAP_Demand_Number__c);
        } 
        for (DemandStatusItem demandStatus : wrapper.DemandStatus){
                 system.debug('insidefor-->116');
            if(sapCNWithID.containskey(demandStatus.VBELN_VF)){
               EYI_Demand__c record = new EYI_Demand__c(
                   EYI_SAP_ODN_No__c   = demandStatus.ODN,
                   EYI_SAP_IRN_No__c = demandStatus.IRN,
                   EYI_SAP_Demand_Number__c = demandStatus.VBELN_VF,
                   //EYI_SapCancellationDocumentNo__c = demandStatus.CAN_ODN,
                   EYI_SAP_IRN_Status__c = demandStatus.IRN_STATUS == 'ACT'?'Active':'',
                   EYI_SAP_Cancelled_ODN_No__c = demandStatus.CAN_ODN,
                   EYI_ESIGN_FLAG__c = (demandStatus.ESIGN_FLAG == 'X') ? true : false,//demandStatus.ESIGN_FLAG,
				   Id = sapCNWithID.get(demandStatus.VBELN_VF)
                    );

             if(demandStatus.CAN_ODN != null){
                 record.EYI_Demand_Status__c = 'Open';
                 record.EYI_SAP_Demand_Number__c = '';
                 record.EYI_Demand_Raise_Date__c = null;
                 record.EYI_Demand_Send_Date__c = null;	
                 record.EYI_Milestone_Block_Date__c = null;                     
             }
                 system.debug('recordsToInsertOrUpdate'+ record);
                 recordsToUpdate.add(record); 
               
            }
            else{
                responses.add(new CustomResponse(
                null,
                'E',
                'Sap Demand Number does not exists: '+ demandStatus.VBELN_VF));
            }
                    
       }   
         List<Database.SaveResult> results;
        results = Database.update(recordsToUpdate, false);
         system.debug('results ==> '+results);
        for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult result = results[i];
                if (result.isSuccess()) {
                    // Success response for each record
                    responses.add(new CustomResponse(
                        sapIDWithCN.get(result.getId()),        // The ID of the updated record
                        'S',                  // Indicates success
                        'Record was successfully updated.'
                    ));
                    
                } else {
                    // Error response for each record
                    String errorMessage;
                     for (Database.Error err : result.getErrors()) {
                            errorMessage = err.getMessage();
                    }
                    responses.add(new CustomResponse(null,'E',errorMessage));
                }
            }
     } catch (Exception e) {
            // General error response if an exception occurs
            //String errorMessage = e.getMessage();
            if(sapDemandNumber.isEmpty()){
                responses.add(new CustomResponse(null,'E','Please check all the data is filled properly or not'));
            }else{
                responses.add(new CustomResponse( null, 'E', e.getMessage()));
            }
            
        }
    system.debug('responses -> '+responses);
        system.debug('serialized responses -> '+JSON.serialize(responses));
            //Schema.SObjectField externalIdField = EYI_Demand__c.EYI_SAP_Demand_Number__c;
            // system.debug('externalIdField'+ externalIdField);
            //results = Database.update(recordsToUpdate,externalIdField, false);
        return responses;
    }
     global class DemandStatusWrapper {
        public List<DemandStatusItem> DemandStatus;
    }

    global class DemandStatusItem {
        public String BUKRS;
        public String KUNNR;
        public String VBELN;
        public String VBELN_VF;
        public String MLBEZ;
        public String MLBEZ_DESC;
        public String ODN;
        public String CAN_ODN;
        public String IRN_STATUS;
        public String ESIGN_FLAG;
        public String IRN;
    }
}