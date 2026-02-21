global class EYI_DemandStatusWrapper {
    global List<DemandWrapper> DemandStatus;
    global class DemandWrapper{
        public  string  CompanyCode;
        public  string  CustomerNo;
        public  string  SalesOrderNo;
        public  string  SapDemandNumber;
        public  string  Usage;
        public  integer MilestoneNumber;
        public  string  SapCancellationDocumentNo;
        public  string  SAP_ODN_No;
        public  string  SAP_IRN_No;
        public  string  SAP_Cancelled_ODN_No;
        public  string  SAP_IRN_Status;
        public  string  IRN_REL_FLAG;
        public  Boolean ESIGN_FLAG;
        
    }
}