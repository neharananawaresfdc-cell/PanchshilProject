// Wrapper Class
public class EYI_TDSCustomerCreationWrapper {
    public TdsReportAPI TdsReportAPI;

    // Model Class
    public class TdsReportAPI {
        public FilterItemWrapper CompanyCode;
        public FilterItemWrapper CustomerNo;
        public FilterItemWrapper SalesOrderNo;
        public FilterItemWrapper SalesOrg;
        public FilterItemWrapper UnitCode;
    }

    // Wrapper for Filter Items
    public class FilterItemWrapper {
        public List<FilterItem> item;
    }

    // Filter Item Class
    public class FilterItem {
        public String SIGN;
        public String OPTION;
        public String LOW;
        public String HIGH;

        public FilterItem(String value) {
            this.SIGN = 'I';
            this.OPTION = 'EQ';
            this.LOW = value;
            this.HIGH = '';
        }
    }
}