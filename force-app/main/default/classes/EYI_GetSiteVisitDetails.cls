@RestResource(urlMapping='/getSiteVisit')
global without sharing class EYI_GetSiteVisitDetails {

    // Request body format
    global class LeadEnquiryRequest {
        public String email;
        public String phone;
    }

    // Response wrapper
    global class LeadEnquiryResponse {
        public Boolean success;
        public String message;
        public List<LeadRecord> leads;

        public LeadEnquiryResponse(Boolean success, String message, List<LeadRecord> leads) {
            this.success = success;
            this.message = message;
            this.leads = leads;
        }
    }

    // Individual lead record
    global class LeadRecord {
        public Id id;
        public String name;
        public String status;
        public String email;
        public String phone;
        public String projectName;
        public Datetime createdDate;
        public String leadSource;
        public Datetime siteVisitDate;

        // Constructor from SObject
        public LeadRecord(EYI_Lead_Enquiry__c lead) {
            this.id = lead.Id;
            this.name = lead.Name;
            this.status = lead.EYI_Lead_Status__c;
            this.email = lead.EYI_Email__c;
            this.phone = lead.EYI_Mobile__c;
            this.projectName = lead.EYI_Project_Enquired__r.Name;
            this.createdDate = lead.CreatedDate;
            this.leadSource = lead.EYI_Lead_Source__c; // Replace with actual API name if different
            this.siteVisitDate = lead.EYI_Site_Visit_Date__c;
        }
    }

    @HttpPost
    global static LeadEnquiryResponse getLeadEnquiryStatus() {
        try {
            RestRequest req = RestContext.request;
            String body = req.requestBody.toString();
            LeadEnquiryRequest request = (LeadEnquiryRequest) JSON.deserialize(body, LeadEnquiryRequest.class);

            // Validate input
            if (String.isBlank(request.email) && String.isBlank(request.phone)) {
                return new LeadEnquiryResponse(false, 'Email or Phone is required', new List<LeadRecord>());
            }

            // Query Lead Enquiry records
            List<EYI_Lead_Enquiry__c> matchedLeads = [
                SELECT Id, Name, EYI_Lead_Status__c, EYI_Email__c, EYI_Mobile__c,EYI_Project_Enquired__r.Name,EYI_Site_Visit_Date__c,
                       CreatedDate, EYI_Lead_Source__c
                FROM EYI_Lead_Enquiry__c
                WHERE (EYI_Email__c = :request.email)
            ];

            // Build response list
            List<LeadRecord> responseLeads = new List<LeadRecord>();
            for (EYI_Lead_Enquiry__c lead : matchedLeads) {
                responseLeads.add(new LeadRecord(lead));
            }

            return new LeadEnquiryResponse(
                true,
                responseLeads.isEmpty() ? 'No leads found.' : 'Leads retrieved successfully.',
                responseLeads
            );

        } catch (Exception e) {
            return new LeadEnquiryResponse(false, 'Error: ' + e.getMessage(), new List<LeadRecord>());
        }
    }
}