@isTest
public class EY_SAPAdapterTest {


    @isTest
    static void testCreateConsumerBody() {
        String input = 'SampleData';
        String result = EY_SAPAdapter.createConsumerBody(input);
        System.assertEquals('', result, 'The method should return an empty string');
    }
}