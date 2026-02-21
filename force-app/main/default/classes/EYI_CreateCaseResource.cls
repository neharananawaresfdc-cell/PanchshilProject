@RestResource(urlMapping='/CreateCase')
global class EYI_CreateCaseResource {

    global class CustomResponse {
        public String message;
        public String type;
        public String caseNumber;
        public String caseId;

        public CustomResponse(String message, Boolean isSuccess, String caseNumber, String caseId) {
            this.message = message;
            this.type = isSuccess ? 'Success' : 'Error';
            this.caseNumber = caseNumber;
            this.caseId = caseId;
        }
    }

    @HttpPost
    global static CustomResponse createCaseRec() {
        try {
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
			System.debug('requestBody : '+requestBody);
            // Deserialize using your structure
            CreateCaseWrapper input = (CreateCaseWrapper) JSON.deserialize(requestBody, CreateCaseWrapper.class);
            System.debug('input : '+input);
            if (input == null || input.CaseDetails == null || String.isBlank(input.CaseDetails.sapCustomerCode)) {
                return new CustomResponse('Invalid request: Missing case details or SAP customer code.', false, null, null);
            }

            // Resolve Opportunity by SAP customer code
            Opportunity opp = [
                SELECT Id,name FROM Opportunity 
                WHERE EYI_SAP_Customer_Number__c = :input.CaseDetails.sapCustomerCode 
                LIMIT 1
            ];

            if (opp == null) {
                return new CustomResponse('No Opportunity found for given SAP Customer Code.', false, null, null);
            }

            // Prepare Case record
            RecordType rt = [
                SELECT Id FROM RecordType 
                WHERE DeveloperName = 'Post_Sales' AND SObjectType = 'Case' 
                LIMIT 1
            ];
            User caseOwnerId = [Select Id,Name from User Where Name =:Label.EYI_Case_Owner];
            Case newCase = new Case();
            if(input.CaseDetails.case_number == ''){
            
            newCase.RecordTypeId = rt.Id;
            newCase.SuppliedName = opp.name;
            newCase.EYI_Opportunity__c = opp.Id;
            newCase.Type = input.CaseDetails.caseType;
                if(input.CaseDetails.category == 'Queries Pre Possession'){
                    newCase.EYI_Case_Category__c = 'Queries_PrePossession';
                }else if(input.CaseDetails.category=='Requests Pre Possession'){
                    newCase.EYI_Case_Category__c = 'Requests_PrePossession';
                }else if(input.CaseDetails.category=='Complaints Pre Possession'){
                    newCase.EYI_Case_Category__c = 'Complaints_PrePossession';
                }else if(input.CaseDetails.category=='Communication Pre Possession'){
                    newCase.EYI_Case_Category__c = 'Communication_PrePossession';
                }else if(input.CaseDetails.category=='Queries Post Possession'){
                    newCase.EYI_Case_Category__c = 'Queries_PostPossession';
                }else if(input.CaseDetails.category=='Requests Post Possession'){
                    newCase.EYI_Case_Category__c = 'Requests_PostPossession';
                }else if(input.CaseDetails.category=='Complaints Post Possession'){
                    newCase.EYI_Case_Category__c = 'Complaints_PostPossession';
                }else if(input.CaseDetails.category=='Communication Post Possession'){
                    newCase.EYI_Case_Category__c = 'Communication_PostPossession';
                }else{
                    newCase.EYI_Case_Category__c = input.CaseDetails.category;
                }
            
            newCase.EYI_Case_Sub_Category__c = input.CaseDetails.subCategory;
            newCase.Subject = input.CaseDetails.subject;
            newCase.Description = input.CaseDetails.description;
            newCase.SuppliedEmail = input.CaseDetails.email;
            newCase.Origin = 'Mobile App';
             
            newCase.OwnerId = caseOwnerId != null ? caseOwnerId.Id : UserInfo.getUserId();
            System.debug('newCase : '+newCase);
            newCase.Status = 'New';
                try{
                    insert newCase;
            System.debug('newCase.Id : '+newCase.Id);
                    newCase = [Select CaseNumber from Case where Id =:newCase.Id];
                    
                }catch(Exception e){
                    System.debug('exception : '+e.getMessage());
                }
            

            // Attach file to Case
           /* if (input.CaseDetails.caseAttachment != null && 
                !String.isBlank(input.CaseDetails.caseAttachment.base64Data)) {

                attachFileToRecord(
                    newCase.Id,
                    input.CaseDetails.caseAttachment.fileName,
                    input.CaseDetails.caseAttachment.base64Data
                );
            } */
                System.debug('input.CaseDetails.caseAttachments : '+input.CaseDetails.caseAttachments);
                if (input.CaseDetails.caseAttachments != null) {
                    for (CreateCaseWrapper.CaseAttachment attachment : input.CaseDetails.caseAttachments) {
                        if (!String.isBlank(attachment.base64Data)) {
                            attachFileToRecord(
                                newCase.Id,
                                attachment.fileName,
                                attachment.base64Data
                            );
                        }
                    }
                }
            }else{
              newCase = [Select Id,CaseNumber from Case where CaseNumber =: input.CaseDetails.case_number ] ;
            }
            

            // Insert Comments
            System.debug('input.CaseDetails.Comments  : '+input.CaseDetails.Comments);
            if (input.CaseDetails.Comments != null) {
                System.debug('Inside comment creation');
                for (CreateCaseWrapper.CaseComment commentData : input.CaseDetails.Comments) {
                    
                    if(commentData.comment != null){
                     EYI_Comments__c comment = new EYI_Comments__c();	
                    comment.EYI_Synced_Case__c = newCase.Id;
                    comment.EYI_Mobile_App_Comments__c = commentData.comment;
                    //comment.EYI_Commented_By__c = commentData.commentedBy;
                    //comment.EYI_Created_Date__c = DateTime.valueOf(commentData.createdDate);
                    insert comment;  
                    
                    
					System.debug('New Comment Id : '+comment.Id);
                    if (commentData.commentAttachment != null &&
                        !String.isBlank(commentData.commentAttachment.base64Data)) {
                        attachFileToRecord(
                            comment.Id,
                            commentData.commentAttachment.fileName,
                            commentData.commentAttachment.base64Data
                        );
                    }
                    }
                }
            }

            return new CustomResponse('Case created successfully', true, newCase.CaseNumber, newCase.Id);

        } catch (Exception e) {
            return new CustomResponse('Error: ' + e.getMessage(), false, null, null);
        }
    }

    public static void attachFileToRecord(Id recordId, String fileName, String base64Body) {
        if (String.isBlank(base64Body)) return;

        ContentVersion cv = new ContentVersion();
        cv.Title = String.isBlank(fileName) ? 'Attachment' : fileName;
        cv.PathOnClient = cv.Title;
        cv.VersionData = EncodingUtil.base64Decode(base64Body);
        insert cv;

        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = [
            SELECT ContentDocumentId FROM ContentVersion 
            WHERE Id = :cv.Id LIMIT 1
        ].ContentDocumentId;
        link.LinkedEntityId = recordId;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;
    }
}