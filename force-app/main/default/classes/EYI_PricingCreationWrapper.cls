public class EYI_PricingCreationWrapper {
    
    /* //public List<cls_item> item;
public I_MASTER I_MASTER;
// Constructor for the outer class (optional)
public EYI_PricingCreationWrapper() {
// public list<item> item; 

this.I_MASTER = new I_MASTER();  // Initialize inner class
}
public class I_MASTER{
public list<cls_item> item; 
}
//public List<EReturn> E_RETURN;
*/
    public IMaster I_MASTER;
    
    // Constructor for the outer class
    public EYI_PricingCreationWrapper() {
        this.I_MASTER = new IMaster();
    }
    
    public class IMaster {
        public list<cls_item> item;
        
        // Constructor for IMaster
        public IMaster() {
            this.item = new cls_item[0]; // Initialize as an empty array
        }
    }
    
    public class cls_item{
        public String KSCHL;
        public String VKORG;
        public String WERKS;
        public String VTWEG;
        public String MATNR;
        public Decimal KBETR;
        public String KMEIN;
        //public Integer KPEIN;
        public string KPEIN;
        public String KRECH;
        //public Date DATAB;
        public string DATAB;
        //public Date DATBI;
        public string DATBI;
        
        // public EReturn(){
        public cls_item(){
            
            this.KSCHL = '';
            this.VKORG= '';
            this.WERKS= '';
            this.VTWEG= '';
            this.MATNR= '';//depend on inventory
            this.KBETR= 0.0;
            this.KMEIN= '';//inventory 
            this.KPEIN ='';
            this.KRECH= '';
            
            Date today = System.today();
            String day = String.valueOf(today.day()).leftPad(2, '0');
            String month = String.valueOf(today.month()).leftPad(2, '0');
            String year = String.valueOf(today.year());
            
            String formattedDate = day + '-' + month + '-' + year;
            System.debug('Formatted Date: ' + formattedDate);
            
            this.DATAB = formattedDate;
            this.DATBI= '31-12-9999';//string.valueof(system.today());
            
            
        }
        //public EReturn(EYI_Rate_List__c pricingRecord){
        public cls_item(EYI_Rate_List__c pricingRecord){
            this.KSCHL = pricingRecord.EYI_Condition_Type__c;
            this.VKORG = pricingRecord.EYI_Project__r.EYI_SAP_Salesorg__c;
            this.WERKS = pricingRecord.EYI_Project__r.EYI_SAP_Plant_Code__c;
            this.MATNR = pricingRecord.EYI_Project_Unit__r.EYI_Unit_SAP_Code__c;
            //this.KBETR;
            //this.KMEIN;
            //this.KPEIN;
            //this.KRECH = pricingRecord.EYI_Calculation_Type__c;
        }
    }
    
    
}