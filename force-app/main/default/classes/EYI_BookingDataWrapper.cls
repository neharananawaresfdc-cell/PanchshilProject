public class EYI_BookingDataWrapper {
    public BookingData BOOKINGDATA;
    
    public EYI_BookingDataWrapper() {
        this.BOOKINGDATA = new BookingData();
    }
    
    public class BookingData {
        public String SalesOrderNo;
        public String DistChannel;
        public String CustomerNo;
        public String SalesOrg;
        public String Division;
        public String PlantCode;
        public String SalesOffice;
        public String SalesGroup;
        public String OpportunityNumber;
        public String BookingDate;
        public String CancellationReason;
        public String ActualBookingDate;
        public String WarrantyDate;
        public String Pdf;
        public List<MaterialDetail> MaterialDetails;
        public List<Condition> Conditions;
        public List<PaymentPlan> PaymentPlan;
        public List<PartnerFunction> PartnerFunction;
        public AdditionalData Additional;
        
        public BookingData() {
            this.SalesOrderNo = '';
            this.CustomerNo = '';
            this.SalesOrg = '';
            this.Division = '';
            this.PlantCode = '';
            this.SalesOffice = '';
            this.SalesGroup = '';
            this.OpportunityNumber = '';
            this.BookingDate = '';
            this.CancellationReason = '';
            this.ActualBookingDate = '';
            this.WarrantyDate = '';
            this.Pdf = '';
            this.MaterialDetails = new List<MaterialDetail>();
            this.Conditions = new List<Condition>();
            this.PaymentPlan = new List<PaymentPlan>();
            this.PartnerFunction = new List<PartnerFunction>();
            this.Additional = new AdditionalData();
        }
    }
    
    public class MaterialDetail {
        public String ItemNumberSD;
        public String MaterialNumber;
        public Decimal Quantity;
        public String UnitOfMeasure;
        
        public MaterialDetail() {
            this.ItemNumberSD = '';
            this.MaterialNumber = '';
            this.Quantity = 0;
            this.UnitOfMeasure = '';
        }
    }
    
    public class Condition {
        public String ConditionItemNumber;
        public String ConditionType;
        public String ConditionAmount;
        
        public Condition() {
            this.ConditionItemNumber = '';
            this.ConditionType = '';
            this.ConditionAmount = '';
        }
    }
    
    public class PaymentPlan {
        public String DateType;
        public String Usage;
        public String UsageDescription;
        public String BillingDate;
        public String PercentageToBeInvoiced;
        public String ValueToBeCalculatedOnDate;
        public String CurrencyKey;
        public String MilestoneNumber;
        
        public PaymentPlan() {
            this.DateType = '';
            this.Usage = '';
            this.UsageDescription = '';
            this.BillingDate = '';
            this.PercentageToBeInvoiced = '';
            this.ValueToBeCalculatedOnDate = '';
            this.CurrencyKey = '';
            this.MilestoneNumber = '';
        }
    }
    
    public class PartnerFunction {
        public String PartnerFunction;
        public String CustomerNumber;
        
        public PartnerFunction() {
            System.debug('PartnerFunction');
            //this.PartnerFunction = '';
            //this.CustomerNumber = '';
        }
    }
    
    public class AdditionalData {
        public String AgrmentExecutionDate;
        public String AgrmentHandoverDate;
        public String AgrmentRecievedDate;
        public String AgrmentRegNo;
        public String SalesDeedNo;
        public String RegistrationDate;
        public String PossesionIntiDate;
        public String RERAPossesionDate;
        public String ActualPossesionDate;
        public String MaintenanceDate;
        public String TransferDate;
        public String TransferRemarks;
        public String MortgageStatus;
        public String LoaningInstitue;
        public String LoanAmount;
        public String LoanFileNo;
        public String LoanPercentage;
        public String SanctionDate;
        public String NOCIssueDate;
        public String CancellationDate;
        public String CancellationInitiatedBy;
        public String DeedOfCancellationRegDate;
        public String Name1;
        public String RateOfIntrstForTabD;
        public String SelfBankingForVA01;
        public String BankingRemarksForVA01;
        public String LoanBranchForVA01;
        public String Reference1;
        public String Reference2;
        public String SalesDetails;
        public String MsebConsumerNo;
        public String PipeGasConsumerNo;
        public String PropertyTaxNo;
        public String FrankingDate;
        public String StampDutyAmount;
        public String ParkingIssueLetter;
        public String ResaleNOC;
        public String ROCDate;
        public String PrevBankNOCDate;
        public String PaymentProject;
        
        public AdditionalData() {
            this.AgrmentExecutionDate = '';
            this.AgrmentHandoverDate = '';
            this.AgrmentRecievedDate = '';
            this.AgrmentRegNo = '';
            this.SalesDeedNo = '';
            this.RegistrationDate = '';
            this.PossesionIntiDate = '';
            this.RERAPossesionDate = '';
            this.ActualPossesionDate = '';
            this.MaintenanceDate = '';
            this.TransferDate = '';
            this.TransferRemarks = '';
            this.MortgageStatus = '';
            this.LoaningInstitue = '';
            this.LoanAmount = '';
            this.LoanFileNo = '';
            this.LoanPercentage = '';
            this.SanctionDate = '';
            this.NOCIssueDate = '';
            this.CancellationDate = '';
            this.CancellationInitiatedBy = '';
            this.DeedOfCancellationRegDate = '';
            this.Name1 = '';
            this.RateOfIntrstForTabD = '';
            this.SelfBankingForVA01 = '';
            this.BankingRemarksForVA01 = '';
            this.LoanBranchForVA01 = '';
            this.Reference1 = '';
            this.Reference2 = '';
            this.SalesDetails = '';
            this.MsebConsumerNo = '';
            this.PipeGasConsumerNo = '';
            this.PropertyTaxNo = '';
            this.FrankingDate = '';
            this.StampDutyAmount = '';
            this.ParkingIssueLetter = '';
            this.ResaleNOC = '';
            this.ROCDate = '';
            this.PrevBankNOCDate = '';
            this.PaymentProject = '';
        }
    }
}