@isTest
public class EYI_SAP_ReportResponseWrapperTest {
    @isTest
    static void testParseWithValidJson() {
        String jsonString = '{'+
            '"message": {"Message": "Success"},'+
            '"output": {'+
                '"item": ['+
                    '{'+
                        '"SalesDocument": "SD001",'+
                        '"SOLineItem": "10",'+
                        '"CustomerNo": "CUST001",'+
                        '"CustomerName": "John Doe",'+
                        '"Material": "MAT001",'+
                        '"MaterialDescription": "Material Desc",'+
                        '"ReconAccount": "RA001",'+
                        '"ReconAccountDescription": "Recon Desc",'+
                        '"TotalConsideration": "1000",'+
                        '"ActualBasicBillAmount": "900",'+
                        '"DebitAmount": "100",'+
                        '"TaxAmount": "50",'+
                        '"BilledAndDebitNoteAmt": "950",'+
                        '"ReceivedAmt": "800",'+
                        '"OutstandingAmt": "150",'+
                        '"ProfitCenter": "PC001",'+
                        '"ReasonForRejection": "None",'+
                        '"Plant": "Plant1",'+
                        '"Flat": "Flat1",'+
                        '"SalesOrg": "SO001",'+
                        '"SalesOrgDesc": "Sales Org Desc",'+
                        '"CompanyName": "Company1",'+
                        '"DistributionChannel": "DC001",'+
                        '"Area": "Area1",'+
                        '"BookingDate": "2024-01-01",'+
                        '"Rejection": "No",'+
                        '"ProfitCenterName": "PC Name",'+
                        '"BuildingName": "Building1",'+
                        '"CreditAmount": "0",'+
                        '"AfterDeductionBasicBill": "850",'+
                        '"AgreementExecutionDate": "2024-01-02",'+
                        '"AgreementHandoverDate": "2024-01-03",'+
                        '"AgreementReceivedDate": "2024-01-04",'+
                        '"AgreementRegNo": "REG001",'+
                        '"SalesDeedNo": "SDN001",'+
                        '"RegistrationDate": "2024-01-05",'+
                        '"CancellationDate": null,'+
                        '"CancellationInitiatedBy": null,'+
                        '"SalesType": "Type1",'+
                        '"PropertyTaxNumber": "PTN001",'+
                        '"FrankingDate": "2024-01-06",'+
                        '"StampDutyAmountSD": "10",'+
                        '"StampDutyAmountFI": "5",'+
                        '"PaymentProject": "PP001",'+
                        '"CRMMapped": "Yes",'+
                        '"NameOfCRMMapped": "CRM Name"'+
                    '}'+
                ']'+
            '}'+
        '}';
        EYI_SAP_ReportResponseWrapper wrapper = EYI_SAP_ReportResponseWrapper.parse(jsonString);
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.message);
        System.assertEquals('Success', wrapper.message.Message);
        System.assertNotEquals(null, wrapper.output);
        System.assertNotEquals(null, wrapper.output.item);
        System.assertEquals(1, wrapper.output.item.size());
        EYI_SAP_ReportResponseWrapper.Item item = wrapper.output.item[0];
        System.assertEquals('SD001', item.SalesDocument);
        System.assertEquals('John Doe', item.CustomerName);
        System.assertEquals('MAT001', item.Material);
        System.assertEquals('CRM Name', item.NameOfCRMMapped);
    }

    @isTest
    static void testParseWithEmptyJson() {
        String jsonString = '{}';
        EYI_SAP_ReportResponseWrapper wrapper = EYI_SAP_ReportResponseWrapper.parse(jsonString);
        System.assertNotEquals(null, wrapper);
        System.assertEquals(null, wrapper.message);
        System.assertEquals(null, wrapper.output);
    }

    @isTest
    static void testParseWithPartialJson() {
        String jsonString = '{"message": {"Message": "Partial"}}';
        EYI_SAP_ReportResponseWrapper wrapper = EYI_SAP_ReportResponseWrapper.parse(jsonString);
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.message);
        System.assertEquals('Partial', wrapper.message.Message);
        System.assertEquals(null, wrapper.output);
    }

    @isTest
    static void testParseWithMultipleItems() {
        String jsonString = '{'+
            '"output": {'+
                '"item": ['+
                    '{"SalesDocument": "SD001"},'+
                    '{"SalesDocument": "SD002"}'+
                ']'+
            '}'+
        '}';
        EYI_SAP_ReportResponseWrapper wrapper = EYI_SAP_ReportResponseWrapper.parse(jsonString);
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.output);
        System.assertEquals(2, wrapper.output.item.size());
        System.assertEquals('SD001', wrapper.output.item[0].SalesDocument);
        System.assertEquals('SD002', wrapper.output.item[1].SalesDocument);
    }
}