@RestResource(urlMapping='/ncfupdate/*')
global class EYI_NCFUpdateResource {

    global class NCFUpdateRequest {
        public String sapCustomerCode;
        public String ncfStatus;
        public String ncfReceivedDate;
    }

    global class NCFUpdateResponse {
        public String Message;
        public String Type;

        public NCFUpdateResponse(String message, String type) {
            this.Message = message;
            this.Type = type;
        }
    }

    @HttpPost
    global static void updateNCF() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            // Parse JSON request body
            NCFUpdateRequest requestBody = (NCFUpdateRequest) JSON.deserialize(req.requestBody.toString(), NCFUpdateRequest.class);

            if (String.isBlank(requestBody.sapCustomerCode)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new NCFUpdateResponse('sapCustomerCode is required.', 'E'))
                );
                return;
            }

            // Find Opportunity by EYI_SAP_Customer_Number__c
            Opportunity opp;
            try {
                opp = [SELECT Id, EYI_SAP_Customer_Number__c, EYI_NCF_Status__c, EYI_NCF_Received_Date__c
                       FROM Opportunity
                       WHERE EYI_SAP_Customer_Number__c = :requestBody.sapCustomerCode
                       LIMIT 1];
            } catch (Exception notFoundEx) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new NCFUpdateResponse('Opportunity not found.', 'E'))
                );
                return;
            }

            // Update fields
            opp.EYI_NCF_Status__c = requestBody.ncfStatus;

            // Convert string to Date if provided
            if (!String.isBlank(requestBody.ncfReceivedDate)) {
                try {
                    opp.EYI_NCF_Received_Date__c = Date.valueOf(requestBody.ncfReceivedDate);
                } catch (Exception e) {
                    // If date format is invalid, respond with error
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(
                        JSON.serialize(new NCFUpdateResponse('Invalid date format for ncfReceivedDate.', 'E'))
                    );
                    return;
                }
            }

            update opp;

            // Success response
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new NCFUpdateResponse('NCF is updated successfully.', 'S'))
            );

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new NCFUpdateResponse('Internal server error: ' + e.getMessage(), 'E'))
            );
        }
    }
}