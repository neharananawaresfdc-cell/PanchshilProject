@isTest
private class EYI_SalesDataCreationWrapperTest {

    @isTest
    static void testSalesDataWrapperInitialization() {
        EYI_SalesDataCreationWrapper wrapper = new EYI_SalesDataCreationWrapper();
        System.assertNotEquals(null, wrapper.salesData);
        System.assertEquals('', wrapper.salesData.ZZ_SALES);
        System.assertEquals('', wrapper.salesData.ZZ_MSEB_NO);
        System.assertEquals('', wrapper.salesData.ZZ_PIPE_GAS_CNUM);
        System.assertEquals('', wrapper.salesData.ZZ_PROPERTY_TAX_NUMBER);
        System.assertEquals('', wrapper.salesData.ZZ_FRANKING_DATE);
        System.assertEquals('', wrapper.salesData.ZZ_STAMP_DUTY);
        System.assertEquals('', wrapper.salesData.ZZ_PARK_ISSUE_LTR);
        System.assertEquals('', wrapper.salesData.ZZ_RESALE_NOC);
        System.assertEquals('', wrapper.salesData.ZZ_ROC_DATE);
        System.assertEquals('', wrapper.salesData.ZZ_NOC_DATE);
        System.assertEquals('', wrapper.salesData.ZZ_PAY_PROJECT);
        System.assertEquals('', wrapper.salesData.POSNR);
        System.assertEquals('', wrapper.salesData.MATNR);
        System.assertEquals('', wrapper.salesData.KWMENG);
        System.assertEquals('', wrapper.salesData.ZIEME);
        System.assertEquals('', wrapper.salesData.KPOSN);
        System.assertEquals('', wrapper.salesData.KSCHL);
        System.assertEquals('', wrapper.salesData.KBETR);
        System.assertEquals('', wrapper.salesData.TIMEBOUND);
        System.assertEquals('', wrapper.salesData.MLBEZ);
        System.assertEquals('', wrapper.salesData.MLBEZ_DESC);
        System.assertEquals('', wrapper.salesData.FKDAT);
        System.assertEquals('', wrapper.salesData.FPROZ);
        System.assertEquals('', wrapper.salesData.FAKWR);
        System.assertEquals('', wrapper.salesData.WAERS);
        System.assertEquals('', wrapper.salesData.MLSTN);
        System.assertEquals('', wrapper.salesData.VBELN);
        System.assertEquals('', wrapper.salesData.MESSAGE);
    }
}