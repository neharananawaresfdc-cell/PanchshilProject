/**
 * @description       : 
 * @author            : Mrinal Tripathi (EYIN)
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EYI_SAP_ReportResponseWrapper {
    public EX_MESSAGE message;
    public EX_OUTPUT output;

    public class EX_MESSAGE {
        public String Message;
    }

    public class EX_OUTPUT {
        public List<Item> item;
    }

    public class Item {
        public String SalesDocument;
        public String SOLineItem;
        public String CustomerNo;
        public String CustomerName;
        public String Material;
        public String MaterialDescription;
        public String ReconAccount;
        public String ReconAccountDescription;
        public String TotalConsideration;
        public String ActualBasicBillAmount;
        public String DebitAmount;
        public String TaxAmount;
        public String BilledAndDebitNoteAmt;
        public String ReceivedAmt;
        public String OutstandingAmt;
        public String ProfitCenter;
        public String ReasonForRejection;
        public String Plant;
        public String Flat;
        public String SalesOrg;
        public String SalesOrgDesc;
        public String CompanyName;
        public String DistributionChannel;
        public String Area;
        public String BookingDate;
        public String Rejection;
        public String ProfitCenterName;
        public String BuildingName;
        public String CreditAmount;
        public String AfterDeductionBasicBill;
        public String AgreementExecutionDate;
        public String AgreementHandoverDate;
        public String AgreementReceivedDate;
        public String AgreementRegNo;
        public String SalesDeedNo;
        public String RegistrationDate;
        public String CancellationDate;
        public String CancellationInitiatedBy;
        public String SalesType;
        public String PropertyTaxNumber;
        public String FrankingDate;
        public String StampDutyAmountSD;
        public String StampDutyAmountFI;
        public String PaymentProject;
        public String CRMMapped;
        public String NameOfCRMMapped;
    }

    // Method to deserialize JSON into Apex class
    public static EYI_SAP_ReportResponseWrapper parse(String jsonString) {
        return (EYI_SAP_ReportResponseWrapper) JSON.deserialize(jsonString, EYI_SAP_ReportResponseWrapper.class);
    }
}