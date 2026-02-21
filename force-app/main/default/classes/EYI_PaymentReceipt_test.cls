@isTest
public class EYI_PaymentReceipt_test {
@isTest
    public static void testSyncPaymentReceipt() {
        
        String jsonString = '{' +
    '   "ReceiptStatus": [' +
    '       {' +
    '           "ReceivableDeskTrackingNumber": "4000000013",' +
    '           "ReceivableDeskDocumentVersion": 0,' +
    '           "SapCompanyCode": "1330",' +
    '           "HouseBank": "HDF01",' +
    '           "AccountId": "85805",' +
    '           "ShortKey": 6948,' +
    '           "GlAccount": "0010503780",' +
    '           "StatementNumber": 17,' +
    '           "MemoRecordNumber": 1,' +
    '           "StatementDate": "2024-01-12",' +
    '           "BusinessTransCode": "",' +
    '           "SapTransaction": "ZINC",' +
    '           "BankPaymentConfirmationDate": "2024-01-12",' +
    '           "PaymentConfirmedAmountFromSAP": 16791402.57,' +
    '           "Coareacurrency": "INR",' +
    '           "AccountType": "",' +
    '           "Account": "",' +
    '           "SapDocumentNumber": "",' +
    '           "FiscalYear": 0,' +
    '           "IsReversed": "",' +
    '           "CompanyName": "",' +
    '           "Reference": "",' +
    '           "Assignment": "",' +
    '           "Checknumber": "",' +
    '           "DepartmentID": "",' +
    '           "DepartmentName": "",' +
    '           "Description": "HDFC#57500000685805",' +
    '           "Site": "",' +
    '           "SiteName": "",' +
    '           "PaymentStatus": "MAILSENT",' +
    '           "SapCustomerNumber": "",' +
    '           "SapCustomerNumber_NAME": "",' +
    '           "SapPaymentAdviceNumber": "0424071211042589",' +
    '           "PDF": "",' +
    '           "InitialRemark": "TEST1",' +
    '           "AttachmentRemark": "",' +
    '           "ChangeRemark": "",' +
    '           "RecvDeskCreatedDate": "2024-07-01",' +
    '           "RecvDeskCreatedBy": "SACHIN",' +
    '           "RecvDeskCreatedTime": "17:36:31",' +
    '           "RecvDeskChangedOn": "",' +
    '           "RecvDeskChangedBy": "",' +
    '           "RecvDeskChangedTime": "2:20:10",' +
    '           "AttachedOn": "",' +
    '           "AttachedBy": "",' +
    '           "AttachedAt": "10:20:30",' +
    '           "DmsDocType": "",' +
    '           "DmsDocNo": "",' +
    '           "DmsDocPart": "",' +
    '           "RecvDeskProcessedDate": "",' +
    '           "RecvDeskProcessedBy": "",' +
    '           "RecvDeskProcessedTime": "10:20:20",' +
    '           "SapReasonCode": "",' +
    '           "SapReasonDescription": "",' +
    '           "SapRejectionHoldRemarks": "",' +
    '           "DelayWRTCreation": "243",' +
    '           "SapDocumentNumber_BRS": "",' +
    '           "BankPostingDate": "",' +
    '           "RecvDeskApprovedBy": "",' +
    '           "RecvDeskApprovedDate": "",' +
    '           "RecvDeskApprovedTime": "8:20:10",' +
    '           "RecvDeskCreatedByName": "Sachin Indulkar",' +
    '           "RecvDeskChangedByName": "",' +
    '           "ProcessedBy": "",' +
    '           "RecvDeskApprovedByName": ""' +
    '       }' +
    '   ]' +
    '}';
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        EYI_PaymentReceipt.createPaymentReceipts();
        EYI_PaymentReceitStatusWrapper wrper = new EYI_PaymentReceitStatusWrapper();
        Test.stopTest();
        
    }
}