@isTest
private class EYI_ZSDDemandResponseWrapperTest {

    @isTest
    static void testParseJson() {
        // Prepare sample JSON string matching the structure
        String sampleJson = '{' +
            '"n0_ZSD_DEMAND_FROM_SFResponse": {' +
                '"EX_OUTPUT": {' +
                    '"item": [' +
                        '{' +
                            '"TYPE": "TYPE1",' +
                            '"KUNNR": "123456",' +
                            '"VBELN": "0000123456",' +
                            '"VBELN_VF": "0000654321",' +
                            '"VKORG": "1000",' +
                            '"VTWEG": "10",' +
                            '"MATNR": "MAT123",' +
                            '"POSNR": "0010",' +
                            '"FKDAT": "2025-07-11",' +
                            '"NETWR": "1000.00",' +
                            '"TAX": "100.00",' +
                            '"PRINCIPAL": "Principal1",' +
                            '"CHARGES": "50.00",' +
                            '"TIMEBOUND": "Yes",' +
                            '"MLBEZ": "ML01",' +
                            '"MLBEZ_DESC": "Description1",' +
                            '"WAERS": "USD",' +
                            '"MLSTN": "MS01",' +
                            '"CUSTOM1": "C1",' +
                            '"CUSTOM2": "C2",' +
                            '"CUSTOM3": "C3",' +
                            '"MSGTYPE": "S",' +
                            '"ID": "MSG001",' +
                            '"MESSAGE": "Success"' +
                        '}' +
                    ']' +
                '}' +
            '}' +
        '}';

        // Parse JSON
        EYI_ZSDDemandResponseWrapper wrapper = EYI_ZSDDemandResponseWrapper.parse(sampleJson);

        // Validate outer object
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.n0_ZSD_DEMAND_FROM_SFResponse);

        // Validate EX_OUTPUT and item list
        EYI_ZSDDemandResponseWrapper.EX_OUTPUT exOutput = wrapper.n0_ZSD_DEMAND_FROM_SFResponse.EX_OUTPUT;
        System.assertNotEquals(null, exOutput);
        System.assertNotEquals(null, exOutput.item);
        System.assertEquals(1, exOutput.item.size());

        // Validate individual item values
        EYI_ZSDDemandResponseWrapper.Item item = exOutput.item[0];
        System.assertEquals('TYPE1', item.TYPE);
        System.assertEquals('123456', item.KUNNR);
        System.assertEquals('0000123456', item.VBELN);
        System.assertEquals('MSG001', item.ID);
        System.assertEquals('Success', item.MESSAGE);
    }
}