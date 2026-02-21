public class EYI_CancellationRefundStatusWrapper {

    public List<Request> CancellationStatus { get; set; }
    public List<Response> CancellationResponse { get; set; }

    public class Request {
        public String SapCustomerNo { get; set; }
        public String SapCompanyCode { get; set; }
        public String SapRefundAmount { get; set; }
        public String SapRefundDocNo { get; set; }
        public String SapRefundDocYear { get; set; }
        public String SapRefundDocItem { get; set; }
        public String SapRefundUtrRefNo { get; set; }
        public String SapRefundDocPostedOn { get; set; }
        public String SapRefundDocPostedAt { get; set; }
        public String SapRefundDocPostedBy { get; set; }
        public String SapRefundRevDocNo { get; set; }
        public String SapRefundRevDocYear { get; set; }
        public String SapRefundRevDocItem { get; set; }
    }

    public class Response {
        public String Type { get; set; }
        public String Message { get; set; }
        public String SapCustomerNo { get; set; }
        public String SapComapnyCode { get; set; }
        public String SapDocNo { get; set; }
    }
}