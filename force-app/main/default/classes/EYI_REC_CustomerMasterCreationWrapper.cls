public class EYI_REC_CustomerMasterCreationWrapper {
    public cls_ImCustomer IM_CUSTOMER;
    
    public EYI_REC_CustomerMasterCreationWrapper() {
        this.IM_CUSTOMER = new cls_ImCustomer();
    }
    
    public class cls_ImCustomer {
        public String TEST_RUN;
        public String RLTYPE;
        public String BU_GROUP;
        public String KUNNR;
        public String TYPE;
        public String TITLE_MEDI;
        public String NAME_FIRST;
        public String NAME_LAST;
        public String SORT1;
        public String SORT2;
        public String SEXID;
        public String MARST;
        public String NATIO;
        public String JOBGR;
        public String BIRTHDT;
        public String BIRTHPL;
        public String BPEXT;
        public String KUKLA;
        public String BRAN1;
        public String BUKRS;
        public String AKONT;
        public String ZUAWA;
        public String VZSKZ;
        public String ZTERMS;
        public String ZWELS;
        public String MAHNA;
        public String VKORG;
        public String WERKS;
        public String VTWEG;
        public String SPART;
        public String BZIRK;
        public String KDGRP;
        public String VKBUR;
        public String VKGRP;
        public String WAERS;
        public String AWAHR;
        public String KALKS;
        public String VERSG;
        public String LPRIO;
        public String KZAZU;
        public String VSBED;
        public String VWERK;
        public String ANTLF;
        public String INCO1;
        public String ZTERM;
        public String KTGRD;
        public String TAXKD;
        public String KVGR1;
        public String KVGR2;
        public String KVGR3;
        public String KVGR4;
        public String KVGR5;
        public String J_1IPANNO;
        public Integer GST_FLAG;
        public Integer TCS_FLAG;
        public String GSTIN;
        public String PDF;
        public cls_Partner[] PARTNER;
        public cls_CustID[] CUSTID;
        public cls_TaxID[] TAXID;
        public cls_Addr[] ADDR;
        public cls_Comm[] COMM;
        public cls_CO_Applicant[] CO_APPLICANT;
        public cls_Bank[] BANK;
        
        public cls_ImCustomer() {
            this.TEST_RUN = '';
            this.RLType = '';
            this.BU_GROUP = '';
            this.Kunnr = '';
            this.Type = '';
            this.TITLE_MEDI = '';
            this.NAME_FIRST = '';
            this.NAME_LAST = '';
            this.Sort1 = '';
            this.Sort2 = '';
            this.Sexid = '';
            this.Marst = '';
            this.Natio = '';
            this.Jobgr = '';
            this.Birthdt = '';
            this.Birthpl = '';
            this.Bpext = '';
            this.Kukla = '';
            this.Bran1 = '';
            this.Bukrs = '';
            this.Akont = '';
            this.Zuawa = '';
            this.Vzskz = '';
            this.Zterms = '';
            this.Zwels = '';
            this.Mahna = '';
            this.Vkorg = '';
            this.Werks = '';
            this.Vtweg = '';
            this.Spart = '';
            this.Bzirk = '';
            this.Kdgrp = '';
            this.Vkbur = '';
            this.Vkgrp = '';
            this.Waers = '';
            this.Awahr = '';
            this.Kalks = '';
            this.Versg = '';
            this.Lprio = '';
            this.Kzazu = '';
            this.Vsbed = '';
            this.Vwerk = '';
            this.Antlf = '';
            this.Inco1 = '';
            this.Zterm = '';
            this.Ktgrd = '';
            this.Taxkd = '';
            this.GSTIN = '';
            this.Kvgr1 = '';
            this.Kvgr2 = '';
            this.Kvgr3 = '';
            this.Kvgr4 = '';
            this.Kvgr5 = '';
            this.J_1IPANNO = '';
            this.GST_FLAG = 1 ;
            this.TCS_FLAG = 1 ;
            this.Gstin = '';
            this.Pdf = '';
            
            this.Partner = new cls_Partner[0];
            this.CustID = new cls_CustID[0];
            this.TaxID = new cls_TaxID[0];
            this.Addr = new cls_Addr[0];
            this.Comm = new cls_Comm[0];
            this.CO_APPLICANT = new cls_CO_Applicant[0];
            this.Bank = new cls_Bank[0];
        }
    }
    
    public class cls_Partner {
        public String PARVW;
        public String KTONR;
        
        // Constructor for cls_Partner to initialize fields to default values
        public cls_Partner() {
            this.PARVW = '';
            this.KTONR = '';
        }
    }
    
    public class cls_CustID {
        public String IDTYPE;
        public String IDNUMBER;
        
        // Constructor for cls_CustID to initialize fields to default values
        public cls_CustID() {
            this.IDTYPE = '';
            this.IDNUMBER = '';
        }
    }
    
    public class cls_TaxID {
        public String TAXTYPE; // Mapping not found
        public String TAXNUM;  // Corresponding tax number
        
        // Constructor for cls_TaxID to initialize fields to default values
        public cls_TaxID() {
            this.TAXTYPE = '';
            this.TAXNUM = '';
        }
    }
    
    public class cls_Addr {
        public String SEQNO;
        public String STREET;
        public String STR_SUPPL3;
        public String LOCATION;
        public String CITY2;
        public String POST_CODE1;
        public String CITY1;
        public String COUNTRY;
        public String REGION;
        public String LANGU;
        public String TIME_ZONE;
        public String TRANSPZONE;
        public String ADDR_TYPE;
        
        // Constructor for cls_Addr to initialize fields to default values
        public cls_Addr() {
            this.SEQNO = '';
            this.STREET = '';
            this.STR_SUPPL3 = '';
            this.LOCATION = '';
            this.CITY2 = '';
            this.POST_CODE1 = '';
            this.CITY1 = '';
            this.COUNTRY = '';
            this.REGION = '';
            this.LANGU = '';
            this.TIME_ZONE = '';
            this.TRANSPZONE = '';
            this.ADDR_TYPE = '';
        }
    }
    
    public class cls_Comm {
        public String COUNTRY;
        public String TEL_EXTENS;
        public String TEL_NUMBER;
        public String SMTP_ADDR;
        public String MOB_NUMBER;
        
        public cls_Comm() {
            this.COUNTRY = '';
            this.TEL_EXTENS = '';
            this.TEL_NUMBER = '';
            this.SMTP_ADDR = '';
            this.MOB_NUMBER = '';
        }
    }
    
    
    public class cls_CO_Applicant {
        public String TITLE;         // CoApplicant's Title
        public String NAME_FIRST;    // CoApplicant's First Name
        public String NAME_LAST;     // CoApplicant's Last Name
        public String ABTNR;         // CoApplicant's ABTNR
        public String PAFKT;         // CoApplicant's PAFKT
        public String BIRTHDT;       // CoApplicant's Birth Date
        public String TEL_NUMBER;    // CoApplicant's Telephone Number
        public String SMTP_ADDRESS;  // CoApplicant's SMTP Address
        public String PANNO;         // CoApplicant's PAN Number
        
        // Constructor for cls_CoApplicant to initialize fields to default values
        public cls_CO_Applicant() {
            this.TITLE = '';
            this.NAME_FIRST = '';
            this.NAME_LAST = '';
            this.ABTNR = '';
            this.PAFKT = '';
            this.BIRTHDT = '';
            this.TEL_NUMBER = '';
            this.SMTP_ADDRESS = '';
            this.PANNO = '';
        }
    }
    
    
    public class cls_Bank {
        public String BKVID; // not needed in SAP
        public String BANK_CTRY; // Country
        public String BANK_KEY; // IFSC
        public String BANK_ACCT; // Account Number
        public String ACCOUNTHOLDER; // bank acc holder name
        public String BANK_REF; //d for delete u for update
        public String BANKACCOUNTNAME; // bank Name
        public String BANKDETAILVALIDFROM; // Not needed in SAP 
        public String BANKDETAILVALIDTO; // Not needed in SAP
        
        // Constructor for cls_Bank to initialize fields to default values
        public cls_Bank() {
            this.BKVID = '';
            this.BANK_CTRY = '';
            this.BANK_KEY = '';
            this.BANK_ACCT = '';
            this.ACCOUNTHOLDER = '';
            this.BANK_REF = '';
            this.BANKACCOUNTNAME = '';
            this.BANKDETAILVALIDFROM = '';
            this.BANKDETAILVALIDTO = '';
        }
    }
    
}