@isTest
public class PricingCreationWrapperTest {

    @isTest
    static void testWrapperInitialization() {
        // Instantiate the wrapper class
        EYI_PricingCreationWrapper wrapper = new EYI_PricingCreationWrapper();

        // Check that the I_MASTER is initialized
        System.assertNotEquals(null, wrapper.I_MASTER);

        // Check that the item list is not null and empty
        System.assertNotEquals(null, wrapper.I_MASTER.item);
        System.assertEquals(0, wrapper.I_MASTER.item.size());
    }

    @isTest
    static void testDefaultClsItem() {
        // Instantiate the cls_item with default constructor
        EYI_PricingCreationWrapper.cls_item item = new EYI_PricingCreationWrapper.cls_item();

        // Check default values
        System.assertEquals('', item.KSCHL);
        System.assertEquals('', item.VKORG);
        System.assertEquals('', item.WERKS);
        System.assertEquals('', item.VTWEG);
        System.assertEquals('', item.MATNR);
        System.assertEquals(0.0, item.KBETR);
        System.assertEquals('EA', item.KMEIN);
        System.assertEquals('', item.KPEIN);
        System.assertEquals('', item.KRECH);
        System.assertEquals('01-01-2025', item.DATAB);
        System.assertEquals('01-01-2025', item.DATBI);
    }
}