global class EYI_InvoiceStatusWrapper {

    global List<InvoiceWrapper> InvStatus;

    global class InvoiceWrapper {
        public String SapBillDeskNumber;
        public String RecVendorNo;
        public String SapPONumber;
        //public String PurchaseOrderNumber;
        public String InvoiceStatus;
        public String ReasonForRejectionHold;
        public String RejectionHoldRemarks;
        public String SapDocumentNumber;
        public String SapDocumentYear;
        public String SapDocumentItem;
        public String SapCompanyCode;
        public String SapUTRNo;
        public String SapMaterialNumber;
        public String ApprovedHoldAt;
        public String ApprovedHoldOn;
        public Decimal paidAmount;
        public String paymentDate;
        public String instrumentNumber;
        public String modeOfPayment;
    }
}