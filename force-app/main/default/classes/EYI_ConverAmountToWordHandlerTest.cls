@isTest
private class EYI_ConverAmountToWordHandlerTest {

    @isTest
    static void testZeroAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(0);
        System.assertEquals('Zero', result, 'Zero amount should return "Zero"');
    }

    @isTest
    static void testSingleDigitAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(7);
        System.assertEquals('Seven', result, 'Single digit should be converted correctly');
    }

    @isTest
    static void testTensAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(42);
        System.assertEquals('Forty Two', result, 'Tens and units should be combined correctly');
    }

    @isTest
    static void testHundredsAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(315);
        System.assertEquals('Three hundred Fifteen', result, 'Hundreds should be formatted correctly');
    }

    @isTest
    static void testThousandsAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(1234);
        System.assertEquals('One thousand, Two hundred Thirty Four', result, 'Thousands should be formatted correctly');
    }

    @isTest
    static void testLakhsAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(123456);
        System.assertEquals('One lakh, Twenty Three thousand, Four hundred Fifty Six', result, 'Lakhs should be formatted correctly');
    }

    @isTest
    static void testCroresAmount() {
        String result = EYI_ConverAmountToWordHandler.convertToIndianWords(12345678);
        System.assertEquals('One crore, Twenty Three lakh, Forty Five thousand, Six hundred Seventy Eight', result, 'Crores should be formatted correctly');
    }
}