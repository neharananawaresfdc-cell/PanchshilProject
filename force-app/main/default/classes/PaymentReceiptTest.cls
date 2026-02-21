@isTest
public class PaymentReceiptTest {

    @isTest
    public static void testPaymentMethod(){
        EYI_Payment_Receipt__c receipt = new EYI_Payment_Receipt__c(
         //   Name = 'Receipt1',
            EYI_Amount__c = 100,
            EYI_Payment_Status__c = 'SUBMITTED'
            //EYI_Opportunity__c = testOpportunity.Id
        );
        insert receipt;
        receipt.EYI_Payment_Status__c ='APPROVE';
        update receipt;

    }
}