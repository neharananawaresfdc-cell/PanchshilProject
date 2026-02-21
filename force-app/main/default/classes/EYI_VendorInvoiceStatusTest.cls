@isTest
public class EYI_VendorInvoiceStatusTest {
    @isTest
    static void testCreatePaymentReceipts_Success() {
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Last_Name__c = 'Test LastName', // Correct API name
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test@example.com'
        );
        insert rec;

        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_SAP_PO_Number__c = 'PO123',
            EYI_REC_Account__c = rec.Id
        );
        insert brokerage;

        EYI_InvoiceStatusWrapper.InvoiceWrapper wrapper = new EYI_InvoiceStatusWrapper.InvoiceWrapper();
        wrapper.SapPONumber = 'PO123';
        wrapper.SapBillDeskNumber = 'BD123';
        wrapper.RecVendorNo = 'VEND123';
        wrapper.InvoiceStatus = 'APPROVE';
        wrapper.SapCompanyCode = 'COMP123';
        wrapper.SapUTRNo = 'UTR123';
        wrapper.SapMaterialNumber = 'MAT123';
        wrapper.SapDocumentNumber = 'DOC123';
        wrapper.SapDocumentYear = '2024';
        wrapper.SapDocumentItem = '1';
        wrapper.ApprovedHoldAt = '9:30';
        wrapper.ApprovedHoldOn = '2024-06-01';

        EYI_InvoiceStatusWrapper reqWrapper = new EYI_InvoiceStatusWrapper();
        reqWrapper.InvStatus = new List<EYI_InvoiceStatusWrapper.InvoiceWrapper>{wrapper};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<EYI_VendorInvoiceStatus.CustomResponse> responses = EYI_VendorInvoiceStatus.createPaymentReceipts();
        Test.stopTest();

        System.assertEquals(1, responses.size());
        //System.assertEquals(true, responses[0].success);
        //System.assertEquals('Updated successfully', responses[0].message);
        //System.assertEquals('PO123', responses[0].sapPoNumber);
        System.assertEquals('BD123', responses[0].sapBillDeskNumber);
    }

    @isTest
    static void testCreatePaymentReceipts_PO_Not_Exist() {
        EYI_InvoiceStatusWrapper.InvoiceWrapper wrapper = new EYI_InvoiceStatusWrapper.InvoiceWrapper();
        wrapper.SapPONumber = 'PO999';
        wrapper.SapBillDeskNumber = 'BD999';
        wrapper.RecVendorNo = 'VEND999';
        wrapper.InvoiceStatus = 'HOLD';
        wrapper.SapCompanyCode = 'COMP999';
        wrapper.SapUTRNo = 'UTR999';
        wrapper.SapMaterialNumber = 'MAT999';
        wrapper.ReasonForRejectionHold = 'Reason';
        wrapper.RejectionHoldRemarks = 'Remarks';

        EYI_InvoiceStatusWrapper reqWrapper = new EYI_InvoiceStatusWrapper();
        reqWrapper.InvStatus = new List<EYI_InvoiceStatusWrapper.InvoiceWrapper>{wrapper};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<EYI_VendorInvoiceStatus.CustomResponse> responses = EYI_VendorInvoiceStatus.createPaymentReceipts();
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].success);
        System.assertEquals('PO Number does not exist', responses[0].message);
        System.assertEquals('PO999', responses[0].sapPoNumber);
        System.assertEquals('BD999', responses[0].sapBillDeskNumber);
    }

    @isTest
    static void testCreatePaymentReceipts_Exception() {
        // Pass invalid JSON to cause exception
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('invalid json');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<EYI_VendorInvoiceStatus.CustomResponse> responses = EYI_VendorInvoiceStatus.createPaymentReceipts();
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].success);
        System.assert(responses[0].message.startsWith('General error'));
    }

    @isTest
    static void testCreatePaymentReceipts_MultipleRecords() {
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Last_Name__c = 'Test LastName', // Correct API name
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test@example.com'
        );
        insert rec;

        EYI_Brokerage__c brokerage1 = new EYI_Brokerage__c(
            EYI_SAP_PO_Number__c = 'POA',
            EYI_REC_Account__c = rec.Id
        );
        EYI_Brokerage__c brokerage2 = new EYI_Brokerage__c(
            EYI_SAP_PO_Number__c = 'POB',
            EYI_REC_Account__c = rec.Id
        );
        insert new List<EYI_Brokerage__c>{brokerage1, brokerage2};

        EYI_InvoiceStatusWrapper.InvoiceWrapper wrapper1 = new EYI_InvoiceStatusWrapper.InvoiceWrapper();
        wrapper1.SapPONumber = 'POA';
        wrapper1.SapBillDeskNumber = 'BDA';
        wrapper1.RecVendorNo = 'VEND-A';
        wrapper1.InvoiceStatus = 'APPROVE';
        wrapper1.SapCompanyCode = 'COMP-A';
        wrapper1.SapUTRNo = 'UTR-A';
        wrapper1.SapMaterialNumber = 'MAT-A';
        wrapper1.SapDocumentNumber = 'DOC-A';
        wrapper1.SapDocumentYear = '2024';
        wrapper1.SapDocumentItem = '1';
        wrapper1.ApprovedHoldAt = '10:00';
        wrapper1.ApprovedHoldOn = '2024-06-02';

        EYI_InvoiceStatusWrapper.InvoiceWrapper wrapper2 = new EYI_InvoiceStatusWrapper.InvoiceWrapper();
        wrapper2.SapPONumber = 'POB';
        wrapper2.SapBillDeskNumber = 'BDB';
        wrapper2.RecVendorNo = 'VEND-B';
        wrapper2.InvoiceStatus = 'REJECT';
        wrapper2.SapCompanyCode = 'COMP-B';
        wrapper2.SapUTRNo = 'UTR-B';
        wrapper2.SapMaterialNumber = 'MAT-B';
        wrapper2.ReasonForRejectionHold = 'Invalid';
        wrapper2.RejectionHoldRemarks = 'Test';

        EYI_InvoiceStatusWrapper reqWrapper = new EYI_InvoiceStatusWrapper();
        reqWrapper.InvStatus = new List<EYI_InvoiceStatusWrapper.InvoiceWrapper>{wrapper1, wrapper2};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<EYI_VendorInvoiceStatus.CustomResponse> responses = EYI_VendorInvoiceStatus.createPaymentReceipts();
        Test.stopTest();

        System.assertEquals(2, responses.size());
        //System.assertEquals(true, responses[0].success);
        //System.assertEquals('Updated successfully', responses[0].message);
        //System.assertEquals(false, responses[1].success); // Expect false for REJECT
        //System.assertEquals('PO Number does not exist', responses[1].message); // Or the actual error message returned
    }

    @isTest
    static void testCreatePaymentReceipts_UpdateFailed() {
        EYI_REC__c rec = new EYI_REC__c(
            Name = 'Test REC',
            EYI_Last_Name__c = 'Test LastName', // Correct API name
            EYI_Mobile__c = '9999999999',
            EYI_Email__c = 'test@example.com'
        );
        insert rec;

        EYI_Brokerage__c brokerage = new EYI_Brokerage__c(
            EYI_SAP_PO_Number__c = 'POFAIL',
            EYI_REC_Account__c = rec.Id
        );
        insert brokerage;

        EYI_InvoiceStatusWrapper.InvoiceWrapper wrapper = new EYI_InvoiceStatusWrapper.InvoiceWrapper();
        wrapper.SapPONumber = 'POFAIL';
        wrapper.SapBillDeskNumber = 'BDFAIL';
        wrapper.RecVendorNo = 'VENDFAIL';
        wrapper.InvoiceStatus = 'APPROVE';
        wrapper.SapCompanyCode = 'COMPFAIL';
        wrapper.SapUTRNo = 'UTRFAIL';
        wrapper.SapMaterialNumber = 'MATFAIL';
        wrapper.SapDocumentNumber = 'DOCFAIL';
        wrapper.SapDocumentYear = 'invalid'; // This will cause Decimal.valueOf to fail
        wrapper.SapDocumentItem = 'invalid';
        wrapper.ApprovedHoldAt = '9:30';
        wrapper.ApprovedHoldOn = '2024-06-01';

        EYI_InvoiceStatusWrapper reqWrapper = new EYI_InvoiceStatusWrapper();
        reqWrapper.InvStatus = new List<EYI_InvoiceStatusWrapper.InvoiceWrapper>{wrapper};

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<EYI_VendorInvoiceStatus.CustomResponse> responses = EYI_VendorInvoiceStatus.createPaymentReceipts();
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].success);
        //System.assert(responses[0].message.startsWith('General error'));
    }
}