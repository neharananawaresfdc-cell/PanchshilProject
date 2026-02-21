@isTest
public class EYI_TDSCustomerCreationWrapperTest {
    @isTest
    static void testFilterItemConstructor() {
        String testValue = 'TestValue';
        EYI_TDSCustomerCreationWrapper.FilterItem item = new EYI_TDSCustomerCreationWrapper.FilterItem(testValue);
        System.assertEquals('I', item.SIGN, 'SIGN should be I');
        System.assertEquals('EQ', item.OPTION, 'OPTION should be EQ');
        System.assertEquals(testValue, item.LOW, 'LOW should be set to the constructor value');
        System.assertEquals('', item.HIGH, 'HIGH should be empty');
    }

    @isTest
    static void testFilterItemWrapper() {
        EYI_TDSCustomerCreationWrapper.FilterItem item1 = new EYI_TDSCustomerCreationWrapper.FilterItem('A');
        EYI_TDSCustomerCreationWrapper.FilterItem item2 = new EYI_TDSCustomerCreationWrapper.FilterItem('B');
        EYI_TDSCustomerCreationWrapper.FilterItemWrapper wrapper = new EYI_TDSCustomerCreationWrapper.FilterItemWrapper();
        wrapper.item = new List<EYI_TDSCustomerCreationWrapper.FilterItem>{item1, item2};
        System.assertEquals(2, wrapper.item.size(), 'Wrapper should contain 2 items');
        System.assertEquals('A', wrapper.item[0].LOW, 'First item LOW should be A');
        System.assertEquals('B', wrapper.item[1].LOW, 'Second item LOW should be B');
    }

    @isTest
    static void testTdsReportAPI() {
        EYI_TDSCustomerCreationWrapper.TdsReportAPI api = new EYI_TDSCustomerCreationWrapper.TdsReportAPI();
        api.CompanyCode = new EYI_TDSCustomerCreationWrapper.FilterItemWrapper();
        api.CustomerNo = new EYI_TDSCustomerCreationWrapper.FilterItemWrapper();
        api.SalesOrderNo = new EYI_TDSCustomerCreationWrapper.FilterItemWrapper();
        api.SalesOrg = new EYI_TDSCustomerCreationWrapper.FilterItemWrapper();
        api.UnitCode = new EYI_TDSCustomerCreationWrapper.FilterItemWrapper();

        api.CompanyCode.item = new List<EYI_TDSCustomerCreationWrapper.FilterItem>{
            new EYI_TDSCustomerCreationWrapper.FilterItem('C1')
        };
        api.CustomerNo.item = new List<EYI_TDSCustomerCreationWrapper.FilterItem>{
            new EYI_TDSCustomerCreationWrapper.FilterItem('Cust1')
        };

        System.assertEquals('C1', api.CompanyCode.item[0].LOW, 'CompanyCode LOW should be C1');
        System.assertEquals('Cust1', api.CustomerNo.item[0].LOW, 'CustomerNo LOW should be Cust1');
    }

    @isTest
    static void testWrapperInstantiation() {
        EYI_TDSCustomerCreationWrapper wrapper = new EYI_TDSCustomerCreationWrapper();
        wrapper.TdsReportAPI = new EYI_TDSCustomerCreationWrapper.TdsReportAPI();
        System.assertNotEquals(null, wrapper, 'Wrapper instance should not be null');
        System.assertNotEquals(null, wrapper.TdsReportAPI, 'TdsReportAPI instance should not be null');
    }
}