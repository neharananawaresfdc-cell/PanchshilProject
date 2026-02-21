public class EYI_RECVendorCreationWrapper{
    
    public cls_ImVendor ImVendor;

    // Constructor for the outer class (optional)
    public EYI_RECVendorCreationWrapper() {
        this.ImVendor = new cls_ImVendor();  // Initialize inner class
    }

    public class cls_ImVendor {
        public String TestRun; // X-Yes, Blank if for Actual Vendor Creation
        public string Lifnr;
        public String Type;    // //Type Of RERA Registration Broker Type --> 1-Person, 4-Organization 
        public String BuGroup; // NA in FM
        public String TitleMedi; // EYI_Salutation__c
        public String NameFirst; // EYI_First_Name__c+ +EYI_Middle_Name__c
        public String NameLast;    // EYI_Last_Name__c
        public String Sexid;    // EYI_Gender__cEYI_Gender__c
        public String Marst;    //EYI_Marital_Status__c
        public String Sort1;    //EYI_First_Name__c+ +EYI_Middle_Name__c
        public String Sort2;    //"Broker" //Need to confirmed
        public String Natio;    //EYI_Country__c
        public String Jobgr;    //EYI_Occupation__c
        public String Organization;    //EYI_Organization__c
        public String Designation;    //EYI_Designation__c
        public String Birthdt;    //EYI_Birth_Date__c
        public String Deathdt;    //EYI_Anniversary_Date__c
        public String Bukrs;    //EYI_Company_Code__c
        public String Akont;    //EYI_Reconciliation_Account__c
        public String Zuawa;    //MAPPING NOT FOUND
        public String Zterm;    //EYI_Payment_Terms__c
        public String Zwels;    //Need to confirmed NOT FOUND
        public String Mindk;    //Not required //EYI_Minority_Indicator__c
        public String Cerdt;    //Not required //EYI_MSME__c
        public String Ekorg;    //MAPPING NOT FOUND
        public String Waers;    //MAPPING NOT FOUND
        public String Inco1;    //MAPPING NOT FOUND
        public String J1ipanno;    //MAPPING NOT FOUND
        public String VenClass;    //MAPPING NOT FOUND
        public String Gstin;    //EYI_GSTIN__c
        public String Pdf;    //MAPP with Attachement
        public String EInvoicing;//EYI_E_Invoicing_Applicable__c
        public String MsmeInd;//EYI_Is_MSME__c
        public String MsmeNo;//EYI_MSME_Number__c
        public cls_Vendorid[] Vendorid;
        public cls_Addr[] Addr;
        public cls_Comm[] Comm;
        public ContactPerson[] ContactPerson;
        public Bankdetail[] Bankdetail;//NEW MAP
        

        // Constructor for cls_ImVendor to initialize fields to default values
        public cls_ImVendor() {
            this.TestRun = '';
            this.Type = '';
            this.Lifnr = '';
            this.BuGroup = '';
            this.TitleMedi = '';
            this.NameFirst = '';
            this.NameLast = '';
            this.Sexid = '';
            this.Marst = '';
            this.Sort1 = '';
            this.Sort2 = '';
            this.Natio = '';
            this.Jobgr = '';
            this.Organization = '';
            this.Designation = '';
            this.Birthdt = '';
            this.Deathdt = '';
            this.Bukrs = '';
            this.Akont = '';
            this.Zuawa = '';
            this.Zterm = '';
            this.Zwels = '';
            this.Mindk = '';
            this.Cerdt = '';
            this.Ekorg = '';
            this.Waers = '';
            this.Inco1 = '';
            this.J1ipanno = '';
            this.VenClass = '';
            this.Gstin = '';
            this.Pdf = '';
            this.MsmeInd = '';
            this.MsmeNo = '';
            this.EInvoicing = '';
            this.Vendorid = new cls_Vendorid[0];  // Initialize as an empty array
            this.Addr = new cls_Addr[0];  // Initialize Addr as a new instance
            this.Comm = new cls_Comm[0];  // Initialize as an empty array
            this.ContactPerson = new ContactPerson[0];  // Initialize as an empty array
            this.Bankdetail = new Bankdetail[0];  // Initialize as an empty array
        }
    }

    public class cls_Vendorid {
        public String Idtype;    // MAPPING NOT FOUND 
        public String Idnumber;    //"EYI_Aadhar__c ? EYI_Udyog_Adhar__c ? EYI_Company_Regisration__c ? EYI_ESIC_Number__c ? EYI_RERA_Number__c

        // Constructor for cls_Vendorid to initialize fields to default values
        public cls_Vendorid() {
            this.Idtype = '';
            this.Idnumber = '';
        }
    }

    public class cls_Addr {
        public String Seqno;    // MAPPING NOT FOUND 
        public String Street;    //EYI_Address1__c FIELD WAS NOT PRESENT
        public String StrSuppl3;    // EYI_Address2__c
        public String Location;    //EYI_Address3__c FIELD WAS NOT PRESENT
        public String City2;    // MAPPING NOT FOUND 
        public String PostCode1;    // MAPPING NOT FOUND 
        public String City1;    //EYI_City__r.Name
        public String Country;    //EYI_Country__c
        public String Region;    //EYI_Region__c
        public String Langu;    // MAPPING NOT FOUND 
        public String TimeZone;    // MAPPING NOT FOUND 
        public String Transpzone;    // MAPPING NOT FOUND
        public String AddrType; //NEW MAP

        // Constructor for cls_Addr to initialize fields to default values
        public cls_Addr() {
            this.Seqno = '';
            this.Street = '';
            this.StrSuppl3 = '';
            this.Location = '';
            this.City2 = '';
            this.PostCode1 = '';
            this.City1 = '';
            this.Country = '';
            this.Region = '';
            this.Langu = '';
            this.TimeZone = '';
            this.Transpzone = '';
        }
    }

    public class cls_Comm {
        public String TelExtens;    // MAPPING NOT FOUND 
        public String TelNumber;    // MAPPING NOT FOUND 
        public String SmtpAddr;    // MAPPING NOT FOUND 
        public String MobNumber;    // MAPPING NOT FOUND MIGHT BE EYI_Mobile__c IF PRESENT EYI_Alternate_Mobile__c SEND IN SECOND ARRAY
        public String Country;

        // Constructor for cls_Comm to initialize fields to default values
        public cls_Comm() {
            this.TelExtens = '';
            this.TelNumber = '';
            this.SmtpAddr = '';
            this.MobNumber = '';
            this.Country = '';
        }
    }
    
    public class ContactPerson{
       public String Firstname;
       public String Lastname;
       public String TitleKey;
       public String Tel1Numbr;
       public String Email;
        
        public ContactPerson(){
       this.Firstname = '';
       this.Lastname= '';
       this.TitleKey= '';
       this.Tel1Numbr ='';
       this.Email= '';
            
        }
    }
    
    public class Bankdetail{
        public String Bkvid;//''001'
        public String BankCtry;
        public String BankKey;
        public String BankAcct;
        public String Accountholder;
        public String BankRef;
        public String Bankaccountname;
        public String BANKDETAILVALIDFROM;
        public String BANKDETAILVALIDTO;
        
        public Bankdetail(){
             this.Bkvid = '';//''001'
            this.BankCtry= '';
            this.BankKey= '';
            this.BankAcct= '';
            this.Accountholder= '';
            this.BankRef= '';
            this.Bankaccountname= '';
            this.Bankdetailvalidfrom ='';
            this.Bankdetailvalidto = '';
            
        }

    }
    
   
    
}