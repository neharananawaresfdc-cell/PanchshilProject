public class EYI_SalesDataCreationWrapper  {
    
    public cls_SalesData salesData;

    // Constructor for the outer class
    public EYI_SalesDataCreationWrapper() {
        this.salesData = new cls_SalesData();
    }

    public class cls_SalesData {
        public String ZZ_SALES;
        public String ZZ_MSEB_NO;
        public String ZZ_PIPE_GAS_CNUM;
        public String ZZ_PROPERTY_TAX_NUMBER;
        public String ZZ_FRANKING_DATE;
        public String ZZ_STAMP_DUTY;
        public String ZZ_PARK_ISSUE_LTR;
        public String ZZ_RESALE_NOC;
        public String ZZ_ROC_DATE;
        public String ZZ_NOC_DATE;
        public String ZZ_PAY_PROJECT;
        public String POSNR;
        public String MATNR;
        public String KWMENG;
        public String ZIEME;
        public String KPOSN;
        public String KSCHL;
        public String KBETR;
        public String TIMEBOUND;
        public String MLBEZ;
        public String MLBEZ_DESC;
        public String FKDAT;
        public String FPROZ;
        public String FAKWR;
        public String WAERS;
        public String MLSTN;
        public String VBELN;
        public String MESSAGE;

        // Constructor for SalesData
        public cls_SalesData() {
            this.ZZ_SALES = '';
            this.ZZ_MSEB_NO = '';
            this.ZZ_PIPE_GAS_CNUM = '';
            this.ZZ_PROPERTY_TAX_NUMBER = '';
            this.ZZ_FRANKING_DATE = '';
            this.ZZ_STAMP_DUTY = '';
            this.ZZ_PARK_ISSUE_LTR = '';
            this.ZZ_RESALE_NOC = '';
            this.ZZ_ROC_DATE = '';
            this.ZZ_NOC_DATE = '';
            this.ZZ_PAY_PROJECT = '';
            this.POSNR = '';
            this.MATNR = '';
            this.KWMENG = '';
            this.ZIEME = '';
            this.KPOSN = '';
            this.KSCHL = '';
            this.KBETR = '';
            this.TIMEBOUND = '';
            this.MLBEZ = '';
            this.MLBEZ_DESC = '';
            this.FKDAT = '';
            this.FPROZ = '';
            this.FAKWR = '';
            this.WAERS = '';
            this.MLSTN = '';
            this.VBELN = '';
            this.MESSAGE = '';
        }
    }
}