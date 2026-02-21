@isTest
public class EYI_RECInventoryCreationWrapperTest {
    @isTest
    static void testWrapperInitialization() {
        EYI_RECInventoryCreationWrapper wrapper = new EYI_RECInventoryCreationWrapper();
        
        System.assertNotEquals(null, wrapper.IM_INPUT, 'IM_INPUT list should be initialized');
        
        EYI_RECInventoryCreationWrapper.cls_ImInput input = new EYI_RECInventoryCreationWrapper.cls_ImInput();
        input.MATNR = 'TestMATNR';
        input.MAKTX = 'Test Description';
        input.MEINS = 'EA';
        input.WERKS = '1000';
        input.TAX_CLASS = 'TX1';

        wrapper.IM_INPUT.add(input);
        
        System.assertEquals('TestMATNR', wrapper.IM_INPUT[0].MATNR);
        System.assertEquals('Test Description', wrapper.IM_INPUT[0].MAKTX);
        System.assertEquals('EA', wrapper.IM_INPUT[0].MEINS);
        System.assertEquals('1000', wrapper.IM_INPUT[0].WERKS);
        System.assertEquals('TX1', wrapper.IM_INPUT[0].TAX_CLASS);
    }
    
}