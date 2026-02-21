public class InvoiceRequestWrapper {
    public List<InvoiceInput> InvoiceInput;
    
    public class InvoiceInput{
        public String PoNumber;
        public String RecVendorCode;
        public String SalesOrderNumber;
        public String MaterialNumber;
        public String PaymentTerms;
        public String PurchasingOrganization;
        public String PurchasingGroup;
        public String CurrencyKey;
        public String InvoiceAmount;
        public String PoDocDate;
        public String CompanyCode;
        public String PurchasingDocumentType;
        public String YourReference;
        public String OurReference;
        public String IncotermsLocation1;
        public String IncotermsLocation2;
        public String Attachment;
        public String Plant;
       // public String CustomField1;
        public String CustomField2;
        public String CustomField3;
        public String InvoiceRemarks;
    }
}