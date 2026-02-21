public class EYI_PaymentReceiptWrapper {
    public PaymentAdvice PaymentAdvice;

    public class PaymentAdvice {
        public PaymentAdvice() {
            LineItems = new List<LineItem>();
        }
        public String TransactionType;
        public String CompanyCode;
        public String SapCustomerNumber;
        public String CurrencyKey;
        public String PaymentDate;
        public String PaymentAmount;
        public String CustomerBankName;
        public String BankReferenceNumber;
        public String MaterialCode;
        public String PaymentAdviceAccountType;
        public String PaymentAdviceNumber;
        public String PaymentDocumentNumber;
        public String REMARKS;
        public String PaymentAdviceType;
        public String PaymentAdviceStatus;
        public String PaymentAdviceHoldIndicator;
        public String RuleForPaymentAdvice;
        public String CustomHeaderField1;
        public String CustomHeaderField2;
        public String CustomHeaderField3;
        public List<LineItem> LineItems;
    }

    public class LineItem {
        
        public String Reference1;
        public String Reference2;
        public String Reference3;
        public String CustomerReference;
        public String Reference;
        public String MaterialCode;
        public String DocumentInvoiceDate;
        public String AccountDocumentNumber;
        public String DocumentYear;
        public String CustRefLineItem;
        public String PartialPaymentAmount;
        public String BillingDocumentNumber;
        public String TaxCode;
        public String ProfitCenter;
        public String CustomItemField1;
        public String CustomItemField2;
        public String CustomItemField3;
    }
}