public class DemandRaiseRequestWrapper {
    public List<DemandRaiseAPI> DemandRaiseAPI;
    
    public class DemandRaiseAPI {
        public String TypeOfAction;
        public String CustomerNo;
        public String SalesOrderNo;
        public String SapBillingDocNo;
        public String SalesOrg;
        public String DistributionChannel;
        public String UnitCode;
        public String SalesOrderLineItemNo;
        public String BillingDate;
        public String TotalDemandAmount;
        public String TaxValue;
        public String PrincipalValue;
        public String OtherCharges;
        public String DateType;
        public String Usage;
        public String UsageDescription;
        public String CurrencyKey;
        public String MilestoneNumber;
        public String AdditionalParameter1;
        public String AdditionalParameter2;
        public String AdditionalParameter3;
        
        // Constructor to initialize fields with default values
        public DemandRaiseAPI() {
            this.TypeOfAction = '';
            this.CustomerNo = '';
            this.SalesOrderNo = '';
            this.SapBillingDocNo = '';
            this.SalesOrg = '';
            this.DistributionChannel = '';
            this.UnitCode = '';
            this.SalesOrderLineItemNo = '';
            this.BillingDate = '';
            this.TotalDemandAmount = '';
            this.TaxValue = '';
            this.PrincipalValue = '';
            this.OtherCharges = '';
            this.DateType = '';
            this.Usage = '';
            this.UsageDescription = '';
            this.CurrencyKey = '';
            this.MilestoneNumber = '';
            this.AdditionalParameter1 = '';
            this.AdditionalParameter2 = '';
            this.AdditionalParameter3 = '';
        }
    }
}