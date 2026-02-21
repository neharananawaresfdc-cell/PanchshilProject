global class GetUserDetailWrapper {
	
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
    global class CaseResponseWrapper {
        public Boolean status;
        public String message;
        public List<CaseResponse> cases;
        
        public CaseResponseWrapper(Boolean status, String message, List<CaseResponse> cases) {
            this.status = status;
            this.message = message;
            this.cases = cases;
        }
    }
    
    // Inner class for individual Case response details
    global class CaseResponse {
        
        public String CaseId;
        public String CaseNumber;
        public String Subject;
        public String Status;
        public String Category;
        public String SubCategory;
        public String Description;
        public String Type;
        Public String Priority;
        public List<String> documentLink;
        
        public CaseResponse(String caseId, String caseNumber, String subject, String status, 
                            String subCategory, String category, String Description, String caseType, String priority)
        {
            
            this.CaseId = caseId;
            this.CaseNumber = caseNumber;
            this.Subject = subject;
            this.Status = status;
            this.Category = category;
            this.SubCategory = subCategory;
            this.Description = Description;     
            this.Type = caseType;
            this.Priority = priority;
        }
    }
}