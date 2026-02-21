@isTest
public class EYI_BookingDataWrapperTest {
    
    @isTest
    static void testEYIBookingDataWrapperInitialization() {

        EYI_BookingDataWrapper wrapper = new EYI_BookingDataWrapper();

        EYI_BookingDataWrapper.BookingData data = wrapper.BOOKINGDATA;

        data.SalesOrderNo = 'SO123';
        data.CustomerNo = 'CUST001';
        data.SalesOrg = 'SO01';
        data.Division = 'DIV01';
        data.PlantCode = 'PLNT1';
        data.SalesOffice = 'SOFF1';
        data.SalesGroup = 'SG01';
        data.OpportunityNumber = 'OPP123';
        data.BookingDate = '2025-01-01';
        data.CancellationReason = 'TestReason';
        data.ActualBookingDate = '2025-01-02';
        data.WarrantyDate = '2026-01-01';
        data.Pdf = 'base64PDFString';

        EYI_BookingDataWrapper.MaterialDetail mat = new EYI_BookingDataWrapper.MaterialDetail();
        mat.ItemNumberSD = '10';
        mat.MaterialNumber = 'MAT001';
        mat.Quantity = 2;
        mat.UnitOfMeasure = 'EA';
        data.MaterialDetails.add(mat);

        EYI_BookingDataWrapper.Condition cond = new EYI_BookingDataWrapper.Condition();
        cond.ConditionItemNumber = '10';
        cond.ConditionType = 'Discount';
        cond.ConditionAmount = '100';
        data.Conditions.add(cond);

        EYI_BookingDataWrapper.PaymentPlan pay = new EYI_BookingDataWrapper.PaymentPlan();
        pay.DateType = 'D1';
        pay.Usage = 'Installment';
        pay.UsageDescription = 'Down Payment';
        pay.BillingDate = '2025-02-01';
        pay.PercentageToBeInvoiced = '10%';
        pay.ValueToBeCalculatedOnDate = '10000';
        pay.CurrencyKey = 'INR';
        pay.MilestoneNumber = 'MS001';
        data.PaymentPlan.add(pay);

        EYI_BookingDataWrapper.PartnerFunction partner = new EYI_BookingDataWrapper.PartnerFunction();
        partner.PartnerFunction = 'Sold-To Party';
        partner.CustomerNumber = 'CUST002';
        data.PartnerFunction.add(partner);

        EYI_BookingDataWrapper.AdditionalData add = new EYI_BookingDataWrapper.AdditionalData();
        add.AgrmentExecutionDate = '2025-01-03';
        add.LoanAmount = '500000';
        add.NOCIssueDate = '2025-03-01';
        add.PaymentProject = 'ProjectX';
        data.Additional = add;

        System.assertEquals('SO123', data.SalesOrderNo);
        System.assertEquals(1, data.MaterialDetails.size());
        System.assertEquals(1, data.Conditions.size());
        System.assertEquals(1, data.PaymentPlan.size());
        System.assertEquals(1, data.PartnerFunction.size());
        System.assertEquals('500000', data.Additional.LoanAmount);
    }
}