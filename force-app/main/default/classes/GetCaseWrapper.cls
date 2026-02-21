global class GetCaseWrapper {
    
    // Request Wrapper
    global class CaseRequest {
        public String CaseId;
        public String CaseNumber;
        public String OpportunityId;
        public String sap_customer_codes;
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
        
        public String CaseNumber;
        public String Subject;
        public String Status;
        public String Category;
        public String SubCategory;
        public String Description;
        public String Type;
        Public String Priority;
        Public Datetime CreatedDate;
        public List<DocumentDetail> documentLinks;
        public List<CommentDetail> comments; 
        public List<Case> cases;
        
        public CaseResponse(String caseId, String caseNumber, String subject, String status, 
                                String subCategory, String category, String Description, String caseType, String priority, DateTime createdDate)
        {
            this.CaseNumber = caseNumber;
            this.Subject = subject;
            this.Status = status;
            this.Category = category;
            this.SubCategory = subCategory;
            this.Description = Description;      
            this.CreatedDate = createdDate;
            this.documentLinks = new List<DocumentDetail>(); 
            this.comments = new List<CommentDetail>();
        }
    }

    // New inner class to hold document URL and type
    global class DocumentDetail {
        public String url;
        public String typeOfDoc;
        public String docName;

        public DocumentDetail(String url,String typeOfDoc,String docName) {
            this.url = url;
            this.typeOfDoc = typeOfDoc;
            this.docName = docName;
        }
    }

    // New inner class to hold EYI_Comments__c details
    global class CommentDetail {
        public Id createdById;
        public Datetime createdDate;
        public String mobileAppComment;
        public String CommentedBy;

        public CommentDetail(Id createdById, Datetime createdDate, String mobileAppComment,String CommentedBy) {
            this.createdById = createdById;
            this.createdDate = createdDate;
            this.mobileAppComment = mobileAppComment;
            this.CommentedBy = CommentedBy;
        }
    }
}