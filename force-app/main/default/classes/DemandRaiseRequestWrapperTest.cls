@isTest
public class DemandRaiseRequestWrapperTest {
    @isTest
    static void testDemandRaiseAPIConstructorDefaults() {
        DemandRaiseRequestWrapper.DemandRaiseAPI apiObj = new DemandRaiseRequestWrapper.DemandRaiseAPI();
        System.assertEquals('', apiObj.TypeOfAction, 'TypeOfAction should be empty');
        System.assertEquals('', apiObj.CustomerNo, 'CustomerNo should be empty');
        System.assertEquals('', apiObj.SalesOrderNo, 'SalesOrderNo should be empty');
        System.assertEquals('', apiObj.SapBillingDocNo, 'SapBillingDocNo should be empty');
        System.assertEquals('', apiObj.SalesOrg, 'SalesOrg should be empty');
        System.assertEquals('', apiObj.DistributionChannel, 'DistributionChannel should be empty');
        System.assertEquals('', apiObj.UnitCode, 'UnitCode should be empty');
        System.assertEquals('', apiObj.SalesOrderLineItemNo, 'SalesOrderLineItemNo should be empty');
        System.assertEquals('', apiObj.BillingDate, 'BillingDate should be empty');
        System.assertEquals('', apiObj.TotalDemandAmount, 'TotalDemandAmount should be empty');
        System.assertEquals('', apiObj.TaxValue, 'TaxValue should be empty');
        System.assertEquals('', apiObj.PrincipalValue, 'PrincipalValue should be empty');
        System.assertEquals('', apiObj.OtherCharges, 'OtherCharges should be empty');
        System.assertEquals('', apiObj.DateType, 'DateType should be empty');
        System.assertEquals('', apiObj.Usage, 'Usage should be empty');
        System.assertEquals('', apiObj.UsageDescription, 'UsageDescription should be empty');
        System.assertEquals('', apiObj.CurrencyKey, 'CurrencyKey should be empty');
        System.assertEquals('', apiObj.MilestoneNumber, 'MilestoneNumber should be empty');
        System.assertEquals('', apiObj.AdditionalParameter1, 'AdditionalParameter1 should be empty');
        System.assertEquals('', apiObj.AdditionalParameter2, 'AdditionalParameter2 should be empty');
        System.assertEquals('', apiObj.AdditionalParameter3, 'AdditionalParameter3 should be empty');
    }

    @isTest
    static void testDemandRaiseRequestWrapperListAssignment() {
        DemandRaiseRequestWrapper wrapper = new DemandRaiseRequestWrapper();
        wrapper.DemandRaiseAPI = new List<DemandRaiseRequestWrapper.DemandRaiseAPI>();
        DemandRaiseRequestWrapper.DemandRaiseAPI apiObj = new DemandRaiseRequestWrapper.DemandRaiseAPI();
        apiObj.TypeOfAction = 'Create';
        apiObj.CustomerNo = 'C123';
        wrapper.DemandRaiseAPI.add(apiObj);
        System.assertEquals(1, wrapper.DemandRaiseAPI.size(), 'List should contain one element');
        System.assertEquals('Create', wrapper.DemandRaiseAPI[0].TypeOfAction, 'TypeOfAction should match');
        System.assertEquals('C123', wrapper.DemandRaiseAPI[0].CustomerNo, 'CustomerNo should match');
    }
}