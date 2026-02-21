public class CreateCaseWrapper {

    public CaseWrapper CaseDetails;

    public class CaseWrapper {
        public String sapCustomerCode;
        public String category;
        public String subCategory;
        public String subject;
        public String description;
        public String case_number;
        public String caseType;
        public String email;
        public List<CaseAttachment> caseAttachments;
       // public CaseAttachment caseAttachment;
        public List<CaseComment> Comments;
    }

    public class CaseAttachment {
        public String fileName;
        public String type;
        public String base64Data;
    }

    public class CaseComment {
        public String commentedBy;
        public String createdDate;
        public String comment;
        public CommentAttachment commentAttachment;
    }

    public class CommentAttachment {
        public String fileName;
        public String type;
        public String base64Data;
    }
}