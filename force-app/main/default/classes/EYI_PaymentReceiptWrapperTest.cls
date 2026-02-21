@isTest
private class EYI_PaymentReceiptWrapperTest {

    @isTest
    static void testWrapperInstantiation() {
        // Create wrapper instance
        EYI_PaymentReceiptWrapper wrapper = new EYI_PaymentReceiptWrapper();
        
        // Create inner PaymentAdvice instance
        wrapper.PaymentAdvice = new EYI_PaymentReceiptWrapper.PaymentAdvice();
        wrapper.PaymentAdvice.TransactionType = 'IN';
        wrapper.PaymentAdvice.CompanyCode = 'EYI001';
        wrapper.PaymentAdvice.SapCustomerNumber = '123456';
        wrapper.PaymentAdvice.CurrencyKey = 'INR';
        wrapper.PaymentAdvice.PaymentDate = '2024-05-09';
        wrapper.PaymentAdvice.PaymentAmount = '10000';
        wrapper.PaymentAdvice.CustomerBankName = 'Test Bank';
        wrapper.PaymentAdvice.BankReferenceNumber = 'BRN123456';
        wrapper.PaymentAdvice.MaterialCode = 'MAT001';
        wrapper.PaymentAdvice.PaymentAdviceAccountType = 'C';
        wrapper.PaymentAdvice.PaymentAdviceNumber = 'PA12345';
        wrapper.PaymentAdvice.PaymentDocumentNumber = 'PD12345';
        wrapper.PaymentAdvice.PaymentAdviceType = 'Standard';
        wrapper.PaymentAdvice.PaymentAdviceStatus = 'Processed';
        wrapper.PaymentAdvice.PaymentAdviceHoldIndicator = 'N';
        wrapper.PaymentAdvice.RuleForPaymentAdvice = 'StandardRule';
        wrapper.PaymentAdvice.CustomHeaderField1 = 'Header1';
        wrapper.PaymentAdvice.CustomHeaderField2 = 'Header2';
        wrapper.PaymentAdvice.CustomHeaderField3 = 'Header3';

        // Create line item
        EYI_PaymentReceiptWrapper.LineItem item = new EYI_PaymentReceiptWrapper.LineItem();
        item.Reference1 = 'Ref1';
        item.Reference2 = 'Ref2';
        item.Reference3 = 'Ref3';
        item.CustomerReference = 'CustRef';
        item.Reference = 'Ref';
        item.DocumentInvoiceDate = '2024-05-08';
        item.AccountDocumentNumber = 'ADN001';
        item.DocumentYear = '2024';
        item.CustRefLineItem = 'CRI001';
        item.PartialPaymentAmount = '5000';
        item.BillingDocumentNumber = 'BD123';
        item.TaxCode = 'GST';
        item.ProfitCenter = 'PC001';
        item.CustomItemField1 = 'Item1';
        item.CustomItemField2 = 'Item2';
        item.CustomItemField3 = 'Item3';

        // Add line item to the list
        wrapper.PaymentAdvice.LineItems.add(item);

        // Assert wrapper fields to verify values were set properly
        System.assertEquals('IN', wrapper.PaymentAdvice.TransactionType);
        System.assertEquals(1, wrapper.PaymentAdvice.LineItems.size());
        System.assertEquals('Ref1', wrapper.PaymentAdvice.LineItems[0].Reference1);
    }
}