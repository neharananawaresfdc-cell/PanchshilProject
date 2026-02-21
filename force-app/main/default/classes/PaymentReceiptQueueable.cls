public class PaymentReceiptQueueable implements Queueable, Database.AllowsCallouts {
    private List<Map<String, Object>> updatedRecords;
    private Map<String, Object> formData;

    public PaymentReceiptQueueable(List<Map<String, Object>> updatedRecords, Map<String, Object> formData) {
        this.updatedRecords = updatedRecords;
        this.formData = formData;
    }

    public void execute(QueueableContext context) {
        HttpResponse hr = EY_SAP_Gateway.sendPayementReceipt(null, updatedRecords, formData);

        // Retrieve the Payment Receipt record using the ID from formData
        Id receiptId = (Id) formData.get('paymentReceiptId');
        EYI_Payment_Receipt__c paymentReceipt = [SELECT Id, EYI_SAP_Error__c FROM EYI_Payment_Receipt__c WHERE Id = :receiptId LIMIT 1];

        // Process response & update record
        //EYI_SAP_PaymentReceiptSyncLwcController.processPaymentResponse(hr, paymentReceipt);
    }
}